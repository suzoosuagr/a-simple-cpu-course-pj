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
reg [2:0] state;
reg [2:0] next_state;

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
parameter 	Sinit = 3'b111; // initial
			S0    = 3'b000; // read opcodes
			S1    = 3'b001;	// pc+1
			S2    = 3'b010; // update pc
			S3    = 3'b011;	// update 
			S4    = 3'b100;	// update reg
			S5    = 3'b101;	// halt

// state reg
always @(posedge clk or negedge CLB) begin
	if (!CLB) state <= Sinit;
	else state <= next_state;
end

// state logic
always @* begin
	case(state)
	S0: next_state = S1;
	S1: begin
		case(op)
		ADD: next_state = S3;
		SUB: next_state = S3;
		NOR: next_state = S3;
		MOVR:next_state = S3;
		MOVA:next_state = S4;
		JZRS:next_state = S2;
		JZIM:next_state = S2;
		JCRS:next_state = S2;
		JCIM:next_state = S2;
		SHL: next_state = S3;
		SHR: next_state = S3;
		LDIM:next_state = S3;
		NOP: next_state = S0;
		HALT:next_state = S5;
		default:next_state = Sinit; // non exist opcode, initial whole system
		endcase
		end
	S2: next_state = S0;
	S3: next_state = S0;
	S4: next_state = S0;
	S5: next_state = S5;
	Sinit: next_state = S0;
	default: next_state = Sinit; // when state run over, initial whole process. 
	endcase
end 
 
// output logic

