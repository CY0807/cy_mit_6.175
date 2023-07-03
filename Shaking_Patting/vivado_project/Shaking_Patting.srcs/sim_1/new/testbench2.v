`timescale  1ns / 1ps

module testbench2();

reg [31:0] cnt_max = 30000; // 测试中传输数据个数

reg clk, rst_n;
parameter period = 10;
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
reg [31:0] master_data;
reg master_valid, slave_ready;
wire [31:0] slave_data;
wire slave_valid, master_ready;

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
	    master_valid <= 1'b0;
	end
	else if(!master_valid || master_ready) begin
	    master_valid <= $random(seed);
	end
end

// corner case for valid
/*
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
	    master_valid <= 1'b0;
	end
	else if(!master_valid || master_ready) begin
	    master_valid <= !master_valid;
	end
end 
*/

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
	    master_data <= $random(seed);
	end
	else if(master_valid && master_ready) begin 
	    master_data <= $random(seed);
	end
end 

always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
	    slave_ready <= 1'b0;
	end
	else begin
	    slave_ready <= $random(seed);
	end
end 

// corner case for ready
/*
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
	    slave_ready <= 1'b0;
	end
	else begin
	    slave_ready <= !slave_ready;
	end
end 
*/


// 自动化验证

wire empty, full;
wire [31:0] data_out;

// check
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cnt_max <= 30000;
    end
    else if(slave_ready && slave_valid) begin
        cnt_max <= cnt_max - 1;
        if(data_out != slave_data) begin
            $display("Data Error!\n");
            $finish;
        end
    end
    else begin
    end
end

// finish
initial begin
    wait(cnt_max == 0);
	$display("PASS\n");
	$finish;
end

 handshake_pipe_both_patting handshake_pipe_inst (
    .clk(clk),
	.rst_n(rst_n),
	
    .master_valid(master_valid),
    .master_data (master_data),
    .master_ready(master_ready),
    
    .slave_valid(slave_valid),
    .slave_data (slave_data),
    .slave_ready(slave_ready)
);

myfifo
#(
    .DATA_WIDTH(32),
    .DATA_DEPTH(2)
)
myfifo_inst
(
    .clk(clk),
    .rst_n(rst_n),    
    .data_in(master_data),
    .wr_en(master_valid && master_ready),
    .rd_en(slave_ready && slave_valid),	
    .data_out(data_out),
    .empty(empty),
    .full(full)
);

endmodule





