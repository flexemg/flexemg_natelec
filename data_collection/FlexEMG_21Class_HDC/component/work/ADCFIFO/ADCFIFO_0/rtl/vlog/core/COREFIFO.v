// ********************************************************************/
// Actel Corporation Proprietary and Confidential
//  Copyright 2011 Actel Corporation.  All rights reserved.
//
// ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
// ACCORDANCE WITH THE ACTEL LICENSE AGREEMENT AND MUST BE APPROVED
// IN ADVANCE IN WRITING.
//
// Description:  CoreFIFO
//               CoreFIFO is a fully configurable Soft FIFO controller. 
//               It is designed to support SmartFusion2 device family.      
//
//
// Revision Information:
// Date     Description
//
// SVN Revision Information:
// SVN $Revision: 4805 $
// SVN $Date: 2012-06-21 17:48:48 +0530 (Thu, 21 Jun 2012) $
//
// Resolved SARs
// SAR      Date     Who   Description
//
// Notes:
//
// ********************************************************************/

`timescale 1ns / 100ps
module ADCFIFO_ADCFIFO_0_COREFIFO (
                  // Clocks and Reset
                  CLK,          // Single Clock for synchronous operation
                  WCLOCK,       // write Clock
                  RCLOCK,       // Read Clock
                  RESET,        // Reset active low
                  // Input Data Bus and Control ports
                  DATA,         // Input Write data
                  WE,           // Write Enable
                  RE,           // Read Enable
                  // Output Data bus
                  Q,            // Output Read data
                  // Status Flags
                  FULL,         // Full flag
                  EMPTY,        // Empty flag
                  AFULL,        // Almost Full flag
                  AEMPTY,       // Almost Empty flag
                  OVERFLOW,     // Overflow indicates write failure
                  UNDERFLOW,    // Underflow indicates read failure
                  WACK,         // Write Acknowledge
                  DVLD,         // Read Data valid
                  WRCNT,        // No.of remaining elements in write domain
                  RDCNT,        // No.of remaining elements in read domain
                  // For external memory
                  MEMWE,        // Memory Write enable
                  MEMRE,        // Memory Read enable
                  MEMWADDR,     // Memory Write Address
                  MEMRADDR,     // Memory Read Address
                  MEMWD,        // Memory Write Data
                  MEMRD         // Memory Read Data
                  );


   // --------------------------------------------------------------------------
   // PARAMETER Declaration
   // --------------------------------------------------------------------------
   parameter                FAMILY        = 19;
   parameter                SYNC          = 0;   // Synchronous or Asynchronous operation | 1 - Single Clock, 0 - Dual clock
   parameter                RCLK_EDGE     = 0;   // Read  Clock Edge | 1 - Posedge, 0 - Negedge
   parameter                WCLK_EDGE     = 0;   // Write Clock Edge | 1 - Posedge, 0 - Negedge
   parameter                RE_POLARITY   = 0;   // Read  Enable Clock Edge | 1 - Active Low, 0 - Active High
   parameter                WE_POLARITY   = 0;   // Write Enable Clock Edge | 1 - Active Low, 0 - Active High
   parameter                RWIDTH        = 32;  // Read  port Data Width
   parameter                WWIDTH        = 32;  // Write port Data Width
   parameter                RDEPTH        = 128; // Read  port Data Depth
   parameter                WDEPTH        = 128; // Write port Data Depth
   parameter                READ_DVALID   = 0;   // Read Data Valid | 0 - Disable , 1 - Enable Read data valid generation
   parameter                WRITE_ACK     = 0;   // Write Data Ack  | 0 - Disable , 1 - Enable Write data ack generation
   parameter                CTRL_TYPE     = 1;   // Controller only options | 1 - Controller Only, 2 - RAM1Kx18, 3 - RAM64x18
   parameter                ESTOP         = 1;   // 0 - Allow Reads when Empty, 1 - Disable Reads when Empty
   parameter                FSTOP         = 1;   // 0 - Allow Writes when Full,  1 - Disable Writes when Full
   parameter                AE_STATIC_EN  = 0;   // Almost Empty Threshold Enable/Disable Static values
                                                 // 0 - Disable values, 1 - Enable Static values 
   parameter                AF_STATIC_EN  = 0;   // Almost Full Threshold Enable/Disable Static values
                                                 // 0 - Disable values, 1 - Enable Static values
   parameter                AEVAL         = 4;   // Almost Empty Threshold assert value
   parameter                AFVAL         = 124; // Almost Full  Threshold assert value
   parameter                PIPE          = 1;   // Pipeline read data out
   parameter                PREFETCH      = 0;   // Prefetching of Read data | 0 - Disable Pre-fetching, 1 - Enable Pre-fetching only if PIPE=1
   parameter                FWFT          = 0;   // FWFT of Read data | 0 - Disable FWFT, 1 - Enable FWFT only if PIPE=1
   parameter                RESET_POLARITY = 0;  // Polarity of Reset | 0 - Active Low, 1 - Active High
   parameter                OVERFLOW_EN    = 0;  // Overflow Enable/Disable | 0 - Disable, 1 - Enable
   parameter                UNDERFLOW_EN   = 0;  // Underflow Enable/Disable | 0 - Disable, 1 - Enable
   parameter                WRCNT_EN       = 0;  // Write Count Enable/Disable | 0 - Disable, 1 - Enable
   parameter                RDCNT_EN       = 0;  // Read Count Enable/Disable | 0 - Disable, 1 - Enable
 
   // **************************************************************************
   // Function Declaration
   // **************************************************************************
   function [31:0] ceil_log2;
      input integer x;
      integer tmp, res;
      begin
         tmp = 1;
         res = 0;
         while(tmp < x) begin
            tmp = tmp * 2;
            res = res + 1;
         end
         ceil_log2 = res;
      end
   endfunction // ceil_log2

  function [31:0] ceil_log2t;
      input integer x;
      integer tmp, res;
      begin
         tmp = 1;
         res = 0;
	 if(x == 1) begin
           ceil_log2t = 1;
	 end
	 else begin
           while(tmp < x) begin
              tmp = tmp * 2;
              res = res + 1;
           end
	   ceil_log2t = res;
         end
      end
   endfunction // ceil_log2t
   // **************************************************************************

   // --------------------------------------------------------------------------
   // Local parameter
   // --------------------------------------------------------------------------
   localparam WMSB_DEPTH      = (ceil_log2(WDEPTH));
   localparam RMSB_DEPTH      = (ceil_log2(RDEPTH)); 
   localparam WDEPTH_CAL      = (WDEPTH == 1) ? (ceil_log2(WDEPTH))  : (ceil_log2(WDEPTH)-1); 
   localparam RDEPTH_CAL      = (RDEPTH == 1) ? (ceil_log2(RDEPTH))  : (ceil_log2(RDEPTH)-1); 
   localparam SYNC_RESET      = (FAMILY == 25) ? 1 : 0; // 0 = async mode, 1 = sync mode

   // --------------------------------------------------------------------------
   // I/O Declaration
   // --------------------------------------------------------------------------
   
   //--------
   // Inputs
   //--------

   // Clocks and Reset
   input                            CLK;   
   input                            WCLOCK;
   input                            RCLOCK;
   input                            RESET;
   // Input Data Bus and Control ports
   input [WWIDTH - 1 : 0]           DATA;
   input                            WE;
   input                            RE;
   input [RWIDTH - 1 : 0]           MEMRD;

   //---------
   // Outputs
   //---------

   // Output Data bus
   output [RWIDTH - 1 : 0]          Q;
   // Output Status Flags
   output                           FULL;
   output                           EMPTY;
   output                           AFULL;
   output                           AEMPTY;
   output                           OVERFLOW;
   output                           UNDERFLOW;
   output                           WACK;
   output                           DVLD;
   output [(ceil_log2(WDEPTH)) : 0] WRCNT;
   output [(ceil_log2(RDEPTH)) : 0] RDCNT;
   // Outputs For external memory
   output                           MEMWE;
   output                           MEMRE;
   output [WDEPTH_CAL : 0]          MEMWADDR;
   output [RDEPTH_CAL : 0]          MEMRADDR;
   output [WWIDTH - 1 : 0]          MEMWD;

   // --------------------------------------------------------------------------
   // Internal signals
   // --------------------------------------------------------------------------
   wire                             EMPTY1;
   wire                             AEMPTY1;
   wire                             EMPTY2;
   wire                             AEMPTY2;
   wire                             fifo_rd_en;
   wire                             fifo_re_in;   
   wire [WDEPTH_CAL : 0]            fifo_MEMWADDR;
   wire [RDEPTH_CAL : 0]            fifo_MEMRADDR;
   wire [RDEPTH_CAL : 0]            pf_MEMRADDR;
   wire [RDEPTH_CAL : 0]            fwft_MEMRADDR;
   wire [RDEPTH_CAL : 0]            ram_raddr;
   wire                             fifo_MEMWE;
   wire                             fifo_MEMRE;
   wire                             fifo_MEMRE_int;
   wire [RWIDTH - 1 : 0]            pf_Q;
   wire [RWIDTH - 1 : 0]            fwft_Q;
   wire [RWIDTH - 1 : 0]            int_MEMRD;
   wire [RWIDTH - 1 : 0]            int_MEMRD_fwft;
   wire [RWIDTH - 1 : 0]            int_MEMRD_pipe0;
   wire [RWIDTH - 1 : 0]            int_MEMRD_pipe1;
   wire [RWIDTH - 1 : 0]            int_MEMRD_pipe2;
   wire [RWIDTH - 1 : 0]            mem_pf_RD;
   wire [RWIDTH - 1 : 0]            ext_MEMRD;
   wire [RWIDTH - 1 : 0]            ext_MEMRD_fwft;
   wire [RWIDTH - 1 : 0]            ext_MEMRD_pipe0;
   wire [RWIDTH - 1 : 0]            ext_MEMRD_pipe1;
   wire [RWIDTH - 1 : 0]            ext_MEMRD_pipe2;
   wire                             RE_pol;
   wire [RWIDTH - 1 : 0]            RDATA_int;  
   wire                             re_pulse; 
   wire                             re_pulse_pre; 
   wire                             aresetn;
   wire                             sresetn;
   wire                             DVLD_async;
   wire                             DVLD_scntr;
   wire                             DVLD_sync;
   wire                             fwft_dvld;
   wire                             fwft_reg_valid;   
   wire                             pf_dvld;
   wire                             pos_rclk;
   wire                             pos_wclk;
   
   reg                              reg_valid;
   reg                              re_set;
   reg [RWIDTH - 1 : 0]             RDATA_r;  
   reg [RWIDTH - 1 : 0]             RDATA_r1;  
   reg [RWIDTH - 1 : 0]             RDATA_r_pre;  
   reg [RWIDTH - 1 : 0]             RDATA_ext_r;  
   reg [RWIDTH - 1 : 0]             RDATA_ext_r1;  
   reg                              REN_d1;
   reg                              REN_d2;
   reg                              re_pulse_d1;
   reg                              re_pulse_d2;
   reg                              RE_d1 ;
   reg                              RE_d2 ;
   reg [RWIDTH - 1 : 0]             fwft_Q_r;
   reg [RWIDTH - 1 : 0]             reg_RD;
   reg                              AEMPTY1_r;
   reg                              AEMPTY1_r1;
   
   // --------------------------------------------------------------------------
   // ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
   // ||                                                                      ||
   // ||                     Start - of - Code                                ||
   // ||                                                                      ||
   // ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
   // --------------------------------------------------------------------------
   
   // --------------------------------------------------------------------------
   // clocks and enables
   // --------------------------------------------------------------------------
   generate
      if(RCLK_EDGE == 1) begin
         assign pos_rclk  = SYNC ? CLK : RCLOCK;  //SAR#60185
      end
   endgenerate
   generate
      if(RCLK_EDGE == 0) begin
         assign pos_rclk  = SYNC ? ~CLK :  ~RCLOCK; //SAR#60185
      end
   endgenerate
   generate
      if(WCLK_EDGE == 1) begin
         assign pos_wclk  = SYNC ? CLK :  WCLOCK;
      end
   endgenerate
   generate
      if(WCLK_EDGE == 0) begin
         assign pos_wclk  = SYNC ? ~CLK :  ~WCLOCK;
      end
   endgenerate

   // --------------------------------------------------------------------------
   // resets
   // --------------------------------------------------------------------------
   assign neg_reset = (RESET_POLARITY == 1) ? ~RESET : RESET;
   assign aresetn   = (SYNC_RESET == 1) ? 1'b1  : neg_reset;
   assign sresetn   = (SYNC_RESET == 1) ? neg_reset : 1'b1;

   // --------------------------------------------------------------------------
   // Generate top-level read data output
   // --------------------------------------------------------------------------         
   generate
      if(FWFT == 0 && PREFETCH == 0) begin
         assign Q   = mem_pf_RD;
      end
   endgenerate

   generate
      if(FWFT == 1 && PREFETCH == 0 && PIPE == 1) begin
         assign Q   = (fwft_dvld & (RE_pol | fwft_reg_valid)) ? fwft_Q : fwft_Q_r;
      end
   endgenerate

   generate
      if(FWFT == 0 && PREFETCH == 1 && PIPE == 1) begin
         assign Q   = RE_pol ? fwft_Q : fwft_Q_r; 
      end
   endgenerate
   
   // --------------------------------------------------------------------------
   // Generate FIFO flags
   // --------------------------------------------------------------------------         
   assign EMPTY  = (FWFT || PREFETCH) ? EMPTY2 : EMPTY1;

   generate
      if((FWFT == 1 || PREFETCH == 1) && PIPE == 1) begin
         assign AEMPTY = AEMPTY2;  
      end
   endgenerate
   generate
      if(FWFT == 0 && PREFETCH == 0) begin
         assign AEMPTY = AEMPTY1;
      end
   endgenerate
 
   always @(posedge pos_rclk or negedge aresetn)
     begin
        if((!aresetn) || (!sresetn)) begin
           AEMPTY1_r  <= 'h0;
           AEMPTY1_r1 <= 'h0;
        end
        else begin
           AEMPTY1_r  <= AEMPTY1;
           AEMPTY1_r1 <= AEMPTY1_r;
        end
     end

   // --------------------------------------------------------------------------
   // Generate top-level read data valid output
   // --------------------------------------------------------------------------         
   generate
      if (SYNC == 0 && FWFT == 0 && PREFETCH == 0) begin
         assign DVLD = DVLD_async;
      end
   endgenerate
   generate
      if (((SYNC == 1) && (RDEPTH == WDEPTH) && (ESTOP == 1) && (FSTOP ==  1)) && FWFT == 0 && PREFETCH == 0) begin  
         assign DVLD = DVLD_scntr;
      end
   endgenerate
   generate
      if ((SYNC == 1) && (RDEPTH == WDEPTH) && (ESTOP == 0 || FSTOP ==  0) && FWFT == 0 && PREFETCH == 0) begin  
         assign DVLD = DVLD_sync;
      end
   endgenerate
   generate
      if (SYNC == 1 &&  (RDEPTH != WDEPTH) && FWFT == 0 && PREFETCH == 0) begin
         assign DVLD = DVLD_sync;
      end
   endgenerate
   generate
      if (FWFT == 1 || PREFETCH == 1) begin
         assign DVLD = (READ_DVALID == 1) ? fwft_dvld : 1'b0;
      end
   endgenerate

   // --------------------------------------------------------------------------
   // Generate read enable to the FIFO controller based on whether FWFT/PREFETCH
   // mode is selected or not.
   // --------------------------------------------------------------------------         
   assign  fifo_re_in   = ((FWFT == 1 || PREFETCH == 1) && PIPE == 1) ? fifo_rd_en : RE;   

   // --------------------------------------------------------------------------
   // Generate top-level outputs to External memory
   // --------------------------------------------------------------------------
   assign MEMWADDR     = (CTRL_TYPE == 1) ? fifo_MEMWADDR : 'h0;
   assign MEMWE        = (CTRL_TYPE == 1) ? fifo_MEMWE    : 1'b0;
   assign MEMWD        = (CTRL_TYPE == 1) ? DATA          : 'h0;
   assign #1 MEMRE     = (CTRL_TYPE == 1) ? fifo_MEMRE    : 1'b0; 
   assign #1 MEMRADDR  = (CTRL_TYPE == 1) ? ((FWFT == 1 && PIPE == 1) ? fwft_MEMRADDR : ((PREFETCH == 1 && PIPE == 1) ? fwft_MEMRADDR : fifo_MEMRADDR)) : 'h0;

   // --------------------------------------------------------------------------
   // Based on the 'SYNC' parameter generate either Synchronous FIFO or
   // Asynchronous FIFO
   // --------------------------------------------------------------------------
   generate
        if ((SYNC == 1) && (RDEPTH == WDEPTH) && (ESTOP == 1) && (FSTOP ==  1))
        // ------------------------------------
        // Synchronous FIFO operation Instance
    	// Equal Depths and No wrap around
        // ------------------------------------
		
            ADCFIFO_ADCFIFO_0_corefifo_sync_scntr #(
                .WRITE_WIDTH      (WWIDTH         ),
                .WRITE_DEPTH      ((ceil_log2(WDEPTH))),
                .FULL_WRITE_DEPTH (WDEPTH         ),
                .READ_WIDTH       (RWIDTH         ),
                .READ_DEPTH       ((ceil_log2(RDEPTH))),
                .FULL_READ_DEPTH  (RDEPTH         ),
                .WCLK_HIGH        (WCLK_EDGE      ),
                .PREFETCH         (PREFETCH       ),
                .FWFT             (FWFT           ), 
                .RESET_LOW        (RESET_POLARITY ),
                .WRITE_LOW        (WE_POLARITY    ),
                .READ_LOW         (RE_POLARITY    ),
                .AF_FLAG_STATIC   (AF_STATIC_EN   ),
                .AE_FLAG_STATIC   (AE_STATIC_EN   ),
                .AFULL_VAL        (AFVAL          ),
                .AEMPTY_VAL       (AEVAL          ),
                .ESTOP            (ESTOP          ),
                .FSTOP            (FSTOP          ),
                .PIPE             (PIPE           ),
                .SYNC_RESET       (SYNC_RESET     ),
                .REGISTER_RADDR   (PIPE           ),
                .READ_DVALID      (READ_DVALID    ),
                .WRITE_ACK        (WRITE_ACK      ),
		.OVERFLOW_EN      (OVERFLOW_EN    ),
                .UNDERFLOW_EN     (UNDERFLOW_EN   ),
                .WRCNT_EN         (WRCNT_EN       ),
                .RDCNT_EN         (RDCNT_EN       )
            )
                fifo_corefifo_sync_scntr (
                    .clk          (CLK          ),
                    .reset        (RESET        ),
                    .we           (WE           ),
                    .re           (fifo_re_in   ),  
                    .re_top       (RE           ),
                    .full         (FULL         ),
                    .afull        (AFULL        ),
                    .wrcnt        (WRCNT        ),
                    .empty        (EMPTY1       ),
                    .aempty       (AEMPTY1       ),
                    .rdcnt        (RDCNT        ),
                    .underflow    (UNDERFLOW    ),
                    .overflow     (OVERFLOW     ),
                    .dvld         (DVLD_scntr   ),
                    .wack         (WACK         ),
                    .memwaddr     (fifo_MEMWADDR),
                    .memwe        (fifo_MEMWE   ),
                    .memraddr     (fifo_MEMRADDR),
                    .memre        (fifo_MEMRE   ),
                    .empty_top_fwft(EMPTY2   )  
                );
   
      else if (SYNC == 1 &&  (WDEPTH >= RDEPTH)) begin
        // ------------------------------------
        // Synchronous FIFO operation Instance
        // ------------------------------------
        ADCFIFO_ADCFIFO_0_corefifo_sync  #(
                          .WRITE_WIDTH      (WWIDTH        ),
                          .WRITE_DEPTH      ((ceil_log2(WDEPTH))),
                          .FULL_WRITE_DEPTH (WDEPTH        ),
                          .READ_WIDTH       (RWIDTH        ),
                          .READ_DEPTH       ((ceil_log2(RDEPTH))),
                          .VAR_ASPECT_WRDEPTH ((ceil_log2(WDEPTH))),
                          .VAR_ASPECT_RDDEPTH ((ceil_log2(WDEPTH))),
                          .FULL_READ_DEPTH  (RDEPTH        ),
                          .PREFETCH         (PREFETCH      ),
                          .FWFT             (FWFT          ),
                          .WCLK_HIGH        (WCLK_EDGE     ),
                          .RESET_LOW        (RESET_POLARITY),
                          .WRITE_LOW        (WE_POLARITY   ),
                          .READ_LOW         (RE_POLARITY   ),
                          .AF_FLAG_STATIC   (AF_STATIC_EN  ),
                          .AE_FLAG_STATIC   (AE_STATIC_EN  ),
                          .AFULL_VAL        (AFVAL         ),
                          .AEMPTY_VAL       (AEVAL         ),
                          .ESTOP            (ESTOP         ),
                          .FSTOP            (FSTOP         ),
                          .PIPE             (PIPE          ),
                          .SYNC_RESET       (SYNC_RESET    ),
                          .REGISTER_RADDR   (PIPE          ),
                          .READ_DVALID      (READ_DVALID   ),
                          .WRITE_ACK        (WRITE_ACK     ),
    	              	  .OVERFLOW_EN      (OVERFLOW_EN   ),
                          .UNDERFLOW_EN     (UNDERFLOW_EN  ),
                          .WRCNT_EN         (WRCNT_EN      ),
                          .RDCNT_EN         (RDCNT_EN      )
                         ) 
                        U_corefifo_sync(
                                         .clk              (CLK             ),
                                         .reset            (RESET           ),
                                         .we               (WE              ),
                                         .re               (RE              ),
                                         .full             (FULL            ),
                                         .afull            (AFULL           ),
                                         .wrcnt            (WRCNT           ),
                                         .empty            (EMPTY1          ),
                                         .aempty           (AEMPTY1         ),
                                         .rdcnt            (RDCNT           ),
                                         .underflow        (UNDERFLOW       ),
                                         .overflow         (OVERFLOW        ),
                                         .dvld             (DVLD_sync       ),
                                         .wack             (WACK            ),
                                         .memwaddr         (fifo_MEMWADDR   ),
                                         .memwe            (fifo_MEMWE      ),
                                         .memraddr         (fifo_MEMRADDR   ),
                                         .memre            (fifo_MEMRE      )
                                         );
      end
      else if (SYNC == 1 &&  (RDEPTH > WDEPTH)) begin
        // ------------------------------------
        // Synchronous FIFO operation Instance
        // ------------------------------------
        ADCFIFO_ADCFIFO_0_corefifo_sync  #(
                          .WRITE_WIDTH      (WWIDTH        ),
                          .WRITE_DEPTH      ((ceil_log2(WDEPTH))),
                          .FULL_WRITE_DEPTH (WDEPTH        ),
                          .READ_WIDTH       (RWIDTH        ),
                          .READ_DEPTH       ((ceil_log2(RDEPTH))),
                          .VAR_ASPECT_WRDEPTH ((ceil_log2(RDEPTH))),
                          .VAR_ASPECT_RDDEPTH ((ceil_log2(RDEPTH))),
                          .FULL_READ_DEPTH  (RDEPTH        ),
                          .PREFETCH         (PREFETCH      ),
                          .FWFT             (FWFT          ),
                          .WCLK_HIGH        (WCLK_EDGE     ),
                          .RESET_LOW        (RESET_POLARITY),
                          .WRITE_LOW        (WE_POLARITY   ),
                          .READ_LOW         (RE_POLARITY   ),
                          .AF_FLAG_STATIC   (AF_STATIC_EN  ),
                          .AE_FLAG_STATIC   (AE_STATIC_EN  ),
                          .AFULL_VAL        (AFVAL         ),
                          .AEMPTY_VAL       (AEVAL         ),
                          .ESTOP            (ESTOP         ),
                          .FSTOP            (FSTOP         ),
                          .PIPE             (PIPE          ),
                          .SYNC_RESET       (SYNC_RESET    ),
                          .REGISTER_RADDR   (PIPE          ),
                          .READ_DVALID      (READ_DVALID   ),
                          .WRITE_ACK        (WRITE_ACK     ),
    	              	  .OVERFLOW_EN      (OVERFLOW_EN   ),
                          .UNDERFLOW_EN     (UNDERFLOW_EN  ),
                          .WRCNT_EN         (WRCNT_EN      ),
                          .RDCNT_EN         (RDCNT_EN      )
                         ) 
                        U_corefifo_sync(
                                         .clk              (CLK             ),
                                         .reset            (RESET           ),
                                         .we               (WE              ),
                                         .re               (RE              ),
                                         .full             (FULL            ),
                                         .afull            (AFULL           ),
                                         .wrcnt            (WRCNT           ),
                                         .empty            (EMPTY1          ),
                                         .aempty           (AEMPTY1         ),
                                         .rdcnt            (RDCNT           ),
                                         .underflow        (UNDERFLOW       ),
                                         .overflow         (OVERFLOW        ),
                                         .dvld             (DVLD_sync       ),
                                         .wack             (WACK            ),
                                         .memwaddr         (fifo_MEMWADDR   ),
                                         .memwe            (fifo_MEMWE      ),
                                         .memraddr         (fifo_MEMRADDR   ),
                                         .memre            (fifo_MEMRE      )
                                         );

      end
      else if (SYNC == 0 && (WDEPTH >= RDEPTH) ) begin  // for variable aspect ratio
        // --------------------------------------------------------------------
        // Asynchronous FIFO operation Instance with Controller Only operation
        // --------------------------------------------------------------------
        ADCFIFO_ADCFIFO_0_corefifo_async  #(
                          .WRITE_WIDTH      (WWIDTH         ),
                          .WRITE_DEPTH      ((ceil_log2(WDEPTH))),
                          .FULL_WRITE_DEPTH (WDEPTH         ),
                          .READ_WIDTH       (RWIDTH         ),
                          .READ_DEPTH       ((ceil_log2(RDEPTH))),
                          .VAR_ASPECT_WRDEPTH ((ceil_log2(WDEPTH))),
                          .VAR_ASPECT_RDDEPTH ((ceil_log2(WDEPTH))),
                          .FULL_READ_DEPTH  (RDEPTH         ),
                          .PREFETCH         (PREFETCH       ),
                          .FWFT             (FWFT           ),
                          .WCLK_HIGH        (WCLK_EDGE      ),
                          .RCLK_HIGH        (RCLK_EDGE      ),
                          .RESET_LOW        (RESET_POLARITY ),
                          .WRITE_LOW        (WE_POLARITY    ),
                          .READ_LOW         (RE_POLARITY    ),
                          .AF_FLAG_STATIC   (AF_STATIC_EN   ),
                          .AE_FLAG_STATIC   (AE_STATIC_EN   ),
                          .AFULL_VAL        (AFVAL          ),
                          .AEMPTY_VAL       (AEVAL          ),
                          .ESTOP            (ESTOP          ),
                          .FSTOP            (FSTOP          ),
                          .PIPE             (PIPE           ),
                          .SYNC_RESET       (SYNC_RESET     ),
                          .REGISTER_RADDR   (PIPE           ),
                          .READ_DVALID      (READ_DVALID    ),
                          .WRITE_ACK        (WRITE_ACK      ),
	       	              .OVERFLOW_EN      (OVERFLOW_EN    ),
                          .UNDERFLOW_EN     (UNDERFLOW_EN   ),
                          .WRCNT_EN         (WRCNT_EN       ),
                          .RDCNT_EN         (RDCNT_EN       )

                         ) 
                        U_corefifo_async(
                                         .rclk             (RCLOCK          ),
                                         .wclk             (WCLOCK          ),
                                         .reset            (RESET           ),
                                         .we               (WE              ),
                                         .re               (fifo_re_in      ),  
                                         .re_top           (RE              ),
                                         .full             (FULL            ),
                                         .afull            (AFULL           ),
                                         .wrcnt            (WRCNT           ),
                                         .empty            (EMPTY1          ),
                                         .aempty           (AEMPTY1         ),
                                         .rdcnt            (RDCNT           ),
                                         .underflow        (UNDERFLOW       ),
                                         .overflow         (OVERFLOW        ),
                                         .dvld             (DVLD_async      ),
                                         .wack             (WACK            ),
                                         .memwaddr         (fifo_MEMWADDR   ),
                                         .memwe            (fifo_MEMWE      ),
                                         .memraddr         (fifo_MEMRADDR   ),
                                         .memre            (fifo_MEMRE      )
                                         );
      end
      else if (SYNC == 0 && (RDEPTH > WDEPTH) ) begin  // for variable aspect ratio
        // --------------------------------------------------------------------
        // Asynchronous FIFO operation Instance with Controller Only operation
        // --------------------------------------------------------------------
        ADCFIFO_ADCFIFO_0_corefifo_async  #(
                          .WRITE_WIDTH      (WWIDTH         ),
                          .WRITE_DEPTH      ((ceil_log2(WDEPTH))),
                          .FULL_WRITE_DEPTH (WDEPTH         ),
                          .READ_WIDTH       (RWIDTH         ),
                          .READ_DEPTH       ((ceil_log2(RDEPTH))),
                          .VAR_ASPECT_WRDEPTH ((ceil_log2(RDEPTH))),
                          .VAR_ASPECT_RDDEPTH ((ceil_log2(RDEPTH))),
                          .FULL_READ_DEPTH  (RDEPTH         ),
                          .PREFETCH         (PREFETCH       ),
                          .FWFT             (FWFT           ),
                          .WCLK_HIGH        (WCLK_EDGE      ),
                          .RCLK_HIGH        (RCLK_EDGE      ),
                          .RESET_LOW        (RESET_POLARITY ),
                          .WRITE_LOW        (WE_POLARITY    ),
                          .READ_LOW         (RE_POLARITY    ),
                          .AF_FLAG_STATIC   (AF_STATIC_EN   ),
                          .AE_FLAG_STATIC   (AE_STATIC_EN   ),
                          .AFULL_VAL        (AFVAL          ),
                          .AEMPTY_VAL       (AEVAL          ),
                          .ESTOP            (ESTOP          ),
                          .FSTOP            (FSTOP          ),
                          .PIPE             (PIPE           ),
                          .SYNC_RESET       (SYNC_RESET     ),
                          .REGISTER_RADDR   (PIPE           ),
                          .READ_DVALID      (READ_DVALID    ),
                          .WRITE_ACK        (WRITE_ACK      ),
	       	          .OVERFLOW_EN      (OVERFLOW_EN    ),
                          .UNDERFLOW_EN     (UNDERFLOW_EN   ),
                          .WRCNT_EN         (WRCNT_EN       ),
                          .RDCNT_EN         (RDCNT_EN       )

                         ) 
                        U_corefifo_async(
                                         .rclk             (RCLOCK          ),
                                         .wclk             (WCLOCK          ),
                                         .reset            (RESET           ),
                                         .we               (WE              ),
                                         .re               (RE              ),
                                         .re_top           (RE              ),
                                         .full             (FULL            ),
                                         .afull            (AFULL           ),
                                         .wrcnt            (WRCNT           ),
                                         .empty            (EMPTY1          ),
                                         .aempty           (AEMPTY1         ),
                                         .rdcnt            (RDCNT           ),
                                         .underflow        (UNDERFLOW       ),
                                         .overflow         (OVERFLOW        ),
                                         .dvld             (DVLD_async      ),
                                         .wack             (WACK            ),
                                         .memwaddr         (fifo_MEMWADDR   ),
                                         .memwe            (fifo_MEMWE      ),
                                         .memraddr         (fifo_MEMRADDR   ),
                                         .memre            (fifo_MEMRE      )
                                         );
      end
      else begin  // for variable aspect ratio
        // --------------------------------------------------------------------
        // Asynchronous FIFO operation Instance with Controller Only operation
        // --------------------------------------------------------------------
        ADCFIFO_ADCFIFO_0_corefifo_async  #(
                          .WRITE_WIDTH      (WWIDTH         ),
                          .WRITE_DEPTH      ((ceil_log2(WDEPTH))),
                          .FULL_WRITE_DEPTH (WDEPTH         ),
                          .READ_WIDTH       (RWIDTH         ),
                          .READ_DEPTH       ((ceil_log2(RDEPTH))),
                          .VAR_ASPECT_RDDEPTH ((ceil_log2(RDEPTH))),
                          .VAR_ASPECT_WRDEPTH ((ceil_log2(WDEPTH))),
                          .FULL_READ_DEPTH  (RDEPTH         ),
                          .PREFETCH         (PREFETCH       ),
                          .FWFT             (FWFT           ),
                          .WCLK_HIGH        (WCLK_EDGE      ),
                          .RCLK_HIGH        (RCLK_EDGE      ),
                          .RESET_LOW        (RESET_POLARITY ),
                          .WRITE_LOW        (WE_POLARITY    ),
                          .READ_LOW         (RE_POLARITY    ),
                          .AF_FLAG_STATIC   (AF_STATIC_EN   ),
                          .AE_FLAG_STATIC   (AE_STATIC_EN   ),
                          .AFULL_VAL        (AFVAL          ),
                          .AEMPTY_VAL       (AEVAL          ),
                          .ESTOP            (ESTOP          ),
                          .FSTOP            (FSTOP          ),
                          .PIPE             (PIPE           ),
                          .SYNC_RESET       (SYNC_RESET     ),
                          .REGISTER_RADDR   (PIPE           ),
                          .READ_DVALID      (READ_DVALID    ),
                          .WRITE_ACK        (WRITE_ACK      ),
    	       	          .OVERFLOW_EN      (OVERFLOW_EN    ),
                          .UNDERFLOW_EN     (UNDERFLOW_EN   ),
                          .WRCNT_EN         (WRCNT_EN       ),
                          .RDCNT_EN         (RDCNT_EN       )

                         ) 
                        U_corefifo_async(
                                         .rclk             (RCLOCK          ),
                                         .wclk             (WCLOCK          ),
                                         .reset            (RESET           ),
                                         .we               (WE              ),
                                         .re               (RE              ),
                                         .re_top           (RE              ),
                                         .full             (FULL            ),
                                         .afull            (AFULL           ),
                                         .wrcnt            (WRCNT           ),
                                         .empty            (EMPTY1          ),
                                         .aempty           (AEMPTY1         ),
                                         .rdcnt            (RDCNT           ),
                                         .underflow        (UNDERFLOW       ),
                                         .overflow         (OVERFLOW        ),
                                         .dvld             (DVLD_async      ),
                                         .wack             (WACK            ),
                                         .memwaddr         (fifo_MEMWADDR   ),
                                         .memwe            (fifo_MEMWE      ),
                                         .memraddr         (fifo_MEMRADDR   ),
                                         .memre            (fifo_MEMRE      )
                                         );
      end      
   endgenerate
   

   // -----------------------------------------------------------------------
   // FWFT/Prefetch logic
   // The module is used to provide FWFT and Prefetch logic.
   // -----------------------------------------------------------------------
   generate
      if ((FWFT == 1 || PREFETCH == 1) && PIPE == 1)  

        // FWFT module instance 
        ADCFIFO_ADCFIFO_0_corefifo_fwft #(
                   .RWIDTH    (RWIDTH         ),
                   .WWIDTH    (WWIDTH         ),
                   .RCLK_HIGH (RCLK_EDGE      ),
                   .WCLK_HIGH (WCLK_EDGE      ),
                   .RESET_LOW (RESET_POLARITY ),
                   .WRITE_LOW (WE_POLARITY    ),
                   .READ_LOW  (RE_POLARITY    ),
                   .PREFETCH  (PREFETCH       ),
                   .FWFT      (FWFT           ),
                   .SYNC      (SYNC           ),
                   .SYNC_RESET(SYNC_RESET     ),
                   .RDEPTH    (ceil_log2(RDEPTH))
                   )
          u_corefifo_fwft(
                     .rd_clk        (RCLOCK        ),
                     .wr_clk        (WCLOCK        ),
                     .clk           (CLK           ),
                     .rst           (RESET         ),
                     .empty         (EMPTY2        ),
                     .aempty        (AEMPTY2       ),
                     .rd_en         (RE            ),
                     .fifo_rd_en    (fifo_rd_en    ),
                     .fifo_dout     (mem_pf_RD     ),
                     .fifo_empty    (EMPTY1        ),
                     .fifo_aempty   (AEMPTY1       ),
                     .wr_en         (WE            ), 
                     .din           (DATA          ), 
                     .fwft_dvld     (fwft_dvld     ),
                     .reg_valid     (fwft_reg_valid),
                     .fifo_MEMRADDR (fifo_MEMRADDR ),
                     .fwft_MEMRADDR (fwft_MEMRADDR ),
                     .dout          (fwft_Q        )  
                     );


   endgenerate

   // --------------------------------------------------------------------------
   // Provides read address to ram memory
   // --------------------------------------------------------------------------
   generate
      if(FWFT == 0 && PREFETCH == 0) begin
         assign #1 ram_raddr = fifo_MEMRADDR;   
      end
   endgenerate

   generate
      if(FWFT == 1 && PIPE == 1) begin
         assign #1 ram_raddr = fwft_MEMRADDR;   
      end
   endgenerate

   generate
      if(PREFETCH == 1 && PIPE == 1) begin
         assign #1 ram_raddr = fwft_MEMRADDR;  
      end
   endgenerate

   // --------------------------------------------------------------------------
   // Provides read address to ram memory
   // --------------------------------------------------------------------------
   always @(posedge pos_rclk or negedge aresetn)
     begin
        if((!aresetn) || (!sresetn)) begin
           re_set <= 'h0;
        end
        else begin
           if(fifo_MEMRE && !REN_d1) begin      
              re_set <= 1'b0;
           end
           else if(!fifo_MEMRE && REN_d1) begin  
              re_set <= 1'b1;
           end
        end
     end

     always @(posedge pos_rclk or negedge aresetn)
       begin
          if((!aresetn) || (!sresetn)) begin
            RDATA_r <= 'h0;
          end
          else if(!fifo_MEMRE && REN_d1) begin
             RDATA_r <= RDATA_int;
          end
       end
     
   // --------------------------------------------------------------------------
   // Maintain the last read data
   // --------------------------------------------------------------------------
   always @(posedge pos_rclk or negedge aresetn)   
     begin
        if((!aresetn) || (!sresetn)) begin
           fwft_Q_r <= 'h0;
        end
        else begin
           fwft_Q_r <= Q;
        end
     end

   always @(posedge pos_rclk or negedge aresetn)   
     begin
        if((!aresetn) || (!sresetn)) begin
           RDATA_r_pre <= 'h0;
        end
        else if(fifo_MEMRE) begin
           RDATA_r_pre <= Q ;
        end
     end

   always @(posedge pos_rclk or negedge aresetn)   
     begin
        if((!aresetn) || (!sresetn)) begin
           RDATA_r1 <= 'h0;
        end
        else if(!REN_d1 && REN_d2) begin
           RDATA_r1 <= RDATA_int;
        end
     end

   assign RE_pol  = RE_POLARITY  ? (~RE) : (RE); 

   always @(posedge pos_rclk or negedge aresetn)
     begin
        if((!aresetn) || (!sresetn)) begin
           REN_d1      <= 'h0;
           REN_d2      <= 'h0;
           RE_d1       <= 'h0;
           RE_d2       <= 'h0;
           re_pulse_d1 <= 'h0;
           re_pulse_d2 <= 'h0;
        end
        else begin
           RE_d1       <= RE_pol;
           RE_d2       <= RE_d1;
           REN_d1      <= fifo_MEMRE;
           REN_d2      <= REN_d1;
           re_pulse_d1 <= re_pulse;
           re_pulse_d2 <= re_pulse_d1;
        end
     end

   assign re_pulse     = (!fifo_MEMRE & REN_d1) | re_set;
   assign re_pulse_pre = !fifo_MEMRE;

   assign int_MEMRD_fwft  =  (re_set  & (RE_d1==0      )) ? RDATA_r     : RDATA_int;  
   assign int_MEMRD_pipe0 =  (re_pulse     & (RE_pol==0)) ? RDATA_r_pre : RDATA_int;
   assign int_MEMRD_pipe1 =  (re_pulse_d1  & (RE_d1==0 )) ? RDATA_r     : RDATA_int;  
   assign int_MEMRD_pipe2 =  (re_pulse_d2  & (RE_d2==0 )) ? RDATA_r1    : RDATA_int;
   assign int_MEMRD       =  (FWFT == 1) ? int_MEMRD_fwft      : 
                             ((PREFETCH == 1) ? int_MEMRD_fwft :
                              ((PIPE == 0)? int_MEMRD_pipe0    : 
                               ((PIPE == 1) ? int_MEMRD_pipe1  : 
                                ((PIPE == 2) ? int_MEMRD_pipe2 : 
                                 RDATA_int)))); 

   assign ext_MEMRD_fwft  =  (re_set  & (RE_d1==0      )) ? RDATA_ext_r : MEMRD;
   assign ext_MEMRD_pipe0 =  (re_pulse     & (RE_pol==0)) ? RDATA_r_pre  : MEMRD;
   assign ext_MEMRD_pipe1 =  (re_pulse_d1  & (RE_d1==0 )) ? RDATA_ext_r  : MEMRD;
   assign ext_MEMRD_pipe2 =  (re_pulse_d2  & (RE_d2==0 )) ? RDATA_ext_r1 : MEMRD;
   assign ext_MEMRD       =  (FWFT == 1) ? ext_MEMRD_fwft      : 
                             ((PREFETCH == 1) ? ext_MEMRD_fwft :
                              ((PIPE == 0)? ext_MEMRD_pipe0    : 
                               ((PIPE == 1) ? ext_MEMRD_pipe1  : 
                                ((PIPE == 2) ? ext_MEMRD_pipe2 : MEMRD)))); 

   // --------------------------------------------------------------------------
   // Get the READ Data from internal or external memory based on CTRL_TYPE
   // --------------------------------------------------------------------------
   assign mem_pf_RD = (CTRL_TYPE == 1) ? ext_MEMRD : int_MEMRD;

   assign #1 fifo_MEMRE_int = fifo_MEMRE;

   always @(posedge pos_rclk or negedge aresetn)
     begin
        if((!aresetn) || (!sresetn)) begin
           RDATA_ext_r <= 'h0;
        end
        else if(!fifo_MEMRE && REN_d1) begin
           RDATA_ext_r <= MEMRD;
        end
     end
   
   always @(posedge pos_rclk or negedge aresetn)  
     begin
        if((!aresetn) || (!sresetn)) begin
           RDATA_ext_r1 <= 'h0;
        end
        else if(!REN_d1 && REN_d2) begin
           RDATA_ext_r1 <= MEMRD;
        end
     end

   // -----------------------------------------------------------------------
   // Memory wrapper instance
   // -----------------------------------------------------------------------
// v2.4 commented   
/*   generate
     if (CTRL_TYPE != 1) begin

        ADCFIFO_ADCFIFO_0_ram_wrapper #(
                   .RWIDTH    (RWIDTH            ),
                   .WWIDTH    (WWIDTH            ),
                   .SYNC      (SYNC              ),
                   .PIPE      (PIPE              ),
                   .CTRL_TYPE (CTRL_TYPE         ),
                   .RDEPTH    (ceil_log2t(RDEPTH)),
                   .WDEPTH    (ceil_log2t(WDEPTH))
                   )
                UI_ram_wrapper (
                                .WDATA (DATA            ),
                                .WADDR (fifo_MEMWADDR   ),
                                .WEN   (fifo_MEMWE      ),
                                .REN   (fifo_MEMRE_int  ),
                                .RDATA (RDATA_int       ), 
                                .RADDR (ram_raddr       ),
                                .CLOCK (CLK             ),  
                                .WCLOCK(WCLOCK          ),  
                                .RCLOCK(RCLOCK          ),  
                                .RESET_N(RESET          )
                                );
     end
endgenerate
*/

// v2.4 --- >
   generate
     if (CTRL_TYPE != 1 && FAMILY != 25) begin

        ADCFIFO_ADCFIFO_0_ram_wrapper #(
                   .RWIDTH    (RWIDTH            ),
                   .WWIDTH    (WWIDTH            ),
                   .SYNC      (SYNC              ),
                   .PIPE      (PIPE              ),
                   .CTRL_TYPE (CTRL_TYPE         ),
                   .RDEPTH    (ceil_log2t(RDEPTH)),
                   .WDEPTH    (ceil_log2t(WDEPTH))
                   )
                UI_ram_wrapper_1 (
                                .WDATA (DATA            ),
                                .WADDR (fifo_MEMWADDR   ),
                                .WEN   (fifo_MEMWE      ),
                                .REN   (fifo_MEMRE_int  ),
                                .RDATA (RDATA_int       ), 
                                .RADDR (ram_raddr       ),
                                .CLOCK (CLK             ),  
                                .WCLOCK(WCLOCK          ),  
                                .RCLOCK(RCLOCK          ),  
                                .RESET_N(RESET          )
                                );
     end
endgenerate

// v2.4 --- >
// The following changes are done for RTG4 Family only.
// When RESET_POLARITY = 1 (Active HIGH), the RAM memories must be applied
// constant '0' de-asserted state .
// When RESET_POLARITY = 0 (Active LOW), the RAM memories must be applied
// constant '1' de-asserted state.
   generate
     if (CTRL_TYPE != 1 && FAMILY == 25 && RESET_POLARITY == 1) begin

        ADCFIFO_ADCFIFO_0_ram_wrapper #(
                   .RWIDTH    (RWIDTH            ),
                   .WWIDTH    (WWIDTH            ),
                   .SYNC      (SYNC              ),
                   .PIPE      (PIPE              ),
                   .CTRL_TYPE (CTRL_TYPE         ),
                   .RDEPTH    (ceil_log2t(RDEPTH)),
                   .WDEPTH    (ceil_log2t(WDEPTH))
                   )
                UI_ram_wrapper_2 (
                                .WDATA (DATA            ),
                                .WADDR (fifo_MEMWADDR   ),
                                .WEN   (fifo_MEMWE      ),
                                .REN   (fifo_MEMRE_int  ),
                                .RDATA (RDATA_int       ), 
                                .RADDR (ram_raddr       ),
                                .CLOCK (CLK             ),  
                                .WCLOCK(WCLOCK          ),  
                                .RCLOCK(RCLOCK          ),  
                                .RESET_N(1'b0           )
                                );
     end
endgenerate

   generate
     if (CTRL_TYPE != 1 && FAMILY == 25 && RESET_POLARITY == 0) begin

        ADCFIFO_ADCFIFO_0_ram_wrapper #(
                   .RWIDTH    (RWIDTH            ),
                   .WWIDTH    (WWIDTH            ),
                   .SYNC      (SYNC              ),
                   .PIPE      (PIPE              ),
                   .CTRL_TYPE (CTRL_TYPE         ),
                   .RDEPTH    (ceil_log2t(RDEPTH)),
                   .WDEPTH    (ceil_log2t(WDEPTH))
                   )
                UI_ram_wrapper_3 (
                                .WDATA (DATA            ),
                                .WADDR (fifo_MEMWADDR   ),
                                .WEN   (fifo_MEMWE      ),
                                .REN   (fifo_MEMRE_int  ),
                                .RDATA (RDATA_int       ), 
                                .RADDR (ram_raddr       ),
                                .CLOCK (CLK             ),  
                                .WCLOCK(WCLOCK          ),  
                                .RCLOCK(RCLOCK          ),  
                                .RESET_N(1'b1           )
                                );
     end
endgenerate

// <---
endmodule // ADCFIFO_ADCFIFO_0_COREFIFO

   // --------------------------------------------------------------------------
   //                             End - of - Code
   // --------------------------------------------------------------------------
