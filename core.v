// Core
// Top-level
module core(clk, CLB);
input wire clk, CLB;

wire LoadIR, IncPC, SelPC, LoadPC, LoadReg, LoadAcc, z, c;

wire [1:0] SelAcc;
wire [3:0] imm, reg_addr, op, SelALU;
wire [7:0] ins, pc, rom_ins, reg_value, accum_value, alu_value;

assign imm = reg_addr;


// Define connections
rom ROM(.data(rom_ins), .addr(pc)); // read codes from testcodes.

IR INS_REG(.I(ins), .clk(clk), .CLB(CLB), .LoadIR(LoadIR), .Instruction(rom_ins));

demux DEMUX(.IR_in(ins), .op(op), .out(imm));

program_counter PC(	.address(pc),
					.regIn(reg_value),
					.imm(imm),
					.CLB(CLB),
					.clk(clk),
					.IncPC(IncPC),
					.LoadPC(LoadPC),
					.selPC(SelPC));

reg_file REG(	.reg_out(reg_value), 
			 	.reg_in(accum_value),
			 	.RegAddr(reg_addr),
			 	.clk(clk),
			 	.CLB(CLB),
			 	.LoadReg(LoadReg));

alu ALU(.accum(accum_value),
		.alu_in(reg_value),
		.alu_sel(SelALU),
		.z(z),
		.c(c),
		.result(alu_value));

accum ACCUM(	.clk(clk),
				.CLB(CLB),
				.loadAcc(LoadAcc),
				.imm(imm),
				.reg_in(reg_value),
				.alu_in(alu_value),
				.sel_acc(SelAcc),
				.dout(accum_value));

controller_v1 CONTROL(	.z(z),
						.c(c),
						.clk(clk),
						.CLB(CLB),
						.op(op),
						.LoadIR(LoadIR),
						.IncPC(IncPC),
						.SelPC(SelPC),
						.LoadPC(LoadPC),
						.LoadReg(LoadReg),
						.LoadAcc(LoadAcc),
						.SelAcc(SelAcc),
						.SelALU(SelALU));
endmodule







