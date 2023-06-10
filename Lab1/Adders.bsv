import Multiplexer::*;

/* Exercise 4
Complete the code for add4 by using a for loop to properly connect all the uses of fa_sum and fa_carry.
The full implementation for the 8-bit ripple-carry adder shown in Figure 2d is included in the module mkRCAdder. It can be tested by running the following:
$ make rca
$ ./simRca
Since mkRCAdder is constructed by combining add4 instances, running ./simRCA will also test add4. An alternate test bench can be used to see outputs from the unit by running:
$ make rcasimple
$ ./simRcaSimple
*/

function Bit#(1) fa_sum( Bit#(1) a, Bit#(1) b, Bit#(1) c_in );
    return (a ^ b) ^ c_in;
endfunction

function Bit#(1) fa_carry( Bit#(1) a, Bit#(1) b, Bit#(1) c_in );
    return (a & b) | ((a ^ b) & c_in);
endfunction

function Bit#(5) add4( Bit#(4) a, Bit#(4) b, Bit#(1) c_in );
    Bit#(5) resu = 0;
    Bit#(5) c = zeroExtend(c_in);
    for(Integer i=0; i<4; i=i+1) begin
        resu[i] = fa_sum(a[i], b[i], c[i]);
        c[i+1] = fa_carry(a[i], b[i], c[i]);
    end
    return {c[4], resu[3:0]};
endfunction

interface Adder8;
    method ActionValue#(Bit#(9)) calc(Bit#(8) a, Bit#(8) b, Bit#(1) c_in);
endinterface

module mkRCAdder(Adder8);
    method ActionValue#(Bit#(9)) calc(Bit#(8) a, Bit#(8) b, Bit#(1) c_in);
        Bit#(5) low = add4(a[3:0], b[3:0], c_in);
        Bit#(5) high = add4(a[7:4], b[7:4], low[4]);
        return {high, low[3:0]};
    endmethod
endmodule

/* Exercise 5 
Complete the code for the carry-select adder in the module mkCSAdder. Use Figure 3 as a guide for the required hardware and connections. This module can be tested by running the following:
$ make csa
$ ./simCsa
An alternate test bench can be used to see outputs from the unit by running:
$ make csasimple
$ ./simCsaSimple
*/

module mkCSAdder(Adder8);
    method ActionValue#(Bit#(9)) calc(Bit#(8) a, Bit#(8) b, Bit#(1) c_in);
        Bit#(5) low = add4(a[3:0], b[3:0], c_in);
        Bit#(5) high0 = add4(a[7:4], b[7:4], 1'b0);
        Bit#(5) high1 = add4(a[7:4], b[7:4], 1'b1);
        let high = multiplexer_n(high0, high1, low[4]);
        return {high, low[3:0]};
    endmethod
endmodule


// TestBench

import Randomizable::*;

(* synthesize *)
module mkTbRCAdder();
    Randomize#(Bit#(8)) a_random <- mkGenericRandomizer;
    Randomize#(Bit#(8)) b_random <- mkGenericRandomizer;
    Randomize#(Bit#(1)) c_in_random <- mkGenericRandomizer;
    Reg#(int) cnt <- mkReg(0);
    Adder8 adder8 <- mkRCAdder();
    rule test;
        cnt <= cnt+1;
        if(cnt == 0) begin
            a_random.cntrl.init;
            b_random.cntrl.init;
            c_in_random.cntrl.init;
            $display("\n");
        end
        else if(cnt == 128) begin
            $display("PASS\n");
            $finish;
        end
        else begin
            let a <- a_random.next;
            let b <- b_random.next;
            let c_in <- c_in_random.next;
            let resu <- adder8.calc(a, b, c_in); 
            Bit#(9) real_resu = zeroExtend(a) + zeroExtend(b) + zeroExtend(c_in);
            if(resu != real_resu) begin
                $display("ERROR\n");
                $finish;
            end
        end
    endrule
endmodule

(* synthesize *)
module mkTbCSAdder();
    Randomize#(Bit#(8)) a_random <- mkGenericRandomizer;
    Randomize#(Bit#(8)) b_random <- mkGenericRandomizer;
    Randomize#(Bit#(1)) c_in_random <- mkGenericRandomizer;
    Reg#(int) cnt <- mkReg(0);
    Adder8 adder8 <- mkCSAdder();
    rule test;
        cnt <= cnt+1;
        if(cnt == 0) begin
            a_random.cntrl.init;
            b_random.cntrl.init;
            c_in_random.cntrl.init;
            $display("\n");
        end
        else if(cnt == 128) begin
            $display("PASS\n");
            $finish;
        end
        else begin
            let a <- a_random.next;
            let b <- b_random.next;
            let c_in <- c_in_random.next;
            let resu <- adder8.calc(a, b, c_in); 
            Bit#(9) real_resu = zeroExtend(a) + zeroExtend(b) + zeroExtend(c_in);
            if(resu != real_resu) begin
                $display("ERROR\n");
                $finish;
            end
        end
    endrule
endmodule

(* synthesize *)
module mkTbRCAdderSimple();
    Randomize#(Bit#(8)) a_random <- mkGenericRandomizer;
    Randomize#(Bit#(8)) b_random <- mkGenericRandomizer;
    Randomize#(Bit#(1)) c_in_random <- mkGenericRandomizer;
    Reg#(int) cnt <- mkReg(0);
    Adder8 adder8 <- mkRCAdder();
    rule test;
        cnt <= cnt+1;
        if(cnt == 0) begin
            a_random.cntrl.init;
            b_random.cntrl.init;
            c_in_random.cntrl.init;
            $display("\n");
        end
        else if(cnt == 128) begin
            $display("PASS\n");
            $finish;
        end
        else begin
            let a <- a_random.next;
            let b <- b_random.next;
            let c_in <- c_in_random.next;
            let resu <- adder8.calc(a, b, c_in);
            $display("adder8.calc(%d, %d, %d) = %d", a, b, c_in, resu);
            Bit#(9) real_resu = zeroExtend(a) + zeroExtend(b) + zeroExtend(c_in);
            if(resu != real_resu) begin
                $display("ERROR\n");
                $finish;
            end
        end
    endrule
endmodule

(* synthesize *)
module mkTbCSAdderSimple();
    Randomize#(Bit#(8)) a_random <- mkGenericRandomizer;
    Randomize#(Bit#(8)) b_random <- mkGenericRandomizer;
    Randomize#(Bit#(1)) c_in_random <- mkGenericRandomizer;
    Reg#(int) cnt <- mkReg(0);
    Adder8 adder8 <- mkCSAdder();
    rule test;
        cnt <= cnt+1;
        if(cnt == 0) begin
            a_random.cntrl.init;
            b_random.cntrl.init;
            c_in_random.cntrl.init;
            $display("\n");
        end
        else if(cnt == 128) begin
            $display("PASS\n");
            $finish;
        end
        else begin
            let a <- a_random.next;
            let b <- b_random.next;
            let c_in <- c_in_random.next;
            let resu <- adder8.calc(a, b, c_in);
            $display("adder8.calc(%d, %d, %d) = %d", a, b, c_in, resu);
            Bit#(9) real_resu = zeroExtend(a) + zeroExtend(b) + zeroExtend(c_in);
            if(resu != real_resu) begin
                $display("ERROR\n");
                $finish;
            end
        end
    endrule
endmodule
