module memManager (MemCmd, MemSlave, MemDataP, MemDataN, MemData);

input [3:0]MemCmd;
input [31:0]MemDataP;
input [31:0]MemDataN;

output [1:0]MemSlave;
output [31:0]MemData;

wire [31:0]DataPath;
wire [1:0]MemSlaver;

assign DataPath = MemCmd[1] ? MemDataN : MemDataP;

assign MemSlaver[1] = MemCmd[3];
assign MemSlaver[0] = MemCmd[0];

assign MemSlave = MemSlaver;

assign MemData = DataPath;

endmodule

