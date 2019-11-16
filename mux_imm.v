// mux imm 
module mux_imm(d1, imm, sel, dout);
input wire [7:0] d1;
input wire [3:0] imm;
input wire sel;
output wire [7:0] dout;
assign dout = (sel)?d1:{4'b0000, imm};
endmodule

