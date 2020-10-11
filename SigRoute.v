module SigRouter (Clk, AIn, BIn, ZIn, Starter, 
MemSlave, RetAddr, memCLR, PPR, Done, q, ZCounter);

//I/O's
input Clk;
input AIn, BIn, ZIn;
input Starter;
input [1:0]MemSlave;
input [13:0]RetAddr;
input memCLR;

output [15:0]PPR;
output Done;
output [31:0]q;
output [31:0]ZCounter;

////****latches****\\\\
//Encoder Signals
wire A, B, Z;

EncSigLatch EncSig0(Clk, AIn, BIn, ZIn, A, B, Z);

//Starter
wire Start;
sigLatch Start0(Clk, Starter, Start);

////****Trigger Logic****\\\\
reg [1:0] ZCtr;
reg DoneSig;

assign Done = DoneSig;



always @ (posedge Clk)
begin

	case (ZCtr)
	2'b00:
	begin
		if (Start)
			ZCtr <= 2'b01;
		else
			ZCtr <= 2'b00;
	end
	
	2'b01:
	begin
	
	if (Z)
		ZCtr <= 2'b10;
	else
		ZCtr <= 2'b01;
	
	end
	
	2'b10:
	begin
	
	if (Z)
		ZCtr <= 2'b11;
	else
		ZCtr <= 2'b10;
	
	end
	
	2'b11:
	begin
	
	ZCtr <= 2'b00;
	
	end
	
	default: ZCtr <= 2'b00;
	endcase


end

always @ (posedge Clk)
begin

	case (ZCtr)
	
	2'b00:
	DoneSig <= 1'b0;
	2'b01:
	DoneSig <= 1'b0;
	2'b10: 
	DoneSig <= 1'b0;
	2'b11:
	DoneSig <= 1'b1;
	
	default: DoneSig <= 0;
	endcase
	
end
////****PPR Counter****\\\\\
reg [15:0] PPRCtr;
reg [15:0] PPROut;

assign PPR = PPROut;

always @ (posedge Clk)
begin

	case (ZCtr)
	
	2'b00:
	begin
	
		PPRCtr <= 0;
		PPROut <= PPROut;
		
	end
	
	2'b01:
	begin
		
		PPRCtr <= 0;
		PPROut <= PPROut;
	
	end
	
	2'b10:
	begin
	
		if (A)
			PPRCtr <= PPRCtr + 1;
		else
			PPRCtr <= PPRCtr;
		
		
	end
	
	2'b11:
	begin
		PPROut <= PPRCtr;
		PPRCtr <= PPRCtr;
	end
	
	default: PPRCtr <= 0;
	endcase
end


////****Timer****\\\\
reg [31:0]Timer;
reg [31:0] ZCount = 0;
assign ZCounter = ZCount;

always @ (posedge Clk)
begin
	
	if (memCLR == 1)
		ZCount <= 0;
	else
	begin
		if ((ZCtr == 2'b10) && (Z))
			ZCount <= Timer;
		else
			ZCount <= ZCount;
	end
	
end

always @ (posedge Clk)
begin

	case(ZCtr)
	
	2'b00:
	Timer <= 0;
	
	2'b01:
	Timer <= 0;
	
	2'b10:
	Timer <= Timer + 1;
	
	2'b11:
	Timer <= Timer;
	
	
	default: Timer <= 0;
	endcase


end

////Cycle end detector



////****A and B Enables****\\\\
reg AEn;
reg BEn;

//A
always @ (posedge Clk)
begin

if (ZCtr == 2'b10)
	AEn <= A;
else
	AEn <= 0;

end

//B
always @ (posedge Clk)
begin

if (ZCtr == 2'b10)
	BEn <= B;
else
	BEn <= 0;

end

////****Address Control Logic****\\\\
reg [13:0]AddA;
reg [13:0]AddB;
reg AddHolderA;
reg AddHolderB;

//Address A
always @ (posedge Clk)
begin

if (MemSlave == 2'b10)
begin

	AddA <= RetAddr;

end
else
begin
	if (ZCtr == 2'b00)
	begin
		AddA <= 0;
		AddHolderA <= 0;
	end
	else if (ZCtr == 2'b01)
	begin
		AddA <= 0;
		AddHolderA <= 0;
	end
	else if (ZCtr == 2'b10)
	begin
		if (AddHolderA == 0)
		begin
			if (A)
				AddHolderA <= 1;
			else
				AddHolderA <= 0;
		end
		else
		begin
		if (A)
			AddA <= AddA + 1;
		else
			AddA <= AddA;
		end	
	end
	else
		AddA <= AddA;
end

end

//Address B
always @ (posedge Clk)
begin

if (MemSlave == 2'b11)
begin

	AddB <= RetAddr;

end
else
begin
	if (ZCtr == 2'b00)
	begin
		AddB <= 0;
		AddHolderB <= 0;
		
	end
	else if (ZCtr == 2'b01)
	begin
		AddB <= 0;
		AddHolderB <= 0;
	end
	else if (ZCtr == 2'b10)
	begin
		if (AddHolderB == 0)
		begin
		if (B)
			AddHolderB <= 1;
		else
			AddHolderB <= 0;
		end
		else
		begin
		if (B)
			AddB <= AddB + 1;
		else
			AddB <= AddB;	
		end
	end
	else
		AddB <= AddB;
end

end

//output Q trackswitch
reg [31:0]qOut;
wire [31:0]qA;
wire [31:0]qB;

assign q = qOut;

always @ (posedge Clk)
begin

if (MemSlave == 2'b10)
	qOut <= qA;
else if (MemSlave <= 2'b11)
	qOut <= qB;
else
	qOut <= 0;

end

////Memory Module Instantiation
DataCollector DataC0(memCLR, Clk, AddA, AddB, AEn, BEn, Timer, qA, qB);

endmodule 



module EncSigLatch(Clk, AIn, BIn, ZIn, AOut, BOut, ZOut);

//I/O's
input Clk, AIn, BIn, ZIn;
output AOut, BOut, ZOut;

wire A, B, Z;

//sigLatch instantiations
sigLatch A0(Clk, AIn, A);
sigLatch B0(Clk, BIn, B);
sigLatch	Z0(Clk, ZIn, Z);

assign AOut = A;
assign BOut = B;
assign ZOut = Z;

endmodule

//Creates a spike when StartIn goes high, and then outputs low 
//until StartIn goes low, at which point resets
module sigLatch(Clk, StartIn, StartOut);

input Clk;
input StartIn;

output StartOut;

reg StartCheck = 0;
reg StartOuter = 0;

assign StartOut = StartOuter;

always @ (posedge Clk)
begin

if (StartIn)
begin
	if (StartCheck == 0)
	begin
		StartOuter <= 1;
		StartCheck <= 1;
	end
	else
	begin
		StartOuter <= 0;
		StartCheck <= 1;
	end
end

else
begin
	StartOuter <= 0;
	StartCheck <= 0;
end

end
endmodule
