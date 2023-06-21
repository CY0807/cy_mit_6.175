module handshake_pipe_valid_patting (
    input wire clk,
    input wire rst_n,

    input  wire master_valid,
    input  wire [31:0] master_data,
    output wire master_ready,

    output wire slave_valid,
    output wire [31:0] slave_data,
    input  wire slave_ready
    );
	
    reg valid_reg;
    reg [31:0] data_reg;

    assign master_ready = slave_ready | (~valid_reg);
    assign slave_data = data_reg;
    assign slave_valid = valid_reg;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            valid_reg <= 1'b0;
        end
        else if(master_valid & master_ready) begin
            valid_reg <= 1'b1;
        end
        else if(slave_ready & valid_reg) begin
			valid_reg <= 1'b0;
		end
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            data_reg <= 32'd0;
        end
        else if(master_valid & master_ready)begin
            data_reg <= master_data; 
        end
    end
    
endmodule