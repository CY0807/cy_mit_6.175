import TestBenchTemplates::*;
import Multipliers::*;

// Example testbenches

(* synthesize *)
module mkTbDumb();
    function Bit#(16) test_function( Bit#(8) a, Bit#(8) b ) = multiply_unsigned( a, b );
    Empty tb <- mkTbMulFunction(test_function, multiply_unsigned, True);
    return tb;
endmodule

/*
(* synthesize *)
module mkTbFoldedMultiplier();
    Multiplier#(8) dut <- mkFoldedMultiplier();
    Empty tb <- mkTbMulModule(dut, multiply_signed, True);
    return tb;
endmodule
*/

/*Exercise 1
In TestBench.bsv, write a test bench mkTbSignedVsUnsigned that tests if multiply_signed produces the same output as multiply_unsigned. Compile this test bench as described above and run it.

$ make SignedVsUnsigned.tb
$ ./simSignedVsUnsigned
*/

(* synthesize *)
module mkTbSignedVsUnsigned();
    function Bit#(16) test_function(Bit#(8) a, Bit#(8) b) = multiply_signed(a, b);
    Empty tb <- mkTbMulFunction(test_function, multiply_unsigned, True);
    return tb;
endmodule

/*
Exercise 3
Fill in the test bench mkTbEx3 in TestBench.bsv to test the functionality of multiply_by_adding. Compile it with
$ make Ex3.tb
and run it with
$ ./simEx3
*/

(* synthesize *)
module mkTbEx3();
    function Bit#(16) test_function(Bit#(8) a, Bit#(8) b) = multiply_by_adding(a, b);
    Empty tb <- mkTbMulFunction(test_function, multiply_unsigned, True);
    return tb;
endmodule

/*Exercise 5 
Fill in the test bench mkTbEx5 to test the functionality of mkFoldedMultiplier against multiply_by_adding. They should produce the same outputs if you implemented mkFoldedMultiplier correctly. To run these, run
$ make Ex5.tb
$ ./simEx5
*/

(* synthesize *)
module mkTbEx5();
    Multiplier#(8) dut <- mkFoldedMultiplier();
    Empty tb <- mkTbMulModule(dut, multiply_unsigned, True);
    return tb;
endmodule

/* Exercise 7 
Fill in the test benches mkTbEx7a and mkTbEx7b for your Booth multiplier to test different bit widths of your choice. You can test them with:
$ make Ex7a.tb
$ ./simEx7a
and
$ make Ex7b.tb
$ ./simEx7b
*/

(* synthesize *)
module mkTbEx7a();
    // TODO: Implement test bench for Exercise 7
    Multiplier#(8) dut <- mkBoothMultiplier();
    Empty tb <- mkTbMulModule(dut, multiply_signed, True);
    return tb;
endmodule

(* synthesize *)
module mkTbEx7b();
    // TODO: Implement test bench for Exercise 7
    Multiplier#(64) dut <- mkBoothMultiplier();
    Empty tb <- mkTbMulModule(dut, multiply_signed, True);
    return tb;
endmodule

/*Exercise 9 
 Fill in test benches mkTbEx9a and mkTbEx9b for your radix-4 Booth multiplier to test different even bit widths of your choice. You can test them with
$ make Ex9a.tb
$ ./simEx9a
and
$ make Ex9b.tb
$ ./simEx9b
*/

(* synthesize *)
module mkTbEx9a();
    Multiplier#(8) dut <- mkBoothMultiplierRadix4();
    Empty tb <- mkTbMulModule(dut, multiply_signed, True);
    return tb;
endmodule

(* synthesize *)
module mkTbEx9b();
    Multiplier#(64) dut <- mkBoothMultiplierRadix4();
    Empty tb <- mkTbMulModule(dut, multiply_signed, True);
    return tb;
endmodule

