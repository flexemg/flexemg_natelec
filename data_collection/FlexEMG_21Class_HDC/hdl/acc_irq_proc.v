///////////////////////////////////////////////////////////////////////////////////////////////////
// Company: <Name>
//
// File: acc_irq_proc.v
// File history:
//      <Revision number>: <Date>: <Comments>
//      <Revision number>: <Date>: <Comments>
//      <Revision number>: <Date>: <Comments>
//
// Description: 
//
// <Description here>
//
// Targeted device: <Family::SmartFusion2> <Die::M2S060T> <Package::325 FCSBGA>
// Author: <Name>
//
/////////////////////////////////////////////////////////////////////////////////////////////////// 

//`timescale <time_units> / <precision>

module acc_irq_proc #(
    parameter DEBUG_BUS_SIZE = 4
  )
  (
	input wire clk, 
	input wire rstb,
 
    output reg mux_sel,

    input wire acc_irq,
    input wire irq_en,
    output reg irq_ok,

    input wire apb_req,
    output reg apb_grant,

    output wire scl,
    input wire  sda_i,
    output wire sda_o,

    output wire [47:0] acc_data,

    output wire fifo_overflow,

    output wire [DEBUG_BUS_SIZE-1:0] debug
);

localparam I2C_REG_SIZE = 500;
localparam SCL_VEC      = 500'b11100110011001100110011001100110011001100110011001100110011001100110011001100111110011001100110011001100110011001100110011001100110011001100110011001100110011001100110011001100110011001100110011001100110011001100110011001100110011001100110011001100110011001100110011001100110011001100110011001100110011001100110011001100110011001100110011111110011001100110011001100110011001100110011001100110011001100110011001100110011111001100110011001100110011001100110011001100110011001100110011001100110011001111;
localparam SDA_VEC      = 500'b10001111111100001111000000000000000011110000000011111111111100001111111111111111000111111110000111100000000000011111111111111111111111111111111111111110000111111111111111111111111111111110000111111111111111111111111111111110000111111111111111111111111111111110000111111111111111111111111111111110000111111111111111111111111111111111111000111000111111110000111100000000000000001111000000001111111111110000111100001111111100011111111000011110000000000001111111111111111111111111111111111111111111100011;

// Ack bits are ack field end position + 2
// See 14pt bold red numbers in in the IRQ Proc section of the ACC New Bit Indices tab of utilities.xlsx
localparam FIRST_ACK  = 462;
localparam SECOND_ACK = 426;
localparam THIRD_ACK  = 383;
localparam FOURTH_ACK = 122;
localparam FIFTH_ACK  = 86;
localparam SIXTH_ACK  = 43;

// Data base bits are data field end positions
// See 14pt bold black numbers in the IRQ Proc section of the ACC New Bit Indices tab of utilities.xlsx
localparam RD_DATA_BASE_X_H = 349;
localparam RD_DATA_BASE_X_L = 313;
localparam RD_DATA_BASE_Y_H = 277;
localparam RD_DATA_BASE_Y_L = 241;
localparam RD_DATA_BASE_Z_H = 205;
localparam RD_DATA_BASE_Z_L = 169;

localparam INT_STATUS_BITS_BASE = 9;

wire reg_en;
reg reg_ld;
reg acc_ld;

// SCL Register
reg [I2C_REG_SIZE-1:0] scl_reg;
assign scl = scl_reg[I2C_REG_SIZE-1];
always @ (posedge clk or negedge rstb) begin
    if (!rstb)
        scl_reg = ~0;
    else if (reg_en)
        scl_reg = {scl_reg[I2C_REG_SIZE-2:0], 1'b1};
    else if (reg_ld)
        scl_reg = SCL_VEC;
    else
        scl_reg = scl_reg;
end

// SDA_o  Register
reg [I2C_REG_SIZE-1:0] sda_o_reg;
assign sda_o = sda_o_reg[I2C_REG_SIZE-1];
always @ (posedge clk or negedge rstb) begin
    if (!rstb)
        sda_o_reg = ~0;
    else if (reg_en)
        sda_o_reg = {sda_o_reg[I2C_REG_SIZE-2:0], 1'b1};
    else if (reg_ld)
        sda_o_reg = SDA_VEC;
    else
        sda_o_reg = sda_o_reg;
end

// SDA_i  Register
reg [I2C_REG_SIZE-1:0] sda_i_reg;
always @ (posedge clk or negedge rstb) begin
    if (!rstb)
        sda_i_reg = 0;
    else if (reg_en)
        sda_i_reg = {sda_i_reg[I2C_REG_SIZE-2:0], sda_i};
    else
        sda_i_reg = sda_i_reg;
end

// ACK register
reg [5:0] ack_reg;
always @ (posedge clk or negedge rstb) begin
    if (!rstb)
        ack_reg = 0;
    else if (acc_ld)
        ack_reg = {sda_i_reg[FIRST_ACK], 
                   sda_i_reg[SECOND_ACK], 
                   sda_i_reg[THIRD_ACK], 
                   sda_i_reg[FOURTH_ACK], 
                   sda_i_reg[FIFTH_ACK], 
                   sda_i_reg[SIXTH_ACK]
        };
    else
        ack_reg = ack_reg;
end

// Interrupt status register
reg [31:0] int_status_bits;
always @ (posedge clk or negedge rstb) begin
    if (!rstb)
        int_status_bits = 0;
    else if (acc_ld)
        int_status_bits = sda_i_reg[INT_STATUS_BITS_BASE+31:INT_STATUS_BITS_BASE];
    else
        int_status_bits = int_status_bits;
end

wire data_rdy;
assign data_rdy = int_status_bits[1];
assign fifo_overflow = int_status_bits[17];

// Sample register
reg [191:0] sample_reg;
always @ (posedge clk or negedge rstb) begin
    if (!rstb)
        sample_reg = 0;
    else if (acc_ld)
        sample_reg = {sda_i_reg[RD_DATA_BASE_X_H+31:RD_DATA_BASE_X_H], 
                      sda_i_reg[RD_DATA_BASE_X_L+31:RD_DATA_BASE_X_L], 
                      sda_i_reg[RD_DATA_BASE_Y_H+31:RD_DATA_BASE_Y_H], 
                      sda_i_reg[RD_DATA_BASE_Y_L+31:RD_DATA_BASE_Y_L], 
                      sda_i_reg[RD_DATA_BASE_Z_H+31:RD_DATA_BASE_Z_H], 
                      sda_i_reg[RD_DATA_BASE_Z_L+31:RD_DATA_BASE_Z_L]
        };
    else
        sample_reg = sample_reg;
end

// Bit Counter
reg bc_en;
reg bc_rst;
reg [8:0] bc_cnt;
always @ (posedge clk or negedge rstb) begin
    if (!rstb || bc_rst)
        bc_cnt = 0;
    else if (bc_en)
        bc_cnt = bc_cnt + 1;
end

assign reg_en = bc_en;

// irq_ok reg
reg irq_ok_clr, irq_ok_set;
always @ (posedge clk or negedge rstb) begin
    if (!rstb || irq_ok_clr)
        irq_ok = 1'b0;
    else if (irq_ok_set)
        irq_ok = 1'b1;
end

////
//// FSM
////

localparam [2:0] // synopsys enum
    STATE_IDLE = 3'b000,    // 0
    STATE_LOAD = 3'b001,    // 1
    STATE_IRQ  = 3'b011,    // 3
    STATE_DONE = 3'b010,    // 2
    STATE_APB  = 3'b100;    // 4

reg [2:0] current_state, next_state;

always @ (posedge clk or negedge rstb) begin
    if (!rstb)
        current_state = STATE_IDLE;
    else
        current_state = next_state;
end

always @ (*) begin
    irq_ok_set = 1'b0;
    irq_ok_clr = 1'b0;
    bc_en = 1'b0;
    bc_rst = 1'b0;
    reg_ld = 1'b0;
    acc_ld = 1'b0;
    apb_grant = 1'b0;
    mux_sel = 1'b0;

    next_state = current_state;

    case (current_state)
        STATE_IDLE:
        begin
            bc_rst = 1'b1;
            irq_ok_set = (ack_reg == 6'b111111);
            if (acc_irq && irq_en && !apb_req)
                next_state = STATE_LOAD;
            else if (apb_req)
                next_state = STATE_APB;
        end

        STATE_LOAD:
        begin
            reg_ld = 1'b1;
            next_state = STATE_IRQ;
        end

        STATE_IRQ:
        begin
            bc_en = 1'b1;
            if (bc_cnt == I2C_REG_SIZE-1)
                next_state = STATE_DONE;
        end

        STATE_DONE:
        begin
            acc_ld = 1'b1;
            next_state = STATE_IDLE;
        end

        STATE_APB:
        begin
            apb_grant = 1'b1;
            mux_sel = 1'b1;
            if (!apb_req)
                next_state = STATE_IDLE;
        end

        default:
            next_state = STATE_IDLE;
    endcase

end

assign acc_data = { 
    sample_reg[190], 
    sample_reg[186], 
    sample_reg[182], 
    sample_reg[178], 
    sample_reg[174], 
    sample_reg[170], 
    sample_reg[166], 
    sample_reg[162],
    sample_reg[158], 
    sample_reg[154], 
    sample_reg[150], 
    sample_reg[146], 
    sample_reg[142], 
    sample_reg[138], 
    sample_reg[134], 
    sample_reg[130],
    sample_reg[126], 
    sample_reg[122], 
    sample_reg[118], 
    sample_reg[114], 
    sample_reg[110], 
    sample_reg[106], 
    sample_reg[102], 
    sample_reg[98],
    sample_reg[94], 
    sample_reg[90], 
    sample_reg[86], 
    sample_reg[82], 
    sample_reg[78], 
    sample_reg[74], 
    sample_reg[70], 
    sample_reg[66],
    sample_reg[62], 
    sample_reg[58], 
    sample_reg[54], 
    sample_reg[50], 
    sample_reg[46], 
    sample_reg[42], 
    sample_reg[38], 
    sample_reg[34],
    sample_reg[30], 
    sample_reg[26], 
    sample_reg[22], 
    sample_reg[18], 
    sample_reg[14], 
    sample_reg[10], 
    sample_reg[6], 
    sample_reg[2]
};

localparam ASSIGNED_DEBUG_BITS = 4;

assign debug = {{DEBUG_BUS_SIZE-ASSIGNED_DEBUG_BITS{1'b0}}, 
    data_rdy,       // 1
    current_state   // 3
};

endmodule

