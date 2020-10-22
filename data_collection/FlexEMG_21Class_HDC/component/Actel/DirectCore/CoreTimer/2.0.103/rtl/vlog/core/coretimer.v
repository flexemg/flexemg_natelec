`timescale 1ns/1ps
// ********************************************************************/ 
// Microsemi Corporation Proprietary and Confidential
// Copyright 2015 Microsemi Corporation.  All rights reserved.
//
// ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN 
// ACCORDANCE WITH THE MICROSEMI LICENSE AGREEMENT AND MUST BE APPROVED 
// IN ADVANCE IN WRITING.  
//  
//
// CoreTimer
//
//
// SVN Revision Information:
// SVN $Revision: 23762 $
// SVN $Date: 2014-11-11 08:01:54 -0800 (Tue, 11 Nov 2014) $
//
// Resolved SARs
// SAR      Date     Who   Description
//
//
// *********************************************************************/ 

module CoreTimer
    (
    PCLK,
    PRESETn,
    PENABLE,
    PSEL,
    PADDR,
    PWRITE,
    PWDATA,
    PRDATA,
    TIMINT
    );

    // Register addresses
    `define TIMERLOADA      3'b000
    `define TIMERVALUEA     3'b001
    `define TIMERCONTROLA   3'b010
    `define TIMERPRESCALEA  3'b011
    `define TIMERCLEARA     3'b100
    `define TIMERINTRAWA    3'b101
    `define TIMERINTA       3'b110

    parameter WIDTH = 32;   // Width can be 16 or 32
    parameter INTACTIVEH = 1; // 1 = Interrupt active high, 0 = interrupt active low
    parameter FAMILY = 19;
    parameter SYNC_RESET = (FAMILY == 25) ? 1 : 0;

    //-----------------------------------------------------------------------------
    // Pin Declarations
    //-----------------------------------------------------------------------------
    input               PCLK;       // APB clock
    input               PRESETn;    // APB reset
    input               PENABLE;    // APB enable
    input               PSEL;       // APB select
    input        [4:2]  PADDR;      // APB address bus
    input               PWRITE;     // APB write
    input       [31:0]  PWDATA;     // APB write data
    output      [31:0]  PRDATA;     // APB read data
    output              TIMINT;     // Timer interrupt


    //-----------------------------------------------------------------------------
    // Signal Declarations
    //-----------------------------------------------------------------------------

    // Input/Output Signals
    wire                PCLK;
    wire                PRESETn;
    wire                PENABLE;
    wire         [4:2]  PADDR;
    wire                PWRITE;
    wire        [31:0]  PWDATA;
    wire        [31:0]  PRDATA;
    wire                PSEL;
    wire                TIMINT;

    // Internal Signals
    wire        [31:0]  PrdataNext;     // Internal PRDATA
    reg         [31:0]  iPRDATA;        // Regd PrdataNext
    wire                PrdataNextEn;   // PRDATAEn register input
    reg         [31:0]  DataOut;

    wire                CtrlEn;         // Ctrl write enable
    reg          [6:0]  CtrlReg;        // Control register

    wire                TimerMode;      // Timer operation mode
    wire                IntEnable;      // Interrupt enable
    wire                TimerEn;        // Timer enable

    wire                OneShot;        // Asserted when TimerMode = 1
    wire                OneShotClr;

    wire                PrescaleEn;     // Prescale reg write enable
    reg          [3:0]  TimerPre;       // Prescale register

    wire                LoadEn;         // Load write enable
    reg                 LoadEnReg;      // Registered load enable
    reg    [WIDTH-1:0]  Load;           // Stores the load value

    reg          [9:0]  PreScale;       // Prescale counter

    reg    [WIDTH-1:0]  Count;          // Current count

    wire                IntClrEn;       // Interrupt Clear enable
    reg                 IntClr;

    wire                NxtRawTimInt;   // iTimInt next value
    reg                 RawTimInt;      // Registered internal counter interrupt
    wire                iTimInt;        // Internal version of interrupt output

    wire                CountIsZero;
    reg                 CountIsZeroReg;
    wire                TimeOut;

    reg                 CountPulse;
    reg                 NextCountPulse;
    
    wire                aresetn;
    wire                sresetn;


    //------------------------------------------------------------------------------
    // Beginning of main code
    //------------------------------------------------------------------------------

    //--------------------------------------------------------------------------
    // Sync reset
    //------------------------------------------------------------------------------
    assign aresetn = (SYNC_RESET == 1) ? 1'b1 : PRESETn;
    assign sresetn = (SYNC_RESET == 1) ? PRESETn : 1'b1;
    
    // Control Register
    //------------------------------------------------------------------------------
    // Functions of bits/bit fields of Control Register are:
    //   2 - Timer mode
    //   1 - Interrupt enable
    //   0 - Timer enable

    // Control register write enable
    assign CtrlEn = (PADDR == `TIMERCONTROLA) ? (PWRITE && PSEL && !PENABLE) : 1'b0;

    // Control register
    always @(negedge aresetn or posedge PCLK)
    begin : p_CtrlSeq
        if ((!aresetn) || (!sresetn))
            CtrlReg <= 3'b000;
        else
            if (CtrlEn)
                CtrlReg <= PWDATA[2:0];
    end

    // Assign control bits/fields
    assign TimerMode = CtrlReg[2];
    assign IntEnable = CtrlReg[1];
    assign TimerEn   = CtrlReg[0];

    assign OneShot = (TimerMode == 1'b1) ? 1'b1 : 1'b0;

    // OneShotClr asserted when clearing one shot bit and counter has reached zero.
    assign OneShotClr = CountIsZero && OneShot && (CtrlEn && !PWDATA[2]);

    //------------------------------------------------------------------------------
    // Prescale Register
    //------------------------------------------------------------------------------

    // Prescale register write enable
    assign PrescaleEn = (PADDR == `TIMERPRESCALEA) ? (PWRITE && PSEL && !PENABLE) : 1'b0;

    // Prescale register
    always @(negedge aresetn or posedge PCLK)
    begin : p_TimerPreSeq
        if ((!aresetn) || (!sresetn))
            TimerPre <= 4'b0000;
        else
            if (PrescaleEn)
                TimerPre <= PWDATA[3:0];
    end

    //------------------------------------------------------------------------------
    // Load Register
    //------------------------------------------------------------------------------

    // Decode a TimerLoad write transaction
    assign LoadEn = (PADDR == `TIMERLOADA) ? (PWRITE && PSEL && !PENABLE) : 1'b0;

    // Register LoadEn so it is aligned with the data in the Load register
    always @(negedge aresetn or posedge PCLK)
    begin : p_LoadEnSeq
        if ((!aresetn) || (!sresetn))
            LoadEnReg <= 1'b0;
        else
            LoadEnReg <= LoadEn;
    end

    // Load register implementation
    always @(negedge aresetn or posedge PCLK)
    begin : p_LoadSeq
        if ((!aresetn) || (!sresetn))
            Load <= {WIDTH{1'b0}};
        else
            if (LoadEn)
                Load <= PWDATA[WIDTH-1:0];
    end

    //------------------------------------------------------------------------------
    // Timer clock prescaler
    //------------------------------------------------------------------------------
    always @(negedge aresetn or posedge PCLK)
    begin : p_PrescalerSeq
        if ((!aresetn) || (!sresetn))
            PreScale <= {10{1'b0}};
        else
            if (LoadEnReg || OneShotClr) // Set to zero for new value/one-shot clear
                PreScale <= {10{1'b0}};
            else
                PreScale <= PreScale + 1'b1;
    end

    always @(PreScale or TimerPre)
    begin : p_NextCountPulseComb
        NextCountPulse = 1'b0;
        case (TimerPre)
            4'b0000: if (PreScale[0] == 1'b1)
                        NextCountPulse = 1'b1;
            4'b0001: if (PreScale[1:0] == 2'b11)
                        NextCountPulse = 1'b1;
            4'b0010: if (PreScale[2:0] == 3'b111)
                        NextCountPulse = 1'b1;
            4'b0011: if (PreScale[3:0] == 4'b1111)
                        NextCountPulse = 1'b1;
            4'b0100: if (PreScale[4:0] == 5'b11111)
                        NextCountPulse = 1'b1;
            4'b0101: if (PreScale[5:0] == 6'b111111)
                        NextCountPulse = 1'b1;
            4'b0110: if (PreScale[6:0] == 7'b1111111)
                        NextCountPulse = 1'b1;
            4'b0111: if (PreScale[7:0] == 8'b11111111)
                        NextCountPulse = 1'b1;
            4'b1000: if (PreScale[8:0] == 9'b111111111)
                        NextCountPulse = 1'b1;
            4'b1001: if (PreScale[9:0] == 10'b1111111111)
                        NextCountPulse = 1'b1;
            default: if (PreScale[9:0] == 10'b1111111111)
                        NextCountPulse = 1'b1;
        endcase
    end

    always @(negedge aresetn or posedge PCLK)
    begin : p_CountPulseSeq
        if ((!aresetn) || (!sresetn))
            CountPulse <= 1'b0;
        else
            CountPulse <= NextCountPulse;
    end

    //------------------------------------------------------------------------------
    // Counter register
    //------------------------------------------------------------------------------
    always @(negedge aresetn or posedge PCLK)
    begin : p_CountSeq
        if ((!aresetn) || (!sresetn))
            Count <= {WIDTH{1'b1}};
        else
            if (LoadEnReg || OneShotClr) // Re-start for new value or one-shot clear
                Count <= Load;
            else
                if (TimerEn && CountPulse)
                    if (CountIsZero)
                        if (OneShot)
                            Count <= Count;
                        else
                            Count <= Load;
                    else
                        Count <= Count - 1'b1;
    end

    assign CountIsZero = (Count == {WIDTH{1'b0}}) ? 1'b1 : 1'b0;

    always @(negedge aresetn or posedge PCLK)
    begin : p_CountIsZeroSeq
        if ((!aresetn) || (!sresetn))
            CountIsZeroReg <= 1'b0;
        else
            CountIsZeroReg <= CountIsZero;
    end

    assign TimeOut = CountIsZero && !CountIsZeroReg;

    //------------------------------------------------------------------------------
    // Interrupt generation
    //------------------------------------------------------------------------------
    // The interrupt is generated (set HIGH) when the counter reaches zero.
    // The interrupt is cleared (set LOW) when the TimerClear address is
    //  written to.

    assign NxtRawTimInt = (TimeOut || RawTimInt) && (!IntClr);

    // Register and hold interrupt until cleared.  TIMCLK is used to
    // ensure that an interrupt is still generated even if PCLK is disabled.
    always @(negedge aresetn or posedge PCLK)
    begin : p_IntSeq
        if ((!aresetn) || (!sresetn))
            RawTimInt <= 1'b0;
        else
            RawTimInt <= NxtRawTimInt;
    end

    // Gate raw interrupt with enable bit
    assign iTimInt = RawTimInt && IntEnable;

    // Drive interrupt output with internal signal
    // Interrupt can be active high or low depending on INTACTIVEH
    assign TIMINT = (INTACTIVEH) ? iTimInt : !iTimInt;

    //------------------------------------------------------------------------------
    // Interrupt clear
    //------------------------------------------------------------------------------
    assign IntClrEn = (PADDR == `TIMERCLEARA)? (PWRITE && PSEL && !PENABLE) : 1'b0;

    always @(negedge aresetn or posedge PCLK)
    begin : p_IntClrSeq
        if ((!aresetn) || (!sresetn))
            IntClr <= 1'b0;
        else
            if (IntClrEn)
                IntClr <= 1'b1;
            else
                IntClr <= 1'b0;
    end

    //------------------------------------------------------------------------------
    // Output data generation
    //------------------------------------------------------------------------------
    // Zero data is used as padding for register reads

    always @(PWRITE or PSEL or PADDR or Load or Count or CtrlReg
             or TimerPre or RawTimInt or iTimInt)
    begin : p_DataOutComb

        DataOut = {32{1'b0}}; // Drive zeros by default

        if (!PWRITE && PSEL)
            case (PADDR)
                `TIMERLOADA :
                    DataOut[WIDTH-1:0] = Load;

                `TIMERVALUEA :
                    DataOut[WIDTH-1:0] = Count;

                `TIMERCONTROLA :
                    DataOut[2:0] = CtrlReg;

                `TIMERPRESCALEA :
                    DataOut[3:0] = TimerPre;

                `TIMERINTRAWA :
                    DataOut[0] = RawTimInt;

                `TIMERINTA :
                    DataOut[0] = iTimInt;

                default:
                    DataOut = {32{1'b0}};
            endcase
        else
            DataOut = {32{1'b0}};
    end

    // Enable for output data.
    assign PrdataNextEn = (PSEL && !PWRITE && !PENABLE);

    assign PrdataNext = (PrdataNextEn) ? DataOut : {32{1'b0}};

    // Register used to reduce output delay during reads.
    always @ (negedge aresetn or posedge PCLK)
    begin : p_iPRDATASeq
        if ((!aresetn) || (!sresetn))
            iPRDATA <= {32{1'b0}};
        else
            iPRDATA <= PrdataNext;
    end

    // Drive output with internal version.
    assign PRDATA = iPRDATA;

endmodule

// --================================= End ===================================--
