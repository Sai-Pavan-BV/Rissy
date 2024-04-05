module multiplex(sel,data_1,data_2,data);
input wire sel;
input wire[15:0] data_1,data_2;
output reg[15:0] data;

always @* begin
	case(sel)
		0:data<=data_1;
		1:data<=data_2;
	endcase
end
endmodule
