module Quadrature (A, B, Clk, Enable, OutTick);

input A, B, Clk, Enable;
output OutTick;

wire Pulse;
wire FClock;

assign Pulse = A ^ B;

assign OutTick = ((!Enable)&(Clk)) | ((Enable)&(Pulse));

endmodule
