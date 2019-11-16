// ROM save the instructions
module rom(data, addr, read, ena);
input wire read, ena;
input wire [7:0] addr;
output wire [7:0] data;

reg [7:0] memory[255:0];

initial begin
	memory[0] = 8'b1101_0100; //ld acc imm 0100
	memory[1] = 8'b0101_0001; // mov reg01 acc 
	momory[2] = 8'b1101_1010; // LD acc 1010
	momory[3] = 8'b0101_0010; // mov reg02 acc
	// todo
end

assign data = (read&&ena)?memory[addr]:8'hzz;
endmodule