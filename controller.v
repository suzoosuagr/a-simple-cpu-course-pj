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
parameter	SUB = 4'b0010,
parameter	NOR = 4'b0011,
parameter	MOVR= 4'b0100,
parameter	MOVA= 4'b0101,
parameter	JZRS= 4'b0110,
parameter	JZIM= 4'b0111,
parameter	JCRS= 4'b1000,
parameter	JCIM= 4'b1010,
parameter	SHL = 4'b1011,
parameter	SHR = 4'b1100,
parameter	LDIM= 4'b1101,
parameter	NOP = 4'b0000,
parameter	HALT= 4'b1111;

// state code
always @ （posedge clk) 
begin 

assign	LoadIR  = 1'b0;
assign  IncPC   = 1'b0;
assign  SelPC   = 1'b0;
assign  LoadPC  = 1'b0;
assign  LoadReg = 1'b0;
assign  LoadAcc = 1'b0; 
assign  SelACC  = 2'b00;
assign  SelALU  = 4'b0000;
	
	
case(opcode) 
	ADD: 
	begin 
		assign LoadAcc = 1'b1;
		assign SelACC  = 2'b10；
		assign SelALU  = 4'b1000； 
		assign LoadIR  = 1'b1;
		assign IncPC   = 1'b1;
	end 
	
	SUB: 
	begin 
		assign LoadAcc = 1'b1;
		assign SelACC  = 2'b10；
		assign SelALU  = 4'b1100； 
		assign LoadIR  = 1'b1;
		assign IncPC   = 1'b1;
	end 
	
	NOR: 
	begin 
		assign LoadAcc = 1'b1;
		assign SelACC  = 2'b10；
		assign SelALU  = 4'b0100； 
		assign LoadIR  = 1'b1;
		assign IncPC   = 1'b1;
	end 
	
	SHL: 
	begin 
		assign LoadAcc = 1'b1;
		assign SelACC  = 2'b10；
		assign SelALU  = 4'b0001； 
		assign LoadIR  = 1'b1;
		assign IncPC   = 1'b1;
	end 
	
	SHR: 
	begin 
		assign LoadAcc = 1'b1;
		assign SelACC  = 2'b10；
		assign SelALU  = 4'b0011； 
		assign LoadIR  = 1'b1;
		assign IncPC   = 1'b1;
	end 
	
	LDIM: 
	begin 
		assign LoadAcc = 1'b1;
		assign SelACC  = 2'b00；
		assign SelALU  = 4'b0010； 
		assign LoadIR  = 1'b1;
		assign IncPC   = 1'b1;
	end 
	
	NOP: 
	begin 
		assign LoadIR  = 1'b1;
		assign IncPC   = 1'b1;
	end 
	
	HALT: 
	begin 
	end 
endcase 
	
	
	


end 
endmodule 
	
	
