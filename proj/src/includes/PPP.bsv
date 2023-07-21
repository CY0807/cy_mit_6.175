import ProcTypes::*;
import MemTypes::*;
import Types::*;
import CacheTypes::*;
import MessageFifo::*;
import Vector::*;
import FShow::*;

typedef enum {
    SendResp2Child,
    SendDownReq,
    WaitMemData_Resp
} ChidReqHandleState deriving(Bits, Eq, FShow);

module mkPPP(MessageGet c2m, MessagePut m2c, WideMem mem, Empty ifc);

    Vector#(CoreNum, Vector#(CacheRows, Reg#(MSI))) childState <- replicateM(replicateM(mkReg(I)));
    Vector#(CoreNum, Vector#(CacheRows, Reg#(CacheTag))) childTag <- replicateM(replicateM(mkRegU));
    Vector#(CoreNum, Vector#(CacheRows, Reg#(Bool))) wait_for_downgrade <- replicateM(replicateM(mkReg(False)));

    Reg#(ChidReqHandleState) stateReg <- mkReg(SendDownReq);

    function Bool isCompatible(MSI cur, MSI next);
        return (cur == I || next == I || (cur == S && next == S));
    endfunction

    rule doSendDownReq if (stateReg == SendDownReq && !c2m.hasResp);
        let req = c2m.first.Req;
        let addr = req.addr;
        let idx = getIndex(addr);
        let tag = getTag(addr);
        let req_core = req.child;
        let req_state = req.state;

        // choose one child
        CoreID core_select = 0;
        Bool core_selected = False;
        for (Integer i=0; i<valueOf(CoreNum); i=i+1) begin
            CoreID des_core = fromInteger(i);
            if (req_core != des_core) begin
                MSI des_core_state = (childTag[des_core][idx] == tag) ? childState[des_core][idx] : I;
                if (!isCompatible(des_core_state, req_state) && !wait_for_downgrade[des_core][idx]) begin
                    if (!core_selected) begin
                        core_selected = True;
                        core_select = des_core;
                    end
                end
            end
        end

        //send downgrade req
        if (core_selected) begin
            wait_for_downgrade[core_select][idx] <= True;
            m2c.enq_req(CacheMemReq {
                child: core_select,
                addr: addr,
                state: (req_state == M ? I : S)
            } );
        end
        else begin // all child downgrade complete
            stateReg <= SendResp2Child;
        end
    endrule

    rule doSendResp2Child if (stateReg == SendResp2Child && !c2m.hasResp);
        let req = c2m.first.Req;
        let addr = req.addr;
        let idx = getIndex(addr);
        let tag = getTag(addr);
        let req_core = req.child;
        let req_state = req.state;
 
        // to check if req's upgrad is compatible and no child is doing downGrade
        Bool safe = True;
        for(Integer i=0; i<valueOf(CoreNum); i=i+1) begin
            CoreID des_core = fromInteger(i);
            if (req_core != des_core) begin
                MSI des_core_state = (childTag[des_core][idx] == tag) ? childState[des_core][idx] : I;
                if (!isCompatible(des_core_state, req_state) || wait_for_downgrade[req_core][idx]) begin
                    safe = False;
                end
            end
        end

        if(safe) begin
            MSI core_state = (childTag[req_core][idx] == tag) ? childState[req_core][idx] : I;
            Bool hit = core_state != I;
            if(hit) begin 
                // send resp               
                m2c.enq_resp(CacheMemResp {
                    child: req_core,
                    addr: addr,
                    state: req_state,
                    data: Invalid
                } );
                // update parent data
                childState[req_core][idx] <= req_state;
                childTag[req_core][idx] <= tag;
                // deq message fifo
                c2m.deq;
                // change state
                stateReg <= SendDownReq;
            end
            else begin
                // send req to mem
                mem.req(WideMemReq {
                        write_en: '0,
                        addr: addr,
                        data: ? 
                } );
                // change state
                stateReg <= WaitMemData_Resp;
            end
        end
    endrule

    rule doWaitMemData_Resp if (stateReg == WaitMemData_Resp && !c2m.hasResp);
        let req = c2m.first.Req;
        let addr = req.addr;
        let idx = getIndex(addr);
        let tag = getTag(addr);
        let req_core = req.child;
        let req_state = req.state;
        let mem_data <- mem.resp();

        // send resp               
        m2c.enq_resp(CacheMemResp {
            child: req_core,
            addr: addr,
            state: req_state,
            data: Valid(mem_data)
        } );
        // update parent data
        childState[req_core][idx] <= req.state;
        childTag[req_core][idx] <= tag;
        // deq message fifo
        c2m.deq;
        // change state
        stateReg <= SendDownReq;
    endrule


    rule doHandleResp if (c2m.hasResp); // deal with child's voluntary downgrade
        let resp = c2m.first.Resp;
        let addr = resp.addr;
        let idx = getIndex(resp.addr);
        let tag = getTag(resp.addr);
        let resp_core = resp.child;
        let resp_state = resp.state;

        // write back dirty data
        MSI pre_state = (childTag[resp_core][idx] == tag) ? childState[resp_core][idx] : I;
        if (pre_state == M) begin
            Bit#(CacheLineWords) wr_en = '1;
            mem.req(WideMemReq {
                write_en: wr_en,
                addr: addr,
                data: fromMaybe(?, resp.data)
            } );
        end

        // update parent's directory
        childState[resp_core][idx] <= resp_state;
        childTag[resp_core][idx] <= tag;
        wait_for_downgrade[resp_core][idx] <= False;
        // deq c2m
        c2m.deq;
    endrule

endmodule