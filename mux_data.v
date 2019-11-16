// data multiplexer 2
module mux_data(d1, d2, sel, dout);
input wire [7:0] d1, d2;
input wire sel;
output wire [7:0] dout;
assign dout = (sel)?d1:d2;
endmodule
