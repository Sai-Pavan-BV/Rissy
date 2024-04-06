`timescale 1ns/1ns
module decoder(clk,inst,
					flags,
					w_en,load_store,pc_inc,
					RA_add,RB_add,alu_op,write_add,
					immediate,bra_counter);

input wire clk;
input wire[1:0] flags;
input wire[15:0] inst;

output reg w_en,load_store,pc_inc;										// jump and conditional bra,write enable
output reg[2:0] RA_add,RB_add,alu_op,write_add;					//alu_op 3'b0xx arthematic
																	//			3'b1xx memory
output reg[15:0] immediate;

output reg bra_counter;
parameter ADD=4'h0,
			NDU=4'h2,
			LW=4'h4,
			SW=4'h5,
			BEQ=4'hc,
			JAL=4'h8;
			
initial begin
	bra_counter<=0;
	pc_inc<=0;

end
			
always @* begin
	if(clk) begin
		case(inst[15:12]) 
			ADD: begin
					alu_op<=3'b000;
					RA_add<=inst[11:9];
					RB_add<=inst[8:6];
					write_add<=inst[5:3];
					w_en<=1;
					immediate<=16'hxxxx;
					load_store<=1'bx;
					pc_inc<=1;
					end
			NDU: begin
					alu_op<=3'b001;
					RA_add<=inst[11:9];
					RB_add<=inst[8:6];
					write_add<=inst[5:3];
					w_en<=1;
					immediate<=16'hxxxx;
					load_store<=1'bx;
					pc_inc<=1;
					end
			LW: begin
					alu_op<=3'b111;
					RA_add<=3'hx;
					RB_add<=inst[8:6];
					write_add<=inst[11:9];
					w_en<=1;
					immediate<={10'h000,inst[5:0]};
					load_store<=1'b1;
					pc_inc<=1;
					end
			SW: begin
					alu_op<=3'b111;
					RA_add<=inst[11:9];
					RB_add<=inst[8:6];
					write_add<=3'hx;
					w_en<=0;
					immediate<={10'h000,inst[5:0]};
					load_store<=1'b0;
					pc_inc<=1;
					end
			BEQ: begin
					if(!bra_counter) begin
							alu_op<=3'b010;
							RA_add<=inst[11:9];
							RB_add<=inst[8:6];
							write_add<=3'hx;
							w_en<=0;
							immediate<=16'hxxxx;
							load_store<=1'b0;
							if(flags[0]) begin				//condition satisfied
								pc_inc<=0;
							end
							else begin
								pc_inc<=1;
							end
						end
						if(bra_counter) begin			//if condition satisfied
							alu_op<=3'b011;
							RA_add<=3'hx;
							RB_add<=3'h7;
							write_add<=3'h7;
							w_en<=1;
							load_store<=1'b0;
							immediate<=({10'h000,inst[5:0]}-16'h0002);				//TO BRANCH TO NEGATIVE NUMBERS CONVERT THE
							pc_inc<=1;															//IMMEDIATE TO A SIGNED NUMBER. BUT DUE TO THE												//LIMITED PROGRAM MEMORY ONLY POSITIVE JUMPS ARE 
																									//POSSIBLE
							
						end
					end
					
			JAL: begin
					if(!bra_counter) begin
							alu_op<=3'b011;
							RA_add<=3'hx;
							RB_add<=7;
							write_add<=inst[11:9];
							w_en<=1;
							immediate<=16'h0002;
							load_store<=1'b0;
							pc_inc<=0;
						end
						if(bra_counter) begin			//if condition satisfied
							alu_op<=3'b011;
							RA_add<=3'hx;
							RB_add<=3'h7;
							write_add<=3'h7;
							w_en<=1;
							load_store<=1'b0;
							immediate<=({7'h00,inst[8:0]}-16'h0002);				//TO BRANCH TO NEGATIVE NUMBERS CONVERT THE
							pc_inc<=1;															//IMMEDIATE TO A SIGNED NUMBER. BUT DUE TO THE													//LIMITED PROGRAM MEMORY ONLY POSITIVE JUMPS ARE 
																									//POSSIBLE
							
						end
					end
					
	endcase
	end
end

always @* begin
	if(!clk) begin
		bra_counter<=~pc_inc;
	end
end
endmodule

module dec_tb();

reg clk;
reg[1:0] flags;
reg[15:0] inst;

wire w_en,load_store,pc_inc;										// jump and conditional bra,write enable
wire[2:0] RA_add,RB_add,alu_op,write_add;					//alu_op 3'b0xx arthematic
																	//			3'b1xx memory
wire[15:0] immediate;

wire bra_counter;

decoder d(clk,inst,
					flags,
					w_en,load_store,pc_inc,
					RA_add,RB_add,alu_op,write_add,
					immediate,bra_counter);
					
always #5 clk=~clk;

initial begin
	clk<=0;
	#4
	inst<=16'hc282;
	flags<=2'b00;
	#2
	flags<=2'b01;
	#8;
	inst<=16'hc242;
	
end

endmodule
