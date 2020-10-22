// ********************************************************************/ 
// Microsemi Corporation Proprietary and Confidential
// Copyright 2014 Microsemi Corporation.  All rights reserved.
//
// ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN 
// ACCORDANCE WITH THE MICROSEMI LICENSE AGREEMENT AND MUST BE APPROVED 
// IN ADVANCE IN WRITING.  
//  
//
// SPI Clock Mux.
//
// SVN Revision Information:
// SVN $Revision: 23983 $
// SVN $Date: 2014-11-28 23:42:46 +0530 (Fri, 28 Nov 2014) $
//
// Resolved SARs
// SAR      Date     Who   Description
//
// Notes: 
//
//
// *********************************************************************/ 

module spi_clockmux ( input      sel,
                  input      clka,
                  input      clkb,
                  output reg clkout
                );


 always @(*)
 begin
     case (sel)
         1'b0    : clkout = clka;
         1'b1    : clkout = clkb;
         default : clkout = clka;
     endcase
 end

endmodule