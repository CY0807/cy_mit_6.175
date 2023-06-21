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

    reg [31:0] data0_reg, data1_reg;
	reg [1:0] valid_reg;

	wire shake_master = master_valid & master_ready;
	wire shake_slave = slave_valid & slave_ready;

	assign master_ready = ~valid_reg[0];
	assign slave_valid = valid_reg[1];
	assign slave_data = data1_reg;

    always@(posedge clk or negedge rst_n) begin
	    if(!rst_n) begin
		    valid_reg <= 2'b00;
			data0_reg <= 0;
			data1_reg <= 0;
		end
		else if(shake_master & shake_slave) begin
			data1_reg <= master_data;
		end
	    else if(shake_master) begin
			if(valid_reg == 2'b00) begin
			    data1_reg <= master_data;
				valid_reg = 2'b10;
			end
			else if(valid_reg == 2'b10) begin
			    data0_reg <= master_data;
				valid_reg = 2'b11;
			end
		end
		else if(shake_slave) begin
			if(valid_reg == 2'b11) begin
			    data1_reg <= data0_reg;
				valid_reg = 2'b10;
			end
			else if(valid_reg == 2'b10) begin
				valid_reg = 2'b00;
			end
		end
	end
    
endmodule