import Ehr::*;
import Vector::*;

interface Fifo#(type t);
    method Bool notFull;
    method Action enq(t x);
    method Bool notEmpty;
    method Action deq;
    method t first;
endinterface

// Pipeline FIFO
module mkMyPipelineFifo(Fifo#(t)) provisos (Bits#(t,tSz));
    Reg#(t) data <- mkRegU();
    Ehr#(2,Bool) empty <- mkEhr(True);
    Ehr#(2,Bool) full <- mkEhr(False);

    method Bool notEmpty;
        return !empty[0];
    endmethod

    method t first if (empty[0]==False);
        return data;
    endmethod

    method Action deq if (empty[0]==False);
        empty[0] <= True;
        full[0] <= False;
    endmethod

    method Bool notFull;
        return !full[1];
    endmethod

    method Action enq(t x) if (full[1]==False);
        full[1] <= True;
        empty[1] <= False;
        data <= x;
    endmethod   
endmodule

// Bypass FIFO
module mkMyBypassFifo(Fifo#(t)) provisos (Bits#(t,tSz));
    Reg#(t) data <- mkRegU();
    Ehr#(2,Bool) empty <- mkEhr(True);
    Ehr#(2,Bool) full <- mkEhr(False);

    method Bool notFull;
        return !full[0];
    endmethod

    method Action enq(t x) if (full[0]==False);
        full[0] <= True;
        empty[0] <= False;
        data <= x;
    endmethod

    method Bool notEmpty;
        return !empty[1];
    endmethod

    method Action deq if (empty[1]==False);
        empty[1] <= True;
        full[1] <= False;
    endmethod

    method t first if (empty[1]==False);
        return data;
    endmethod
endmodule


// Confilc Free FIFO
module mkMyCFFifo(Fifo#(t)) provisos (Bits#(t,tSz));
    Vector#(2, Reg#(t)) data <- replicateM(mkRegU());
    Reg#(Bool) empty <- mkReg(True);
    Reg#(Bool) full <- mkReg(False);
    Reg#(Bit#(2)) cnt <- mkReg(0);
    Ehr#(2, Maybe#(t)) enqReq <- mkEhr(tagged Invalid);
    Ehr#(2, Bool) deqReq <- mkEhr(False);
    
    rule canonicalize;
        deqReq[1] <= False;
        enqReq[1] <= tagged Invalid;

        case (tuple2(enqReq[1], deqReq[1])) matches
            {tagged Valid .dat, True}: begin
                data[1] <= dat;
            end
            {tagged Valid .dat, False}: begin
                cnt <= cnt + 1;
                if(cnt == 0) begin
                    data[1] <= dat;
                    empty <= False;
                end
                else begin
                    data[0] <= dat;
                    full <= True;
                end
            end
            {tagged Invalid, True}: begin
                cnt <= cnt - 1;
                if(cnt == 2) begin
                    data[1] <= data[0];
                    full <= False;
                end
                else begin
                    empty <= True;
                end
            end
            default: begin end
        endcase  
    endrule

    method Bool notFull;
        return !full;
    endmethod

    method Bool notEmpty;
        return !empty;
    endmethod

    method t first if (empty==False);
        return data[1]; 
    endmethod

    method Action enq(t x) if (full==False);
        enqReq[0] <= tagged Valid x; 
    endmethod

    method Action deq if (empty==False);
        deqReq[0] <= True;
    endmethod

endmodule
