import Ehr::*;
import Vector::*;

interface Fifo#(type t);
    method Bool notFull;
    method Action enq(t x);
    method Bool notEmpty;
    method Action deq;
    method t first;
    method Action clear;
endinterface

// Pipeline FIFO
// Combinational paths from inputs to outputs:
//   EN_deq -> notFull
//   EN_deq -> notFull -> RDY_enq -> EN_deq(previous fifo)
module mkMyPipelineFifo(Fifo#(t)) provisos (Bits#(t,tSz));
    Ehr#(2, t) data_ehr <- mkEhr(?); // 可以只用reg：Reg#(t) data_reg <- mkRegU();
    Ehr#(3, Bool) valid_ehr <- mkEhr(False);

    method Bool notEmpty;
        return valid_ehr[0];
    endmethod

    method t first if (valid_ehr[0]);
        return data_ehr[0]; // data_reg;
    endmethod

    method Action deq if (valid_ehr[0]);
        valid_ehr[0] <= False;
    endmethod

    method Bool notFull;
        return !valid_ehr[1];
    endmethod

    method Action enq(t x) if (!valid_ehr[1]);
        valid_ehr[1] <= True;
        data_ehr[1] <= x; // data_reg <= x;
    endmethod 

    method Action clear;
        valid_ehr[2] <= False;
    endmethod
endmodule

// Bypass FIFO
// Combinational paths from inputs to outputs:
//   EN_enq -> notEmpty
//   EN_enq -> notEmpty -> RDY_deq -> EN_enq(next fifo)
//   EN_enq -> RDY_first
module mkMyBypassFifo(Fifo#(t)) provisos (Bits#(t,tSz));
    Ehr#(2, t) data_ehr <- mkEhr(?);
    Ehr#(3, Bool) valid_ehr <- mkEhr(False);

    method Bool notFull;
        return !valid_ehr[0];
    endmethod

    method Action enq(t x) if (!valid_ehr[0]);
        valid_ehr[0] <= True;
        data_ehr[0] <= x;
    endmethod

    method Bool notEmpty;
        return valid_ehr[1];
    endmethod

    method Action deq if (valid_ehr[1]);
        valid_ehr[1] <= False;
    endmethod

    method t first if (valid_ehr[1]);
        return data_ehr[1];
    endmethod

    method Action clear;
        valid_ehr[2] <= False;
    endmethod
endmodule


// Confilc Free FIFO
// No combinational paths from inputs to outputs
module mkMyCFFifo(Fifo#(t)) provisos (Bits#(t,tSz));
    Vector#(2, Reg#(t)) data_reg <- replicateM(mkRegU());
    Reg#(Bool) empty_reg <- mkReg(True);
    Reg#(Bool) full_reg <- mkReg(False);
    Ehr#(2, Maybe#(t)) enqReq_ehr <- mkEhr(tagged Invalid);
    Ehr#(2, Bool) deqReq_ehr <- mkEhr(False);
    Ehr#(2, Bool) clearReq_ehr <- mkEhr(False);
    
    rule canonicalize;
        deqReq_ehr[1] <= False;
        enqReq_ehr[1] <= tagged Invalid;

        case (tuple3(enqReq_ehr[1], deqReq_ehr[1], clearReq_ehr[1])) matches
            {tagged Valid .dat, True, False}: begin
                data_reg[1] <= dat;
            end
            {tagged Valid .dat, False, False}: begin
                if(empty_reg) begin
                    data_reg[1] <= dat;
                    empty_reg <= False;
                end
                else begin
                    data_reg[0] <= dat;
                    full_reg <= True;
                end
            end
            {tagged Invalid, True, False}: begin
                if(full_reg) begin
                    data_reg[1] <= data_reg[0];
                    full_reg <= False;
                end
                else begin
                    empty_reg <= True;
                end
            end
            {.*, .*, True}: begin
                empty_reg <= True;
                full_reg <= False;
            end
            default: begin end
        endcase  
    endrule

    method Bool notFull;
        return !full_reg;
    endmethod

    method Bool notEmpty;
        return !empty_reg;
    endmethod

    method t first if (!empty_reg);
        return data_reg[1]; 
    endmethod

    method Action enq(t x) if (!full_reg);
        enqReq_ehr[0] <= tagged Valid x; 
    endmethod

    method Action deq if (!empty_reg);
        deqReq_ehr[0] <= True;
    endmethod

    method Action clear;
        clearReq_ehr[0] <= True;
    endmethod
endmodule

// modules without provisos for generating verilog

module mkBypassFifo(Fifo#(int));
    Fifo#(int) bypassFifo <- mkMyBypassFifo;
    return bypassFifo;
endmodule

module mkPipelineFifo(Fifo#(int));
    Fifo#(int) pipelineFifo <- mkMyPipelineFifo;
    return pipelineFifo;
endmodule

module mkCFFifo(Fifo#(int));
    Fifo#(int) cfFifo <- mkMyCFFifo;
    return cfFifo;
endmodule