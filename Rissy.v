`timescale 1ns/1ns
module Rissy(clk,rst,inst,
					address,result,flags);

input wire clk,rst;
input wire[15:0] inst;

output reg[15:0] address,result;
output reg[1:0] flags;
wire[2:0] in_write_add;


wire [15:0]in_address,in_data_a,in_data_b,data_a;				//in stands for internal wires

wire in_bra_c,in_w_en,in_load_store,in_pc_inc;										
wire[2:0] in_RA_add,in_RB_add,in_alu_op;				
															
wire[15:0] in_immediate,in_result,write_data,mem_data;
wire[1:0] in_flags;
reg pc_inc;
always @(negedge clk,posedge rst) begin
pc_inc<=in_pc_inc|~rst;
end

reg_file r(clk,rst,in_w_en,pc_inc,
					write_data,in_write_add,in_RA_add,in_RB_add,
					in_address,in_data_a,in_data_b
					);
					
decoder  d(clk,inst,in_bra_c,in_w_en,in_load_store,in_pc_inc,
					in_RA_add,in_RB_add,in_alu_op,in_write_add,
					in_immediate);

multiplex m_alu(in_alu_op[2],in_data_a,in_immediate,data_a);

multiplex m_reg(in_alu_op[2],in_result,mem_data,write_data);

alu a(clk,in_alu_op,data_a,in_data_b,in_result,in_flags);

memory m(clk,in_load_store, in_alu_op[2],mem_data,in_result);
					
always @* begin
	address<=in_address;
	flags<=in_flags;
	result<=in_result;
	
end

assign mem_data=(in_alu_op[2]&!(in_load_store))?in_data_a:16'hzzzz;

endmodule


module instruction_cache();

reg clk,rst;
reg[15:0]inst;

wire[15:0] address,result;
wire[1:0] flags;

Rissy r(clk,rst,inst,address,result,flags);
reg[7:0] prog_mem[15:0];

always #5 clk=~clk;

initial begin
clk=0;
#1
rst=1;
#2
rst=0;
{prog_mem[1],prog_mem[0]} = 16'h4a40;
{prog_mem[3],prog_mem[2]} = 16'h0a58;
{prog_mem[5],prog_mem[4]} = 16'h5601;
{prog_mem[7],prog_mem[6]} = 16'h4601;
{prog_mem[9],prog_mem[8]} = 16'h0658;
{prog_mem[11],prog_mem[10]} = 16'h0618;
end

always @* begin
	if(clk) begin
		inst={prog_mem[address+1],prog_mem[address]};
	end
end
endmodule


