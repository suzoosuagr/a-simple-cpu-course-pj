// Core
// Top-level
module core(clk, CLB);
input wire clk, CLB;

wire LoadIR, IncPC, SelPC, LoadPC, LoadReg, LoadAcc, z, c;

wire [1:0] SelPC;
wire [3:0] imm, reg_addr, op, SelALU;
wire [7:0] ins, pc, rom_ins, reg_value, accum_value;

assign imm = reg_addr


// Define connections
rom ROM(.data(rom_ins), .addr(pc)) // read codes from testcodes.

IR INS_REG(.I(ins), .clk(clk), .CLB(CLB), .LoadIR(LoadIR), .Instruction(rom_ins))

demux DEMUX(.IR_in(ins), .op(op), .out(imm))

program_counter PC(	.address(pc),
					.regIn(reg_value),
					.imm(imm),
					.CLB(CLB),
					.clk(clk),
					.IncPC(IncPC),
					.LoadPC(LoadPC),
					.selPC(SelPC))

reg_file REG(	.reg_out(reg_value), 
			 	.reg_in(accum_value),
			 	.RegAddr(reg_addr),
			 	.clk(clk),
			 	.CLB(CLB),
			 	.LoadReg(LoadReg))



