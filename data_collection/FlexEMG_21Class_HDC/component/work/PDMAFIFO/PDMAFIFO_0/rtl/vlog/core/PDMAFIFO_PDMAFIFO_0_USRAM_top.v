`timescale 1 ns/100 ps
// Version: v11.7 SP3 11.7.3.7


module PDMAFIFO_PDMAFIFO_0_USRAM_top(
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
output [7:0] A_DOUT;
output [7:0] B_DOUT;
input  [15:0] C_DIN;
input  [7:0] A_ADDR;
input  [7:0] B_ADDR;
input  [6:0] C_ADDR;
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
    
    RAM64x18 PDMAFIFO_PDMAFIFO_0_USRAM_top_R0C0 (.A_DOUT({nc0, nc1, 
        nc2, nc3, nc4, nc5, nc6, nc7, nc8, nc9, nc10, nc11, nc12, nc13, 
        A_DOUT[3], A_DOUT[2], A_DOUT[1], A_DOUT[0]}), .B_DOUT({nc14, 
        nc15, nc16, nc17, nc18, nc19, nc20, nc21, nc22, nc23, nc24, 
        nc25, nc26, nc27, B_DOUT[3], B_DOUT[2], B_DOUT[1], B_DOUT[0]}), 
        .BUSY(), .A_ADDR_CLK(CLK), .A_DOUT_CLK(VCC), .A_ADDR_SRST_N(
        A_ADDR_SRST_N), .A_DOUT_SRST_N(VCC), .A_ADDR_ARST_N(
        A_ADDR_ARST_N), .A_DOUT_ARST_N(VCC), .A_ADDR_EN(A_ADDR_EN), 
        .A_DOUT_EN(VCC), .A_BLK({A_BLK, VCC}), .A_ADDR({A_ADDR[7], 
        A_ADDR[6], A_ADDR[5], A_ADDR[4], A_ADDR[3], A_ADDR[2], 
        A_ADDR[1], A_ADDR[0], GND, GND}), .B_ADDR_CLK(CLK), 
        .B_DOUT_CLK(VCC), .B_ADDR_SRST_N(B_ADDR_SRST_N), 
        .B_DOUT_SRST_N(VCC), .B_ADDR_ARST_N(B_ADDR_ARST_N), 
        .B_DOUT_ARST_N(VCC), .B_ADDR_EN(B_ADDR_EN), .B_DOUT_EN(VCC), 
        .B_BLK({B_BLK, VCC}), .B_ADDR({B_ADDR[7], B_ADDR[6], B_ADDR[5], 
        B_ADDR[4], B_ADDR[3], B_ADDR[2], B_ADDR[1], B_ADDR[0], GND, 
        GND}), .C_CLK(CLK), .C_ADDR({C_ADDR[6], C_ADDR[5], C_ADDR[4], 
        C_ADDR[3], C_ADDR[2], C_ADDR[1], C_ADDR[0], GND, GND, GND}), 
        .C_DIN({GND, GND, GND, GND, GND, GND, GND, GND, GND, GND, 
        C_DIN[11], C_DIN[10], C_DIN[9], C_DIN[8], C_DIN[3], C_DIN[2], 
        C_DIN[1], C_DIN[0]}), .C_WEN(C_WEN), .C_BLK({C_BLK, VCC}), 
        .A_EN(VCC), .A_ADDR_LAT(GND), .A_DOUT_LAT(VCC), .A_WIDTH({GND, 
        VCC, GND}), .B_EN(VCC), .B_ADDR_LAT(GND), .B_DOUT_LAT(VCC), 
        .B_WIDTH({GND, VCC, GND}), .C_EN(VCC), .C_WIDTH({GND, VCC, VCC})
        , .SII_LOCK(GND));
    RAM64x18 PDMAFIFO_PDMAFIFO_0_USRAM_top_R0C1 (.A_DOUT({nc28, nc29, 
        nc30, nc31, nc32, nc33, nc34, nc35, nc36, nc37, nc38, nc39, 
        nc40, nc41, A_DOUT[7], A_DOUT[6], A_DOUT[5], A_DOUT[4]}), 
        .B_DOUT({nc42, nc43, nc44, nc45, nc46, nc47, nc48, nc49, nc50, 
        nc51, nc52, nc53, nc54, nc55, B_DOUT[7], B_DOUT[6], B_DOUT[5], 
        B_DOUT[4]}), .BUSY(), .A_ADDR_CLK(CLK), .A_DOUT_CLK(VCC), 
        .A_ADDR_SRST_N(A_ADDR_SRST_N), .A_DOUT_SRST_N(VCC), 
        .A_ADDR_ARST_N(A_ADDR_ARST_N), .A_DOUT_ARST_N(VCC), .A_ADDR_EN(
        A_ADDR_EN), .A_DOUT_EN(VCC), .A_BLK({A_BLK, VCC}), .A_ADDR({
        A_ADDR[7], A_ADDR[6], A_ADDR[5], A_ADDR[4], A_ADDR[3], 
        A_ADDR[2], A_ADDR[1], A_ADDR[0], GND, GND}), .B_ADDR_CLK(CLK), 
        .B_DOUT_CLK(VCC), .B_ADDR_SRST_N(B_ADDR_SRST_N), 
        .B_DOUT_SRST_N(VCC), .B_ADDR_ARST_N(B_ADDR_ARST_N), 
        .B_DOUT_ARST_N(VCC), .B_ADDR_EN(B_ADDR_EN), .B_DOUT_EN(VCC), 
        .B_BLK({B_BLK, VCC}), .B_ADDR({B_ADDR[7], B_ADDR[6], B_ADDR[5], 
        B_ADDR[4], B_ADDR[3], B_ADDR[2], B_ADDR[1], B_ADDR[0], GND, 
        GND}), .C_CLK(CLK), .C_ADDR({C_ADDR[6], C_ADDR[5], C_ADDR[4], 
        C_ADDR[3], C_ADDR[2], C_ADDR[1], C_ADDR[0], GND, GND, GND}), 
        .C_DIN({GND, GND, GND, GND, GND, GND, GND, GND, GND, GND, 
        C_DIN[15], C_DIN[14], C_DIN[13], C_DIN[12], C_DIN[7], C_DIN[6], 
        C_DIN[5], C_DIN[4]}), .C_WEN(C_WEN), .C_BLK({C_BLK, VCC}), 
        .A_EN(VCC), .A_ADDR_LAT(GND), .A_DOUT_LAT(VCC), .A_WIDTH({GND, 
        VCC, GND}), .B_EN(VCC), .B_ADDR_LAT(GND), .B_DOUT_LAT(VCC), 
        .B_WIDTH({GND, VCC, GND}), .C_EN(VCC), .C_WIDTH({GND, VCC, VCC})
        , .SII_LOCK(GND));
    GND GND_power_inst1 (.Y(GND_power_net1));
    VCC VCC_power_inst1 (.Y(VCC_power_net1));
    
endmodule
