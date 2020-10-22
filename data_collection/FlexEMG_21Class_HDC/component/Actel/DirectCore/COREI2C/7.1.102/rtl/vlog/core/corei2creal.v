// ********************************************************************/ 
// Microsemi Corporation Proprietary and Confidential
// Copyright 2014 Microsemi Corporation.  All rights reserved.
//
// ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN 
// ACCORDANCE WITH THE MICROSEMI LICENSE AGREEMENT AND MUST BE APPROVED 
// IN ADVANCE IN WRITING.  
//  
// Project name         : CoreI2C
// Project description  : Inter-Integrated Circuit Bus Interface (I2C)
//
// File name            : corei2creal.v
// File contents        : Module CoreI2C
// Purpose              : CoreI2C Serial Channel
//
// Destination library  : COREI2C_LIB
//
// SVN Revision Information:
// SVN $Revision: 24155 $
// SVN $Date: 2014-12-24 18:18:17 +0000 (Wed, 24 Dec 2014) $
//
//---------------------------------------------------------------------

`timescale 1 ns / 1 ns // timescale for following modules

module COREI2CREAL #(
parameter FAMILY         			=17,
parameter OPERATING_MODE 			=0,
parameter BAUD_RATE_FIXED			=0,
parameter BAUD_RATE_VALUE			=3'b000,
parameter BCLK_ENABLED				=1,
parameter GLITCHREG_NUM				=3,
parameter SMB_EN         			=0,
parameter IPMI_EN					=1,
parameter FREQUENCY      			=30,
parameter FIXED_SLAVE0_ADDR_EN		=0,
parameter FIXED_SLAVE0_ADDR_VALUE	=8'h00,
parameter ADD_SLAVE1_ADDRESS_EN		=1,
parameter FIXED_SLAVE1_ADDR_EN		=0,
parameter FIXED_SLAVE1_ADDR_VALUE	=8'h00
)(
input  pulse_215us,
input  [7:0] seradr0,
input  [7:0] seradr1,
input  seradr1apb0,

//system globals
input  aresetn,
input  sresetn,
input  PCLK,
input  BCLKe,
//APB register interface
input  PSEL,
input  PENABLE,
input  PWRITE,
input  [4:0] PADDR,
input  [7:0] PWDATA,
output [7:0] PRDATA,
output INT,
//serial IF signals
input  SCLI,
input  SDAI,
output SCLO,
output SDAO,
//optional signals
input  SMBALERT_NI,
output SMBALERT_NO,
output SMBA_INT,
input  SMBSUS_NI,
output SMBSUS_NO,
output SMBS_INT
   );

// Declarations
localparam DELLONGINX = 4;
localparam [DELLONGINX-1 :0] INFILTERDELAY = GLITCHREG_NUM+2;
localparam MST_TX_SLV_RX = OPERATING_MODE[1];
localparam SLAVE_ONLY_EN = OPERATING_MODE[0];
//Operating_Mode[1:0]:
// 00 = Master and Slave
// 01 = Slave Only (TX and RX)
// 10 = Master TX, Slave Receive
// 11 = Slave Only RX

// Declarations

  // serCON   : 00  : 00  :
  parameter [4:0] serCON_ID = 5'b00000;  // serCON location
  parameter [7:0] serCON_RV = 8'b00000000; // serCON reset

  // serSTA   : 04  : F8  :
  parameter [4:0] serSTA_ID = 5'b00100;  // serSTA location
  parameter [7:0] serSTA_RV = 8'b11111000; // serSTA reset

  // serDAT   : 08  : 00  :
  parameter [4:0] serDAT_ID = 5'b01000;  // serDAT location
  parameter [7:0] serDAT_RV = 8'b00000000; // serDAT reset

  // serSMB   : 10  : 00  :
  parameter [4:0] serSMB_ID = 5'b10000;  // SMB_ID location
  parameter [7:0] serSMB_RV = 8'b01X1X000; // SMB_ID reset


// serADR   : 0C  : 00  :
parameter [4:0] serADR0_ID = 5'b01100;  // serADR location
parameter [7:0] serADR0_RV = 8'b00000000; // serADR reset


// serADR1   : 1C  : 00  :
parameter [4:0] serADR1_ID = 5'b11100;  // serADR location
parameter [7:0] serADR1_RV = 8'b00000000; // serADR reset

//
   //---------------------------------------------------------------
   // FSM STATUS enumeration type
   //---------------------------------------------------------------
   parameter [4:0] FSMSTA08 = 0;
   parameter [4:0] FSMSTA10 = 1;
   parameter [4:0] FSMSTAE0 = 29;
   parameter [4:0] FSMSTA18 = 2;
   parameter [4:0] FSMSTA20 = 3;
   parameter [4:0] FSMSTA28 = 4;
   parameter [4:0] FSMSTA30 = 5;
   parameter [4:0] FSMSTA38 = 6;
   parameter [4:0] FSMSTA40 = 7;
   parameter [4:0] FSMSTA48 = 8;
   parameter [4:0] FSMSTA50 = 9;
   parameter [4:0] FSMSTA58 = 10;
   parameter [4:0] FSMSTA60 = 11;
   parameter [4:0] FSMSTA68 = 12;
   parameter [4:0] FSMSTA70 = 13;
   parameter [4:0] FSMSTA78 = 14;
   parameter [4:0] FSMSTA80 = 15;
   parameter [4:0] FSMSTA88 = 16;
   parameter [4:0] FSMSTA90 = 17;
   parameter [4:0] FSMSTA98 = 18;
   parameter [4:0] FSMSTAA0 = 19;
   parameter [4:0] FSMSTAA8 = 20;
   parameter [4:0] FSMSTAB0 = 21;
   parameter [4:0] FSMSTAB8 = 22;
   parameter [4:0] FSMSTAC0 = 23;
   parameter [4:0] FSMSTAC8 = 24;
   parameter [4:0] FSMSTAF8 = 25;
   parameter [4:0] FSMSTA00 = 26;
   parameter [4:0] FSMSTAD0 = 27;
   parameter [4:0] FSMSTAD8 = 28;
//   parameter [4:0] FSMSTA00 = 5'b00000; //25;
//   parameter [4:0] FSMSTA08 = 5'b00001; //0;
//   parameter [4:0] FSMSTA10 = 5'b00010; //1;
//   parameter [4:0] FSMSTA18 = 5'b00011; //2;
//   parameter [4:0] FSMSTA20 = 5'b00100; //3;
//   parameter [4:0] FSMSTA28 = 5'b00101; //4;
//   parameter [4:0] FSMSTA30 = 5'b00110; //5;
//   parameter [4:0] FSMSTA38 = 5'b00111; //6;
//   parameter [4:0] FSMSTA40 = 5'b01000; //7;
//   parameter [4:0] FSMSTA48 = 5'b01001; //8;
//   parameter [4:0] FSMSTA50 = 5'b01010; //9;
//   parameter [4:0] FSMSTA58 = 5'b01011; //10;
//   parameter [4:0] FSMSTA60 = 5'b01100; //11;
//   parameter [4:0] FSMSTA68 = 5'b01101; //12;
//   parameter [4:0] FSMSTA70 = 5'b01110; //13;
//   parameter [4:0] FSMSTA78 = 5'b01111; //14;
//   parameter [4:0] FSMSTA80 = 5'b10000; //15;
//   parameter [4:0] FSMSTA88 = 5'b10001; //16;
//   parameter [4:0] FSMSTA90 = 5'b10010; //17;
//   parameter [4:0] FSMSTA98 = 5'b10011; //18;
//   parameter [4:0] FSMSTAA0 = 5'b10100; //19;
//   parameter [4:0] FSMSTAA8 = 5'b10101; //20;
//   parameter [4:0] FSMSTAB0 = 5'b10110; //21;
//   parameter [4:0] FSMSTAB8 = 5'b10111; //22;
//   parameter [4:0] FSMSTAC0 = 5'b11000; //23;
//   parameter [4:0] FSMSTAC8 = 5'b11001; //24;
//   parameter [4:0] FSMSTAD0 = 5'b11010; //27;
//   parameter [4:0] FSMSTAD8 = 5'b11011; //28;
//   parameter [4:0] FSMSTAF8 = 5'b11111; //26;

   //---------------------------------------------------------------
   // FSM DETECT enumeration type
   //---------------------------------------------------------------
   parameter [2:0] FSMDET0 = 0;
   parameter [2:0] FSMDET1 = 1;
   parameter [2:0] FSMDET2 = 2;
   parameter [2:0] FSMDET3 = 3;
   parameter [2:0] FSMDET4 = 4;
   parameter [2:0] FSMDET5 = 5;
   parameter [2:0] FSMDET6 = 6;

   //---------------------------------------------------------------
   // FSM SYNCHRONIZATION enumeration type
   //---------------------------------------------------------------
   parameter [2:0] FSMSYNC0 = 0;
   parameter [2:0] FSMSYNC1 = 1;
   parameter [2:0] FSMSYNC2 = 2;
   parameter [2:0] FSMSYNC3 = 3;
   parameter [2:0] FSMSYNC4 = 4;
   parameter [2:0] FSMSYNC5 = 5;
   parameter [2:0] FSMSYNC6 = 6;
   parameter [2:0] FSMSYNC7 = 7;

   //---------------------------------------------------------------
   // FSM MODE enumeration type
   //---------------------------------------------------------------
   parameter [2:0] FSMMOD0 = 0;
   parameter [2:0] FSMMOD1 = 1;
   parameter [2:0] FSMMOD2 = 2;
   parameter [2:0] FSMMOD3 = 3;
   parameter [2:0] FSMMOD4 = 4;
   parameter [2:0] FSMMOD5 = 5;
   parameter [2:0] FSMMOD6 = 6;

//*******************************************************************--

   parameter DATAWIDTH = 8; // data width
   parameter ADDRWIDTH = 7; // address width
   
//---------------------------------------------------------------
// Timeout Counter Calibrations based on FREQUENCY
//---------------------------------------------------------------


   //using 215us free running pulses to increment a >35ms 8-bit counter,
   //            flag with stick between 35.045 and 35.260.
   wire [7:0] term_cnt_35ms =  8'b10100100;//164
   reg [7:0] term_cnt_35ms_reg;
   wire       term_cnt_35ms_flag;//flag for 35 ms timeout

   //using 215us free running pulses to increment a >25ms 7-bit counter,
   //            flag with stick between 25.155 and 25.370.
   wire [6:0] term_cnt_25ms = 7'b1110110; //118
   reg [6:0] term_cnt_25ms_reg;
   wire       term_cnt_25ms_flag;//flag for 25 ms timeout
   
   //using 215us free running pulses to increment a >3ms 4-bit counter,
   //            flag with stick between 3.010 and 3.225.
   wire [3:0] term_cnt_3ms =  4'b1111;
   reg 	[3:0]  term_cnt_3ms_reg;
   wire       term_cnt_3ms_flag;//flag for 3 ms timeout

   //  Interrupt flag
   wire     si;
   assign   INT = si;

   //---------------------------------------------------------------
   // FSM registers and signals
   //---------------------------------------------------------------
   reg   [2:0] fsmmod      ;///* synthesis syn_state_machine = 0 */ ;// Master/slave mode detection FSM state
   reg   [2:0] fsmmod_nxt; // Master/slave mode detection FSM next state
   reg   [2:0] fsmsync     ;///* synthesis syn_state_machine = 0 */ ;// Clock synchronization FSM
   reg   [2:0] fsmsync_nxt;// Clock synchronization FSM next state
   reg   [2:0] fsmdet      ;///* synthesis syn_state_machine = 0 */ ;// stop/start detector FSM
   reg   [2:0] fsmdet_nxt; // stop/start detector FSM next state
   reg   [4:0] fsmsta     /* synthesis syn_state_machine = 0 */ ;// I2C status FSM
   reg   [4:0] fsmsta_nxt; // I2C status FSM next state

   //---------------------------------------------------------------
   // serial channel APB registers
   //---------------------------------------------------------------
   reg   [7:0] sercon;     // sercon APB register
   reg   [7:0] serdat;     // serdat APB register
   reg   [4:0] sersta;     // sersta APB register
   reg    	   sersmb7;     // sersmb APB register bit
   reg    	   sersmb6;     // sersmb APB register bit
   wire    	   sersmb5;     // sersmb APB register bit
   reg    	   sersmb4;     // sersmb APB register bit
   wire    	   sersmb3;     // sersmb APB register bit
   reg    	   sersmb2;     // sersmb APB register bit
   reg    	   sersmb1;     // sersmb APB register bit
   reg    	   sersmb0;     // sersmb APB register bit


   //---------------------------------------------------------------
   // sercon bits
   //---------------------------------------------------------------
   wire  [2:0] cr210;      // cr2, cr1, cr0 bits
   wire  ens1;             // "enable serial 1" bit
   wire  sta;              // start bit
   wire  sto;              // stop bit
   wire  aa;               // acknowledge bit

   //---------------------------------------------------------------
   // internal sersmb bits; others come from ports.
   //---------------------------------------------------------------
   wire smbus_mst_reset, smbus_mst_reset_posedge;
   reg  smbus_mst_reset_ff0, smbus_mst_reset_ff1, smbus_mst_reset_ff2;
   reg  set_int;  //interrupt set for slave reset sequence
   reg  ens1_pre; //internal reset of s.machines based on timeouts
   wire SMB_EN_int;  //internal SMBus Enable
   wire IPMI_EN_int; //internal IPMI Timeout Enable
   reg  SMBSUS_NI_d,SMBSUS_NI_d2 ;
   reg  SMBALERT_NI_d,SMBALERT_NI_d2 ;

   //---------------------------------------------------------------
   // serial data bit 7
   //---------------------------------------------------------------
   reg   bsd7;             // serial data bit 7
   reg   bsd7_tmp;         // serial data temporary bit 7

   //---------------------------------------------------------------
   // acknowledge bit
   //---------------------------------------------------------------
   reg   ack;              // acknowledge bit
   reg   ack_bit;          // acknowledge temporary bit

   //---------------------------------------------------------------
   // input filters
   //---------------------------------------------------------------
   reg   [GLITCHREG_NUM-1:0] SDAI_ff_reg; // serial data input ffs
   reg   SDAInt;           // serial data input - internal reg
   reg   [GLITCHREG_NUM-1:0] SCLI_ff_reg; // serial clock input ffs
   reg   SCLInt;           // serial clock input - internal reg

   //---------------------------------------------------------------
   // address comparator
   //---------------------------------------------------------------
   reg   adrcomp;          // address comparator output
   reg   adrcompen;        // address comparator enable

   //---------------------------------------------------------------
   // scl edge detector
   //---------------------------------------------------------------
   reg   nedetect;         // SCLInt negative edge det.
   reg   pedetect;         // SCLInt positive edge det.

   //---------------------------------------------------------------
   // clock generator signals
   //---------------------------------------------------------------
   reg   [3:0] PCLK_count1; // clock counter 1
   reg   PCLK_count1_ov;    // PCLK_count1 overflow
   reg   [3:0] PCLK_count2; // clock counter 2
   reg   PCLK_count2_ov;    // PCLK_count2 overflow
   reg   PCLKint;           // internal PCLK generator
   reg   PCLKint_ff;        // int. PCLK gen. flip-flop
   wire  PCLKint_p1;        // positive edge PCLKint det.
   wire  PCLKint_p2;        // negative edge PCLKint det.

   //---------------------------------------------------------------
   // clock counter reset
   //---------------------------------------------------------------
   wire  counter_PRESETN;

   //---------------------------------------------------------------
   // frame synchronization counter
   //---------------------------------------------------------------
   reg   [3:0] framesync;

   //---------------------------------------------------------------
   // master mode indicator
   //---------------------------------------------------------------
   reg   mst;

   //---------------------------------------------------------------
   // input filter delay counter
   //---------------------------------------------------------------
   reg   [DELLONGINX-1:0] indelay;

   //---------------------------------------------------------------
   //---------------------------------------------------------------
   reg   busfree;          // I2C bus free detector
   reg   SDAO_int;         // serial data output register
   reg   SCLO_int;         // serial clock output register
   wire  si_int;           // interrupt flag output
   reg   sclscl;           // two cycles scl
   reg   starto_en;        // transmit START condiion enable

   //------------------------------------------------------------------
   // Serial data output driver
   // Registered output
   //------------------------------------------------------------------
   assign SDAO = SDAO_int ;

   //------------------------------------------------------------------
   // Serial clock output driver
   // Registered output
   //------------------------------------------------------------------
   assign SCLO = (smbus_mst_reset)? 1'b0 : SCLO_int ;

   //------------------------------------------------------------------
   // Interrupt flag output
   // Registered output
   //------------------------------------------------------------------
   assign si = si_int ;

   //------------------------------------------------------------------
   // serial data output write
   //------------------------------------------------------------------
   always @(posedge PCLK or negedge aresetn)
   begin : SDAO_int_write_proc
   //------------------------------------------------------------------
   if ((!aresetn) || (!sresetn))
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      SDAO_int <= 1'b1 ;
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      begin
      if (
            (!ens1) |                        // ser disable
            (fsmmod == FSMMOD3) |            // repeated START transmit
            (fsmmod == FSMMOD0 & !adrcomp)   //or -- n.a.slave
         )
         begin // arbit lost
         SDAO_int <= 1'b1 ;
         end
      else if (
            (
               fsmmod == FSMMOD1 |
               fsmmod == FSMMOD4 |
               fsmmod == FSMMOD6
            ) |   // START / STOP transmit
            (adrcomp & adrcompen)
         )
         begin
         SDAO_int <= 1'b0 ;
         end
      else if (fsmsta == FSMSTA38)
         begin
         SDAO_int <= 1'b1 ;
         end
      else if (
            (
               //-----------------------------------
               // data ack
               //-----------------------------------
               // master receiver
               //-----------------------------------
               ((fsmsta == FSMSTA40 | fsmsta == FSMSTA50)&& (MST_TX_SLV_RX==0)) |
               //-----------------------------------
               // slave receiver
               //-----------------------------------
               fsmsta == FSMSTA60 | fsmsta == FSMSTA68 |
               fsmsta == FSMSTA80 | fsmsta == FSMSTA70 |
               fsmsta == FSMSTA78 | fsmsta == FSMSTA90
            ) &
            (framesync == 4'b0111 | framesync == 4'b1000)
         )
         begin
         if (framesync == 4'b0111 & nedetect)
            begin
            SDAO_int <= ~ack_bit ; //serdat(7); -- data ACK
            end
         end
      else if (
            //-----------------------------------
            // transmit data
            //-----------------------------------
            // master transmitter
            //-----------------------------------
            fsmsta == FSMSTA08 | fsmsta == FSMSTA10 |
            fsmsta == FSMSTA18 | fsmsta == FSMSTA20 |
            fsmsta == FSMSTA28 | fsmsta == FSMSTA30 |
            //-----------------------------------
            // slave transmitter
            //-----------------------------------
            ((fsmsta == FSMSTAA8 | fsmsta == FSMSTAB0 |
            fsmsta == FSMSTAB8)&& (MST_TX_SLV_RX==0))
         )
         begin
         if (framesync < 4'b1000 | framesync == 4'b1001)
            begin
            SDAO_int <= bsd7 ;
            end
         else
            begin
            SDAO_int <= 1'b1 ;
            end
         end
      else
         begin
         SDAO_int <= 1'b1 ;
         end
      end
   end

   //------------------------------------------------------------------
   // sercon bits
   //------------------------------------------------------------------
assign cr210 = BAUD_RATE_FIXED==1 ? BAUD_RATE_VALUE : {sercon[7], sercon[1:0]} ;
//   assign cr210 = {sercon[7], sercon[1:0]} ;

   //------------------------------------------------------------------
   assign ens1 = sercon[6] & ens1_pre; //enable or 1 clock disable
                                       //for timeout reset conditions.

   //------------------------------------------------------------------
generate
	if (SLAVE_ONLY_EN == 0) begin
   		assign sta = sercon[5] & (~sto) ;
   		assign sto = sercon[4] ;
	end
	else
	begin
   		assign sta = 1'b0 ;
   		assign sto = 1'b0 ;
	end
endgenerate
   //------------------------------------------------------------------
   assign si_int = sercon[3] ;

   //------------------------------------------------------------------
   assign aa = sercon[2] ;

   //------------------------------------------------------------------
   // sercon APB register
   //------------------------------------------------------------------
   always @(posedge PCLK or negedge aresetn)
   begin : sercon_write_proc
   //------------------------------------------------------------------
   if ((!aresetn) || (!sresetn))
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      sercon <= serCON_RV ;
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      // APB register write
      //--------------------------------
      begin
      if ((PENABLE && PWRITE && PSEL) && (PADDR == serCON_ID))
         begin
          sercon <= PWDATA ;
         end
      else
         //-----------------------------
         // setting si flag
         //-----------------------------
         begin
         if (
               (ens1) &
               (
                  (
                     (fsmmod == FSMMOD1 | fsmmod == FSMMOD6) &
                     (fsmdet == FSMDET3)
                  ) |               // transmitted START or Sr condition
                  (
                     (framesync == 4'b1000 & pedetect) &
                     (mst | adrcomp)// master operation, slave operation
                                    // or own addr received
                  ) |
                  (
                     (framesync == 4'b0000 | framesync == 4'b1001) &
                     (fsmdet == FSMDET3 | fsmdet == FSMDET5) &
                               // received START or STOP
                     (adrcomp) // addressed slave switched to FSMSTAA0
                  ) |
                  (
                     (framesync == 4'b0001 | framesync == 4'b0010 |
                      framesync == 4'b0011 | framesync == 4'b0100 |
                      framesync == 4'b0101 | framesync == 4'b0110 |
                      framesync == 4'b0111 | framesync == 4'b1000) &
                     (fsmdet == FSMDET3 | fsmdet == FSMDET5) &
                                     // received START or STOP
                     (mst | adrcomp) // bus ERROR
                ) |
                (
                   ((smbus_mst_reset_posedge == 1'b1) && (SMB_EN_int == 1)) // begin 35ms clk low bus reset
                ) |
                (
                   ((term_cnt_35ms_flag == 1'b1) && (SMB_EN_int == 1)) // mst reset, 35ms clk low
                ) |
                (
                   ((term_cnt_25ms_flag == 1'b1) && (SMB_EN_int == 1) && (fsmsta != FSMSTAD0)) // slave resetting status, 25ms clk low
                ) |
                (
                   ((term_cnt_3ms_flag == 1'b1) && (IPMI_EN_int == 1) ) // 3ms clk low
                ) |
                (
                   ((set_int == 1'b1) && (SMB_EN_int == 1)) // slave has reset
                ) |
               (   (fsmmod == FSMMOD4 & SCLInt & PCLKint_p1)       ) // transmitted STOP SAR 29537  
               )
            )
            begin
            sercon[3] <= 1'b1 ;
            end

                     //-----------------------------
         // clearing sto flag
         //-----------------------------
         if (
               (fsmmod == FSMMOD4 & PCLKint_p2) | // transmitted STOP
               (fsmdet == FSMDET5) |             // received STOP
               (!mst & sto) |                    // internal stop
               (!ens1)                           // ENS1='0'
            )
            begin
            sercon[4] <= 1'b0 ;
            end
         end
      end
   end

   //------------------------------------------------------------------
   // serdat APB register
   //------------------------------------------------------------------
   always @(posedge PCLK or negedge aresetn)
   begin : serdat_write_proc
   //------------------------------------------------------------------
   if ((!aresetn) || (!sresetn))
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      serdat   <= serDAT_RV ;
      ack      <= 1'b1 ;
      ack_bit  <= 1'b1 ;
      bsd7     <= 1'b1 ;
      bsd7_tmp <= 1'b1 ;
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      begin
      if (!ens1)
         begin
         if ((PENABLE && PWRITE && PSEL) && (PADDR == serDAT_ID))      // load data byte
            begin
            serdat <= PWDATA ;
            end
         end
      else // enable ser
         begin
         if (fsmdet == FSMDET3)  // START
            begin
            if ((PENABLE && PWRITE && PSEL) && (PADDR == serDAT_ID))   // load data byte
               begin
               serdat <= PWDATA ;
               end

            bsd7 <= 1'b0 ;
            bsd7_tmp <= 1'b0 ;

            end
         else if (
               //-----------------------------------
               // master transmitter
               //-----------------------------------
               fsmsta == FSMSTA08 | fsmsta == FSMSTA10 |
               fsmsta == FSMSTA18 | fsmsta == FSMSTA20 |
               fsmsta == FSMSTA28 | fsmsta == FSMSTA30 |
               //-----------------------------------
               // slave transmitter
               //-----------------------------------
               ((fsmsta == FSMSTAA8 | fsmsta == FSMSTAB0 |
               fsmsta == FSMSTAB8)&& (MST_TX_SLV_RX==0))
            )
            begin
            if (si_int) // interrupt process
               begin
               ack <= 1'b1 ; // high Z on ser bus after transmitted byte

               //--------------------------------
               // APB write
               //--------------------------------
               if ((PENABLE && PWRITE && PSEL) && (PADDR == serDAT_ID))   // load data byte
                  begin
                  serdat <= PWDATA ;
                  bsd7_tmp <= PWDATA[7] ;
                  end
               else
                  begin
                  if (!SCLInt)
                     begin
                     bsd7 <= bsd7_tmp ;
                     end
                  else
                     begin
                     bsd7 <= 1'b1 ;
                     end
                  end
               end
            else    // transmit data byte
               begin
               if ((PENABLE && PWRITE && PSEL) && (PADDR == serDAT_ID))   // load data byte
                  begin
                  serdat <= PWDATA ;
                  bsd7 <= PWDATA[7] ;
                  end
               else
                  begin
                  if (pedetect)
                     begin
                     serdat <= {serdat[6:0], ack} ;
                     ack <= SDAInt ;
                     end

                  if (nedetect)
                     begin
                     bsd7 <= serdat[7] ;
                     bsd7_tmp <= 1'b1 ;
                     end
                  end
               end
            end
         else if (
               //-----------------------------------
               // master receiver
               //-----------------------------------
               ((fsmsta == FSMSTA40 | fsmsta == FSMSTA50)&& (MST_TX_SLV_RX==0)) |
               //-----------------------------------
               // slave receiver
               //-----------------------------------
               fsmsta == FSMSTA60 | fsmsta == FSMSTA68 |
               fsmsta == FSMSTA80 | fsmsta == FSMSTA70 |
               fsmsta == FSMSTA78 | fsmsta == FSMSTA90
            )
            begin
            if (si_int) // intrrupt process
               begin
               if ((PENABLE && PWRITE && PSEL) && (PADDR == serCON_ID))
                  begin
                  ack_bit <= PWDATA[2] ; //aa
                  end
               if ((PENABLE && PWRITE && PSEL) && (PADDR == serDAT_ID))   // load data byte
                  begin
                  serdat <= PWDATA ;
                  end
               end
            else        // receiving data byte
               begin
               if ((PENABLE && PWRITE && PSEL) && (PADDR == serDAT_ID))   // load data byte
                  begin
                  serdat <= PWDATA ;
                  end
               else if (pedetect)
                  begin
                  serdat <= {serdat[6:0], ack} ;
                  ack <= SDAInt ;
                  end
               end

            bsd7 <= 1'b1 ;

            end
         else           // not addressed slave
            begin
            if ((PENABLE && PWRITE && PSEL) && (PADDR == serDAT_ID))      // load data byte
               begin
               serdat <= PWDATA ;
               end
            else if (pedetect)
               begin
               serdat <= {serdat[6:0], ack} ;
               ack <= SDAInt ;
               end

            bsd7 <= 1'b1 ;

            end
         end
      end
   end

      //------------------------------------------------------------------
   // sersta APB register
   //------------------------------------------------------------------
   always @(posedge PCLK or negedge aresetn)
   begin : sersta_write_proc
   //------------------------------------------------------------------
   if ((!aresetn) || (!sresetn))
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      sersta[4:0] <= serSTA_RV[4:0] ;
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      // APB register read-only
      //--------------------------------
      begin
      if (si_int)
         begin
         case (fsmsta)
         FSMSTA08 :
            begin
            sersta <= 5'b00001 ; //08H -- start has been trx/rcv
            end
         FSMSTA10 :
            begin
            sersta <= 5'b00010 ; //10H  -- repeated start has been trx/rcv
            end
         FSMSTA18 :
            begin
            sersta <= 5'b00011 ;
            end
         FSMSTA20 :
            begin
            sersta <= 5'b00100 ;
            end
         FSMSTA28 :
            begin
            sersta <= 5'b00101 ;
            end
         FSMSTA30 :
            begin
            sersta <= 5'b00110 ;
            end
         FSMSTA38 :
            begin
            sersta <= 5'b00111 ;
            end
         FSMSTA40 :
            begin
            sersta <= 5'b01000 ;
            end
         FSMSTA48 :
            begin
            sersta <= 5'b01001 ;
            end
         FSMSTA50 :
            begin
            sersta <= 5'b01010 ;
            end
         FSMSTA58 :
            begin
            sersta <= 5'b01011 ;
            end
         FSMSTA60 :
            begin
            sersta <= 5'b01100 ;
            end
         FSMSTA68 :
            begin
            sersta <= 5'b01101 ;
            end
         FSMSTA70 :
            begin
            sersta <= 5'b01110 ;
            end
         FSMSTA78 :
            begin
            sersta <= 5'b01111 ;
            end
         FSMSTA80 :
            begin
            sersta <= 5'b10000 ;
            end
         FSMSTA88 :
            begin
            sersta <= 5'b10001 ;
            end
         FSMSTA90 :
            begin
            sersta <= 5'b10010 ;
            end
         FSMSTA98 :
            begin
            sersta <= 5'b10011 ;
            end
         FSMSTAA0 :
            begin
            sersta <= 5'b10100 ;
            end
         FSMSTAA8 :
            begin
            sersta <= 5'b10101 ;
            end
         FSMSTAB0 :
            begin
            sersta <= 5'b10110 ;
            end
         FSMSTAB8 :
            begin
            sersta <= 5'b10111 ;
            end
         FSMSTAC0 :
            begin
            sersta <= 5'b11000 ;
            end
         FSMSTAC8 :
            begin
            sersta <= 5'b11001 ;
            end
         FSMSTA00 :
            begin
            sersta <= 5'b00000 ;
            end
         FSMSTAD0 :
            begin
            sersta <= 5'b11010 ;
            end
         FSMSTAD8 :
            begin
            sersta <= 5'b11011 ;
            end
         FSMSTAE0 :
            begin
            sersta <= 5'b11100 ;
            end
         default :
            begin
            // when FSMSTAF8
            sersta <= 5'b11111 ;
            end
         endcase
         end
      else
         begin
         sersta <= 5'b11111 ;
         end
      end
   end

//   //------------------------------------------------------------------
//   // sersta APB register
//   //------------------------------------------------------------------
//   always @(posedge PCLK or negedge aresetn)
//   begin : sersta_write_proc
//   //------------------------------------------------------------------
//   if ((!aresetn) || (!sresetn))
//      //-----------------------------------
//      // Synchronous reset
//      //-----------------------------------
//      begin
//      sersta[4:0] <= serSTA_RV[7:3] ;
//      end
//   else
//      //-----------------------------------
//      // Synchronous write
//      //-----------------------------------
//      // APB register read-only
//      //--------------------------------
//      begin
//      if (si_int)
//         begin
//      		sersta[4:0] <= fsmsta ;
//      	 end
//      else
//         begin
//         sersta[4:0] <= 5'b11111 ;
//         end
//      end
//   end
//
//
   //------------------------------------------------------------------
   // sersmb APB register; NOTE: some bits are R/W, others R only.
   //------------------------------------------------------------------
generate
begin: g_smbus_reg_bits
 if (SMB_EN == 1)
 begin
   always @(posedge PCLK or negedge aresetn)
   begin : sersmb_write_proc
   //------------------------------------------------------------------
   if ((!aresetn) || (!sresetn))
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
         sersmb7 <= serSMB_RV[7] ;
         sersmb6 <= serSMB_RV[6] ;
         sersmb4 <= serSMB_RV[4] ;
         sersmb2 <= serSMB_RV[2] ;
         sersmb1 <= serSMB_RV[1] ;
         sersmb0 <= serSMB_RV[0] ;
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      // APB register write
      //--------------------------------
      begin
      if ((PENABLE && PWRITE && PSEL) && (PADDR == serSMB_ID))
         begin
         sersmb7 <= PWDATA[7] ;
         sersmb6 <= PWDATA[6] ;
         sersmb4 <= PWDATA[4] ;
         sersmb2 <= PWDATA[2] ;
         sersmb1 <= PWDATA[1] ;
         sersmb0 <= PWDATA[0] ;
         end
      else if ((sersmb7 == 1'b1) && (term_cnt_35ms_flag == 1'b1))
         begin
         sersmb7 <= 1'b0;
         end
      end
   end
   always @(posedge PCLK or negedge aresetn)
   begin : ser_opt_sync_proc
   //------------------------------------------------------------------
   if ((!aresetn) || (!sresetn))
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
         SMBSUS_NI_d 	<= 1'b1 ;
         SMBALERT_NI_d 	<= 1'b1 ;
         SMBSUS_NI_d2 	<= 1'b1 ;
         SMBALERT_NI_d2	<= 1'b1 ;
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      // APB register write
      //--------------------------------
      begin
         SMBSUS_NI_d 	<= SMBSUS_NI ;
         SMBALERT_NI_d 	<= SMBALERT_NI ;
         SMBSUS_NI_d2 	<= SMBSUS_NI_d ;
         SMBALERT_NI_d2	<= SMBALERT_NI_d ;
      end
   end      //-----------------------------------
      // sersmb Read bits
      //-----------------------------------
      assign IPMI_EN_int = 1'b0;
      assign smbus_mst_reset = sersmb7;
      assign SMBSUS_NO = sersmb6;
      assign sersmb5 = SMBSUS_NI_d2;
      assign SMBALERT_NO = sersmb4;
      assign sersmb3 = SMBALERT_NI_d2;
      assign SMB_EN_int = sersmb2;
      assign SMBS_INT = (sersmb1==1'b1)? ~SMBSUS_NI_d2   : 1'b0;
      assign SMBA_INT = (sersmb0==1'b1)? ~SMBALERT_NI_d2 : 1'b0;
 end
 else if (IPMI_EN == 1)
 begin
   always @(posedge PCLK or negedge aresetn)
   begin : sersmb_write_proc
   //------------------------------------------------------------------
   if ((!aresetn) || (!sresetn))
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
         sersmb2 <= serSMB_RV[2] ;
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      // APB register write
      //--------------------------------
      begin
      if ((PENABLE && PWRITE && PSEL) && (PADDR == serSMB_ID))
         begin
         sersmb2 <= PWDATA[2] ;
         end
      end
   end
      //-----------------------------------
      // sersmb Read bits
      //-----------------------------------

      assign IPMI_EN_int = sersmb2;
      assign smbus_mst_reset = 1'b0;
      assign SMBSUS_NO = 1'b1;
      assign sersmb5 = 1'b1;
      assign SMBALERT_NO = 1'b1;
      assign sersmb3 = 1'b1;
      assign SMB_EN_int = 1'b0;
      assign SMBS_INT = 1'b0;
      assign SMBA_INT = 1'b0; end
 else
 begin
      assign IPMI_EN_int = 1'b0;
      assign smbus_mst_reset = 1'b0;
      assign SMBSUS_NO = 1'b1;
      assign sersmb5 = 1'b1;
      assign SMBALERT_NO = 1'b1;
      assign sersmb3 = 1'b1;
      assign SMB_EN_int = 1'b0;
      assign SMBS_INT = 1'b0;
      assign SMBA_INT = 1'b0;
 end
end
endgenerate


      //-----------------------------------
      // posedge detect for smbus_mst_reset
      //-----------------------------------
      always @ (posedge PCLK or negedge aresetn)
      begin: smbus_mst_reset_posedge_proc
       if ((!aresetn) || (!sresetn))
       begin
          smbus_mst_reset_ff0 <= 1'b0;
          smbus_mst_reset_ff1 <= 1'b0;
          smbus_mst_reset_ff2 <= 1'b0;
       end
       else
       begin
          smbus_mst_reset_ff0 <= smbus_mst_reset;
          smbus_mst_reset_ff1 <= smbus_mst_reset_ff0;
          smbus_mst_reset_ff2 <= smbus_mst_reset_ff1;
       end
      end

   assign smbus_mst_reset_posedge = ((smbus_mst_reset_ff1 == 1'b1) &&
                                    (smbus_mst_reset_ff2 == 1'b0))? 1'b1:1'b0;
   //------------------------------------------------------------------
   // SCL input filter
   //------------------------------------------------------------------

   always @(posedge PCLK or negedge aresetn)
   begin : SMBint_filter_proc
   //------------------------------------------------------------------
   if ((!aresetn) || (!sresetn))
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      SCLI_ff_reg <= {GLITCHREG_NUM{1'b1}};
      end
    else
      begin
      //-----------------------------------
      //     Synchronous write
      //-----------------------------------
      if (ens1)
        begin
        // i2c enable
        SCLI_ff_reg <= {SCLI_ff_reg[GLITCHREG_NUM-2:0], SCLI};
        end
      else
        begin
        SCLI_ff_reg <= {GLITCHREG_NUM{1'b1}};
        end
      end
    end

   //------------------------------------------------------------------
   // SCL write
   //------------------------------------------------------------------
   always @(posedge PCLK or negedge aresetn)
   begin : SCLInt_write_proc
   //------------------------------------------------------------------
   if ((!aresetn) || (!sresetn))
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      SCLInt   <= 1'b1 ;
      nedetect <= 1'b0 ; // negative edge of SCLI
      pedetect <= 1'b0 ; // positive edge of SCLI
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      	begin
            if (~ens1)
                SCLInt <= 1'b1;
            else if (|SCLI_ff_reg == 1'b0)
         	begin
         	SCLInt <= 1'b0 ;
         		if (SCLInt)
            	begin
            	nedetect <= 1'b1 ;
            	end
         		else
            	begin
            	nedetect <= 1'b0 ;
            	end
         	end
      		else if (&SCLI_ff_reg == 1'b1)
         	begin
         	SCLInt <= 1'b1 ;
         		if (!SCLInt)
            	begin
            	pedetect <= 1'b1 ;
            	end
         		else
            	begin
            	pedetect <= 1'b0 ;
            	end
         	end
      		else
         	begin
         	pedetect <= 1'b0 ;
         	nedetect <= 1'b0 ;
         	end
        end
   end

   //------------------------------------------------------------------
   // SDA input filter
   //------------------------------------------------------------------
   always @(posedge PCLK or negedge aresetn)
   begin : SDAI_ff_reg_proc
   //------------------------------------------------------------------
   if ((!aresetn) || (!sresetn))
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
    	begin
    	SDAI_ff_reg <= {GLITCHREG_NUM{1'b1}};
    	end
    else
      begin
      //-----------------------------------
      //     Synchronous write
      //-----------------------------------
      	if (ens1)
        begin
        // i2c enable
         SDAI_ff_reg <= {SDAI_ff_reg[GLITCHREG_NUM-2:0], SDAI};
        end
      	else
        begin
        SDAI_ff_reg <= {GLITCHREG_NUM{1'b0}};
        end
      end
    end

  //------------------------------------------------------------------
  always @(posedge PCLK or negedge aresetn)
    begin : SDAInt_write_proc
    if ((!aresetn) || (!sresetn))
      begin
      SDAInt <= 1'b1 ;
      end
    else
      	begin
      		if (|SDAI_ff_reg == 1'b0)
        	begin
        	SDAInt <= 1'b0 ;
        	end
      		else if (&SDAI_ff_reg == 1'b1)
         	begin
         	SDAInt <= 1'b1 ;
         	end
      	end
   end

   //------------------------------------------------------------------
   // address comparator
   //------------------------------------------------------------------
   always @(posedge PCLK or negedge aresetn)
   begin : adrcomp_write_proc
   //------------------------------------------------------------------
   if ((!aresetn) || (!sresetn))
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      adrcomp   <= 1'b0 ; // address comparator output
      adrcompen <= 1'b0 ; // address comparator enable
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      begin
      if (!mst & sto)   // intstop /internal stop condition/
         begin
         adrcomp <= 1'b0 ;
         adrcompen <= 1'b0 ;
         end
      else if (ens1_pre == 1'b0)   // int reset
         begin
         adrcomp <= 1'b0 ;
         adrcompen <= 1'b0 ;
         end
      else
         //----------------------------------
         // adrcompen write
         //----------------------------------
         begin
         if (fsmdet == FSMDET3)  // START condition detected
            begin
            adrcompen <= 1'b1 ;
            end
         else if (framesync == 4'b1000 & nedetect)
            begin
            adrcompen <= 1'b0 ;
            end

         //----------------------------------
         // adrcomp write
         //----------------------------------
         if (
               (fsmdet == FSMDET3 | fsmdet == FSMDET5) | //START or STOP
               (
                  (fsmsta == FSMSTA88 | fsmsta == FSMSTA98 |
                   fsmsta == FSMSTAC8 | fsmsta == FSMSTAC0 |
                   fsmsta == FSMSTA38 | fsmsta == FSMSTAA0 |
                   fsmsta == FSMSTA00
                  ) &
                  (si_int)    // switched to n.a.slave
               )
            )
            begin
            adrcomp <= 1'b0 ;
            end
         else if (
               (adrcompen &
                framesync == 4'b0111 &
                nedetect &
                aa) &
               (~(serdat[6:0] == 7'b0000000 & ack)) &//read from adr=00h
               (
                (
                  (serdat[6:0] == seradr0[7:1]) |   // own address
                  (
                     serdat[6:0] == 7'b0000000 &
                     (seradr0[0])             // GC address (only write)
                  )
               )
                |
                (
                 (((ADD_SLAVE1_ADDRESS_EN==1)&&(seradr1apb0 == 1'b1)) &&
                   (serdat[6:0] == seradr1[7:1]) && FIXED_SLAVE1_ADDR_EN) |   // own address
                 ((ADD_SLAVE1_ADDRESS_EN==1) &&
                   (serdat[6:0] == seradr1[7:1]) && ~FIXED_SLAVE1_ADDR_EN) |   // own address
                 (
                 (((ADD_SLAVE1_ADDRESS_EN==1)&&(seradr1apb0 == 1'b1)) &&
                   (serdat[6:0] == 7'b0000000) && ~FIXED_SLAVE1_ADDR_EN)      // common address
                 )
                )
               )
               &
               (!mst | fsmsta == FSMSTA38)
            )
            begin
            adrcomp <= 1'b1 ;
            end
         end
      end
   end

   //------------------------------------------------------------------
   // input filter delay
   // count 4*fosc after each positive edge scl
   //------------------------------------------------------------------
   always @(posedge PCLK or negedge aresetn)
   begin : indelay_write_proc
   //------------------------------------------------------------------
   if ((!aresetn) || (!sresetn))
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      indelay <= {DELLONGINX{1'b0}};
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      begin
      if (fsmsync == FSMSYNC3)
         begin
         if (~(indelay == INFILTERDELAY))
            begin
            indelay <= indelay + 1'b1 ;
            end
         end
      else
         begin
         indelay <= {DELLONGINX{1'b0}};
         end
      end
   end

   //------------------------------------------------------------------
   // frame synchronization counter
   //------------------------------------------------------------------
   always @(posedge PCLK or negedge aresetn)
   begin : framesync_write_proc
   //------------------------------------------------------------------
   if ((!aresetn) || (!sresetn))
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      framesync <= 4'b1111 ;
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      begin
      if (fsmdet == FSMDET3)     // START condition
         begin
         framesync <= 4'b1111 ;
         end
      else if (
            (fsmdet == FSMDET5) |   // STOP condition
            (si_int & !SCLInt)
         )
         begin // interrupt process
         framesync <= 4'b1001 ;
         end
      else if (framesync == 4'b1001)
         begin
         if (fsmsta == FSMSTAA0 | fsmsta == FSMSTA88 |
             fsmsta == FSMSTAC8 | fsmsta == FSMSTA98 |
             fsmsta == FSMSTAC0)
            begin
            framesync <= 4'b0000 ;
            end
         else
            begin
            if (
                  (!si_int) &
                  (!sto) &
                  (!sta | fsmsta == FSMSTA08 | fsmsta == FSMSTA10)
               )
               begin
               framesync <= 4'b0000 ;
               end
            else     // START / repeated START / STOP
               begin
               framesync <= 4'b1001 ;
               end
            end
         end
      else if (nedetect)
         begin
         if (framesync == 4'b1000)
            begin
            if (
                  (!si_int) &
                  (!sto) &
                  (!sta | fsmsta == FSMSTA08 | fsmsta == FSMSTA10)
               )
               begin
               framesync <= 4'b0000 ;
               end
            else     // START / repeated START / STOP
               begin
               framesync <= 4'b1001 ;
               end
            end
         else
            begin
            framesync <= framesync + 1'b1 ;
            end
         end
      end
   end

   //------------------------------------------------------------------
   // reset counters signal
   //------------------------------------------------------------------
   assign counter_PRESETN =
      (
         (fsmsync == FSMSYNC1 |
          fsmsync == FSMSYNC4 |
          fsmsync == FSMSYNC5) | // scl synchronization
         (!mst & sto) |          // internal stop
         (fsmdet == FSMDET5) |
         (fsmdet == FSMDET3) |   // STOP, START condition
         (fsmmod == FSMMOD4 &
          !SCLInt &
          SCLO_int) |            // transmit START condition
         (busfree &
          !SCLInt &              // impossible (?)
          ~(fsmmod == FSMMOD5))
      ) ? 1'b1 : 1'b0 ;


   //------------------------------------------------------------------
   // clock counter
   //------------------------------------------------------------------
   always @(posedge PCLK or negedge aresetn)
   begin : PCLK_counter1_proc
   //------------------------------------------------------------------
   if ((!aresetn) || (!sresetn))
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      PCLK_count1    <= 4'b0000 ;
      PCLK_count1_ov <= 1'b0 ;
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      begin
      if (counter_PRESETN)           // scl synchronization
         begin
         PCLK_count1 <= 4'b0000 ; // counter reset
         PCLK_count1_ov <= 1'b0 ;
         end
      else                       // normal operation
         begin
         case (cr210)
         3'b000 :                                     // 1/256
            begin
            if (PCLK_count1 < 4'b1111)                 // 1/16
               begin
               PCLK_count1 <= PCLK_count1 + 1'b1 ;
               PCLK_count1_ov <= 1'b0 ;
               end
            else
               begin
               PCLK_count1 <= 4'b0000 ;
               PCLK_count1_ov <= 1'b1 ;
               end
            end
         3'b001 :                                     // 1/224
            begin
            if (PCLK_count1 < 4'b1101)                 // 1/14
               begin
               PCLK_count1 <= PCLK_count1 + 1'b1 ;
               PCLK_count1_ov <= 1'b0 ;
               end
            else
               begin
               PCLK_count1 <= 4'b0000 ;
               PCLK_count1_ov <= 1'b1 ;
               end
            end
         3'b010 :                                     // 1/192
            begin
            if (PCLK_count1 < 4'b1011)                 // 1/12
               begin
               PCLK_count1 <= PCLK_count1 + 1'b1 ;
               PCLK_count1_ov <= 1'b0 ;
               end
            else
               begin
               PCLK_count1 <= 4'b0000 ;
               PCLK_count1_ov <= 1'b1 ;
               end
            end
         3'b011 :                                     // 1/160
            begin
            if (PCLK_count1 < 4'b1001)                 // 1/10
               begin
               PCLK_count1 <= PCLK_count1 + 1'b1 ;
               PCLK_count1_ov <= 1'b0 ;
               end
            else
               begin
               PCLK_count1 <= 4'b0000 ;
               PCLK_count1_ov <= 1'b1 ;
               end
            end
         3'b100 :                                     // 1/960
            begin
            if (PCLK_count1 < 4'b1110)                 // 1/15
               begin
               PCLK_count1 <= PCLK_count1 + 1'b1 ;
               PCLK_count1_ov <= 1'b0 ;
               end
            else
               begin
               PCLK_count1 <= 4'b0000 ;
               PCLK_count1_ov <= 1'b1 ;
               end
            end
         3'b101 :                                     // 1/120
            begin
            if (PCLK_count1 < 4'b1110)                 // 1/15
               begin
               PCLK_count1 <= PCLK_count1 + 1'b1 ;
               PCLK_count1_ov <= 1'b0 ;
               end
            else
               begin
               PCLK_count1 <= 4'b0000 ;
               PCLK_count1_ov <= 1'b1 ;
               end
            end
         3'b110 :                                     // 1/60
            begin
            if (PCLK_count1 < 4'b1110)                 // 1/15
               begin
               PCLK_count1 <= PCLK_count1 + 1'b1 ;
               PCLK_count1_ov <= 1'b0 ;
               end
            else
               begin
               PCLK_count1 <= 4'b0000 ;
               PCLK_count1_ov <= 1'b1 ;
               end
            end
         default :                  // 1/8 -- baud rate clock
            begin
            if (BCLKe)                                // 1/2
               begin
               if (PCLK_count1 < 4'b0001)
                  begin
                  PCLK_count1 <= PCLK_count1 + 1'b1 ;
                  PCLK_count1_ov <= 1'b0 ;
                  end
               else
                  begin
                  PCLK_count1 <= 4'b0000 ;
                  PCLK_count1_ov <= 1'b1 ;
                  end
               end
            else
               begin
               PCLK_count1_ov <= 1'b0 ;
               end
            end
         endcase
         end
      end
   end

   //------------------------------------------------------------------
   // clock counter
   //------------------------------------------------------------------
   always @(posedge PCLK or negedge aresetn)
   begin : PCLK_count2_write_proc
   //------------------------------------------------------------------
   if ((!aresetn) || (!sresetn))
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      PCLK_count2 <= 4'b0000 ;
      PCLK_count2_ov <= 1'b0 ;
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      begin
      if (counter_PRESETN)     // scl synchronization
         begin
         PCLK_count2 <= 4'b0000 ; // counter reset
         PCLK_count2_ov <= 1'b0 ;
         end
      else                 // normal operation
         begin
         if (PCLK_count1_ov)
            begin
            PCLK_count2 <= PCLK_count2 + 1'b1 ;
            case (cr210)
            3'b101 :       // 1/2
               begin
               if (PCLK_count2[0])
                  begin
                  PCLK_count2_ov <= 1'b1 ;
                  end
               else
                  begin
                  PCLK_count2_ov <= 1'b0 ;
                  end
               end
            3'b000,
            3'b001,
            3'b010,
            3'b011 :       // 1/4
               begin
               if (PCLK_count2[1:0] == 2'b11)
                  begin
                  PCLK_count2_ov <= 1'b1 ;
                  end
               else
                  begin
                  PCLK_count2_ov <= 1'b0 ;
                  end
               end
            3'b100 :       // 1/16
               begin
               if (PCLK_count2 == 4'b1111)
                  begin
                  PCLK_count2_ov <= 1'b1 ;
                  end
               else
                  begin
                  PCLK_count2_ov <= 1'b0 ;
                  end
               end
            default :   // PCLK_count2_ov <= PCLK_count1_ov
               begin
               PCLK_count2_ov <= 1'b1 ;
               end
            endcase
            end
         else
            begin
            PCLK_count2_ov <= 1'b0 ;
            end
         end
      end
   end

   //------------------------------------------------------------------
   // internal clock generator
   //------------------------------------------------------------------
   always @(posedge PCLK or negedge aresetn)
   begin : PCLKint_write_proc
   //------------------------------------------------------------------
   if ((!aresetn) || (!sresetn))
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      PCLKint <= 1'b1 ;
      PCLKint_ff <= 1'b1 ;
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      begin
      if (counter_PRESETN)  // scl synchronization
         begin
         PCLKint <= 1'b1 ;
         PCLKint_ff <= 1'b1 ;
         end
      else              // normal operation
         begin
         if (PCLK_count2_ov)
            begin
            PCLKint <= ~PCLKint ;
            end
         PCLKint_ff <= PCLKint ;
         end
      end
   end

   //------------------------------------------------------------------
   // internal clock generator PCLKint_p1
   //------------------------------------------------------------------
   assign PCLKint_p1 = (~PCLKint_ff) & PCLKint ; // positive edge

   //------------------------------------------------------------------
   // internal clock generator PCLKint_p2
   //------------------------------------------------------------------
   assign PCLKint_p2 = PCLKint_ff & (~PCLKint) ; // negative edge

   //------------------------------------------------------------------
   // SCL synchronization
   //------------------------------------------------------------------
   always @(fsmsync or SCLInt or PCLKint_p1 or indelay or si_int or
      SDAInt or sto or framesync or fsmmod)
   begin : fsmsync_comb_proc
   //------------------------------------------------------------------
   //-----------------------------
   // Initial value
   //-----------------------------
   fsmsync_nxt = FSMSYNC7 ;

   //-----------------------------
   // Combinational value
   //-----------------------------
   case (fsmsync)
   //-----------------------------
   FSMSYNC0 :
   //-----------------------------
      begin
      if (!SCLInt)
         begin
         fsmsync_nxt = FSMSYNC1 ;
         end
      else
         begin
         if (PCLKint_p1 &
            ~(fsmmod == FSMMOD3 | fsmmod == FSMMOD4))
            begin
            fsmsync_nxt = FSMSYNC2 ;
            end
         else
            begin
            fsmsync_nxt = FSMSYNC0 ;
            end
         end
      end

   //-----------------------------
   FSMSYNC1 :
   //-----------------------------
      begin
      fsmsync_nxt = FSMSYNC2 ;
      end

   //-----------------------------
   FSMSYNC2 :
   //-----------------------------
      begin
      if (PCLKint_p1)
         begin
         if (si_int)
            begin
            fsmsync_nxt = FSMSYNC5 ;
            end
         else
            begin
            if (sto & framesync == 4'b1001)
               begin
               fsmsync_nxt = FSMSYNC6 ;
               end
            else
               begin
               fsmsync_nxt = FSMSYNC3 ;
               end
            end
         end
      else
         begin
         fsmsync_nxt = FSMSYNC2 ;
         end
      end

   //-----------------------------
   FSMSYNC3 :
   //-----------------------------
      begin
      if (indelay == INFILTERDELAY)
         begin
         if (SCLInt)
            begin
            fsmsync_nxt = FSMSYNC0 ;
            end
         else
            begin
            fsmsync_nxt = FSMSYNC4 ;
            end
         end
      else
         begin
         fsmsync_nxt = FSMSYNC3 ;
         end
      end

   //-----------------------------
   FSMSYNC4 :
   //-----------------------------
      begin
      if (SCLInt)
         begin
         fsmsync_nxt = FSMSYNC0 ;
         end
      else
         begin
         fsmsync_nxt = FSMSYNC4 ;
         end
      end

   //-----------------------------
   FSMSYNC5 :
   //-----------------------------
      begin
      if (!si_int)
         begin
         if (sto)
            begin
            fsmsync_nxt = FSMSYNC6 ;
            end
         else
            begin
            fsmsync_nxt = FSMSYNC3 ;
            end
         end
      else
         begin
         fsmsync_nxt = FSMSYNC5 ;
         end
      end

   //-----------------------------
   FSMSYNC6 :
   //-----------------------------
      begin
      if (!SDAInt)
         begin
         fsmsync_nxt = FSMSYNC7 ;
         end
      else
         begin
         fsmsync_nxt = FSMSYNC6 ;
         end
      end

   //-----------------------------
   default :      // when FSMSYNC7
   //-----------------------------
      begin
      fsmsync_nxt = FSMSYNC7 ;
      end
   endcase
   end

   //------------------------------------------------------------------
   // Registered SCLO output
   //------------------------------------------------------------------
   always @(posedge PCLK or negedge aresetn)
   begin : fsmsync_sync_proc
   //------------------------------------------------------------------
   if ((!aresetn) || (!sresetn))
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      fsmsync <= FSMSYNC0 ;
      SCLO_int <= 1'b1 ;
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      begin
      if (fsmmod == FSMMOD0)  // slave mode
         begin
         fsmsync <= FSMSYNC0 ;
         end
      else
         begin
         fsmsync <= fsmsync_nxt ;
         end

      if (
            (ens1) & // ser enable
            (
               //-------------------------------------
               // master clock generator
               //-------------------------------------
               (fsmsync == FSMSYNC1 | fsmsync == FSMSYNC2 |
                fsmsync == FSMSYNC5 | fsmsync == FSMSYNC6) |

               //-------------------------------------
               // slave stretch when interrupt process
               //-------------------------------------
               (
                  ( // slave transmitter
                   ((fsmsta == FSMSTAA8 | fsmsta == FSMSTAB0 |
                   fsmsta == FSMSTAC0 | fsmsta == FSMSTAC8 |
                   fsmsta == FSMSTAB8)&&(MST_TX_SLV_RX==0)) |
                   // slave receiver
                   fsmsta == FSMSTA60 | fsmsta == FSMSTA68 |
                   fsmsta == FSMSTA80 | fsmsta == FSMSTA88 |
                   fsmsta == FSMSTA70 | fsmsta == FSMSTA78 |
                   fsmsta == FSMSTA90 | fsmsta == FSMSTA98 |
                   fsmsta == FSMSTAA0) &
                  (!SCLInt) &
                  (si_int)
               )
            )
         )
         begin
         SCLO_int <= 1'b0 ;
         end
      else
         begin
         SCLO_int <= 1'b1 ;
         end
      end
   end

   //------------------------------------------------------------------
   // I2C status FSM
   //------------------------------------------------------------------
   always @(fsmsta or pedetect or ack or SDAInt or SDAO_int or
      framesync or aa or adrcomp or adrcompen or serdat or
      seradr0 or seradr1)
   begin : fsmsta_comb_proc
   //------------------------------------------------------------------
   //-----------------------------
   // Initial value
   //-----------------------------
   fsmsta_nxt = FSMSTAF8 ;

   //-----------------------------
   // Combinational value
   //-----------------------------
   case (fsmsta)

   //==========================================--
   // MASTER Mode both RX | TX
   //==========================================--
   //-----------------------------
   FSMSTAD0 :
   //-----------------------------
      begin
      fsmsta_nxt = FSMSTAD0 ;
      end

   //==========================================--
   // MASTER TRANSMITTER
   //==========================================--
   //-----------------------------
   FSMSTA08 :
   //-----------------------------
      begin
      if (framesync == 4'b1000)     // ACK receiving
         begin
         if (!ack)                  // R/nW='0' --master transmitter
            begin
            if (SDAInt)             // not ACK
               begin
               fsmsta_nxt = FSMSTA20 ;
               end
            else                    // ACK
               begin
               fsmsta_nxt = FSMSTA18 ;
               end
            end
         else if (MST_TX_SLV_RX==0)// R/nW='1'  --master receiver
            begin
            if (SDAInt)             // not ACK
               begin
               fsmsta_nxt = FSMSTA48 ;
               end
            else                    // ACK
               begin
               fsmsta_nxt = FSMSTA40 ;
               end
            end
         end
      else
         begin
         if (SDAO_int & !SDAInt & pedetect)
            begin                   // arbitration lost
            fsmsta_nxt = FSMSTA38 ;
            end
         else
            begin
            fsmsta_nxt = FSMSTA08 ;
            end
         end
      end

   //-----------------------------
   FSMSTA10 :
   //-----------------------------
      begin
      if (framesync == 4'b1000)     // ACK receiving
         begin
         if (!ack)                  // R/nW='0' --master transmitter
            begin
            if (SDAInt)             // not ACK
               begin
               fsmsta_nxt = FSMSTA20 ;
               end
            else                    // ACK
               begin
               fsmsta_nxt = FSMSTA18 ;
               end
            end
         else if (MST_TX_SLV_RX==0) // R/nW='1' --master receiver
            begin
            if (SDAInt)             // not ACK
               begin
               fsmsta_nxt = FSMSTA48 ;
               end
            else                    // ACK
               begin
               fsmsta_nxt = FSMSTA40 ;
               end
            end
         end
      else
         begin
         if (SDAO_int & !SDAInt & pedetect)
            begin                   // arbitration lost
            fsmsta_nxt = FSMSTA38 ;
            end
         else
            begin
            fsmsta_nxt = FSMSTA10 ;
            end
         end
      end

   //-----------------------------
   FSMSTA18 :
   //-----------------------------
      begin
      if (framesync == 4'b1000)     // ACK receiving
         begin
         if (SDAInt)                // not ACK
            begin
            fsmsta_nxt = FSMSTA30 ;
            end
         else                       // ACK
            begin
            fsmsta_nxt = FSMSTA28 ;
            end
         end
      else
         begin
         if (SDAO_int & !SDAInt & pedetect)
            begin                   // arbitration lost
            fsmsta_nxt = FSMSTA38 ;
            end
         else
            begin
            fsmsta_nxt = FSMSTA18 ;
            end
         end
      end

   //-----------------------------
   FSMSTA20 :
   //-----------------------------
      begin
      if (framesync == 4'b1000)     // ACK receiving
         begin
         if (SDAInt)                // not ACK
            begin
            fsmsta_nxt = FSMSTA30 ;
            end
         else                       // ACK
            begin
            fsmsta_nxt = FSMSTA28 ;
            end
         end
      else
         begin
         if (SDAO_int & !SDAInt & pedetect)
            begin                   //arbitration lost
            fsmsta_nxt = FSMSTA38 ;
            end
         else
            begin
            fsmsta_nxt = FSMSTA20 ;
            end
         end
      end

   //-----------------------------
   FSMSTA28 :
   //-----------------------------
      begin
      if (framesync == 4'b1000)     // ACK receiving
         begin
         if (SDAInt)                // not ACK
            begin
            fsmsta_nxt = FSMSTA30 ;
            end
         else                       // ACK
            begin
            fsmsta_nxt = FSMSTA28 ;
            end
         end
      else
         begin
         if (SDAO_int & !SDAInt & pedetect)
            begin                   // arbitration lost
            fsmsta_nxt = FSMSTA38 ;
            end
         else
            begin
            fsmsta_nxt = FSMSTA28 ;
            end
         end
      end

   //-----------------------------
   FSMSTA30 :
   //-----------------------------
      begin
      if (framesync == 4'b1000)     // ACK receiving
         begin
         if (SDAInt)                // not ACK
            begin
            fsmsta_nxt = FSMSTA30 ;
            end
         else                       // ACK
            begin
            fsmsta_nxt = FSMSTA28 ;
            end
         end
      else
         begin
         if (SDAO_int & !SDAInt & pedetect)
            begin                   // arbitration lost
            fsmsta_nxt = FSMSTA38 ;
            end
         else
            begin
            fsmsta_nxt = FSMSTA30 ;
            end
         end
      end

   //-----------------------------
   FSMSTA38 :
   //----------------------------
      begin
      if (adrcomp & adrcompen &
         framesync == 4'b1000)      // ACK receiving
         begin
         if ((ack) && (MST_TX_SLV_RX==0))// SLA+R
            begin
            fsmsta_nxt = FSMSTAB0 ;
            end
         else                       	// SLA+W
            begin
            if (serdat[6:0] == 7'b0000000 &  // GC Address1
               (seradr0[0]))
               begin
               fsmsta_nxt = FSMSTA78 ;
               end
            else if ((serdat[6:0] == 7'b0000000) &&  // GC Address2
               (seradr1[0] == 1'b1) && (ADD_SLAVE1_ADDRESS_EN==1))
               begin
               fsmsta_nxt = FSMSTA78 ;
               end
            else
               begin
               fsmsta_nxt = FSMSTA68 ;
               end
            end
         end
      else
         begin
         fsmsta_nxt = FSMSTA38 ;
         end
      end

   //==========================================--
   // MASTER RECEIVER
   //==========================================--

   //-----------------------------
   FSMSTA40 :
   //-----------------------------
      begin
      if ((framesync == 4'b1000) && (MST_TX_SLV_RX==0))     // ACK transmitting
         begin
         if (SDAO_int &
            !SDAInt &
            pedetect)
            begin                   // arbitration lost in not ACK
            fsmsta_nxt = FSMSTA38 ;
            end
         else
            begin
            if (!SDAO_int)          // ACK transmitting
               begin
               fsmsta_nxt = FSMSTA50 ;
               end
            else                    // not ACK transmitting
               begin
               fsmsta_nxt = FSMSTA58 ;
               end
            end
         end
      else                          // receiving data
         begin
         fsmsta_nxt = FSMSTA40 ;
         end
      end

   //-----------------------------
   FSMSTA48 :
   //-----------------------------
      begin
      fsmsta_nxt = FSMSTA48 ;
      end

   //-----------------------------
   FSMSTA50 :
   //-----------------------------
      begin
      if ((framesync == 4'b1000) && (MST_TX_SLV_RX==0))     // ACK transmitting
         begin
         if (SDAO_int & !SDAInt & pedetect)
            begin                   // arbitration lost in not ACK
            fsmsta_nxt = FSMSTA38 ;
            end
         else
            begin
            if (!SDAO_int)          // ACK transmitting
               begin
               fsmsta_nxt = FSMSTA50 ;
               end
            else                    // not ACK transmitting
               begin
               fsmsta_nxt = FSMSTA58 ;
               end
            end
         end
      else                          // receiving data
         begin
         fsmsta_nxt = FSMSTA50 ;
         end
      end
   //-----------------------------
   FSMSTA58 :
   //-----------------------------
      begin
      fsmsta_nxt = FSMSTA58 ;
      end
   //==========================================--
   // SLAVE xmt or rcv
   //==========================================--
   //-----------------------------
   FSMSTAD8 :
   //-----------------------------
      begin
      fsmsta_nxt = FSMSTAD8 ;
      end
   //==========================================--
   // SLAVE RECEIVER
   //==========================================--

   //-----------------------------
   FSMSTA60 :
   //-----------------------------
      begin
      if (framesync == 4'b1000)     // ACK transmitting
         begin
         if (!SDAO_int)             // ACK transmitting
            begin
            fsmsta_nxt = FSMSTA80 ;
            end
         else                       // not ACK transmitting
            begin
            fsmsta_nxt = FSMSTA88 ;
            end
         end
      else                          // receiving data
         begin
         fsmsta_nxt = FSMSTA60 ;
         end
      end

   //-----------------------------
   FSMSTA68 :
   //-----------------------------
      begin
      if (framesync == 4'b1000)     // ACK transmitting
         begin
         if (!SDAO_int)             // ACK transmitting
            begin
            fsmsta_nxt = FSMSTA80 ;
            end
         else                       // not ACK transmitting
            begin
            fsmsta_nxt = FSMSTA88 ;
            end
         end
      else                          // receiving data
         begin
         fsmsta_nxt = FSMSTA68 ;
         end
      end

   //-----------------------------
   FSMSTA80 :
   //-----------------------------
      begin
      if (framesync == 4'b1000)     // ACK transmitting
         begin
         if (!SDAO_int)             // ACK transmitting
            begin
            fsmsta_nxt = FSMSTA80 ;
            end
         else                       // not ACK transmitting
            begin
            fsmsta_nxt = FSMSTA88 ;
            end
         end
      else                          // receiving data
         begin
         fsmsta_nxt = FSMSTA80 ;
         end
      end

   //-----------------------------
   FSMSTA88 :
   //-----------------------------
      begin
      fsmsta_nxt = FSMSTA88 ;      // go to n.a. slv
      end

   //-----------------------------
   FSMSTA70 :
   //-----------------------------
      begin
      if (framesync == 4'b1000)     // ACK transmitting
         begin
         if (!SDAO_int)             // ACK transmitting
            begin
            fsmsta_nxt = FSMSTA90 ;
            end
         else                       // not ACK transmitting
            begin
            fsmsta_nxt = FSMSTA98 ;
            end
         end
      else                          // receiving data
         begin
         fsmsta_nxt = FSMSTA70 ;
         end
      end

   //-----------------------------
   FSMSTA78 :
   //-----------------------------
      begin
      if (framesync == 4'b1000)     // ACK transmitting
         begin
         if (!SDAO_int)             // ACK transmitting
            begin
            fsmsta_nxt = FSMSTA90 ;
            end
         else                       // not ACK transmitting
            begin
            fsmsta_nxt = FSMSTA98 ;
            end
         end
      else                          // receiving data
         begin
         fsmsta_nxt = FSMSTA78 ;
         end
      end

   //-----------------------------
   FSMSTA90 :
   //-----------------------------
      begin
      if (framesync == 4'b1000)     // ACK transmitting
         begin
         if (!SDAO_int)             // ACK transmitting
            begin
            fsmsta_nxt = FSMSTA90 ;
            end
         else                       // not ACK transmitting
            begin
            fsmsta_nxt = FSMSTA98 ;
            end
         end
      else                          // receiving data
         begin
         fsmsta_nxt = FSMSTA90 ;
         end
      end

   //-----------------------------
   FSMSTA98 :
   //-----------------------------
      begin
      fsmsta_nxt = FSMSTA98 ;      // go to n.a. slv
      end

   //-----------------------------
   FSMSTAA0 :
   //-----------------------------
      begin
      fsmsta_nxt = FSMSTAA0 ;      // go to n.a. slv
      end

   //==========================================--
   // SLAVE TRANSMITTER
   //==========================================--

   //-----------------------------
   FSMSTAA8 :
   //-----------------------------
      begin
      if ((framesync == 4'b1000) && (MST_TX_SLV_RX==0))     // ACK receiving
         begin
         if (SDAInt)                // not ACK
            begin
            fsmsta_nxt = FSMSTAC0 ;
            end
         else                       // ACK
            begin
            if (!aa)                // transmit last data
               begin
               fsmsta_nxt = FSMSTAC8 ;
               end
            else
               begin
               fsmsta_nxt = FSMSTAB8 ;
               end
            end
         end
      else
         begin
         if ((SDAO_int & !SDAInt & pedetect) && (MST_TX_SLV_RX==0))
            begin                   // arbitration lost
            fsmsta_nxt = FSMSTA38 ;
            end
         else
            begin
            fsmsta_nxt = FSMSTAA8 ;
            end
         end
      end

   //-----------------------------
   FSMSTAB0 :
   //-----------------------------
      begin
      if ((framesync == 4'b1000) && (MST_TX_SLV_RX==0))     // ACK receiving
         begin
         if (SDAInt)                // not ACK
            begin
            fsmsta_nxt = FSMSTAC0 ;
            end
         else                       // ACK
            begin
            if (!aa)                // transmit last data
               begin
               fsmsta_nxt = FSMSTAC8 ;
               end
            else
               begin
               fsmsta_nxt = FSMSTAB8 ;
               end
            end
         end
      else
         begin
         if ((SDAO_int & !SDAInt & pedetect) && (MST_TX_SLV_RX==0))
            begin                   // arbitration lost
            fsmsta_nxt = FSMSTA38 ;
            end
         else
            begin
            fsmsta_nxt = FSMSTAB0 ;
            end
         end
      end

   //-----------------------------
   FSMSTAB8 :
   //-----------------------------
      begin
      if ((framesync == 4'b1000) && (MST_TX_SLV_RX==0))     // ACK receiving
         begin
         if (SDAInt)                // not ACK
            begin
            fsmsta_nxt = FSMSTAC0 ;
            end
         else                       // ACK
            begin
            if (!aa)                // transmit last data
               begin
               fsmsta_nxt = FSMSTAC8 ;
               end
            else
               begin
               fsmsta_nxt = FSMSTAB8 ;
               end
            end
         end
      else
         begin
         if ((SDAO_int & !SDAInt & pedetect) && (MST_TX_SLV_RX==0))
            begin                   //arbitration lost
            fsmsta_nxt = FSMSTA38 ;
            end
         else
            begin
            fsmsta_nxt = FSMSTAB8 ;
            end
         end
      end

   //-----------------------------
   FSMSTAC0 :
   //-----------------------------
      begin
      fsmsta_nxt = FSMSTAC0 ;      // go to n.a. slv
      end

   //-----------------------------
   FSMSTAC8 :
   //-----------------------------
      begin
      fsmsta_nxt = FSMSTAC8 ;      // go to n.a. slv
      end

   //-----------------------------
   FSMSTAE0 :
   //-----------------------------
      begin
      fsmsta_nxt = FSMSTAE0 ;      // STOP Transmitted 
      end

   //==========================================--

   //==========================================--
   // BUS ERROR
   //==========================================--

   //-----------------------------
   FSMSTA00 :
   //-----------------------------
      begin
      fsmsta_nxt = FSMSTA00 ;      // go to n.a. slv
      end

   //-----------------------------
   default :
   //----------------------------
      begin
      fsmsta_nxt = FSMSTAF8 ;      // go to n.a. slv
      end

   endcase
   end

   //------------------------------------------------------------------
   always @(posedge PCLK or negedge aresetn)
   begin : fsmsta_sync_proc
   //------------------------------------------------------------------
   if ((!aresetn) || (!sresetn))
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      fsmsta <= FSMSTAF8 ;
      set_int <= 1'b0;  //<- for slave mode reset only.
	  ens1_pre <= 1'b1; //disable (i.e. reset device state machines)
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      begin
      if ((smbus_mst_reset_posedge == 1'b1) && (SMB_EN_int == 1))
         begin
             set_int <= 1'b0;  //<- for slave mode reset only.
			 ens1_pre <= 1'b1; //disable (i.e. reset device state machines)
             fsmsta <= FSMSTAD0 ;  // "reset the bus" state,

         end
      else if ((term_cnt_35ms_flag == 1'b1) && (SMB_EN_int == 1))
         begin
             set_int <= 1'b0;  //<- for slave mode reset only.
			 ens1_pre <= 1'b0; //disable (i.e. reset device state machines)
             fsmsta <= FSMSTAF8 ;
         end
      else if ((term_cnt_25ms_flag == 1'b1) && (SMB_EN_int == 1) && (fsmsta != FSMSTAD0) && (mst!=1'b1))
         begin
             fsmsta <= FSMSTAD8 ;  // gen interrupt based on forced slave reset.
             set_int <= 1'b0;  //<- for slave mode reset only.
			 ens1_pre <= 1'b1; //disable (i.e. reset device state machines)
         end
      else if ((term_cnt_3ms_flag == 1'b1) && (IPMI_EN_int == 1) )
         begin
             fsmsta <= FSMSTAD8 ;  // gen interrupt based on forced slave reset.
             set_int <= 1'b0;  //<- for slave mode reset only.
			 ens1_pre <= 1'b1; //disable (i.e. reset device state machines)
         end
      else if ((fsmsta == FSMSTAD8) && (si_int != 1'b1) && (SMB_EN_int == 1))
         begin
             fsmsta <= FSMSTAF8 ;
             set_int <= 1'b1;
			 ens1_pre <= 1'b0; //disable (i.e. reset device state machines)
         end

      else if (fsmdet == FSMDET3 & fsmmod == FSMMOD1)
         begin
         fsmsta <= FSMSTA08 ;          // START has been trx
             set_int <= 1'b0;  //<- for slave mode reset only.
			 ens1_pre <= 1'b1; //disable (i.e. reset device state machines)
         end
      else if (fsmdet == FSMDET3 & fsmmod == FSMMOD6)
         begin
         fsmsta <= FSMSTA10 ;          // repeated START has been trx
             set_int <= 1'b0;  //<- for slave mode reset only.
			 ens1_pre <= 1'b1; //disable (i.e. reset device state machines)
         end
      else if (fsmmod == FSMMOD4 & PCLKint_p2) //  transmitted STOP SAR 29537  
         begin
             fsmsta <= FSMSTAE0 ;          // repeated START has been trx
         end
      else if (fsmdet == FSMDET3 | fsmdet == FSMDET5)
         begin                         // START or STOP has been rcv
         if ((framesync == 4'b0000 | framesync == 4'b1001) &
            (!si_int))
            begin
            if (adrcomp)               // addressed slave
               begin
               fsmsta <= FSMSTAA0 ;    // switched to n.a.slv. mode
             set_int <= 1'b0;  //<- for slave mode reset only.
			 ens1_pre <= 1'b1; //disable (i.e. reset device state machines)
               end
            else
               begin
               fsmsta <= FSMSTAF8 ;
             set_int <= 1'b0;  //<- for slave mode reset only.
			 ens1_pre <= 1'b1; //disable (i.e. reset device state machines)
               end
            end
         else if (
               (framesync == 4'b0001 | framesync == 4'b0010 |
                framesync == 4'b0011 | framesync == 4'b0100 |
                framesync == 4'b0101 | framesync == 4'b0110 |
                framesync == 4'b0111 | framesync == 4'b1000) &
               (adrcomp | mst)
            )
            begin
            fsmsta <= FSMSTA00 ;       // frame error
             set_int <= 1'b0;  //<- for slave mode reset only.
			 ens1_pre <= 1'b1; //disable (i.e. reset device state machines)
            end
         end
      else if (
            framesync == 4'b1000 &
            pedetect &
            adrcomp &
            adrcompen &
            ~(fsmsta == FSMSTA38)
         )
         begin                      // switched to addressed slv. mode
         if (!ack)                  // R/nW = 0
            begin
            if (serdat[6:0] == 7'b0000000)
               begin
               fsmsta <= FSMSTA70 ; // GC Address
             set_int <= 1'b0;  //<- for slave mode reset only.
			 ens1_pre <= 1'b1; //disable (i.e. reset device state machines)
               end
            else
               begin
               fsmsta <= FSMSTA60 ; // slave address
             set_int <= 1'b0;  //<- for slave mode reset only.
			 ens1_pre <= 1'b1; //disable (i.e. reset device state machines)
               end
            end
         else if (MST_TX_SLV_RX==0)                      // R/nW = 1
            begin
            fsmsta <= FSMSTAA8 ;    // slave address (R/nW = 1)
             set_int <= 1'b0;  //<- for slave mode reset only.
			 ens1_pre <= 1'b1; //disable (i.e. reset device state machines)
            end
         end
      else
         begin
         if (pedetect)
            begin
            fsmsta <= fsmsta_nxt ;
             set_int <= 1'b0;  //<- for slave mode reset only.
			 ens1_pre <= 1'b1; //disable (i.e. reset device state machines)
            end
         end
      end
   end

   //------------------------------------------------------------------
   // stop/start condition detector
   //------------------------------------------------------------------
   always @(fsmdet or SDAInt)
   begin : fsmdet_comb_proc
   //------------------------------------------------------------------
   //-----------------------------
   // Initial value
   //-----------------------------
   fsmdet_nxt = FSMDET6 ;

   //-----------------------------
   // Combinational value
   //-----------------------------

   case (fsmdet)

   //-----------------------------
   FSMDET0 :
   //-----------------------------
      begin
      if (!SDAInt)
         begin
         fsmdet_nxt = FSMDET2 ;
         end
      else
         begin
         fsmdet_nxt = FSMDET1 ;
         end
      end

   //-----------------------------
   FSMDET1 :
   //-----------------------------
      begin
      if (!SDAInt)
         begin
         fsmdet_nxt = FSMDET3 ;
         end
      else
         begin
         fsmdet_nxt = FSMDET1 ;
         end
      end

   //-----------------------------
   FSMDET2 :
   //-----------------------------
      begin
      if (!SDAInt)
         begin
         fsmdet_nxt = FSMDET2 ;
         end
      else
         begin
         fsmdet_nxt = FSMDET5 ;
         end
      end

   //-----------------------------
   FSMDET3 :
   //-----------------------------
      begin
      fsmdet_nxt = FSMDET4 ;
      end

   //-----------------------------
   FSMDET4 :
   //-----------------------------
      begin
      if (!SDAInt)
         begin
         fsmdet_nxt = FSMDET4 ;
         end
      else
         begin
         fsmdet_nxt = FSMDET5 ;
         end
      end

   //-----------------------------
   FSMDET5 :
   //-----------------------------
      begin
      fsmdet_nxt = FSMDET6 ;
      end

   //-----------------------------
   default :   // when FSMDET6
   //-----------------------------
      begin
      if (!SDAInt)
         begin
         fsmdet_nxt = FSMDET3 ;
         end
      else
         begin
         fsmdet_nxt = FSMDET6 ;
         end
      end

   endcase
   end

   //------------------------------------------------------------------
   always @(posedge PCLK or negedge aresetn)
   begin : fsmdet_sync_proc
   //------------------------------------------------------------------
   if ((!aresetn) || (!sresetn))
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      fsmdet <= FSMDET0 ;
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      begin
      if (!SCLInt)
         begin
         fsmdet <= FSMDET0 ;
         end
      else
         begin
         fsmdet <= fsmdet_nxt ;
         end
      end
   end

   //------------------------------------------------------------------
   // I2C bus free detector
   //------------------------------------------------------------------
   always @(posedge PCLK or negedge aresetn)
   begin : busfree_write_proc
   //------------------------------------------------------------------
   if ((!aresetn) || (!sresetn))
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      busfree <= 1'b1 ;
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      begin
      if (fsmdet == FSMDET3)           // START condition
         begin
         busfree <= 1'b0 ;
         end
      else if (
            (fsmdet == FSMDET5) |      // STOP condition rcv
            (fsmmod == FSMMOD4 & PCLKint_p1 &
            SCLInt) |                  // STOP transmitted
            (!mst & sto) |             // internal stop
            (!ens1)
         )
         begin
         busfree <= 1'b1 ;
         end
      end
   end

   //------------------------------------------------------------------
   // two cycles SCL
   //------------------------------------------------------------------
   always @(posedge PCLK or negedge aresetn)
   begin : sclscl_write_proc
   //------------------------------------------------------------------
   if ((!aresetn) || (!sresetn))
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      sclscl <= 1'b0 ;
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      begin
      if (fsmmod == FSMMOD5)
         begin
         if (pedetect)
            begin
            sclscl <= 1'b1 ;
            end
         end
      else
         begin
         sclscl <= 1'b0 ;
         end
      end
   end

   //------------------------------------------------------------------
   // transmit START condition enable
   //------------------------------------------------------------------
   always @(posedge PCLK or negedge aresetn)
   begin : starto_en_write_proc
   //------------------------------------------------------------------
   if ((!aresetn) || (!sresetn))
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      starto_en <= 1'b0 ;
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
     begin
      	if (busfree & SCLInt & ~(fsmmod == FSMMOD5))
         begin
         if (PCLKint_p1)
            begin
            starto_en <= 1'b1 ;
            end
         end
      else
         begin
         starto_en <= 1'b0 ;
         end
      end
   end

   //------------------------------------------------------------------
   // master/slave mode detector
   //------------------------------------------------------------------
   always @(fsmmod or SDAInt or SCLInt or PCLKint_p2 or PCLKint_p1 or
      sto or sta or nedetect or framesync or starto_en or si_int or
      fsmsta or pedetect or sclscl)
   begin : fsmmod_comb_proc
   //------------------------------------------------------------------
   //-----------------------------
   // Initial value
   //-----------------------------
   mst = 1'b1 ;
   fsmmod_nxt = FSMMOD6 ;

   //-----------------------------
   // Combinational value
   //-----------------------------
   case (fsmmod)
   //-----------------------------
   FSMMOD0 :
   //-----------------------------
      begin
      mst = 1'b0 ;
      if (starto_en & sta & !si_int & PCLKint_p1)
         begin
         if (!SDAInt)
            begin
            fsmmod_nxt = FSMMOD5 ; // transmit 2*SCL
            end
         else
            begin
            fsmmod_nxt = FSMMOD1 ; // transmit START
            end
         end
      else
         begin
         fsmmod_nxt = FSMMOD0 ;
         end
      end

   //-----------------------------
   FSMMOD1 :
   //-----------------------------
      begin
      mst = 1'b1 ;
      if (nedetect)
         begin
         // SCLInt neg. edge deteted
         fsmmod_nxt = FSMMOD2 ;
         end
      else
         begin
         fsmmod_nxt = FSMMOD1 ;
         end
      end

   //-----------------------------
   FSMMOD2 :
   //-----------------------------
      begin
      mst = 1'b1 ;
      if (framesync == 4'b1001 & !si_int)
         begin
         if (sto)
            begin
            fsmmod_nxt = FSMMOD4 ; // transmit STOP
            end
         else if (sta & ~(fsmsta == FSMSTA08 | fsmsta == FSMSTA10) &
            PCLKint_p2)
            begin
            fsmmod_nxt = FSMMOD3 ; // transmit repeated START (Sr)
            end
         else
            begin
            fsmmod_nxt = FSMMOD2 ;
            end
         end
      else
         begin
         fsmmod_nxt = FSMMOD2 ;
         end
      end

   //-----------------------------
   FSMMOD3 :
   //-----------------------------
      begin
      mst = 1'b1 ;
      if ((PCLKint_p1 | PCLKint_p2) & SCLInt)
         begin
         fsmmod_nxt = FSMMOD6 ;
         end
      else
         begin
         fsmmod_nxt = FSMMOD3 ;
         end
      end

   //-----------------------------
   FSMMOD4 : //STOP state
   //-----------------------------
      begin
      mst = 1'b1 ;
      if (SCLInt & PCLKint_p1)
         begin
         fsmmod_nxt = FSMMOD0 ;
         end
      else
         begin
         fsmmod_nxt = FSMMOD4 ;
         end
      end

   //-----------------------------
   FSMMOD5 :
   //-----------------------------
      begin
      mst = 1'b0 ;
      if (sclscl & pedetect)        // two cycles SCLO
         begin
         fsmmod_nxt = FSMMOD0 ;
         end
      else
         begin
         fsmmod_nxt = FSMMOD5 ;
         end
      end

   //-----------------------------
   default :      //when FSMMOD6
   //-----------------------------
      begin
      mst = 1'b1 ;
      if (nedetect)     // Sr
         begin
         fsmmod_nxt = FSMMOD2 ;
         end
      else
         begin
         fsmmod_nxt = FSMMOD6 ;
         end
      end
   endcase
   end

   //------------------------------------------------------------------
   always @(posedge PCLK or negedge aresetn)
   begin : fsmmod_sync_proc
   //------------------------------------------------------------------
   if ((!aresetn) || (!sresetn))
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      fsmmod <= FSMMOD0 ;
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      begin
         if (
            (fsmdet == FSMDET5) |         // STOP
            (
               fsmsta == FSMSTA38 &
               framesync == 4'b1000 &
               pedetect
            ) |
            (!ens1)                       // ser disable
         )
         begin
         fsmmod <= FSMMOD0 ;
         end
      else
         begin
         fsmmod <= fsmmod_nxt ;
         end
      end
   end

   //------------------------------------------------------------------
   // APB registers read
   //------------------------------------------------------------------
   assign PRDATA =
      (PADDR == serCON_ID) ? sercon :
      (PADDR == serDAT_ID) ? serdat :
      (PADDR == serSTA_ID) ? {sersta, 3'b000} :
      (PADDR == serADR0_ID) ? seradr0 :
      (PADDR == serADR1_ID) ? seradr1 :
      ((PADDR == serSMB_ID) && (SMB_EN == 1)) ? {sersmb7,sersmb6,sersmb5,
      							sersmb4,sersmb3,sersmb2, sersmb1, sersmb0} :
      ((PADDR == serSMB_ID) && (IPMI_EN == 1)) ? {5'b0,
      											sersmb2, 2'b0} :
      8'b00000000 ; //  8'bXXXXXXXX;
      
//   assign PRDATA =
//      (PADDR == serCON_ID) ? {1'b0,sercon[6:2],2'b00} :
////      (PADDR == serCON_ID) ? {sercon[7:0]} :
//      (PADDR == serDAT_ID) ? serdat :
//      (PADDR == serSTA_ID) ? {sersta, 3'b000} :  //sersta, 3'b000
////      (PADDR == serADR0_ID) ? seradr0 :
////      (PADDR == serADR1_ID) ? {7'b0000000, seradr1apb0} :
//      ((PADDR == serSMB_ID) && (SMB_EN == 1)) ? {sersmb7,sersmb6,sersmb5,
//      							sersmb4,sersmb3,sersmb2, sersmb1, sersmb0} :
//      ((PADDR == serSMB_ID) && (IPMI_EN == 1)) ? {5'b0,
//      											sersmb2, 2'b0} :
//      8'b00000000 ;


   //SMBus Counter to hold clock low for 35 ms when in master mode.
  always @(posedge PCLK or negedge aresetn)
  begin : term_cnt_35ms_proc
   if ((!aresetn) || (!sresetn))
      begin
      term_cnt_35ms_reg <= 0 ;
      end
   else
      begin
      if (SMB_EN_int == 1)
      begin
       if ((smbus_mst_reset_posedge == 1'b1) ) //&& (mst == 1'b1))
       begin
        term_cnt_35ms_reg <= 0;  // reset counter if smbus_mst_reset
       end
       else if ((smbus_mst_reset == 1'b0) ) //&& (mst == 1'b1))
       begin
        term_cnt_35ms_reg <= 0;  // reset counter if smbus_mst_reset
       end
       else if ((term_cnt_35ms_reg != term_cnt_35ms) && (pulse_215us == 1'b1))
       begin
        term_cnt_35ms_reg <= term_cnt_35ms_reg + 1;
       end
      end
    end
  end

    assign term_cnt_35ms_flag = (((term_cnt_35ms_reg >= term_cnt_35ms) &&
                                  (smbus_mst_reset == 1'b1))
                                 || (SMB_EN_int == 0))? 1'b1:1'b0;

   //Counter to hold clock low for 25 ms when in slave mode.
  always @(posedge PCLK or negedge aresetn)
  begin : term_cnt_25ms_proc
   if ((!aresetn) || (!sresetn))
      begin
      term_cnt_25ms_reg <= 0 ;
      end
   else
      begin
      if (SMB_EN_int == 1)
      begin
        if (SCLInt == 1'b1)
        begin
        term_cnt_25ms_reg <= 0 ; // reset counter if slave mode and clk is high
        end
        else if ((term_cnt_25ms_reg != term_cnt_25ms) && (pulse_215us == 1'b1))
        begin
        term_cnt_25ms_reg <= term_cnt_25ms_reg + 1;
        end
      end
    end
  end

    assign term_cnt_25ms_flag = (((term_cnt_25ms_reg == (term_cnt_25ms - 1)) && (pulse_215us == 1'b1))
                                 || (SMB_EN_int == 0))? 1'b1:1'b0;  //pulse

   //IPMI Counter to hold clock low for 3 ms.
  always @(posedge PCLK or negedge aresetn)
  begin : term_cnt_3ms_proc
   if ((!aresetn) || (!sresetn))
      begin
      term_cnt_3ms_reg <= 0 ;
      end
   else
      begin
      if (IPMI_EN_int == 1)
      begin
        if (SCLInt == 1'b1)
        begin
        term_cnt_3ms_reg <= 0 ; // reset counter if slave mode and clk is high
        end
        else if ((term_cnt_3ms_reg != term_cnt_3ms) && (pulse_215us == 1'b1))
        begin
        term_cnt_3ms_reg <= term_cnt_3ms_reg + 1;
        end
      end
    end
  end

    assign term_cnt_3ms_flag = (((term_cnt_3ms_reg == (term_cnt_3ms-1)) && (pulse_215us == 1'b1))
                                 || (IPMI_EN_int == 0))? 1'b1:1'b0;  //pulse

endmodule


