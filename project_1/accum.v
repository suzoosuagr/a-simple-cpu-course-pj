// accumulator
module accum(clk, CLB, loadAcc, imm, reg_in, alu_in, sel_acc, dout);
input wire clk, CLB, loadAcc;
input wire [1:0] sel_acc;
input wire [7:0] reg_in, alu_in;
input wire [3:0] imm;
output wire [7:0] dout;

reg [7:0] Data;

assign dout = Data;

always @(posedge clk or CLB) begin
	if (!CLB) begin
		// clb
		Data<=8'b0;
	end
	else begin
		if (loadAcc)
			begin
			case(sel_acc)
			2'b00: Data <= alu_in;
			2'b01: Data <= alu_in;
			2'b10: Data <= reg_in;
			2'b11: Data <= {4'b0000, imm};
			default: Data <= Data;
			endcase
		// din <= sel_acc[0]?{4'b0000, imm}:reg_in;
		// din <= sel_acc[1]?din:alu_in;
		// dout<= loadAcc?din:dout;
			end
		end
	

end
endmodule


