# Lab1

## 加法器

本实验中实现的加法器主要分为两种，第一种为ripple carry加法器：

![image-20230610094814415](./image/image-20230610094814415.png)

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

![image-20230610095250158](./image/image-20230610095250158.png)

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







## 多选器

