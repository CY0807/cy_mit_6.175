import Vector::*;
import Complex::*;
import Fifo::*;
import FIFO::*;
import FIFOF::*;
import FftCommon::*;
import DReg::*;

// Given Material : FftCommon.bsv, function state_f, interface Fft, module mkFftCombinational

function Vector#(FftPoints, ComplexData) stage_f(StageIdx stage, Vector#(FftPoints, ComplexData) stage_in);
    Vector#(FftPoints, ComplexData) stage_temp, stage_out;
    for (FftIdx i = 0; i < fromInteger(valueOf(BflysPerStage)); i = i + 1)  begin
        FftIdx idx = i * 4;
        Vector#(4, ComplexData) x;
        Vector#(4, ComplexData) twid;

        for (FftIdx j = 0; j < 4; j = j + 1 ) begin
            x[j] = stage_in[idx+j];
            twid[j] = getTwiddle(stage, idx+j);
        end
        
        let y = bfly4(twid, x);
        for(FftIdx j = 0; j < 4; j = j + 1 ) begin
            stage_temp[idx+j] = y[j];
        end
    end
    stage_out = permute(stage_temp);
    return stage_out;
endfunction

function Vector#(4,ComplexData) bfly4(Vector#(4, ComplexData) t, Vector#(4, ComplexData) x);
    Vector#(4, ComplexData) m, y, z;
    for (Integer i = 0; i < 4; i = i + 1)
    begin
        m[i] = x[i] * t[i];
    end
    y[0] = m[0] + m[2];
    y[1] = m[0] - m[2];
    y[2] = m[1] + m[3];
    y[3] = m[1] - m[3];
    z[0] = y[0] + y[2];
    z[1] = y[1] + y[3];
    z[2] = y[0] - y[2];
    z[3] = y[1] - y[3];
    return z;
endfunction

interface Fft;
    method Action enq(Vector#(FftPoints, ComplexData) in);
    method ActionValue#(Vector#(FftPoints, ComplexData)) deq;
endinterface

module mkFftCombinational(Fft);
    FIFOF#(Vector#(FftPoints, ComplexData)) inFifo <- mkFIFOF;
    FIFOF#(Vector#(FftPoints, ComplexData)) outFifo <- mkFIFOF;   

    rule doFft;
            inFifo.deq;
            Vector#(4, Vector#(FftPoints, ComplexData)) stage_data;
            stage_data[0] = inFifo.first;

            for (StageIdx stage = 0; stage < 3; stage = stage + 1) begin
                stage_data[stage + 1] = stage_f(stage, stage_data[stage]);
            end
            outFifo.enq(stage_data[3]);
    endrule

    method Action enq(Vector#(FftPoints, ComplexData) in);
        inFifo.enq(in);
    endmethod

    method ActionValue#(Vector#(FftPoints, ComplexData)) deq;
        outFifo.deq;
        return outFifo.first;
    endmethod
endmodule

/* Exercise 2
In mkFftInelasticPipeline, create an inelastic pipeline FFT implementation. You can look here for some extra slides on inelastic pipelining, compared to what we covered in class. This implementation should make use of 48 butterflies and 2 large registers, each carrying 64 complex numbers. The latency of this pipelined unit must also be exactly 3 cycles, though its throughput would be 1 FFT operation every cycle.

The Makefile can be used to build simInelastic to test this implementation. Compile and run using

$ make inelastic
$ ./simInelastic
*/

module mkFftInelastic(Fft);
    FIFOF#(Vector#(FftPoints, ComplexData)) inFifo <- mkFIFOF;
    FIFOF#(Vector#(FftPoints, ComplexData)) outFifo <- mkFIFOF;
    Reg#(Maybe#(Vector#(FftPoints, ComplexData))) regS1 <- mkDReg(tagged Invalid);
    Reg#(Maybe#(Vector#(FftPoints, ComplexData))) regS2 <- mkDReg(tagged Invalid);

    rule fftS1;
        let s1_ret = stage_f(0, inFifo.first);
        regS1 <= tagged Valid s1_ret;
        inFifo.deq;
    endrule

    rule fftS2 if(isValid(regS1));
        let s2_ret = stage_f(1, fromMaybe(?, regS1));
        regS2 <= tagged Valid s2_ret;
    endrule

    rule fftS3 if(isValid(regS2));
        let s3_ret = stage_f(2, fromMaybe(?, regS2));
        outFifo.enq(s3_ret);
    endrule

    method Action enq(Vector#(FftPoints, ComplexData) in);
        inFifo.enq(in);
    endmethod

    method ActionValue#(Vector#(FftPoints, ComplexData)) deq;
        outFifo.deq;
        return outFifo.first;
    endmethod
endmodule


/*
Exercise 3 (10 Points):

In mkFftElasticPipeline, create an elastic pipeline FFT implementation. This implementation should make use of 48 butterflies and some fifos. You should also try to use:

1. your 3 elements FIFOs (instantiated with mkFifo).
2. the provided FIFOs (instantiated with mkCFFifo).
The stages between the FIFOs should be in their own rules that can fire independently. When running the testbench you are likely to observe an important difference in performance (number of cycle it took to run the testbench). That is expected, please email me if you don't.
The Makefile can be used to build simElastic to test this implementation. Compile and run using

$ make elastic
$ ./simElastic
*/

module mkFftElastic(Fft);
    FIFOF#(Vector#(FftPoints, ComplexData)) inFifo <- mkFIFOF;
    FIFOF#(Vector#(FftPoints, ComplexData)) outFifo <- mkFIFOF;
    //Fifo#(3, Vector#(FftPoints, ComplexData)) fifoS1 <- mkConflictFreeFifo3();
    //Fifo#(3, Vector#(FftPoints, ComplexData)) fifoS2 <- mkConflictFreeFifo3();
    FIFO#(Vector#(FftPoints, ComplexData)) fifoS1 <- mkSizedFIFO(3);
    FIFO#(Vector#(FftPoints, ComplexData)) fifoS2 <- mkSizedFIFO(3);

    rule fftS1;
        let s1_ret = stage_f(0, inFifo.first);
        fifoS1.enq(s1_ret);
        inFifo.deq;
    endrule

    rule fftS2;
        let s2_ret = stage_f(1, fifoS1.first);
        fifoS2.enq(s2_ret);
        fifoS1.deq;
    endrule

    rule fftS3;
        let s3_ret = stage_f(2, fifoS2.first);
        outFifo.enq(s3_ret);
        fifoS2.deq;
    endrule

    method Action enq(Vector#(FftPoints, ComplexData) in);
        inFifo.enq(in);
    endmethod

    method ActionValue#(Vector#(FftPoints, ComplexData)) deq;
        outFifo.deq;
        return outFifo.first;
    endmethod
endmodule

// TestBench

import Randomizable::*;

(* synthesize *)
module mkTbFftInelastic();
    let fft <- mkFftInelastic;
    mkTestBench(fft);
endmodule

(* synthesize *)
module mkTbFftElastic();
    let fft <- mkFftElastic;
    mkTestBench(fft);
endmodule

module mkTestBench#(Fft fft)();
    let fft_comb <- mkFftCombinational;

    Vector#(FftPoints, Randomize#(Data)) randomVal1 <- replicateM(mkGenericRandomizer);
    Vector#(FftPoints, Randomize#(Data)) randomVal2 <- replicateM(mkGenericRandomizer);

    Reg#(Bool) init <- mkReg(False);
    Reg#(Bit#(32)) cycle_count <- mkReg(0);
    Reg#(Bit#(8)) stream_count <- mkReg(0);
    Reg#(Bit#(8)) feed_count <- mkReg(0);

    rule initialize(init == False);
        for (Integer i = 0; i < fftPoints; i = i + 1 ) begin
            randomVal1[i].cntrl.init;
            randomVal2[i].cntrl.init;
        end
        init <= True;
    endrule

    rule feed(feed_count < 128 && init);
        Vector#(FftPoints, ComplexData) d;
        for (Integer i = 0; i < fftPoints; i = i + 1 ) begin
            let rv <- randomVal1[i].next;
            let iv <- randomVal2[i].next;
            d[i] = cmplx(rv, iv);
        end
        fft_comb.enq(d);
        fft.enq(d);
        feed_count <= feed_count + 1;
    endrule

    rule stream(init);
        stream_count <= stream_count + 1;
        let rc <- fft_comb.deq;
        let rf <- fft.deq;
        if ( rc != rf ) begin
            $display("FAILED!");
            for (Integer i = 0; i < fftPoints; i = i + 1) begin
                $display ("\t(%x, %x) != (%x, %x)", rc[i].rel, rc[i].img, rf[i].rel, rf[i].img);
            end
            $finish;
        end
    endrule

    rule pass (stream_count == 128 && init);
        $display("\nPASSED\n");
        $finish;
    endrule

    rule timeout(init);
        if( cycle_count == 128 * 128 ) begin
            $display("FAILED: Only saw %0d out of 128 outputs after %0d cycles", stream_count, cycle_count);
            $finish;
        end
        cycle_count <= cycle_count + 1;
    endrule
endmodule
