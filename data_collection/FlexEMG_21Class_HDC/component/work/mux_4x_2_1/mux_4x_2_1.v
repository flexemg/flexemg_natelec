//////////////////////////////////////////////////////////////////////
// Created by SmartDesign Fri Feb 03 07:54:58 2017
// Version: v11.7 SP3 11.7.3.7
//////////////////////////////////////////////////////////////////////

`timescale 1ns / 100ps

// mux_4x_2_1
module mux_4x_2_1(
    // Inputs
    A1,
    A2,
    A3,
    A4,
    B1,
    B2,
    B3,
    B4,
    sel,
    // Outputs
    Y1,
    Y2,
    Y3,
    Y4
);

//--------------------------------------------------------------------
// Input
//--------------------------------------------------------------------
input  A1;
input  A2;
input  A3;
input  A4;
input  B1;
input  B2;
input  B3;
input  B4;
input  sel;
//--------------------------------------------------------------------
// Output
//--------------------------------------------------------------------
output Y1;
output Y2;
output Y3;
output Y4;
//--------------------------------------------------------------------
// Nets
//--------------------------------------------------------------------
wire   A1;
wire   A2;
wire   A3;
wire   A4;
wire   B1;
wire   B2;
wire   B3;
wire   B4;
wire   sel;
wire   Y1_net_0;
wire   Y2_net_0;
wire   Y3_net_0;
wire   Y4_net_0;
wire   Y1_net_1;
wire   Y2_net_1;
wire   Y3_net_1;
wire   Y4_net_1;
//--------------------------------------------------------------------
// Top level output port assignments
//--------------------------------------------------------------------
assign Y1_net_1 = Y1_net_0;
assign Y1       = Y1_net_1;
assign Y2_net_1 = Y2_net_0;
assign Y2       = Y2_net_1;
assign Y3_net_1 = Y3_net_0;
assign Y3       = Y3_net_1;
assign Y4_net_1 = Y4_net_0;
assign Y4       = Y4_net_1;
//--------------------------------------------------------------------
// Component instances
//--------------------------------------------------------------------
//--------MX2
MX2 MX2_0(
        // Inputs
        .A ( A1 ),
        .B ( B1 ),
        .S ( sel ),
        // Outputs
        .Y ( Y1_net_0 ) 
        );

//--------MX2
MX2 MX2_1(
        // Inputs
        .A ( A2 ),
        .B ( B2 ),
        .S ( sel ),
        // Outputs
        .Y ( Y2_net_0 ) 
        );

//--------MX2
MX2 MX2_2(
        // Inputs
        .A ( A3 ),
        .B ( B3 ),
        .S ( sel ),
        // Outputs
        .Y ( Y3_net_0 ) 
        );

//--------MX2
MX2 MX2_3(
        // Inputs
        .A ( A4 ),
        .B ( B4 ),
        .S ( sel ),
        // Outputs
        .Y ( Y4_net_0 ) 
        );


endmodule
