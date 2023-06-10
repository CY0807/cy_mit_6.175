/* Exercise 1
Using the and, or, and not gates, re-implement the function multiplexer1 in Multiplexer.bsv. How many gates are needed? (The required functions, called and1, or1 and not1, respectively, are provided in Multiplexers.bsv.)
*/

function Bit#(1) and1(Bit#(1) a, Bit#(1) b);
    return a & b;
endfunction

function Bit#(1) or1(Bit#(1) a, Bit#(1) b);
    return a | b;
endfunction

function Bit#(1) not1(Bit#(1) a);
    return ~a;
endfunction

function Bit#(1) multiplexer1(Bit#(1) a, Bit#(1) b, Bit#(1) sel);
    return or1(and1(a, not1(sel)), and1(b, sel));
endfunction

/* Exercise 2
Complete the implementation of the function multiplexer5 in Multiplexer.bsv using for loops and multiplexer1.
Check the correctness of the code by running the multiplexer testbench:
$ make mux
$ ./simMux
An alternate test bench can be used to see outputs from the unit by running:
$ make muxsimple
$ ./simMuxSimple
*/

function Bit#(5) multiplexer5(Bit#(5) a, Bit#(5) b, Bit#(1) sel);
    return multiplexer_n(a, b, sel);
endfunction

/* Exercise 3
Complete the definition of the function multiplexer_n. Verify that this function is correct by replacing the original definition of multiplexer5 to only have: return multiplexer_n(sel, a, b);. This redefinition allows the test benches to test your new implementation without modification.
*/

function Bit#(n) multiplexer_n(Bit#(n) a, Bit#(n) b, Bit#(1) sel);
    Bit#(n) resu = 0;
    for(Integer i=0; i<valueOf(n); i=i+1) begin
        resu[i] = multiplexer1(a[i], b[i], sel);
    end
    return resu;
endfunction

// TestBench

import Randomizable::*;

(* synthesize *)
module mkTbMux();
    Randomize#(Bit#(5)) a_random <- mkGenericRandomizer;
    Randomize#(Bit#(5)) b_random <- mkGenericRandomizer;
    Randomize#(Bit#(1)) sel_random <- mkGenericRandomizer;
    Reg#(int) cnt <- mkReg(0);

    rule test;
        cnt <= cnt + 1;
        if(cnt == 0) begin
            a_random.cntrl.init;
            b_random.cntrl.init;
            sel_random.cntrl.init;
            $display("\n");
        end
        else if(cnt == 128) begin
            $display("PASS\n");
            $finish;
        end
        else begin
            let a <- a_random.next;
            let b <- b_random.next;
            let sel <- sel_random.next;
            let resu = multiplexer_n(a, b, sel);
            let real_resu = (sel==0) ? a : b;
            if(resu != real_resu) begin
                $display("ERROR\n");
                $finish;
            end
        end
    endrule
endmodule

(* synthesize *)
module mkTbMuxSimple();
    Randomize#(Bit#(5)) a_random <- mkGenericRandomizer;
    Randomize#(Bit#(5)) b_random <- mkGenericRandomizer;
    Randomize#(Bit#(1)) sel_random <- mkGenericRandomizer;
    Reg#(int) cnt <- mkReg(0);

    rule test;
        cnt <= cnt + 1;
        if(cnt == 0) begin
            a_random.cntrl.init;
            b_random.cntrl.init;
            sel_random.cntrl.init;
            $display("\n");
        end
        else if(cnt == 128) begin
            $display("PASS\n");
            $finish;
        end
        else begin
            let a <- a_random.next;
            let b <- b_random.next;
            let sel <- sel_random.next;
            let resu = multiplexer_n(a, b, sel); 
            $display("multiplexer_n(%d, %d, %d) = %d", a, b, sel, resu);
            let real_resu = (sel==0) ? a : b;
            if(resu != real_resu) begin
                $display("ERROR\n");
                $finish;
            end
        end
    endrule
endmodule

