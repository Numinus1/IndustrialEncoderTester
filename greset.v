module greset (rcmd, rset, Clk);

input rcmd;
input Clk;

output rset;

reg [31:0]rcounter;

reg [1:0]rcont;
reg reset;

assign rset = reset;

always @ (posedge Clk)
begin

case (rcont)

2'b00:
begin
reset <= 0;
rcounter <= 0;

if (rcmd)
	rcont <= 2'b01;
else
	rcont <= 2'b00;
	
end

2'b01:
begin
reset <= 1;
rcounter <= rcounter + 1;

if (rcounter == 200000000)
	rcont <= 2'b10;
else
	rcont <= 2'b01;

end

2'b10:
begin
reset <= 0;
rcounter <= 0;
rcont <= 2'b00;


end

default: rcont <= 2'b00;
endcase


end

endmodule 