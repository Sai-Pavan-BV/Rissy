`timescale 1ns/1ns
module reg_file(clk,rst,w_en,pc_inc,
					write_data,write_add,RA_add,RB_add,
					address,data_a,data_b
					);

input wire clk,rst,w_en,pc_inc;
input wire[15:0] write_data;
input wire[2:0] write_add,RA_add,RB_add;

output reg[15:0] address,data_a,data_b;

reg[15:0] mem[7:0];

integer i;

always @(clk, rst) begin
	if(rst) begin
		for(i=0; i<7; i=i+1) begin
			mem[i] = 0;
		end
		mem[7]=16'hfffe;
	end
	else begin
		if(clk) begin
			if(!rst) begin
				if(pc_inc) begin
					mem[7] = mem[7] + 16'h0002	;
				end
			end
		end
	end
end

always @* begin
	if(clk) begin
		address<=mem[7];
		data_a<=mem[RA_add];
		data_b<=mem[RB_add];
	end
end


endmodule

