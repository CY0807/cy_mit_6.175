/* Exercise 6 
Complete the function Bit#(32) barrelShiftRight(Bit#(32) in, Bit#(5) shiftBy) in the file BarrelShifter.bsv provided with the initial lab code. This module can be tested by running the following:
$ make bs
$ ./simBs
*/

function Bit#(32) shiftRightPow2(Bit#(32) unshifted, Integer power, Bit#(1) en);
    Integer i = 2**power;
    Bit#(32) shifted = 0;
    Bit#(32) resu = 0;
    for(Integer j=0; j<32-i; j=j+1) begin
        shifted[j] = unshifted[j+i];
    end
    resu = (en==1) ? shifted : unshifted;
    return resu;
endfunction

function Bit#(32) barrelShiftRight(Bit#(32) in, Bit#(5) shiftBy);
    Bit#(32) resu = in;
    for(Integer i=0; i<5; i=i+1) begin
        resu = unpack(shiftRightPow2(resu, i, shiftBy[i]));
    end
    return resu;
endfunction

// Test Bench

import Randomizable::*;

(* synthesize *)
module mkTbBS();
    Randomize#(Bit#(32)) in_random <- mkGenericRandomizer;
    Randomize#(Bit#(5)) shiftBy_random <- mkGenericRandomizer;
    Reg#(int) cnt <- mkReg(0);
    rule test;
        cnt <= cnt+1;
        if(cnt == 0) begin
            in_random.cntrl.init;
            shiftBy_random.cntrl.init;
            $display("\n");
        end
        else if(cnt == 128) begin
            $display("PASS\n");
            $finish;
        end
        else begin
            let in <- in_random.next;
            let shiftBy <- shiftBy_random.next;
            let resu = barrelShiftRight(in, shiftBy);
            $display("ShiftRight(%d, %d) = %d", in, shiftBy, resu);
            Bit#(32) real_resu = in >> shiftBy;
            if(resu != real_resu) begin
                $display("ERROR\n");
                $display("real_resu=%d", real_resu);
                $finish;
            end
        end
    endrule
endmodule
