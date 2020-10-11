module TxUartManager (Clk, Cmd, Tx, TxEnable, TBusy, BytePing, Data, PPR);

//I/O's
input Clk;
input [3:0]Cmd; // 3'b000: Idle; 3'b001: ID 
input [31:0]Data;
input [15:0]PPR;

output Tx, TxEnable, BytePing, TBusy;

//Outgoing Connections and Outgoing Status Holders
reg BytePinger;
assign BytePing = BytePinger;

reg Sending;
assign TBusy = Sending; 

wire TxSig;
assign Tx = TxSig;

wire DoneSig;

wire SerClock, SerHalf;
wire TxEnabler;
assign TxEnable = TxEnabler;

//Internal Regs/Wires
wire [7:0]SData;
wire Start;

////////*****Transmit Branch Signals*****\\\\\\\\

//Initiate Comm
reg IDSig;
reg StatusSig;
reg StartSig;
reg SendSig;
reg ResetSig;
reg PPRSig;
reg StopSig;
reg TempSig; //Testing

//Comm Complete Feedback
reg SigID;
reg SigStatus;
reg SigStart;
reg SigSend;
reg SigReset;
reg SigPPR;
reg SigStop;
reg SigTemp; //Testing
wire UniversalSigEnd;
assign UniversalSigEnd = SigID + SigStatus + SigStart + SigSend + 
SigReset + SigPPR +SigStop + SigTemp;
////////*****Transmit Branch/CMD Isolation*****\\\\\\\\
always @ (posedge Clk)
begin
	
	case (Cmd)
	
	4'b0000: //Idle
	begin
	IDSig <= 0;
	StatusSig <= 0;
	StartSig <= 0;
	SendSig <= 0;
	ResetSig <= 0;
	PPRSig <= 0;
	StopSig <= 0;
	TempSig <= 0;
	end
	
	4'b0001: //ID
	begin
	IDSig <= 1;
	StatusSig <= 0;
	StartSig <= 0;
	SendSig <= 0;
	ResetSig <= 0;
	PPRSig <= 0;
	StopSig <= 0;
	TempSig <= 0;
	end
	
	4'b0011: //Start
	begin
	IDSig <= 0;
	StatusSig <= 0;
	StartSig <= 1;
	SendSig <= 0;
	ResetSig <= 0;
	PPRSig <= 0;
	StopSig <= 0;
	TempSig <= 0;
	end
	
	4'b0100: //Send Data
	begin
	IDSig <= 0;
	StatusSig <= 0;
	StartSig <= 0;
	SendSig <= 1;
	ResetSig <= 0;
	PPRSig <= 0;
	StopSig <= 0;
	TempSig <= 0;
	end
	
	4'b0101: //Send PPR
	begin
	IDSig <= 0;
	StatusSig <= 0;
	StartSig <= 0;
	SendSig <= 0;
	ResetSig <= 0;
	PPRSig <= 1;
	StopSig <= 0;
	TempSig <= 0;
	end
	
	4'b0111: //Test
	begin
	IDSig <= 0;
	StatusSig <= 0;
	StartSig <= 0;
	SendSig <= 0;
	ResetSig <= 0;
	PPRSig <= 0;
	StopSig <= 0;
	TempSig <= 1;	
	end
	
	4'b0110: //Send Stop
	begin
	IDSig <= 0;
	StatusSig <= 0;
	StartSig <= 0;
	SendSig <= 0;
	ResetSig <= 0;
	PPRSig <= 0;
	StopSig <= 1;
	TempSig <= 0;	
	end
	endcase
	
end


////////*****Transmit Branch Control*****\\\\\\\\
reg [3:0]TrBr;
//reg [1:0]TrBrChk;

always @ (posedge Clk)
begin

	case (TrBr)
	
	4'b0000: //Idle
	begin
	if (IDSig == 1)
		TrBr <= 4'b0001;
	else if (StatusSig == 1)
		TrBr <= 4'b0010;
	else if (StartSig == 1)
		TrBr <= 4'b0011;
	else if (SendSig == 1)
		TrBr <= 4'b0100;
	else if (PPRSig == 1)
		TrBr <= 4'b0101;
	else if (TempSig == 1)
		TrBr <= 4'b0111;
	else if (StopSig == 1)
		TrBr <= 4'b0110;
	else if (ResetSig == 1)
		TrBr <= 4'b0000;
	end
	
	4'b0001:
	begin
	/*if (TrBrChk != 2)
		TrBrChk <= TrBrChk + 1;
	else
		TrBrChk <= TrBrChk;
		
	if (SigID == 1) 
		TrBr <= 4'b0000; *///Reply to ID Query
	TrBr <= 4'b1111;
	end
	
	//3'b010:  //Send Status 		
	//3'b011:  //Reply to Start signal
	//3'b100:	//Reply to Data Request
	//3'b101:	//assert global Reset and reply
	
	4'b0011:
	begin
	/*if (TrBrChk != 2)
		TrBrChk <= TrBrChk + 1;
	else
		TrBrChk <= TrBrChk;*/
	TrBr <= 4'b1111;	
	//if (SigTemp == 1) TrBr <= 4'b0000;//temporary, for testing
	end
	
	4'b0100: //Send Data
	begin
		TrBr <= 4'b1111;
	end
	
	4'b0101: //PPR
	begin

	TrBr <= 4'b1111;	
	end
	
	4'b0110: //Send Stop
	begin

	TrBr <= 4'b1111;	
	end
	
	4'b0111:
	begin
	/*if (TrBrChk != 2)
		TrBrChk <= TrBrChk + 1;
	else
		TrBrChk <= TrBrChk;*/
	TrBr <= 4'b1111;	
	//if (SigTemp == 1) TrBr <= 4'b0000;//temporary, for testing
	end
	
	4'b1111:
	begin
	if (UniversalSigEnd == 1)
		TrBr <= 4'b1110;
	end
		
	4'b1110:
	begin
		TrBr <= 4'b0000;
	end
	
	
	default: TrBr <= 4'b0000;
	
	endcase

end

//FSM Busy Status Control
always @ (posedge Clk)
begin

	if (TrBr == 4'b0000)
		Sending <= 0;
	else
		Sending <= 1;

end

////////*****TX ID Query Control*****\\\\\\\\
reg [7:0] IDData;
reg [3:0] IDstate;
reg IDStart;

always @ (posedge Clk)
begin

case (IDstate)

	4'b0000: //wait for TrBr to signal
	begin
	IDStart <= 0;
	SigID <= 0;
	IDData <= 8'h00;
	if (TrBr == 4'b0001)
		IDstate <= 4'b0001;
	end
	
	4'b0001:
	begin
	IDData <= 8'h48; //ready Data Byte 1
	IDStart <= 1;
	IDstate <= 4'b0010;
	end	
	
   4'b0010:
	begin
	IDStart <= 0;	//wait for Byte 1 send
	if (BytePing == 1)
		IDstate <= 4'b0011;
	end
	
	4'b0011:
	begin
	IDData <= 8'h65; //ready Data Byte 2
	IDStart <= 1;
	IDstate <= 4'b0100;
	end		  
	4'b0100: 
	begin
	IDStart <= 0;	//wait for Byte 2 send
	if (BytePing == 1)
		IDstate <= 4'b0101;
	end
	
	4'b0101: 
	begin
	IDData <= 8'h6C; //ready Data Byte 3
	IDStart <= 1;
	IDstate <= 4'b0110;
	end
	
	4'b0110: 
	begin
	IDStart <= 0;	//wait for Byte 3 send
	if (BytePing == 1)
		IDstate <= 4'b0111;
	end
	
	4'b0111: 
	begin
	IDData <= 8'h6C; //ready Data Byte 4
	IDStart <= 1;
	IDstate <= 4'b1000;
	end
	
	4'b1000: 
	begin
	IDStart <= 0;	//wait for Byte 4 send
	if (BytePing == 1)
		IDstate <= 4'b1001;
	end
	
	4'b1001: 
	begin
	IDData <= 8'h6F; //ready Data Byte 5
	IDStart <= 1;
	IDstate <= 4'b1010;
	end
	
	4'b1010: 
	begin
	IDStart <= 0;	//wait for Byte 5 send
	if (BytePing == 1)
		IDstate <= 4'b1011;
	end
	
	4'b1011: 
	begin
	IDData <= 8'h2E; //fullstop 1
	IDStart <= 1;
	IDstate <= 4'b1100;
	end
	
	4'b1100: 
	begin
	IDStart <= 0;	//wait for fullstop 1 send
	if (BytePing == 1)
		IDstate <= 4'b1101;
	end
	
	4'b1101: 
	begin
	IDData <= 8'h2E; //fullstop 2
	IDStart <= 1;
	IDstate <= 4'b1110;
	end
	
	4'b1110: 
	begin
	IDStart <= 0;	//wait for fullstop 2 send
	if (BytePing == 1)
		begin
		IDData <= 8'h00;
		IDstate <= 4'b0000; //Return to Idle
		SigID <= 1;
		end
	end
	default: IDstate <= 4'b0000;
	endcase
			 
end

////////*****TX Start Query Control*****\\\\\\\\

reg [7:0]StartData;
reg [3:0] Startstate;
reg StartStart;

always @ (posedge Clk)
begin

	case (Startstate)
	
	4'b0000: //wait for TrBr to signal
	begin
	StartStart <= 0;
	SigStart <= 0;
	StartData <= 8'h00;
	if (TrBr == 4'b0011)
		Startstate <= 4'b0001;
	end
	
	4'b0001:
	begin
	StartData <= 8'h47; //ready Data Byte 1
	StartStart <= 1;
	Startstate <= 4'b0010; //wfwef
	end	
	
   4'b0010: 
	begin
	StartStart <= 0;	//wait for Byte 1 send
	if (BytePing == 1)
		Startstate <= 4'b1000;
	end
	
	4'b1000:
	begin
	StartData <= 8'h47; //new B2
	StartStart <= 1;
	Startstate <= 4'b1001;
	end
	
	4'b1001:
	begin
	StartStart <= 0;
	if (BytePing == 1)
		Startstate <= 4'b0011;
	
	end
	
	4'b0011: 
	begin
	StartData <= 8'h2E; //ready Data Byte 2
	StartStart <= 1;
	Startstate <= 4'b0100;
	end
	
	4'b0100:
	begin
	StartStart <= 0; //wait for Byte 2 send
	if (BytePing == 1)
		Startstate <= 4'b0101;
	
	end
	
	4'b0101: 
	begin
	StartData <= 8'h2E; //ready Data Byte 3
	StartStart <= 1;
	Startstate <= 4'b0110;
	end
	
	4'b0110:
	begin
	StartStart <= 0;	//wait for Byte 3 send
	if (BytePing == 1)
		begin
		StartData <= 8'h00;
		Startstate <= 4'b0000; //Return to Idle
		SigStart <= 1;
		end
	end
	
	default: Startstate <= 4'b0000;
	endcase



end

////////*****TX PPR Query Control*****\\\\\\\\
reg [7:0]PPRData;
reg [4:0]PPRstate;
reg PPRStart;

always @ (posedge Clk)
begin

	case (PPRstate)
	
	5'b00000: //wait for TrBr to signal
	begin
	PPRStart <= 0;
	SigPPR <= 0;
	PPRData <= 8'h00;
	if (TrBr == 4'b0101)
		PPRstate <= 5'b00001;
	end
	
	5'b00001:
	begin
	PPRData <= 8'h47;
	PPRStart <= 1;
	PPRstate <= 5'b00010;
	end
	
	5'b00010:
	begin
	PPRStart <= 0;	//wait for Byte 1 send
	if (BytePing == 1)
		PPRstate <= 5'b00011;
	end
	
	5'b00011:
	begin
	PPRData <= 8'h47;
	PPRStart <= 1;
	PPRstate <= 5'b00100;
	end
	
	5'b00100:
	begin
	PPRStart <= 0;	//wait for Byte 1 send
	if (BytePing == 1)
		PPRstate <= 5'b00101;
	end
	
	5'b00101:
	begin
	PPRData <= PPR[15:8]; //ready Data Byte 1
	PPRStart <= 1;
	PPRstate <= 5'b00110; //wfwef
	end	
	
   5'b00110: 
	begin
	PPRStart <= 0;	//wait for Byte 1 send
	if (BytePing == 1)
		PPRstate <= 5'b00111;
	end
	
	5'b00111:
	begin
	PPRData <= PPR[7:0]; //new B2
	PPRStart <= 1;
	PPRstate <= 5'b01000;
	end
	
	5'b01000:
	begin
	PPRStart <= 0;
	if (BytePing == 1)
		PPRstate <= 5'b01001;
	
	end
	
	5'b01001:
	begin
	PPRData <= Data[31:24];
	PPRStart <= 1;
	PPRstate <= 5'b01010;
	end
	
	5'b01010:
	begin
	PPRStart <= 0; //wait for Byte 2 send
	if (BytePing == 1)
		PPRstate <= 5'b01011;
	
	end
	
	5'b01011:
	begin
	PPRData <= Data[23:16];
	PPRStart <= 1;
	PPRstate <= 5'b01100;
	end
	
	5'b01100:
	begin
	PPRStart <= 0; //wait for Byte 2 send
	if (BytePing == 1)
		PPRstate <= 5'b01101;
	
	end
	
	5'b01101:
	begin
	PPRData <= Data[15:8];
	PPRStart <= 1;
	PPRstate <= 5'b01110;
	end
	
	5'b01110:
	begin
	PPRStart <= 0; //wait for Byte 2 send
	if (BytePing == 1)
		PPRstate <= 5'b01111;
	
	end
	
	5'b01111:
	begin
	PPRData <= Data[7:0];
	PPRStart <= 1;
	PPRstate <= 5'b10000;
	end
	
	5'b10000:
	begin
	PPRStart <= 0; //wait for Byte 2 send
	if (BytePing == 1)
		PPRstate <= 5'b10001;
	
	end
	
	5'b10001: 
	begin
	PPRData <= 8'h2E; //ready Data Byte 2
	PPRStart <= 1;
	PPRstate <= 5'b10010;
	end
	
	5'b10010:
	begin
	PPRStart <= 0; //wait for Byte 2 send
	if (BytePing == 1)
		PPRstate <= 5'b10011;
	
	end
	
	5'b10011: 
	begin
	PPRData <= 8'h2E; //ready Data Byte 3
	PPRStart <= 1;
	PPRstate <= 5'b10100;
	end
	
	5'b10100:
	begin
	PPRStart <= 0;	//wait for Byte 3 send
	if (BytePing == 1)
		begin
		PPRData <= 8'h00;
		PPRstate <= 5'b00000; //Return to Idle
		SigPPR <= 1;
		end
	end
	
	default: PPRstate <= 5'b00000;
	endcase



end

////////*****TX Send Data Query Control*****\\\\\\\\

reg [7:0]SendData;
reg [3:0] Sendstate;
reg SendStart;

always @ (posedge Clk)
begin

	case (Sendstate)
	
	4'b0000: //wait for TrBr to signal
	begin
	SendStart <= 0;
	SigSend <= 0;
	SendData <= 8'h00;
	if (TrBr == 4'b0100)
		Sendstate <= 4'b0001;
	end
	
	4'b0001:
	begin
	SendData <= Data[31:24]; //ready Data Byte 1
	SendStart <= 1;
	Sendstate <= 4'b0010; //wfwef
	end	
	
   4'b0010: 
	begin
	SendStart <= 0;	//wait for Byte 1 send
	if (BytePing == 1)
		Sendstate <= 4'b0011;
	end
	
	4'b0011:
	begin
	SendData <= Data[23:16]; //ready Data Byte 1
	SendStart <= 1;
	Sendstate <= 4'b0100; //wfwef
	end	
	
   4'b0100: 
	begin
	SendStart <= 0;	//wait for Byte 1 send
	if (BytePing == 1)
		Sendstate <= 4'b0101;
	end
	
	4'b0101:
	begin
	SendData <= Data[15:8]; //ready Data Byte 1
	SendStart <= 1;
	Sendstate <= 4'b0110; //wfwef
	end	
	
   4'b0110: 
	begin
	SendStart <= 0;	//wait for Byte 1 send
	if (BytePing == 1)
		Sendstate <= 4'b0111;
	end
	
	4'b0111:
	begin
	SendData <= Data[7:0]; //ready Data Byte 1
	SendStart <= 1;
	Sendstate <= 4'b1000; //wfwef
	end	
	
   4'b1000: 
	begin
	SendStart <= 0;	//wait for Byte 3 send
	if (BytePing == 1)
		begin
		SendData <= 8'h00;
		Sendstate <= 4'b0000; //Return to Idle
		SigSend <= 1;
		end
	end
	
	default: Sendstate <= 4'b0000;
	endcase



end

////////*****TX Send Stops Control*****\\\\\\\\
reg [7:0]StopData;
reg [3:0] Stopstate;
reg StopStart;

always @ (posedge Clk)
begin

	case (Stopstate)
	
	4'b0000: //wait for TrBr to signal
	begin
	StopStart <= 0;
	SigStop <= 0;
	StopData <= 8'h00;
	if (TrBr == 4'b0110)
		Stopstate <= 4'b0001;
	end
	
	4'b0001:
	begin
	StopData <= 8'h2A; //ready Data Byte 1
	StopStart <= 1;
	Stopstate <= 4'b0010; //wfwef
	end	

	4'b0010: 
	begin
	StopStart <= 0;	//wait for Byte 1 send
	if (BytePing == 1)
		Stopstate <= 4'b0011;
	end
	
	4'b0011:
	begin
	StopData <= 8'h2B; //ready Data Byte 1
	StopStart <= 1;
	Stopstate <= 4'b0100; //wfwef
	end	
	
	4'b0100:
	begin
	StopStart <= 0;	//wait for Byte 3 send
	if (BytePing == 1)
		begin
		StopData <= 8'h00;
		Stopstate <= 4'b0000; //Return to Idle
		SigStop <= 1;
		end
	end
	
	default: Stopstate <= 4'b0000;
	endcase



end
////////*****TX Temp Query Control*****\\\\\\\\
reg [7:0]TempData;
reg [3:0] Tempstate;
reg TempStart;

always @ (posedge Clk)
begin

	case (Tempstate)
	
	4'b0000: //wait for TrBr to signal
	begin
	TempStart <= 0;
	SigTemp <= 0;
	TempData <= 8'h00;
	if (TrBr == 4'b0111)
		Tempstate <= 4'b0001;
	end
	
	4'b0001:
	begin
	TempData <= Data[15:8]; //ready Data Byte 1
	TempStart <= 1;
	Tempstate <= 4'b0010; //wfwef
	end	
	
   4'b0010: 
	begin
	TempStart <= 0;	//wait for Byte 1 send
	if (BytePing == 1)
		Tempstate <= 4'b1000;
	end
	
	4'b1000:
	begin
	TempData <= Data[7:0]; //new B2
	TempStart <= 1;
	Tempstate <= 4'b1001;
	end
	
	4'b1001:
	begin
	TempStart <= 0;
	if (BytePing == 1)
		Tempstate <= 4'b0011;
	
	end
	
	4'b0011: 
	begin
	TempData <= 8'h2E; //ready Data Byte 2
	TempStart <= 1;
	Tempstate <= 4'b0100;
	end
	
	4'b0100:
	begin
	TempStart <= 0; //wait for Byte 2 send
	if (BytePing == 1)
		Tempstate <= 4'b0101;
	
	end
	
	4'b0101: 
	begin
	TempData <= 8'h2E; //ready Data Byte 3
	TempStart <= 1;
	Tempstate <= 4'b0110;
	end
	
	4'b0110:
	begin
	TempStart <= 0;	//wait for Byte 3 send
	if (BytePing == 1)
		begin
		TempData <= 8'h00;
		Tempstate <= 4'b0000; //Return to Idle
		SigTemp <= 1;
		end
	end
	
	default: Tempstate <= 4'b0000;
	endcase



end

////////*****TX Cycle Control*****\\\\\\\\


////***********State & Status & Data Holders***********\\\\

reg [1:0]sstate;

reg Starter;

assign Start = IDStart + TempStart + StartStart + PPRStart + SendStart + StopStart;

assign SData = IDData + TempData + StartData + PPRData + SendData + StopData;

////***********LOGIC***********\\\\

//FSM State Transition

always @ (posedge Clk)
begin

	case (sstate)
	2'b00: if (Start) sstate <= 2'b01;   	//Idle
	2'b01: sstate <= 2'b10;						//Send Byte
	2'b10: if (DoneSig) sstate <= 2'b11;	//Sending Stop Bit
	2'b11: if (!DoneSig) sstate <= 2'b00;	//Stop Bit Sent
	default: sstate <= 2'b00;
	endcase

end

//FSM Start Signal Control (per Byte)
always @ (posedge Clk)
begin

	case (sstate)
	2'b00: Starter <= 0;
	2'b01: Starter <= 1;
	2'b10: Starter <= 0;
	2'b11: Starter <= 0;
	default: Starter <= 0;
	endcase

end

//FSM Done Status Control
always @ (Clk)
begin

case (sstate)
	2'b00: BytePinger <= 0;
	2'b01: BytePinger <= 0;
	2'b10: BytePinger <= 0;
	2'b11: if (!DoneSig) BytePinger <= 1;
	default: BytePinger <= 0;
endcase

end

////////*****TX Cycle Control END*****\\\\\\\\

//Instantiations
TxUart Txer0(Clk, SerClock, Starter, SData, TxSig, TxEnabler, DoneSig);
Metronome TxMetr0(Clk, SerClock, SerHalf, Starter);

endmodule
