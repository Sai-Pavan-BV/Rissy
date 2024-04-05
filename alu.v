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

always @* begin
	if(clk) begin
		case(alu_op) 
			add_a: begin
						{flags[1],result}=data_a+data_b;
						flags[0]<=~|result;
					end
			nda:	begin
						result=~(data_a & data_b);
					end
			eq:	begin
						flags[0]<=~|(data_a-data_b);
						result<=16'hxxxx;
					end
			add_m: begin
						result=data_a+data_b;
						flags[0]<=~|result;
					end
			
		endcase
	end
end


endmodule
