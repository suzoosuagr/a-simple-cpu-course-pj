module test_bench

reg clk;
reg [23:0] memory [255:0];
reg [7:0] address;
reg clk;
reg clb;

wire [7:0] acc;
wire [7:0] pc;
wire [7:0] ir;

assign ir = memory[address][23:16];
assign op = memory[address][23:20];
assign imm = memory[address][19:16];
assign expected = memory[address][15:0];

initial
begin
	$readmemh("test_code.txt", memory);
	clk = 0;
	clb = 0;
	address = 0;
	#250 $stop;
end

always begin
#5 clk = ~clk;

always @(posedge clk) begin
	address <= address + 1;
	if(expected !=={acc,pc} || expected === 16'bx)
		$error("op=%b, imm=%b, expected=%b, received=%b\n",op, imm, expected, {acc, pc});
	else
		$display($time, "op=%b, imm=%b, result=%b\n", op, imm, {acc, pc});
end

test_bench tb(
	.pc(pc);
	.accum_value(acc);
	.clk(clk);
	.CLB(clb);
	.input_ins(ir);
)

endmodule
