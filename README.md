# Lab1

## 多选器

1-bit的多选器结构如下：

<img src="./image/image-20230610101746035.png" alt="image-20230610101746035" style="zoom:50%;" />

实验中采用多个并行的1-bit多选器实现多态的n-bit的多选器：

````
function Bit#(n) multiplexer_n(Bit#(n) a, Bit#(n) b, Bit#(1) sel);
    Bit#(n) resu = 0;
    for(Integer i=0; i<valueOf(n); i=i+1) begin
        resu[i] = multiplexer1(a[i], b[i], sel);
    end
    return resu;
endfunction
````

## 加法器

本实验中实现的加法器主要分为两种，第一种为ripple carry加法器：

<img src="./image/image-20230610094814415.png" alt="image-20230610094814415" style="zoom: 50%;" />

其接口为：

 ````
 interface Adder8;
     method ActionValue#(Bit#(9)) calc(Bit#(8) a, Bit#(8) b, Bit#(1) c_in);
 endinterface
 ````

实现核心程序（add4为4个全加器级联函数）：

````
module mkRCAdder(Adder8);
    method ActionValue#(Bit#(9)) calc(Bit#(8) a, Bit#(8) b, Bit#(1) c_in);
        Bit#(5) low = add4(a[3:0], b[3:0], c_in);
        Bit#(5) high = add4(a[7:4], b[7:4], low[4]);
        return {high, low[3:0]};
    endmethod
endmodule
````

它的结构简单，实现容易，但通过级联全加器的方式实现当bit数高时逻辑延时随之比例升高；

第二种为carry select加法器：

<img src="./image/image-20230610095250158.png" alt="image-20230610095250158" style="zoom: 50%;" />

对高四位的加法同时计算有\无进位的结果，再通过低四位的结果进行选择，逻辑上延时减半但面积增加了，核心代码如下：

````
module mkCSAdder(Adder8);
    method ActionValue#(Bit#(9)) calc(Bit#(8) a, Bit#(8) b, Bit#(1) c_in);
        Bit#(5) low = add4(a[3:0], b[3:0], c_in);
        Bit#(5) high0 = add4(a[7:4], b[7:4], 1'b0);
        Bit#(5) high1 = add4(a[7:4], b[7:4], 1'b1);
        let high = multiplexer_n(high0, high1, low[4]);
        return {high, low[3:0]};
    endmethod
endmodule
````

附：bsv中随机数的生成

````
module mkTbRCAdder();
    Randomize#(Bit#(8)) a_random <- mkGenericRandomizer; // 例化随机数生成模块
    Reg#(int) cnt <- mkReg(0);
    rule test;
        cnt <= cnt+1;
        if(cnt == 0) begin
            a_random.cntrl.init; // 需要在第一个时钟周期初始化
        end
        else begin
            let a <- a_random.next; // 用<-来获取ActionValue方法next
        end
    endrule
endmodule
````

## 桶形移位器

桶形移位器包含多个串联的2的幂次方的移位器，通过多选器来决定是否使用某个移位器，来达到任意数的移位功能，本实验以右移为例，首先实现右移2次幂的电路：

````
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
````

再用多选器进行串联：

````
function Bit#(32) barrelShiftRight(Bit#(32) in, Bit#(5) shiftBy);
    Bit#(32) resu = in;
    for(Integer i=0; i<5; i=i+1) begin
        resu = unpack(shiftRightPow2(resu, i, shiftBy[i]));
    end
    return resu;
endfunction
````

# Lab2

本实验主要介绍了如何将逻辑电路转变为elastic和inelastic的pipeline电路

以fft电路为例，其逻辑电路核心如下：

````
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
````

1、转变为inelastic pipeline电路：采用寄存器存储每一个流水线级的中间数据，流水线需要严格按照时序输入，不然会造成数据错误：

````
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
````

2、转变为elastic pipeline电路：采用fifo衔接前后流水线级的中间数据，fifo能保持数据并有安全的接口，对输入输出端有很大灵活性

````
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
````

# Lab3



````
module mkFoldedMultiplier(Multiplier#(n)) provisos(Add#(1, a__, n));
    Reg#(Bit#(TAdd#(TLog#(n),1))) cnt <- mkReg(fromInteger(valueOf(n)+1));
    Reg#(Bit#(n)) a <- mkRegU();
    Reg#(Bit#(n)) b <- mkRegU();
    Reg#(Bit#(TAdd#(n,1))) part_sum <- mkReg(0);
    Reg#(Bit#(n)) resu_lower <- mkRegU();

    rule step_mul if (cnt < fromInteger(valueOf(n)));
        cnt <= cnt + 1;
        Bit#(n) part_sum_upper = part_sum[valueOf(n):1];
        Bit#(TAdd#(n,1)) temp_sum = add_unsigned(part_sum_upper, b[0]==1 ? a : 0);
        part_sum <= temp_sum;
        b <= b >> 1;
        resu_lower <= {temp_sum[0], resu_lower[valueOf(n)-1:1]};
    endrule

    method Bool start_ready();
        return (cnt == fromInteger(valueOf(n)+1));
    endmethod    

    method Action start(Bit#(n) a_in, Bit#(n) b_in) if (cnt == fromInteger(valueOf(n)+1));
        cnt <= 0;
        a <= a_in;
        b <= b_in;
        part_sum <= 0;
    endmethod

    method Bool result_ready() ;
        return True;
    endmethod

    method ActionValue#(Bit#(TAdd#(n,n))) result() if (cnt == fromInteger(valueOf(n)));
        cnt <= cnt+1;
        Bit#(n) resu_upper = part_sum[valueOf(n):1];
        Bit#(TAdd#(n,n)) resu = {resu_upper, resu_lower};
        return resu;
    endmethod
endmodule
````

