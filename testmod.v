module PPR_Sim(Clk, Starter, Aout, Zout);

input Clk, Starter;

output Aout, Zout;

wire Start;
sigLatch TestStart0(Clk, Starter, Start);

reg mode = 0;
reg [15:0]Ctr = 0;
reg [4:0]TimeDiv = 0;

reg A = 0;
reg Z = 0;
assign Aout = A;
assign Zout = Z;

always @ (*)
begin

if (mode == 0)
begin
	if (Start == 1)
		mode = 1;
	else
		mode = 0;
end
else
begin
	if (Ctr == 2048)
		mode = 0;
	else
		mode = 1;
end

end

//time division
always @ (posedge Clk)
begin

if (mode == 1)
	TimeDiv <= TimeDiv + 1;
else
	TimeDiv <= 0;

end

//z ctrl
always @ (posedge Clk)
begin

if (Start == 1)
	Z <= 1;
else if (Ctr == 2048)
	Z <= 1;
else
	Z <= 0;
	
end

//a, ctr ctrl
always @ (posedge Clk)
begin

if (mode == 1)
begin
	if (TimeDiv == 5'b11111)
	begin
		A <= ~A;
		if (A == 1)
			Ctr <= Ctr + 1;
	end
	else
		A <= A;
end
else
begin
	A <= 0;
	Ctr <= 0;
end

end

endmodule

