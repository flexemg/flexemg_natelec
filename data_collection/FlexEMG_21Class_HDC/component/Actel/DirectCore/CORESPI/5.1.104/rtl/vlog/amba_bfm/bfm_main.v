// ********************************************************************/ 
// Actel Corporation Proprietary and Confidential
// Copyright 2009 Actel Corporation.  All rights reserved.
//
// ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN 
// ACCORDANCE WITH THE ACTEL LICENSE AGREEMENT AND MUST BE APPROVED 
// IN ADVANCE IN WRITING.  
//  
// Description: AMBA BFMs
//              AHB Lite BFM     
//
// Revision Information:
// Date     Description
// 01Sep07  Initial Release 
// 14Sep07  Updated for 1.2 functionality
// 25Sep07  Updated for 1.3 functionality
// 09Nov07  Updated for 1.4 functionality
// 18Dec08  Updated for 1.5 functionality
// 18Feb08  Updated for 1.6 functionality
// 08May08  2.0 for Soft IP Usage
// 08May08  2.0 for Soft IP Usage
// 04Feb09  2.1 Created fileset for G4 with CON bus back
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
//
// Release 2.0
//   Soft IP Release of Internal Hard IP Models
// Release 2.1
//   Added else and case support
//
// Requested Enhancements
//   Ability to do back-to-back single cycle checking of the IO_IN inputs 
// 
//
//
// *********************************************************************/ 


`timescale 1 ns / 100 ps


module BFM_MAIN (SYSCLK, SYSRSTN, PCLK, HCLK, HRESETN, 
                 HADDR, HBURST, HMASTLOCK, HPROT, HSIZE, HTRANS, HWRITE, HWDATA, HRDATA, HREADY, HRESP, HSEL, 
                 INTERRUPT, GP_OUT, GP_IN, EXT_WR, EXT_RD, EXT_ADDR, EXT_DATA, EXT_WAIT, 
                 CON_ADDR, CON_DATA, CON_RD, CON_WR, CON_BUSY, 
                 INSTR_OUT, INSTR_IN, FINISHED, FAILED);

    parameter OPMODE    = 0;
    parameter VECTFILE  = "test.vec";
    parameter MAX_INSTRUCTIONS  = 16384;
    parameter MAX_STACK   = 1024;
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
     

    localparam [1:(3)*8] BFM_VERSION = "2.1"; 
    localparam [1:(7)*8] BFM_DATE    = "04FEB09"; 

    input SYSCLK; 
    input SYSRSTN; 
    output PCLK; 
    wire PCLK;
    output HCLK; 
    wire HCLK;
    output HRESETN; 
    wire #TPD HRESETN;
   
    output[31:0] HADDR; 
    wire[31:0] #TPD HADDR;
   
    output[2:0] HBURST; 
    wire[2:0] #TPD HBURST;
    output HMASTLOCK; 
    wire #TPD HMASTLOCK;
    output[3:0] HPROT; 
    wire[3:0] #TPD HPROT;
    output[2:0] HSIZE; 
    wire[2:0] #TPD HSIZE;
    output[1:0] HTRANS; 
    wire[1:0] #TPD HTRANS;
    output HWRITE; 
    wire #TPD HWRITE;
    output[31:0] HWDATA; 
    wire[31:0] #TPD HWDATA;
    input[31:0] HRDATA; 
    input HREADY; 
    input HRESP; 
    output[15:0] HSEL; 
    wire[15:0] #TPD HSEL;
    input[255:0] INTERRUPT; 
    output[31:0] GP_OUT; 
    wire[31:0] #TPD GP_OUT;
    input[31:0] GP_IN; 
    output EXT_WR; 
    wire #TPD EXT_WR;
    output EXT_RD; 
    wire #TPD EXT_RD;
    output[31:0] EXT_ADDR; 
    wire[31:0] #TPD EXT_ADDR;
    inout[31:0] EXT_DATA; 
    wire[31:0] #TPD EXT_DATA;
    input EXT_WAIT; 
   
    input[15:0] CON_ADDR; 
    inout[31:0] CON_DATA; 
    wire[31:0] #TPD CON_DATA;
    wire[31:0] CON_DATA_xhdl1;
    input CON_RD; 
    input CON_WR; 
    output CON_BUSY; 
    reg CON_BUSY;
   
   
    output[31:0] INSTR_OUT; 
    reg[31:0] INSTR_OUT;
    input[31:0] INSTR_IN; 
    output FINISHED; 
    wire #TPD FINISHED;
    output FAILED; 
    wire #TPD FAILED;

    localparam NUL = 0;

    wire SCLK; 
    integer command [0:255]; 
    integer vectors [0:MAX_INSTRUCTIONS - 1]; 
    reg HRESETN_P0; 
    reg[2:0] HBURST_P0; 
    reg HMASTLOCK_P0; 
    reg[3:0] HPROT_P0; 
    reg[1:0] HTRANS_P0; 
    reg HWRITE_P0; 
    wire[31:0] HWDATA_P0; 
    reg[31:0] HADDR_P0; 
    reg[31:0] HADDR_P1; 
    reg[2:0] HSIZE_P0; 
    reg[2:0] HSIZE_P1; 
    reg[15:0] HSEL_P0; 
    reg WRITE_P1; 
    reg WRITE_P0; 
    reg READ_P0; 
    reg READ_P1; 
    reg POLL_P0; 
    reg POLL_P1; 
    reg RDCHK_P0; 
    reg RDCHK_P1; 
    reg[31:0] RDATA_P0; 
    reg[31:0] MDATA_P0; 
    reg[31:0] WDATA_P0; 
    reg[31:0] RDATA_P1; 
    reg[31:0] MDATA_P1; 
    reg[31:0] WDATA_P1; 
    reg[31:0] EIO_RDATA_P0; 
    reg[31:0] EIO_MDATA_P0; 
    integer EIO_LINENO_P0; 
    reg EIO_RDCHK_P0; 
    reg EIO_RDCHK_P1; 
    reg[31:0] EIO_RDATA_P1; 
    reg[31:0] EIO_MDATA_P1; 
    integer EIO_LINENO_P1; 
    reg EXTWR_P0; 
    reg EXTRD_P0; 
    reg EXTRD_P1; 
    reg GPIORD_P0; 
    reg GPIOWR_P0; 
    wire[31:0] EXT_DIN; 
    reg[31:0] EXT_DOUT; 
    reg[31:0] EXTADDR_P0; 
    reg[31:0] EXTADDR_P1; 
    wire[31:0] CON_DIN; 
    reg[31:0] CON_DOUT; 
    reg CON_RDP1; 
    reg CON_WRP1; 
    integer LINENO_P0; 
    integer LINENO_P1; 
    reg HCLK_STOP = 1'b0; 
    reg[31:0] GPOUT_P0; 
    reg[1:(80)*8] FILENAME; 
    reg FINISHED_P0; 
    reg FAILED_P0; 
    reg DRIVEX_CLK; 
    reg DRIVEX_RST; 
    reg DRIVEX_ADD; 
    reg DRIVEX_DAT; 


    parameter[31:0]   ZEROLV = {32{1'b0}}; 
    parameter[255:0] ZERO256 = {256{1'b0}}; 

    parameter TPDns = TPD * 1; 

    assign SCLK = SYSCLK ;

    integer stack[0:MAX_STACK - 1]; 
    integer return_value; 
    integer stkptr; 
    integer cmd_lineno; 
    integer DEBUG; 
    integer logopen;

    
    `include "bfm_package.v"

    function integer len_string;
        input len; 
        integer len;

        integer nparas; 
        integer nchars; 
        integer n; 

        begin
            nchars = len / 65536; 
            nparas = len % 65536; 
            n = 2 + nparas + 1 + ((nchars - 1) / 4); 
            len_string = n; 
        end
    endfunction

    function [1:(256)*8] extract_string;
        input cptr; 
        integer cptr;

        reg[1:(256)*8] pstr; 
        reg[1:(256)*8] str; 
        integer i; 
        integer p; 
        integer j; 
        reg[31:0] tmp_un; 
        integer nparas; 
        integer nchars; 
        integer len; 
		integer b;

        begin
            nchars = vectors[cptr + 1] / 65536; 
            nparas = vectors[cptr + 1] % 65536; 
            len = 2 + nparas + 1 + ((nchars - 1) / 4); 
            for(p = 1; p <= 256*8; p = p + 1)  pstr[p]=0;

            i = cptr + 2 + nparas; 
            j = 3; 
            begin : xhdl_3
                integer p;
                for(p = 1; p <= nchars; p = p + 1)
                begin
                    tmp_un = vectors[i]; 
                    for (b=1;b<=8;b=b+1) 
                       pstr[(p-1)*8+b] = tmp_un[j * 8 + 8-b]; 
                    if (j == 0)
                    begin
                        i = i + 1; 
                        j = 4; 
                    end 
                    j = j - 1; 
                end
            end 
            case (nparas)
                0 :
                            begin
                                $sformat(str, pstr); 
                            end
                1 :
                            begin
                                $sformat(str, pstr, command[2]); 
                            end
                2 :
                            begin
                                $sformat(str, pstr, command[2], command[3]); 
                            end
                3 :
                            begin
                                $sformat(str, pstr, command[2], command[3], command[4]); 
                            end
                4 :
                            begin
                                $sformat(str, pstr, command[2], command[3], command[4], command[5]); 
                            end
                5 :
                            begin
                                $sformat(str, pstr, command[2], command[3], command[4], command[5], command[6]); 
                            end
                6 :
                            begin
                                $sformat(str, pstr, command[2], command[3], command[4], command[5], command[6], command[7]); 
                            end
                7 :
                            begin
                                $sformat(str, pstr, command[2], command[3], command[4], command[5], command[6], command[7], command[8]); 
                            end
                default :
                            begin
                                $display("String Error (FAILURE)"); 
                            end
            endcase 

            extract_string = str; 
        end
    endfunction


	integer lastrandom;
    integer setrandom;
    integer ERRORS; 
    integer reset_pulse; 
    parameter[2:0] idle = 0; 
    parameter[2:0] init = 1; 
    parameter[2:0] active = 2; 
    parameter[2:0] done = 3; 
    parameter[2:0] fill = 4; 
    parameter[2:0] scan = 5; 
    integer mt_addr; 
    integer mt_size; 
    integer mt_align; 
    integer mt_cycles; 
    integer mt_seed; 
    reg[2:0] mt_state; 
    integer mt_image[0:MAX_MEMTEST-1]; 
    integer mt_ad; 
    integer mt_op; 
    integer mt_base; 
    integer mt_base2; 
    reg mt_readok; 
    integer mt_reads; 
    integer mt_writes; 
    integer mt_nops;
    integer var_ltimer; 
    integer var_licycles; 
    integer instructions_timer; 
    reg mt_dual; 
    reg mt_fill; 
    reg mt_scan; 
    reg mt_restart; 
    integer mt_fillad; 

    function automatic integer get_para_value;
        input isvar;
        input x; 
        integer x;

        integer y; 
        integer x30x16; 
        integer x14x13; 
        integer x12x0; 
        integer x12x8; 
        integer x7x0; 
        reg[31:0] xlv; 
        integer offset; 

        begin
            if (isvar)
            begin
                xlv    = x; 
                x30x16 = xlv[30:16]; 
                x14x13 = xlv[14:13]; 
                x12x0  = xlv[12:0]; 
                x12x8  = xlv[12:8]; 
                x7x0   = xlv[7:0]; 
                offset = 0; 
                if ((xlv[15]) == 1'b1)
                begin
                    // ARRAY offset in upper 16 bits
                    offset = get_para_value(1, x30x16);
                end 
                case (x14x13)
                    3 :
                                begin
                                    case (x12x8)
                                        D_NORMAL :
                                                    begin
                                                        case (x7x0)
                                                            // E_CONST
                                                            D_RETVALUE :
                                                                        begin
                                                                            y = return_value; 
                                                                        end
                                                            D_TIME :
                                                                        begin
                                                                            y = ( $time / 1); 
                                                                        end
                                                            D_DEBUG :
                                                                        begin
                                                                            y = DEBUG; 
                                                                        end
                                                            D_LINENO :
                                                                        begin
                                                                            y = cmd_lineno; 
                                                                        end
                                                            D_ERRORS :
                                                                        begin
                                                                            y = ERRORS; 
                                                                        end
                                                            D_TIMER :
                                                                        begin
                                                                            y = instructions_timer - 1; 
                                                                        end
                                                            D_LTIMER :
                                                                        begin
                                                                            y = var_ltimer; 
                                                                        end
                                                            D_LICYCLES :
                                                                        begin
                                                                            y = var_licycles; 
                                                                        end
                                                            default :
                                                                        begin
                                                                            $display("Illegal Parameter P0 (FAILURE)"); 
                                                                        end
                                                        endcase 
                                                    end
                                        D_ARGVALUE :
                                                    begin
                                                        case (x7x0)
                                                            0   :	  y = ARGVALUE0;  
                                                            1   :	  y = ARGVALUE1;  
                                                            2   :	  y = ARGVALUE2;  
                                                            3   :	  y = ARGVALUE3;  
                                                            4   :	  y = ARGVALUE4;  
                                                            5   :	  y = ARGVALUE5;  
                                                            6   :	  y = ARGVALUE6;  
                                                            7   :	  y = ARGVALUE7;  
                                                            8   :	  y = ARGVALUE8;  
                                                            9   :	  y = ARGVALUE9;  
                                                            10  :	  y = ARGVALUE10; 
                                                            11  :	  y = ARGVALUE11; 
                                                            12  :	  y = ARGVALUE12; 
                                                            13  :	  y = ARGVALUE13; 
                                                            14  :	  y = ARGVALUE14; 
                                                            15  :	  y = ARGVALUE15; 
                                                            16  :	  y = ARGVALUE16; 
                                                            17  :	  y = ARGVALUE17; 
                                                            18  :	  y = ARGVALUE18; 
                                                            19  :	  y = ARGVALUE19; 
                                                            20  :	  y = ARGVALUE20; 
                                                            21  :	  y = ARGVALUE21; 
                                                            22  :	  y = ARGVALUE22; 
                                                            23  :	  y = ARGVALUE23; 
                                                            24  :	  y = ARGVALUE24; 
                                                            25  :	  y = ARGVALUE25; 
                                                            26  :	  y = ARGVALUE26; 
                                                            27  :	  y = ARGVALUE27; 
                                                            28  :	  y = ARGVALUE28; 
                                                            29  :	  y = ARGVALUE29; 
                                                            30  :	  y = ARGVALUE30; 
                                                            31  :	  y = ARGVALUE31; 
                                                            32  :	  y = ARGVALUE32; 
                                                            33  :	  y = ARGVALUE33; 
                                                            34  :	  y = ARGVALUE34; 
                                                            35  :	  y = ARGVALUE35; 
                                                            36  :	  y = ARGVALUE36; 
                                                            37  :	  y = ARGVALUE37; 
                                                            38  :	  y = ARGVALUE38; 
                                                            39  :	  y = ARGVALUE39; 
                                                            40  :	  y = ARGVALUE40; 
                                                            41  :	  y = ARGVALUE41; 
                                                            42  :	  y = ARGVALUE42; 
                                                            43  :	  y = ARGVALUE43; 
                                                            44  :	  y = ARGVALUE44; 
                                                            45  :	  y = ARGVALUE45; 
                                                            46  :	  y = ARGVALUE46; 
                                                            47  :	  y = ARGVALUE47; 
                                                            48  :	  y = ARGVALUE48; 
                                                            49  :	  y = ARGVALUE49; 
                                                            50  :	  y = ARGVALUE50; 
                                                            51  :	  y = ARGVALUE51; 
                                                            52  :	  y = ARGVALUE52; 
                                                            53  :	  y = ARGVALUE53; 
                                                            54  :	  y = ARGVALUE54; 
                                                            55  :	  y = ARGVALUE55; 
                                                            56  :	  y = ARGVALUE56; 
                                                            57  :	  y = ARGVALUE57; 
                                                            58  :	  y = ARGVALUE58; 
                                                            59  :	  y = ARGVALUE59; 
                                                            60  :	  y = ARGVALUE60; 
                                                            61  :	  y = ARGVALUE61; 
                                                            62  :	  y = ARGVALUE62; 
                                                            63  :	  y = ARGVALUE63; 
                                                            64  :	  y = ARGVALUE64; 
                                                            65  :	  y = ARGVALUE65; 
                                                            66  :	  y = ARGVALUE66; 
                                                            67  :	  y = ARGVALUE67; 
                                                            68  :	  y = ARGVALUE68; 
                                                            69  :	  y = ARGVALUE69; 
                                                            70  :	  y = ARGVALUE70; 
                                                            71  :	  y = ARGVALUE71; 
                                                            72  :	  y = ARGVALUE72; 
                                                            73  :	  y = ARGVALUE73; 
                                                            74  :	  y = ARGVALUE74; 
                                                            75  :	  y = ARGVALUE75; 
                                                            76  :	  y = ARGVALUE76; 
                                                            77  :	  y = ARGVALUE77; 
                                                            78  :	  y = ARGVALUE78; 
                                                            79  :	  y = ARGVALUE79; 
                                                            80  :	  y = ARGVALUE80; 
                                                            81  :	  y = ARGVALUE81; 
                                                            82  :	  y = ARGVALUE82; 
                                                            83  :	  y = ARGVALUE83; 
                                                            84  :	  y = ARGVALUE84; 
                                                            85  :	  y = ARGVALUE85; 
                                                            86  :	  y = ARGVALUE86; 
                                                            87  :	  y = ARGVALUE87; 
                                                            88  :	  y = ARGVALUE88; 
                                                            89  :	  y = ARGVALUE89; 
                                                            90  :	  y = ARGVALUE90; 
                                                            91  :	  y = ARGVALUE91; 
                                                            92  :	  y = ARGVALUE92; 
                                                            93  :	  y = ARGVALUE93; 
                                                            94  :	  y = ARGVALUE94; 
                                                            95  :	  y = ARGVALUE95; 
                                                            96  :	  y = ARGVALUE96; 
                                                            97  :	  y = ARGVALUE97; 
                                                            98  :	  y = ARGVALUE98; 
                                                            99  :	  y = ARGVALUE99; 
                                                            default :
                                                                        begin
                                                                            $display("Illegal Parameter P1 (FAILURE)"); 
                                                                        end
                                                        endcase 
                                                    end
                                        D_RAND :
                                                    begin
                                                        lastrandom = random(lastrandom); 
                                                        y = mask_randomN(lastrandom, x7x0); 
                                                    end
                                        D_RANDSET :
                                                    begin
                                                        setrandom = lastrandom; 
                                                        lastrandom = random(lastrandom); 
                                                        y = mask_randomN(lastrandom, x7x0); 
                                                    end
                                        D_RANDRESET :
                                                    begin
                                                        lastrandom = setrandom; 
                                                        lastrandom = random(lastrandom); 
                                                        y = mask_randomN(lastrandom, x7x0); 
                                                    end
                                        default :
                                                    begin
                                                        $display("Illegal Parameter P2 (FAILURE)"); 
                                                    end
                                    endcase 
                                end
                    2 :
                                begin
                                    y = stack[stkptr - x12x0 + offset]; // E_STACK
                                end
                    1 :
                                begin
                                    y = stack[x12x0 + offset]; // E_ADDR
                                end
                    0 :
                                begin
                                    y = x12x0; // E_DATA
                                end
                    default :
                                begin
                                    $display("Illegal Parameter P3 (FAILURE)"); 
                                end
                endcase 
            end
            else
            begin
                // immediate data
                y = x; 
            end 
            get_para_value = y; 
        end
    endfunction

    function integer get_storeaddr;
        input x; 
        integer x;
        input stkptr;
        integer stkptr;

        integer sa; 
        integer x30x16; 
        integer x14x13; 
        integer x12x0; 
        integer x12x8; 
        integer x7x0; 
        reg[31:0] xlv; 
        integer offset; 

        begin
            xlv    = x; 
            x30x16 = xlv[30:16]; 
            x14x13 = xlv[14:13]; 
            x12x0  = xlv[12:0]; 
            x12x8  = xlv[12:8]; 
            x7x0   = xlv[7:0]; 
            offset = 0; 
            if ((xlv[15]) == 1'b1)
            begin
                // ARRAY offset in upper 16 bits
                offset = get_para_value(1, x30x16); 
            end 
            case (x14x13)
                3 :
                            begin
                                $display("$Variables not allowed (FAILURE)"); 
                            end
                2 :
                            begin
                                sa = stkptr - x12x0 + offset; // E_STACK
                            end
                1 :
                            begin
                                sa = x12x0 + offset; // E_ADDR
                            end
                0 :
                            begin
                                $display("Immediate data not allowed (FAILURE)"); 
                            end
                default :
                            begin
                                $display("Illegal Parameter P3 (FAILURE)"); 
                            end
            endcase 
            get_storeaddr = sa; 
        end
    endfunction 



//---------------------------------------------------------------------------------------

    // NOTE THIS IS IN ONE HUGE PROCESS FOR SIMULATION PERFORMANCE REASONS 
    always @(posedge SCLK or negedge SYSRSTN)
    begin : BFM
       
        parameter[0:0] OK1  = 0; 
        parameter[0:0] OK2  = 1; 

        integer flog;
        reg initdone; 
        integer Loopcmd[0:4]; 
        reg [31:0] commandLV [0:255]; 
        integer Nvectors; 
        integer cptr; 
        integer lptr; 
        integer fptr; 
        integer loopcounter; 
        reg[31:0] command0; 
        reg[1:0] cmd_size; 
        integer cmd_cmd; 
        integer cmd_cmdx4; 
        integer cmd_scmd; 
        integer command_length; 
        integer command_timeout; 
        reg[2:0] command_size; 
        reg[31:0] command_address; 
        reg[31:0] command_data; 
        reg[31:0] command_mask; 
        reg do_case; 
        reg do_read; 
        reg do_bwrite; 
        reg do_bread; 
        reg do_write; 
        reg do_poll; 
        reg do_flush; 
        reg do_idle;
        reg do_io;
        reg cmd_active; 
        reg last_match; 
        integer wait_counter; 
        integer bitn; 
        integer timer; 
        integer n; 
        integer i; 
        integer j; 
        integer x; 
        integer y; 
        integer v; 
        reg[1:(256)*8] str; 
        reg[1:(256)*8] logstr; 
        reg[1:(256)*8] logfile; 
        integer burst_address; 
        integer burst_length; 
        integer burst_count; 
        integer burst_addrinc; 
        integer burst_data[0:8191]; 
        reg[1:(8)*8] istr; 
        reg bfm_done; 
        reg filedone; 
        reg ch; 
        integer tableid; 
        integer characters; 
        integer int_vector; 
        integer call_address; 
        integer return_address; 
        integer jump_address; 
        integer nparas; 
        integer data_start; 
        integer data_inc; 
        integer hresp_mode; 
        integer bfm_mode; 
        integer instruct_cycles; 
        integer instuct_count; 
        integer setvar; 
        integer newvalue; 
        reg[31:0] EXP; 
        reg[31:0] GOT; 
        reg DATA_MATCH_AHB; 
        reg DATA_MATCH_EXT; 
        reg DATA_MATCH_IO; 
        reg hresp_occured; 
        reg[0:0] HRESP_STATE; 
        reg[1:(10)*8] tmpstr; 
        reg ahb_lock; 
        reg[3:0] ahb_prot; 
        reg[2:0] ahb_burst; 
        integer storeaddr; 
        reg piped_activity; 
        reg [1:(256)*8] filenames[0:100]; 
        integer NFILES; 
        integer filemult; 
        reg[1:0] su_xsize; 
        reg[5:0] su_xainc; 
        reg[16:0] su_xrate; 
        reg su_flush; 
        integer su_noburst; 
        reg su_align; 
        reg bfm_run; 
        reg bfm_single; 
        reg int_active; 
        reg su_endsim;
        integer count_xrate; 
        reg insert_busy; 
        reg log_ahb; 
        reg log_ext; 
        reg log_gpio; 
        reg log_bfm; 
        integer bfmc_version; 
        integer cmpvalue; 
        integer vectors_version; 
        integer wait_time; 
        reg ahbc_hwrite; 
        reg[1:0] ahbc_htrans; 
        reg[3:0] ahbc_prot; 
        reg[2:0] ahbc_burst; 
        reg      ahbc_lock; 
        reg      ahb_activity; 
       
        reg [256*8:0] vchar;
        integer c;
        integer b;
        integer ni;
        reg zerocycle; 
        integer mt_dual; 
        integer passed[0:15]; 
        integer npass; 
        integer returnstk[0:255]; 
        reg[8:0] wptr_cstk; 
        reg[8:0] rptr_cstk; 
        integer casedone[0:255];
        integer casedepth;

        if (SYSRSTN == 1'b0)
        begin
            // These are auto initialized in VHDL
            instruct_cycles = 0;
            instuct_count   = 0;
            ERRORS          = 0;
            NFILES          = 0;
            filemult        = 65536;
            HRESP_STATE     = OK1;
            reset_pulse     = 0;
            var_ltimer      = 0;
            var_licycles    = 0;


            //
            HCLK_STOP <= 1'b0 ; 
            DEBUG <= DEBUGLEVEL ; 
            HADDR_P0 <= {32{1'b0}} ; 
            HBURST_P0 <= {3{1'b0}} ; 
            HMASTLOCK_P0 <= 1'b0 ; 
            HPROT_P0 <= {4{1'b0}} ; 
            HSIZE_P0 <= {3{1'b0}} ; 
            HTRANS_P0 <= {2{1'b0}} ; 
            HWRITE_P0 <= 1'b0 ; 
            GPOUT_P0 <= {32{1'b0}} ; 
            INSTR_OUT <= {32{1'b0}} ; 
            WRITE_P0 <= 1'b0 ; 
            READ_P0 <= 1'b0 ; 
            RDATA_P0 <= {32{1'b0}} ; 
            MDATA_P0 <= {32{1'b0}} ; 
            WDATA_P0 <= {32{1'b0}} ; 
            GPIORD_P0 <= 1'b0 ; 
            EXTWR_P0 <= 1'b0 ; 
            EXTRD_P0 <= 1'b0 ; 
            EXTADDR_P0 <= {32{1'b0}} ; 
            EXT_DOUT <= {32{1'b0}} ; 
            FINISHED_P0 <= 1'b0 ; 
            FILENAME[1:8] <= {"UNKNOWN", 8'b0 } ; 
            READ_P1 <= 1'b0 ; 
            RDATA_P1 <= {32{1'b0}} ; 
            MDATA_P1 <= {32{1'b0}} ; 
            LINENO_P1 <= 0 ; 
            HADDR_P1 <= {32{1'b0}} ; 
            FAILED_P0 <= 1'b0 ; 
            HRESETN_P0 <= 1'b0 ; 
            CON_BUSY <= 1'b0 ; 
            LINENO_P1 <= 0 ; 
            POLL_P0 <= 1'b0 ; 
            POLL_P1 <= 1'b0 ; 
            DRIVEX_CLK <= 0 ; 
            DRIVEX_RST <= 0 ; 
            DRIVEX_ADD <= 0 ; 
            DRIVEX_DAT <= 0 ; 
            initdone = 0; 
            cptr = 0; 
            cmd_active = 0; 
            bfm_mode = 0; 
            do_case = 0; 
            do_flush = 0; 
            do_write = 0; 
            do_read = 0; 
            do_bwrite = 0; 
            do_bread = 0; 
            do_poll = 0; 
            do_idle = 0; 
            stkptr = 0; 
            hresp_mode = 0; 
            command_timeout = 512; 
            piped_activity = 0; 
            ERRORS = 0; 
            hresp_occured = 0; 
            ahb_lock = 1'b0; 
            ahb_prot = 4'b0011; 
            ahb_burst = 3'b001; 
            bfm_done = 0; 
            su_xsize = 2; 
            su_xainc = 4; 
            su_xrate = 0; 
            su_flush = 0; 
            su_align = 0;	                   
            su_endsim = 0;
            return_value = 0; 
            bfm_run = 0; 
            count_xrate = 0; 
            log_ahb = 0; 
            log_ext = 0; 
            log_gpio = 0; 
            log_bfm = 0; 
            logopen = NUL; 
            insert_busy = 0; 
            wait_time = 0; 
            lastrandom =1;
            setrandom =1;
            logopen =1;
            npass = 0;
            wptr_cstk = 0; 
            rptr_cstk = 0; 
            casedepth = 0;
            su_noburst = 0;
        end
        else
        begin
            CON_RDP1 <= CON_RD ; 
            CON_WRP1 <= CON_WR ; 
            EXTWR_P0 <= 1'b0 ; 
            EXTRD_P0 <= 1'b0 ; 
            GPIORD_P0 <= 1'b0 ; 
            GPIOWR_P0 <= 1'b0 ;
            do_io = 0; 
            if (~initdone)
            begin
                $display(" "); 
                $display("###########################################################################"); 
                $display("AMBA BFM Model"); 
                $display("Version %s %s",BFM_VERSION,BFM_DATE); 
                $display(" "); 
                $display("Opening BFM Script file %0s", VECTFILE); 
                if (~initdone & OPMODE != 2)
                begin
                    $readmemh(VECTFILE,vectors);
                    v = 3000;
                    initdone = 1; 
                    Nvectors        = vectors[4]; 
                    bfmc_version    = vectors[0] % 65536; 
                    vectors_version = vectors[0] / 65536; 
                    $display("Read %0d Vectors - Compiler Version %0d.%0d", Nvectors, vectors_version, bfmc_version); 
                    if (vectors_version != C_VECTORS_VERSION)
                    begin
                        $display("Incorrect vectors file format for this BFM %0s  (FAILURE) == ", VECTFILE); 
                        $stop;
                    end 
                    cptr   = vectors[1]; 
                    fptr   = vectors[2]; 
                    stkptr = vectors[3];	// Start Stack after required global storage area
                    stack[stkptr] = 0;	    // put a return address of zero on the stack
                    stkptr = stkptr +1;

                    if (cptr == 0)
                    begin
                        $display("BFM Compiler reported errors (FAILURE)"); 
                        $stop;
                    end 
                    // extract files names     
                    $display("BFM:Filenames referenced in Vectors"); 
                    command0 = vectors[fptr]; 
                    cmd_cmd  = vectors[fptr] % 256; 
                    while (cmd_cmd == C_FILEN)
                    begin
                        command_length = len_string(vectors[fptr+1]); 
                        str = extract_string(fptr); 
                        $display("  %0s", str); 
                        begin : xhdl_6
                            integer i,b;
                            for(i = 0; i<256; i=i+1)
                              for (b=1;b<=8;b=b+1) filenames[NFILES][i*8+b] = str[i*8+b];  
                        end 
                        NFILES = NFILES + 1; 
                        fptr = fptr + command_length; 
                        command0 = to_slv32(vectors[fptr]); 
                        cmd_cmd = vectors[fptr] % 256; 
                    end 
                    filemult = 65536; 
                    if (NFILES > 1)  filemult = 32768; 
                    if (NFILES > 2)  filemult = 16384; 
                    if (NFILES > 4)  filemult = 8912; 
                    if (NFILES > 8)  filemult = 4096; 
                    if (NFILES > 16) filemult = 2048; 
                    if (NFILES > 32) filemult = 1024; 
                    bfm_run = (OPMODE == 0); 
                end 
            end 
            if (OPMODE == 2 & ~initdone)
            begin
                filemult = 65536; 
                initdone = 1; 
                bfm_run = 0; 
                stkptr = vectors[3]+1;
                stack[stkptr] =0;
                stkptr = stkptr+1;
            end 
            //--------------------------------------------------------------------------
            // see whether reset needs deasserting
            if (reset_pulse <= 1)
            begin
                HRESETN_P0 <= 1'b1 ; 
            end
            else
            begin
                reset_pulse = reset_pulse - 1; 
            end 
     
            //----------------------------------------------------------------------------------------------------------
                
            case (HRESP_STATE)
                OK1 :
                            begin
                                if (HRESP == 1'b1 & HREADY == 1'b1)
                                begin
                                    $display("BFM: HRESP Signaling Protocol Error T2 (ERROR)"); 
                                    ERRORS = ERRORS + 1; 
                                end 
                                if (HRESP == 1'b1 & HREADY == 1'b0)
                                begin
                                    HRESP_STATE = OK2; 
                                end 
                            end
                OK2 :
                            begin
                                if (HRESP == 1'b0 | HREADY == 1'b0)
                                begin
                                    $display("BFM: HRESP Signaling Protocol Error T3 (ERROR)"); 
                                    ERRORS = ERRORS + 1; 
                                end 
                                if (HRESP == 1'b1 & HREADY == 1'b1)
                                begin
                                    HRESP_STATE = OK1; 
                                end 
                                case (hresp_mode)
                                    0 :
                                                begin
                                                    // should not have occured
                                                    $display("BFM: Unexpected HRESP Signaling Occured (ERROR)"); 
                                                    ERRORS = ERRORS + 1; 
                                                end
                                    1 :
                                                begin
                                                    // Ignore
                                                    hresp_occured = 1; 
                                                end
                                    default :
                                                begin
                                                    $display("BFM: HRESP mode is not correctly set (ERROR)"); 
                                                    ERRORS = ERRORS + 1; 
                                                end
                                endcase 
                            end
            endcase 
    
            //----------------------------------------------------------------------------------------------------------
         
            if (OPMODE > 0)
            begin
                if ((CON_WR == 1'b1) && ( CON_WRP1 == 1'b0 || CON_SPULSE ==1))
                begin
                    n = to_int(CON_ADDR); 
                    case (n)
                        0 :
                                    begin
                                        bfm_run = ((CON_DIN[0]) == 1'b1); 
                                        bfm_single = ((CON_DIN[1]) == 1'b1); 
                                        bfm_done = 0; 
                                        if ( bfm_run & ~bfm_single)
                                       	begin
	                                      stack[stkptr] = 0;		// null return address
	                                      stkptr = stkptr+1;
					                    end 
                                        //----------------------------------------------------------------------------------------
                                        // Handle the external command interface
                                        if (DEBUG >= 2 & bfm_run & ~bfm_single)
                                        begin
                                            $display("BFM: Starting script at %08x (%0d parameters)", cptr,npass); 
                                        end 
                                        if (DEBUG >= 2 & bfm_run & bfm_single)
                                        begin
                                            $display("BFM: Starting instruction at %08x", cptr); 
                                        end 
                                        if (bfm_run)
                                        begin
                                            if (npass > 0)
                                            begin
                                                // put the stored parameters on the stack
                                                begin : xhdl_7
                                                    integer i;
                                                    for(i = 0; i <= npass - 1; i = i + 1)
                                                    begin
                                                        stack[stkptr] = passed[i]; 
                                                        stkptr = stkptr + 1; 
                                                    end
                                                end 
                                                npass = 0; 
                                            end 
                                            wptr_cstk = 0; 
                                            rptr_cstk = 0; 
                                        end 
                                    end
                        1 :
                                    begin
                                        cptr = CON_DIN; 
                                    end
                        2 :
                                    begin
                                        passed[npass] = CON_DIN; 
                                        npass = npass + 1; 
                                    end
                        default :
                                    begin
                                        vectors[n] = to_int_signed(CON_DIN); 
                                    end
                    endcase 
                end 
                if ((CON_RD == 1'b1) && ( CON_RDP1 == 1'b0 || CON_SPULSE ==1))
                begin
                    n = to_int(CON_ADDR); 
                    case (n)
                        0 :
                                    begin
                                        CON_DOUT <= {32{1'b0}} ; 
                                        CON_DOUT[2] <= bfm_run ; 
                                        CON_DOUT[3] <= (ERRORS > 0) ; 
                                    end
                        1 :
                                    begin
                                        CON_DOUT <= cptr; 
                                    end
                        2 :
                                    begin
                                        CON_DOUT <= return_value; 
                                        npass = 0;
                                    end
                        3 :
                                    begin
                                        if (wptr_cstk > rptr_cstk)
                                        begin
                                            CON_DOUT <= returnstk[rptr_cstk] ; 
                                            rptr_cstk = rptr_cstk + 1; 
                                        end
                                        else
                                        begin
                                            $display("BFM: Overread Control return stack"); 
                                            CON_DOUT <= {32{1'b0}} ; 
                                        end 
                                    end
                        default :
                                    begin
                                        CON_DOUT <= {32{1'b0}} ; 
                                    end
                    endcase 
                end 
            end 
            //----------------------------------------------------------------------------------------
            // Decode the Commands and schedule activities
            // Command Processing no requirement on HREADY
            instruct_cycles    = instruct_cycles + 1; 
            instructions_timer = instructions_timer + 1; 
            zerocycle = 1; 
            while (zerocycle)
            begin
                zerocycle = 0; 
                if (~cmd_active & bfm_run)
                begin
                    for (i=0;i<=7;i=i+1) command[i]=0;
                    command0   = vectors[cptr]; 
                    cmd_size   = command0[1:0]; 
                    cmd_cmd    = command0[7:0]; 
                    cmd_scmd   = command0[15:8]; 
                    cmd_lineno = command0[31:16]; 
                    timer = command_timeout; 
                    instuct_count = instuct_count + 1; 
                    command_length = 1; 
                    storeaddr = -1; 
                    count_xrate = 0; 
                    if (DEBUG>=5) $display( "BFM: Instruction %0d Line Number %0d Command %0d", cptr, cmd_lineno, cmd_cmd); 
                    if (log_bfm)
                    begin
                      $fdisplay(flog,"%05d BF %4d %4d %3d", $time, cptr, cmd_lineno, cmd_cmd); 
                    end 
                    if (cmd_cmd >= 100)
                    begin
                        cmd_cmdx4 = cmd_cmd; 
                    end
                    else
                    begin
                        cmd_cmdx4 = 4 * (cmd_cmd / 4); 
                    end 
                    if (cmd_cmd != C_CHKT)
                    begin
                        instruct_cycles = 0; 
                    end 
                    // Move command from vectors to stack switching parameters if necessary
                    case (cmd_cmdx4)
                        C_PRINT, C_HEAD, C_FILEN, C_LOGF :     n = 8; 
                        C_WRTM, C_RDMC :  n = 4 + vectors[cptr + 1]; 
                        C_CALLP :         n = 3 + vectors[cptr + 2]; 
                        C_CALL :          n = 3; 
                        C_TABLE :         n = 2 + vectors[cptr + 1]; 
                        C_CALC :          n = 3 + vectors[cptr + 2]; 
                        C_ECHO :          n = 2 + vectors[cptr + 1]; 
                        C_EXTWM :         n = 3 + vectors[cptr + 1]; 
                        default :         n = 8; 
                    endcase 
                    if (n > 0)
                    begin
                        begin : xhdl_7aa
                            integer i;
                            for(i = 0; i <= n - 1; i = i + 1)
                            begin
                                if (i >= 1 & i <= 8)
                                begin
                                    command[i] = get_para_value(((command0[7 + i]) == 1'b1), vectors[cptr + i]); 
                                end
                                else
                                begin
                                    command[i] = vectors[cptr + i]; 
                                end 
                                commandLV[i] = to_slv32(command[i]); 
                            end
                        end 
                    end 
                    case (cmd_cmdx4)
                        C_FAIL :
                                    begin
                                        $display("BFM Compiler reported an error (FAILURE)"); 
                                        ERRORS = ERRORS + 1; 
                                        $stop;
                                    end
                        C_CONPU :
                                    begin
                                        command_length = 2; 
                                        zerocycle = 1; 
                                        returnstk[wptr_cstk] = command[1]; 
                                        wptr_cstk = wptr_cstk + 1; 
                                        if (DEBUG>=2) $display( "BFM:%0d:conifpush %0d", cmd_lineno,command[1]); 
                                
                                    end
                        C_RESET :
                                    begin
                                        command_length = 2; 
                                        HRESETN_P0 <= 1'b0 ; 
                                        reset_pulse = command[1]; 
                                        if (DEBUG>=2) $display( "BFM:%0d:RESET %0d", cmd_lineno,reset_pulse); 
                                    end
                        C_CLKS :
                                    begin
                                        command_length = 2; 
                                        HCLK_STOP <= commandLV[1][0] ; 
                                        if (DEBUG>=2) $display( "BFM:%0d:STOPCLK %0d ", cmd_lineno, commandLV[1][0]); 
                                    end
                        C_MODE :
                                    begin
                                        command_length = 2; 
                                        bfm_mode = command[1]; 
                                        if (DEBUG>=2) $display( "BFM:%0d:mode %0d (No effect in this version)", cmd_lineno, bfm_mode); 
                                    end
                        C_SETUP :
                                    begin
                                        zerocycle = 1; 
                                        command_length = 4; 
                                        n = command[1]; 
                                        x = command[2]; 
                                        y = command[3]; 
                                        if (DEBUG>=2) $display( "BFM:%0d:setup %0d %0d %0d ", cmd_lineno, n, x, y); 
                                        // Main Command Processing
                                        case (n)
                                            1 :
                                                        begin
                                                            command_length = 4; 
                                                            su_xsize = x; 
                                                            su_xainc = y; 
                                                            if (DEBUG>=2) $display( "BFM:%0d:Setup- Memory Cycle Transfer Size %0s %0d", cmd_lineno, to_char(su_xsize), su_xainc); 
                                                        end
                                            2 :
                                                        begin
                                                            command_length = 3; 
                                                            su_flush = to_boolean(x); 
                                                            if (DEBUG>=2) $display( "BFM:%0d:Setup- Automatic Flush %0d", cmd_lineno, su_flush); 
                                                        end
                                            3 :
                                                        begin
                                                            command_length = 3; 
                                                            su_xrate = x; 
                                                            if (DEBUG>=2) $display( "BFM:%0d:Setup- XRATE %0d", cmd_lineno, su_xrate); 
                                                        end
                                            4 :
                                                        begin
                                                            command_length = 3; 
                                                            su_noburst = x; 
                                                            if (DEBUG>=2) $display( "BFM:%0d:Setup- Burst Mode %0d", cmd_lineno, su_noburst); 
                                                        end
                                            5 :
                                                        begin
                                                            command_length = 3; 
                                                            su_align = x; 
                                                            if (DEBUG >= 2) $display( "BFM:%0d:Setup- Alignment %0d", cmd_lineno, su_align); 
                                                            if (su_align == 1 | su_align == 2)
                                                            begin
                                                                $display("BFM: Untested 8 or 16 Bit alignment selected (WARNING)"); 
                                                            end 
                                                        end
                                            6:          begin
                                                           command_length = 3;
                                                           // ignore VHDL endsim command
                                                        end
                                            7:          begin
                                                            command_length = 3; 
                                                            su_endsim =   x; 
                                                            if (DEBUG >= 2) $display( "BFM:%0d:Setup- End Sim Action %0d", cmd_lineno, su_endsim); 
                                                            if ( su_endsim > 2)
                                                            begin
                                                                $display("BFM: Unexpected End Simulation value (WARNING)"); 
                                                            end 
                                                        end
                                           
                                            default :
                                                        begin
                                                            $display("BFM Unknown Setup Command (FAILURE)"); 
                                                        end
                                        endcase 
                                    end
               
                        C_DRVX :
                                    begin
                                        zerocycle = 1; 
                                        command_length = 2; 
                                        DRIVEX_ADD <= ((commandLV[1][0]) == 1'b1) ; 
                                        DRIVEX_DAT <= ((commandLV[1][1]) == 1'b1) ; 
                                        DRIVEX_RST <= ((commandLV[1][2]) == 1'b1) ; 
                                        DRIVEX_CLK <= ((commandLV[1][3]) == 1'b1) ; 
                                        if (DEBUG >= 2) $display( "BFM:%0d:drivex %0d ", cmd_lineno,command[1]); 
                                    end
               
               
                        C_ERROR :
                                    begin
                                        zerocycle = 1; 
                                        command_length = 3; 
                                        if (DEBUG>=2) $display( "BFM:%0d:error %0d %0d (No effect in this version)", cmd_lineno, command[1], command[2]); 
                                    end
                        C_PROT :
                                    begin
                                        zerocycle = 1; 
                                        command_length = 2; 
                                        ahb_prot = commandLV[1][3:0]; 
                                        if (DEBUG>=2) $display( "BFM:%0d:prot %0d ", cmd_lineno, ahb_prot); 
                                    end
                        C_LOCK :
                                    begin
                                        zerocycle = 1; 
                                        command_length = 2; 
                                        ahb_lock = commandLV[1][0]; 
                                        if (DEBUG>=2) $display( "BFM:%0d:lock %0d ", cmd_lineno, ahb_lock); 
                                    end
                        C_BURST :
                                    begin
                                        zerocycle = 1; 
                                        command_length = 2; 
                                        ahb_burst = commandLV[1][2:0]; 
                                        if (DEBUG>=2) $display( "BFM:%0d:burst %0d ", cmd_lineno, ahb_burst); 
                                    end
                        C_WAIT :
                                    begin
                                        command_length = 2; 
                                        wait_counter = command[1]; 
                                        if (DEBUG>=2) $display( "BFM:%0d:wait %0d  starting at %0d ns", cmd_lineno, wait_counter,$time); 
                                        do_case = 1; 
                                    end
                        C_WAITUS :
                                    begin
                                        command_length = 2; 
                                        wait_time = command[1] * 1000 + ($time / 1); 
                                        if (DEBUG>=2) $display( "BFM:%0d:waitus %0d  starting at %0d ns", cmd_lineno, command[1],$time); 
                                        do_case = 1; 
                                    end
                        C_WAITNS :
                                    begin
                                        command_length = 2; 
                                        wait_time = command[1] * 1 + ($time / 1); 
                                        if (DEBUG>=2) $display( "BFM:%0d:waitns %0d  starting at %0d ns", cmd_lineno, command[1],$time); 
                                        do_case = 1; 
                                    end
                        C_CHKT :
                                    begin
                                        command_length = 3; 
                                        if (DEBUG>=2) $display( "BFM:%0d:checktime %0d %0d at %0d ns", cmd_lineno, command[1], command[2],$time); 
                                        do_case = 1;
                                    end
                  
                        C_STTIM :
                                    begin
                                        zerocycle = 1; 
                                        command_length = 1; 
                                        instructions_timer = 1; 
                                        if (DEBUG>=2) $display("BFM:%0d:starttimer at %0d ns", cmd_lineno,$time); 
                                    end
                        C_CKTIM :
                                    begin
                                        command_length = 3; 
                                        if (DEBUG>=2) $display("BFM:%0d:checktimer %0d %0d at %0d ns ", cmd_lineno, command[1], command[2],$time); 
                                        do_case = 1; 
                                    end
                  
                        C_NOP :
                                    begin
                                        command_length = 1; 
                                        if (DEBUG>=2) $display( "BFM:%0d:nop", cmd_lineno); 
                                    end
                        C_WRITE :
                                    begin
                                        command_length = 4; 
                                        command_size = xfer_size(cmd_size, su_xsize); 
                                        command_address = to_slv32(command[1] + command[2]); 
                                        command_data = commandLV[3]; 
                                        if (DEBUG>=2) $display( "BFM:%0d:write %c %08x %08x at %0d ns", cmd_lineno, to_char(cmd_size), command_address, command_data,$time); 
                                        do_write = 1; 
                                    end
      
                        C_AHBC :
                                    begin
                                        command_length = 5; 
                                        command_size = xfer_size(cmd_size, su_xsize); 
                                        command_address = to_slv32(command[1] + command[2]); 
                                        command_data = commandLV[3]; 
                                        ahbc_hwrite = commandLV[4][0]; 
                                        ahbc_htrans = commandLV[4][5:4]; 
                                        ahbc_burst = commandLV[4][10:8]; 
                                        ahbc_lock = commandLV[4][12]; 
                                        ahbc_prot = commandLV[4][19:16]; 
                                        if (DEBUG>=2) $display( "BFM:%0d:idle %c %08x %08x %08x at %0d ns",cmd_lineno, to_char(cmd_size),
                                                                                                          command_address,command_data, commandLV[4],$time); 
                                        do_idle = 1; 
                                    end
      
                        C_READ :
                                    begin
                                        command_length = 3; 
                                        command_size = xfer_size(cmd_size, su_xsize); 
                                        command_address = to_slv32(command[1] + command[2]); 
                                        command_data = {32{1'b0}}; 
                                        command_mask = {32{1'b0}}; 
                                        if (DEBUG>=2) $display("BFM:%0d:read %c %08x at %0d ns", cmd_lineno, to_char(cmd_size), command_address,$time); 
                                        do_read = 1; 
                                    end
                        C_READS :
                                    begin
                                        command_length = 4; 
                                        command_size = xfer_size(cmd_size, su_xsize); 
                                        command_address = to_slv32(command[1] + command[2]); 
                                        command_data = {32{1'b0}}; 
                                        command_mask = {32{1'b0}}; 
                                        storeaddr = get_storeaddr(vectors[cptr + 3],stkptr); // take pointer from vectors
                                        if (DEBUG>=2) $display( "BFM:%0d:readstore %c %08x @%0d at %0d ns ", 
                                                cmd_lineno, to_char(cmd_size), command_address, storeaddr,$time); 
                                        do_read = 1; 
                                        do_flush = 1; 
                                    end
                        C_RDCHK :
                                    begin
                                        command_length = 4; 
                                        command_size = xfer_size(cmd_size, su_xsize); 
                                        command_address = to_slv32(command[1] + command[2]); 
                                        command_data = commandLV[3]; 
                                        command_mask = {32{1'b1}}; 
                                        if (DEBUG>=2) $display( "BFM:%0d:readcheck %c %08x %08x at %0d ns", cmd_lineno, to_char(cmd_size), command_address, command_data,$time); 
                                        do_read = 1; 
                                    end
                        C_RDMSK :
                                    begin
                                        command_length = 5; 
                                        command_size = xfer_size(cmd_size, su_xsize); 
                                        command_address = to_slv32(command[1] + command[2]); 
                                        command_data = commandLV[3]; 
                                        command_mask = commandLV[4]; 
                                        if (DEBUG>=2) $display( "BFM:%0d:readmask %c %08x %08x %08x at %0d ns", cmd_lineno, to_char(cmd_size), command_address, command_data, command_mask,$time); 
                                        do_read = 1; 
                                    end
                        C_POLL :
                                    begin
                                        command_length = 4; 
                                        command_size = xfer_size(cmd_size, su_xsize); 
                                        command_address = to_slv32(command[1] + command[2]); 
                                        command_data = commandLV[3]; 
                                        command_mask = {32{1'b1}}; 
                                        if (DEBUG>=2) $display( "BFM:%0d:poll %c %08x %08x at %0d ns", cmd_lineno, to_char(cmd_size), command_address, command_data,$time); 
                                        cmd_active = 1; 
                                        do_poll = 1; 
                                        do_poll = 1; 
                                    end
                        C_POLLM :
                                    begin
                                        command_length = 5; 
                                        command_size = xfer_size(cmd_size, su_xsize); 
                                        command_address = to_slv32(command[1] + command[2]); 
                                        command_data = commandLV[3]; 
                                        command_mask = commandLV[4]; 
                                        if (DEBUG>=2) $display( "BFM:%0d:pollmask %c %08x %08x %08x at %0d ns", cmd_lineno, to_char(cmd_size), command_address, command_data, command_mask,$time); 
                                        do_poll = 1; 
                                    end
                        C_POLLB :
                                    begin
                                        command_length = 5; 
                                        command_size = xfer_size(cmd_size, su_xsize); 
                                        command_address = to_slv32(command[1] + command[2]); 
                                        command_data = {32{1'b0}}; 
                                        command_mask = {32{1'b0}}; 
                                        bitn = command[3]; 
                                        command_mask[bitn] = 1'b1; 
                                        command_data[bitn] = commandLV[4][0]; 
                                        if (DEBUG>=2) $display( "BFM:%0d:pollbit %c %08x %0d %0d at %0d ns", cmd_lineno, to_char(cmd_size), command_address, bitn, command_data[bitn],$time); 
                                        do_poll = 1; 
                                    end
                        C_WRTM :
                                    begin
                                        burst_length = command[1]; 
                                        command_length = 4 + burst_length; 
                                        command_size = xfer_size(cmd_size, su_xsize); 
                                        command_address = to_slv32(command[2] + command[3]); 
                                        burst_count = 0; 
                                        burst_addrinc = address_increment(cmd_size, su_xainc); 
                                        begin : xhdl_8
                                            integer i;
                                            for(i = 0; i <= burst_length - 1; i = i + 1)
                                            begin
                                                burst_data[i] = command[i + 4]; 
                                            end
                                        end 
                                        if (DEBUG>=2) $display( "BFM:%0d:writemultiple %c %08x %08x ... at %0d ns", cmd_lineno, to_char(cmd_size), command_address, burst_data[0],$time); 
                                        do_bwrite = 1; 
                                    end
                        C_FILL :
                                    begin
                                        burst_length = command[3]; 
                                        command_length = 6; 
                                        command_size = xfer_size(cmd_size, su_xsize); 
                                        command_address = to_slv32(command[1] + command[2]); 
                                        burst_count = 0; 
                                        burst_addrinc = address_increment(cmd_size, su_xainc); 
                                        data_start = command[4]; 
                                        data_inc = command[5]; 
                                        begin : xhdl_9
                                            integer i;
                                            for(i = 0; i <= burst_length - 1; i = i + 1)
                                            begin
                                                burst_data[i] = data_start; 
                                                data_start = data_start + data_inc; 
                                            end
                                        end 
                                        if (DEBUG>=2) $display( "BFM:%0d:fill %c %08x %0d %0d %0d at %0d ns", cmd_lineno, to_char(cmd_size), command_address, burst_length, command[4], command[4],$time); 
                                        do_bwrite = 1; 
                                    end
                        C_WRTT :
                                    begin
                                        burst_length = command[4]; 
                                        command_length = 5; 
                                        command_size = xfer_size(cmd_size, su_xsize); 
                                        command_address = to_slv32(command[1] + command[2]); 
                                        burst_count = 0; 
                                        burst_addrinc = address_increment(cmd_size, su_xainc); 
                                        tableid = command[3]; 
                                        begin : xhdl_10
                                            integer i;
                                            for(i = 0; i <= burst_length - 1; i = i + 1)
                                            begin
                                                burst_data[i] = vectors[2 + tableid + i]; 
                                            end
                                        end 
                                        if (DEBUG>=2) $display( "BFM:%0d:writetable %c %08x %0d %0d at %0d ns ", cmd_lineno, to_char(cmd_size), command_address, tableid, burst_length,$time); 
                                        do_bwrite = 1; 
                                    end
                      
                        C_WRTA :
                                    begin
                                        burst_length = command[4]; 
                                        command_length = 5; 
                                        command_size = xfer_size(cmd_size, su_xsize); 
                                        command_address = to_slv32(command[1] + command[2]); 
                                        burst_count = 0; 
                                        burst_addrinc = address_increment(cmd_size, su_xainc); 
                                        setvar = get_storeaddr(vectors[cptr + 3],stkptr); 
                                        begin : xhdl_10a
                                            integer i;
                                            for(i = 0; i <= burst_length - 1; i = i + 1)
                                            begin
                                                burst_data[i] = stack[setvar + i]; 
                                            end
                                        end 
                                        if (DEBUG>=2) $display( "BFM:%0d:writearray %c %08x %0d %0d at %0d ns ", 
                                                                 cmd_lineno, to_char(cmd_size), command_address,setvar, burst_length,$time); 
                                        do_bwrite = 1; 
                                    end
                      
                      
                        C_RDM :
                                    begin
                                        burst_length = command[3]; // note this is a fixed length instruction
                                        command_length = 4; 
                                        command_size = xfer_size(cmd_size, su_xsize); 
                                        command_address = to_slv32(command[1] + command[2]); 
                                        command_mask = {32{1'b0}}; 
                                        burst_count = 0; 
                                        burst_addrinc = address_increment(cmd_size, su_xainc); 
                                        command_mask = {32{1'b0}}; 
                                        if (DEBUG>=2) $display( "BFM:%0d:readmult %c %08x %0d at %0d ns", cmd_lineno, to_char(cmd_size), command_address, burst_length,$time); 
                                        do_bread = 1; 
                                    end
                        C_RDMC :
                                    begin
                                        burst_length = command[1]; 
                                        command_length = 4 + burst_length; 
                                        command_size = xfer_size(cmd_size, su_xsize); 
                                        command_address = to_slv32(command[2] + command[3]); 
                                        command_mask = {32{1'b1}}; 
                                        burst_count = 0; 
                                        burst_addrinc = address_increment(cmd_size, su_xainc); 
                                        command_mask = {32{1'b1}}; 
                                        begin : xhdl_11
                                            integer i;
                                            for(i = 0; i <= burst_length - 1; i = i + 1)
                                            begin
                                                burst_data[i] = command[i + 4]; 
                                            end
                                        end 
                                        if (DEBUG>=2) $display( "BFM:%0d:readmultchk %c %08x %08x ... at %0d ns", cmd_lineno, to_char(cmd_size), command_address, burst_data[0],$time); 
                                        do_bread = 1; 
                                    end
                        C_READF :
                                    begin
                                        burst_length = command[3]; 
                                        command_length = 6; 
                                        command_size = xfer_size(cmd_size, su_xsize); 
                                        command_address = to_slv32(command[1] + command[2]); 
                                        command_mask = {32{1'b1}}; 
                                        burst_count = 0; 
                                        burst_addrinc = address_increment(cmd_size, su_xainc); 
                                        data_start = command[4]; 
                                        data_inc = command[5]; 
                                        begin : xhdl_12
                                            integer i;
                                            for(i = 0; i <= burst_length - 1; i = i + 1)
                                            begin
                                                burst_data[i] = data_start; 
                                                data_start = data_start + data_inc; 
                                            end
                                        end 
                                        if (DEBUG>=2) $display( "BFM:%0d:fillcheck %c %08x %0d %0d %0d at %0d ns", cmd_lineno, to_char(cmd_size), command_address, burst_length, command[4], command[5],$time); 
                                        do_bread = 1; 
                                    end
                        C_READT :
                                    begin
                                        burst_length = command[4]; 
                                        command_length = 5; 
                                        command_size = xfer_size(cmd_size, su_xsize); 
                                        command_address = to_slv32(command[1] + command[2]); 
                                        command_mask = {32{1'b1}}; 
                                        burst_count = 0; 
                                        burst_addrinc = address_increment(cmd_size, su_xainc); 
                                        tableid = command[3]; 
                                        begin : xhdl_13
                                            integer i;
                                            for(i = 0; i <= burst_length - 1; i = i + 1)
                                            begin
                                                burst_data[i] = vectors[tableid + 2 + i]; 
                                            end
                                        end 
                                        if (DEBUG>=2) $display( "BFM:%0d:readtable %c %08x %0d %0d at %0d ns", cmd_lineno, to_char(cmd_size), command_address, tableid, burst_length,$time); 
                                        do_bread = 1; 
                                    end
                        C_READA :
                                    begin
                                        burst_length = command[4]; 
                                        command_length = 5; 
                                        command_size = xfer_size(cmd_size, su_xsize); 
                                        command_address = to_slv32(command[1] + command[2]); 
                                        command_mask = {32{1'b1}}; 
                                        burst_count = 0; 
                                        burst_addrinc = address_increment(cmd_size, su_xainc); 
                                        setvar = get_storeaddr(vectors[cptr + 3],stkptr); 
                                        begin : xhdl_13s
                                            integer i;
                                            for(i = 0; i <= burst_length - 1; i = i + 1)
                                            begin
                                                burst_data[i] = stack[setvar + i];  
                                            end
                                        end 
                                        if (DEBUG>=2) $display( "BFM:%0d:readtable %c %08x %0d %0d at %0d ns", 
                                                                           cmd_lineno, to_char(cmd_size), command_address, setvar, burst_length,$time); 
                                        do_bread = 1; 
                                    end
                        C_MEMT :
                                    begin
                                        command_length = 7; 
                                        do_case = 1; 
                                        mt_state = init; 
                                    end
                        C_MEMT2 :
                                    begin
                                        command_length = 7; 
                                        do_case = 1; 
                                        mt_state = init; 
                                    end
                        C_FIQ :
                                    begin
                                        command_length = 1; 
                                        int_vector = 0; 
                                        if (DEBUG>=2) $display( "BFM:%0d:waitfiq at %0d ns ", cmd_lineno,$time); 
                                        do_case = 1; 
                                    end
                        C_IRQ :
                                    begin
                                        command_length = 1; 
                                        int_vector = 1; 
                                        if (DEBUG>=2) $display( "BFM:%0d:waitirq at %0d ns ", cmd_lineno,$time); 
                                        do_case = 1; 
                                    end
                        C_INTREQ :
                                    begin
                                        command_length = 2; 
                                        int_vector = command[1]; 
                                        if (DEBUG>=2) $display( "BFM:%0d:waitint %0d  at %0d ns", cmd_lineno, int_vector,$time); 
                                        do_case = 1; 
                                    end
                        C_IOWR :
                                    begin
                                        command_length = 2; 
                                        command_data = commandLV[1]; 
                                        GPOUT_P0 <= command_data ; 
                                        GPIOWR_P0 <= 1'b1 ; 
                                        if (DEBUG>=2) $display( "BFM:%0d:iowrite %08x  at %0d ns ", cmd_lineno, command_data,$time); 
                                    end                                                                                  
                        C_IORD :
                                    begin
                                        command_length = 2; 
                                        command_data = {32{1'b0}}; 
                                        command_mask = {32{1'b0}}; 
                                        storeaddr = get_storeaddr(vectors[cptr + 1],stkptr); // take pointer from vectors
                                        if (DEBUG>=2) $display( "BFM:%0d:ioread @%0d at %0d ns", cmd_lineno, storeaddr,$time); 
                                        GPIORD_P0 <= 1'b1 ; 
                                        do_case = 1; 
                                        do_flush = 1; 
                                        do_io = 1;
                                    end
                        C_IOCHK :
                                    begin
                                        command_length = 2; 
                                        command_data = commandLV[1]; 
                                        command_mask = {32{1'b1}}; 
                                        GPIORD_P0 <= 1'b1 ; 
                                        if (DEBUG>=2) $display( "BFM:%0d:iocheck %08x  at %0d ns ", cmd_lineno, command_data,$time); 
                                        do_case = 1; 
                                    end
                        C_IOMSK :
                                    begin
                                        command_length = 3; 
                                        command_data = commandLV[1]; 
                                        command_mask = commandLV[2]; 
                                        if (DEBUG>=2) $display( "BFM:%0d:iomask %08x %08x  at %0d ns", cmd_lineno, command_data, command_mask,$time); 
                                        GPIORD_P0 <= 1'b1 ; 
                                        do_case = 1; 
                                    end
                        C_IOTST :
                                    begin
                                        command_length = 2; 
                                        command_data = {32{1'b0}}; 
                                        command_mask = {32{1'b0}}; 
                                        bitn = command[1]; 
                                        command_data[bitn] = command0[0]; 
                                        command_mask[bitn] = 1'b1; 
                                        GPIORD_P0 <= 1'b1 ; 
                                        if (DEBUG>=2) $display( "BFM:%0d:iotest %0d %0d  at %0d ns", cmd_lineno, bitn, command0[0],$time); 
                                        do_case = 1; 
                                    end
                        C_IOSET :
                                    begin
                                        command_length = 2; 
                                        bitn = command[1]; 
                                        GPOUT_P0[bitn] <= 1'b1 ; 
                                        GPIOWR_P0 <= 1'b1 ; 
                                        if (DEBUG>=2) $display( "BFM:%0d:ioset %0d at %0d ns", cmd_lineno, bitn,$time); 
                                    end
                        C_IOCLR :
                                    begin
                                        command_length = 2; 
                                        bitn = command[1]; 
                                        GPOUT_P0[bitn] <= 1'b0 ; 
                                        GPIOWR_P0 <= 1'b1 ; 
                                        if (DEBUG>=2) $display( "BFM:%0d:ioclr %0d at %0d ns", cmd_lineno, bitn,$time); 
                                    end
                        C_IOWAIT :
                                    begin
                                        command_length = 2; 
                                        command_data = {32{1'b0}}; 
                                        command_mask = {32{1'b0}}; 
                                        bitn = command[1]; 
                                        command_data[bitn] = command0[0]; 
                                        command_mask[bitn] = 1'b1; 
                                        if (DEBUG>=2) $display( "BFM:%0d:iowait %0d %0d at %0d ns ", cmd_lineno, bitn, command0[0],$time); 
                                        GPIORD_P0 <= 1'b1 ; 
                                        do_case = 1; 
                                    end
                        C_EXTW :
                                    begin
                                        command_length = 3; 
                                        command_address = commandLV[1]; 
                                        command_data = commandLV[2]; 
                                        if ( DEBUG >=2) $display("BFM:%0d:extwrite %08x %08x at %0d ns", cmd_lineno, command_address, command_data,$time); 
                                        do_case = 1; 
                                    end
                        C_EXTR :
                                    begin
                                        command_length = 3; 
                                        command_address = commandLV[1]; 
                                        command_data = {32{1'b0}}; 
                                        command_mask = {32{1'b0}}; 
                                        storeaddr =get_storeaddr(vectors[cptr + 2],stkptr); // take pointer from vectors
                                        EXTRD_P0 <= 1'b1 ; 
                                        if ( DEBUG >=2) $display("BFM:%0d:extread @%0d %08x at %0d ns ", cmd_lineno, storeaddr, command_address,$time); 
                                        do_case = 1; 
                                        do_flush = 1; 
                                        do_io = 1;
                                    end
                       
                        C_EXTWM :
                                    begin
                                        burst_length = command[1]; 
                                        burst_address = command[2]; 
                                        command_length = burst_length + 3; 
                                        begin : xhdl_14
                                            integer i;
                                            for(i = 0; i < burst_length ; i = i + 1)
                                            begin
                                                burst_data[i] = command[i + 3]; 
                                            end
                                        end 
                                        if (DEBUG >= 2) $display("BFM:%0d:extwrite %08x %0d Words at %0t ns", cmd_lineno,command_address, burst_length, $time); 
                                        burst_count = 0; 
                                        do_case = 1; 
                                    end
                   
                        C_EXTRC :
                                    begin
                                        command_length = 3; 
                                        command_address = commandLV[1]; 
                                        command_data = commandLV[2]; 
                                        command_mask = {32{1'b1}}; 
                                        cmd_active = 1; 
                                        EXTRD_P0 <= 1'b1 ; 
                                        if ( DEBUG >=2) $display("BFM:%0d:extcheck %08x %08x at %0d ns", cmd_lineno, command_address, command_data,$time); 
                                        do_case = 1; 
                                    end
                        C_EXTMSK :
                                    begin
                                        command_length = 4; 
                                        command_address = commandLV[1]; 
                                        command_data = commandLV[2]; 
                                        command_mask = commandLV[3]; 
                                        EXTRD_P0 <= 1'b1 ; 
                                        if ( DEBUG >=2) $display("BFM:%0d:extmask %08x %08x %08x at %0d ns", cmd_lineno, command_address, command_data, command_mask,$time); 
                                        do_case = 1; 
                                    end
                        C_EXTWT :
                                    begin
                                        command_length = 1; 
                                        wait_counter = 1; 
                                        cmd_active = 1; 
                                        if ( DEBUG >=2) $display("BFM:%0d:extwait ", cmd_lineno); 
                                        do_case = 1; 
                                    end
                        C_LABEL :
                                    begin
                                        $display("LABEL instructions not allowed in vector files (FAILURE)"); 
                                    end
                        C_TABLE :
                                    begin
                                        zerocycle = 1; 
                                        command_length = 2 + command[1]; 
                                        if (DEBUG>=2) $display( "BFM:%0d:table %08x ... (length=%0d)", cmd_lineno, command[2], command_length - 2); 
                                    end
                        C_JMP :
                                    begin
                                        zerocycle = 1; 
                                        command_length = 2; 
                                        jump_address = command[1]; 
                                        command_length = jump_address - cptr; // point at new address
                                        if (DEBUG>=2) $display( "BFM:%0d:jump", cmd_lineno); 
                                    end
                        C_JMPZ :
                                    begin
                                        zerocycle = 1; 
                                        command_length = 3; 
                                        jump_address = command[1]; 
                                        if (command[2] == 0)
                                        begin
                                            command_length = jump_address - cptr; // point at new address
                                        end 
                                        if (DEBUG>=2) $display( "BFM:%0d:jumpz  %08x", cmd_lineno, command[2]); 
                                    end
                        C_IF :
                                    begin
                                        zerocycle = 1; 
                                        command_length = 5; 
                                        jump_address = command[1]; 
                                        newvalue = calculate(command[3], command[2], command[4], DEBUG); 
                                        if (newvalue == 0)
                                        begin
                                            command_length = jump_address + 2 - cptr; // point at new address
                                        end 
                                        if (DEBUG>=2) $display("BFM:%0d:if %08x func %08x", cmd_lineno, command[2], command[4]); 
                                    end
                        C_IFNOT :
                                    begin
                                        zerocycle = 1; 
                                        command_length = 5; 
                                        jump_address = command[1]; 
                                        newvalue = calculate(command[3], command[2], command[4], DEBUG); 
                                        if (newvalue != 0)
                                        begin
                                            command_length = jump_address + 2 - cptr; // point at new address
                                        end 
                                        if (DEBUG>=2) $display("BFM:%0d:ifnot %08x func %08x", cmd_lineno, command[2], command[4]); 
                                    end
                     
                        C_ELSE :
                                    begin
                                        zerocycle = 1; 
                                        command_length = 2; 
                                        jump_address = command[1]; 
                                        command_length = jump_address + 2 - cptr; // point at new address
                                        if (DEBUG>=2) $display("BFM:%0d:else ",cmd_lineno); 
                                    end
                      
                        C_ENDIF :
                                    begin
                                        zerocycle = 1; // do nothing endif is pad instruction stream so +2 works
                                        command_length = 2; 
                                        if (DEBUG>=2) $display("BFM:%0d:endif ",cmd_lineno); 
                                    end
                        C_WHILE :
                                    begin
                                        zerocycle = 1; 
                                        command_length = 5; 
                                        jump_address = command[1] + 2; // after endwhile
                                        newvalue = calculate(command[3], command[2], command[4], DEBUG); 
                                        if (newvalue == 0)
                                        begin
                                            command_length = jump_address - cptr; // point at new address
                                        end 
                                        if (DEBUG>=2) $display("BFM:%0d:while %08x func %08x", cmd_lineno, command[2], command[4]); 
                                    end
                        C_ENDWHILE :
                                    begin
                                        zerocycle = 1; 
                                        command_length = 2; 
                                        jump_address = command[1]; 
                                        command_length = jump_address - cptr; // point at new address
                                        if (DEBUG>=2) $display( "BFM:%0d:endwhile", cmd_lineno); 
                                    end
                  
                        C_WHEN :
                                    begin
                                        zerocycle = 1; 
                                        command_length = 4; 
                                        jump_address = command[3]; 
                                        if (command[1] != command[2])
                                        begin
                                            command_length = jump_address - cptr; // point at new address ie next when/endcase
                                        end 
                                        else
                                        begin
                                            casedone[casedepth] = 1; // doing this branch
                                        end 
                                        if (DEBUG>=2) $display( "BFM:%0d:when %08x=%08x %08x", cmd_lineno, command[1], command[2], command[3]); 
                                    end
                  
                        C_DEFAULT :
                                    begin
                                        zerocycle = 1; 
                                        command_length = 4; 
                                        jump_address = command[3]; 
                                        if (casedone[casedepth])
                                        begin
                                            // if already done then branch
                                            command_length = jump_address - cptr; // point at new address ie next when/endcase
                                        end
                                        else
                                        begin
                                            casedone[casedepth] = 0; // doing this branch
                                        end 
                                        if (DEBUG>=2) $display("BFM:%0d:default %08x=%08x %08x", cmd_lineno, command[1], command[2],command[3]); 
                                    end
                        C_CASE :
                                    begin
                                        zerocycle = 1; 
                                        command_length = 1; 
                                        casedepth = casedepth + 1; 
                                        casedone[casedepth] = 0; 
                                        if (DEBUG>=2) $display( "BFM:%0d:case", cmd_lineno); 
                                    end
                        C_ENDCASE :
                                    begin
                                        zerocycle = 1; 
                                        command_length = 1; 
                                        casedepth = casedepth - 1; 
                                        if (DEBUG>=2) $display("BFM:%0d:endcase", cmd_lineno); 
                                    end
                  
                        C_JMPNZ :
                                    begin
                                        zerocycle = 1; 
                                        command_length = 3; 
                                        jump_address = command[1]; 
                                        if (command[2] != 0)
                                        begin
                                            command_length = jump_address - cptr; // point at new address
                                        end 
                                        if (DEBUG>=2) $display( "BFM:%0d:jumpnz  %08x", cmd_lineno, command[2]); 
                                    end
                        C_CMP :
                                    begin
                                        zerocycle = 1; 
                                        command_length = 4; 
                                        command_data = commandLV[2]; 
                                        command_mask = commandLV[3]; 
                                        cmpvalue = (commandLV[1] ^ command_data) & command_mask; 
                                        if ( DEBUG >=2) $display("BFM:%0d:compare  %08x==%08x Mask=%08x (RES=%08x) at %0d ns", cmd_lineno, command[1], command_data, command_mask, cmpvalue,$time); 
                                        if (cmpvalue != 0)
                                        begin
                                            ERRORS = ERRORS + 1; 
                                            $display("ERROR:  compare failed %08x==%08x Mask=%08x (RES=%08x) ", command[1], command_data, command_mask, cmpvalue); 
                                            $display("       Stimulus file %0s  Line No %0d", filenames[get_file(cmd_lineno, filemult)], get_line(cmd_lineno, filemult)); 
                                            $display("BFM Data Compare Error (ERROR)"); 
                                            $stop;
                                        end 
                                    end
                        C_CMPR :
                                    begin
                                        zerocycle = 1; 
                                        command_length = 4; 
                                        command_data = commandLV[2]; 
                                        command_mask = commandLV[3]; 
                                        if (command[1] >= command[2] & command[1] <= command[3])
                                        begin
                                            cmpvalue = 1; 
                                        end
                                        else
                                        begin
                                            cmpvalue = 0; 
                                        end 
                                        if ( DEBUG >=2) $display("BFM:%0d:cmprange %0d in %0d to %0d at %0d ns", cmd_lineno, command[1], command[2], command[3],$time); 
                                        if (cmpvalue == 0)
                                        begin
                                            ERRORS = ERRORS + 1; 
                                            $display("ERROR: cmprange failed %0d in %0d to %0d", command[1], command[2], command[3]); 
                                            $display("       Stimulus file %0s  Line No %0d", filenames[get_file(cmd_lineno, filemult)], get_line(cmd_lineno, filemult)); 
                                            $display("BFM Data Compare Error (ERROR)"); 
                                            $stop;
                                        end 
                                    end
                        C_INT :
                                    begin
                                        zerocycle = 1; 
                                        command_length = 2; 
                                        nparas = command[1]; 
                                        stkptr = stkptr + nparas; 
                                        stack[stkptr] = 0; 
                                        if (DEBUG>=2) $display( "BFM:%0d:int %0d", cmd_lineno, command[1]); 
                                    end
                                    	
                        C_CALL, C_CALLP :
                                    begin
                                        zerocycle = 1; 
                                        if (cmd_cmd == C_CALL)
                                        begin
                                            command_length = 2; 
                                            nparas = 0; 
                                        end
                                        else
                                        begin
                                            nparas = command[2]; 
                                            command_length = 3 + nparas; 
                                        end 
                                        call_address = command[1]; 
                                        return_address = cptr + command_length; 
                                        command_length = call_address - cptr; // point at new address
                                        stack[stkptr] = return_address; 
                                        stkptr = stkptr + 1; 
                                        if (nparas > 0)
                                        begin
                                            begin : xhdl_16
                                                integer i;
                                                for(i = 0; i <= nparas - 1; i = i + 1)
                                                begin
                                                    stack[stkptr] = command[3 + i]; 
                                                    stkptr = stkptr + 1; 
                                                end
                                            end 
                                        end 
                                        if (DEBUG >= 2 & cmd_cmd == C_CALL)  $display("BFM:%0d:call %0d", cmd_lineno, call_address); 
                                        if (DEBUG >= 2 & cmd_cmd == C_CALLP) $display("BFM:%0d:call %0d %08x ...", cmd_lineno, call_address, command[3]); 
                                    end
                        C_RET :
                                    begin
                                        zerocycle = 1; 
                                        command_length = 2; 
                                        stkptr = stkptr - command[1]; // no of values pushed
                                        return_address = 0; 
                                        if (stkptr > 0)
                                        begin
                                            stkptr = stkptr - 1; 
                                            return_address = stack[stkptr]; 
                                        end 
                                        if (return_address == 0)
                                        begin
                                            bfm_done = 1; 
                                            do_flush = 1; 
                                            zerocycle = 0; 
                                        end
                                        else
                                        begin
                                            command_length = return_address - cptr; // point at new address
                                        end 
                                        if (DEBUG>=2) $display( "BFM:%0d:return", cmd_lineno); 
                                    end
                        C_RETV :
                                    begin
                                        zerocycle = 1; 
                                        command_length = 3; 
                                        stkptr = stkptr - command[1]; // no of values pushed
                                        return_address = 0; 
                                        if (stkptr > 0)
                                        begin
                                            stkptr = stkptr - 1; 
                                            return_address = stack[stkptr]; 
                                        end 
                                        return_value = command[2]; 
                                        if (return_address == 0)
                                        begin
                                            bfm_done = 1; 
                                            do_flush = 1; 
                                            zerocycle = 0; 
                                        end
                                        else
                                        begin
                                            command_length = return_address - cptr; // point at new address
                                        end 
                                        if (DEBUG>=2) $display( "BFM:%0d:return %08x", cmd_lineno, return_value); 
                                    end
                        C_LOOP :
                                    begin
                                        zerocycle = 1; 
                                        command_length = 5; 
                                        setvar = get_storeaddr(vectors[cptr + 1],stkptr); 
                                        newvalue = command[2]; 
                                        stack[setvar] = newvalue; 
                                        if (DEBUG >= 2)  $display("BFM:%0d:loop %0d %0d %0d %0d ", cmd_lineno, setvar, command[2], command[3], command[4]); 
                                    end
                        C_LOOPE :
                                    begin
                                        zerocycle = 1; 
                                        command_length = 2; 
                                        lptr = command[1]; // points at the loop commands
                                        // Get parameters from the loop command
                                        begin : xhdl_19a
                                            integer i;
                                            for(i = 2; i <= 4; i = i + 1)
                                            begin
                                                Loopcmd[i] = get_para_value((to_slv32(vectors[lptr][7 + i]) == 1'b1), vectors[lptr + i]); 
                                            end
                                        end 
                                        setvar = get_storeaddr(vectors[lptr + 1],stkptr); 
                                        n = Loopcmd[4]; 
                                        j = Loopcmd[3]; 
                                        //$display("OLD LOOP %0d  INC %0d  LIMIT %0d",stack(setvar)),n),j);
                                        loopcounter = stack[setvar]; 
                                        loopcounter = loopcounter + n; 
                                        stack[setvar] = loopcounter; 
                                        jump_address = lptr + 5; 
                                        if ((n >= 0 & loopcounter <= j) | (n < 0 & loopcounter >= j))
                                        begin
                                            command_length = jump_address - cptr; // point at new address
                                            if ( DEBUG >=2) $display("BFM:%0d:endloop (Next Loop=%0d)", cmd_lineno, loopcounter); 
                                        end
                                        else
                                        begin
                                            if ( DEBUG >=2) $display("BFM:%0d:endloop (Finished)", cmd_lineno); 
                                        end 
                                    end
                        C_TOUT :
                                    begin
                                        zerocycle = 1; 
                                        command_length = 2; 
                                        command_timeout = command[1]; 
                                        if ( DEBUG >=2) $display("BFM:%0d:timeout %0d", cmd_lineno, command_timeout); 
                                    end
                     
                        C_RAND :
                                    begin
                                        zerocycle = 1; 
                                        command_length = 2; 
                                        lastrandom = command[1]; 
                                        if ( DEBUG >=2) $display("BFM:%0d:rand %0d",cmd_lineno,lastrandom); 
                                    end
                     
                        C_PRINT :
                                    begin
                                        zerocycle = 1; 
                                        command_length = len_string(vectors[cptr+1]); 
                                        str = extract_string(cptr); 
                                        $display("BFM:%0s", str); 
                                    end
                        C_HEAD :
                                    begin
                                        zerocycle = 1; 
                                        command_length = len_string(vectors[cptr+1]); 
                                        str = extract_string(cptr); 
                                        $display("################################################################"); 
                                        $display("BFM:%0s", str); 
                                    end
                        C_FILEN :
                                    begin
                                        zerocycle = 1; 
                                        characters = to_int(command0[15:8]); 
                                        command_length = (characters - 1) / 4 + 2; 
                                    end
                        C_DEBUG :
                                    begin
                                        zerocycle = 1; 
                                        command_length = 2; 
                                        if (DEBUGLEVEL >= 0 & DEBUGLEVEL <= 5)
                                        begin
                                            $display("BFM:%0d: DEBUG - ignored due to DEBUGLEVEL generic setting", cmd_lineno); 
                                        end
                                        else
                                        begin
                                            DEBUG <= command[1] ; 
                                            $display("BFM:%0d: DEBUG %0d", cmd_lineno, command[1]); 
                                        end 
                                    end
                        C_HRESP :
                                    begin
                                        zerocycle = 0; 
                                        command_length = 2; 
                                        hresp_mode = command[1]; 
                                        tmpstr[1] = NUL; 
                                        if (hresp_mode == 2)
                                        begin
                                            if (hresp_occured)
                                            begin
                                                tmpstr[1:9] = {"OCCURRED", NUL}; 
                                            end
                                            else
                                            begin
                                                $display("BFM: HRESP Did Not Occur When Expected (ERROR)"); 
                                                ERRORS = ERRORS + 1; 
                                                $stop;
                                            end 
                                            hresp_mode = 0; 
                                        end 
                                        hresp_occured = 0; 
                                        if (DEBUG >= 2) $display("BFM:%0d:hresp %0d %0s", cmd_lineno, hresp_mode, tmpstr); 
                                    end
                        C_STOP :
                                    begin
                                        zerocycle = 1; 
                                        command_length = 2; 
                                        if ( DEBUG >=2) $display("BFM:%0d:stop %0d", cmd_lineno, command[1]); 
                                        $display("       Stimulus file %0s  Line No %0d", filenames[get_file(cmd_lineno, filemult)], get_line(cmd_lineno, filemult)); 
                                        case (command[1])
                                            0 :
                                                        begin
                                                            $display("BFM Script Stop Command (NOTE)"); 
                                                        end
                                            1 :
                                                        begin
                                                            $display("BFM Script Stop Command (WARNING)"); 
			    											//$stop;
                                                        end
                                            3 :
                                                        begin
                                                            $display("BFM Script Stop Command (FAILURE)"); 
                                                            $stop;
                                                        end
                                            default :
                                                        begin
                                                            $display("BFM Script Stop Command (ERROR)"); 
                                                            $stop;
                                                        end
                                        endcase 
                                    end
                        C_QUIT :
                                    begin
                                        bfm_done = 1; 
                                    end
                        C_ECHO :
                                    begin
                                        zerocycle = 1; 
                                        if (DEBUG>=1) $display("BFM:%0d:echo at %0d ns", cmd_lineno,$time); 
                                        command_length = 2 + command[1]; 
                                        $display("BFM Parameter values are"); 
                                        begin : xhdl_21
                                            integer i;
                                            for(i = 0; i <= command_length - 3; i = i + 1)
                                            begin
                                                $display(" Para %0d=0x%08x (%0d)", i + 1, commandLV[2 + i], commandLV[2 + i]); 
                                            end
                                        end 
                                    end
                        C_FLUSH :
                                    begin
                                        command_length = 2; 
                                        wait_counter = command[1]; 
                                        if ( DEBUG >=2) $display("BFM:%0d:flush %0d at %0d ns", cmd_lineno, wait_counter,$time); 
                                        do_flush = 1; 
                                        do_case = 1; 
                                    end
                        C_SFAIL :
                                    begin
                                        zerocycle = 1; 
                                        ERRORS = ERRORS + 1; 
                                        if ( DEBUG >=2) $display("BFM:%0d:setfail", cmd_lineno); 
                                        $display("BFM: User Script detected ERROR (ERROR)"); 
                                        $stop;
                                    end
                        C_SET :
                                    begin
                                        zerocycle = 1; 
                                        command_length = 3; 
                                        setvar = get_storeaddr(vectors[cptr + 1],stkptr); 
                                        newvalue = command[2]; 
                                        stack[setvar] = newvalue; 
                                        if (DEBUG >= 2) $display("BFM:%0d:set %0d= 0x%08x (%0d)", cmd_lineno, setvar, newvalue, newvalue); 
                                    end
                        C_CALC :
                                    begin
                                        zerocycle = 1; 
                                        command_length = command[2] + 3; 
                                        setvar = get_storeaddr(vectors[cptr + 1],stkptr); 
                                        newvalue = calculate(command[4], command[3], command[5], DEBUG); 
                                        i = 6; 
                                        while (i < command_length)
                                        begin
                                            newvalue = calculate(command[i], newvalue, command[i + 1], DEBUG); 
                                            i = i + 2; 
                                        end 
                                        stack[setvar] = newvalue; 
                                        if (DEBUG >= 2) $display("BFM:%0d:set %0d= 0x%08x (%0d)", cmd_lineno, setvar, newvalue, newvalue); 
                                    end
                        C_LOGF :
                                    begin
                                        zerocycle = 1; 
                                        if (logopen)
                                        begin
			    						   $fflush(flog);
			    						   $fclose(flog);
                                        end 
                                        command_length = len_string(vectors[cptr+1]); 
                                        logfile = extract_string(cptr); 
                                        $display("BFM:%0d:LOGFILE %0s", cmd_lineno, logfile); 
                                        flog = $fopen(logfile,"w"); 
                                        logopen = 1;
                                    end
                        C_LOGS :
                                    begin
                                        zerocycle = 1; 
                                        command_length = 2; 
                                        $display("BFM:%0d:LOGSTART %0d", cmd_lineno, command[1]); 
                                        if (logopen==0)
                                        begin
                                            $display("Logfile not defined, ignoring command (ERROR)"); 
                                        end
                                        else
                                        begin
                                            log_ahb  = ((commandLV[1][0]) == 1'b1); 
                                            log_ext  = ((commandLV[1][1]) == 1'b1); 
                                            log_gpio = ((commandLV[1][2]) == 1'b1); 
                                            log_bfm  = ((commandLV[1][3]) == 1'b1); 
                                        end 
                                    end
                        C_LOGE :
                                    begin
                                        zerocycle = 1; 
                                        command_length = 1; 
                                        $display("BFM:%0d:LOGSTOP", cmd_lineno); 
                                        log_ahb = 0; 
                                        log_ext = 0; 
                                        log_gpio = 0; 
                                        log_bfm = 0; 
                                    end
                        C_VERS :
                                    begin
                                        zerocycle = 1; 
                                        command_length = 1; 
                                        $display("BFM:%0d:VERSION", cmd_lineno); 
                                        $display("  BFM Verilog Version %0s", BFM_VERSION); 
                                        $display("  BFM Date %0s", BFM_DATE); 
                                        // The two lines below will be autoupdated when file is commited to SubVersion
                                        $display("  SVN Revision $Revision: 21608 $");
                                        $display("  SVN Date $Date: 2013-12-03 05:33:36 +0530 (Tue, 03 Dec 2013) $");
                                        $display("  Compiler Version %0d", bfmc_version); 
                                        $display("  Vectors Version %0d", vectors_version); 
                                        $display("  No of Vectors %0d", Nvectors); 
                                        if (logopen != NUL)
                                        begin
                                          $fdisplay(flog,"%05d VR %0s %0s %0d %0d %0d", $time,BFM_VERSION, BFM_DATE, bfmc_version, vectors_version, Nvectors); 
                                        end 
                                    end
                        default :
                                    begin
                                        $display("BFM: Instruction %0d Line Number %0d Command %0d", cptr, cmd_lineno, cmd_cmd); 
                                        $display("       Stimulus file %0s  Line No %0d", filenames[get_file(cmd_lineno, filemult)], get_line(cmd_lineno, filemult)); 
                                        $display("Instruction not yet implemented (ERROR)"); 
                                        $stop;
                                    end
                    endcase 
                end 
                // zero cycle was set indicating instruction does not require a clock! 
                if (zerocycle)
                begin
                    cmd_active = 0; 
                    cptr = cptr + command_length; 
                    command_length = 0; 
                end 
			end
				
            //----------------------------------------------------------------------------------------------------------
            //----------------------------------------------------------------------------------------------------------
            // Data Checker, needs to happen before multi cycle command processing
            DATA_MATCH_AHB = 0; 
            DATA_MATCH_EXT = 0; 
            DATA_MATCH_IO = 0; 
            if (READ_P1 == 1'b1)
            begin
                EXP = RDATA_P1 & MDATA_P1; 
                GOT = HRDATA & MDATA_P1; 
                DATA_MATCH_AHB = (EXP === GOT); 
            end 
            if (EXTRD_P1 == 1'b1)
            begin
                EXP = EIO_RDATA_P1 & EIO_MDATA_P1; 
                GOT = EXT_DIN & EIO_MDATA_P1; 
                DATA_MATCH_EXT = (EXP === GOT); 
            end 
            if (GPIORD_P0 == 1'b1)
            begin
                EXP = EIO_RDATA_P0 & EIO_MDATA_P0; 
                GOT = GP_IN & EIO_MDATA_P0; 
                DATA_MATCH_IO = (EXP === GOT); 
            end 

            //----------------------------------------------------------------------------------------------------------
            piped_activity = do_read | do_write | do_bwrite | do_bread | do_poll | do_idle | do_io 
                                          | to_boolean(READ_P1 | READ_P0 | WRITE_P0 | WRITE_P1 | EXTRD_P0 | EXTRD_P1 | GPIORD_P0 ); 
            if (do_case)
            begin
                case (cmd_cmdx4)
                    C_FLUSH :
                                begin
                                    if (~piped_activity)
                                    begin
                                        //----------------------------------------------------------------------------------------------------------
                                        //----------------------------------------------------------------------------------------------------------
                                        // Command Processing for multi cycle commands etc
                                        if (wait_counter <= 1)
                                        begin
                                            do_case = 0; 
                                        end
                                        else
                                        begin
                                            wait_counter = wait_counter - 1; 
                                        end 
                                    end 
                                end
                    C_WAIT :
                                begin
                                    if (wait_counter <= 1)
                                    begin
                                        do_case = 0; 
                                    end
                                    else
                                    begin
                                        wait_counter = wait_counter - 1; 
                                    end 
                                end
                    C_WAITNS, C_WAITUS :
                                begin
                                    if ($time >= wait_time)
                                    begin
                                        do_case = 0; 
                                    end 
                                end
                    C_IRQ, C_FIQ, C_INTREQ :
                                begin
                                    if (int_vector == 256)
                                    begin
                                        int_active = (INTERRUPT != ZERO256); 
                                    end
                                    else
                                    begin
                                        int_active = ((INTERRUPT[int_vector]) === 1'b1); 
                                    end 
                                    if (int_active)
                                    begin
                                        if (DEBUG>=2) $display( "BFM:Interrupt Wait Time %0d cycles", instruct_cycles); 
                                        do_case = 0; 
                                    end 
                                end
                    C_EXTW :
                                begin
                                    EXTADDR_P0 <= command_address ; 
                                    EXT_DOUT   <= command_data ; 
                                    EXTWR_P0   <= 1'b1 ; 
                                    do_case = 0; 
                                end
                                	
                    C_EXTWM :
                                begin
                                    EXTADDR_P0 <= burst_address + burst_count ; 
                                    EXT_DOUT   <= burst_data[burst_count] ; 
                                    EXTWR_P0   <= 1'b1 ; 
                                    burst_count = burst_count + 1; 
                                    if (burst_count >= burst_length)
                                    begin
                                        do_case = 0; 
                                    end 
                                end

                    C_EXTR, C_EXTRC, C_EXTMSK :
                                begin
                                    EXTADDR_P0 <= command_address ; 
                                    EIO_RDATA_P0 <= command_data ; 
                                    EIO_MDATA_P0 <= command_mask ; 
                                    EIO_LINENO_P0 <= cmd_lineno ; 
                                    EIO_RDCHK_P0 <= 1'b1 ; 
                                    if (EXTRD_P1 == 1'b1)
                                    begin
                                        // must wait until data on bus, cannot allow immediate write
                                        do_case = 0; 
                                    end 
                                end
                    C_EXTWT :
                                begin
                                    if (EXT_WAIT == 1'b0 & wait_counter == 0)
                                    begin
                                        if (DEBUG>=2) $display( "BFM:Exteral Wait Time %0d cycles", instruct_cycles); 
                                        do_case = 0; 
                                    end 
                                    if (wait_counter >= 1)
                                    begin
                                        wait_counter = wait_counter - 1; 
                                    end 
                                end
                    C_IOCHK, C_IOMSK, C_IOTST, C_IORD :
                                begin
                                    EIO_RDCHK_P0 <= 1'b1 ; 
                                    EIO_RDATA_P0 <= command_data ; 
                                    EIO_MDATA_P0 <= command_mask ; 
                                    EIO_LINENO_P0 <= cmd_lineno ; 
                                    do_case = 0; 
                                end
                    C_IOWAIT :
                                begin
                                    EIO_RDATA_P0 <= command_data ; 
                                    EIO_MDATA_P0 <= command_mask ; 
                                    EIO_LINENO_P0 <= cmd_lineno ; 
                                    GPIORD_P0 <= 1'b1 ; 
                                    EIO_RDCHK_P0 <= 1'b0 ; 
                                    if (GPIORD_P0 == 1'b1 & DATA_MATCH_IO)
                                    begin
                                        GPIORD_P0 <= 1'b0 ; 
                                        do_case = 0; 
                                        if (DEBUG>=2) $display( "BFM:GP IO Wait Time %0d cycles", instruct_cycles); 
                                    end 
                                end
                    C_MEMT , C_MEMT2 :
                                begin
                                    case (mt_state)
                                        //memtest resource addr size align cycles
                                        idle :  do_case = 0; 
                                        init :	    begin
                                                        mt_base    = command[1] + command[2]; 
                                                        mt_size    = command[3]; 
                                                        mt_align   = command[4] % 65536; 
                                                        mt_fill    = ((commandLV[4][16]) == 1'b1); 
                                                        mt_scan    = ((commandLV[4][17]) == 1'b1); 
                                                        mt_restart = ((commandLV[4][18]) == 1'b1); 
                                                        mt_cycles  = command[5]; 
                                                        mt_seed    = command[6]; 
                                                        if (~mt_restart)
                                                           for (i=0;i<MAX_MEMTEST;i=i+1) mt_image[i] = 0; 
                                                        mt_reads = 0; 
                                                        mt_writes = 0; 
                                                        mt_nops = 0; 
                                                        mt_dual = 0; 
                                                        mt_fillad = 0;
                                                        if (cmd_cmdx4 == C_MEMT2)
                                                        begin
                                                            // if two banks double size
                                                            mt_base = command[1]; 
                                                            mt_base2 = command[2] - mt_size; 
                                                            mt_size = 2 * mt_size; 
                                                            mt_dual = 1; 
                                                        end 
                                                        if (cmd_cmdx4 == C_MEMT)
                                                        begin
                                                            $display("BFM:%0d: memtest Started at %0d ns", cmd_lineno, $time); 
                                                            $display("BFM:  Address %08x Size %0d Cycles %5d", mt_base, mt_size, mt_cycles); 
                                                        end
                                                        else
                                                        begin
                                                            $display("BFM:%0d: dual memtest Started at %0d ns", cmd_lineno, $time); 
                                                            $display("BFM:  Address %08x %08x  Size %0d Cycles %5d", mt_base,mt_base2 + mt_size/2, mt_size/2, mt_cycles); 
                                                        end 
                                                        case (mt_align)
                                                            0 :	  begin end
                                                            1 :	  $display("BFM: Transfers are APB Byte aligned"); 
                                                            2 :	  $display("BFM: Transfers are APB Half Word aligned"); 
                                                            3 :	  $display("BFM: Transfers are APB Word aligned"); 
                                                            4 :	  $display("BFM: Byte Writes Suppressed"); 
                                                            default :   $display("Illegal Align on memtest (FAILURE)"); 
                                                        endcase 
                                                        if (mt_restart)
                                                        begin
                                                            $display("BFM: memtest restarted"); 
                                                        end 
                                                        if (mt_fill)
                                                        begin
                                                            $display("BFM: Memtest Filling Memory"); 
                                                            mt_state = fill; 
                                                        end
                                                        else if (mt_cycles > 0)
                                                        begin
                                                            $display("BFM: Memtest Random Read Writes"); 
                                                            mt_state = active; 
                                                        end
                                                        else if (mt_scan)
                                                        begin
                                                            $display("BFM: Memtest Verifying Memory Content"); 
                                                            mt_state = scan; 
                                                        end
                                                        else
                                                        begin
                                                            mt_state = done; 
                                                        end 
                                                    end
                                        active, fill, scan :
                                                    begin
                                                        if (~(do_write | do_read))
                                                        begin
                                                            case (mt_state)
                                                                active :
                                                                            begin
                                                                                mt_seed = random(mt_seed); 
                                                                                mt_ad = mask_randomS(mt_seed, mt_size); 
                                                                                mt_seed = random(mt_seed); 
                                                                                mt_op = mask_randomS(mt_seed, 8); 
                                                                            end
                                                                fill :
                                                                            begin
                                                                                mt_ad = mt_fillad; 
                                                                                mt_op = 6; 
                                                                            end
                                                                scan :
                                                                            begin
                                                                                mt_ad = mt_fillad; 
                                                                                mt_op = 2; 
                                                                            end
                                                                default :
                                                                            begin
                                                                            end
                                                            endcase 
                                                            case (mt_align)
                                                                0 :
                                                                            begin
                                                                            end
                                                                1 :
                                                                            begin
                                                                                // byte wide APB
                                                                                mt_ad = 4 * (mt_ad / 4); 
                                                                                case (mt_op)
                                                                                    // full AHB operation
                                                                                    0, 4 :
                                                                                                begin
                                                                                                    mt_op = mt_op; // all to op 0 and 4
                                                                                                end
                                                                                    1, 5 :
                                                                                                begin
                                                                                                    mt_op = mt_op - 1; 
                                                                                                end
                                                                                    2, 6 :
                                                                                                begin
                                                                                                    mt_op = mt_op - 2; 
                                                                                                end
                                                                                    default :
                                                                                                begin
                                                                                                end
                                                                                endcase 
                                                                            end
                                                                2 :
                                                                            begin
                                                                                // half wide APB
                                                                                mt_ad = 4 * (mt_ad / 4); 
                                                                                case (mt_op)
                                                                                    0, 4 :
                                                                                                begin
                                                                                                    mt_op = mt_op + 1; // all to op 1 and 5
                                                                                                end
                                                                                    1, 5 :
                                                                                                begin
                                                                                                    mt_op = mt_op; 
                                                                                                end
                                                                                    2, 6 :
                                                                                                begin
                                                                                                    mt_op = mt_op - 1; 
                                                                                                end
                                                                                    default :
                                                                                                begin
                                                                                                end
                                                                                endcase 
                                                                            end
                                                                3 :
                                                                            begin
                                                                                // word wide APB
                                                                                mt_ad = 4 * (mt_ad / 4); 
                                                                                case (mt_op)
                                                                                    0, 4 :
                                                                                                begin
                                                                                                    mt_op = mt_op + 2; // all to op 2 and 6
                                                                                                end
                                                                                    1, 5 :
                                                                                                begin
                                                                                                    mt_op = mt_op + 1; 
                                                                                                end
                                                                                    2, 6 :
                                                                                                begin
                                                                                                    mt_op = mt_op; 
                                                                                                end
                                                                                    default :
                                                                                                begin
                                                                                                end
                                                                                endcase 
                                                                            end
                                                                4 :
                                                                            begin
                                                                                // Dont allow Byte writes
                                                                                case (mt_op)
                                                                                    4 :
                                                                                                begin
                                                                                                    mt_ad = 2 * (mt_ad / 2); 
                                                                                                    mt_op = 5; // stop a byte write, make a half write
                                                                                                end
                                                                                    default :
                                                                                                begin
                                                                                                end
                                                                                endcase 
                                                                            end
                                                                default :
                                                                            begin
                                                                            end
                                                            endcase 
                                                            if (mt_op >= 0 & mt_op <= 2)
                                                            begin
                                                                // do read
                                                                case (mt_op)
                                                                    // see if valid data
                                                                    0 :
                                                                                begin
                                                                                    command_size = 3'b000; 
                                                                                    mt_ad = mt_ad; 
                                                                                    mt_readok = (mt_image[mt_ad + 0] >= 256); 
                                                                                end
                                                                    1 :
                                                                                begin
                                                                                    command_size = 3'b001; 
                                                                                    mt_ad = 2 * (mt_ad / 2); 
                                                                                    mt_readok = ((mt_image[mt_ad + 0] >= 256) & (mt_image[mt_ad + 1] >= 256)); 
                                                                                end
                                                                    2 :
                                                                                begin
                                                                                    command_size = 3'b010; 
                                                                                    mt_ad = 4 * (mt_ad / 4); 
                                                                                    mt_readok = ((mt_image[mt_ad + 0] >= 256) & (mt_image[mt_ad + 1] >= 256) & (mt_image[mt_ad + 2] >= 256) & (mt_image[mt_ad + 3] >= 256)); 
                                                                                end
                                                                    default :
                                                                                begin
                                                                                end
                                                                endcase 
                                                                // wait until previous cycle clears
                                                                if (mt_readok)
                                                                begin
                                                                    // do a read
                                                                    do_read = 1; 
                                                                    mt_reads = mt_reads + 1; 
                                                                    if (mt_dual == 1 & mt_ad >= mt_size / 2)
                                                                    begin
                                                                        command_address = mt_base2 + mt_ad; 
                                                                    end
                                                                    else
                                                                    begin
                                                                        command_address = mt_base + mt_ad; 
                                                                    end 
                                                                    case (mt_op)
                                                                        0 :	        begin
                                                                                        command_data = {ZEROLV[31:8], mt_image[mt_ad + 0][7:0]}; 
                                                                                    end
                                                                        1 :	        begin
                                                                                        command_data = {ZEROLV[31:16], mt_image[mt_ad + 1][7:0], mt_image[mt_ad + 0][7:0]}; 
                                                                                    end
                                                                        2 :	        begin
                                                                                        command_data = {mt_image[mt_ad + 3][7:0], mt_image[mt_ad + 2][7:0], 
                                                                                                        mt_image[mt_ad + 1][7:0], mt_image[mt_ad + 0][7:0]}; 
                                                                                    end
                                                                        default :   begin
                                                                                        command_data = ZEROLV[31:0]; 
                                                                                    end
                                                                    endcase 
                                                                    command_mask = {32{1'b1}}; 
                                                                end
                                                                else
                                                                begin
                                                                    //$display("Memtest read converted to write");
                                                                    mt_op = mt_op + 4; // force a write if not written
                                                                    // if a byte read converted to byte write and byte writes not allowed make a half word write!
                                                                    if (mt_op == 4 & mt_align == 4)
                                                                    begin
                                                                        mt_op = 5; 
                                                                    end 
                                                                end 
                                                            end 
                                                            if (mt_op >= 4 & mt_op <= 6)
                                                            begin
                                                                // do write
                                                                do_write = 1; 
                                                                mt_writes = mt_writes + 1; 
                                                                mt_seed = random(mt_seed); 
                                                                command_data = mt_seed; 
                                                                case (mt_op)
                                                                    // update image
                                                                    4 :
                                                                                begin
                                                                                    command_size = 3'b000; 
                                                                                    mt_ad = mt_ad; 
                                                                                    mt_image[mt_ad + 0] = 256 + command_data[7:0]; 
                                                                                end
                                                                    5 :
                                                                                begin
                                                                                    command_size = 3'b001; 
                                                                                    mt_ad = 2 * (mt_ad / 2); 
                                                                                    mt_image[mt_ad + 0] = 256 + command_data[7:0]; 
                                                                                    mt_image[mt_ad + 1] = 256 + command_data[15:8]; 
                                                                                end
                                                                    6 :
                                                                                begin
                                                                                    command_size = 3'b010; 
                                                                                    mt_ad = 4 * (mt_ad / 4); 
                                                                                    mt_image[mt_ad + 0] = 256 + command_data[7:0]; 
                                                                                    mt_image[mt_ad + 1] = 256 + command_data[15:8]; 
                                                                                    mt_image[mt_ad + 2] = 256 + command_data[23:16]; 
                                                                                    mt_image[mt_ad + 3] = 256 + command_data[31:24]; 
                                                                                end
                                                                    default :
                                                                                begin
                                                                                end
                                                                endcase 
                                                                if (mt_dual == 1 & mt_ad >= mt_size / 2)
                                                                begin
                                                                    command_address = mt_base2 + mt_ad; 
                                                                end
                                                                else
                                                                begin
                                                                    command_address = mt_base + mt_ad; 
                                                                end 
                                                            end 
                                                            if (mt_op == 3 | mt_op == 7)
                                                            begin
                                                                // insert one wait cycle
                                                                mt_nops = mt_nops + 1; 
                                                            end 
                                                            mt_fillad = mt_fillad + 4; 
                                                            case (mt_state)
                                                                active :
                                                                            begin
                                                                                if (mt_cycles > 0)
                                                                                begin
                                                                                    mt_cycles = mt_cycles - 1; 
                                                                                end
                                                                                else if (mt_scan)
                                                                                begin
                                                                                    mt_fillad = 0; 
                                                                                    mt_state = scan; 
                                                                                    $display("BFM: Memtest Verifying Memory Content"); 
                                                                                end
                                                                                else
                                                                                begin
                                                                                    mt_state = done; 
                                                                                end 
                                                                            end
                                                                fill :
                                                                            begin
                                                                                if (mt_fillad >= mt_size)
                                                                                begin
                                                                                    if (mt_cycles == 0)
                                                                                    begin
                                                                                        if (mt_scan)
                                                                                        begin
                                                                                            mt_fillad = 0; 
                                                                                            mt_state = scan; 
                                                                                            $display("BFM: Memtest Verifying Memory Content"); 
                                                                                        end
                                                                                        else
                                                                                        begin
                                                                                            mt_state = done; 
                                                                                        end 
                                                                                    end
                                                                                    else
                                                                                    begin
                                                                                        mt_state = active; 
                                                                                        $display("BFM: Memtest Random Read Writes"); 
                                                                                    end 
                                                                                end 
                                                                            end
                                                                scan :
                                                                            begin
                                                                                if (mt_fillad >= mt_size)
                                                                                begin
                                                                                    mt_state = done; 
                                                                                end 
                                                                            end
                                                                default :
                                                                            begin
                                                                            end
                                                            endcase 
                                                            timer = command_timeout; // also reset the timer as we completed a cycle  
                                                        end 
                                                    end
                                        done :
                                                    begin
                                                        if (~piped_activity)
                                                        begin
                                                            mt_state = idle; 
                                                            $display("BFM: bfmtest complete  Writes %0d  Reads %0d  Nops %0d", mt_writes, mt_reads, mt_nops); 
                                                        end 
                                                    end
                                    endcase 
                                end
                    default :
                                begin
                                end
                endcase 
            end 
            //----------------------------------------------------------------------------------------------------------
            //----------------------------------------------------------------------------------------------------------
            // AMBA Bus Cycles
            //- this inserts AHB BUSY cycles
            if (count_xrate == 0)
            begin
                insert_busy = 0; 
                count_xrate = su_xrate; 
            end
            else
            begin
                count_xrate = count_xrate - 1; 
                insert_busy = 1; 
            end 
            if (HREADY == 1'b1)
            begin
                HTRANS_P0 <= 2'b00 ; // IDLE
                HWRITE_P0 <= 1'b0 ; 
                // AMBA Cycles
                WRITE_P0 <= 1'b0 ; 
                READ_P0 <= 1'b0 ; 
                POLL_P0 <= 1'b0 ; 
                //---------
                if (WRITE_P0 == 1'b1 | READ_P0 == 1'b1)
                begin
                    RDCHK_P0 <= 1'b0 ; 
                end 
                if (do_write & HREADY == 1'b1)
                begin
                    HADDR_P0 <= command_address ; 
                    HWRITE_P0 <= 1'b1 ; 
                    HBURST_P0 <= ahb_burst ; 
                    HTRANS_P0 <= 2'b10 ; 
                    HMASTLOCK_P0 <= ahb_lock ; 
                    HPROT_P0 <= ahb_prot ; 
                    HSIZE_P0 <= command_size ; 
                    WDATA_P0 <= align_data(command_size, command_address[1:0], command_data, su_align) ; 
                    WRITE_P0 <= 1'b1 ; 
                    LINENO_P0 <= cmd_lineno ; 
                    do_write = 0; 
                end 
                if (do_read & HREADY == 1'b1)
                begin
                    HADDR_P0 <= command_address ; 
                    HWRITE_P0 <= 1'b0 ; 
                    HBURST_P0 <= ahb_burst ; 
                    HTRANS_P0 <= 2'b10 ; 
                    HMASTLOCK_P0 <= ahb_lock ; 
                    HPROT_P0 <= ahb_prot ; 
                    HSIZE_P0 <= command_size ; 											 
                    RDATA_P0 <= align_data(command_size, command_address[1:0], command_data, su_align) ; 
                    MDATA_P0 <= align_mask(command_size, command_address[1:0], command_mask, su_align) ; 
                    LINENO_P0 <= cmd_lineno ; 
                    READ_P0 <= 1'b1 ; 
                    RDCHK_P0 <= 1'b1 ; 
                    do_read = 0; 
                end 
                if (do_idle & HREADY == 1'b1)
                begin
                    HADDR_P0 <= command_address ; 
                    HWRITE_P0 <= ahbc_hwrite ; 
                    HBURST_P0 <= ahbc_burst ; 
                    HTRANS_P0 <= ahbc_htrans ; 
                    HMASTLOCK_P0 <= ahbc_lock ; 
                    HPROT_P0 <= ahbc_prot ; 
                    HSIZE_P0 <= command_size ; 
                    WDATA_P0 <= align_data(command_size, command_address[1:0], command_data, su_align) ; 
                    WRITE_P0 <= 1'b1 ; // use write pipe line to control timing
                    LINENO_P0 <= cmd_lineno ; 
                    do_idle = 0; 
                end 
                if (do_poll & HREADY == 1'b1)
                begin
                    //$display("POLL %08x %08x",RDATA_P0),MDATA_P0));
                    HADDR_P0 <= command_address ; 
                    HWRITE_P0 <= 1'b0 ; 
                    HBURST_P0 <= ahb_burst ; 
                    HMASTLOCK_P0 <= ahb_lock ; 
                    HPROT_P0 <= ahb_prot ; 
                    HSIZE_P0 <= command_size ; 
                    RDATA_P0 <= align_data(command_size, command_address[1:0], command_data, su_align) ; 
                    MDATA_P0 <= align_mask(command_size, command_address[1:0], command_mask, su_align) ; 
                    LINENO_P0 <= cmd_lineno ; 
                    if (READ_P0 == 1'b1 | READ_P1 == 1'b1)
                    begin
                        HTRANS_P0 <= 2'b00 ; // No cycle, waiting to check data
                    end
                    else
                    begin
                        HTRANS_P0 <= 2'b10 ; 
                        READ_P0 <= 1'b1 ; 
                        POLL_P0 <= 1'b1 ; 
                    end 
                    if (POLL_P1 == 1'b1 & DATA_MATCH_AHB)
                    begin
                        do_poll = 0; 
                    end 
                end 
                if (do_bwrite & HREADY == 1'b1)
                begin
                    HADDR_P0 <= command_address ; 
                    HWRITE_P0 <= 1'b1 ; 
                    HBURST_P0 <= ahb_burst ; 
                    HMASTLOCK_P0 <= ahb_lock ; 
                    HPROT_P0 <= ahb_prot ; 
                    HSIZE_P0 <= command_size ; 
                    LINENO_P0 <= cmd_lineno ; 
                    if (insert_busy)
                    begin
                        HTRANS_P0 <= 2'b01 ; 
                    end
                    else
                    begin
                        WDATA_P0 <= align_data(command_size, command_address[1:0], to_slv32(burst_data[burst_count]), su_align) ; 
                        WRITE_P0 <= 1'b1 ; 
                        if (burst_count == 0 | cmd_size == 3 | bound1k(su_noburst, command_address) )
                        begin
                            HTRANS_P0 <= 2'b10 ; 
                        end
                        else
                        begin
                            HTRANS_P0 <= 2'b11 ; 
                        end 
                        command_address = command_address + burst_addrinc; 
                        burst_count = burst_count + 1; 
                        if (burst_count == burst_length)
                        begin
                            do_bwrite = 0; 
                        end 
                    end 
                end 
                if (do_bread & HREADY == 1'b1)
                begin
                    HADDR_P0 <= command_address ; 
                    HWRITE_P0 <= 1'b0 ; 
                    HBURST_P0 <= ahb_burst ; 
                    HMASTLOCK_P0 <= ahb_lock ; 
                    HPROT_P0 <= ahb_prot ; 
                    HSIZE_P0 <= command_size ; 
                    LINENO_P0 <= cmd_lineno ; 
                    if (insert_busy)
                    begin
                        HTRANS_P0 <= 2'b01 ; 
                    end
                    else
                    begin
                        RDATA_P0 <= align_data(command_size, command_address[1:0], to_slv32(burst_data[burst_count]), su_align) ; 
                        MDATA_P0 <= align_mask(command_size, command_address[1:0], command_mask, su_align) ; 
                        READ_P0 <= 1'b1 ; 
                        RDCHK_P0 <= 1'b1 ; 
                        if (burst_count == 0 | cmd_size == 3 | bound1k(su_noburst, command_address) )
                        begin
                            HTRANS_P0 <= 2'b10 ; 
                        end
                        else
                        begin
                            HTRANS_P0 <= 2'b11 ; 
                        end 
                        command_address = command_address + burst_addrinc; 
                        burst_count = burst_count + 1; 
                        if (burst_count == burst_length)
                        begin
                            do_bread = 0; 
                        end 
                    end 
                end 
            end 
            //----------------------------------------------------------------------------------------------------------
            if (HREADY == 1'b1)
            begin
                WRITE_P1 <= WRITE_P0 ; 
                READ_P1 <= READ_P0 ; 
                POLL_P1 <= POLL_P0 ; 
                RDCHK_P1 <= RDCHK_P0 ; 
                RDATA_P1 <= RDATA_P0 ; 
                MDATA_P1 <= MDATA_P0 ; 
                LINENO_P1 <= LINENO_P0 ; 
                HADDR_P1 <= HADDR_P0 ; 
                HSIZE_P1 <= HSIZE_P0 ; 
            end 
            	
            EXTRD_P1 <= EXTRD_P0 ; 
            EXTADDR_P1 <= EXTADDR_P0 ; 
            //seperate data pipe to AHB!
            EIO_RDCHK_P1 <= EIO_RDCHK_P0 ; 
            EIO_RDATA_P1 <= EIO_RDATA_P0 ; 
            EIO_MDATA_P1 <= EIO_MDATA_P0 ; 
            EIO_LINENO_P1 <= EIO_LINENO_P0 ; 


            if (HREADY == 1'b1)
            begin
                //----------------------------------------------------------------------------------------------------------
                //----------------------------------------------------------------------------------------------------------
                // Write Data Pipeline and logger
                if (WRITE_P0 == 1'b1)
                begin
                    WDATA_P1 <= WDATA_P0 ; 
                end
                else
                begin
                    WDATA_P1 <= {32{1'b0}} ; 
                end 
                if (WRITE_P1 == 1'b1 & DEBUG >= 3)
                begin
                    $display("BFM: Data Write %08x %08x", HADDR_P1, WDATA_P1); 
                end 
                if (log_ahb & WRITE_P1 == 1'b1)
                begin
                    $fdisplay(flog,"%05d AW %c %08x %08x", $time,to_char(HSIZE_P1), HADDR_P1, WDATA_P1); 
                end 
            end 
            if (GPIOWR_P0 == 1'b1 & log_gpio)
            begin
                $fdisplay(flog,"%05d GW   %08x ", $time,GPOUT_P0); 
            end 
            if (EXTWR_P0 == 1'b1 & log_ext)
            begin
                $fdisplay(flog,"%05d EW   %08x %08x", $time,EXTADDR_P0, EXT_DOUT); 
            end 
            if (HREADY == 1'b1)
            begin
                if (READ_P1 == 1'b1)
                begin
                    if (DEBUG >= 3)
                    begin
                        //----------------------------------------------------------------------------------------------------------
                        //----------------------------------------------------------------------------------------------------------
                        // Read Data Pipeline, Checker and logger
                        // AHB Read Checks
                        if (MDATA_P1 == ZEROLV)
                        begin
                            $display("BFM: Data Read %08x %08x", HADDR_P1, HRDATA); 
                        end
                        else
                        begin
                            $display("BFM: Data Read %08x %08x MASK:%08x", HADDR_P1, HRDATA, MDATA_P1); 
                        end 
                    end 
                    if (log_ahb)
                    begin
                         $fdisplay(flog,"%05d AR %c %08x %08x", $time,to_char(HSIZE_P1), HADDR_P1, HRDATA); 
                    end 
                    if (storeaddr >= 0)
                    begin
                        stack[storeaddr] = to_int(align_read(HSIZE_P1, HADDR_P1[1:0], HRDATA,su_align)); 
                    end 
                    if (RDCHK_P1 == 1'b1 & ~DATA_MATCH_AHB)
                    begin
                        ERRORS = ERRORS + 1; 
                        $display("ERROR: AHB Data Read Comparison failed Addr:%08x  Got:%08x  EXP:%08x  (MASK:%08x)", HADDR_P1, HRDATA, RDATA_P1, MDATA_P1); 
                        $display("       Stimulus file %0s  Line No %0d", filenames[get_file(LINENO_P1, filemult)], get_line(LINENO_P1, filemult)); 
                        $display("BFM Data Compare Error (ERROR)"); 
                        $stop;
                        if (log_ahb)
                        begin
                            $fdisplay(flog, "%05d ERROR  Addr:%08x  Got:%08x  EXP:%08x  (MASK:%08x)", $time,HADDR_P1, HRDATA, RDATA_P1, MDATA_P1); 
                        end 
                    end 
                end 
            end 

                
            if (GPIORD_P0 == 1'b1)
            begin
                if (DEBUG >= 3)
                begin
                    // IO Port Checker
                    if (EIO_MDATA_P0 == ZEROLV)
                    begin
                        $display("BFM: GP IO Data Read %08x", GP_IN); 
                    end
                    else
                    begin
                        $display("BFM: GP IO Data Read %08x  MASK:%08x", GP_IN, EIO_MDATA_P0); 
                    end 
                end 
                if (log_gpio)
                begin
                    $fdisplay(flog,"%05d GR   %08x ",$time, EIO_RDATA_P0); 
                end 
                if (storeaddr >= 0)
                begin
                    stack[storeaddr] = GP_IN; 
                end 
                if (EIO_RDCHK_P0 == 1'b1 & ~DATA_MATCH_IO)
                begin
                    ERRORS = ERRORS + 1; 
                    $display("GPIO input not as expected  Got:%08x  EXP:%08x  (MASK:%08x)", GP_IN, EIO_RDATA_P0, EIO_MDATA_P0); 
                    $display("       Stimulus file %0s  Line No %0d", filenames[get_file(EIO_LINENO_P0, filemult)], get_line(EIO_LINENO_P0, filemult)); 
                    $display("BFM GPIO Compare Error (ERROR)"); 
                    $stop;
                    if (log_gpio)
                    begin
                        $fdisplay(flog,"ERROR  Got:%08x  EXP:%08x  (MASK:%08x)", GP_IN, EIO_RDATA_P0, EIO_MDATA_P0); 
                    end 
                end 
            end 
                
            if (EXTRD_P1 == 1'b1)
            begin
                if (DEBUG >= 3)
                begin
                    // Extention Read Checks
                    if (EIO_MDATA_P1 == ZEROLV)
                    begin
                        $display("BFM: Extention Data Read %08x %08x", EXTADDR_P1, EXT_DIN); 
                    end
                    else
                    begin
                        $display("BFM: Extention Data Read %08x %08x  MASK:%08x", EXTADDR_P1, EXT_DIN, EIO_MDATA_P1); 
                    end 
                end 
                if (log_ext)
                begin
                    $fdisplay(flog,"%05d ER   %08x %08x", $time,EXTADDR_P1, EIO_RDATA_P1); 
                end 
                if (storeaddr >= 0)
                begin
                    stack[storeaddr] = to_int(EXT_DIN); 
                end 
                if (EIO_RDCHK_P1 == 1'b1 & ~DATA_MATCH_EXT)
                begin
                    ERRORS = ERRORS + 1; 
                    $display("ERROR: Extention Data Read Comparison FAILED  Got:%08x  EXP:%08x  (MASK:%08x)", EXT_DIN, EIO_RDATA_P1, EIO_MDATA_P1); 
                    $display("       Stimulus file %0s  Line No %0d", filenames[get_file(EIO_LINENO_P1, filemult)], get_line(EIO_LINENO_P1, filemult)); 
                    $display("BFM Extention Data Compare Error (ERROR)"); 
                    $stop;
                    if (log_ext)
                    begin
                        $fdisplay(flog,"ERROR  Got:%08x  EXP:%08x  (MASK:%08x)", EXT_DIN, EIO_RDATA_P1, EIO_MDATA_P1); 
                    end 
                end 
            end 
            //----------------------------------------------------------------------------------------------------------
            // routines that require operation after AHB cycle completes

            ahb_activity = do_read | do_write | do_bwrite | do_bread | do_poll | do_idle | to_boolean(READ_P0 | WRITE_P0 | EXTRD_P0 | GPIORD_P0) | (to_boolean((READ_P1 | WRITE_P1) & ~HREADY)); 
            if (do_case)
            begin
                case (cmd_cmdx4)
                    C_CHKT :
                                begin
                                    if (~ahb_activity)
                                    begin
                                        if (DEBUG >= 2) $display( "BFM:%0d:checktime was %0d cycles ", cmd_lineno, instruct_cycles); 
                                        if (instruct_cycles < command[1] | instruct_cycles > command[2])
                                        begin
                                            $display("BFM: ERROR checktime %0d %0d Actual %0d", command[1], command[2], instruct_cycles); 
                                            $display("       Stimulus file %0s  Line No %0d", filenames[get_file(LINENO_P1, filemult)], get_line(LINENO_P1, filemult)); 
                                            $display("BFM checktime failure (ERROR)"); 
                                            ERRORS = ERRORS + 1; 
                                            $stop;
                                        end 
                                        do_case = 0; 
                                        var_licycles = instruct_cycles; 
                                    end 
                                end
                    C_CKTIM :
                                begin
                                    if (~ahb_activity)
                                    begin
                                        instructions_timer = instructions_timer - 1; // need to allow for check instruction
                                        if (DEBUG >= 2) $display( "BFM:%0d:checktimer was %0d cycles ", cmd_lineno, instructions_timer); 
                                        if (instructions_timer < command[1] | instructions_timer > command[2])
                                        begin
                                            $display("BFM: ERROR checktimer %0d %0d Actual %0d", command[1], command[2], instructions_timer); 
                                            $display("       Stimulus file %0s  Line No %0d", filenames[get_file(LINENO_P1, filemult)], get_line(LINENO_P1, filemult)); 
                                            $display("BFM checktimer failure (ERROR)"); 
                                            ERRORS = ERRORS + 1; 
                                            $stop;
                                        end 
                                        do_case = 0; 
                                        var_ltimer = instructions_timer; 
                                    end 
                                end
                    default :
                                begin
                                end
                endcase 
            end 
            //----------------------------------------------------------------------------------------------------------

            if (bfm_run)
            begin
                //----------------------------------------------------------------------------------------------------------
                //----------------------------------------------------------------------------------------------------------
                // Watchdog timer
                if (timer > 0)
                begin
                    timer = timer - 1; 
                end
                else
                begin
                    timer = command_timeout; 
                    $display("BFM Command Timeout Occured");
                    $display("       Stimulus file %0s  Line No %0d", filenames[get_file(LINENO_P1, filemult)], get_line(LINENO_P1, filemult)); 
                    if (~bfm_done) $display("BFM Command timeout occured (ERROR)"); 
                    if ( bfm_done) $display("BFM Completed and timeout occured (ERROR)");
                    $stop; 
                end 
            end
            else
            begin
                timer = command_timeout; 
            end 
            if (ERRORS > 0)
            begin
                FAILED_P0 <= 1'b1 ; 
            end 
            if (do_case | do_read | do_write | do_bwrite | do_bread | do_poll | do_idle | ((do_flush | su_flush) & piped_activity))
            begin
                cmd_active = 1; 
            end
            else
            begin
                do_flush = 0; 
                // See if command done, if so allow next command to be started
                if (~bfm_done)
                begin
                    cmd_active = 0; 
                end 
                cptr = cptr + command_length; 
                command_length = 0; 
                if (OPMODE > 0)
                begin
                    if (bfm_single | bfm_done)
                    begin
                        bfm_run = 0; 
                        cmd_active = 0; 
                    end 
                end 
            end 
            if (FINISHED_P0 == 1'b0 & OPMODE == 0 & bfm_done & ~piped_activity)
            begin
                $display("###########################################################"); 
                $display(" "); 
                //----------------------------------------------------------------------------------------------------------
                //----------------------------------------------------------------------------------------------------------
                if (ERRORS == 0)
                begin
                    $display("BFM Simulation Complete - %0d Instructions - NO ERRORS", instuct_count); 
                end
                else
                begin
                    $display("BFM Simulation Complete - %0d Instructions - %0d ERRORS OCCURED", instuct_count, ERRORS); 
                end 
                $display(" "); 
                $display("###########################################################"); 
                $display(" "); 
                FINISHED_P0 <= 1'b1 ; 
                cmd_active = 1; 
                bfm_run = 0; 
                if (logopen)
                begin
                    // close log file
                   $fflush(flog); 
                   $fclose(flog); 
                end 
                if ( su_endsim==1 ) $stop;
                if ( su_endsim==2 ) $finish;
            end 
            CON_BUSY  <= (bfm_run | piped_activity) ; 
            INSTR_OUT <= to_slv32(cptr) ; 
        end 
    end 
    	
    assign #TPD GP_OUT   = GPOUT_P0 ;
    assign #TPD EXT_WR   = EXTWR_P0 ;
    assign #TPD EXT_RD   = EXTRD_P0 ;
    assign #TPD EXT_ADDR = EXTADDR_P0 ;
    assign #TPD EXT_DATA = (EXTWR_P0 == 1'b1) ? EXT_DOUT : {32{1'bz}} ;
    assign      EXT_DIN  = EXT_DATA ;

    always @(HADDR_P0)
    begin
        begin : xhdl_29
            integer i;
            for(i = 0; i <= 15; i = i + 1)
            begin
                HSEL_P0[i] <= (HADDR_P0[31:28] == i) ; 
            end
        end 
    end 
    	
    assign HCLK      = (DRIVEX_CLK) ? 1'bx : (SYSCLK | HCLK_STOP) ;
    assign PCLK      = (DRIVEX_CLK) ? 1'bx : (SYSCLK | HCLK_STOP) ;
    assign #TPD HRESETN   = (DRIVEX_RST) ? 1'bx : HRESETN_P0 ;
    assign #TPD HADDR     = (DRIVEX_ADD) ? {32{1'bx}} : HADDR_P0 ;
    assign #TPD HWDATA    = (DRIVEX_DAT) ? {32{1'bx}} : WDATA_P1 ;
    assign #TPD HBURST    = (DRIVEX_ADD) ? {3{1'bx}} : HBURST_P0 ;
    assign #TPD HMASTLOCK = (DRIVEX_ADD) ? 1'bx : HMASTLOCK_P0 ;
    assign #TPD HPROT     = (DRIVEX_ADD) ? {4{1'bx}} : HPROT_P0 ;
    assign #TPD HSIZE     = (DRIVEX_ADD) ? {3{1'bx}} : HSIZE_P0 ;
    assign #TPD HTRANS    = (DRIVEX_ADD) ? {2{1'bx}} : HTRANS_P0 ;
    assign #TPD HWRITE    = (DRIVEX_ADD) ? 1'bx : HWRITE_P0 ;
    assign #TPD HSEL      = (DRIVEX_ADD) ? {16{1'bx}} : HSEL_P0 ;

    assign #TPD CON_DATA = (CON_RDP1 == 1'b1) ? CON_DOUT : {32{1'bz}} ;
    assign      CON_DIN  = CON_DATA ;
    assign #TPD FINISHED = FINISHED_P0 ;
    assign #TPD FAILED   = FAILED_P0 ;



endmodule



