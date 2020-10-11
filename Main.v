module Main (LED, SW, KEY, ClkA, Tx, Rx, TxEnable, AIn, BIn, ZIn,
 TestIn0, TestIn1, TestOut0, TestOut1);

input [1:0]SW;
input [1:0]KEY;
input ClkA;
input Rx;
input AIn, BIn, ZIn;
input TestIn0, TestIn1;

output [7:0]LED;
output Tx;
output TxEnable;
output TestOut0, TestOut1;

wire Ap, Bp, Zp;
wire An, Bn, Zn;
wire Ai, Bi, Zi;
wire Aflag, Bflag, Zflag;
reg Zflagged = 0;
wire [31:0]ZCount;
wire RxC;

//Clock Multiplier
wire areset, locked;
wire Clker, Clk;

//assign Clk = ClkA;

wire SupA, SupB;
reg Enable = 1'b0;
ClockAcc PLL0(areset, ClkA, Clker, locked);
Quadrature Qualude0(SupA, SupB, Clker, Enable, Clk);
	
////****Sieve Inputs****\\\\
inSieve ASig(AIn, Ai, Clk);
inSieve BSig(BIn, Bi, Clk);
inSieve ZSig(ZIn, Zi, Clk);
inSieve RxSig(Rx, RxC, Clk);
Ranger(Ai, Ap, An, Clk, AFlag);
Ranger(Bi, Bp, Bn, Clk, BFlag);
Ranger(Zi, Zp, Zn, Clk, ZFlag);

always @ (posedge Clk)
begin
	if (rset)
	Zflagged <= 0;
	else
	begin
		if (ZFlag == 1)
			Zflagged <= 1;
	end
end

////****Instantiations****\\\\
//Uart
wire [31:0]MemDataP;
wire [31:0]MemDataN;
wire [31:0]MemData;
wire [15:0]PPR;
wire [15:0]PPR0;
wire CycleDone;
wire CycleDone0;

wire [13:0]RetAddr;
wire UStart;
wire [1:0]MemSlave;
wire [3:0]MemCmd;
//pseudo
wire [31:0]Fzc;

//global reset
wire rcmd, rset;
greset rset0(rcmd, rset, Clk);

//UartCentralTrial UART0(Clk, Rx, Tx, TxEnable);
UartCentral UART0(Clk, RxC, Tx, TxEnable, MemData, PPR, CycleDone, RetAddr, 
UStart, MemCmd, rcmd, ZCount);

//Signal Router

SigRouter SigP(Clk, Ap, Bp, Zp, UStart, 
MemSlave, RetAddr, rset, PPR, CycleDone, MemDataP, ZCount);


SigRouter SigN(Clk, An, Bn, Zp, UStart, 
MemSlave, RetAddr, rset, PPR0, CycleDone0, MemDataN, Fzc);


//Memory Manager
memManager (MemCmd, MemSlave, MemDataP, MemDataN, MemData);

//Flag Modules

assign LED[6:0] = 7'b1111111;

assign LED[7] = ~Zflagged;


endmodule
