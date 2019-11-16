// accumulator
module accum(clk, CLB, loadAcc, din, dout);
input wire clk, CLB, loadAcc;
input wire [7:0] din;
output reg [7:0] dout;

always @(posedge clk or posedge CLB) begin
	if (!CLB) begin
		// clb
		dout<=8'b0;
	end
	else begin
		if (loadAcc) dout <= din;
		else dout <= dout;
	end
end
endmodule


