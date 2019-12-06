//////////////////////////////////////////////////////////////////////////////////
//END USER LICENCE AGREEMENT                                                    //
//                                                                              //
//Copyright (c) 2012, ARM All rights reserved.                                  //
//                                                                              //
//THIS END USER LICENCE AGREEMENT ("LICENCE") IS A LEGAL AGREEMENT BETWEEN      //
//YOU AND ARM LIMITED ("ARM") FOR THE USE OF THE SOFTWARE EXAMPLE ACCOMPANYING  //
//THIS LICENCE. ARM IS ONLY WILLING TO LICENSE THE SOFTWARE EXAMPLE TO YOU ON   //
//CONDITION THAT YOU ACCEPT ALL OF THE TERMS IN THIS LICENCE. BY INSTALLING OR  //
//OTHERWISE USING OR COPYING THE SOFTWARE EXAMPLE YOU INDICATE THAT YOU AGREE   //
//TO BE BOUND BY ALL OF THE TERMS OF THIS LICENCE. IF YOU DO NOT AGREE TO THE   //
//TERMS OF THIS LICENCE, ARM IS UNWILLING TO LICENSE THE SOFTWARE EXAMPLE TO    //
//YOU AND YOU MAY NOT INSTALL, USE OR COPY THE SOFTWARE EXAMPLE.                //
//                                                                              //
//ARM hereby grants to you, subject to the terms and conditions of this Licence,//
//a non-exclusive, worldwide, non-transferable, copyright licence only to       //
//redistribute and use in source and binary forms, with or without modification,//
//for academic purposes provided the following conditions are met:              //
//a) Redistributions of source code must retain the above copyright notice, this//
//list of conditions and the following disclaimer.                              //
//b) Redistributions in binary form must reproduce the above copyright notice,  //
//this list of conditions and the following disclaimer in the documentation     //
//and/or other materials provided with the distribution.                        //
//                                                                              //
//THIS SOFTWARE EXAMPLE IS PROVIDED BY THE COPYRIGHT HOLDER "AS IS" AND ARM     //
//EXPRESSLY DISCLAIMS ANY AND ALL WARRANTIES, EXPRESS OR IMPLIED, INCLUDING     //
//WITHOUT LIMITATION WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR //
//PURPOSE, WITH RESPECT TO THIS SOFTWARE EXAMPLE. IN NO EVENT SHALL ARM BE LIABLE/
//FOR ANY DIRECT, INDIRECT, INCIDENTAL, PUNITIVE, OR CONSEQUENTIAL DAMAGES OF ANY/
//KIND WHATSOEVER WITH RESPECT TO THE SOFTWARE EXAMPLE. ARM SHALL NOT BE LIABLE //
//FOR ANY CLAIMS, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, //
//TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE    //
//EXAMPLE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE EXAMPLE. FOR THE AVOIDANCE/
// OF DOUBT, NO PATENT LICENSES ARE BEING LICENSED UNDER THIS LICENSE AGREEMENT.//
//////////////////////////////////////////////////////////////////////////////////

module ARMSOC_TOP (
    input  wire          CLK,                  // Oscillator - 100MHz
    input  wire          RESET,                // Reset

    // TO BOARD LEDs
    output wire    [7:0] LED,
    
	// VGA IO
    output wire    [2:0] VGA_RED,
    output wire    [2:0] VGA_GREEN,
    output wire    [1:0] VGA_BLUE,
    output wire          VGA_HSYNC,            // VGA Horizontal Sync
    output wire          VGA_VSYNC,            // VGA Vertical Sync
    
    // TO UART
    input  wire          UART_RXD,
    output wire          UART_TXD,
    
	// Switch Inputs
    input  wire    [7:0] SW,
    
    // 7 Segment display
    output wire    [6:0] SEG,
    output wire          DP,
    output wire    [3:0] AN,
    
    // Debug
    input  wire          TDI,                  // JTAG TDI
    input  wire          TCK,                  // SWD Clk / JTAG TCK
    inout  wire          TMS,                  // SWD I/O / JTAG TMS
    output wire          TDO                   // SWV     / JTAG TDO
    );

	// Clock
	wire          fclk;                 // Free running clock
    // Reset
    wire          reset_n = RESET;
	
    // Select signals
    wire    [3:0] mux_sel;

    wire          hsel_mem;
    wire          hsel_vga;
    wire          hsel_uart;
    wire          hsel_gpio;
    wire          hsel_timer;
    wire          hsel_7seg;
  
    // Slave read data
    wire   [31:0] hrdata_mem;
    wire   [31:0] hrdata_vga;
    wire   [31:0] hrdata_uart;
    wire   [31:0] hrdata_gpio;
    wire   [31:0] hrdata_timer;
    wire   [31:0] hrdata_7seg;

    // Slave hready
    wire          hready_mem;
    wire          hready_vga;
    wire          hready_uart;
    wire          hready_gpio;
    wire          hready_timer;
    wire          hready_7seg;

    // CM-DS Sideband signals
    wire          lockup;
    wire          txev;
    wire          sleeping;
    wire  [239:0] irq;

    // Interrupt signals
    wire          uart_irq;
    wire          timer_irq;
    assign        irq[239:2] = 238'b0;

    assign irq[0] = timer_irq;
    assign irq[1] = uart_irq;
//    assign        LED[7] = lockup; 
    
	// Clock divider, divide the frequency by two, hence less time constraint 
    reg clk_div;
    always @(posedge CLK)
    begin
        clk_div=~clk_div;
    end
    BUFG BUFG_CLK (
        .O(fclk),
        .I(clk_div)
    );

    // System level reset
	wire   sys_reset_req;              // System reset request from CPU or debug host
    reg    reg_sys_rst_n;
    always @(posedge fclk or negedge reset_n)
    begin
        if (!reset_n)
            reg_sys_rst_n <= 1'b0;
        else
        if ( sys_reset_req | lockup )
            reg_sys_rst_n <= 1'b0;
        else
        reg_sys_rst_n <= 1'b1;
    end

    // CPU I-Code
    wire   [31:0] haddri;
    wire    [1:0] htransi;
    wire    [2:0] hsizei;
    wire    [2:0] hbursti;
    wire    [3:0] hproti;
    wire    [1:0] memattri;
    wire   [31:0] hrdatai;
    wire          hreadyi;
    wire    [1:0] hrespi = 2'b00;      // System generates no error response;;

    // CPU D-Code
    wire   [31:0] haddrd;
    wire    [1:0] htransd;
    wire    [1:0] hmasterd;
    wire    [2:0] hsized;
    wire    [2:0] hburstd;
    wire    [3:0] hprotd;
    wire    [1:0] memattrd;
    wire   [31:0] hwdatad;
    wire          hwrited;
    wire          exreqd;
    wire   [31:0] hrdatad;
    wire          hreadyd;
    wire    [1:0] hrespd = 2'b00;      // System generates no error response;
    wire          exrespd = 1'b0;

    // Code Bus Mux
    wire   [31:0] haddrc     = htransd[1] ? haddrd  : haddri;
    wire    [2:0] hburstc    = htransd[1] ? hburstd : hbursti;
    wire          hmastlockc = 1'b0;
    wire    [3:0] hprotc     = htransd[1] ? hprotd  : hproti;
    wire    [2:0] hsizec     = htransd[1] ? hsized  : hsizei;
    wire    [1:0] htransc    = htransd[1] ? htransd : htransi;
    wire   [31:0] hwdatac    = hwdatad;
    wire          hwritec    = htransd[1] ? hwrited : 1'b0;
    wire   [31:0] hrdatac; 
    wire          hreadyc; 
    assign        hreadyi    = hreadyc;
    assign        hreadyd    = hreadyc;
    assign        hrdatai    = hrdatac;
    assign        hrdatad    = hrdatac;

    // CPU System Bus
    wire   [31:0] haddrs; 
    wire    [2:0] hbursts; 
    wire          hmastlocks; 
    wire    [3:0] hprots; 
    wire    [2:0] hsizes; 
    wire    [1:0] htranss; 
    wire   [31:0] hwdatas; 
    wire          hwrites; 
    wire   [31:0] hrdatas; 
    wire          hreadys; 
    wire    [1:0] hresps = 2'b00;      // System generates no error response
    wire          exresps = 1'b0;

    // Debug signals (TDO pin is used for SWV unless JTAG mode is active)
    wire          dbg_tdo;                    // SWV / JTAG TDO
    wire          dbg_tdo_nen;                // SWV / JTAG TDO tristate enable (active low)
    wire          dbg_swdo;                   // SWD I/O 3-state output
    wire          dbg_swdo_en;                // SWD I/O 3-state enable
    wire          dbg_jtag_nsw;               // SWD in JTAG state (HIGH)
    wire          dbg_swo;                    // Serial wire viewer/output
    wire          tdo_enable     = !dbg_tdo_nen | !dbg_jtag_nsw;
    wire          tdo_tms        = dbg_jtag_nsw         ? dbg_tdo    : dbg_swo;
    assign        TMS            = dbg_swdo_en          ? dbg_swdo   : 1'bz;
    assign        TDO            = tdo_enable           ? tdo_tms    : 1'bz;

    // CoreSight requires a loopback from REQ to ACK for a minimal
    // debug power control implementation
    wire          cpu0cdbgpwrupreq;          // Debug Power Domain up request
    wire          cpu0cdbgpwrupack;          // Debug Power Domain up acknowledge
    assign        cpu0cdbgpwrupack = cpu0cdbgpwrupreq;

    // DesignStart simplified integration level
    CORTEXM3INTEGRATIONDS u_CORTEXM3INTEGRATION (
       // Inputs
       .ISOLATEn       (1'b1),               // Active low to isolate core power domain
       .RETAINn        (1'b1),               // Active low to retain core state during power-down

       // Resets
       .PORESETn       (reset_n),            // Power on reset - reset processor and debugSynchronous to FCLK and HCLK
       .SYSRESETn      (reg_sys_rst_n),      // System reset   - reset processor onlySynchronous to FCLK and HCLK
       .RSTBYPASS      (1'b0),               // Reset bypass - active high to disable internal generated reset for testing (e.gATPG)
       .CGBYPASS       (1'b0),               // Clock gating bypass - active high to disable internal clock gating for testing
       .SE             (1'b0),               // DFT is tied off in this example

       // Clocks
       .FCLK           (fclk),               // Free running clock - NVIC, SysTick, debug
       .HCLK           (fclk),               // System clock - AHB, processor
                                             // it is separated so that it can be gated off when no debugger is attached
       .TRACECLKIN     (fclk),               // Trace clock input.  REVISIT, does it want its own named signal as an input?
       // SysTick
       .STCLK          (1'b1),               // External reference clock for SysTick (Not really a clock, it is sampled by DFF)
                                             // Must be synchronous to FCLK or tied when no alternative clock source
       .STCALIB        ({1'b1,               // No alternative clock source
                         1'b0,               // Exact multiple of 10ms from FCLK
                         24'h007A11F}),      // Calibration value for SysTick for 50 MHz source

       .AUXFAULT       ({32{1'b0}}),         // Auxiliary Fault Status Register inputs: Connect to fault status generating logic
                                             // if required. Result appears in the Auxiliary Fault Status Register at address
                                             // 0xE000ED3C. A one-cycle pulse of information results in the information being stored
                                             // in the corresponding bit until a write-clear occurs.

       // Configuration - system
       .BIGEND         (1'b0),               // Select when exiting system reset - Peripherals in this system do not support BIGEND
       .DNOTITRANS     (1'b1),               // I-CODE & D-CODE merging configuration.
                                             // This disable I-CODE from generating a transfer when D-CODE bus need a transfer
                                             // Must be HIGH when using the Designstart system

       //SWJDAP signal for single processor mode
       .nTRST          (1'b1),               // JTAG TAP Reset
       .SWCLKTCK       (TCK),                // SW/JTAG Clock
       .SWDITMS        (TMS),                // SW Debug Data In / JTAG Test Mode Select
       .TDI            (TDI),                // JTAG TAP Data In / Alternative input function
       .CDBGPWRUPACK   (cpu0cdbgpwrupack),   // Debug Power Domain up acknowledge.

       // IRQs
       .INTISR         (irq[239:0]),         // Interrupts
       .INTNMI         (1'b0),               // Non-maskable Interrupt

       // I-CODE Bus
       .HREADYI        (hreadyi),            // I-CODE bus ready
       .HRDATAI        (hrdatai),            // I-CODE bus read data
       .HRESPI         (hrespi),             // I-CODE bus response
       .IFLUSH         (1'b0),               // Prefetch flush - fixed when using the Designstart system

       // D-CODE Bus
       .HREADYD        (hreadyd),            // D-CODE bus ready
       .HRDATAD        (hrdatad),            // D-CODE bus read data
       .HRESPD         (hrespd),             // D-CODE bus response
       .EXRESPD        (exrespd),            // D-CODE bus exclusive response

       // System Bus
       .HREADYS        (hreadys),            // System bus ready
       .HRDATAS        (hrdatas),            // System bus read data
       .HRESPS         (hresps),             // System bus response
       .EXRESPS        (exresps),            // System bus exclusive response

       // Sleep
       .RXEV           (1'b0),               // Receive Event input
       .SLEEPHOLDREQn  (1'b1),               // Extend Sleep request

       // External Debug Request
       .EDBGRQ         (1'b0),               // External Debug request to CPU
       .DBGRESTART     (1'b0),               // Debug Restart request - Not needed in a single CPU system

       // DAP HMASTER override
       .FIXMASTERTYPE  (1'b0),               // Tie High to override HMASTER for AHB-AP accesses

       // WIC
       .WICENREQ       (1'b0),               // Active HIGH request for deep sleep to be WIC-based deep sleep
                                             // This should be driven from a PMU

       // Timestamp interface
       .TSVALUEB       ({48{1'b0}}),         // Binary coded timestamp value for trace - Trace is not used in this course
       // Timestamp clock ratio change is rarely used

       // Configuration - debug
       .DBGEN          (1'b1),               // Halting Debug Enable
       .NIDEN          (1'b1),               // Non-invasive debug enable for ETM
       .MPUDISABLE     (1'b0),               // Tie high to emulate processor with no MPU

       // Outputs

       //SWJDAP signal for single processor mode
       .TDO            (dbg_tdo),            // JTAG TAP Data Out // REVISIT needs mux for SWV
       .nTDOEN         (dbg_tdo_nen),        // TDO enable
       .CDBGPWRUPREQ   (cpu0cdbgpwrupreq),   // Debug Power Domain up request
       .SWDO           (dbg_swdo),           // SW Data Out
       .SWDOEN         (dbg_swdo_en),        // SW Data Out Enable
       .JTAGNSW        (dbg_jtag_nsw),       // JTAG/not Serial Wire Mode

       // Single Wire Viewer
       .SWV            (dbg_swo),            // SingleWire Viewer Data

       //TPIU signals for single processor mode
       .TRACECLK       (),                   // TRACECLK output
       .TRACEDATA      (),                   // Trace Data

       // CoreSight AHB Trace Macrocell (HTM) bus capture interface
       // Connected here for visibility but usually not used in SoC.
       .HTMDHADDR      (),                   // HTM data HADDR
       .HTMDHTRANS     (),                   // HTM data HTRANS
       .HTMDHSIZE      (),                   // HTM data HSIZE
       .HTMDHBURST     (),                   // HTM data HBURST
       .HTMDHPROT      (),                   // HTM data HPROT
       .HTMDHWDATA     (),                   // HTM data HWDATA
       .HTMDHWRITE     (),                   // HTM data HWRITE
       .HTMDHRDATA     (),                   // HTM data HRDATA
       .HTMDHREADY     (),                   // HTM data HREADY
       .HTMDHRESP      (),                   // HTM data HRESP

       // AHB I-Code bus
       .HADDRI         (haddri),             // I-CODE bus address
       .HTRANSI        (htransi),            // I-CODE bus transfer type
       .HSIZEI         (hsizei),             // I-CODE bus transfer size
       .HBURSTI        (hbursti),            // I-CODE bus burst length
       .HPROTI         (hproti),             // i-code bus protection
       .MEMATTRI       (memattri),           // I-CODE bus memory attributes

       // AHB D-Code bus
       .HADDRD         (haddrd),             // D-CODE bus address
       .HTRANSD        (htransd),            // D-CODE bus transfer type
       .HSIZED         (hsized),             // D-CODE bus transfer size
       .HWRITED        (hwrited),            // D-CODE bus write not read
       .HBURSTD        (hburstd),            // D-CODE bus burst length
       .HPROTD         (hprotd),             // D-CODE bus protection
       .MEMATTRD       (memattrd),           // D-CODE bus memory attributes
       .HMASTERD       (hmasterd),           // D-CODE bus master
       .HWDATAD        (hwdatad),            // D-CODE bus write data
       .EXREQD         (exreqd),             // D-CODE bus exclusive request

       // AHB System bus
       .HADDRS         (haddrs),             // System bus address
       .HTRANSS        (htranss),            // System bus transfer type
       .HSIZES         (hsizes),             // System bus transfer size
       .HWRITES        (hwrites),            // System bus write not read
       .HBURSTS        (hbursts),            // System bus burst length
       .HPROTS         (hprots),             // System bus protection
       .HMASTLOCKS     (hmastlocks),         // System bus lock
       .MEMATTRS       (),                   // System bus memory attributes
       .HMASTERS       (),                   // System bus master
       .HWDATAS        (hwdatas),            // System bus write data
       .EXREQS         (),                   // System bus exclusive request

       // Status
       .BRCHSTAT       (),                   // Branch State
       .HALTED         (),                   // The processor is halted
       .DBGRESTARTED   (),                   // Debug Restart interface handshaking
       .LOCKUP         (lockup),             // The processor is locked up
       .SLEEPING       (),                   // The processor is in sleep mdoe (sleep/deep sleep)
       .SLEEPDEEP      (),                   // The processor is in deep sleep mode
       .SLEEPHOLDACKn  (),                   // Acknowledge for SLEEPHOLDREQn
       .ETMINTNUM      (),                   // Current exception number
       .ETMINTSTAT     (),                   // Exception/Interrupt activation status
       .CURRPRI        (),                   // Current exception priority
       .TRCENA         (),                   // Trace Enable

       // Reset Request
       .SYSRESETREQ    (sys_reset_req),      // System Reset Request

       // Events
       .TXEV           (),                   // Transmit Event

       // Clock gating control
       .GATEHCLK       (),                   // when high, HCLK can be turned off

       .WAKEUP         (),                   // Active HIGH signal from WIC to the PMU that indicates a wake-up event has
                                             // occurred and the system requires clocks and power
       .WICENACK       ()                    // Acknowledge for WICENREQ - WIC operation deep sleep mode
   );

    // AHB-Lite ROM
    AHB2MEM uAHB2ROM (
      //AHBLITE Signals
      .HSEL(1'b1),
      .HCLK(fclk), 
      .HRESETn(reg_sys_rst_n), 
      .HREADY(hreadyc),     
      .HADDR(haddrc),
      .HTRANS(htransc), 
      .HWRITE(hwritec),
      .HSIZE(hsizec),
      .HWDATA(hwdatac), 
      
      .HRDATA(hrdatac), 
      .HREADYOUT(hreadyc)
    );

    // Address Decoder 
    AHBDCD uAHBDCD (
      .HADDR(haddrs),
     
      .HSEL_S0(hsel_mem),
      .HSEL_S1(hsel_vga),
      .HSEL_S2(hsel_uart),
      .HSEL_S3(hsel_timer),
      .HSEL_S4(hsel_gpio),
      .HSEL_S5(hsel_7seg),
      .HSEL_S6(),
      .HSEL_S7(),
      .HSEL_S8(),
      .HSEL_S9(),
      .HSEL_NOMAP(),
     
      .MUX_SEL(mux_sel[3:0])
    );

    // Slave to Master Mulitplexor
    AHBMUX uAHBMUX (
      .HCLK(fclk),
      .HRESETn(reg_sys_rst_n),
      .MUX_SEL(mux_sel[3:0]),
     
      .HRDATA_S0(hrdata_mem),
      .HRDATA_S1(hrdata_vga),
      .HRDATA_S2(hrdata_uart),
      .HRDATA_S3(hrdata_timer),
      .HRDATA_S4(hrdata_gpio),
      .HRDATA_S5(hrdata_7seg),
      .HRDATA_S6(),
      .HRDATA_S7(),
      .HRDATA_S8(),
      .HRDATA_S9(),
      .HRDATA_NOMAP(32'hDEADBEEF),
     
      .HREADYOUT_S0(hready_mem),
      .HREADYOUT_S1(hready_vga),
      .HREADYOUT_S2(hready_uart),
      .HREADYOUT_S3(hready_timer),
      .HREADYOUT_S4(hready_gpio),
      .HREADYOUT_S5(hready_7seg),
      .HREADYOUT_S6(1'b1),
      .HREADYOUT_S7(1'b1),
      .HREADYOUT_S8(1'b1),
      .HREADYOUT_S9(1'b1),
      .HREADYOUT_NOMAP(1'b1),
    
      .HRDATA(hrdatas),
      .HREADY(hreadys)
    );

    // AHBLite Peripherals

    // AHB-Lite RAM
    AHB2MEM uAHB2RAM (
      //AHBLITE Signals
      .HSEL(hsel_mem),
      .HCLK(fclk), 
      .HRESETn(reg_sys_rst_n), 
      .HREADY(hreadys),     
      .HADDR(haddrs),
      .HTRANS(htranss), 
      .HWRITE(hwrites),
      .HSIZE(hsizes),
      .HWDATA(hwdatas), 
      
      .HRDATA(hrdata_mem), 
      .HREADYOUT(hready_mem)
    );

    AHBVGA uAHBVGA (
        .HCLK(fclk), 
        .HRESETn(reg_sys_rst_n), 
        .HADDR(haddrs), 
        .HWDATA(hwdatas), 
        .HREADY(hreadys), 
        .HWRITE(hwrites), 
        .HTRANS(htranss), 
        .HSEL(hsel_vga), 
        .HRDATA(hrdata_vga), 
        .HREADYOUT(hready_vga), 
        .hsync(VGA_HSYNC), 
        .vsync(VGA_VSYNC), 
        .rgb({VGA_RED,VGA_GREEN,VGA_BLUE})
    );

    AHBUART uAHBUART(
        .HCLK(fclk),
        .HRESETn(reg_sys_rst_n),
        .HADDR(haddrs),
        .HTRANS(htranss),
        .HWDATA(hwdatas),
        .HWRITE(hwrites),
        .HREADY(hreadys),
        .HREADYOUT(hready_uart),
        .HRDATA(hrdata_uart),
        .HSEL(hsel_uart),
	
        .RsRx(UART_RXD),
        .RsTx(UART_TXD),
        .uart_irq(uart_irq)
    );
    
    // AHBLite 7-segment Pheripheral	 
    AHB7SEGDEC uAHB7SEGDEC(
        .HCLK(fclk),
        .HRESETn(reg_sys_rst_n),
        .HADDR(haddrs),
        .HTRANS(htranss),
        .HWDATA(hwdatas),
        .HWRITE(hwrites),
        .HREADY(hreadys),
        .HREADYOUT(hready_7seg),
        .HRDATA(hrdata_7seg),
        .HSEL(hsel_7seg),

        .seg(SEG),
        .an(AN),
        .dp(DP)
    );    
            
    // AHBLite timer
    AHBTIMER uAHBTIMER(
        .HCLK(fclk),
        .HRESETn(reg_sys_rst_n),
        .HADDR(haddrs),
        .HTRANS(htranss),
        .HWDATA(hwdatas),
        .HWRITE(hwrites),
        .HREADY(hreadys),
        .HREADYOUT(hready_timer),
        .HRDATA(hrdata_timer),
        .HSEL(hsel_timer),
        .timer_irq(timer_irq)
    );
    
    // AHBLite GPIO    
    AHBGPIO uAHBGPIO(
        .HCLK(fclk),
        .HRESETn(reg_sys_rst_n),
        .HADDR(haddrs),
        .HWRITE(hwrites),
        .HWDATA(hwdatas),
        .HTRANS(htranss),
        .HSEL(hsel_gpio),
        .HREADY(hreadys),
        .GPIOIN({8'b00000000, SW[7:0]}),
        .HREADYOUT(hready_gpio),
        .HRDATA(hrdata_gpio),
        .GPIOOUT(LED[7:0])
    );
        
endmodule

module BUFG (
        input wire I,
        output wire O
);
assign O = I;

endmodule

