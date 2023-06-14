import Randomizable::*;
import FIFOF::*;
import FIFO::*;
import SpecialFIFOs::*;
import ministFifo::*;
import Ehr::*;

typedef enum { Conflict, Pipeline, Bypass, CF } FifoType deriving(Eq);

////////////////////////
// Test Bench Templates

// This tests the functionality of the fifo considering enq, deq, and clear
module mkTbFunctionalTemplate( Fifo#(Bit#(m)) fifo, FifoType fifo_type, Empty ifc );
    FIFOF#(Bit#(m)) ref_fifo;
    if( fifo_type == Pipeline ) begin
        ref_fifo <- mkLFIFOF();
    end else if( fifo_type == Bypass ) begin
        ref_fifo <- mkBypassFIFOF();
    end else begin
        ref_fifo <- mkFIFOF();
    end
    // Various Counters
    Reg#(Bit#(32)) cycle <- mkReg(0);
    Reg#(Bit#(32)) input_count <- mkReg(0);
    Reg#(Bit#(32)) output_count <- mkReg(0);
    // Random Number Generators
    Randomize#(Bit#(2)) randomA <- mkGenericRandomizer;
    Randomize#(Bit#(2)) randomB <- mkGenericRandomizer;
    Randomize#(Bit#(4)) randomC <- mkGenericRandomizer;
    Randomize#(Bit#(m)) randomData <- mkGenericRandomizer;

    // Forces the order of the rules so the cycle boundary is printed first.
    // It is really confusing when the cycle_print rule fires in the middle of
    // the clock cycle.
    /*
    (* execution_order = "cycle_print, init" *)
    (* execution_order = "cycle_print, feed_inputs" *)
    (* execution_order = "cycle_print, check_outputs" *)
    (* execution_order = "cycle_print, maybe_clear" *)
    (* execution_order = "cycle_print, check_fifos_not_empty" *)
    (* execution_order = "cycle_print, check_fifos_not_full" *)
    (* execution_order = "cycle_print, check_fifos_first" *)
    (* execution_order = "cycle_print, stop_tb" *)
    (* execution_order = "cycle_print, cycle_inc" *)
    
    rule cycle_print;
        $display("= cycle %0d ====================", cycle);
        let a = cycle;
    endrule
    */

    rule init(cycle == 0);
        randomA.cntrl.init;
        randomB.cntrl.init;
        randomC.cntrl.init;
        randomData.cntrl.init;
    endrule
    
    rule feed_inputs (input_count < 1024);
        let rnd <- randomA.next;
        if( rnd != 0 ) begin // P = 3/4
            let a <- randomData.next;
            fifo.enq( a );
            ref_fifo.enq( a );
            //$display("\tEnqueued %0d", a);
            input_count <= input_count + 1;
        end
    endrule

    rule check_outputs;
        let rnd <- randomB.next;
        if( rnd != 0 ) begin // P = 3/4
            let b = fifo.first;
            fifo.deq;
            //$display("\tDequeued %0d", b);
            let c = ref_fifo.first;
            ref_fifo.deq;
            if( b != c ) begin
                $display("\tERROR: should have dequeued %0d", c);
                $finish;
            end
            output_count <= output_count + 1;
        end
    endrule

    rule check_fifos_not_full;
        if( ref_fifo.notFull != fifo.notFull ) begin
            if( fifo.notFull ) begin
                $display( "\tERROR: test fifo is not full but reference fifo is." );
                $finish;
            end else begin
                $display( "\tERROR: test fifo is full but reference fifo is not." );
                $finish;
            end
        end
    endrule

    rule check_fifos_not_empty;
        if( ref_fifo.notEmpty != fifo.notEmpty ) begin
            if( fifo.notEmpty ) begin
                $display( "\tERROR: test fifo is not empty but reference fifo is." );
                $finish;
            end else begin
                $display( "\tERROR: test fifo is empty but reference fifo is not." );
                $finish;
            end
        end
    endrule

    (* descending_urgency = "feed_inputs, check_fifos_first" *)
    rule check_fifos_first;
        if( ref_fifo.first != fifo.first ) begin
            $display( "\tError: fifo.first = %0d but ref_fifo.first = %0d.", fifo.first, ref_fifo.first );
            $finish;
        end
    endrule

    rule stop_tb (input_count == 1024 || cycle == 9128);
        if( input_count == 1024 ) begin
            $display("\tFinished Test, PASS");
            $display("\tOutput count = %0d", output_count);
        end else begin
            $display("\tERROR: Reached maximum cycle count!");
        end
        $finish;
    endrule

    rule cycle_inc;
        cycle <= cycle + 1;
    endrule
endmodule

// This tests the schedulability of the fifo
module [Module] mkTbSchedulingTemplate( Module#(Fifo#(Bit#(8))) mkFifo, FifoType fifo_type, Empty ifc );

    Fifo#(Bit#(8)) fifo_1 <- mkFifo();
    Fifo#(Bit#(8)) fifo_2 <- mkFifo();

    Ehr#(3, Bit#(2)) fifo_1_ehr <- mkEhr(0);
    Ehr#(3, Bit#(2)) fifo_2_ehr <- mkEhr(0);

    Bool enq_before_deq = (fifo_type == Bypass || fifo_type == CF);
    Bool deq_before_enq = (fifo_type == Pipeline || fifo_type == CF);

    // fifo_1
    // enq < deq < clear
    if( enq_before_deq ) begin
        rule enq_fifo_1;
            if( fifo_1_ehr[0] == 0 ) begin
                if( fifo_1.notFull() ) begin
                    fifo_1.enq(1);
                end
                fifo_1_ehr[0] <= 1;
            end
        endrule
        rule deq_fifo_1;
            if( fifo_1_ehr[1] == 1 ) begin
                if( fifo_1.notEmpty() ) begin
                    fifo_1.deq;
                end
                fifo_1_ehr[1] <= 0;
            end
        endrule
    end

    // fifo_2
    // deq < enq < clear
    if( deq_before_enq ) begin
        rule deq_fifo_2;
            if( fifo_2_ehr[0] == 0 ) begin
                if( fifo_2.notEmpty() ) begin
                    fifo_2.deq;
                end
                fifo_2_ehr[0] <= 1;
            end
        endrule
        rule enq_fifo_2;
            if( fifo_2_ehr[1] == 1 ) begin
                if( fifo_2.notFull() ) begin
                    fifo_2.enq(2);
                end
                fifo_2_ehr[1] <= 0;
            end
        endrule
    end

endmodule