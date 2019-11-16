module controller(z, c, clk, CLB, op, 
	LoadIR, IncPC, SelPC, LoadPC, 
	LoadReg, LoadAcc, SelACC, SelALU);
// input define
input wire z, c, clk, CLB;
input wire [3:0] op;

// output define
output reg LoadIR, IncPC, SelPC, LoadPC, LoadReg, LoadAcc;
output reg [1:0] SelACC;
output reg [3:0] SelALU;

// State code
reg [3:0] state;
reg [3:0] nest_satte;

// op code
parameter 	ADD = 4'b0001,
			SUB = 4'b0010,
			NOR = 4'b0011,
			MOVR= 4'b0100,
			MOVA= 4'b0101,
			JZRS= 4'b0110,
			JZIM= 4'b0111,
			JCRS= 4'b1000,
			JCIM= 4'b1010,
			SHL = 4'b1011,
			SHR = 4'b1100,
			LDIM= 4'b1101,
			NOR = 4'b0000,
			HALT= 4'b1111;

// state code
parameter 