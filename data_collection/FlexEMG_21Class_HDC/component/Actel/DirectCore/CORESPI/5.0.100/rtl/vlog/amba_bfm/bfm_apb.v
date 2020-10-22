// ********************************************************************/ 
// Actel Corporation Proprietary and Confidential
// Copyright 2009 Actel Corporation.  All rights reserved.
//
// ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN 
// ACCORDANCE WITH THE ACTEL LICENSE AGREEMENT AND MUST BE APPROVED 
// IN ADVANCE IN WRITING.  
//  
// Description: AMBA BFMs
//              APB Master Wrapper  
//
// Revision Information:
// Date     Description
// 01Sep07  Initial Release 
// 14Sep07  Updated for 1.2 functionality
// 25Sep07  Updated for 1.3 functionality
// 09Nov07  Updated for 1.4 functionality
//
//
// SVN Revision Information:
// SVN $Revision: 21608 $
// SVN $Date: 2013-12-03 00:03:36 +0000 (Tue, 03 Dec 2013) $
//
//
// Resolved SARs
// SAR      Date     Who  Description
//
//
// Notes: 
//        
// *********************************************************************/ 

`timescale 1 ns / 100 ps

module BFM_APB (SYSCLK, SYSRSTN, PCLK, PRESETN, PADDR, PENABLE, PWRITE, PWDATA, PRDATA, PREADY, PSLVERR, PSEL, INTERRUPT, GP_OUT, GP_IN, EXT_WR, EXT_RD, EXT_ADDR, EXT_DATA, EXT_WAIT, CON_ADDR, CON_DATA, CON_RD, CON_WR, CON_BUSY, FINISHED, FAILED);

    parameter OPMODE     = 0;
    parameter VECTFILE    = "test.vec";
    parameter MAX_INSTRUCTIONS  = 16384;
    parameter MAX_STACK  = 1024;
    parameter MAX_MEMTEST = 65536;
    parameter TPD        = 1;
    parameter DEBUGLEVEL = -1;
    parameter CON_SPULSE = 0;
    parameter ARGVALUE0  = 0;
    parameter ARGVALUE1  = 0;
    parameter ARGVALUE2  = 0;
    parameter ARGVALUE3  = 0;
    parameter ARGVALUE4  = 0;
    parameter ARGVALUE5  = 0;
    parameter ARGVALUE6  = 0;
    parameter ARGVALUE7  = 0;
    parameter ARGVALUE8  = 0;
    parameter ARGVALUE9  = 0;
    parameter ARGVALUE10 = 0;
    parameter ARGVALUE11 = 0;
    parameter ARGVALUE12 = 0;
    parameter ARGVALUE13 = 0;
    parameter ARGVALUE14 = 0;
    parameter ARGVALUE15 = 0;
    parameter ARGVALUE16 = 0;
    parameter ARGVALUE17 = 0;
    parameter ARGVALUE18 = 0;
    parameter ARGVALUE19 = 0;
    parameter ARGVALUE20 = 0;
    parameter ARGVALUE21 = 0;
    parameter ARGVALUE22 = 0;
    parameter ARGVALUE23 = 0;
    parameter ARGVALUE24 = 0;
    parameter ARGVALUE25 = 0;
    parameter ARGVALUE26 = 0;
    parameter ARGVALUE27 = 0;
    parameter ARGVALUE28 = 0;
    parameter ARGVALUE29 = 0;
    parameter ARGVALUE30 = 0;
    parameter ARGVALUE31 = 0;
    parameter ARGVALUE32 = 0;
    parameter ARGVALUE33 = 0;
    parameter ARGVALUE34 = 0;
    parameter ARGVALUE35 = 0;
    parameter ARGVALUE36 = 0;
    parameter ARGVALUE37 = 0;
    parameter ARGVALUE38 = 0;
    parameter ARGVALUE39 = 0;
    parameter ARGVALUE40 = 0;
    parameter ARGVALUE41 = 0;
    parameter ARGVALUE42 = 0;
    parameter ARGVALUE43 = 0;
    parameter ARGVALUE44 = 0;
    parameter ARGVALUE45 = 0;
    parameter ARGVALUE46 = 0;
    parameter ARGVALUE47 = 0;
    parameter ARGVALUE48 = 0;
    parameter ARGVALUE49 = 0;
    parameter ARGVALUE50 = 0;
    parameter ARGVALUE51 = 0;
    parameter ARGVALUE52 = 0;
    parameter ARGVALUE53 = 0;
    parameter ARGVALUE54 = 0;
    parameter ARGVALUE55 = 0;
    parameter ARGVALUE56 = 0;
    parameter ARGVALUE57 = 0;
    parameter ARGVALUE58 = 0;
    parameter ARGVALUE59 = 0;
    parameter ARGVALUE60 = 0;
    parameter ARGVALUE61 = 0;
    parameter ARGVALUE62 = 0;
    parameter ARGVALUE63 = 0;
    parameter ARGVALUE64 = 0;
    parameter ARGVALUE65 = 0;
    parameter ARGVALUE66 = 0;
    parameter ARGVALUE67 = 0;
    parameter ARGVALUE68 = 0;
    parameter ARGVALUE69 = 0;
    parameter ARGVALUE70 = 0;
    parameter ARGVALUE71 = 0;
    parameter ARGVALUE72 = 0;
    parameter ARGVALUE73 = 0;
    parameter ARGVALUE74 = 0;
    parameter ARGVALUE75 = 0;
    parameter ARGVALUE76 = 0;
    parameter ARGVALUE77 = 0;
    parameter ARGVALUE78 = 0;
    parameter ARGVALUE79 = 0;
    parameter ARGVALUE80 = 0;
    parameter ARGVALUE81 = 0;
    parameter ARGVALUE82 = 0;
    parameter ARGVALUE83 = 0;
    parameter ARGVALUE84 = 0;
    parameter ARGVALUE85 = 0;
    parameter ARGVALUE86 = 0;
    parameter ARGVALUE87 = 0;
    parameter ARGVALUE88 = 0;
    parameter ARGVALUE89 = 0;
    parameter ARGVALUE90 = 0;
    parameter ARGVALUE91 = 0;
    parameter ARGVALUE92 = 0;
    parameter ARGVALUE93 = 0;
    parameter ARGVALUE94 = 0;
    parameter ARGVALUE95 = 0;
    parameter ARGVALUE96 = 0;
    parameter ARGVALUE97 = 0;
    parameter ARGVALUE98 = 0;
    parameter ARGVALUE99 = 0;

    input SYSCLK; 
    input SYSRSTN; 
    output PCLK; 
    wire PCLK;
    output PRESETN; 
    wire PRESETN;
    output[31:0] PADDR; 
    wire[31:0] PADDR;
    output PENABLE; 
    wire PENABLE;
    output PWRITE; 
    wire PWRITE;
    output[31:0] PWDATA; 
    wire[31:0] PWDATA;
    input[31:0] PRDATA; 
    input PREADY; 
    input PSLVERR; 
    output[15:0] PSEL; 
    wire[15:0] PSEL;
    input[255:0] INTERRUPT; 
    output[31:0] GP_OUT; 
    wire[31:0] GP_OUT;
    input[31:0] GP_IN; 
    output EXT_WR; 
    wire EXT_WR;
    output EXT_RD; 
    wire EXT_RD;
    output[31:0] EXT_ADDR; 
    wire[31:0] EXT_ADDR;
    inout[31:0] EXT_DATA; 
    wire[31:0] EXT_DATA;
    input EXT_WAIT; 
    input[15:0] CON_ADDR; 
    inout[31:0] CON_DATA; 
    wire[31:0] CON_DATA;
    input CON_RD; 
    input CON_WR; 
    output CON_BUSY; 
    wire CON_BUSY;
    output FINISHED; 
    wire FINISHED;
    output FAILED; 
    wire FAILED;

    wire iPCLk; 
    wire iHCLk; 
    wire iHRESETN; 
    wire[31:0] iHADDR; 
    wire[2:0] iHBURST; 
    wire iHMASTLOCK; 
    wire[3:0] iHPROT; 
    wire[2:0] iHSIZE; 
    wire[1:0] iHTRANS; 
    wire iHWRITE; 
    wire[31:0] iHRDATA; 
    wire[31:0] iHWDATA; 
    wire iHREADY; 
    wire iHREADYIN; 
    wire iHREADYOUT; 
    wire iHRESP; 
    wire[15:0] iHSEL; 
    wire[31:0] INSTR_IN = {32{1'b0}}; 


    BFM_MAIN #( OPMODE, VECTFILE, MAX_INSTRUCTIONS, MAX_STACK, MAX_MEMTEST, TPD, DEBUGLEVEL, CON_SPULSE,
                ARGVALUE0,  ARGVALUE1,  ARGVALUE2,  ARGVALUE3,  ARGVALUE4,  ARGVALUE5,  ARGVALUE6,  ARGVALUE7,  ARGVALUE8,  ARGVALUE9,
                ARGVALUE10, ARGVALUE11, ARGVALUE12, ARGVALUE13, ARGVALUE14, ARGVALUE15, ARGVALUE16, ARGVALUE17, ARGVALUE18, ARGVALUE19,
                ARGVALUE20, ARGVALUE21, ARGVALUE22, ARGVALUE23, ARGVALUE24, ARGVALUE25, ARGVALUE26, ARGVALUE27, ARGVALUE28, ARGVALUE29,
                ARGVALUE30, ARGVALUE31, ARGVALUE32, ARGVALUE33, ARGVALUE34, ARGVALUE35, ARGVALUE36, ARGVALUE37, ARGVALUE38, ARGVALUE39,
                ARGVALUE40, ARGVALUE41, ARGVALUE42, ARGVALUE43, ARGVALUE44, ARGVALUE45, ARGVALUE46, ARGVALUE47, ARGVALUE48, ARGVALUE49,
                ARGVALUE50, ARGVALUE51, ARGVALUE52, ARGVALUE53, ARGVALUE54, ARGVALUE55, ARGVALUE56, ARGVALUE57, ARGVALUE58, ARGVALUE59,
                ARGVALUE60, ARGVALUE61, ARGVALUE62, ARGVALUE63, ARGVALUE64, ARGVALUE65, ARGVALUE66, ARGVALUE67, ARGVALUE68, ARGVALUE69,
                ARGVALUE70, ARGVALUE71, ARGVALUE72, ARGVALUE73, ARGVALUE74, ARGVALUE75, ARGVALUE76, ARGVALUE77, ARGVALUE78, ARGVALUE79,
                ARGVALUE80, ARGVALUE81, ARGVALUE82, ARGVALUE83, ARGVALUE84, ARGVALUE85, ARGVALUE86, ARGVALUE87, ARGVALUE88, ARGVALUE89,
                ARGVALUE90, ARGVALUE91, ARGVALUE92, ARGVALUE93, ARGVALUE94, ARGVALUE95, ARGVALUE96, ARGVALUE97, ARGVALUE98, ARGVALUE99
     ) UBFM(
        .SYSCLK(SYSCLK), 
        .SYSRSTN(SYSRSTN), 
        .HADDR(iHADDR), 
        .HCLK(iHCLk), 
        .PCLK(iPCLk), 
        .HRESETN(iHRESETN), 
        .HBURST(iHBURST), 
        .HMASTLOCK(iHMASTLOCK), 
        .HPROT(iHPROT), 
        .HSIZE(iHSIZE), 
        .HTRANS(iHTRANS), 
        .HWRITE(iHWRITE), 
        .HWDATA(iHWDATA), 
        .HRDATA(iHRDATA), 
        .HREADY(iHREADY), 
        .HRESP(iHRESP), 
        .HSEL(iHSEL), 
        .INTERRUPT(INTERRUPT), 
        .GP_OUT(GP_OUT), 
        .GP_IN(GP_IN), 
        .EXT_WR(EXT_WR), 
        .EXT_RD(EXT_RD), 
        .EXT_ADDR(EXT_ADDR), 
        .EXT_DATA(EXT_DATA), 
        .EXT_WAIT(EXT_WAIT), 
        .CON_ADDR(CON_ADDR), 
        .CON_DATA(CON_DATA), 
        .CON_RD(CON_RD), 
        .CON_WR(CON_WR), 
        .CON_BUSY(CON_BUSY), 
        .INSTR_OUT(), 
        .INSTR_IN(INSTR_IN), 
        .FINISHED(FINISHED), 
        .FAILED(FAILED)
    ); 
    assign PCLK = iPCLk ;
    assign PRESETN = iHRESETN ;

    BFM_AHB2APB #(TPD) UBRIDGE(
        .HCLK(iHCLk), 
        .HRESETN(iHRESETN), 
        .HSEL(1'b1), 
        .HWRITE(iHWRITE), 
        .HADDR(iHADDR), 
        .HWDATA(iHWDATA), 
        .HRDATA(iHRDATA), 
        .HREADYIN(iHREADY), 
        .HREADYOUT(iHREADY), 
        .HTRANS(iHTRANS), 
        .HSIZE(iHSIZE), 
        .HBURST(iHBURST), 
        .HMASTLOCK(iHMASTLOCK), 
        .HPROT(iHPROT), 
        .HRESP(iHRESP), 
        .PSEL(PSEL), 
        .PADDR(PADDR), 
        .PWRITE(PWRITE), 
        .PENABLE(PENABLE), 
        .PWDATA(PWDATA), 
        .PRDATA(PRDATA), 
        .PREADY(PREADY), 
        .PSLVERR(PSLVERR)
    ); 
endmodule
