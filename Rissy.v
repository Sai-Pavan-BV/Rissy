`timescale 1ns/1ns
module Rissy(clk,rst,inst,
				address,data_a,data_b);

input wire clk,rst;
input wire[15:0] inst;

output reg[15:0] address,data_a,data_b;

reg[15:0] inst_reg;

wire[15:0] write_data;
wire[2:0] write_add,RA_add,RB_add;


wire [15:0]in_address,in_data_a,in_data_b;

reg_file r(clk,rst,1'b0,1'b1,
					16'hxxxx,3'hx,2,3,
					in_address,in_data_a,in_data_b
					);
					
always @(negedge clk) begin
	inst_reg=inst;
end

always @* begin
	address<=in_address;
	data_a<=in_data_a;
	data_b<=in_data_b;
end


endmodule


module instruction_cache();

reg clk,rst;
reg[15:0]inst;

wire[15:0] address,data_a,data_b;

Rissy r(clk,rst,inst,address,data_a,data_b);

reg[7:0] prog_mem[15:0];

always #5 clk=~clk;

initial begin
clk=0;
#1
rst=1;
#2
rst=0;
{prog_mem[1],prog_mem[0]}=16'b0000000001010000;
end

always @* begin
	if(clk) begin
		inst={prog_mem[address+1],prog_mem[address]};
	end
end
endmodule


