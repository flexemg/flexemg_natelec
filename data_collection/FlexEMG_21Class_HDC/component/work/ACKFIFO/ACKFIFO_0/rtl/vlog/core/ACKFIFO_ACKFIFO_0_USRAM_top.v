`timescale 1 ns/100 ps
// Version: v11.7 SP3 11.7.3.7


module ACKFIFO_ACKFIFO_0_USRAM_top(
       A_DOUT,
       B_DOUT,
       C_DIN,
       A_ADDR,
       B_ADDR,
       C_ADDR,
       A_BLK,
       B_BLK,
       C_BLK,
       A_ADDR_ARST_N,
       B_ADDR_ARST_N,
       A_ADDR_SRST_N,
       B_ADDR_SRST_N,
       A_ADDR_EN,
       B_ADDR_EN,
       CLK,
       C_WEN
    );
output [31:0] A_DOUT;
output [31:0] B_DOUT;
input  [31:0] C_DIN;
input  [5:0] A_ADDR;
input  [5:0] B_ADDR;
input  [5:0] C_ADDR;
input  A_BLK;
input  B_BLK;
input  C_BLK;
input  A_ADDR_ARST_N;
input  B_ADDR_ARST_N;
input  A_ADDR_SRST_N;
input  B_ADDR_SRST_N;
input  A_ADDR_EN;
input  B_ADDR_EN;
input  CLK;
input  C_WEN;

    wire VCC, GND, ADLIB_VCC;
    wire GND_power_net1;
    wire VCC_power_net1;
    assign GND = GND_power_net1;
    assign VCC = VCC_power_net1;
    assign ADLIB_VCC = VCC_power_net1;
    
    RAM64x18 ACKFIFO_ACKFIFO_0_USRAM_top_R0C0 (.A_DOUT({nc0, 
        A_DOUT[15], A_DOUT[14], A_DOUT[13], A_DOUT[12], A_DOUT[11], 
        A_DOUT[10], A_DOUT[9], A_DOUT[8], nc1, A_DOUT[7], A_DOUT[6], 
        A_DOUT[5], A_DOUT[4], A_DOUT[3], A_DOUT[2], A_DOUT[1], 
        A_DOUT[0]}), .B_DOUT({nc2, B_DOUT[15], B_DOUT[14], B_DOUT[13], 
        B_DOUT[12], B_DOUT[11], B_DOUT[10], B_DOUT[9], B_DOUT[8], nc3, 
        B_DOUT[7], B_DOUT[6], B_DOUT[5], B_DOUT[4], B_DOUT[3], 
        B_DOUT[2], B_DOUT[1], B_DOUT[0]}), .BUSY(), .A_ADDR_CLK(CLK), 
        .A_DOUT_CLK(VCC), .A_ADDR_SRST_N(A_ADDR_SRST_N), 
        .A_DOUT_SRST_N(VCC), .A_ADDR_ARST_N(A_ADDR_ARST_N), 
        .A_DOUT_ARST_N(VCC), .A_ADDR_EN(A_ADDR_EN), .A_DOUT_EN(VCC), 
        .A_BLK({A_BLK, VCC}), .A_ADDR({A_ADDR[5], A_ADDR[4], A_ADDR[3], 
        A_ADDR[2], A_ADDR[1], A_ADDR[0], GND, GND, GND, GND}), 
        .B_ADDR_CLK(CLK), .B_DOUT_CLK(VCC), .B_ADDR_SRST_N(
        B_ADDR_SRST_N), .B_DOUT_SRST_N(VCC), .B_ADDR_ARST_N(
        B_ADDR_ARST_N), .B_DOUT_ARST_N(VCC), .B_ADDR_EN(B_ADDR_EN), 
        .B_DOUT_EN(VCC), .B_BLK({B_BLK, VCC}), .B_ADDR({B_ADDR[5], 
        B_ADDR[4], B_ADDR[3], B_ADDR[2], B_ADDR[1], B_ADDR[0], GND, 
        GND, GND, GND}), .C_CLK(CLK), .C_ADDR({C_ADDR[5], C_ADDR[4], 
        C_ADDR[3], C_ADDR[2], C_ADDR[1], C_ADDR[0], GND, GND, GND, GND})
        , .C_DIN({GND, C_DIN[15], C_DIN[14], C_DIN[13], C_DIN[12], 
        C_DIN[11], C_DIN[10], C_DIN[9], C_DIN[8], GND, C_DIN[7], 
        C_DIN[6], C_DIN[5], C_DIN[4], C_DIN[3], C_DIN[2], C_DIN[1], 
        C_DIN[0]}), .C_WEN(C_WEN), .C_BLK({C_BLK, VCC}), .A_EN(VCC), 
        .A_ADDR_LAT(GND), .A_DOUT_LAT(VCC), .A_WIDTH({VCC, GND, GND}), 
        .B_EN(VCC), .B_ADDR_LAT(GND), .B_DOUT_LAT(VCC), .B_WIDTH({VCC, 
        GND, GND}), .C_EN(VCC), .C_WIDTH({VCC, GND, GND}), .SII_LOCK(
        GND));
    RAM64x18 ACKFIFO_ACKFIFO_0_USRAM_top_R0C1 (.A_DOUT({nc4, 
        A_DOUT[31], A_DOUT[30], A_DOUT[29], A_DOUT[28], A_DOUT[27], 
        A_DOUT[26], A_DOUT[25], A_DOUT[24], nc5, A_DOUT[23], 
        A_DOUT[22], A_DOUT[21], A_DOUT[20], A_DOUT[19], A_DOUT[18], 
        A_DOUT[17], A_DOUT[16]}), .B_DOUT({nc6, B_DOUT[31], B_DOUT[30], 
        B_DOUT[29], B_DOUT[28], B_DOUT[27], B_DOUT[26], B_DOUT[25], 
        B_DOUT[24], nc7, B_DOUT[23], B_DOUT[22], B_DOUT[21], 
        B_DOUT[20], B_DOUT[19], B_DOUT[18], B_DOUT[17], B_DOUT[16]}), 
        .BUSY(), .A_ADDR_CLK(CLK), .A_DOUT_CLK(VCC), .A_ADDR_SRST_N(
        A_ADDR_SRST_N), .A_DOUT_SRST_N(VCC), .A_ADDR_ARST_N(
        A_ADDR_ARST_N), .A_DOUT_ARST_N(VCC), .A_ADDR_EN(A_ADDR_EN), 
        .A_DOUT_EN(VCC), .A_BLK({A_BLK, VCC}), .A_ADDR({A_ADDR[5], 
        A_ADDR[4], A_ADDR[3], A_ADDR[2], A_ADDR[1], A_ADDR[0], GND, 
        GND, GND, GND}), .B_ADDR_CLK(CLK), .B_DOUT_CLK(VCC), 
        .B_ADDR_SRST_N(B_ADDR_SRST_N), .B_DOUT_SRST_N(VCC), 
        .B_ADDR_ARST_N(B_ADDR_ARST_N), .B_DOUT_ARST_N(VCC), .B_ADDR_EN(
        B_ADDR_EN), .B_DOUT_EN(VCC), .B_BLK({B_BLK, VCC}), .B_ADDR({
        B_ADDR[5], B_ADDR[4], B_ADDR[3], B_ADDR[2], B_ADDR[1], 
        B_ADDR[0], GND, GND, GND, GND}), .C_CLK(CLK), .C_ADDR({
        C_ADDR[5], C_ADDR[4], C_ADDR[3], C_ADDR[2], C_ADDR[1], 
        C_ADDR[0], GND, GND, GND, GND}), .C_DIN({GND, C_DIN[31], 
        C_DIN[30], C_DIN[29], C_DIN[28], C_DIN[27], C_DIN[26], 
        C_DIN[25], C_DIN[24], GND, C_DIN[23], C_DIN[22], C_DIN[21], 
        C_DIN[20], C_DIN[19], C_DIN[18], C_DIN[17], C_DIN[16]}), 
        .C_WEN(C_WEN), .C_BLK({C_BLK, VCC}), .A_EN(VCC), .A_ADDR_LAT(
        GND), .A_DOUT_LAT(VCC), .A_WIDTH({VCC, GND, GND}), .B_EN(VCC), 
        .B_ADDR_LAT(GND), .B_DOUT_LAT(VCC), .B_WIDTH({VCC, GND, GND}), 
        .C_EN(VCC), .C_WIDTH({VCC, GND, GND}), .SII_LOCK(GND));
    GND GND_power_inst1 (.Y(GND_power_net1));
    VCC VCC_power_inst1 (.Y(VCC_power_net1));
    
endmodule
