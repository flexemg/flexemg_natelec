// ***************************************************************************/
//Microsemi Corporation Proprietary and Confidential
//Copyright 2011 Microsemi Corporation. All rights reserved.
//
//ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
//ACCORDANCE WITH THE MICROSEMI LICENSE AGREEMENT AND MUST BE APPROVED
//IN ADVANCE IN WRITING.
//
//Description:  CoreFFT
//              Hard MAC component wrapper
//
//Revision Information:
//Date         Description
//01Aug2011    Initial Release
//
//SVN Revision Information:
//SVN $Revision: $
//SVN $Data: $
//
//Resolved SARs
//SAR     Date    Who         Description
//
//Notes:
//
// 10/7/2011  Static unused register are tight to 1'b1 when possible

`timescale 1 ns/100 ps


// MAC 18x18 for wide and cmplx mult:
//  -optional mcand and P registers
//  -common reset; no accumulator - just adder
//  -add/sub input
//  -mcands get sign extended
//  -unused cin/cdin are grounded
module fft_inpl_mac18x18mx(nGrst, rstn, clk, en_a, en_b, en_p,
                mcand_a, mcand_b,
                carryin,
                cdsel,            // it is parameter actually
                cdout, pout,
                shftsel, sub);
  parameter WIDTH_A      = 18;
  parameter WIDTH_B      = 18;
  parameter BYPASS_REG_A = 0;
  parameter BYPASS_REG_B = 0;
  parameter BYPASS_REG_P = 0;
  parameter FPGA_FAMILY  = 12;

  localparam [1:0] BY_REGA = BYPASS_REG_A ? 2'b11 : 2'b00;
  localparam [1:0] BY_REGB = BYPASS_REG_B ? 2'b11 : 2'b00;
  localparam [1:0] BY_REGP = BYPASS_REG_P ? 2'b11 : 2'b00;

  localparam P_WIDTH = (FPGA_FAMILY==12)? 41 : (FPGA_FAMILY==26)? 48 : 44;

  input nGrst, rstn, clk, en_a, en_b, en_p;
  input [WIDTH_A-1:0] mcand_a;
  input [WIDTH_B-1:0] mcand_b;
  input [P_WIDTH-1:0] carryin;
  input cdsel;        // Constant; 0-carryin=cin; 1-carryin=cdin;
  input shftsel;      // Constant; 0-no shift; 1-carryin>>>17;
  input sub;          // Constant; 0-add; 1-sub;
  output[P_WIDTH-1:0] cdout, pout;

  wire [1:0] ea_w, eb_w, ep_w;
  wire [1:0] rstn_a_w, rstn_b_w, rstn_p_w;
  wire [17:0] mcand_a18, mcand_b18;
  wire [1:0] arstn_a, arstn_b, arstn_p;
  wire[P_WIDTH-1:0] hw_cdin, hw_cin;
  wire [1:0] sel_cdin;

  always @ (nGrst)
    if((WIDTH_A>18) || (WIDTH_B>18))
      $display("Error: Multiplicand bitwidth cannot exceed 18\n");

  assign ea_w = BYPASS_REG_A ? 2'b11 : {en_a,en_a};
  assign eb_w = BYPASS_REG_B ? 2'b11 : {en_b,en_b};
  assign ep_w = BYPASS_REG_P ? 2'b11 : {en_p,en_p};

  //sar81520 assign rstn_a_w = BYPASS_REG_A ? 2'b11 : {rstn,rstn};
  //sar81520 assign rstn_b_w = BYPASS_REG_B ? 2'b11 : {rstn,rstn};
  //sar81520 assign rstn_p_w = BYPASS_REG_P ? 2'b11 : {rstn,rstn};
  //sar81520 assign arstn_a  = BYPASS_REG_A ? 2'b11 : {nGrst,nGrst};   // tool
  //sar81520 assign arstn_b  = BYPASS_REG_B ? 2'b11 : {nGrst,nGrst};   // tool
  //sar81520 assign arstn_p  = BYPASS_REG_P ? 2'b11 : {nGrst,nGrst};   // tool
  
  generate if (BYPASS_REG_A == 1) 
    begin
      assign rstn_a_w = 2'b11;
      assign arstn_a  = 2'b11;
    end
  else 
    begin
      assign rstn_a_w = {rstn,rstn};
      assign arstn_a  = {nGrst,nGrst};
    end
  endgenerate
      
  generate if (BYPASS_REG_B == 1) 
    begin
      assign rstn_b_w = 2'b11;
      assign arstn_b  = 2'b11;
    end
  else 
    begin
      assign rstn_b_w = {rstn,rstn};
      assign arstn_b  = {nGrst,nGrst};
    end
  endgenerate

  generate if (BYPASS_REG_P == 1) 
    begin
      assign rstn_p_w = 2'b11;
      assign arstn_p  = 2'b11;
    end
  else 
    begin
      assign rstn_p_w = {rstn,rstn};
      assign arstn_p  = {nGrst,nGrst};
    end
  endgenerate

  // The leftmost mult of a cmplx half-multiplier always has its C input = 0.
  // Other mults take carryins from adjacent mults, that is use CDIN input. 
  // Thus the C input = 0 on all mults of the cmplx half-multiplier, and CDIN 
  // take carryins on all mults except the first one. To implement this, the 
  // 'cdsel' input (parameter) = 0 on the first mult and 1 on the others. 
  assign hw_cin  = cdsel ? 'b0 : carryin;   
  assign hw_cdin = cdsel ? carryin : 'b0; // the case for a column bottom only

  fft_inpl_signExt # ( .INWIDTH(WIDTH_A), .OUTWIDTH(18), .UNSIGNED(0)) signExt_a (
    .inp(mcand_a), .outp(mcand_a18)  );
  fft_inpl_signExt # ( .INWIDTH(WIDTH_B), .OUTWIDTH(18), .UNSIGNED(0)) signExt_b (
    .inp(mcand_b), .outp(mcand_b18)  );

  generate if(FPGA_FAMILY == 12) begin: rtax_d
    MATH18X18 mac_0 (
      .CLK({clk,clk}),
      .A(mcand_a18),
      .EA(ea_w),
      .ARSTA(arstn_a),      // async rst
      .SRSTA(rstn_a_w),     // sync rst
      .ALAT(BY_REGA),       // latch

      .B    (mcand_b18),
      .EB   (eb_w),
      .ARSTB(arstn_b),      // async rs
      .SRSTB(rstn_b_w),     // sync rst
      .BLAT (BY_REGB),      // latch

      .P    (pout),
      .CDOUT(cdout),
      .OVFL (),
      .EP   (ep_w),
      .ARSTP(arstn_p),      // async rs
      .SRSTP(rstn_p_w),     // sync rst
      .PLAT (BY_REGP),      // latch

      .CIN  (hw_cin),
      .CDIN (hw_cdin),

      .SUB        (sub),
      .ESUB       (1'b1),           // en
      .SUBAD      (1'b0),           // async data bit
      .ALSUB      (1'b1),           // async load the data bit
      .SUBSD      (1'b1),           // sync data bit
      .SLSUB      (1'b1),           // sync load the data bit
      .SUBLAT     (1'b1),           // latch

      .SHFTSEL    (shftsel),
      .ESHFTSEL   (1'b1),           // en
      .SHFTSELAD  (1'b0),           // async data bit
      .ALSHFTSEL  (1'b1),           // async load the data bit
      .SHFTSELSD  (1'b1),           // sync data bit
      .SLSHFTSEL  (1'b1),           // sync load the data bit
      .SHFTSELLAT (1'b1),           // latch

      .CDSEL      (cdsel),
      .ECDSEL     (1'b1),           // en
      .CDSELAD    (1'b0),           // async data bit
      .ALCDSEL    (1'b1),           // async load the data bit
      .CDSELSD    (1'b1),           // sync data bit
      .SLCDSEL    (1'b1),           // sync load the data bit
      .CDSELLAT   (1'b1),           // latch

      .FDBKSEL    (1'b0),
      .EFDBKSEL   (1'b1),           // en
      .FDBKSELAD  (1'b0),           // async data bit
      .ALFDBKSEL  (1'b1),           // async load the data bit
      .FDBKSELSD  (1'b1),           // sync data bit
      .SLFDBKSEL  (1'b1),           // sync load the data bit
      .FDBKSELLAT (1'b1),           // latch

      .SIMD(1'b0)             );
    end
  endgenerate

  generate if( (FPGA_FAMILY==19) || (FPGA_FAMILY==24) || (FPGA_FAMILY==25) ) begin: g4_macc
    // Cdin input of a MAC by design is connected ONLY to cdout of an adjacent
    // MAC
    // 1.Set fdbksel mux (sel0) to let zero thru it.
    // 2.Set cdsel mux to disconnect cdin and let the fdbk mux output, i.e.
    //   zero thru it.
    MACC macc_0 (
      .CLK  ({clk,clk}),

      .A        (mcand_a18),
      .A_EN     (ea_w),
      .A_ARST_N (arstn_a),
      .A_SRST_N (rstn_a_w),
      .A_BYPASS (BY_REGA),      // latch

      .B        (mcand_b18),
      .B_EN     (eb_w),
      .B_ARST_N (arstn_b),
      .B_SRST_N (rstn_b_w),
      .B_BYPASS (BY_REGB),      // latch

      // Permanent 44'b0 generator
      .C        (44'hFFFFFFFFFFF),
      .C_EN     (2'b11),
//sar81520      .C_ARST_N (2'b00),
      .C_ARST_N ({nGrst,nGrst}),
//sar81520      .C_SRST_N (2'b11),
      .C_SRST_N (2'b00),
      .C_BYPASS (2'b00),        // latch
      .CARRYIN  (1'b1),

      .P        (pout),
      .CDOUT    (cdout),
      .P_EN     (ep_w),
      .P_ARST_N (arstn_p),
      .P_SRST_N (rstn_p_w),
      .P_BYPASS (BY_REGP),      //latch

      .OVFL_CARRYOUT  (),

      .CDIN (hw_cdin),

      // Transparent reg as on the cmplc mult sub is static
      .SUB        (sub),
      .SUB_EN     (1'b1),           // en
      .SUB_AD     (1'b0),           // async data bit
      .SUB_AL_N   (1'b1),           // async load the data bit
      .SUB_SD_N   (1'b1),           // sync data bit
      .SUB_SL_N   (1'b1),           // sync load the data bit
      .SUB_BYPASS (1'b1),           // latch

      // Transparent reg as shftsel is static
      .ARSHFT17         (shftsel),
      .ARSHFT17_EN      (1'b1),           // en
      .ARSHFT17_AD      (1'b0),           // async data bit
      .ARSHFT17_AL_N    (1'b1),           // async load the data bit
      .ARSHFT17_SD_N    (1'b1),           // sync data bit
      .ARSHFT17_SL_N    (1'b1),           // sync load the data bit
      .ARSHFT17_BYPASS  (1'b1),           // latch

      // Let zero thru fdbksel mux so, that when cdsel==0 adder 'd' input = 0
      // Reg is a permanent 0 generator to keep fdbk control signal = 0
      .FDBKSEL        (1'b0),   // cannot tight it to high !!! SAR 34520
      .FDBKSEL_EN     (1'b1),           // en
      .FDBKSEL_AD     (1'b0),           // async data bit
      .FDBKSEL_AL_N   (1'b0),           // async load the data bit
      .FDBKSEL_SD_N   (1'b1),           // sync data bit
      .FDBKSEL_SL_N   (1'b1),           // sync load the data bit
      .FDBKSEL_BYPASS (1'b1),           // latch

      // Transparent reg as cdsel is static
      .CDSEL        (cdsel),
      .CDSEL_EN     (1'b1),           // en
      .CDSEL_AD     (1'b0),           // async data bit
      .CDSEL_AL_N   (1'b1),           // async load the data bit
      .CDSEL_SD_N   (1'b1),           // sync data bit
      .CDSEL_SL_N   (1'b1),           // sync load the data bit
      .CDSEL_BYPASS (1'b1),           // latch

      .OVFL_CARRYOUT_SEL  (1'b1),     // Select carryout 1 ???

      .SIMD(1'b0),
      .DOTP(1'b0)    );
    end
  endgenerate

  generate if( FPGA_FAMILY==26 )  begin: g5_macc
    assign sel_cdin = (cdsel==1'b1)? 2'b11 : 2'b00;  
    MACC_PA macc_0 (
      .CLK  (clk),

      .AL_N (nGrst),      // Negative async reset for all regs except C, D and B2

      .A        (mcand_a18),
      .A_BYPASS (1'b0),   // A reg on
      .A_SRST_N (rstn),
      .A_EN     (en_a),

      .B        (mcand_b18),
      .B_BYPASS (1'b0),   // B reg on
      .B_SRST_N (rstn),
      .B_EN     (en_b),

      // D reg to keep const 0
      .D        (18'h3FFFF),
      .D_ARST_N (nGrst),
      .D_BYPASS (1'b0),   // B reg on
      .D_SRST_N (1'b0),
      .D_EN     (1'b1),
      
      // Constant 48'b0 generator
      .CARRYIN  (1'b1),
      .C        (48'hFFFFFFFFFFFF),
      .C_BYPASS (1'b0),   // C reg on
      .C_ARST_N (nGrst),
      .C_SRST_N (1'b0),
      .C_EN     (1'b1),

      .CDIN (carryin),

      .P        (pout),
      .OVFL_CARRYOUT  (),
      .CDOUT    (cdout),
      .P_EN     (en_p),
      .P_SRST_N (rstn),
      .P_BYPASS (1'b0),      //latch

      //  ----------  Ctrl inputs  ---------
      // Pre-adder isn't used on cmplx mult. Configure to be permanent 0 gen 
      .PASUB        (1'b0),   
      .PASUB_BYPASS (1'b0),   //Static
      .PASUB_AD_N   (1'b0),   //Static. Data to be loaded on async AL_N
      .PASUB_SL_N   (1'b0),   // Negative sync reset
      .PASUB_SD_N   (1'b0),   //Static. Data to be loaded on sync PASUB_SL_N
      .PASUB_EN     (1'b1),   

      // Transparent reg, as sub is static on a cmplx multiplier
      .SUB        (sub),
      .SUB_EN     (1'b1),           // en
      .SUB_AD_N   (1'b1),           // Static. Data to be loaded on async rst
      .SUB_SD_N   (1'b1),           // Static. Data to be loaded on sync SL_N
      .SUB_SL_N   (1'b1),           // Sync reset
      .SUB_BYPASS (1'b1),           // latch

      // Transparent reg, as shftsel is static on a cmplx multiplier
      .ARSHFT17         (shftsel),
      .ARSHFT17_EN      (1'b1),     // en
      .ARSHFT17_AD_N    (1'b1),     // Static. Data to be loaded on async rst
      .ARSHFT17_SD_N    (1'b1),     // Static. Data to be loaded on sync SL_N
      .ARSHFT17_SL_N    (1'b1),     // Sync reset
      .ARSHFT17_BYPASS  (1'b1),     // latch

      // Keep selector mux either in CDIN or 0 generator position.
      // Reg is transparent, as cdsel is static
      .CDIN_FDBK_SEL        (sel_cdin),   
      .CDIN_FDBK_SEL_BYPASS (1'b1),   //static
      .CDIN_FDBK_SEL_AD_N   (2'b11),  //Static. Value to be loaded on async rst
      .CDIN_FDBK_SEL_SD_N   (2'b11),  //Static. Value to be loaded on sync rst CDIN_FDBK_SEL_SL_N
      .CDIN_FDBK_SEL_SL_N   (1'b1),   // Negative sync reset
      .CDIN_FDBK_SEL_EN     (1'b1),

      .OVFL_CARRYOUT_SEL  (1'b0),
      .SIMD(1'b0),
      .DOTP(1'b0)    );
    end
  endgenerate


endmodule



































































