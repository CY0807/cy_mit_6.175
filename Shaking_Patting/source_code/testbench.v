`timescale  1ns / 1ps

module testbench();

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
reg [31:0] data_master[0:99999];	
reg [31:0] data_slave[0:99999];
reg [31:0] cnt_master = 0;
reg [31:0] cnt_slave = 0;

// master数据
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
	    cnt_master <= 0;
	end
	else if(cnt_master < cnt_max) begin
		if(master_valid && master_ready) begin
			data_master[cnt_master] <= master_data;
			cnt_master <= cnt_master + 1;
		end
	end
end

// slave
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
	    cnt_slave <= 0;
	end
	else if(cnt_slave < cnt_max) begin
		if(slave_valid && slave_ready) begin
			data_slave[cnt_slave] <= slave_data;
			cnt_slave <= cnt_slave + 1;
		end
	end
end

// check
always@(posedge clk or negedge rst_n) begin
	if(cnt_slave == cnt_max && cnt_master == cnt_max) begin
		for(integer i=0; i<cnt_max; i=i+1) begin
		    if(data_master[i] != data_slave[i]) begin
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
    wait(cnt_master >= cnt_max || cnt_slave >= cnt_max);
    #(50*period);
	$display("time out error\n");
	$finish;
end


// 1. valid patting
// handshake_pipe_valid_patting handshake_pipe_inst (	
// 2. ready patting
// handshake_pipe_ready_patting handshake_pipe_inst (	
// 3. both patting
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

endmodule





