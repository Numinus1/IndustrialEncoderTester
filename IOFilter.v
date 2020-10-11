module inSieve (D, Q, Clk);

input D;
input Clk;

output Q;

reg q1, q2, q3, q4, q5, q6, q7, q8;

assign Q = q8;

always @ (posedge Clk)
begin
q1 <= D;
q2 <= q1;
q3 <= q2;
q4 <= q3;
q5 <= q4;
q6 <= q5;
q7 <= q6;
q8 <= q7;
end


endmodule

module Ranger(D, Qp, Qn, Clk, SpikeFlag);

input D;
input Clk;

output Qn, Qp;
output SpikeFlag;

reg [3:0]range;

reg Qout;
reg Spike = 0;
assign SpikeFlag = Spike;

assign Qp = Qout;
assign Qn = ~Qout;

always @ (posedge Clk)
begin

	case(range)
	
	3'b000:
	begin
	if (D != Qout)
		range <= 3'b001;
	else
		range <= 3'b000;
		
	Spike <= 0;
	end
	
	3'b001:
	begin
	if (D != Qout)
		range <= 3'b010;
	else
		range <= 3'b111;
		
	Spike <= 0;
	end
	
	3'b010:
	begin
	if (D != Qout)
		range <= 3'b011;
	else
		range <= 3'b111;
	
	Spike <= 0;
	end
	
	3'b011:
	begin
	if (D != Qout)
		range <= 3'b100;
	else
		range <= 3'b111;
		
	Spike <= 0;
	end
	
	3'b100:
	begin
	if (D != Qout)
	begin
		Qout <= D;
		range <= 3'b000;
	end
	else
		range <= 3'b111;
	
	Spike <= 0;
	end
	
	3'b111:
	begin
	//flag occurence of spike
	range <= 3'b000;
	Spike <= 1;
	end
	
	default: range <= 3'b000;
	endcase

end
endmodule
