//Instruction register
module IR (
output wire [7:0] I,

input wire clk,
input wire CLB,
input wire LoadIR,
input wire [7:0] Instruction
);

reg [7:0] I_out;
assign I = I_out;

always @(posedge clk or CLB) begin
	if (CLB == 1'b0) begin
		I_out <= 0;
	end
	else begin
		if (LoadIR == 1'b1) begin
			I_out <= Instruction;
		end
	end

end

endmodule
