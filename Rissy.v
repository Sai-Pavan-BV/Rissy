`timescale 1ns/1ns
module Rissy(clk,rst,inst,
					address,result,flags,bc,d1,d2);

input wire clk,rst;
input wire[15:0] inst;

output reg[15:0] address,result;
output reg[1:0] flags;
output reg bc;
output reg[15:0] d1,d2;

wire[2:0] in_write_add;


wire [15:0]in_address,in_data_a,in_data_b,data_a;				//in stands for internal wires

wire in_w_en,in_load_store,in_pc_inc;										
wire[2:0] in_RA_add,in_RB_add,in_alu_op;				
															
wire[15:0] in_immediate,in_result,write_data,mem_data;
wire[1:0] in_flags;
reg pc_inc;

wire in_bc;


reg_file r(clk,rst,in_w_en,in_pc_inc,
					write_data,in_write_add,in_RA_add,in_RB_add,
					in_address,in_data_a,in_data_b
					);
					
decoder  d(clk,inst,in_flags,
					in_w_en,in_load_store,in_pc_inc,
					in_RA_add,in_RB_add,in_alu_op,in_write_add,
					in_immediate,in_bc);

multiplex m_alu((in_alu_op[1]&in_alu_op[0]),in_data_a,in_immediate,data_a);

multiplex m_reg(in_alu_op[2],in_result,mem_data,write_data);

alu a(clk,in_alu_op[1:0],data_a,in_data_b,in_result,in_flags);

memory m(clk,in_load_store, in_alu_op[2],mem_data,in_result);
					
always @* begin
	address<=in_address;
	flags<=in_flags;
	result<=in_result;
	bc<=in_bc;
	d1<=data_a;
	d2<=in_data_b;
	
end

assign mem_data=(in_alu_op[2]&!(in_load_store))?in_data_a:16'hzzzz;

endmodule


module instruction_cache();

reg clk,rst;
reg[15:0]inst;

wire[15:0] address,result,d1,d2;
wire[1:0] flags;
wire bc;

Rissy r(clk,rst,inst,address,result,flags,bc,d1,d2);
reg[7:0] prog_mem[15:0];

always #5 clk=~clk;

initial begin
clk=0;
#1
rst=1;
#2
rst=0;
{prog_mem[1],prog_mem[0]} = 16'h0ba0;								//never do a branch instruction as 1st instruction
{prog_mem[3],prog_mem[2]} = 16'h8204;
{prog_mem[5],prog_mem[4]} = 16'h44c5;
{prog_mem[7],prog_mem[6]} = 16'h0220;
end

always @* begin
	if(clk) begin
		inst={prog_mem[address+1],prog_mem[address]};
	end
end
endmodule


