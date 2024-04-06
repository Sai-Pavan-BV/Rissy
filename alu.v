`timescale 1ns/1ns
module alu(clk,alu_op,data_a,data_b,
				result,flags);

input wire clk;
input wire[1:0] alu_op;
input wire[15:0] data_a,data_b;

output reg[15:0] result;
output reg[1:0] flags;				//2nd bit for carry, 1st bit for zero

parameter add_a=2'b00,				//add for arthematic operation
			nda=2'b01,					//nand
			eq=2'b10,					//operation for equal
			add_m=2'b11;			// add for memory operation

initial begin
flags<=2'b00;
end
			
always @* begin
	if(clk) begin
		case(alu_op) 
			add_a: begin
						{flags[1],result}=data_a+data_b;
						flags[0]<=(result==0)?1:0;
					end
			nda:	begin
						result=~(data_a & data_b);
					end
			eq:	begin
						flags[0]<=(result==0)?1:0;
						result<=data_a-data_b;
					end
			add_m: begin
						result=data_a+data_b;
						flags[0]<=~|result;
					end
			
		endcase
	end
end


endmodule

module alu_tb();
reg clk;
reg [1:0] alu_op;
reg [15:0] data_a,data_b;

wire[15:0] result;
wire[1:0] flags;


alu a(clk,alu_op,data_a,data_b,result,flags);

always #5 clk=~clk;

initial begin
	clk=0;
	alu_op=3'b010;
	data_a<=3;
	data_b<=3;
end
endmodule
