// split the output of IR to imm and op
module demux(IR_in, op, out);
input wire [7:0] IR_in;
output wire [3:0] out;
output wire [3:0] op;

assign op = IR_in[7:4];
assign out = IR_in[3:0];

endmodule