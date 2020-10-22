// ***************************************************************************/
//Actel Corporation Proprietary and Confidential
//Copyright 2009 Actel Corporation. All rights reserved.
//
//ANY USE OR REDISTRIBUTION IN PART OR IN WHOLE MUST BE HANDLED IN
//ACCORDANCE WITH THE ACTEL LICENSE AGREEMENT AND MUST BE APPROVED
//IN ADVANCE IN WRITING.
//
//Description:  CoreFFT
//              Complex Multiplier calculates (q.re+j*q.im)*(t.re+j*t.im) =
//                                (q.re*t.re-q.im*t.im)+j*(q.im*t.re+q.re*t.im)
//
//Revision Information:
//Date         Description
//05Nov2009    Initial Release
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

`timescale 1 ns/100 ps
//      _   _   _   _   _   _     _   _   _   _   _   _   _
//     / \ / \ / \ / \ / \ / \   / \ / \ / \ / \ / \ / \ / \
//    ( 3 | 5 | - | b | i | t ) ( C | o | m | p | l | e | x )
//     \_/ \_/ \_/ \_/ \_/ \_/   \_/ \_/ \_/ \_/ \_/ \_/ \_/
// 4-mult 19-35 bits complex multiplier calculates h=a*b-/+c*d
//    Note: provided bitwidth of all mcands = WIDTH,
//    half_prod bitwidth = 2*WIDTH + one extra bit due to addition/sub
module fft_inpl_half_cmplx_35 (nGrst, rst, clk, clkEn,
  al,
  bl,
  cl_tick,
  dl_tick,
  al_tick2,
  bl_tick3,
  cl_tick4,
  dl_tick5,
  bh_tick2,
  ah_tick3,
  dh_tick4,
  ch_tick5,
  ah_tick6,
  bh_tick6,
  ch_tick7,
  dh_tick7,
  half_prod);
  parameter WIDTH = 32;
  parameter MINUS = 1;    // -/+
  parameter NOPIPE = 1;   // bypass regP
  parameter FPGA_FAMILY = 12;
  parameter P_WIDTH = 41;

  localparam DBG = 0;
  localparam SUB = MINUS ? 1'b1 : 1'b0;

  input nGrst, rst, clk, clkEn;
  input [17:0] al, bl, cl_tick, dl_tick, al_tick2, bl_tick3, cl_tick4, dl_tick5;
  input [WIDTH-18:0] bh_tick2, ah_tick3, dh_tick4, ch_tick5;
  input [WIDTH-18:0] ah_tick6, bh_tick6, ch_tick7, dh_tick7;
  output[2*WIDTH:0] half_prod;

  wire rstn = ~rst;
  wire[P_WIDTH-1:0] halfl, halfm, halfh;
  wire[P_WIDTH-1:0] cd_w [1:7];

  wire [P_WIDTH-1:0] zero = {P_WIDTH{1'b0}};

  // cut off extra MSB's but keep sign
  fft_inpl_signExt # ( .INWIDTH(P_WIDTH), .OUTWIDTH(2*WIDTH+1-34), .UNSIGNED(0)) signExt_p (
    .inp(halfh), .outp(half_prod[2*WIDTH:34])  );

  generate
    if(NOPIPE==0) begin
      fft_inpl_kitDelay_reg # (.BITWIDTH(17), .DELAY(6) ) dly_half1 (
        .nGrst(nGrst), .rst(rst), .clk(clk), .clkEn(clkEn),
        .inp(halfl[16:0]), .outp(half_prod[16:0])  );
      fft_inpl_kitDelay_reg # (.BITWIDTH(17), .DELAY(2) ) dly_half2 (
        .nGrst(nGrst), .rst(rst), .clk(clk), .clkEn(clkEn),
        .inp(halfm[16:0]), .outp(half_prod[33:17])  );
    end
    else  begin
      assign half_prod[33:17] = halfm[16:0];
      assign half_prod[16:0]  = halfl[16:0];
    end
  endgenerate

  fft_inpl_mac18x18mx # (.BYPASS_REG_A(DBG), .BYPASS_REG_B(DBG), .BYPASS_REG_P(NOPIPE),
                .WIDTH_A(18), .WIDTH_B(18), .FPGA_FAMILY(FPGA_FAMILY) ) mx_1 (  //g4
    .nGrst(nGrst), .rstn(rstn), .clk(clk), .en_a(1'b1),.en_b(1'b1),.en_p(1'b1),
    .mcand_a(al), .mcand_b(bl),
    .carryin(zero),
    .cdout(cd_w[1]),
    .pout(), .cdsel(1'b0), .shftsel(1'b0), .sub(1'b0) );

  fft_inpl_mac18x18mx # (.BYPASS_REG_A(DBG), .BYPASS_REG_B(DBG), .BYPASS_REG_P(NOPIPE),
                .WIDTH_A(18), .WIDTH_B(18), .FPGA_FAMILY(FPGA_FAMILY) ) mx_2 (
    .nGrst(nGrst), .rstn(rstn), .clk(clk), .en_a(1'b1),.en_b(1'b1),.en_p(1'b1),
    .mcand_a(cl_tick), .mcand_b(dl_tick),
    .carryin(cd_w[1]),
    .cdout(cd_w[2]),
    .pout(halfl), .cdsel(1'b1), .shftsel(1'b0), .sub(SUB) );

  fft_inpl_mac18x18mx # (.BYPASS_REG_A(DBG), .BYPASS_REG_B(DBG), .BYPASS_REG_P(NOPIPE),
                .WIDTH_A(18), .WIDTH_B(WIDTH-17), .FPGA_FAMILY(FPGA_FAMILY) ) mx_3 (
    .nGrst(nGrst), .rstn(rstn), .clk(clk), .en_a(1'b1),.en_b(1'b1),.en_p(1'b1),
    .mcand_a(al_tick2), .mcand_b(bh_tick2),
    .carryin(cd_w[2]),
    .cdout(cd_w[3]),
    .pout(), .cdsel(1'b1), .shftsel(1'b1), .sub(1'b0) );

  fft_inpl_mac18x18mx # (.BYPASS_REG_A(DBG), .BYPASS_REG_B(DBG), .BYPASS_REG_P(NOPIPE),
                .WIDTH_A(WIDTH-17), .WIDTH_B(18), .FPGA_FAMILY(FPGA_FAMILY) ) mx_4 (
    .nGrst(nGrst), .rstn(rstn), .clk(clk), .en_a(1'b1),.en_b(1'b1),.en_p(1'b1),
    .mcand_a(ah_tick3), .mcand_b(bl_tick3),
    .carryin(cd_w[3]),
    .cdout(cd_w[4]),
    .pout(), .cdsel(1'b1), .shftsel(1'b0), .sub(1'b0) );

  fft_inpl_mac18x18mx # (.BYPASS_REG_A(DBG), .BYPASS_REG_B(DBG), .BYPASS_REG_P(NOPIPE),
                .WIDTH_A(18), .WIDTH_B(WIDTH-17), .FPGA_FAMILY(FPGA_FAMILY) ) mx_5 (
    .nGrst(nGrst), .rstn(rstn), .clk(clk), .en_a(1'b1),.en_b(1'b1),.en_p(1'b1),
    .mcand_a(cl_tick4), .mcand_b(dh_tick4),
    .carryin(cd_w[4]),
    .cdout(cd_w[5]),
    .pout(), .cdsel(1'b1), .shftsel(1'b0), .sub(SUB) );

  fft_inpl_mac18x18mx # (.BYPASS_REG_A(DBG), .BYPASS_REG_B(DBG), .BYPASS_REG_P(NOPIPE),
                .WIDTH_A(WIDTH-17), .WIDTH_B(18), .FPGA_FAMILY(FPGA_FAMILY) ) mx_6 (
    .nGrst(nGrst), .rstn(rstn), .clk(clk), .en_a(1'b1),.en_b(1'b1),.en_p(1'b1),
    .mcand_a(ch_tick5), .mcand_b(dl_tick5),
    .carryin(cd_w[5]),
    .cdout(cd_w[6]),
    .pout(halfm), .cdsel(1'b1), .shftsel(1'b0), .sub(SUB) );

  fft_inpl_mac18x18mx # (.BYPASS_REG_A(DBG), .BYPASS_REG_B(DBG), .BYPASS_REG_P(NOPIPE),
                .WIDTH_A(WIDTH-17), .WIDTH_B(WIDTH-17), .FPGA_FAMILY(FPGA_FAMILY) ) mx_7 (
    .nGrst(nGrst), .rstn(rstn), .clk(clk), .en_a(1'b1),.en_b(1'b1),.en_p(1'b1),
    .mcand_a(ah_tick6), .mcand_b(bh_tick6),
    .carryin(cd_w[6]),
    .cdout(cd_w[7]),
    .pout(), .cdsel(1'b1), .shftsel(1'b1), .sub(1'b0) );

  fft_inpl_mac18x18mx # (.BYPASS_REG_A(DBG), .BYPASS_REG_B(DBG), .BYPASS_REG_P(NOPIPE),
                .WIDTH_A(WIDTH-17), .WIDTH_B(WIDTH-17), .FPGA_FAMILY(FPGA_FAMILY) ) mx_8 (
    .nGrst(nGrst), .rstn(rstn), .clk(clk), .en_a(1'b1),.en_b(1'b1),.en_p(1'b1),
    .mcand_a(ch_tick7), .mcand_b(dh_tick7),
    .carryin(cd_w[7]),
    .cdout(),
    .pout(halfh), .cdsel(1'b1), .shftsel(1'b0), .sub(SUB) );
endmodule


// Full precision cmplx multiplier.  The partial products are 2*WIDTH wide,
// and output sums Hr, Hi are (2*WIDTH+1) wide
module fft_inpl_cmplx_35 (nGrst, rst, clk, clkEn,
  // imaginary and real inputs
  Qi, Qr,
  Ti, Tr,
  // imaginary and real output
  Hi, Hr);
  parameter WIDTH = 32;
  parameter NOPIPE = 1;   // bypass regP
  parameter FPGA_FAMILY = 12;       //g4
  parameter P_WIDTH = 41;           //g4

  input nGrst, rst, clk, clkEn;
  input [WIDTH-1:0] Qi, Qr, Ti, Tr;
  output[2*WIDTH:0] Hi, Hr;

  wire[17:0]       qil, qrl, til, trl;
  wire[WIDTH-18:0] qih, qrh, tih, trh;

  wire[17:0] til_tick, trl_tick3, til_tick5;
  wire[WIDTH-18:0] trh_tick2, tih_tick4, trh_tick6, tih_tick7;

  wire[17:0] qil_tick, qrl_tick2, qil_tick4;
  wire[17:0] qrl_tick, qil_tick2, qrl_tick4;
  wire[WIDTH-18:0] qrh_tick3, qih_tick5, qrh_tick6, qih_tick7;
  wire[WIDTH-18:0] qih_tick3, qrh_tick5, qih_tick6, qrh_tick7;

  // separate inputs into 17-bit LSB's and remaining MSB's
  assign qil = {1'b0, Qi[16:0]};
  assign qrl = {1'b0, Qr[16:0]};
  assign til = {1'b0, Ti[16:0]};
  assign trl = {1'b0, Tr[16:0]};
  assign qih = Qi[WIDTH-1:17];
  assign qrh = Qr[WIDTH-1:17];
  assign tih = Ti[WIDTH-1:17];
  assign trh = Tr[WIDTH-1:17];

  generate
    if(NOPIPE==0) begin
      // til_tick, trl_tick3, til_tick5;
      fft_inpl_kitDelay_reg # (.BITWIDTH(18), .DELAY(1) ) dly_til0 (
        .nGrst(nGrst), .rst(rst), .clk(clk), .clkEn(clkEn),
        .inp(til), .outp(til_tick)  );
      fft_inpl_kitDelay_reg # (.BITWIDTH(18), .DELAY(3) ) dly_til1 (
        .nGrst(nGrst), .rst(rst), .clk(clk), .clkEn(clkEn),
        .inp(trl), .outp(trl_tick3)  );
      fft_inpl_kitDelay_reg # (.BITWIDTH(18), .DELAY(4) ) dly_til2 (
        .nGrst(nGrst), .rst(rst), .clk(clk), .clkEn(clkEn),
        .inp(til_tick), .outp(til_tick5)  );

      // qil_tick, qrl_tick ,
      fft_inpl_kitDelay_reg # (.BITWIDTH(18), .DELAY(1) ) dly_qil0 (
        .nGrst(nGrst), .rst(rst), .clk(clk), .clkEn(clkEn),
        .inp(qil), .outp(qil_tick)  );
      fft_inpl_kitDelay_reg # (.BITWIDTH(18), .DELAY(1) ) dly_qrl0 (
        .nGrst(nGrst), .rst(rst), .clk(clk), .clkEn(clkEn),
        .inp(qrl), .outp(qrl_tick)  );

      // qil_tick2, qrl_tick2
      fft_inpl_kitDelay_reg # (.BITWIDTH(18), .DELAY(1) ) dly_qil1 (
        .nGrst(nGrst), .rst(rst), .clk(clk), .clkEn(clkEn),
        .inp(qil_tick), .outp(qil_tick2)  );
      fft_inpl_kitDelay_reg # (.BITWIDTH(18), .DELAY(1) ) dly_qrl1 (
        .nGrst(nGrst), .rst(rst), .clk(clk), .clkEn(clkEn),
        .inp(qrl_tick), .outp(qrl_tick2)  );

      // qil_tick4, qrl_tick4
      fft_inpl_kitDelay_reg # (.BITWIDTH(18), .DELAY(2) ) dly_qil2 (
        .nGrst(nGrst), .rst(rst), .clk(clk), .clkEn(clkEn),
        .inp(qil_tick2), .outp(qil_tick4)  );
      fft_inpl_kitDelay_reg # (.BITWIDTH(18), .DELAY(2) ) dly_qrl2 (
        .nGrst(nGrst), .rst(rst), .clk(clk), .clkEn(clkEn),
        .inp(qrl_tick2), .outp(qrl_tick4)  );

      // trh_tick2, tih_tick4, trh_tick6, tih_tick7
      fft_inpl_kitDelay_reg # (.BITWIDTH(WIDTH-17), .DELAY(2) ) dly_trh0 (
        .nGrst(nGrst), .rst(rst), .clk(clk), .clkEn(clkEn),
        .inp(trh), .outp(trh_tick2)  );
      fft_inpl_kitDelay_reg # (.BITWIDTH(WIDTH-17), .DELAY(4) ) dly_tih0 (
        .nGrst(nGrst), .rst(rst), .clk(clk), .clkEn(clkEn),
        .inp(tih), .outp(tih_tick4)  );
      fft_inpl_kitDelay_reg # (.BITWIDTH(WIDTH-17), .DELAY(4) ) dly_trh1 (
        .nGrst(nGrst), .rst(rst), .clk(clk), .clkEn(clkEn),
        .inp(trh_tick2), .outp(trh_tick6)  );
      fft_inpl_kitDelay_reg # (.BITWIDTH(WIDTH-17), .DELAY(3) ) dly_tih1 (
        .nGrst(nGrst), .rst(rst), .clk(clk), .clkEn(clkEn),
        .inp(tih_tick4), .outp(tih_tick7)  );

      // qih_tick3, qrh_tick3
      fft_inpl_kitDelay_reg # (.BITWIDTH(WIDTH-17), .DELAY(3) ) dly_qih0 (
        .nGrst(nGrst), .rst(rst), .clk(clk), .clkEn(clkEn),
        .inp(qih), .outp(qih_tick3)  );
      fft_inpl_kitDelay_reg # (.BITWIDTH(WIDTH-17), .DELAY(3) ) dly_qrh0 (
        .nGrst(nGrst), .rst(rst), .clk(clk), .clkEn(clkEn),
        .inp(qrh), .outp(qrh_tick3)  );

      // qih_tick5, qrh_tick5
      fft_inpl_kitDelay_reg # (.BITWIDTH(WIDTH-17), .DELAY(2) ) dly_qih01 (
        .nGrst(nGrst), .rst(rst), .clk(clk), .clkEn(clkEn),
        .inp(qih_tick3), .outp(qih_tick5)  );
      fft_inpl_kitDelay_reg # (.BITWIDTH(WIDTH-17), .DELAY(2) ) dly_qrh1 (
        .nGrst(nGrst), .rst(rst), .clk(clk), .clkEn(clkEn),
        .inp(qrh_tick3), .outp(qrh_tick5)  );

      // qih_tick6, qrh_tick6
      fft_inpl_kitDelay_reg # (.BITWIDTH(WIDTH-17), .DELAY(1) ) dly_qih2 (
        .nGrst(nGrst), .rst(rst), .clk(clk), .clkEn(clkEn),
        .inp(qih_tick5), .outp(qih_tick6)  );
      fft_inpl_kitDelay_reg # (.BITWIDTH(WIDTH-17), .DELAY(1) ) dly_qrh2 (
        .nGrst(nGrst), .rst(rst), .clk(clk), .clkEn(clkEn),
        .inp(qrh_tick5), .outp(qrh_tick6)  );

      // qih_tick7, qrh_tick7
      fft_inpl_kitDelay_reg # (.BITWIDTH(WIDTH-17), .DELAY(1) ) dly_qih3 (
        .nGrst(nGrst), .rst(rst), .clk(clk), .clkEn(clkEn),
        .inp(qih_tick6), .outp(qih_tick7)  );
      fft_inpl_kitDelay_reg # (.BITWIDTH(WIDTH-17), .DELAY(1) ) dly_qrh3 (
        .nGrst(nGrst), .rst(rst), .clk(clk), .clkEn(clkEn),
        .inp(qrh_tick6), .outp(qrh_tick7)  );
    end
    else  begin
      assign til_tick   = til;
      assign trl_tick3  = trl;
      assign til_tick5  = til;
      assign qil_tick   = qil;
      assign qrl_tick   = qrl;
      assign qrl_tick2  = qrl;
      assign qil_tick2  = qil;
      assign qil_tick4  = qil;
      assign qrl_tick4  = qrl;
      assign trh_tick2  = trh;
      assign tih_tick4  = tih;
      assign trh_tick6  = trh;
      assign tih_tick7  = tih;
      assign qih_tick3  = qih;
      assign qrh_tick3  = qrh;
      assign qih_tick5  = qih;
      assign qrh_tick5  = qrh;
      assign qih_tick6  = qih;
      assign qrh_tick6  = qrh;
      assign qih_tick7  = qih;
      assign qrh_tick7  = qrh;
    end
  endgenerate

  fft_inpl_half_cmplx_35 # (.WIDTH(WIDTH), .MINUS(1), .NOPIPE(NOPIPE),
                   .FPGA_FAMILY(FPGA_FAMILY), .P_WIDTH(P_WIDTH) ) half_0 (
    .nGrst(nGrst), .rst(rst), .clk(clk), .clkEn(clkEn),
    .al      (qrl),
    .bl      (trl),
    .cl_tick (qil_tick),
    .dl_tick (til_tick),
    .al_tick2(qrl_tick2),
    .bh_tick2(trh_tick2),
    .ah_tick3(qrh_tick3),
    .bl_tick3(trl_tick3),
    .cl_tick4(qil_tick4),
    .dh_tick4(tih_tick4),
    .ch_tick5(qih_tick5),
    .dl_tick5(til_tick5),
    .ah_tick6(qrh_tick6),
    .bh_tick6(trh_tick6),
    .ch_tick7(qih_tick7),
    .dh_tick7(tih_tick7),
    .half_prod(Hr)        );

  fft_inpl_half_cmplx_35 # (.WIDTH(WIDTH), .MINUS(0), .NOPIPE(NOPIPE),
                   .FPGA_FAMILY(FPGA_FAMILY), .P_WIDTH(P_WIDTH) ) half_1 (
    .nGrst(nGrst), .rst(rst), .clk(clk), .clkEn(clkEn),
    .al      (qil),
    .bl      (trl),
    .cl_tick (qrl_tick),
    .dl_tick (til_tick),
    .al_tick2(qil_tick2),
    .bh_tick2(trh_tick2),
    .ah_tick3(qih_tick3),
    .bl_tick3(trl_tick3),
    .cl_tick4(qrl_tick4),
    .dh_tick4(tih_tick4),
    .ch_tick5(qrh_tick5),
    .dl_tick5(til_tick5),
    .ah_tick6(qih_tick6),
    .bh_tick6(trh_tick6),
    .ch_tick7(qrh_tick7),
    .dh_tick7(tih_tick7),
    .half_prod(Hi)        );
endmodule


//        _   _   _   _   _   _     _   _   _   _   _   _   _
//       / \ / \ / \ / \ / \ / \   / \ / \ / \ / \ / \ / \ / \
//      ( 1 | 8 | - | b | i | t ) ( C | o | m | p | l | e | x )
//       \_/ \_/ \_/ \_/ \_/ \_/   \_/ \_/ \_/ \_/ \_/ \_/ \_/
// 4-mult complex multiplier
module fft_inpl_half_cmplx_18 (nGrst, rst, clk, clkEn,
  a, b, c, d, half_prod);
  parameter WIDTH = 18;
  parameter MINUS = 1;    // -/+
  parameter NOPIPE = 1;   // bypass regP
  parameter FPGA_FAMILY = 12;
  parameter P_WIDTH = 41;

  localparam SUB = MINUS ? 1'b1 : 1'b0;
  localparam DBG = 0;

  input nGrst, rst, clk, clkEn;
  input [WIDTH-1:0] a, b, c, d;
  output[2*WIDTH:0] half_prod;

  wire rstn = ~rst;
  wire[WIDTH-1:0] c_tick, d_tick;
  wire[P_WIDTH-1:0] cd_w, half;

  wire [P_WIDTH-1:0] zero = {P_WIDTH{1'b0}};

  generate
    if(NOPIPE==0) begin
      fft_inpl_kitDelay_reg # (.BITWIDTH(WIDTH), .DELAY(1) ) dly_c (
        .nGrst(nGrst), .rst(rst), .clk(clk), .clkEn(clkEn),
        .inp(c), .outp(c_tick)  );
      fft_inpl_kitDelay_reg # (.BITWIDTH(WIDTH), .DELAY(1) ) dly_d (
        .nGrst(nGrst), .rst(rst), .clk(clk), .clkEn(clkEn),
        .inp(d), .outp(d_tick)  );
    end
    else  begin
      assign c_tick = c;
      assign d_tick = d;
    end
  endgenerate

  fft_inpl_mac18x18mx # (.BYPASS_REG_A(DBG), .BYPASS_REG_B(DBG), .BYPASS_REG_P(NOPIPE),
                .WIDTH_A(WIDTH), .WIDTH_B(WIDTH), .FPGA_FAMILY(FPGA_FAMILY) ) mx_0 (
    .nGrst(nGrst), .rstn(rstn), .clk(clk), .en_a(1'b1),.en_b(1'b1),.en_p(1'b1),
    .mcand_a(a), .mcand_b(b),
    .carryin(zero),
    .cdout(cd_w),
    .pout(), .cdsel(1'b0), .shftsel(1'b0), .sub(1'b0) );

  fft_inpl_mac18x18mx # (.BYPASS_REG_A(DBG), .BYPASS_REG_B(DBG), .BYPASS_REG_P(0),
                .WIDTH_A(WIDTH), .WIDTH_B(WIDTH), .FPGA_FAMILY(FPGA_FAMILY) ) mx_1 (
    .nGrst(nGrst), .rstn(rstn), .clk(clk), .en_a(1'b1),.en_b(1'b1),.en_p(1'b1),
    .mcand_a(c_tick), .mcand_b(d_tick),
    .carryin(cd_w),
    .cdout(),
    .pout(half), .cdsel(1'b1), .shftsel(1'b0), .sub(SUB) );

  // cut off extra MSB's but keep sign
  fft_inpl_signExt # ( .INWIDTH(P_WIDTH), .OUTWIDTH(2*WIDTH+1), .UNSIGNED(0)) signExt_p (
    .inp(half), .outp(half_prod)  );
endmodule


// Full precision cmplx multiplier.  The partial products are 2*WIDTH wide,
// and output sums Hr, Hi are (2*WIDTH+1) wide
module fft_inpl_cmplx_18 (nGrst, rst, clk, clkEn,
  // imaginary and real inputs
  Qi, Qr,
  Ti, Tr,
  // imaginary and real output
  Hi, Hr);
  parameter WIDTH = 18;
  parameter NOPIPE = 0;   // bypass regP
  parameter FPGA_FAMILY = 12;
  parameter P_WIDTH = 41;

  input nGrst, rst, clk, clkEn;
  input [WIDTH-1:0] Qi, Qr, Ti, Tr;
  output[2*WIDTH:0] Hi, Hr;

  fft_inpl_half_cmplx_18 # (.WIDTH (WIDTH ), .MINUS (1), .NOPIPE(NOPIPE),
                   .FPGA_FAMILY(FPGA_FAMILY), .P_WIDTH(P_WIDTH) ) half_0 (
    .nGrst(nGrst), .rst(rst), .clk(clk), .clkEn(clkEn),
    .a(Qr), .b(Tr), .c(Qi), .d(Ti),
    .half_prod(Hr)  );

  fft_inpl_half_cmplx_18 # (.WIDTH (WIDTH ), .MINUS (0), .NOPIPE(NOPIPE),
                   .FPGA_FAMILY(FPGA_FAMILY), .P_WIDTH(P_WIDTH) ) half_1 (
    .nGrst(nGrst), .rst(rst), .clk(clk), .clkEn(clkEn),
    .a(Qi), .b(Tr), .c(Qr), .d(Ti),
    .half_prod(Hi)  );
endmodule

module fft_inpl_cmplx_rnd (nGrst, rst, clk, clkEn,
  // imaginary and real inputs
  Qi, Qr,
  Ti, Tr,
  // imaginary and real output
  Hi, Hr);
  parameter WIDTH = 18;
  parameter NOPIPE = 0;   // bypass regP
  parameter FPGA_FAMILY = 12;

  localparam RND = 1;

  localparam P_WIDTH = (FPGA_FAMILY==12)? 41 : (FPGA_FAMILY==26)? 48 : 44;

  input nGrst, rst, clk, clkEn;
  input [WIDTH-1:0] Qi, Qr, Ti, Tr;
  output[WIDTH-1:0] Hi, Hr;

  wire [2*WIDTH:0] Hi_full, Hr_full;

  generate
    if(WIDTH<19)
      fft_inpl_cmplx_18 # (.WIDTH(WIDTH), .NOPIPE(NOPIPE),
                  .FPGA_FAMILY(FPGA_FAMILY), .P_WIDTH(P_WIDTH) ) cmplx18_0 (
        .nGrst(nGrst),  .rst(rst), .clk(clk), .clkEn(clkEn),
        .Qi(Qi), .Qr(Qr), .Ti(Ti), .Tr(Tr),
        .Hi(Hi_full), .Hr(Hr_full)  );
    else
      fft_inpl_cmplx_35 # (.WIDTH(WIDTH), .NOPIPE(NOPIPE),
                  .FPGA_FAMILY(FPGA_FAMILY), .P_WIDTH(P_WIDTH) ) cmplx35_0 (
        .nGrst(nGrst),  .rst(rst), .clk(clk), .clkEn(clkEn),
        .Qi(Qi), .Qr(Qr), .Ti(Ti), .Tr(Tr),
        .Hi(Hi_full), .Hr(Hr_full)  );
  endgenerate

  // Partial products are 2*WIDTH wide but their MSB is redundant as the next
  // bit MSB-1 replicates it.  Then the sumd Hr, Hi have the redundant MSB, too.
  // Discard these prior to rounding
  fft_inpl_kitRndUp # (.WIDTH_OUT(WIDTH), .RND_MODE (RND)  ) rndHi_0 (
    .nGrst(nGrst), .clk(clk), .rst(1'b0), .clkEn(1'b1),
    .inp(Hi_full[2*WIDTH-1:WIDTH-1]), .valInp(1'b0),
    .outp(Hi), .valOutp() );
  fft_inpl_kitRndUp # (.WIDTH_OUT(WIDTH), .RND_MODE (RND)  ) rndHr_0 (
    .nGrst(nGrst), .clk(clk), .rst(1'b0), .clkEn(1'b1),
    .inp(Hr_full[2*WIDTH-1:WIDTH-1]), .valInp(1'b0),
    .outp(Hr), .valOutp() );
endmodule
