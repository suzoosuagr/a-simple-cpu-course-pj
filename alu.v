// ALU
module alu(accum, alu_in, alu_sel, z, c, result);
// accum is the input from accum
// alu_in from the reg data
// alu_sel opcode
input wire [7:0] alu_in, accum;
input wire [3:0] alu_sel;
output wire z, c;
output wire [7:0] result;

// claim the connections
reg[8:0] Result;
assign result = Result[7:0];
assign cout = Result[8];
assign zout = (result == 8'b0);

parameter 	ADD = 4'b0001,
			SUB = 4'b0010,
			NOR = 4'b0011,
			MOVR= 4'b0100,
			SHL = 4'b1011,
			SHR = 4'b1100;

always @(accum or alu_in or alu_sel) begin
	case(alu_sel):
	ADD: Result <= accum + alu_in;
	SUB: Result <= accum - alu_in;
	NOR: Reulst <= ~(a|b);
	MOVR:Result <= alu_in;
	SHL: Result <= accum << 1;
	SHR: Result <= accum >> 1;
	default: Result <= 9'bzzzzzzzzz;
end
endmodule



