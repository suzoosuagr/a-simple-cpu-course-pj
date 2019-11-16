// accumulator
module accum(clk, CLB, loadAcc, imm, reg_in, alu_in, sel_acc, dout);
input wire clk, CLB, loadAcc;
input wire [1:0] sel_acc;
input wire [7:0] reg_in, alu_in;
input wire [3:0] imm;
output reg [7:0] dout;

reg [7:0] din;

always @(posedge clk or posedge CLB) begin
	if (!CLB) begin
		// clb
		dout<=8'b0;
	end
	else begin
		din <= sel_acc[0]?{4'b0000, imm}:reg_in;
		din <= sel_acc[1]?din:alu_in;
		dout<= loadAcc?din:dout;
	end
end
endmodule


