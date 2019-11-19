module test_bench();


reg [23:0] memory [255:0];
reg [7:0] address;
reg clk;
reg clb;

wire [7:0] acc;
wire [7:0] pc;
wire [7:0] ir;
wire [7:0] op;
wire [7:0] imm;
wire [15:0] expected;

assign ir = memory[address][23:16];
assign op = memory[address][23:20];
assign imm = memory[address][19:16];
assign expected = memory[address][15:0];

initial
begin
	$readmemh("test_commands.txt", memory);
	clk = 0;
	clb = 0;
	address = 0;
	#10;
	clb = 1;
	#2500 $stop;
end

always begin
#5 clk = ~clk;
end 

always @(posedge clk) begin
	address <= pc; // pipe between pc and address , DO NOT CHANGE.

	// TODO:
	if(expected !=={acc,pc} || expected === 16'bx)
		$error("op=%b, imm=%b, expected=%b, received=%b\n",op, imm, expected, {acc, pc});
	else
		$display($time, "op=%b, imm=%b, result=%b\n", op, imm, {acc, pc});
	
end

core topmodule(
	.pc(pc),
	.accum_value(acc),
	.clk(clk),
	.CLB(clb),
	.input_ins(ir)
);

endmodule
