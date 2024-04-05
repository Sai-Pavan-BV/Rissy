module decoder(clk,inst,bra_c,w_en,load_store,pc_inc,
					RA_add,RB_add,alu_op,write_add,
					immediate);

input wire clk;
input wire[15:0] inst;

output reg bra_c,w_en,load_store,pc_inc;										// jump and conditional bra,write enable
output reg[2:0] RA_add,RB_add,alu_op,write_add;					//alu_op 3'b0xx arthematic
																	//			3'b1xx memory
output reg[15:0] immediate;

parameter ADD=4'h0,
			NDU=4'h2,
			LW=4'h4,
			SW=4'h5,
			BEQ=4'hc,
			JAL=4'h8;
always @* begin
	if(clk) begin
		case(inst[15:12]) 
			ADD: begin
					alu_op<=3'b000;
					RA_add<=inst[11:9];
					RB_add<=inst[8:6];
					write_add<=inst[5:3];
					bra_c<=0;
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
					bra_c<=0;
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
					bra_c<=0;
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
					bra_c<=0;
					w_en<=0;
					immediate<={10'h000,inst[5:0]};
					load_store<=1'b0;
					pc_inc<=1;
					end
			BEQ: begin
					alu_op<=3'b010;
					RA_add<=inst[11:9];
					RB_add<=inst[8:6];
					write_add<=3'hx;
					bra_c<=1;
					w_en<=0;
					immediate<={10'h000,inst[5:0]};
					load_store<=1'b0;
					pc_inc<=1;
					end
					
			JAL: begin
					alu_op<=3'b000;
					RA_add<=inst[11:9];
					RB_add<=inst[8:6];
					write_add<=inst[11:9];
					bra_c<=0;
					w_en<=1;
					immediate<={10'h000,inst[5:0]};
					load_store<=1'b0;
					pc_inc<=1;
					end
					
	endcase
	end
end
endmodule