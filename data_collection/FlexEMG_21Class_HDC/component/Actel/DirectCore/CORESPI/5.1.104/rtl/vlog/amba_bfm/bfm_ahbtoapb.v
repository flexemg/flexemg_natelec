`timescale 1 ns / 100 ps
// ********************************************************************/ 
// Actel Corporation Proprietary and Confidential
// Copyright 2009 Actel Corporation.  All rights reserved.
//
// ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN 
// ACCORDANCE WITH THE ACTEL LICENSE AGREEMENT AND MUST BE APPROVED 
// IN ADVANCE IN WRITING.  
//  
// Description: AMBA BFMs
//              AHB to APB Bridge  
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
// SVN $Date: 2013-12-03 05:33:36 +0530 (Tue, 03 Dec 2013) $
//
//
// Resolved SARs
// SAR      Date     Who  Description
//
//
// Notes: 
// 28Nov07 IPB Updated to increase throughput
//
// *********************************************************************/ 

module BFM_AHB2APB (HCLK, HRESETN, HSEL, HWRITE, HADDR, HWDATA, HRDATA, HREADYIN, HREADYOUT, HTRANS, HSIZE, HBURST, HMASTLOCK, HPROT, HRESP, PSEL, PADDR, PWRITE, PENABLE, PWDATA, PRDATA, PREADY, PSLVERR);

    parameter  TPD  = 1;


    input HCLK; 
    input HRESETN; 
    input HSEL; 
    input HWRITE; 
    input[31:0] HADDR; 
    input[31:0] HWDATA; 
    output[31:0] HRDATA; 
    wire[31:0]  HRDATA;
    input HREADYIN; 
    output HREADYOUT; 
    wire  HREADYOUT;
    input[1:0] HTRANS; 
    input[2:0] HSIZE; 
    input[2:0] HBURST; 
    input HMASTLOCK; 
    input[3:0] HPROT; 
    output HRESP; 
    wire  HRESP;
    output[15:0] PSEL; 
    wire[15:0]  PSEL;
    output[31:0] PADDR; 
    wire[31:0]  PADDR;
    output PWRITE; 
    wire  PWRITE;
    output PENABLE; 
    wire  PENABLE;
    output[31:0] PWDATA; 
    wire[31:0]  PWDATA;
    input[31:0] PRDATA; 
    input PREADY; 
    input PSLVERR; 

    parameter[1:0] T0 = 0; 
    parameter[1:0] T2 = 1; 
    parameter[1:0] T345 = 2; 
    parameter[1:0] TR0 = 3; 
    reg[1:0] STATE; 
    reg HREADYOUT_P0; 
    reg HRESP_P0; 
    reg[15:0] PSEL_P0; 
    reg[31:0] PADDR_P0; 
    reg PWRITE_P0; 
    reg PENABLE_P0; 
    reg[31:0] PWDATA_P0; 
    wire[31:0] PWDATA_MUX; 
    reg DMUX; 
    reg PSELEN; 

    always @(posedge HCLK or negedge HRESETN)
    begin
        if (HRESETN == 1'b0)
        begin
            STATE  <= T0 ; 
            HREADYOUT_P0 <= 1'b1 ; 
            PADDR_P0   <= {32{1'b0}} ; 
            PWDATA_P0  <= {32{1'b0}} ; 
            PWRITE_P0  <= 1'b0 ; 
            PENABLE_P0 <= 1'b0 ; 
            HRESP_P0   <= 1'b0 ; 
            DMUX       <= 1'b0 ; 
            PSELEN     <= 1'b0 ; 
        end
        else
        begin
            HRESP_P0 <= 1'b0 ; 
            HREADYOUT_P0 <= 1'b0 ; 
            DMUX <= 1'b0 ; 
            case (STATE)
                T0 :
                            begin
                                if (HSEL == 1'b1 & HREADYIN == 1'b1 & (HTRANS[1]) == 1'b1)
                                begin
                                    STATE <= T2 ; 
                                    PADDR_P0 <= HADDR ; 
                                    PWRITE_P0 <= HWRITE ; 
                                    PWDATA_P0 <= HWDATA ; 
                                    PENABLE_P0 <= 1'b0 ; 
                                    DMUX <= HWRITE ; 
                                    PSELEN <= 1'b1 ; 
                                end
                                else
                                begin
                                    HREADYOUT_P0 <= 1'b1 ; 
                                end 
                            end
                T2 :
                            begin
                                PENABLE_P0 <= 1'b1 ; 
                                STATE <= T345 ; 
                            end
                T345 :
                            begin
                                if (PREADY == 1'b1)
                                begin
                                    PENABLE_P0 <= 1'b0 ; 
                                    PSELEN <= 1'b0 ; 
                                    if (PSLVERR == 1'b0)
                                    begin
                                        STATE <= T0 ; 
                                        if (HSEL == 1'b1 & HREADYIN == 1'b1 & (HTRANS[1]) == 1'b1)
                                        begin
                                            STATE <= T2 ; 
                                            PADDR_P0 <= HADDR ; 
                                            PWRITE_P0 <= HWRITE ; 
                                            DMUX <= HWRITE ; 
                                            PSELEN <= 1'b1 ; 
                                        end 
                                    end
                                    else
                                    begin
                                        HRESP_P0 <= 1'b1 ; 
                                        STATE <= TR0 ; 
                                    end 
                                end 
                            end
                TR0 :
                            begin
                                HRESP_P0 <= 1'b1 ; 
                                HREADYOUT_P0 <= 1'b1 ; 
                                STATE <= T0 ; 
                            end
            endcase 
            if (DMUX == 1'b1)
            begin
                PWDATA_P0 <= HWDATA ; 
            end 
        end 
    end 

    always @(PADDR_P0 or PSELEN)
    begin
        PSEL_P0 <= {16{1'b0}} ; 
        if (PSELEN == 1'b1)
        begin
            begin : xhdl_3
                integer i;
                for(i = 0; i <= 15; i = i + 1)
                begin
                    PSEL_P0[i] <= (PADDR_P0[27:24] == i) ; 
                end
            end 
        end 
    end 
    	
    assign      PWDATA_MUX = (DMUX == 1'b1) ? HWDATA : PWDATA_P0 ;
    assign #TPD HRDATA     = PRDATA ;
    assign #TPD HREADYOUT  = HREADYOUT_P0 | (PREADY & PSELEN & PENABLE_P0 & ~PSLVERR) ;
    assign #TPD HRESP      = HRESP_P0 ;
    assign #TPD PSEL       = PSEL_P0 ;
    assign #TPD PADDR      = PADDR_P0 ;
    assign #TPD PWRITE     = PWRITE_P0 ;
    assign #TPD PENABLE    = PENABLE_P0 ;
    assign #TPD PWDATA     = PWDATA_MUX ;

endmodule
 