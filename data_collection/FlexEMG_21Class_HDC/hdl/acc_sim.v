///////////////////////////////////////////////////////////////////////////////////////////////////
// Company: <Name>
//
// File: acc_sim.v
// File history:
//      <Revision number>: <Date>: <Comments>
//      <Revision number>: <Date>: <Comments>
//      <Revision number>: <Date>: <Comments>
//
// Description: Simulation of the I2C interface of the MPU6050
//
// <Description here>
//
// Targeted device: <Family::SmartFusion2> <Die::M2S060T> <Package::325 FCSBGA>
// Author: <Name>
//
/////////////////////////////////////////////////////////////////////////////////////////////////// 

//`timescale <time_units> / <precision>

module acc_sim (
    input wire aclk,
    input wire rstb,

    input wire run,

    input wire scl,
    input wire sda_o,
    output wire sda_i,

    output wire irq
);

localparam SDA_REG_SIZE       = 252;
localparam SDA_I_HDR_VEC      = 252'b111111111111111111111111111111110000111111111111111111111111111111110000111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
localparam SDA_I_WR_DATA_VEC  = 252'b111111111111111111111111111000011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
localparam SDA_I_RD_DATA_VEC  = 252'b111111111111111111111111111111110000000000000000111100000000111100001111000000001111111100001111000000001111000011110000111100001111111100001111000011111111111111110000000000001111111100000000111111110000111100001111111100001111111111111111000000001111;
                                    
// SDA Register
reg reg_en;
reg reg_ld_hdr;
reg reg_ld_wr_data;
reg reg_ld_rd_data;
reg [SDA_REG_SIZE-1:0] sda_reg;
assign sda_i = sda_reg[SDA_REG_SIZE-1];
always @ (posedge aclk or negedge rstb) begin
    if (!rstb)
        sda_reg = 0;
    else if (reg_en)
        sda_reg = {sda_reg[SDA_REG_SIZE-2:0], 1'b1};    // shift left by 1
    else if (reg_ld_hdr)
        sda_reg = {SDA_I_HDR_VEC};
    else if (reg_ld_wr_data)
        sda_reg = {SDA_I_WR_DATA_VEC};
    else if (reg_ld_rd_data)
        sda_reg = SDA_I_RD_DATA_VEC;
    else
        sda_reg = sda_reg;
end

// IRQ generator
// Assert irq every 1ms
// Initial delay is 10us
reg [9:0] irq_cnt;
always @ (posedge aclk or negedge rstb) begin
    if (!rstb || !run)
        irq_cnt = 10'd990;
    else if (irq_cnt >= 10'd1000)
        irq_cnt = 10'd1;
    else
        irq_cnt = irq_cnt + 1;
end
assign irq = (irq_cnt == 10'd999);

// bit counter
reg bc_en;
reg bc_rst;
reg [6:0] bc_cnt;
always @ (posedge aclk or negedge rstb) begin
    if (!rstb || bc_rst)
        bc_cnt = 0;
    else if (bc_en)
        bc_cnt = bc_cnt + 1;
    else
        bc_cnt = bc_cnt;
end

// FSM state encoding
localparam IDLE        = 5'd0;
localparam S_DETECT_1  = 5'd1; 
localparam SKIP_BIT_3  = 5'd16;
localparam HDR_SETUP   = 5'd2;
localparam HDR_RUN     = 5'd3;
localparam S_DELAY     = 5'd4;
localparam S_DETECT_2  = 5'd5;
localparam SKIP_BIT_1  = 5'd14;
localparam SKIP_BIT_2  = 5'd15;
localparam RD_SETUP_1  = 5'd6;
localparam RD_SETUP_2  = 5'd7;
localparam RD_SETUP_3  = 5'd8;
localparam RD_RUN      = 5'd9;
localparam RD_NEXT     = 5'd13;
localparam ACK_OR_NACK = 5'd10;
localparam WR_SETUP    = 5'd11;
localparam WR_RUN      = 5'd12;

// FSM state registers
reg [4:0] current_state, next_state;
always @ (posedge aclk or negedge rstb) begin
    if (!rstb || !run)
        current_state = 0;
    else
        current_state = next_state;
end

// FSM logic
always @ (*) begin
    reg_en = 1'b0;
    reg_ld_hdr = 1'b0;
    reg_ld_wr_data = 1'b0;
    reg_ld_rd_data = 1'b0;
    bc_en = 1'b0;
    bc_rst = 1'b0;
    next_state = current_state;

    case (current_state)
        IDLE:
            if (scl && sda_o)
                next_state = S_DETECT_1;

        S_DETECT_1:
            if (scl && !sda_o)
                next_state = SKIP_BIT_3;

        SKIP_BIT_3:
            next_state = HDR_SETUP;

        HDR_SETUP:
        begin
            bc_rst = 1'b1;
            reg_ld_hdr = 1'b1;
            next_state = HDR_RUN;
        end

        HDR_RUN:
        begin
            reg_en = 1'b1;
            bc_en = 1'b1;
            if (bc_cnt == 72) begin
                bc_rst = 1'b1;
                next_state = S_DELAY;
            end
        end

        S_DELAY:
        begin
            bc_en = 1'b1;
            if (bc_cnt == 1)
                next_state = S_DETECT_2;
        end

        S_DETECT_2:
            if (scl)
                next_state = SKIP_BIT_1;
            else
                next_state = WR_SETUP;

        SKIP_BIT_1:
            next_state = SKIP_BIT_2;

        SKIP_BIT_2:
            next_state = RD_SETUP_1;

        RD_SETUP_1:
        begin
            bc_rst = 1'b1;
            reg_ld_rd_data = 1'b1;
            next_state = RD_SETUP_2;
        end

        RD_SETUP_2:
        begin
            bc_en = 1'b1;
            reg_en = 1'b1;
            if (bc_cnt == 32)
                next_state = RD_SETUP_3;
        end

        RD_SETUP_3:
        begin
            bc_rst = 1'b1;
            reg_en = 1'b1;
            next_state = RD_RUN;
        end

        RD_RUN:
        begin
            bc_en = 1'b1;
            reg_en = 1'b1;
            if (bc_cnt == 36)
                next_state = ACK_OR_NACK;
        end

        ACK_OR_NACK:
        begin
            reg_en = 1'b1;
            if (!scl && !sda_o) begin
                bc_rst = 1'b1;
                next_state = RD_RUN;
            end else 
                next_state = IDLE;
        end

        RD_NEXT:
        begin
            reg_en = 1'b1;
            bc_rst = 1'b1;
            next_state = RD_RUN;
        end

        WR_SETUP:
        begin
            bc_rst = 1'b1;
            reg_ld_wr_data = 1'b1;
            next_state = WR_RUN;
        end

        WR_RUN:
        begin
            bc_en = 1'b1;
            reg_en = 1'b1;
            if (bc_cnt == 35)
                next_state = IDLE;
        end

        default:
            next_state = IDLE;
    endcase
end

endmodule

