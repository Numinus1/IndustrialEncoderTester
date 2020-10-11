module UartCentral(Clk, Rx, Tx, TxEnable, MemDat, PPRin, CycDone, RetAdd, 
UserStart, MemSlave, rcmd, ZCount);

//Regular I/O's
input Clk, Rx;
output Tx, TxEnable;

//Memory Interface I/O's
input [31:0]MemDat;
input [31:0]ZCount;
input [15:0]PPRin;
input CycDone;
			
output [13:0] RetAdd;
output UserStart;
output [3:0]MemSlave;

output rcmd;

reg UseStart;
assign UserStart = UseStart;

reg [31:0]Data;
reg [2:0]SendPhase;
reg [13:0]RetrAdd;
reg [13:0]StopAdd;
reg [13:0]CurrAdd;
assign RetAdd = CurrAdd;

reg [3:0]MemSlaver;
assign MemSlave = MemSlaver;
//CNS Regs
reg ZSend = 0;
reg [3:0]CmdTx;
reg [3:0]nCmdTx;
wire [3:0]ReqRx;
wire TBusy, BytePing;

wire [7:0]ByteRequest;

//test stuff
reg [15:0]PPR;
reg [1:0]readPPR;

//reset command
reg reset;
assign rcmd = reset;

always @ (posedge Clk)
begin
if (ReqRx == 4'b1111)
	reset <= 1;
else
	reset <= 0;

end

//Instantiations
TxUartManager TxUM0(Clk, CmdTx, Tx, TxEnable, TBusy, BytePing, Data, PPR);
RxUartManager RxUM0(Clk, Rx, RBusy, ReqRx, ByteRequest);

always @ (posedge Clk)
begin

	case (readPPR)
	
	2'b00:
	begin
	if (CycDone)
		readPPR <= 2'b01;
	else
		readPPR <= 2'b00;
	end
	
	2'b01:
	begin
	if (CycDone)
		readPPR <= 2'b01;
	else
		readPPR <= 2'b10;
	end
	
	2'b10:
		readPPR <= 2'b00;
	
	
	
	default: readPPR <= 2'b00;
	endcase


end

always @ (posedge Clk)
begin
	
	if (reset)
		PPR <= 0;
	else if (readPPR == 2'b10)
		PPR <= PPRin;
	else
		PPR <= PPR;

end

 
reg [4:0]cenState;
reg [4:0]nState;
reg [2:0]delayCtr;

always @ (posedge Clk)
begin
 
if ((ReqRx == 4'b1000) || (ReqRx == 4'b1001) || (ReqRx == 4'b1010) || (ReqRx == 4'b1011))
	begin
	RetrAdd <= (ByteRequest * 100);
	StopAdd <= (ByteRequest * 100) + 100;
	end
else
	begin	
	RetrAdd <= RetrAdd;
	StopAdd <= StopAdd;
	end

end
 
always @ (posedge Clk)
begin
 
	case (cenState)
	
	5'b00000: //Idle
	begin

		delayCtr <= 0;
		ZSend <= 0;
		if (ReqRx == 4'b1111)
		begin
			nState <= 5'b00010;
			Data <= 32'h72527252;
			nCmdTx <= 4'b0100;
			cenState <= 5'b11111;
		end
		else if (ReqRx == 4'b0011)
		begin
			CmdTx <= 4'b0000;
			nCmdTx <= 4'b0011;
			nState <= 5'b00010;
			cenState <= 5'b11111;
		end
		else
		begin
			CmdTx <= ReqRx;
			cenState <= 5'b00000;
			Data <= 0;
		end
		
	end
	
	5'b00001: //after Cycle crossroads
	begin
	
		CmdTx <= 4'b0000;
		CurrAdd <= 0;
		
		if (ReqRx == 4'b1111)
		begin
			nState <= 5'b00010;
			Data <= 32'h72527252;
			nCmdTx <= 4'b0100;
			cenState <= 5'b11111;
		end
			
		else if (ReqRx == 4'b0011)
		begin
			nCmdTx <= 4'b0101;
			nState <= 5'b00010;
			cenState <= 5'b11111;
			Data <= ZCount;
			//ZSend <= 1;
		end
		else if (ReqRx == 4'b1000)
		begin
			nCmdTx <= 4'b0000;
			nState <= 5'b10000;
			cenState <= 5'b11111;
			SendPhase <= 3'b000;
		end
		else if (ReqRx == 4'b1001)
		begin
			nCmdTx <= 4'b0000;
			nState <= 5'b10000;
			cenState <= 5'b11111;
			SendPhase <= 3'b000;
		end
		else if (ReqRx == 4'b1010)
		begin
			nCmdTx <= 4'b0000;
			nState <= 5'b10000;
			cenState <= 5'b11111;
			SendPhase <= 3'b000;
		end
		else if (ReqRx == 4'b1011)
		begin
			nCmdTx <= 4'b0000;
			nState <= 5'b10000;
			cenState <= 5'b11111;
			SendPhase <= 3'b000;
		end
		else if (ReqRx == 4'b0000)
		begin
			nCmdTx <= 4'b0000;
			nState <= 5'b00000;
			cenState <= 5'b00001;
		end
		else
		begin
			nCmdTx <= ReqRx;
			nState <= 5'b00010;
			cenState <= 5'b11111;
			Data <= 0;
		end
		
	end
	
	5'b00010: //if not Data request, pass to Tx Manager
	begin
		
		if (~TBusy)
		begin
			CmdTx <= nCmdTx;
			//if (ZSend == 0)
			//begin
				nState <= 5'b00000;
				cenState <= 5'b00001;
			//end
			//else
			/*begin
				ZSend <= 0;
				Data <= ZCount;
				nCmdTx <= 4'b0100;
				nState <= 5'b00010;
				cenState <= 5'b11111;
			end*/
			if (reset)
				cenState <= 5'b00000;
			else
				cenState <= 5'b00001;
		end
		else
		begin
			Data <= Data;
			CmdTx <= 4'b0000;
			cenState <= 5'b00010;
		end

	end
 
	5'b10000:
	begin
		if (~TBusy)
		begin
			if (SendPhase == 0)
			begin
				Data[31:16] <= 16'hDDDD;
				Data[15:14] <= 2'b00;
				Data[13:0] <= RetrAdd[13:0];
				CmdTx <= 4'b0100;
				SendPhase <= 1;
				CurrAdd <= RetrAdd;
				nState <= 5'b10000;
				cenState <= 5'b11111;
			end
			else if (SendPhase == 1)
			begin
				
				if (CurrAdd == StopAdd)
				begin
					CmdTx <= 4'b0110;
					nState <= 5'b00001;
					cenState <= 5'b11111;
					SendPhase <= 0;
				end
				else
				begin
					Data <= MemDat;
					CurrAdd <= CurrAdd + 1;
					CmdTx <= 4'b0100;
					SendPhase <= 1;
					nState <= 5'b10000;
					cenState <= 5'b11111;
				end
				
			end
			else if (SendPhase == 2)
			begin
				Data[31:30] <= 2'b00;
				Data[29:16] <= RetrAdd[13:0];
				Data[15:14] <= 2'b00;
				Data[13:0] <= StopAdd[13:0];
				CmdTx <= 4'b0100;
				SendPhase <= 0;
				nState <= 5'b00001;
				cenState <= 5'b11111;
			end
			else
			begin
				CmdTx <= 4'b0000;
				nState <= 5'b00001;
				cenState <= 5'b11111;
			end
		end
		else
		begin
			Data <= Data;
			CmdTx <= 4'b0000;
			cenState <= 5'b10000;
		end
	
	end
	
	
	5'b11111:
	begin
	Data <= Data;
	CmdTx <= 4'b0000;
	if (delayCtr == 3'b111)
	begin
		delayCtr <= 3'b000;
		cenState <= nState;
	end
	else
	begin
		delayCtr <= delayCtr + 1;
		cenState <= 5'b11111;
	end
	
	end
	
	default: cenState <= 5'b00000;
	endcase
end

//Start Signal Logic

always @ (posedge Clk)
begin

if ((ReqRx == 4'b0011) && (cenState == 5'b00000))
	UseStart <= 1;
else
	UseStart <= 0;
	
end
 
//Memory Slave Logic
always @ (posedge Clk)
begin

if (cenState == 5'b00000)
begin
	MemSlaver <= 4'b0000;
end
else if (cenState == 5'b00001)
begin
	if ((ReqRx == 4'b1000)||(ReqRx == 4'b1001)||(ReqRx == 4'b1010)||(ReqRx == 4'b1011))
		MemSlaver <= ReqRx;
	else
		MemSlaver <= 4'b0000;
end
else
	MemSlaver <= MemSlaver;

end


endmodule 