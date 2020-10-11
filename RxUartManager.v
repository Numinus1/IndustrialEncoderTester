module RxUartManager (Clk, Rx, RBusy, CmdStr, ByteRequest);

//I/O's
input Clk, Rx;
output RBusy;
output [3:0]CmdStr;
output [7:0]ByteRequest;


//Outgoing Busy Status Holders
reg CycleBusy, CheckBusy;
wire RxBusy;
wire Busy;

assign Busy = CycleBusy + CheckBusy + RxBusy;

assign RBusy = Busy;

//Received String Significance Notification
reg [3:0]Cmd;
assign CmdStr = Cmd;


//Incoming connections
wire RxSig;
assign RxSig = Rx;

//Incoming BUffer Counter

reg [3:0]BuffrPoint;
reg [7:0]ByteQuest;
assign ByteRequest = ByteQuest;


////////*****Receive Branch Control*****\\\\\\\\
reg[3:0] RBstate;

always @ (posedge Clk)
begin

	case (RBstate)
	
	4'b0000:// IDLE until a full string is received
	begin
		Cmd <= 4'b0000;
		ByteQuest <= 0;
		
		if (StrRec == 1)
		begin
			RBstate <= 4'b0001;
			CheckBusy <= 1;
		end
		else
		begin
			RBstate <= 4'b0000;
			CheckBusy <= 0;
		end
	end
	
	4'b0001:// Chooses branch based on length of string
	begin
	
		if (BuffrPoint == 1)
			RBstate <= 4'b0010;
		else if (BuffrPoint == 2)
			RBstate <= 4'b0011;
		else if (BuffrPoint == 3)
			RBstate <= 4'b0100;
		else if (BuffrPoint == 4)
			RBstate <= 4'b0101;
		else if (BuffrPoint == 5)
			RBstate <= 4'b0110;
		else if (BuffrPoint == 6)
			RBstate <= 4'b0111;
		else
			RBstate <= 4'b0000;
	
	end
	
	4'b0010: //1 Byte received
	begin
		if (RxBuff0 == 8'h4C)//Test Case
		begin
		Cmd <= 4'b0000;
		
		end
		else
		begin
		Cmd <= 4'b0000;
		end
		RBstate <= 4'b0000;
	
	end
	4'b0011: //2 Bytes received; empty for now
	begin
	
		if ((RxBuff0 == 8'h4C) && (RxBuff1 == 8'hC4))//Test Case
			Cmd <= 4'b0101;
		else if ((RxBuff0 == 8'h47) && (RxBuff1 == 8'h47)) // Start Signal
			Cmd <= 4'b0011;
		else if ((RxBuff0 == 8'h72) && (RxBuff1 == 8'h52)) // Reset Signal
			Cmd <= 4'b1111;
		else
			Cmd <= 4'b0000;
			
		RBstate <= 4'b0000;
		
	end
	4'b0100: //3 Bytes received; empty for now
	begin
		
		if ((RxBuff0 == 8'hAD) && (RxBuff1 == 8'hAD))
		begin
			ByteQuest <= RxBuff2;
			Cmd <= 4'b1000;
		end
		else if ((RxBuff0 == 8'hBD) && (RxBuff1 == 8'hBD))
		begin
			ByteQuest <= RxBuff2;
			Cmd <= 4'b1001;
		end
		if ((RxBuff0 == 8'hDA) && (RxBuff1 == 8'hDA))
		begin
			ByteQuest <= RxBuff2;
			Cmd <= 4'b1010;
		end
		else if ((RxBuff0 == 8'hDB) && (RxBuff1 == 8'hDB))
		begin
			ByteQuest <= RxBuff2;
			Cmd <= 4'b1011;
		end
		RBstate <= 4'b0000;
	
	end
	4'b0101: //4 Bytes received; empty for now
	begin
	
		RBstate <= 4'b0000;
		
	end
	4'b0110: //5 Bytes received; empty for now
	begin
	
		if ((RxBuff0 == 8'h48) && (RxBuff1 == 8'h69) && (RxBuff2 == 8'h20) &&
		(RxBuff3 == 8'h49) && (RxBuff4 == 8'h44))
			Cmd <= 4'b0001; // ID
		else
			Cmd <= 4'b0000;
			
		RBstate <= 4'b0000;
	
	end
	4'b0111: //6 Bytes received
	begin
		if ((RxBuff0 == 8'h67) && (RxBuff1 == 8'h69) && (RxBuff2 == 8'h76) &&
		(RxBuff3 == 8'h65) && (RxBuff4 == 8'h72)) //temp for testing
		begin
			ByteQuest <= RxBuff5;
			Cmd <= 4'b0111;
		end
		else
			Cmd <= 4'b0000;
			
		RBstate <= 4'b0000;
	end
	
	default: RBstate <= 4'b0000;
	
	endcase
	
end

////////*****RX Cycle Control*****\\\\\\\\

////********Incoming Byte Buffer********\\\\
wire [7:0]Data;
wire DoneSig;

reg [7:0]RxBuff0;
reg [7:0]RxBuff1;
reg [7:0]RxBuff2;
reg [7:0]RxBuff3;
reg [7:0]RxBuff4;
reg [7:0]RxBuff5;
reg [7:0]RxBuff6;
reg [7:0]RxBuff7;
reg [7:0]RxBuff8;
reg [7:0]RxBuff9;

reg [7:0]RxrBuff0;
reg [7:0]RxrBuff1;
reg [7:0]RxrBuff2;
reg [7:0]RxrBuff3;
reg [7:0]RxrBuff4;
reg [7:0]RxrBuff5;
reg [7:0]RxrBuff6;
reg [7:0]RxrBuff7;
reg [7:0]RxrBuff8;
reg [7:0]RxrBuff9;


reg [3:0]BuffPoint;

reg StrRec; //high when full string received complete with delimiting char ".."

////***********State & Status Holders***********\\\\

reg [2:0]sstate;

always @ (posedge Clk)
begin

	case (sstate)
	
	3'b000: //IDLE state wait for DoneSig
	begin

	StrRec <= 0;
	
	if (DoneSig)
	begin
		BuffPoint <= 0;
		CycleBusy <= 1;
		sstate <= 3'b001; 
	end
	else
		CycleBusy <= 0;
		
	end

	
	3'b001: //get byte
	begin
	
	if (!DoneSig)
	begin
		
		
		if (Data == 8'hFF)
			sstate <= 3'b101;//fullstop 1
		else
		begin
			sstate <= 3'b010;
			if (BuffPoint == 0)
			begin
				RxBuff0 <= Data;
				BuffPoint <= BuffPoint + 1;
			end
			else if (BuffPoint == 1)
			begin
				RxBuff1 <= Data;
				BuffPoint <= BuffPoint + 1;
			end
			else if (BuffPoint == 2)
			begin
				RxBuff2 <= Data;
				BuffPoint <= BuffPoint + 1;
			end
			else if (BuffPoint == 3)
			begin
				RxBuff3 <= Data;
				BuffPoint <= BuffPoint + 1;
			end
			else if (BuffPoint == 4)
			begin
				RxBuff4 <= Data;
				BuffPoint <= BuffPoint + 1;
			end
			else if (BuffPoint == 5)
			begin
				RxBuff5 <= Data;
				BuffPoint <= BuffPoint + 1;
			end
			else if (BuffPoint == 6)
			begin
				RxBuff6 <= Data;
				BuffPoint <= BuffPoint + 1;
			end
			else if (BuffPoint == 7)
			begin
				RxBuff7 <= Data;
				BuffPoint <= BuffPoint + 1;
			end
			else if (BuffPoint == 8)
			begin
				RxBuff8 <= Data;
				BuffPoint <= BuffPoint + 1;		
			end
			else if (BuffPoint == 9)
			begin
				RxBuff9 <= Data;
				BuffPoint <= BuffPoint + 1;
			end
		end
	end
	
	end
	
	3'b010:
	begin
	if (DoneSig)
		sstate <= 3'b001;
		
	end
	
	3'b101:
	begin
	if (DoneSig)
		sstate <= 3'b110;
	
	end
	
	3'b110:
	begin
		if (!DoneSig)
		begin
			RxrBuff0 <= RxBuff0;
			RxrBuff1 <= RxBuff1;
			RxrBuff2 <= RxBuff2;
			RxrBuff3 <= RxBuff3;
			RxrBuff4 <= RxBuff4;
			RxrBuff5 <= RxBuff5;
			RxrBuff6 <= RxBuff6;
			RxrBuff7 <= RxBuff7;
			RxrBuff8 <= RxBuff8;
			RxrBuff9 <= RxBuff9;
			BuffrPoint <= BuffPoint;
		
			if (Data == 8'hFF) //second fullstop check
			begin
				StrRec <= 1;
				sstate <= 3'b000;
			end
		end
		else
		begin
				StrRec <= 0;
				sstate <= 3'b000;
		end
		
	end
	
	
	default: sstate <= 3'b000;
	
	endcase
	
end


////////*****Instantiations*****\\\\\\\\\
RxUart Rx0(Clk, RxSig, Data, DoneSig, RxBusy);


endmodule
