import CacheTypes::*;
import Vector::*;
import FShow::*;
import MemTypes::*;
import Types::*;
import ProcTypes::*;
import Fifo::*;
import Ehr::*;
import RefTypes::*;
import StQ::*;

typedef enum {
    HandleCoreReq, 
    StartMiss, 
    SendReq2Mem, 
    WaitMemResp, 
    Resp2Core
} CacheStatus deriving(Eq, Bits);

module mkDCacheStQ#(CoreID id) (
    MessageGet fromMem,
    MessagePut toMem,
    RefDMem refDMem,
    DCache ifc
    );

    // Store Queue
    StQ#(StQSize) stq <- mkStQ;

    // cache data
    Vector#(CacheRows, Reg#(CacheLine)) dataArray <- replicateM(mkRegU);
    Vector#(CacheRows, Reg#(CacheTag)) tagArray <- replicateM(mkRegU);
    Vector#(CacheRows, Reg#(MSI)) msiArray <- replicateM(mkReg(I));

    // fifos between core
    Fifo#(2, Data) respQ <- mkBypassFifo;
    Fifo#(2, MemReq) reqQ <- mkCFFifo;

    // functional regs
    Reg#(MemReq) missReq <- mkRegU;
    Reg#(CacheStatus) stateReg <- mkReg(HandleCoreReq);
    Reg#(Maybe#(CacheLineAddr)) linkAddr <- mkReg(Invalid);

    // check whether status of linkAddr is normal
    function Bool isLinkAddrOK(Addr req_addr);
        Bool state = True;
        if (!isValid(linkAddr)) begin
            state = False;
        end
        else if (fromMaybe(?, linkAddr) != getLineAddr(req_addr)) begin
            state = False;
        end
        return state;
    endfunction

    // A Lr or Sc request can start processing only when the store queue is empty
    rule doLoad if (stateReg == HandleCoreReq && (reqQ.first.op == Ld || (reqQ.first.op == Lr && !stq.notEmpty)));    
        let req = reqQ.first;       
        let sel = getWordSelect(req.addr);
        let idx = getIndex(req.addr);
        let tag = getTag(req.addr);
        reqQ.deq;
       
        let data = stq.search(req.addr);
        Bool hit = False;
        // hit from store queue
        if (isValid(data)) begin
            respQ.enq(fromMaybe(?, data));
            refDMem.commit(req, Invalid, data);
            hit = True;
        end
        // hit from data cache
        else if (tagArray[idx] == tag && msiArray[idx] > I) begin
                respQ.enq(dataArray[idx][sel]);
                refDMem.commit(req, Valid(dataArray[idx]), Valid(dataArray[idx][sel]));
                hit = True;
        end
        // cache miss
        else begin
            missReq <= req;
            stateReg <= StartMiss;
        end

        if (hit && req.op == Lr) begin
            linkAddr <= tagged Valid getLineAddr(req.addr);
        end
    endrule

    // A St request are always enqueued into the store queue
    rule doStore if (reqQ.first.op == St);
        let req = reqQ.first;
        reqQ.deq;
        stq.enq(req);
    endrule

    // A Lr or Sc request can start processing only when the store queue is empty
    rule doSc if (stateReg == HandleCoreReq && reqQ.first.op == Sc && !stq.notEmpty);
        let req = reqQ.first;
        let sel = getWordSelect(req.addr);
        let idx = getIndex(req.addr);
        let tag = getTag(req.addr);
        reqQ.deq;

        if (isLinkAddrOK(req.addr)) begin
            // hit
            if (tagArray[idx] == tag && msiArray[idx] > I) begin
                // directly write cache
                if (msiArray[idx] == M) begin
                    respQ.enq(scSucc);
                    dataArray[idx][sel] <= req.data;
                    refDMem.commit(req, Valid(dataArray[idx]), Valid(scSucc));
                    linkAddr <= Invalid;
                end
                // send upgrade req to mem
                else begin
                    missReq <= req;
                    stateReg <= SendReq2Mem;
                end
            end
            else begin
                missReq <= req;
                stateReg <= StartMiss;
            end
        end
        else begin
            respQ.enq(scFail);
            refDMem.commit(req, Invalid, Valid(scFail));
            linkAddr <= Invalid;
        end
    endrule

    rule doFence (stateReg == HandleCoreReq && reqQ.first.op == Fence && !stq.notEmpty);
        reqQ.deq;
        refDMem.commit(reqQ.first, Invalid, Invalid);
    endrule

    rule doStartMiss if (stateReg == StartMiss);
        let req = missReq;
        let idx = getIndex(req.addr);     
        let sel = getWordSelect(req.addr);
        let tag = getTag(req.addr);

        // voluntary downgrade
        if (msiArray[idx] != I) begin
            msiArray[idx] <= I;
            Maybe#(CacheLine) data = Invalid;
            if (msiArray[idx] == M) begin 
                // write back dirty data
                data = tagged Valid dataArray[idx];
            end
            let old_tag = tagArray[idx];
            toMem.enq_resp( CacheMemResp {
                child: id,
                addr: {old_tag, idx, sel, 2'b0},
                state: I,
                data: data
            } );
        end

        // linkAddr should be set to Invalid when cache miss happens
        if (isLinkAddrOK(missReq.addr)) begin
            linkAddr <= Invalid;
        end

        stateReg <= SendReq2Mem;
    endrule

    rule doSendReq2Mem if (stateReg == SendReq2Mem);
        let req = missReq;

        // send upgrade req to mem
        MSI des_state = (missReq.op == Ld || missReq.op == Lr) ? S : M;
        toMem.enq_req( CacheMemReq {
            child: id,
            addr: req.addr,
            state: des_state
        } );

        stateReg <= WaitMemResp;
    endrule

    rule doWaitMemResp if (stateReg == WaitMemResp && fromMem.hasResp);
        let resp = fromMem.first.Resp;
        let idx = getIndex(missReq.addr);
        let tag = getTag(missReq.addr);
        let sel = getWordSelect(missReq.addr);
        fromMem.deq;
        
        // original data in cache/memory
        CacheLine data;
        if (isValid(resp.data)) begin
            data = fromMaybe(?, resp.data);
        end
        else begin
            data = dataArray[idx];
        end

        // deal with op
        if (missReq.op == Sc) begin
            if(isLinkAddrOK(missReq.addr)) begin                   
                let old_data = data;               
                data[sel] = missReq.data; 
                refDMem.commit(missReq, Valid(old_data), Valid(scSucc));   
                respQ.enq(scSucc);            
            end
            else begin
                refDMem.commit(missReq, Invalid, Valid(scFail));
                respQ.enq(scFail);
            end
            linkAddr <= Invalid;
        end
        else if (missReq.op == St) begin
            let old_data = data; 
            refDMem.commit(missReq, Valid(old_data), Invalid); 
            data[sel] = missReq.data;
            stq.deq;
        end

        // update cache data
        dataArray[idx] <= data;
        tagArray[idx] <= tag;
        msiArray[idx] <= resp.state;
        stateReg <= Resp2Core;
    endrule

    rule doResp2Core if (stateReg == Resp2Core);
        let req = missReq;
        let idx = getIndex(req.addr);     
        let sel = getWordSelect(req.addr);
        
        if (missReq.op == Ld || missReq.op == Lr) begin
            if (req.op == Lr) begin
                linkAddr <= tagged Valid getLineAddr(missReq.addr);
            end
            respQ.enq(dataArray[idx][sel]);
            refDMem.commit(missReq, tagged Valid dataArray[idx], tagged Valid dataArray[idx][sel]);
        end

        stateReg <= HandleCoreReq;
    endrule

    rule doHandleDownGradeReqFromMem if (!fromMem.hasResp && fromMem.hasReq && stateReg != Resp2Core); 
        let req = fromMem.first.Req;
        let idx = getIndex(req.addr);     
        let state = req.state;
        fromMem.deq;
        
        if (msiArray[idx] > state) begin
            msiArray[idx] <= state;

            // write back dirty data
            Maybe#(CacheLine) data = Invalid;
            if (msiArray[idx] == M) begin
                data = tagged Valid dataArray[idx];
            end

            // send resp
            toMem.enq_resp( CacheMemResp {
                child: id,
                addr: req.addr,
                state: state,
                data: data
            } );

            if (state == I) begin
                linkAddr <= Invalid;
            end
        end
    endrule

    rule mvStqToCache if (stateReg == HandleCoreReq && (!reqQ.notEmpty || reqQ.first.op != Ld));
        let req <- stq.issue;
        let sel = getWordSelect(req.addr);
        let idx = getIndex(req.addr);
        let tag = getTag(req.addr);

        // cache hit
        if (tagArray[idx] == tag && msiArray[idx] > I) begin
            // directly write
            if (msiArray[idx] == M) begin                
                dataArray[idx][sel] <= req.data;
                refDMem.commit(req, Valid(dataArray[idx]), Invalid);
                stq.deq;
                /* if (isLinkAddrOK(req.addr)) begin
                    linkAddr <= Invalid;
                end */
            end
            // send upgrade req to mem
            else begin
                missReq <= req;
                stateReg <= SendReq2Mem;
            end
        end
        // cache miss
        else begin
            missReq <= req;
            stateReg <= StartMiss;
        end
    endrule

    method Action req(MemReq r);
        reqQ.enq(r);
        refDMem.issue(r);
    endmethod

    method ActionValue#(MemResp) resp;
        respQ.deq;
        return respQ.first;
    endmethod

endmodule


