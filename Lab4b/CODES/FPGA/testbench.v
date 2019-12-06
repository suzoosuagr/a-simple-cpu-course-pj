`timescale 1ns/1ps

module testbench ();

reg CLK;
reg reset;

initial  begin
	CLK = 0;
	reset = 0;
	#12 reset = 1;
end

always begin
	#5 CLK = ~CLK;
end

ARMSOC_TOP top (
    .CLK (CLK),                  // Oscillator - 100MHz
    .RESET (reset),                // Reset 

    .LED (),
    .SW  (8'hDE),
    .UART_RXD (0),
    
    .TDI (),                  // JTAG TDI
    .TCK (),                  // SWD Clk / JTAG TCK
    .TMS (),                  // SWD I/O / JTAG TMS
    .TDO ()                  // SWV     / JTAG TDO
    );
endmodule
