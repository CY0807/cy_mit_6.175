# Lab1

## 多选器

1-bit的多选器结构如下：

<img src="./image/image-20230610101746035.png" alt="image-20230610101746035" style="zoom: 33%;" />

实验中采用多个并行的1-bit多选器实现多态的n-bit的多选器；

注意：在function中，输入参数带有numeric type n可以实现多态；

````
function Bit#(n) multiplexer_n(Bit#(n) a, Bit#(n) b, Bit#(1) sel);
    Bit#(n) resu = 0;
    for(Integer i=0; i<valueOf(n); i=i+1) begin
        resu[i] = multiplexer1(a[i], b[i], sel);
    end
    return resu;
endfunction
````

仿真结果：

<img src="./image/image-20230610104834353.png" alt="image-20230610104834353" style="zoom:33%;" />

## 加法器

本实验中实现的加法器主要分为两种，第一种为ripple carry加法器：

<img src="./image/image-20230610094814415.png" alt="image-20230610094814415" style="zoom: 33%;" />

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

<img src="./image/image-20230610095250158.png" alt="image-20230610095250158" style="zoom: 33%;" />

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

仿真结果：

<img src="./image/image-20230610104953461.png" alt="image-20230610104953461" style="zoom:33%;" />

<img src="./image/image-20230610105025692.png" alt="image-20230610105025692" style="zoom:33%;" />

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

仿真结果：

<img src="./image/image-20230610105205108.png" alt="image-20230610105205108" style="zoom:33%;" />

# Lab2

本实验主要介绍了如何将逻辑电路转变为elastic和inelastic的pipeline电路

以fft电路为例，其逻辑电路核心如下：

````
for (StageIdx stage = 0; stage < 3; stage = stage + 1) begin
	stage_data[stage + 1] = stage_f(stage, stage_data[stage]);
end
````

1、转变为inelastic pipeline电路：采用寄存器存储每一个流水线级的中间数据，流水线需要严格按照时序输入，不然会造成数据错误;

仿真结果：

<img src="./image/image-20230610125909891.png" alt="image-20230610125909891" style="zoom:33%;" />

2、转变为elastic pipeline电路：采用fifo衔接前后流水线级的中间数据，fifo能保持数据并有安全的接口，对输入输出端有很大灵活性

````
module mkFftElastic(Fft);
    FIFOF#(Vector#(FftPoints, ComplexData)) inFifo <- mkFIFOF;
    FIFOF#(Vector#(FftPoints, ComplexData)) outFifo <- mkFIFOF;
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

仿真结果：

<img src="./image/image-20230610130002337.png" alt="image-20230610130002337" style="zoom:33%;" />

# Lab3

实验三的主要内容为采用folded的方式来设计移位累加原理的乘法器：

<img src="./image/image-20230610130112483.png" alt="image-20230610130112483" style="zoom:33%;" />

核心代码如下，需要注意的地方：

1、interface的guard

2、数据位宽

3、移位累加原理的乘法器仅适用于正数乘法

4、在interface中，可以在“#”后定义参数实现多态

````
interface Multiplier#(numeric type n);
    method Bool start_ready();
    method Action start(Bit#(n) a, Bit#(n) b);
    method Bool result_ready();
    method ActionValue#(Bit#(TAdd#(n,n))) result();
endinterface

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

此外实验还给出了Booth原理的乘法器可用于有符号数乘法，在此不一一例举了。

编译warning：

<img src="./image/image-20230610134251599.png" alt="image-20230610134251599" style="zoom:33%;" />

仿真结果：



<img src="./image/image-20230610134228323.png" alt="image-20230610134228323" style="zoom:33%;" />

# Lab4

本实验实现了n长度的四种FIFO：Conflict FIFO、Bypass FIFO、Pipeline FIFO、Conflict Free FIFO，其中主要用到了Ehr寄存器实现了rule之间优先级处理：

<img src="./image/image-20230610160343325.png" alt="image-20230610160343325" style="zoom:33%;" />

1、Confict FIFO：rule之间涉及到double write冲突，因此在编译时有warning：

<img src="./image/image-20230610161729546.png" alt="image-20230610161729546" style="zoom:33%;" />

仿真结果：

<img src="./image/image-20230610162014681.png" alt="image-20230610162014681" style="zoom:33%;" />

2、Bypass FIFO：rule enq中采用Ehr的优先级0操作输入输出指针、empty、full信号，在rule dep中采用优先级1操作这些变量。

编译仿真结果：

<img src="./image/image-20230610162137381.png" alt="image-20230610162137381" style="zoom:33%;" />

3、Pipeline FIFO：rule deq中采用Ehr的优先级0操作输入输出指针、empty、full信号，在rule enq中采用优先级1操作这些变量。

编译仿真结果：

<img src="./image/image-20230610162728613.png" alt="image-20230610162728613" style="zoom:33%;" />

4、Conflict Free FIFO：rule enq和deq中都只采用empty、full优先级0，并用优先级0采集输入输出的信号和数据，在rule canonicalize中，首先将输入输出信号置False，然后采用优先级1操作empty、full、enq和deq指针。

编译仿真结果：

<img src="./image/image-20230610163930122.png" alt="image-20230610163930122" style="zoom:33%;" />









