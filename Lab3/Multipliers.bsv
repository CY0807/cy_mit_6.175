import Vector :: * ;

// Reference functions that use Bluespec's '*' operator

function Bit#(TAdd#(n,n)) multiply_unsigned( Bit#(n) a, Bit#(n) b );
    UInt#(n) a_uint = unpack(a);
    UInt#(n) b_uint = unpack(b);
    UInt#(TAdd#(n,n)) product_uint = zeroExtend(a_uint) * zeroExtend(b_uint);
    return pack( product_uint );
endfunction

function Bit#(TAdd#(n,n)) multiply_signed( Bit#(n) a, Bit#(n) b );
    Int#(n) a_int = unpack(a);
    Int#(n) b_int = unpack(b);
    Int#(TAdd#(n,n)) product_int = signExtend(a_int) * signExtend(b_int);
    return pack( product_int );
endfunction

/*Exercise 2 
Fill in the code for multiply_by_adding so it calculates the product of a and b using repeated addition in a single clock cycle. (You will verify the correctness of your multiplier in Exercise 3.) If you need an adder to produce an (n+1)-bit output from two n-bit operands, follow the model of multiply_unsigned and multiply_signed and extend the operands to (n+1)-bit before adding.
*/

function Bit#(TAdd#(n,1)) add_unsigned(Bit#(n) a, Bit#(n) b);
    UInt#(n) a_uint = unpack(a);
    UInt#(n) b_uint = unpack(b);
    UInt#(TAdd#(n,1)) add_uint = zeroExtend(a_uint) + zeroExtend(b_uint);
    return pack(add_uint);
endfunction

function Bit#(TAdd#(n,n)) multiply_by_adding(Bit#(n) a, Bit#(n) b);
    Bit#(TAdd#(n,n)) resu = 0;
    Bit#(TAdd#(n,1)) part_sum = 0;
    Bit#(n) part_sum_upper = 0;

    for (Integer i=0; i<valueOf(n); i=i+1) begin
        if (b[i] == 0) begin 
            part_sum = {1'b0, part_sum_upper};
        end 
        else begin
            part_sum = add_unsigned(part_sum_upper, a);
        end
        resu[i] = part_sum[0];
        part_sum_upper = part_sum[valueOf(n):1]; // ？？ part_sum[valueOf(n-1):1] 没有报错或者警告？位宽检查？
    end

    resu[valueOf(n)*2-1:valueOf(n)] = part_sum_upper;
    return resu;
endfunction

/*Exercise 4 
Fill in the code for the module mkFoldedMultiplier to implement a folded repeated addition multiplier.
Can you implement it without using a variable-shift bit shifter? Without using dynamic bit selection? (In other words, can you avoid shifting or bit selection by a value stored in a register?)
*/

// Multiplier Interface
interface Multiplier#(numeric type n);
    method Bool start_ready();
    method Action start(Bit#(n) a, Bit#(n) b);
    method Bool result_ready();
    method ActionValue#(Bit#(TAdd#(n,n))) result();
endinterface

// Folded multiplier by repeated addition
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
        return cnt == fromInteger(valueOf(n));
    endmethod

    method ActionValue#(Bit#(TAdd#(n,n))) result() if (cnt == fromInteger(valueOf(n)));
        cnt <= cnt+1;
        Bit#(n) resu_upper = part_sum[valueOf(n):1];
        Bit#(TAdd#(n,n)) resu = {resu_upper, resu_lower};
        return resu;
    endmethod
endmodule

/*Exercise 6 
Fill in the implementation for a folded version of the Booth multiplication algorithm in the module mkBooth: This module uses a parameterized input size n; your implementation will be expected to work for all n >= 2.
*/

function Bit#(n) shr_signed( Bit#(n) a, Integer x );
    Int#(n) a_int = unpack(a);
    Int#(n) shr_int = a_int >> x;
    return pack( shr_int );
endfunction

// Booth Multiplier
module mkBoothMultiplier(Multiplier#(n));
    Reg#(Bit#(TAdd#(TLog#(n),1))) cnt <- mkReg(fromInteger(valueOf(n)+1));
    Reg#(Bit#(TAdd#(TAdd#(n,n),1))) m_neg <- mkRegU;
    Reg#(Bit#(TAdd#(TAdd#(n,n),1))) m_pos <- mkRegU;
    Reg#(Bit#(TAdd#(TAdd#(n,n),1))) p <- mkRegU;

    rule step_mul if (cnt < fromInteger(valueOf(n)));
        cnt <= cnt + 1;
        let pr = p[1:0];
        Bit#(TAdd#(TAdd#(n,n),1)) sum_part = p;
        if(pr == 2'b01) begin
            sum_part = p + m_pos;
        end
        else if(pr == 2'b10) begin
            sum_part = p + m_neg;
        end       
        p <= shr_signed(sum_part, 1);
    endrule

    method Bool start_ready();
        return (cnt == fromInteger(valueOf(n)+1));
    endmethod    

    method Action start(Bit#(n) a_in, Bit#(n) b_in) if (cnt == fromInteger(valueOf(n)+1));
        cnt <= 0;
        m_neg <= {(-a_in), 0};
        m_pos <= {a_in, 0};
        p <= {0, b_in, 1'b0};
    endmethod

    method Bool result_ready() ;
        return True;
    endmethod

    method ActionValue#(Bit#(TAdd#(n,n))) result() if (cnt == fromInteger(valueOf(n)));
        cnt <= cnt+1;
        return p[?:1];
    endmethod
endmodule


/*Exercise 8
Fill in the implementation for a radix-4 Booth multiplier in the module mkBoothRadix4. This module uses a parameterized input size n; your implementation will be expected to work for all even n >= 2.
*/

// Radix-4 Booth Multiplier
module mkBoothMultiplierRadix4(Multiplier#(n)) provisos(Div#(n,2,a__));
    Reg#(Bit#(TAdd#(TLog#(n),1))) cnt <- mkReg(fromInteger(valueOf(n)+2));
    Reg#(Bit#(TAdd#(TAdd#(n,n),2))) m_neg <- mkRegU;
    Reg#(Bit#(TAdd#(TAdd#(n,n),2))) m_pos <- mkRegU;
    Reg#(Bit#(TAdd#(TAdd#(n,n),2))) p <- mkRegU;

    rule step_mul if (cnt < fromInteger(valueOf(n)));
        let pr = p[2:0];
        Bit#(TAdd#(TAdd#(n,n),2)) sum_part = p;
        case(pr) matches
            3'b001: begin 
                sum_part = p + m_pos; end
            3'b010: begin 
                sum_part = p + m_pos; end
            3'b011: begin 
                sum_part = p + (m_pos << 1); end
            3'b100: begin 
                sum_part = p + (m_neg << 1); end
            3'b101: begin 
                sum_part = p + m_neg; end
            3'b110: begin 
                sum_part = p + m_neg; end
        endcase    
        p <= shr_signed(sum_part, 2);
        cnt <= cnt + 2;
    endrule

    method Bool start_ready();
        return (cnt == fromInteger(valueOf(n)+2));
    endmethod    

    method Action start(Bit#(n) a_in, Bit#(n) b_in) if (cnt == fromInteger(valueOf(n)+2));
        cnt <= 0;
        m_neg <= signExtend({(-a_in), 1'b0});
        m_pos <= signExtend({a_in, 1'b0});
        p <= {0, b_in, 1'b0};
    endmethod

    method Bool result_ready() ;
        return True;
    endmethod

    method ActionValue#(Bit#(TAdd#(n,n))) result() if (cnt == fromInteger(valueOf(n)+1));
        cnt <= cnt+1;
        return p[?:1];
    endmethod
endmodule