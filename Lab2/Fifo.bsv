/* Exercise 1 
Completes the code in Fifo.bsv to implements a 3-elements fifo with properly guarded methods.
*/

import Ehr::*;

interface Fifo#(numeric type n, type t);
    method Action enq(t x);
    method Action deq;
    method t first;
    method Bool notEmpty;
    method Bool notFull;
endinterface

module mkPiplineFifo3(Fifo#(3, t)) provisos (Bits#(t,tSz));
    Ehr#(2, t) d0 <- mkEhr(?);
    Ehr#(2, Bool) v0 <- mkEhr(False);
    Ehr#(2, t) d1 <- mkEhr(?);
    Ehr#(2, Bool) v1 <- mkEhr(False);
    Ehr#(2, t) d2 <- mkEhr(?);
    Ehr#(2, Bool) v2 <- mkEhr(False);

    method Action enq(t x) if (!v0[1]);  
        if(!v2[1]) begin
            d2[1] <= x; v2[1] <= True;
        end
        else if(!v1[0]) begin
            d1[1] <= x; v1[1] <= True;
        end
        else begin      
            d0[1] <= x; v0[1] <= True;
        end
    endmethod

    method Action deq if (v2[0]);
        d2[0] <= d1[0]; v2[0] <= v1[0];
        d1[0] <= d0[0]; v1[0] <= v0[0];
        v0[0] <= False;
    endmethod

    method t first if (v2[0]);
        return d2[0]; 
    endmethod

    method Bool notEmpty;
        return v2[0];
    endmethod 

    method Bool notFull;
        return !v0[0];
    endmethod
endmodule


module mkBypassFifo3(Fifo#(3, t)) provisos (Bits#(t,tSz));
    Ehr#(2, t) d0 <- mkEhr(?);
    Ehr#(2, Bool) v0 <- mkEhr(False);
    Ehr#(2, t) d1 <- mkEhr(?);
    Ehr#(2, Bool) v1 <- mkEhr(False);
    Ehr#(2, t) d2 <- mkEhr(?);
    Ehr#(2, Bool) v2 <- mkEhr(False);

    method Action enq(t x) if (!v0[0]);  
        if(!v2[0]) begin
            d2[0] <= x; v2[0] <= True;
        end
        else if(!v1[0]) begin
            d1[0] <= x; v1[0] <= True;
        end
        else begin      
            d0[0] <= x; v0[0] <= True;
        end
    endmethod

    method Action deq if (v2[1]);
        v2[1] <= v1[1]; d2[1] <= d1[1];
        v1[1] <= v0[1]; d1[1] <= d0[1];
        v0[1] <= False;
    endmethod

    method t first if (v2[1]);
        return d2[1]; 
    endmethod

    method Bool notEmpty;
        return v2[0];
    endmethod 

    method Bool notFull;
        return !v0[0];
    endmethod
endmodule

module mkConflictFreeFifo3(Fifo#(3, t)) provisos (Bits#(t,tSz)); 
    Ehr#(2, t) d0 <- mkEhr(?);
    Ehr#(2, Bool) v0 <- mkEhr(False);
    Ehr#(2, t) d1 <- mkEhr(?);
    Ehr#(2, Bool) v1 <- mkEhr(False);
    Ehr#(2, t) d2 <- mkEhr(?);
    Ehr#(2, Bool) v2 <- mkEhr(False);

    rule canonicalize (!v2[1] && v1[1]);
        d2[1] <= d1[1]; v2[1] <= True;
        d1[1] <= d0[1]; v1[1] <= v0[1]; 
        v0[1] <= False;
    endrule

    method Action enq(t x) if (!v0[0]);  
        if(!v1[0]) begin
            d1[0] <= x; v1[0] <= True;
        end
        else begin      
            d0[0] <= x; v0[0] <= True;
        end
    endmethod

    method Action deq if (v2[0]);
        v2[0] <= False;
    endmethod

    method t first if (v2[0]);
        return d2[0]; 
    endmethod

    method Bool notEmpty;
        return v2[0];
    endmethod 

    method Bool notFull;
        return !v0[0];
    endmethod
endmodule

// TestBench

import Randomizable::*;
import SpecialFIFOs::*;
import FIFO::*;
import FIFOF::*;

(* synthesize *)
module mkTestBenchFifo(); 
    FIFOF#(Bit#(32)) referenceFifo <- mkSizedBypassFIFOF(3); Fifo#(3, Bit#(32)) testFifo <- mkBypassFifo3();
    //FIFO#(Bit#(32)) referenceFifo <- mkSizedFIFO(3); Fifo#(3, Bit#(32)) testFifo <- mkConflictFreeFifo3();
    Randomize#(Bit#(32)) randomVal1 <- mkGenericRandomizer;
    Reg#(Bool) init <- mkReg(False);
    Reg#(Bit#(32)) cycle_count <- mkReg(0);
    Reg#(Bit#(32)) delay <- mkReg(0);
    Reg#(Bit#(8)) stream_count <- mkReg(0);
    Reg#(Bit#(8)) feed_count <- mkReg(0);

    rule initialize(init == False);
        randomVal1.cntrl.init;
        init <= True;
    endrule

    rule feed (feed_count <128 && init);
       let el <- randomVal1.next;
       referenceFifo.enq(el);
       feed_count <= feed_count + 1;
       testFifo.enq(el);
       $display("Enqueuing %d in the tested fifo and the reference fifo",el);
    endrule

    rule pad (feed_count >= 128 && init);
       referenceFifo.enq(0);
       feed_count <= feed_count + 1;
       testFifo.enq(0);
    endrule

    rule stream (init);
        testFifo.deq();
        $display("Dequeue");
        stream_count <= stream_count + 1;
        referenceFifo.deq();
        let r = referenceFifo.first();
        let t = testFifo.first();
        if (t!=r) begin 
            $display("FAILED: We see %d in the reference fifo and %d in your fifo", r, t); 
            $finish; 
        end
    endrule

    rule finish(stream_count == 132);
        $display("PASSED");
        $finish();
    endrule

    rule deadlock (delay == 2000 && init );
        $display("FAILED It seems that your fifo is deadlocking, either we are failing to enqueue, or we enqueud some stuff in it but we can't dequeue from it.");
        $finish;
    endrule

    rule timeout (init);
        delay <= delay + 1;
        cycle_count <= cycle_count + 1;
    endrule
endmodule