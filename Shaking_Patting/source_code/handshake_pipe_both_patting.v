module handshake_pipe_both_patting (
    input wire clk,
    input wire rst_n,

    input  wire master_valid,
    input  wire [31:0] master_data,
    output wire master_ready,

    output wire slave_valid,
    output wire [31:0] slave_data,
    input  wire slave_ready
    );
	
// input -> ready_pipe -> valid_pipe -> output
	
wire [31:0] data_trans;
wire valid_trans, ready_trans;	

handshake_pipe_ready_patting handshake_pipe_inst1 (	
    .clk(clk),
	.rst_n(rst_n),
	
    .master_valid(master_valid),
    .master_data (master_data),
    .master_ready(master_ready),
    
    .slave_valid(valid_trans),
    .slave_data (data_trans),
    .slave_ready(ready_trans)
);
	
handshake_pipe_valid_patting handshake_pipe_inst2 (	
    .clk(clk),
	.rst_n(rst_n),
	
    .master_valid(valid_trans),
    .master_data (data_trans),
    .master_ready(ready_trans),
    
    .slave_valid(slave_valid),
    .slave_data (slave_data),
    .slave_ready(slave_ready)
);	
    
endmodule