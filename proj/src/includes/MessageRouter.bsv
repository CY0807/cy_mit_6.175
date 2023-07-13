import Vector::*;
import CacheTypes::*;
import MessageFifo::*;
import Types::*;

module mkMessageRouter(
    Vector#(CoreNum, MessageGet) c2r, 
    Vector#(CoreNum, MessagePut) r2c, 
    MessageGet m2r, 
    MessagePut r2m,
    Empty ifc 
);
    Reg#(CoreID) cache_start <- mkReg(0);

    rule cache2parent;
        CoreID cache_select = 0;
        CoreID cache_iter = 0;
        Bool got_msg = False;
        Bool msg_is_rsp = False;

        // do rout: found the right core with the right message
        for (Integer i=0; i<valueOf(CoreNum); i=i+1) begin

            Bit#(TLog#(TAdd#(CoreNum,1))) tmp_iter = zeroExtend(cache_select+fromInteger(i));
            Bit#(TLog#(TAdd#(CoreNum,1))) max_iter = fromInteger(valueOf(CoreNum));
            tmp_iter = tmp_iter % max_iter;
            $display("%b", tmp_iter);
            cache_iter = truncate(tmp_iter);

            let cache_tmp = c2r[cache_iter];

            if (cache_tmp.hasResp && !msg_is_rsp) begin
                got_msg = True;
                msg_is_rsp = True;
                cache_select = cache_iter;
            end
            else if (cache_tmp.hasReq && !got_msg) begin
                got_msg = True;
                cache_select = cache_iter;
            end
        end

        // send message
        if (got_msg) begin
            let msg = c2r[cache_select].first;
            if(msg_is_rsp) begin
                r2m.enq_resp(msg.Resp);
            end
            else begin
                r2m.enq_req(msg.Req);
            end
            c2r[cache_select].deq;
        end

        // change start core
        CoreID core_max = fromInteger(valueOf(CoreNum)-1);
        if (cache_start == core_max) begin
            cache_start <= 0;
        end
        else begin
            cache_start <= cache_start + 1;
        end
    endrule


    rule parent2cache;
        CacheMemMessage msg = m2r.first;
        m2r.deq;
        case (msg) matches
            tagged Resp .resp : r2c[resp.child].enq_resp(resp);
            tagged Req .req : r2c[req.child].enq_req(req);
        endcase
    endrule

endmodule