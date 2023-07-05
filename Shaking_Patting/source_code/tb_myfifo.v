`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/03 12:18:02
// Design Name: 
// Module Name: tb_myfifo
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


module tb_myfifo();
  
parameter period = 10;  
reg clk, rst_n; 
wire empty, full;
wire [31:0] data_out;
integer seed = 0;

initial begin
    clk = 0;
    forever # (period/2) clk = ~clk;
end

initial begin
    $display("\n***** Start	Simulation *****");
    $display("Random Seed = ", seed);
	rst_n = 0;    
	# (period/2) rst_n = 1;  
end  

// 随机激励
reg to_wr, to_rd;
wire wr_en, rd_en;
reg [31:0] data_in;

always@(posedge clk or negedge rst_n) begin
    to_wr <= $random(seed);
end
assign wr_en = to_wr && !full && cnt_in<cnt_max;

always@(posedge clk) begin
    to_rd <= $random(seed);
end
assign rd_en = to_rd && !empty && cnt_out<cnt_max;

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        data_in <= $random(seed);
    end
    else if(wr_en) begin
        data_in <= $random(seed);
    end
end

// 自动化验证
reg [31:0] data_in_array[0:100000];	
reg [31:0] data_out_array[0:100000];
reg [31:0] cnt_in = 0;
reg [31:0] cnt_out = 0;
reg [31:0] cnt_max = 30000;
integer i;
    
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cnt_in <= 0;
    end
    else if(wr_en) begin
        cnt_in <= cnt_in + 1;
        data_in_array[cnt_in] <= data_in;
    end
end   

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cnt_out <= 0;
    end
    else if(rd_en) begin
        cnt_out <= cnt_out + 1;
        data_out_array[cnt_out] <= data_out;
    end
end  

// check
always@(posedge clk) begin
	if(cnt_in == cnt_max && cnt_out == cnt_max) begin
		for(i=0; i<cnt_max; i=i+1) begin
		    if(data_in_array[i] != data_out_array[i]) begin
			    $display("data Error!\n");
		        $finish;
			end
		end
		$display("PASS\n");
		$finish;
	end
end

// timeout
initial begin
    wait(cnt_in >= cnt_max || cnt_out >= cnt_max);
    #(50*period);
	$display("time out error\n");
	$finish;
end
   
myfifo
#(
    .DATA_WIDTH(32),
    .DATA_DEPTH(2)
)
myfifo_inst
(
    .clk(clk),
    .rst_n(rst_n),    
    .data_in(data_in),
    .wr_en(wr_en),
    .rd_en(rd_en),	
    .data_out(data_out),
    .empty(empty),
    .full(full)
);    
    
endmodule
