module AHB2LED(
	//AHBLITE INTERFACE
		//Slave Select Signals
			input wire HSEL,
		//Global Signal
			input wire HCLK,
			input wire HRESETn,
		//Address, Control & Write Data
			input wire HREADY,
			input wire [31:0] HADDR,
			input wire [1:0] HTRANS,
			input wire HWRITE,
			input wire [2:0] HSIZE,
			
			input wire [31:0] HWDATA,
		// Transfer Response & Read Data
			output wire HREADYOUT,
			output wire [31:0] HRDATA,
		//LED Output
			output wire [7:0] LED
);

//Address Phase Sampling Registers
  reg rHSEL;
  reg [31:0] rHADDR;
  reg [1:0] rHTRANS;
  reg rHWRITE;
  reg [2:0] rHSIZE;

  reg [7:0] rRDATA;
  reg [7:0] rLED;
  reg [7:0] rMASK;
 
//Address Phase Sampling
  always @(posedge HCLK or negedge HRESETn)
  begin
	 if(!HRESETn)
	 begin
		rHSEL	<= 1'b0;
		rHADDR	<= 32'h0;
		rHTRANS	<= 2'b00;
		rHWRITE	<= 1'b0;
		rHSIZE	<= 3'b000;
	 end
    else if(HREADY)
    begin
      	rHSEL	<= HSEL;
		rHADDR	<= HADDR;
		rHTRANS	<= HTRANS;
		rHWRITE	<= HWRITE;
		rHSIZE	<= HSIZE;
    end
  end

 

//Data Phase data transfer
  always @(posedge HCLK or negedge HRESETn)
  begin
    if(!HRESETn) begin
      rLED <= 8'b0000_0000;
      rMASK<= 8'hff;
      rRDATA<= 8'h00;
    end 
    else if(rHSEL & rHWRITE & rHTRANS[1])begin
      if (rHADDR == 32'h5700_0004) begin
      	rMASK <= HWDATA[7:0];
      	rRDATA <= rMASK;
      end
    else begin
    	rRDATA <= rLED;
        rLED <= (HWDATA[7:0] & rMASK) | (rLED & ~rMASK);
    	end
    end
  end
 
//Transfer Response
  assign HREADYOUT = 1'b1; //Single cycle Write & Read. Zero Wait state operations

//Read Data  
  assign HRDATA = {24'h0000_00,rRDATA};

  assign LED = rLED;

endmodule

