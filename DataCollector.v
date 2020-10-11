module DataCollector (aCLR, Clk, AddrA, AddrB, AEn, BEn, Timer, qA, qB);

input wire Clk;
input wire aCLR;

input wire [13:0]AddrA;
input wire [13:0]AddrB;
input wire AEn;
input wire BEn;

input wire [31:0]Timer;

output wire [31:0]qA;
output wire [31:0]qB;


////****Memory Block Instantiations****\\\\
SigMem A0(aCLR, AddrA, Clk, Timer, AEn, qA);
SigMem B0(aCLR, AddrB, Clk, Timer, BEn, qB);

endmodule
