`timescale 1ns/1ns
module memory(clk,load_store,en,
					data,
					add);
input wire clk,load_store,en;
inout[15:0] data;
input wire[7:0] add;

reg[15:0] mem[255:0];
reg[15:0] data_o;

integer i;
initial begin
	for(i=0;i<256;i=i+1) begin
		mem[i]<=i;
	end
end

assign data=(en&load_store)?data_o:16'hzzzz;  //load

always @* begin
	if(clk) begin
		if(en) begin
			if(!load_store) begin
				mem[add]<=data;				//store
			end
			else begin
				data_o<=mem[add];				//load
			end
		end
	end
end

endmodule

module mem_test();

reg clk,load_store,en;
wire[15:0] data;
reg[15:0] data_o;
reg[7:0] add;

assign data=(!load_store)?data_o:16'hzzzz;

memory m(clk,load_store,en,
					data,
					add);

always #5 clk=~clk;

initial begin
clk=0;
#5
en=1;
load_store=0;
data_o=$random;
add=0;
#10
load_store=1;
add=0;
data_o=$random;

end
endmodule
