// ********************************************************************/
// Microsemi Corporation Proprietary and Confidential
// Copyright 2014 Microsemi Corporation.  All rights reserved.
//
// ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
// ACCORDANCE WITH THE MICROSEMI LICENSE AGREEMENT AND MUST BE APPROVED
// IN ADVANCE IN WRITING.
//
//
// SPI Transmit/Receive control logic for channel
//
// SVN Revision Information:
// SVN $Revision: 28013 $
// SVN $Date: 2016-11-24 20:38:56 +0530 (Thu, 24 Nov 2016) $
//
// Resolved SARs
// SAR      Date     Who   Description
//
// Notes:
// -----
//
// ********************************************************************/


module spi_chanctrl # (
  parameter SPH              = 0,
  parameter SPO              = 0,
  parameter SPS              = 0,
  parameter CFG_MODE         = 0,
  parameter CFG_CLKRATE      = 7,
  parameter CFG_FRAME_SIZE   = 4,
  parameter CFG_FIFO_DEPTH   = 4,
  parameter SYNC_RESET       = 0
)
(
                       input         pclk,
                       input         presetn,
                       input         aresetn,
                       input         sresetn,
                       // SPI Interface
                       input         spi_clk_in,
                       output  reg   spi_clk_out,
                       input         spi_ssel_in,
                       output        spi_ssel_out,
                       input         spi_data_in,
                       output        spi_data_out,
                       output        spi_data_oen,

                       //FIFOs
                       input  [5:0]  txfifo_count,
                       input         txfifo_empty,
                       output        txfifo_read,
                       input [CFG_FRAME_SIZE-1:0]  txfifo_data,
                       input         txfifo_last,
                       input  [5:0]  rxfifo_count,
                       output        rxfifo_write,
                       output [CFG_FRAME_SIZE-1:0] rxfifo_data,
                       output        rxfifo_first,

                       //Configuration
                       input         cfg_enable,
                       input         cfg_master,
                       input         cfg_frameurun,
                       input         cfg_oenoff,
                       input  [2:0]  cfg_cmdsize,

                       //Status
                       output        tx_alldone,
                       output reg    rx_alldone,
                       output        tx_underrun,
                       output        rx_pktend,
                       output reg    rx_cmdsize,
                       output        active
                     );



localparam [3:0] MTX_IDLE1     = 4'd0;
localparam [3:0] MTX_IDLE2     = 4'd1;
localparam [3:0] MTX_MOTSTART  = 4'd2;
localparam [3:0] MTX_TISTART1  = 4'd3;
localparam [3:0] MTX_TISTART2  = 4'd4;
localparam [3:0] MTX_NSCSTART1 = 4'd5;
localparam [3:0] MTX_NSCSTART2 = 4'd6;
localparam [3:0] MTX_SHIFT1    = 4'd7;
localparam [3:0] MTX_SHIFT2    = 4'd8;
localparam [3:0] MTX_END       = 4'd9;

localparam       STXS_IDLE     = 1'b0;
localparam       STXS_SHIFT    = 1'b1;


//------------------------------------------------------------------------------------------------------
// Simple Stuff

localparam MOTMODE = ( CFG_MODE == 2'b00);
localparam TIMODE  = ( CFG_MODE == 2'b01);
localparam NSCMODE = ( CFG_MODE == 2'b10);
localparam MOTNOSSEL  = MOTMODE && ( SPH || SPS);
localparam NSCNOSSEL  = NSCMODE && !SPH;

localparam cfg_framesizeM1   = CFG_FRAME_SIZE - 1;

//######################################################################################################
// NEW BIT CONTROL ASSIGNMENTS
//  NSC SPH force idle cycle
//  NSC SPO free running clock
//  NSC SPS Concatenate
//  TI  SPH suppress SSEL
//  TI  SPO free running clock


//######################################################################################################
// Declarations


reg [15:0]  spi_clk_count;
reg         spi_clk_next;
reg         spi_clk_nextd;
reg         spi_clk_tick;

reg         cfg_enable_P1;
wire        cfg_enableON;


reg [4:0]   mtx_bitsel;
reg         mtx_fiforead;
reg [4:0]   mtx_bitcnt;
reg         mtx_ssel;
reg         mtx_lastframe;
reg         mtx_consecutive;
reg [2:0]   mtx_datahold;
reg         mtx_oen;
reg         mtx_spi_data_out;
reg         mtx_spi_data_oen;
reg         mtx_busy;
reg         mtx_rxbusy;
reg         mtx_holdsel;
reg         mtx_first;
reg         mtx_pktsel;
reg         mtx_lastbit;
reg         mtx_firstrx;
reg         mtx_midbit;
reg         mtx_alldone;

reg         mtx_re;
reg         mtx_re_q1;
reg         mtx_re_q2;
wire        mtx_re_d = mtx_re_q1 && !mtx_re_q2;

reg         msrxs_strobe;
reg [CFG_FRAME_SIZE-2:0]  msrxs_shiftreg;
reg [CFG_FRAME_SIZE-1:0]  msrxs_datain;
wire        msrxs_pktsel;
reg         msrxs_ssel;
reg         msrxp_strobe;
reg [5:0]   msrxp_frames;
reg         msrxs_first;
reg         msrxp_pktend;
reg         msrxp_alldone;

reg         SYNC1_msrxp_strobe;
reg         SYNC2_msrxp_strobe;
reg         SYNC3_msrxp_strobe;
reg         SYNC1_msrxp_pktsel;
reg         SYNC2_msrxp_pktsel;
reg         SYNC3_msrxp_pktsel;


wire        cfg_clk_idle1;
wire        cfg_clk_idle2;
wire        cfg_clk_ph1;
wire        cfg_clk_ph2;
wire        cfg_clk_cap;
wire        cfg_clk_end1;

wire        clock_rx;
wire        resetn_rx;
wire        resetn_tx;

// Sync/Async reset signals
wire        aresetn_tx;        
wire        sresetn_tx;

reg         stxs_strobetx;
reg         stxs_midbit;
reg         stxs_direct;
reg [CFG_FRAME_SIZE-1:0]  stxs_datareg;
reg [4:0]   stxs_bitsel;
reg [4:0]   stxs_bitcnt;
wire        stxp_fiforead;
reg         stxs_dataerr;
reg         stxs_checkorun;
reg         stxs_oen;
reg         stxs_spi_data_out;
reg         stxs_spi_data_oen;
wire        stxp_strobe;
wire        stxp_underrun;
reg         stxp_lastframe;
reg         stxs_txzeros;
reg         stxs_first;
reg         stxs_pktsel;
wire        stxs_txready;
reg         stxs_txready_at_ssel;
reg         stxs_lastbit;


reg         txfifo_davailable;
reg         SYNC1_stxp_strobetx;
reg         SYNC1_stxp_dataerr;
reg         SYNC2_stxp_strobetx;
reg         SYNC2_stxp_dataerr;
reg         SYNC3_stxp_strobetx;
reg         SYNC3_stxp_dataerr;
reg         SYNC1_stxs_txready;

wire        stxs_txready_re = txfifo_davailable && !SYNC1_stxs_txready;

reg         spi_ssel_pos;
reg         spi_ssel_neg;

reg [CFG_FRAME_SIZE-1:0]  txfifo_datadelay;


wire [CFG_FRAME_SIZE-1:0] txfifo_dhold;
wire        busy;

reg         msrx_async_reset_ok;
reg         stx_async_reset_ok;

reg [3:0]   mtx_state;
reg         stxs_state;

wire cfg_slave = ~cfg_master;

reg         clock_rx_q1;
reg         clock_rx_q2;
reg         clock_rx_q3;
reg         data_rx_q1;
reg         data_rx_q2;
reg         ssel_rx_q1;
reg         ssel_rx_q2;

wire spi_ssel_mux = ( cfg_master ? spi_ssel_out : ssel_rx_q2);

wire spi_di_mux = (cfg_master ? spi_data_in : data_rx_q2); 

wire clock_rx_re_slave = clock_rx_q2 && !clock_rx_q3;
wire clock_rx_re       = (cfg_master ? mtx_re_d : clock_rx_re_slave);
wire clock_rx_fe       = !clock_rx_q2 &&  clock_rx_q3;

//######################################################################################################
// Clock Generation

always@ *
begin
  if (spi_clk_count[7:0] ==  CFG_CLKRATE)
  begin
    spi_clk_nextd =  (!spi_clk_next);
  end
  else
  begin
    spi_clk_nextd =  spi_clk_next;
  end
end

always @(posedge pclk or negedge aresetn)
   begin
   if ((!aresetn) || (!sresetn))
      begin
        spi_clk_count      <= 16'b0;
        spi_clk_next       <= 1'b0;
        spi_clk_tick       <= 1'b0;
      end
   else
      begin
        //Not in Use
        if ( !(cfg_enable && cfg_master))
        begin
            spi_clk_tick  <= 1'b0;
            spi_clk_count <= 16'b0;
        end
        else
        begin
          if (spi_clk_count[7:0] ==  CFG_CLKRATE)
          begin
            spi_clk_count <= 16'b0;
          end
          else
          begin
            // Default inc count
            spi_clk_count <= spi_clk_count + 1;
          end

          // Edge Detects
          spi_clk_next    <= spi_clk_nextd;
          spi_clk_tick    <= spi_clk_nextd  ^ spi_clk_next;
        end
      end
   end


//######################################################################################################
// Support features in both modes

always @(posedge pclk or negedge aresetn)
 begin
   if ((!aresetn) || (!sresetn))
      begin
        cfg_enable_P1 <= 1'b0;
      end
   else
      begin
        cfg_enable_P1 <= cfg_enable;
      end
 end

assign cfg_enableON = cfg_enable && cfg_enable_P1;   // delayed assertion of enable, to gate critical stuff


always @(posedge pclk or negedge aresetn)
 begin
   if ((!aresetn) || (!sresetn))
      begin
        mtx_re_q1 <= 1'b0;
        mtx_re_q2 <= 1'b0;
      end
   else
      begin
		mtx_re_q1 <= mtx_re;
		mtx_re_q2 <= mtx_re_q1;
	  end
 end


//######################################################################################################
// Master Transmit Engine  runs of PCLK, max rate is PCLK/2


generate
    if(CFG_MODE == 0)  // MOTMODE
      begin: mode_0
        assign cfg_clk_end1  = SPO;
        assign cfg_clk_idle1 = SPO;
        assign cfg_clk_idle2 = SPO;
        assign cfg_clk_ph1   = SPO ^ SPH;
        assign cfg_clk_ph2   = !(SPO ^ SPH);
        assign cfg_clk_cap   = SPO ^ SPH;
      end
    else if(CFG_MODE == 1)  // TIMODE
      begin: mode_1
        assign cfg_clk_end1  = 1'b1;
        assign cfg_clk_idle1 = SPO;
        assign cfg_clk_idle2 = 1'b0;
        assign cfg_clk_ph1   = 1'b1;
        assign cfg_clk_ph2   = 1'b0;
        assign cfg_clk_cap   = 1'b1;
      end
    else if(CFG_MODE == 2)  // NSCMODE
      begin: mode_2
        assign cfg_clk_end1  = 1'b0;
        assign cfg_clk_idle1 = 1'b0;
        assign cfg_clk_idle2 = SPO;
        assign cfg_clk_ph1   = 1'b0;
        assign cfg_clk_ph2   = 1'b1;
        assign cfg_clk_cap   = 1'b0;
      end
    else
      begin: mode_default   // invalid!
        assign cfg_clk_end1  = 1'b0;
        assign cfg_clk_idle1 = 1'b0;
        assign cfg_clk_idle2 = 1'b0;
        assign cfg_clk_ph1   = 1'b0;
        assign cfg_clk_ph2   = 1'b0;
        assign cfg_clk_cap   = 1'b0;
      end
endgenerate

always @(posedge pclk or negedge aresetn)
 begin
   if ((!aresetn) || (!sresetn))
    begin
      mtx_bitsel       <= cfg_framesizeM1;
      mtx_state        <= MTX_IDLE1;
      mtx_bitcnt       <= 5'b00000;
      mtx_fiforead     <= 1'b0;
      mtx_lastframe    <= 1'b0;
      mtx_consecutive  <= 1'b0;
      mtx_datahold     <= 3'b000;
      mtx_oen          <= 1'b0;
      mtx_busy         <= 1'b0;
      mtx_rxbusy       <= 1'b0;
      mtx_holdsel      <= 1'b0;
      mtx_ssel         <= 1'b0;
      mtx_first        <= 1'b1;
      mtx_pktsel       <= 1'b0;
      mtx_alldone      <= 1'b0;
      mtx_re           <= 1'b0;
    end
    else
    begin
      //------------------------------------------------------
      //This runs every clock
      mtx_fiforead  <= 1'b0;
      mtx_alldone   <= 1'b0;
      mtx_re        <= 1'b0;

      //------------------------------------------------------
      //Master Disabled so hold key signals inactive
      if (!cfg_master || !cfg_enable)
       begin
         mtx_state  <= MTX_IDLE1;
         mtx_pktsel <= 1'b0;
         mtx_first  <= 1'b0;
       end
      //-----------------------------------------------------
      //This runs at SPICLK rising and falling edges
      // FSM has two phases aligned with data
      //  Phase 1: first clock cycle that data is valid
      //  Phase 2: second clock cycle that data is valid
      //-----------------------------------------------------
      else if (spi_clk_tick)
       begin
         mtx_ssel <= 1'b0;
         case (mtx_state)
          MTX_IDLE1,MTX_IDLE2:
                        begin
                            // state assign
                            if (mtx_state==MTX_IDLE1) mtx_state <= MTX_IDLE2;
                            else mtx_state <= MTX_IDLE1;

                            if (!txfifo_empty && cfg_master && cfg_enableON)            // AS: removed autostall check
                            begin
                              mtx_bitsel   <= cfg_framesizeM1;
                              mtx_bitcnt   <= 5'b00000;
                              mtx_pktsel   <= 1'b1;
                              mtx_first    <= !mtx_holdsel;
                                case (CFG_MODE)
                                  0   : mtx_state <= MTX_MOTSTART;
                                  1   : if (mtx_state==MTX_IDLE2)  mtx_state <= MTX_TISTART1;     // make sure stays aligned
                                  2   : if (mtx_state==MTX_IDLE2)  mtx_state <= MTX_NSCSTART1;
                                  default : begin end
                                endcase
                            end
                            else
                             begin
                               mtx_oen <= 1'b0;
                               if (mtx_state==MTX_IDLE1) mtx_busy <= 1'b0;                         // hold busy until we get to IDLE1
                               if ((mtx_state==MTX_IDLE1) && (mtx_busy==1'b0)) mtx_rxbusy <= 1'b0; // Allows time for RX activity to complete
                               mtx_pktsel <= mtx_holdsel;
                               mtx_first  <= !mtx_holdsel;
                             end
                        end
          MTX_MOTSTART: begin
                          mtx_state  <= MTX_SHIFT1;
                          mtx_oen    <= 1'b1;
                          mtx_busy   <= 1'b1;
                          mtx_rxbusy <= 1'b1;
                        end
          MTX_TISTART1: begin
                          mtx_state  <= MTX_TISTART2;
                          mtx_oen    <= 1'b1;
                          mtx_rxbusy <= 1'b1;
                          mtx_busy   <= 1'b1;
                        end
          MTX_TISTART2: begin
                          mtx_state  <= MTX_SHIFT1;
                          mtx_ssel   <= 1'b0;
                        end
          MTX_NSCSTART1:begin
                          mtx_state  <= MTX_NSCSTART2;
                          mtx_oen    <= 1'b1;
                          mtx_busy   <= 1'b1;
                          mtx_rxbusy <= 1'b1;
                        end
          MTX_NSCSTART2:begin
                          mtx_state <= MTX_SHIFT1;
                        end
          MTX_SHIFT1 :  begin
                         mtx_state  <= MTX_SHIFT2;
                         mtx_ssel   <= mtx_ssel;
						 mtx_re     <= 1'b1;
                         case (mtx_bitsel)
                           3: begin
                                mtx_datahold  <= txfifo_data[2:0];        // Hold data for last bits
                              end
                           2: begin
                                mtx_fiforead  <= 1'b1;                    // Advance read, since we are here not empty
                                mtx_lastframe <= txfifo_last;
                              end
                           1: begin

                                if (!txfifo_empty && !mtx_lastframe )      // more data - get ready to do back to back
                                  begin
                                    mtx_consecutive <= 1'b1;
                                  end
                                 else
                                  begin
                                    mtx_consecutive <= 1'b0;
                                  end
                              end

                           default:
                              begin
                                 // Simply decrement the count until zero
                              end
                         endcase
                       end
          MTX_SHIFT2 : begin
                          // if set at shift 1 hold value
                          mtx_ssel    <= mtx_ssel;
                          mtx_state   <= MTX_SHIFT1;
                          // AS: added condition to avoid wraparound
                          if (mtx_bitsel == 5'b00000)
                            mtx_bitsel <= cfg_framesizeM1;
                          else
                          begin
                            mtx_bitsel  <= mtx_bitsel -1;
                          end
                          mtx_bitcnt  <= mtx_bitcnt +1;
                          mtx_oen     <= 1'b1;
                          mtx_holdsel <= 1'b0;

                          if (NSCMODE && (mtx_bitcnt[3] || mtx_bitcnt[4] )) mtx_oen <= 1'b0;

                          case (mtx_bitsel)
                           1: begin
                                if (mtx_consecutive && TIMODE) mtx_ssel <= !SPH;
                              end
                           0: begin
                                mtx_ssel      <= 1'b0;
                                mtx_first     <= 1'b0;
                                if (mtx_lastframe)
                                   begin  // last frame so go through IDLE to END state
                                     mtx_state   <= MTX_END;
                                     mtx_oen     <= 1'b0;    //not continuous so remove OEN
                                     mtx_alldone <= 1'b1;
                                   end
                                else
                                   begin
                                     if (mtx_consecutive)
                                       begin  // Next data was available so lets output it
                                         mtx_consecutive <= 1'b0;
                                         if ((TIMODE) || (MOTNOSSEL) || (NSCNOSSEL))
                                           begin   // back to back frames
					     if (NSCMODE && !SPH && !SPS)
					      begin
						 mtx_oen <= 1'b1;
					      end
                                             mtx_bitsel <= cfg_framesizeM1;
                                             mtx_state  <= MTX_SHIFT1;
                                             mtx_bitcnt <= 5'b00000;
                                             if (SPS && NSCMODE)
                                              begin // Restart at receive phase
                                                 mtx_bitsel <= cfg_framesizeM1-9;
                                                 mtx_bitcnt <= 5'b01000;
                                              end
                                           end
                                         else
                                           begin   // go through SSEL must be in MOT/NSC mode
                                             mtx_state  <= MTX_END;
                                             mtx_oen    <= MOTMODE;                   //make sure OEN stays on in MOT
                                           end
                                       end
                                     else  //data was not ready do go back to IDLE  through END
                                       begin
                                         mtx_state   <= MTX_END;
                                         mtx_oen     <= 1'b0;      // turn off OEN as we dont have data
                                         mtx_holdsel <= MOTMODE && SPS;  // see whether need to hold SSEL
                                       end
                                   end
                              end
                           endcase
                        end
          MTX_END    : begin
                         mtx_state   <= MTX_IDLE2;        // Got to IDLE2 so TI/NSC mode alignment occurs
                         mtx_pktsel  <= mtx_holdsel;      // unless we are holding SSEL must be end of packet
                       end
          default:     begin
                         mtx_state <= MTX_IDLE1;
                       end
          endcase
       end
    end
 end

//-----------------------------------------------------------------------------------------------------
// Based on the STATE value drive out the signals 1 PCLK cycle later
//

assign txfifo_dhold =  {txfifo_data[CFG_FRAME_SIZE-1:3] , mtx_datahold };

always @(posedge pclk or negedge aresetn)
 begin
   if ((!aresetn) || (!sresetn))
    begin
      spi_clk_out      <= cfg_clk_idle1;
      spi_ssel_pos     <= 1'b1;
      mtx_spi_data_oen <= 1'b0;
      mtx_spi_data_out <= 1'b0;
      mtx_lastbit      <= 1'b0;
      mtx_firstrx      <= 1'b0;
      mtx_midbit       <= 1'b0;
    end
   else
    begin
       // Control Lines
       case (mtx_state)
        MTX_IDLE1   : begin
                        spi_clk_out      <= cfg_clk_idle1;
                        spi_ssel_pos     <= !(TIMODE || mtx_holdsel);
                        mtx_spi_data_oen <= mtx_oen;
                      end
        MTX_IDLE2   : begin
                        spi_clk_out      <= cfg_clk_idle2;
                        spi_ssel_pos     <= !(TIMODE || mtx_holdsel);
                        mtx_spi_data_oen <= mtx_oen;
                      end
        MTX_MOTSTART :begin
                        spi_clk_out      <= cfg_clk_idle1;
                        spi_ssel_pos     <= 1'b0;
                        mtx_spi_data_oen <= 1'b0;
                      end
        MTX_TISTART1: begin
                        spi_clk_out      <= cfg_clk_ph1;
                        spi_ssel_pos     <= 1'b1;
                        mtx_spi_data_oen <= 1'b0;
                      end
        MTX_TISTART2: begin
                        spi_clk_out      <= cfg_clk_ph2;
                        spi_ssel_pos     <= 1'b1;
                        mtx_spi_data_oen <= 1'b1;
                      end
        MTX_NSCSTART1:begin
                        spi_clk_out      <= cfg_clk_ph1;
                        spi_ssel_pos     <= 1'b1;
                        mtx_spi_data_oen <= 1'b0;
                      end
        MTX_NSCSTART2:begin
                        spi_clk_out      <= cfg_clk_ph2;
                        spi_ssel_pos     <= 1'b0;
                        mtx_spi_data_oen <= 1'b1;
                      end
        MTX_SHIFT1  : begin
                        spi_clk_out      <= cfg_clk_ph1;
                        spi_ssel_pos     <= (TIMODE && mtx_ssel);
                        mtx_spi_data_oen <= 1'b1 && mtx_oen;
                      end
        MTX_SHIFT2  : begin
                        spi_clk_out      <= cfg_clk_ph2;
                        spi_ssel_pos     <= (TIMODE && mtx_ssel);
                        mtx_spi_data_oen <= 1'b1 && mtx_oen;
                      end
        MTX_END     : begin
                        spi_clk_out      <= cfg_clk_end1;
                        spi_ssel_pos     <= 1'b0;
                        mtx_spi_data_oen <= MOTMODE || TIMODE;   // should be held on here
                      end
        default :     begin //Unused states
                        spi_clk_out      <= 1'b0;
                        spi_ssel_pos     <= 1'b0;
                        mtx_spi_data_oen <= 1'b0;
                      end
       endcase

       // Data Lines
       mtx_spi_data_out <= txfifo_dhold[mtx_bitsel] ;
       if (NSCMODE && (mtx_bitcnt[4] || mtx_bitcnt[3]) ) mtx_spi_data_out <= 1'b0;

       // RX capture
       mtx_lastbit <= (mtx_bitsel == 5'b00000);  // Used to assert RX strobe
       mtx_midbit  <= (mtx_bitsel == 5'b00010);  // Used to deassert RX strobe
       mtx_firstrx <= mtx_first;


  end
 end

assign tx_alldone = mtx_alldone || (cfg_slave && msrxp_alldone);


always @(negedge pclk or negedge aresetn)
 begin
   if ((!aresetn) || (!sresetn))
    begin
      spi_ssel_neg <= 1'b1;
    end
   else
    begin
      spi_ssel_neg <= spi_ssel_pos;
    end
 end

assign  spi_ssel_out = (NSCMODE ? spi_ssel_neg :  spi_ssel_pos);

always @(posedge pclk or negedge aresetn)
 begin
   if ((!aresetn) || (!sresetn))
    begin
       SYNC1_stxs_txready <= 1'b0;
    end
   else
    begin
       SYNC1_stxs_txready <= txfifo_davailable;
   end
 end

assign stxs_txready = txfifo_davailable;

// Handle case that no initial shift clock
// This is clocks as SEL is released
always @(posedge resetn_rx)
 begin
   stxs_txready_at_ssel <= txfifo_davailable;
 end


// The FSM  only needed in slaves
//always @(negedge clock_rx or negedge resetn_tx)
always @(posedge pclk or negedge aresetn_tx)
 begin
  if ((!aresetn_tx) || (!sresetn_tx))
   begin
      stxs_state      <= STXS_IDLE;
      stxs_strobetx   <= 1'b0;
      stxs_midbit     <= 1'b0;
      stxs_direct     <= 1'b1;
      stxs_datareg    <= {(CFG_FRAME_SIZE-1){1'b0}};
      stxs_bitsel     <= 5'b00000;
      stxs_bitcnt     <= 5'b00000;
      stxs_dataerr    <= 1'b0;
      stxs_checkorun  <= 1'b0;
      stxs_oen        <= 1'b0;
      stxs_first      <= 1'b0;
      stxs_txzeros    <= 1'b0;
      stxs_pktsel     <= 1'b0;
      stxs_lastbit    <= 1'b0;
   end
  else
   begin
	if (stxs_txready_re && (stxs_bitcnt == 5'b00000)) // data now available in tx FIFO and still on first bit
	begin
		stxs_datareg   <= txfifo_data[CFG_FRAME_SIZE-1:0]; // reload with valid data
	end
    if (clock_rx_fe)
    begin
      stxs_strobetx  <= 1'b0;
      stxs_midbit    <= 1'b0;
      stxs_lastbit   <= 1'b0;
      case (stxs_state)
         STXS_IDLE:
           begin
             stxs_bitcnt    <= 5'b00000;
             stxs_datareg   <= {txfifo_datadelay[CFG_FRAME_SIZE-2:0] , 1'b0};         //Sample the Data, check ready flag in two clocks time
             stxs_dataerr   <= 1'b0;
             stxs_checkorun <= !cfg_frameurun;                          
             stxs_dataerr   <= 1'b0;
             stxs_first     <= 1'b1;
             stxs_txzeros   <= 1'b0;
             stxs_direct    <= 1'b1;  //  !NSCMODE;
             stxs_oen       <= TIMODE && msrxs_ssel;
             if ((cfg_slave && cfg_enableON && ( MOTMODE || NSCMODE ||  (TIMODE && msrxs_ssel==1'b1))))
               begin //About to transmit, but not sure until we see next clock edge
                  stxs_state   <= STXS_SHIFT;
                  stxs_bitsel  <= cfg_framesizeM1;
                  stxs_oen     <= !NSCMODE;
                  stxs_pktsel  <= 1'b1;
                  if (MOTMODE && !SPH)   // no initial shift edge
                    begin
                      stxs_bitsel  <= cfg_framesizeM1-1;
                      stxs_bitcnt  <= 5'b00001;
                      stxs_direct  <= 1'b0;
                    end
               end
           end
         STXS_SHIFT:
           begin
             stxs_bitcnt  <= stxs_bitcnt +1;
             stxs_bitsel  <= stxs_bitsel -1;
             if (!stxs_direct) stxs_datareg <= {stxs_datareg, 1'b0};     // Shift
             stxs_direct  <= 1'b0;
             //----------------------------------------------------------------------
             case (stxs_bitcnt)
               1 : begin                    // At this point we can see whether we actually sampled valid data from the FIFO
                     stxs_midbit  <= 1'b1;  // clear the RX strobe, stays in S clock domain
					   // If no initial shift then we need to check value at SSEL going inactive
                       if (       ( (MOTMODE && SPH==1'b0 && stxs_first) && stxs_txready_at_ssel && !stxs_dataerr )
                               || (!(MOTMODE && SPH==1'b0 && stxs_first) && stxs_txready && !stxs_dataerr)  ) // Got good data and not failed before
                       begin
                         stxs_strobetx  <= 1'b1;
                         stxs_checkorun <= 1'b1;              // Check for overrun from now on
                       end
                     else
                       begin                               // Data was not available, see if checking report
                         stxs_dataerr <= stxs_checkorun;
                         stxs_txzeros <= 1'b1;
                       end
                   end
               2 : begin
                    stxs_strobetx <= stxs_strobetx;      // if asserted hold strobe for second cycle
                   end
               7: begin
                   stxs_oen <= 1'b1; //Turn on OEN slave TXT in NSC mode, on in other modes anyway
                  end
             endcase
             //-----------------------------------------------------------------------


             case (stxs_bitsel)
                1: begin
                    stxs_lastbit <= 1'b1;
                   end
                0: begin
                     stxs_oen    <= !NSCMODE;
                     stxs_first  <= 1'b0;
                     stxs_direct <= 1'b1;
                     stxs_oen    <= 1'b0;
                     if (  (TIMODE && msrxs_ssel==1'b1)                 // If TI Mode and SSEL start again
                         || (MOTMODE)                                  // Start again unless reset
                         || (NSCMODE)                                  // Start again unless reset
                        )
                       begin // CLOCK EDGE OF NEXT FRAME TRANSMIT AGAIN
                         stxs_bitsel    <= cfg_framesizeM1;
                         stxs_bitcnt    <= 5'b00000;
                         stxs_direct    <= 1'b0;
                         stxs_datareg   <= txfifo_data[CFG_FRAME_SIZE-1:0];           //Next frame, This time no need for direct operation
                         stxs_oen       <= TIMODE && msrxs_ssel;
                         stxs_pktsel    <= 1'b1;
                       end
                     else
                       begin
                         stxs_pktsel <= 1'b0;
                         stxs_state  <= STXS_IDLE;
                         stxs_oen    <= 1'b0;
                       end
                   end
                default:
                   begin
                   end
             endcase
           end
      endcase
    end
   end
 end

// Work out that to output
always @(*)
 begin
    if (stxs_txzeros)     stxs_spi_data_out = 1'b0;
    else if (stxs_direct) stxs_spi_data_out = txfifo_datadelay[cfg_framesizeM1];
    else                  stxs_spi_data_out = stxs_datareg[cfg_framesizeM1];

    //OEN is little complicated
    case (CFG_MODE)
      0 : begin //MOT
                stxs_spi_data_oen = !ssel_rx_q2;
              end
      1 : begin //TI
                stxs_spi_data_oen = stxs_oen;
              end
      2 : begin //NSC
                stxs_spi_data_oen = (!ssel_rx_q2 && stxs_oen);
              end
      default :
              begin
                stxs_spi_data_oen = 1'bx;
              end
    endcase
    if (!cfg_slave || !cfg_enableON) stxs_spi_data_oen = 1'b0;

 end



// SYNC the Strobes back to PCLK
always @(posedge pclk or negedge aresetn)
 begin
   if ((!aresetn) || (!sresetn))
    begin
       SYNC1_stxp_strobetx   <= 1'b0;
       SYNC1_stxp_dataerr    <= 1'b0;
       SYNC2_stxp_strobetx   <= 1'b0;
       SYNC2_stxp_dataerr    <= 1'b0;
       SYNC3_stxp_strobetx   <= 1'b0;
       SYNC3_stxp_dataerr    <= 1'b0;
    end
   else
    begin
       SYNC1_stxp_strobetx   <= stxs_strobetx;
       SYNC1_stxp_dataerr    <= stxs_dataerr;
       SYNC2_stxp_strobetx   <= SYNC1_stxp_strobetx;
       SYNC2_stxp_dataerr    <= SYNC1_stxp_dataerr;
       SYNC3_stxp_strobetx   <= SYNC2_stxp_strobetx;
       SYNC3_stxp_dataerr    <= SYNC2_stxp_dataerr;
    end
 end


assign stxp_strobe   =  SYNC2_stxp_strobetx && ~SYNC3_stxp_strobetx;
assign stxp_fiforead =  stxp_strobe;
assign stxp_underrun =  SYNC2_stxp_dataerr && ~SYNC3_stxp_dataerr;



// The HW Status Register is effectivly sampled at the start of a transfer
// The SPICLK domain will sample after this time
// The TXDATA is also delayed by a clock cycle to make sure its on Q of register, FIFO's have muxes on outputs


always @(posedge pclk or negedge aresetn)
 begin
   if ((!aresetn) || (!sresetn))
    begin
       txfifo_davailable <= 1'b0;
       txfifo_datadelay  <= {CFG_FRAME_SIZE{1'b0}};
       stxp_lastframe    <= 1'b0;
    end
   else
    begin
       txfifo_davailable <= !txfifo_empty;
       txfifo_datadelay  <= txfifo_data;
       if (stxp_strobe) stxp_lastframe <= txfifo_last;      //remember that we are doing last bit
	   if (!cfg_slave)  stxp_lastframe <= 1'b0;				//make sure off in if not in slave mode
    end
 end


//######################################################################################################
// Select Outputs based on mode

assign  txfifo_read  = ( cfg_master ? mtx_fiforead : stxp_fiforead);


assign  spi_data_out = ( cfg_slave ? stxs_spi_data_out :  mtx_spi_data_out);
wire    spi_data_oex = ( cfg_slave ? stxs_spi_data_oen :  mtx_spi_data_oen);
assign  spi_data_oen = spi_data_oex && !cfg_oenoff;


assign  busy        = (mtx_busy || mtx_rxbusy || (stxs_state != STXS_IDLE) || (cfg_master && !txfifo_empty) );
assign  active      = busy;
assign  tx_underrun = stxp_underrun;


//######################################################################################################
//Receive logic

//Reduce the combinational logic clock driving the ASYNC resets

always @(posedge pclk or negedge aresetn)
 begin
   if ((!aresetn) || (!sresetn))
   begin
      msrx_async_reset_ok <= 1'b0;
      stx_async_reset_ok <= 1'b0;
   end
   else
   begin
      msrx_async_reset_ok <= cfg_enable && !TIMODE;
       stx_async_reset_ok <= cfg_enable && !TIMODE && cfg_slave;
   end
end

assign resetn_rx = ~(!presetn || (spi_ssel_mux && msrx_async_reset_ok) );
assign resetn_tx = ~(!presetn || (ssel_rx_q2  && stx_async_reset_ok)) ;

assign aresetn_tx = (SYNC_RESET == 1) ? 1'b1 : resetn_tx;
assign sresetn_tx = (SYNC_RESET == 1) ? resetn_tx : 1'b1;

//Instantiate the clock mux for synthesis etc

spi_clockmux UCLKMUX1 (
                   .sel     (cfg_master),
                   .clka    (spi_clk_in),
                   .clkb    (spi_clk_out),
                   .clkout  (clock_rx_mux1)
                  );

wire  clock_rx_mux2 = (cfg_clk_cap ^ clock_rx_mux1);		// Clock inversion when needed


assign clock_rx = clock_rx_mux2;

//-------------------------------------------------------------------------
always @(posedge pclk or negedge aresetn)
begin
    if ((!aresetn) || (!sresetn))
    begin
        clock_rx_q1 <= 1'b0;
        clock_rx_q2 <= 1'b0;
        clock_rx_q3 <= 1'b0;

        data_rx_q1 <= 1'b0;
        data_rx_q2 <= 1'b0;

        ssel_rx_q1 <= 1'b0;
        ssel_rx_q2 <= 1'b0;
	end
    else
    begin
        clock_rx_q1 <= clock_rx;
        clock_rx_q2 <= clock_rx_q1;
        clock_rx_q3 <= clock_rx_q2;
		
        data_rx_q1 <= spi_data_in;
        data_rx_q2 <= data_rx_q1;
		
        ssel_rx_q1 <= spi_ssel_in;
        ssel_rx_q2 <= ssel_rx_q1;
    end
end

//-------------------------------------------------------------------------

// The msrxs_datain register must not be reset by the next frame select,

always @(posedge pclk or negedge aresetn)
begin
  if ((!aresetn) || (!sresetn))
    begin
      msrxs_strobe    <= 1'b0;
      msrxs_datain    <= {(CFG_FRAME_SIZE){1'b0}};
      msrxs_shiftreg  <= {(CFG_FRAME_SIZE-1){1'b0}};
      msrxs_first     <= 1'b0;
      msrxs_ssel      <= 1'b0;
    end
  else
    begin
    if (clock_rx_re)
    begin
       msrxs_ssel      <= ssel_rx_q2 & cfg_enableON;
	   msrxs_shiftreg  <=  { msrxs_shiftreg[CFG_FRAME_SIZE-3:0], spi_di_mux};//spi_di_mux};
       if (stxs_midbit || mtx_midbit )  msrxs_strobe <= 1'b0;
       if (TIMODE && spi_ssel_mux) msrxs_shiftreg  <= 31'b00000; 	 // Start of Cycle clear shift reg, no data at SSEL
       if (stxs_lastbit ||  mtx_lastbit )
         begin
            msrxs_first     <= mtx_firstrx || (cfg_slave && stxs_first);
            msrxs_shiftreg  <= {(CFG_FRAME_SIZE-1){1'b0}};
            msrxs_datain    <= { msrxs_shiftreg[CFG_FRAME_SIZE-2:0], spi_di_mux};
            msrxs_strobe    <= 1'b1;
         end
    end
    end
end

// Note mrsx_ssel samples ssel for TI mode at the -ve clock edge for the stx FSM to use on +ve clock edge

// msrxs_strobe pulse high every frame whether good or bad!

assign msrxs_pktsel = stxs_pktsel || mtx_pktsel;

// Data is held valid accross FIFO write pulse by design
assign rxfifo_data   = msrxs_datain;
assign rxfifo_first  = msrxs_first;

// SYNC the Strobe back to PCLK  and write to FIFO
// Used in both master and slave modes to write data to FIFO

always @(posedge pclk or negedge aresetn)
 begin
   if ((!aresetn) || (!sresetn))
    begin
      SYNC1_msrxp_strobe <= 1'b1;
      SYNC2_msrxp_strobe <= 1'b1;
      SYNC3_msrxp_strobe <= 1'b1;
      SYNC1_msrxp_pktsel <= 1'b0;
      SYNC2_msrxp_pktsel <= 1'b0;
      SYNC3_msrxp_pktsel <= 1'b0;
    end
   else
    begin
      SYNC1_msrxp_strobe <= msrxs_strobe;
      SYNC2_msrxp_strobe <= SYNC1_msrxp_strobe;
      SYNC3_msrxp_strobe <= SYNC2_msrxp_strobe;
      SYNC1_msrxp_pktsel <= msrxs_pktsel;
      SYNC2_msrxp_pktsel <= SYNC1_msrxp_pktsel;
      SYNC3_msrxp_pktsel <= SYNC2_msrxp_pktsel;
    end
end

always @(posedge pclk or negedge aresetn)
 begin
   if ((!aresetn) || (!sresetn))
    begin
      msrxp_strobe    <= 1'b0;
      msrxp_pktend    <= 1'b0;
      msrxp_alldone	  <= 1'b0;
      rx_alldone      <= 1'b0;
    end
   else
    begin
      msrxp_strobe  <= 1'b0;
      msrxp_pktend  <= 1'b0;
      msrxp_alldone <= 1'b0;
      if ( SYNC2_msrxp_strobe && ~SYNC3_msrxp_strobe )
       begin
              msrxp_strobe  <= 1'b1;
              msrxp_alldone <= mtx_lastframe || stxp_lastframe;    // consistent with write strobe
       end

      if  (~SYNC2_msrxp_pktsel && SYNC3_msrxp_pktsel)       //
       begin
            msrxp_pktend <= 1'b1;
       end

       rx_alldone <=  msrxp_alldone ;   // let write to FIFO complete before setting done

    end
end

assign rxfifo_write =  msrxp_strobe;
wire   msrxp_pktsel =  SYNC2_msrxp_pktsel;


//######################################################################################################
// FIFO Level Checkers

reg [2:0] tmp;
always@*
begin
  tmp = msrxp_frames+1;
end


always @(posedge pclk or negedge aresetn)  // Register as this feeds into lots of logic
begin
  if ((!aresetn) || (!sresetn))
  begin
    msrxp_frames <= 6'b000000;
    rx_cmdsize   <= 1'b0;
  end
  else
  begin
    rx_cmdsize   <= 1'b0;
    if (msrxp_pktsel==1'b0)
    begin
      msrxp_frames <= 6'b00000;
    end
    else if (msrxp_strobe)
    begin
      msrxp_frames <= {3'b000, tmp};
      rx_cmdsize   <= (tmp == cfg_cmdsize);
    end
  end
end


assign  rx_pktend  = msrxp_pktend;

endmodule
