/*module Rspace(Clk, StCont, Start, Done, Data, Outro, ASp, Bsp, Zsp);

input Clk;
input [5:0]StCont;
input Start;
output [31:0]Data;
output [5:0]Outro;
input Asp, Bsp, Zsp;
input Done;

//stack controller
//protocol:
//first 15 slots for speed measurements
//5 slots each for A, B, and Z in that order for spikes
//beyond 30th slot memory space is unreserved;
//total size, 64 words of size 32-bit
reg [1:0]Stk;

always @ (posedge Clk)
begin

case (Stk)

2'b00: //Idle State, awaiting command
begin
if (Start)
	Stk <= 2'b01;
else
	Stk <= 2'b00;
end

2'b01: //write in flags
begin

if (Start)
	Stk <= 2'b00;
else if (Done)
	Stk <= 2'b11;

else
	Stk <= 2'b01;

end
	

end




reg [5:0]address;
reg data[31:0];
reg wren;
wire [31:0]q;

//memory stack
Stack (memclr, address, Clk, data, wren, q);

endmodule*/
