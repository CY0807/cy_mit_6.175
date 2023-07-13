import Fifo::*;
import CacheTypes::*;

module mkMessageFifo(MessageFifo#(n));
    Fifo#(n, CacheMemReq) fifo_req <- mkCFFifo;
    Fifo#(n, CacheMemResp) fifo_resp <- mkCFFifo;

    method Action enq_resp(CacheMemResp d);
        fifo_resp.enq(d);
    endmethod

    method Action enq_req(CacheMemReq d);
        fifo_req.enq(d);
    endmethod

    method Bool hasResp = fifo_resp.notEmpty;

    method Bool hasReq = fifo_req.notEmpty;

    method Bool notEmpty;
        return fifo_resp.notEmpty || fifo_req.notEmpty;
    endmethod

    method Bool respNotFull;
        return fifo_resp.notFull;
    endmethod

    method CacheMemMessage first;
        if(fifo_resp.notEmpty) begin
            return tagged Resp fifo_resp.first;
        end
        else begin
            return tagged Req fifo_req.first;
        end
    endmethod

    method Action deq;
        if(fifo_resp.notEmpty) begin
            fifo_resp.deq;
        end
        else begin
            fifo_req.deq;
        end
    endmethod

endmodule