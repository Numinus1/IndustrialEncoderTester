//Transmitter Module
module TxUart(Clk, SerClock, Start, Data, TxSig, TxEnable, DoneSig);

input Clk, SerClock, Start;
input [7:0]Data;

output TxSig;
output TxEnable;
output DoneSig;

reg Tx;
reg TxEnabler;
wire TxEnabling;
assign TxSig = Tx;
assign TxEnable = TxEnabling;
assign TxEnabling = ~TxEnabler;

reg Done;
assign DoneSig = Done;

reg [3:0]state;

reg Starter;
reg StarterDone;

//Ensure start signal is captured and not re-used



always @ (posedge Clk)
begin
	
	if (state == 4'b0000)
	begin
		if (Start == 1)
		begin
			if (StarterDone == 0)
			begin
				StarterDone <= 1;
				Starter <= 1;
			end
			else
				Starter <= 0;
		end
		else
		Starter <= 0;
	end
	
	else
	begin
		StarterDone <= 0;
		Starter <= 0;
	end
	

end

//FSM State Transition
always @ (posedge Clk)
begin

case (state)

	4'b0000: if (Starter) state <= 4'b0001; 		//Idle
	4'b0001: if (SerClock) state <= 4'b0010;	//Start Bit
	4'b0010: if (SerClock) state <= 4'b0011;	//Bit 1
	4'b0011: if (SerClock) state <= 4'b0100;	//Bit 2
	4'b0100: if (SerClock) state <= 4'b0101;	//Bit 3
	4'b0101: if (SerClock) state <= 4'b0110;	//Bit 4
	4'b0110: if (SerClock) state <= 4'b0111;	//Bit 5
	4'b0111: if (SerClock) state <= 4'b1000;	//Bit 6
	4'b1000: if (SerClock) state <= 4'b1001;	//Bit 7
	4'b1001: if (SerClock) state <= 4'b1010;	//Bit 8
	4'b1010: if (SerClock) state <= 4'b0000;	//Stop Bit
	
	default: state <= 4'b0000;
	
endcase

end


//FSM State Functionality
//Tx Assertions
always @ (posedge Clk)
begin

case (state)
	
	4'b0000: Tx <= 1; //Idle
	4'b0001: Tx <= 0;	//Start Bit //STR 0 0 1 1 0 0 1 0 1
	4'b0010: Tx <= Data[0];	//Bit 1
	4'b0011: Tx <= Data[1];	//Bit 2
	4'b0100: Tx <= Data[2];	//Bit 3
	4'b0101: Tx <= Data[3];	//Bit 4
	4'b0110: Tx <= Data[4];	//Bit 5
	4'b0111: Tx <= Data[5];	//Bit 6
	4'b1000: Tx <= Data[6];	//Bit 7
	4'b1001: Tx <= Data[7];	//Bit 8
	4'b1010: Tx <= 1;	//Stop Bit	
	default: Tx <= 1;
	
endcase
	
end

//Tx Enables
always @ (posedge Clk)
begin

case (state)
	
	4'b0000: TxEnabler <= 1; //Idle
	4'b0001: TxEnabler <= 0;	//Start Bit //STR 0 0 1 1 0 0 1 0 1
	4'b0010: TxEnabler <= 0;//Data[0];	//Bit 1
	4'b0011: TxEnabler <= 0;//Data[1];	//Bit 2
	4'b0100: TxEnabler <= 0;//Data[2];	//Bit 3
	4'b0101: TxEnabler <= 0;//Data[3];	//Bit 4
	4'b0110: TxEnabler <= 0;//Data[4];	//Bit 5
	4'b0111: TxEnabler <= 0;//Data[5];	//Bit 6
	4'b1000: TxEnabler <= 0;//Data[6];	//Bit 7
	4'b1001: TxEnabler <= 0;//Data[7];	//Bit 8
	4'b1010: TxEnabler <= 0;//1;	//Stop Bit	
	default: TxEnabler <= 1;
	
endcase
	
end
//Send Notification
always @ (posedge Clk)
begin

case (state)
	4'b0000: Done <= 0;
	4'b1010: Done <= 1;
	default: Done <= 0;
endcase;

end

endmodule

//Receiver Module
module RxUart(Clk, RxSig, Data, DoneSig, RxBusy);

input Clk;
input RxSig;

output [7:0]Data;
output DoneSig;
output RxBusy;

reg [7:0]DataIn;
reg [7:0]DataRdy;
assign Data[7:0] = DataRdy[7:0];

//Testing

reg Done = 0;
assign DoneSig = Done;

reg Busy;
assign RxBusy = Busy;

wire SerClock, SerHalf;
wire Rx;
assign Rx = RxSig;

reg Starter;

//Metronome Instantiation//

Metronome RxMetr0(Clk, SerClock, SerHalf, Starter);

//FSM
reg [3:0]state;

always @ (posedge Clk)
begin
	case (state)
	
	4'b0000:
	begin
	
	Done <= 0;
	if (Rx == 0)
	begin
		state <= 4'b0001;
		Starter <= 1;
	end
	else
	begin
		state <= 4'b0000;
		Starter <= 0;
	end
		
	end
	
	4'b0001:
	begin
	
	Starter <= 0;
	
	if (SerHalf)
	begin
		if (Rx == 1)
		state <= 4'b0000;
	end
	
	if (SerClock)
		state <= 4'b0010;
	
	end
	
	4'b0010:
	begin
	
	if (SerHalf)
		DataIn[0] <= Rx;
		
	if (SerClock)
		state <= 4'b0011;
	
	end
	
	4'b0011:
	begin
	
	if (SerHalf)
		DataIn[1] <= Rx;
		
	if (SerClock)
		state <= 4'b0100;
	
	end
	
	4'b0100:
	begin
	
	if (SerHalf)
		DataIn[2] <= Rx;
		
	if (SerClock)
		state <= 4'b0101;
	
	end
	
	4'b0101:
	begin
	
	if (SerHalf)
		DataIn[3] <= Rx;
		
	if (SerClock)
		state <= 4'b0110;
	
	end
	
	4'b0110:
	begin
	
	if (SerHalf)
		DataIn[4] <= Rx;
		
	if (SerClock)
		state <= 4'b0111;
	
	end
	
	4'b0111:
	begin
	
	if (SerHalf)
		DataIn[5] <= Rx;
		
	if (SerClock)
		state <= 4'b1000;
	
	end
	
	4'b1000:
	begin
	
	if (SerHalf)
		DataIn[6] <= Rx;
		
	if (SerClock)
		state <= 4'b1001;
	
	end
	
	4'b1001:
	begin
	
	if (SerHalf)
		DataIn[7] <= Rx;
		
	if (SerClock)
		state <= 4'b1010;
	
	end
	
	4'b1010:
	begin
	
	if (SerHalf)
	begin
		if (Rx == 0)
		begin
			state <= 4'b1111;
		end
		else
		begin
			Done <= 1;
			DataRdy <= DataIn;
			state <= 4'b1011;
		end
	end
	
	end
	
	4'b1011:
	begin
	Done <= 0;
	if (SerClock)
	begin
	
	state <= 4'b0000;
	
	end
	
	end
	
	4'b1100: //Currently not used
	begin
	
	Done <= 0;
	state <= 4'b0000;
	
	end
	
	4'b1111: //error state
	begin
	
	state <= 4'b0000; //010
	
	end
	
	default: state <= 4'b0000;
	endcase
end

always @ (posedge Clk)
begin

if (state == 4'b0000)
	Busy <= 0;
else
	Busy <= 1;

end

endmodule

//Metronome to create baud ticks
module Metronome(Clk, SerClock, SerHalf, Reset);

input Clk;
input Reset;
output SerClock, SerHalf;

reg [14:0]ClockDiv;
reg lReset = 0;
reg ResCheck = 0;
wire brate;
wire halfbrate;
reg SerHalfTick;

assign brate = (ClockDiv == 1735); //ClockDiv == 5207 OR 20831
assign halfbrate = (ClockDiv == 867); //ClockDiv == 2603 OR 10415

assign SerClock = brate;
assign SerHalf = halfbrate;

/*always @ (posedge Reset)
begin

lReset = 1;

end*/
always @ (negedge Clk)
begin

if (Reset == 1)
	begin
		if (ResCheck == 0)
		begin
			lReset <= 1;
			ResCheck <= 1;
		end
		else
			lReset <= 0;
	end
else
	begin
	ResCheck <= 0;
	lReset <= 0;
	end

end

always @ (posedge Clk)
begin

if (lReset == 0)
	begin
	if (ClockDiv == 1735)
		ClockDiv <= 0;
	else
		ClockDiv <= ClockDiv + 1;
	end
else
	begin
		ClockDiv <= 0;
	end

end

endmodule
