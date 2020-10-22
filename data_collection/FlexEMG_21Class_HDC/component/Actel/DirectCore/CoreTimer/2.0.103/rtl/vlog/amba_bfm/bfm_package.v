// ********************************************************************/ 
// Actel Corporation Proprietary and Confidential
// Copyright 2009 Actel Corporation.  All rights reserved.
//
// ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN 
// ACCORDANCE WITH THE ACTEL LICENSE AGREEMENT AND MUST BE APPROVED 
// IN ADVANCE IN WRITING.  
//  
// Description: AMBA BFMs
//              BFM Support Package  
//
// Revision Information:
// Date     Description
//
//
// SVN Revision Information:
// SVN $Revision: 21608 $
// SVN $Date: 2013-12-02 16:03:36 -0800 (Mon, 02 Dec 2013) $
//
//
// Resolved SARs
// SAR      Date     Who  Description
//
//
// Notes: 
//        
// *********************************************************************/ 

    //-------------------------------------------------------------------------------------------
    // Constants
    localparam C_VECTORS_VERSION = 22; 
    // Command Encodings in Vectors
    localparam C_NOP = 0; 
    localparam C_WRITE = 4; 
    localparam C_READ = 8; 
    localparam C_RDCHK = 12; 
    localparam C_RDMSK = 16; 
    localparam C_POLL = 20; 
    localparam C_POLLM = 24; 
    localparam C_POLLB = 28; 
    localparam C_WRTM = 32; 
    localparam C_FILL = 36; 
    localparam C_WRTT = 40; 
    localparam C_RDM = 44; 
    localparam C_RDMC = 48; 
    localparam C_READF = 52; 
    localparam C_READT = 56; 
    localparam C_IOTST = 60; 
    localparam C_IOWAIT = 64; 
    localparam C_READS = 68;
    localparam C_AHBC  = 72;
    localparam C_WRTA  = 76;
    localparam C_READA = 80;
     
    localparam C_IOWR = 100; 
    localparam C_IORD = 101; 
    localparam C_IOCHK = 102; 
    localparam C_IOMSK = 103; 
    localparam C_IOSET = 104; 
    localparam C_IOCLR = 105; 
    localparam C_INTREQ = 106; 
    localparam C_FIQ = 107; 
    localparam C_IRQ = 108; 
    localparam C_HRESP = 109; 
    localparam C_EXTW = 110; 
    localparam C_EXTR = 111; 
    localparam C_EXTRC = 112; 
    localparam C_EXTMSK = 113; 
    localparam C_EXTWT = 114; 
    localparam C_EXTWM = 115; 
    localparam C_LABEL = 128; 
    localparam C_JMP = 129; 
    localparam C_JMPZ = 130; 
    localparam C_JMPNZ = 131; 
    localparam C_CALL = 132; 
    localparam C_CALLP = 133; 
    localparam C_RET = 134; 
    localparam C_LOOP = 135; 
    localparam C_LOOPE = 136; 
    localparam C_WAIT = 137; 
    localparam C_STOP = 138; 
    localparam C_QUIT = 139; 
    localparam C_TOUT = 140; 
    localparam C_TABLE = 141; 
    localparam C_FLUSH = 142; 
    localparam C_PRINT = 150; 
    localparam C_HEAD = 151; 
    localparam C_FILEN = 152; 
    localparam C_MEMT = 153; 
    localparam C_MEMT2 = 154; 
    localparam C_MODE = 160; 
    localparam C_SETUP = 161; 
    localparam C_DEBUG = 162; 
    localparam C_PROT = 163; 
    localparam C_LOCK = 164; 
    localparam C_ERROR = 165; 
    localparam C_BURST = 166; 
    localparam C_CHKT = 167; 
    localparam C_SFAIL  = 168;
    localparam C_STTIM  = 169;
    localparam C_CKTIM  = 170;
    localparam C_RAND  = 171;
    localparam C_CONPU = 172;
        
    localparam C_MMAP      = 200;
    localparam C_SET       = 201;
    localparam C_CONS      = 202;
    localparam C_INT       = 203;
    localparam C_CALC      = 204;
    localparam C_CMP       = 205;
    localparam C_RESET     = 206;
    localparam C_CLKS      = 207;
    localparam C_IF        = 208;
    localparam C_IFNOT     = 209;
    localparam C_WHILE     = 210;
    localparam C_ELSE      = 211;
    localparam C_ENDIF     = 212;
    localparam C_ENDWHILE  = 213;
    localparam C_CASE      = 214;
    localparam C_WHEN      = 215;
    localparam C_ENDCASE   = 216;
    localparam C_DEFAULT   = 217;
    localparam C_CMPR      = 218;
    localparam C_RETV      = 219;
    localparam C_WAITNS    = 220;
    localparam C_WAITUS    = 221;
    localparam C_DRVX      = 222;

    localparam  C_VERS     = 250;
    localparam  C_LOGF     = 251;
    localparam  C_LOGS     = 252;
    localparam  C_LOGE     = 253;
    localparam  C_ECHO     = 254;
    localparam  C_FAIL     = 255;
        
    
    
     
    localparam OP_NONE = 1001; 
    localparam OP_ADD = 1002; 
    localparam OP_SUB = 1003; 
    localparam OP_MULT = 1004; 
    localparam OP_DIV = 1005; 
    localparam OP_MOD = 1006; 
    localparam OP_POW = 1007; 
    localparam OP_AND = 1008; 
    localparam OP_OR = 1009; 
    localparam OP_XOR = 1010; 
    localparam OP_CMP = 1011; 
    localparam OP_SHL = 1012; 
    localparam OP_SHR = 1013; 
    localparam OP_EQ = 1014; 
    localparam OP_NEQ = 1015; 
    localparam OP_GR = 1016; 
    localparam OP_LS = 1017; 
    localparam OP_GRE = 1018; 
    localparam OP_LSE = 1019; 
    localparam OP_SETB = 1020; 
    localparam OP_CLRB = 1021; 
    localparam OP_INVB = 1022; 
    localparam OP_TSTB = 1023; 

    localparam  D_RESERVED  = 0;
    localparam  D_RETVALUE  = 1;
    localparam  D_TIME      = 2;
    localparam  D_DEBUG     = 3;
    localparam  D_LINENO    = 4;
    localparam  D_ERRORS    = 5;
    localparam  D_TIMER     = 6;
    localparam  D_LTIMER    = 7;
    localparam  D_LICYCLES  = 8;


    localparam  D_NORMAL  = 0;
    localparam  D_ARGVALUE  = 1;
    localparam  D_RAND      = 2;
    localparam  D_RANDSET   = 3;
    localparam  D_RANDRESET = 4;
 
    localparam  E_DATA   = 32'h00000000;   
    localparam  E_ADDR   = 32'h00002000;   
    localparam  E_STACK  = 32'h00004000;
    localparam  E_CONST  = 32'h00006000;   
    localparam  E_ARRAY  = 32'h00008000;   
     
   
    localparam[1:0] B_Tcommand_s = 0; 
    localparam[1:0] H = 1; 
    localparam[1:0] W = 2; 
    localparam[1:0] X = 3; 

    function integer to_int;
        input [31:0] xlv; 
        integer X; 
        begin
            X = xlv; 
            to_int = X; 
        end
    endfunction

    function integer to_int_unsigned;
        input [31:0] xlv; 
        integer xlv;
        integer X; 

        begin
            X = xlv; 
            to_int_unsigned = X; 
        end
    endfunction

    function integer to_int_signed;
        input [31:0] xlv; 
        integer X; 

        begin
            X = xlv; 
            to_int_signed = X; 
        end
    endfunction

    function [31:0] to_slv32;
        input X; 
        integer X;

        reg[31:0] xlv; 

        begin
            xlv = X; 
            to_slv32 = xlv; 
        end
    endfunction


    function [31:0] align_data;
        input[2:0] size; 
        input[1:0] addr10; 
        input[31:0] datain; 
        input alignmode; 
        integer alignmode;

        reg[31:0] adata; 
        reg addr1; 

        begin
            adata = {32{1'b0}}; 
            case (alignmode)
                0 :
                            begin
                                case (size)
                                    3'b000 :
                                                begin
                                                    // Normal operation, data is correctly aligned for a 32 bit bus 
                                                    case (addr10)
                                                        2'b00 :
                                                                    begin
                                                                        adata[7:0] = datain[7:0]; 
                                                                    end
                                                        2'b01 :
                                                                    begin
                                                                        adata[15:8] = datain[7:0]; 
                                                                    end
                                                        2'b10 :
                                                                    begin
                                                                        adata[23:16] = datain[7:0]; 
                                                                    end
                                                        2'b11 :
                                                                    begin
                                                                        adata[31:24] = datain[7:0]; 
                                                                    end
                                                        default :
                                                                    begin
                                                                    end
                                                    endcase 
                                                end
                                    3'b001 :
                                                begin
                                                    case (addr10)
                                                        2'b00 :
                                                                    begin
                                                                        adata[15:0] = datain[15:0]; 
                                                                    end
                                                        2'b01 :
                                                                    begin
                                                                        adata[15:0] = datain[15:0]; 
                                                                        $display("BFM: Missaligned AHB Cycle(Half A10=01) ? (WARNING)"); 
                                                                    end
                                                        2'b10 :
                                                                    begin
                                                                        adata[31:16] = datain[15:0]; 
                                                                    end
                                                        2'b11 :
                                                                    begin
                                                                        adata[31:16] = datain[15:0]; 
                                                                        $display("BFM: Missaligned AHB Cycle(Half A10=11) ? (WARNING)"); 
                                                                    end
                                                        default :
                                                                    begin
                                                                    end
                                                    endcase 
                                                end
                                    3'b010 :
                                                begin
                                                    adata = datain; 
                                                    case (addr10)
                                                        2'b00 :
                                                                    begin
                                                                    end
                                                        2'b01 :
                                                                    begin
                                                                        $display("BFM: Missaligned AHB Cycle(Word A10=01) ? (WARNING)"); 
                                                                    end
                                                        2'b10 :
                                                                    begin
                                                                        $display("BFM: Missaligned AHB Cycle(Word A10=10) ? (WARNING)"); 
                                                                    end
                                                        2'b11 :
                                                                    begin
                                                                        $display("BFM: Missaligned AHB Cycle(Word A10=11) ? (WARNING)"); 
                                                                    end
                                                        default :
                                                                    begin
                                                                    end
                                                    endcase 
                                                end
                                    default :
                                                begin
                                                    $display("Unexpected AHB Size setting (ERROR)"); 
                                                end
                                endcase 
                            end
                1 :
                            begin
                                case (size)
                                    3'b000 :
                                                begin
                                                    // Normal operation, data is correctly aligned for a 16 bit bus 
                                                    case (addr10)
                                                        2'b00 :
                                                                    begin
                                                                        adata[7:0] = datain[7:0]; 
                                                                    end
                                                        2'b01 :
                                                                    begin
                                                                        adata[15:8] = datain[7:0]; 
                                                                    end
                                                        2'b10 :
                                                                    begin
                                                                        adata[7:0] = datain[7:0]; 
                                                                    end
                                                        2'b11 :
                                                                    begin
                                                                        adata[15:8] = datain[7:0]; 
                                                                    end
                                                        default :
                                                                    begin
                                                                    end
                                                    endcase 
                                                end
                                    3'b001 :
                                                begin
                                                    adata[15:0] = datain[15:0]; 
                                                    case (addr10)
                                                        2'b00 :
                                                                    begin
                                                                    end
                                                        2'b01 :
                                                                    begin
                                                                        $display("BFM: Missaligned AHB Cycle(Half A10=01) ? (WARNING)"); 
                                                                    end
                                                        2'b10 :
                                                                    begin
                                                                        $display("BFM: Missaligned AHB Cycle(Half A10=10) ? (WARNING)"); 
                                                                    end
                                                        2'b11 :
                                                                    begin
                                                                        $display("BFM: Missaligned AHB Cycle(Half A10=11) ? (WARNING)"); 
                                                                    end
                                                        default :
                                                                    begin
                                                                    end
                                                    endcase 
                                                end
                                    default :
                                                begin
                                                    $display("Unexpected AHB Size setting (ERROR)"); 
                                                end
                                endcase 
                            end
                2 :
                            begin
                                // Normal operation, data is correctly aligned for a 8 bit bus 
                                case (size)
                                    3'b000 :
                                                begin
                                                    adata[7:0] = datain[7:0]; 
                                                end
                                    default :
                                                begin
                                                    $display("Unexpected AHB Size setting (ERROR)"); 
                                                end
                                endcase 
                            end
                8 :
                            begin
                                // No alignment takes place
                                adata = datain; 
                            end
                default :
                            begin
                                $display("Illegal Alignment mode (ERROR)"); 
                            end
            endcase 
            align_data = adata; 
        end
    endfunction

    function [31:0] align_mask;
        input[2:0] size; 
        input[1:0] addr10; 
        input[31:0] datain; 
        input alignmode; 
        integer alignmode;

        reg[31:0] adata; 

        begin
            adata = align_data(size, addr10, datain, alignmode); 
            align_mask = adata; 
        end
    endfunction

    function [31:0] align_read;
        input[2:0] size; 
        input[1:0] addr10; 
        input[31:0] datain; 
        input alignmode; 
        integer alignmode;

        reg[31:0] adata; 
        reg addr1; 

        begin
            if (alignmode == 8)
            begin
                adata = datain; 
            end
            else
            begin
              adata = 0; 
              addr1 = addr10[1]; 
              case (size)
                  3'b000 :    begin
                                  case (addr10)
                                      2'b00 :	 adata[7:0] = datain[7:0  ]; 
                                      2'b01 :	 adata[7:0] = datain[15:8 ]; 
                                      2'b10 :	 adata[7:0] = datain[23:16]; 
                                      2'b11 :	 adata[7:0] = datain[31:24]; 
                                      default : begin
                                                end
                                  endcase 
                              end
                  3'b001 :    begin
                                  case (addr1)
                                      1'b0 : adata[15:0] = datain[15:0]; 
                                      1'b1 : adata[15:0] = datain[31:16]; 
                                      default : begin
                                                end
                                  endcase 
                              end
                  3'b010 :    begin
                                  adata = datain; 
                              end
                  default :       $display("Unexpected AHB Size setting (ERROR)"); 
              endcase 
            end
            align_read = adata; 
        end
    endfunction

    function  integer to_ascii;
        input X; 
        integer X;

        integer  c; 

        begin
            c = X; 
            to_ascii = c; 
        end
    endfunction


    function integer to_char;
        input size; 
        integer size;

        integer c; 

        begin
            case (size)
                0 :
                            begin
                                c = 'h62;  //'b'
                            end
                1 :
                            begin
                                c = 'h68; //'h'; 
                            end
                2 :
                            begin
                                c = 'h77; //'w'; 
                            end
                3 :
                            begin
                                c = 'h78 ; //'x';
                            end
                default :
                            begin
                                c = 'h3f; //'?'; 
                            end
            endcase 
            to_char = c; 
        end
    endfunction


    function integer address_increment;
        input size; 
        integer size;
        input xainc; 
        integer xainc;

        integer c; 

        begin
            case (size)
                0 :
                            begin
                                c = 1; 
                            end
                1 :
                            begin
                                c = 2; 
                            end
                2 :
                            begin
                                c = 4; 
                            end
                3 :
                            begin
                                c = xainc; 
                            end
                default :
                            begin
                                c = 0; 
                            end
            endcase 
            address_increment = c; 
        end
    endfunction

    function integer xfer_size;
        input size; 
        integer size;
        input xsize; 
        integer xsize;

        reg[2:0] c; 

        begin
            case (size)
                0 :
                            begin
                                c = 3'b000; 
                            end
                1 :
                            begin
                                c = 3'b001; 
                            end
                2 :
                            begin
                                c = 3'b010; 
                            end
                3 :
                            begin
                                c = xsize; 
                            end
                default :
                            begin
                                c = 3'bXXX; 
                            end
            endcase 
            xfer_size = c; 
        end
    endfunction

    function integer calculate;
        input op; 
        integer op;
        input X; 
        integer X;
        input Y; 
        integer Y;
        input debug; 
        integer debug;

        integer Z; 
        reg[31:0] XS; 
        reg[31:0] YS; 
        reg[31:0] ZS; 
        integer YI; 
        reg[63:0] ZZS; 
        localparam[31:0] ZERO = 0; 
        localparam[31:0] ONE  = 1; 

        begin
            
            XS = X; 
            YS = Y; 
            YI = Y; 
            ZS = {32{1'b0}}; 
            case (op)
                OP_NONE :
                            begin
                                ZS = 0; 
                            end
                OP_ADD :
                            begin
                                ZS = XS + YS; 
                            end
                OP_SUB :
                            begin
                                ZS = XS - YS; 
                            end
                OP_MULT :
                            begin
                                ZZS = XS * YS; 
                                ZS = ZZS[31:0]; 
                            end
                OP_DIV :
                            begin
                                ZS = XS / YS; 
                            end
                OP_AND :
                            begin
                                ZS = XS & YS; 
                            end
                OP_OR :
                            begin
                                ZS = XS | YS; 
                            end
                OP_XOR :
                            begin
                                ZS = XS ^ YS; 
                            end
                OP_CMP :
                            begin
                                ZS = XS ^ YS; 
                            end
                OP_SHR :
                            begin
                                if (YI == 0)
                                begin
                                    ZS = XS; 
                                end
                                else
                                begin
                                    ZS = XS >> YI;
                                end 
                            end
                OP_SHL :
                            begin
                                if (YI == 0)
                                begin
                                    ZS = XS; 
                                end
                                else
                                begin
                                    ZS = XS << YI;
                                end 
                            end
                OP_POW :
                            begin
                                ZZS = {ZERO, ONE}; 
                                if (YI > 0)
                                begin
                                    begin : xhdl_1
                                        integer i;
                                        for(i = 1; i <= YI; i = i + 1)
                                        begin
                                            ZZS = ZZS[31:0] * XS; 
                                        end
                                    end 
                                end 
                                ZS = ZZS[31:0]; 
                            end
                OP_EQ :
                            begin
                                if (XS == YS)
                                begin
                                    ZS = ONE; 
                                end 
                            end
                OP_NEQ :
                            begin
                                if (XS != YS)
                                begin
                                    ZS = ONE; 
                                end 
                            end
                OP_GR :
                            begin
                                if (XS > YS)
                                begin
                                    ZS = ONE; 
                                end 
                            end
                OP_LS :
                            begin
                                if (XS < YS)
                                begin
                                    ZS = ONE; 
                                end 
                            end
                OP_GRE :
                            begin
                                if (XS >= YS)
                                begin
                                    ZS = ONE; 
                                end 
                            end
                OP_LSE :
                            begin
                                if (XS <= YS)
                                begin
                                    ZS = ONE; 
                                end 
                            end
                OP_MOD :
                            begin
                                ZS = XS % YS; 
                            end
                OP_SETB :
                            begin
                                if (Y <= 31)
                                begin
                                    ZS = XS; 
                                    ZS[Y] = 1'b1; 
                                end
                                else
                                begin
                                    $display("Bit operation on bit >31 (FAILURE)"); 
                                    $stop;
                                end 
                            end
                OP_CLRB :
                            begin
                                if (Y <= 31)
                                begin
                                    ZS = XS; 
                                    ZS[Y] = 1'b0; 
                                end
                                else
                                begin
                                    $display("Bit operation on bit >31 (FAILURE)"); 
                                    $stop;
                                end 
                            end
                OP_INVB :
                            begin
                                if (Y <= 31)
                                begin
                                    ZS = XS; 
                                    ZS[Y] = ~ZS[Y]; 
                                end
                                else
                                begin
                                    $display("Bit operation on bit >31 (FAILURE)"); 
                                    $stop;
                                end 
                            end
                OP_TSTB :
                            begin
                                if (Y <= 31)
                                begin
                                    ZS = 0; 
                                    ZS[0] = XS[Y]; 
                                end
                                else
                                begin
                                    $display("Bit operation on bit >31 (FAILURE)"); 
                                    $stop;
                                end 
                            end
                default :
                            begin
                                $display("Illegal Maths Operator (FAILURE)"); 
                                $stop;
                            end
            endcase 
            Z = ZS; 
            if (debug >= 4)
            begin
                $display("Calculated %d = %d (%d) %d", Z, X, op, Y); 
            end 
            calculate = Z; 
        end
    endfunction

    function [31:0] clean;
        input [31:0] X; 

        reg[31:0] tmp; 

        begin
            tmp = X; 
            tmp = 0; 
            begin : xhdl_2
                integer i;
                for(i =0 ; i <= 31; i = i + 1)
                begin
                    if ((X[i]) == 1'b1)
                    begin
                        tmp[i] = 1'b1; 
                    end 
                end
            end 
            clean = tmp; 
        end
    endfunction

/*
    function [1:(256)*8] extract_string;
        input len; 
        integer len;
        input vchar; 
        reg [256*8:0] vchar;
        reg [1:(256)*8] str; 
        integer i,j,b,p; 

        begin
            nchars = vectors(cptr + 1) / 65536; 
            nparas = vectors(cptr + 1) % 65536; 

            for (i=0; i<256*8; i=i+1) str[i] = 0;
            p=0;
            for (i=0; i<(len+3)/4; i=i+1) 
             begin
               for (j=3;j>=0;j=j-1)
                 begin
                   for (b=1;b<=8;b=b+1)
                     begin 
                       str[p*8+b] = vchar[i*32+32-8*(4-j)+8-b];
                     end
                   p=p+1;
                 end
              end
            extract_string = str; 
        end
    endfunction

*/




    function integer get_line;
        input lineno; 
        integer lineno;
        input X; 
        integer X;

        integer ln; 
        integer fn; 

        begin
            fn = lineno / X; 
            ln = lineno - fn * X; 
            get_line = ln; 
        end
    endfunction

    function integer get_file;
        input lineno; 
        integer lineno;
        input X; 
        integer X;

        integer ln; 
        integer fn; 

        begin
            fn = lineno / X; 
            ln = lineno - fn * X; 
            get_file = fn; 
        end
    endfunction



    function integer to_boolean;
        input X; 
        integer X;
        integer z;
        begin   
          z=0;
          if (X!=0) z=1;
          to_boolean = z;
        end
    endfunction


    function integer random;
    input seed; 
    integer seed;
    reg [31:0] regx;  
    reg [31:0] regy;  
    reg d;
    begin
      regx = seed;
      d = 1'b1;
      regy[0]  = d ^ regx[31];
      regy[1]  = d ^ regx[31] ^ regx[0];
      regy[2]  = d ^ regx[31] ^ regx[1];
      regy[3]  = regx[2];
      regy[4]  = d ^ regx[31] ^ regx[3];
      regy[5]  = d ^ regx[31] ^ regx[4];
      regy[6]  = regx[5];
      regy[7]  = d ^ regx[31] ^ regx[6];
      regy[8]  = d ^ regx[31] ^ regx[7];
      regy[9]  = regx[8];
      regy[10] = d ^ regx[31] ^ regx[9];
      regy[11] = d ^ regx[31] ^ regx[10];
      regy[12] = d ^ regx[31] ^ regx[11];
      regy[13] = regx[12];
      regy[14] = regx[13];
      regy[15] = regx[14];
      regy[16] = d ^ regx[31] ^ regx[15];
      regy[17] = regx[16];
      regy[18] = regx[17];
      regy[19] = regx[18];
      regy[20] = regx[19];
      regy[21] = regx[20];
      regy[22] = d ^ regx[31] ^ regx[21];
      regy[23] = d ^ regx[31] ^ regx[22];
      regy[24] = regx[23];
      regy[25] = regx[24];
      regy[26] = d ^ regx[31] ^ regx[25];
      regy[27] = regx[26];
      regy[28] = regx[27];
      regy[29] = regx[28];
      regy[30] = regx[29];
      regy[31] = regx[30];
      random = regy;
    end

endfunction



function integer mask_randomN;
    input seed; 
    integer seed;
    input size; 
    integer size;

    integer xrand; 
    integer i;

    reg[31:0] regx; 

    begin
        regx =seed; 
        for(i=31;i>=size;i=i-1) regx[i] = 0; 
        xrand = regx; 
        mask_randomN = xrand; 
    end
endfunction



    function integer mask_randomS;
        input seed; 
        integer seed;
        input size; 
        integer size;

        integer xrand; 
        reg[31:0] regx; 
        integer sn; 
        integer i;
        begin
            case (size)
                1 :
                            begin
                                sn = 0; 
                            end
                2 :
                            begin
                                sn = 1; 
                            end
                4 :
                            begin
                                sn = 2; 
                            end
                8 :
                            begin
                                sn = 3; 
                            end
                16 :
                            begin
                                sn = 4; 
                            end
                32 :
                            begin
                                sn = 5; 
                            end
                64 :
                            begin
                                sn = 6; 
                            end
                128 :
                            begin
                                sn = 7; 
                            end
                256 :
                            begin
                                sn = 8; 
                            end
                512 :
                            begin
                                sn = 9; 
                            end
                1024 :
                            begin
                                sn = 10; 
                            end
                2048 :
                            begin
                                sn = 11; 
                            end
                4096 :
                            begin
                                sn = 12; 
                            end
                8192 :
                            begin
                                sn = 13; 
                            end
                16384 :
                            begin
                                sn = 14; 
                            end
                32768 :
                            begin
                                sn = 15; 
                            end
                65536 :
                            begin
                                sn = 16; 
                            end
                131072     : sn= 17;
                262144     : sn= 18;
                524288     : sn= 19;
                1048576    : sn= 20;
                2097152    : sn= 21;
                4194304    : sn= 22;
                8388608    : sn= 23;
                16777216   : sn= 24;
                33554432   : sn= 25;
                67108864   : sn= 26;
                134217728  : sn= 27;
                268435456  : sn= 28;
                536870912  : sn= 29;
                1073741824 : sn= 30;
                default :
                            begin
                                $display("Random function error (FAILURE)"); 
                                $finish;
                            end
            endcase 
            regx = to_slv32(seed); 
            if (sn < 31)
            begin
                for(i=31;i>=sn;i=i-1) regx[i] = 0; 
            end 
            xrand = to_int_signed(regx); 
            mask_randomS = xrand; 
        end
    endfunction





    function bound1k;
        input bmode; 
        integer bmode;
        input addr; 
		integer addr;

        reg[31:0] address; 
        reg boundary; 

        begin
        	address = addr;
            boundary = 0; 
            case (bmode)
                0 :
                            begin
                                if (address[9:0] == 10'b0000000000)
                                begin
                                    boundary = 1; 
                                end 
                            end
                1 :
                            begin
                                boundary = 1; 
                            end
                2 :
                            begin
                                // return FALSE
                            end
                default :
                            begin
                                $display("Illegal Burst Boundary Set (FAILURE)"); 
                                $finish;
                            end
            endcase 
            bound1k = boundary; 
        end
    endfunction
