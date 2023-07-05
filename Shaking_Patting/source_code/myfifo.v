`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/03 11:25:49
// Design Name: 
// Module Name: myfifo
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module myfifo
#(
    parameter DATA_WIDTH = 32,
    parameter DATA_DEPTH = 2
)
(
    input clk,
    input rst_n,
    
    input [DATA_WIDTH-1:0] data_in,
    input wr_en,
    input rd_en,
	
    output [DATA_WIDTH-1:0] data_out,
    output empty,
    output full
);

localparam PTR_WIDTH = $clog2(DATA_DEPTH);

reg [DATA_WIDTH-1:0] data_reg[DATA_DEPTH-1:0];
reg [PTR_WIDTH-1:0] enq_ptr_reg, deq_ptr_reg;
reg [1:0] ptr_flag_reg;

assign empty = enq_ptr_reg==deq_ptr_reg && ptr_flag_reg[0]==ptr_flag_reg[1];
assign full = enq_ptr_reg==deq_ptr_reg && ptr_flag_reg[0]!=ptr_flag_reg[1];
assign data_out = data_reg[deq_ptr_reg];

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        enq_ptr_reg <= 0;
        ptr_flag_reg[0] <= 0;
    end
    else if(wr_en && !full) begin
        enq_ptr_reg <= enq_ptr_reg +1;
        data_reg[enq_ptr_reg] <= data_in;
        if(enq_ptr_reg == DATA_DEPTH-1) begin
            enq_ptr_reg <= 0;
            ptr_flag_reg[0] <= ~ptr_flag_reg[0];
        end
    end
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        deq_ptr_reg <= 0;
        ptr_flag_reg[1] <= 0;
    end
    else if(rd_en && !empty) begin
        deq_ptr_reg <= deq_ptr_reg +1;
        if(deq_ptr_reg == DATA_DEPTH-1) begin
            deq_ptr_reg <= 0;
            ptr_flag_reg[1] <= ~ptr_flag_reg[1];
        end
    end
end

endmodule
