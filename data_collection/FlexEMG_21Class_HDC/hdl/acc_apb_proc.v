///////////////////////////////////////////////////////////////////////////////////////////////////
// Company: <Name>
//
// File: acc_apb_proc.v
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

module acc_apb_proc #(
    parameter DEBUG_BUS_SIZE = 4
  )
  (
	input wire clk, 
	input wire rstb,
 
	input wire [7:0] addr,		// register address
	input wire [7:0] data_wr,	// write data in
	input wire wren_latch,		// write enable (active high)
    output reg wren_clr,
	output wire [7:0] data_rd,	// read data out
	input wire rden_latch,
    output reg rden_clr,

    output reg apb_req,
    input wire apb_grant,

    output wire scl,
    input wire  sda_i,
    output wire sda_o,

    output reg rd_ok,
    output reg wr_ok,

    output wire [DEBUG_BUS_SIZE-1:0] debug
);

localparam I2C_REG_SIZE   = 160;

localparam WR_SCL_VEC = 160'b1110011001100110011001100110011001100110011001100110011001100110011001100110011001100110011001100110011001100110011111111111111111111111111111111111111111111111;
localparam WR_SDA_VEC = 160'b1000111111110000111100000000000000001111000000000000000000000000000000001111000000000000000000000000000000001111000111111111111111111111111111111111111111111111;

localparam RD_SCL_VEC = 160'b1110011001100110011001100110011001100110011001100110011001100110011001100110011111001100110011001100110011001100110011001100110011001100110011001100110011001111;
localparam RD_SDA_VEC = 160'b1000111111110000111100000000000000001111000000000000000000000000000000001111111100011111111000011110000000000001111111111111111111111111111111111111111111100011;

// Ack bits are ack field end position + 2
// See 14pt bold red numbers in the APB Proc read and write vector section of the ACC New Bit Indices tab of utilities.xlsx
localparam FIRST_ACK = 122;
localparam SECOND_ACK = 86;
localparam THIRD_ACK_RD = 43;
localparam THIRD_ACK_WR = 50;

// Data base is the data field end position
// See 14pt bold black number in the APB Proc read vector section of the ACC New Bit Indices tab of utilities.xlsx
localparam RD_DATA_BASE = 9;
           
wire reg_en;
reg reg_ld_rd;
reg reg_ld_wr;
reg rd_active;
reg wr_active;
reg result_ld;

// SCL Register
reg [I2C_REG_SIZE-1:0] scl_reg;
assign scl = scl_reg[I2C_REG_SIZE-1];
always @ (posedge clk or negedge rstb) begin
    if (!rstb)
        scl_reg = ~0;
    else if (reg_en)
        scl_reg = {scl_reg[I2C_REG_SIZE-2:0], 1'b1};
    else if (reg_ld_rd)
        scl_reg = RD_SCL_VEC;
    else if (reg_ld_wr)
        scl_reg = WR_SCL_VEC;
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
    else if (reg_ld_wr)
        sda_o_reg = {WR_SDA_VEC[I2C_REG_SIZE-1:120], 
                     addr[7],addr[7],addr[7],addr[7],
                     addr[6],addr[6],addr[6],addr[6],
                     addr[5],addr[5],addr[5],addr[5],
                     addr[4],addr[4],addr[4],addr[4],
                     addr[3],addr[3],addr[3],addr[3],
                     addr[2],addr[2],addr[2],addr[2],
                     addr[1],addr[1],addr[1],addr[1],
                     addr[0],addr[0],addr[0],addr[0],
                     WR_SDA_VEC[87:84],
                     data_wr[7],data_wr[7],data_wr[7],data_wr[7],
                     data_wr[6],data_wr[6],data_wr[6],data_wr[6],
                     data_wr[5],data_wr[5],data_wr[5],data_wr[5],
                     data_wr[4],data_wr[4],data_wr[4],data_wr[4],
                     data_wr[3],data_wr[3],data_wr[3],data_wr[3],
                     data_wr[2],data_wr[2],data_wr[2],data_wr[2],
                     data_wr[1],data_wr[1],data_wr[1],data_wr[1],
                     data_wr[0],data_wr[0],data_wr[0],data_wr[0],
                     WR_SDA_VEC[51:0]
                    };
    else if (reg_ld_rd)
        sda_o_reg = {RD_SDA_VEC[I2C_REG_SIZE-1:120], 
                     addr[7],addr[7],addr[7],addr[7],
                     addr[6],addr[6],addr[6],addr[6],
                     addr[5],addr[5],addr[5],addr[5],
                     addr[4],addr[4],addr[4],addr[4],
                     addr[3],addr[3],addr[3],addr[3],
                     addr[2],addr[2],addr[2],addr[2],
                     addr[1],addr[1],addr[1],addr[1],
                     addr[0],addr[0],addr[0],addr[0],
                     RD_SDA_VEC[87:0]
                    };
    else
        sda_o_reg = sda_o_reg;
end

// SDA_i Register
reg [I2C_REG_SIZE-1:0] sda_i_reg;
always @ (posedge clk or negedge rstb) begin
    if (!rstb || reg_ld_rd || reg_ld_wr)
        sda_i_reg = 0;
    else if (reg_en)
        sda_i_reg = {sda_i_reg[I2C_REG_SIZE-2:0], sda_i};
    else
        sda_i_reg = sda_i_reg;
end

// ACK register
reg [2:0] ack_reg;
always @ (posedge clk or negedge rstb) begin
    if (!rstb)
        ack_reg <= 12'd0;
    else if (result_ld && wr_active)
        ack_reg <= {sda_i_reg[FIRST_ACK], sda_i_reg[SECOND_ACK], sda_i_reg[THIRD_ACK_WR]};
    else if (result_ld && rd_active)
        ack_reg <= {sda_i_reg[FIRST_ACK], sda_i_reg[SECOND_ACK], sda_i_reg[THIRD_ACK_RD]};
    else
        ack_reg <= ack_reg;
end

// Read result register
reg [31:0] rd_result_reg;
always @ (posedge clk or negedge rstb) begin
    if (!rstb)
        rd_result_reg = 0;
    else if (result_ld)
        rd_result_reg = sda_i_reg[RD_DATA_BASE+31:RD_DATA_BASE];
    else
        rd_result_reg = rd_result_reg;
end

// wr_ok reg
reg wr_ok_clr, wr_ok_set;
always @ (posedge clk or negedge rstb) begin
    if (!rstb || wr_ok_clr)
        wr_ok = 1'b0;
    else if (wr_ok_set)
        wr_ok = 1'b1;
end

// rd_ok reg
reg rd_ok_clr, rd_ok_set;
always @ (posedge clk or negedge rstb) begin
    if (!rstb || rd_ok_clr)
        rd_ok = 1'b0;
    else if (rd_ok_set)
        rd_ok = 1'b1;
end

assign data_rd = { 
    rd_result_reg[30], 
    rd_result_reg[26], 
    rd_result_reg[22], 
    rd_result_reg[18], 
    rd_result_reg[14], 
    rd_result_reg[10], 
    rd_result_reg[6], 
    rd_result_reg[2]
};

// Bit Counter
reg bc_en;
reg bc_rst;
reg [7:0] bc_cnt;
always @ (posedge clk or negedge rstb) begin
    if (!rstb || bc_rst)
        bc_cnt = 6'd0;
    else if (bc_en)
        bc_cnt = bc_cnt + 1;
end

assign reg_en = bc_en;

//
// FSM
//

localparam [3:0] // synopsys enum
    STATE_IDLE        = 4'b0000,    // 0
    STATE_WR_LD       = 4'b0001,    // 1
    STATE_WR_EN       = 4'b0011,    // 3
    STATE_WR_DONE     = 4'b0111,    // 7
    STATE_WR_TEST_ACK = 4'b0110,    // 6
    STATE_RD_LD       = 4'b1000,    // 8
    STATE_RD_EN       = 4'b1001,    // 9
    STATE_RD_DONE     = 4'b1011,    // 11
    STATE_RD_TEST_ACK = 4'b1010;    // 10

reg [3:0] current_state, next_state;

always @ (posedge clk or negedge rstb) begin
    if (!rstb)
        current_state = STATE_IDLE;
    else
        current_state = next_state;
end

always @ (*) begin
    rden_clr = 1'b0;
    wren_clr = 1'b0;
    rd_ok_clr = 1'b0;
    rd_ok_set = 1'b0;
    wr_ok_clr = 1'b0;
    wr_ok_set = 1'b0;
    bc_rst = 1'b0;
    bc_en = 1'b0;
    reg_ld_rd = 1'b0;
    reg_ld_wr = 1'b0;
    result_ld = 1'b0;
    rd_active = 1'b0;
    wr_active = 1'b0;
    apb_req = 1'b0;

    next_state = current_state;

    case (current_state)
        STATE_IDLE:
        begin
            bc_rst = 1'b1;
            if (wren_latch)
                next_state = STATE_WR_LD;
            else if (rden_latch)
                next_state = STATE_RD_LD;
        end

        STATE_WR_LD:
        begin
            reg_ld_wr = 1'b1;
            wr_ok_clr = 1'b1;
            wren_clr = 1'b1;
            apb_req = 1'b1;
            if (apb_grant)
                next_state = STATE_WR_EN;
        end

        STATE_WR_EN:
        begin
            apb_req = 1'b1;
            bc_en = 1'b1;
            if (bc_cnt == I2C_REG_SIZE-1)
                next_state = STATE_WR_DONE;
        end

        STATE_WR_DONE:
        begin
            apb_req = 1'b1;
            wr_active = 1'b1;
            next_state = STATE_WR_TEST_ACK;
        end

        STATE_WR_TEST_ACK:
        begin
            apb_req = 1'b1;
            if (ack_reg == 3'd0)
                wr_ok_set = 1'b1;
            next_state = STATE_IDLE;
        end

        STATE_RD_LD:
        begin
            reg_ld_rd = 1'b1;
            rd_ok_clr = 1'b1;
            rden_clr = 1'b1;
            apb_req = 1'b1;
            if (apb_grant)
                next_state = STATE_RD_EN;
        end

        STATE_RD_EN:
        begin
            apb_req = 1'b1;
            bc_en = 1'b1;
            if (bc_cnt == I2C_REG_SIZE-1)
                next_state = STATE_RD_DONE;
        end

        STATE_RD_DONE:
        begin
            apb_req = 1'b1;
            rd_active = 1'b1;
            result_ld = 1'b1;
            next_state = STATE_RD_TEST_ACK;
        end

        STATE_RD_TEST_ACK:
        begin
            apb_req = 1'b1;
            if (ack_reg == 3'd0)
                rd_ok_set = 1'b1;
            next_state = STATE_IDLE;
        end

        default:
            next_state = STATE_IDLE;
    endcase

end

localparam ASSIGNED_DEBUG_BITS = 4;

assign debug = {{DEBUG_BUS_SIZE-ASSIGNED_DEBUG_BITS{1'b0}}, 
    current_state   // 4
};

endmodule
