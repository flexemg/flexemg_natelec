////////////////////////////////////////////////////////////////////////////////
// File: cm_if_apb.v
// Description: CM-level address decoder
//
// CORTERA NEUROTECHNOLOGIES INC. CONFIDENTIAL
// Unpublished Copyright (C) 2015 CORTERA NEUROTECHNOLOGIES INC.
// All rights reserved.
//
// NOTICE:  All information contained herein is the property of 
// CORTERA NEUROTECHNOLOGIES INC. The intellectual and technical concepts 
// contained herein are proprietary to CORTERA NEUROTECHNOLOGIES INC. and may
// be covered by U.S. and foreign patents, patents in process, and are protected
// by trade secret and/or copyright law.  Dissemination of this information or 
// reproduction of this material is strictly forbidden unless prior written 
// permission is obtained from CORTERA NEUROTECHNOLOGIES INC.
//
// The copyright notice above does not evidence any actual or intended publication
// or disclosure of this source code, which includes information that is confidential
// and/or proprietary, and is a trade secret, of CORTERA NEUROTECHNOLOGIES INC.   
// ANY REPRODUCTION, MODIFICATION, DISTRIBUTION, PUBLIC  PERFORMANCE, 
// OR PUBLIC DISPLAY OF OR THROUGH USE OF THIS SOURCE CODE WITHOUT 
// THE EXPRESS WRITTEN CONSENT OF CORTERA NEUROTECHNOLOGIES INC. IS STRICTLY PROHIBITED, AND 
// IN VIOLATION OF APPLICABLE LAWS AND INTERNATIONAL TREATIES.  THE 
// RECEIPT OR POSSESSION OF THIS SOURCE CODE AND/OR RELATED INFORMATION
// DOES NOT CONVEY OR IMPLY ANY RIGHTS TO REPRODUCE, DISCLOSE OR DISTRIBUTE
// ITS CONTENTS, OR TO MANUFACTURE, USE, OR SELL ANYTHING THAT IT MAY 
// DESCRIBE, IN WHOLE OR IN PART.                
//////////////////////////////////////////////////////////////////////////////////
//`timescale <time_units> / <precision>

module cm_if_apb #(
    parameter DEBUG_BUS_SIZE = 4
  )
  (
    input wire          PCLK,	
    input wire          PRESETN,

    // APB interface
    input wire          PENABLE,
    input wire          PSEL,
    input wire          PWRITE,
  	input wire [15:0]   PADDR,
  	input wire [31:0]   PWDATA,
  	output wire         PREADY,
    output wire         PSLVERR,
  	output reg [31:0]   PRDATA,

    // Generated enables
  	output wire         rd_enable,
  	output wire         wr_enable,

    // PRDATA mux inputs
  	input wire [31:0]   nmif_PRDATA,
  	input wire [31:0]   acc_PRDATA,

    // Exported address & data
    output wire [15:0]  apb_addr,
    output wire [31:0]  apb_data_wr,

    // Sub-block enables
  	output reg          pdma_en,
  	output reg          artifact_en,
  	output reg          fft_en,
  	output reg          acc_irq_en,

    output reg [11:0]   fft_channel,

    // Debug only

    output reg [4:0]    debug_sel,

    // Emulation block enables
    output reg          emulate_pdma,
    output reg          emulate_nm_1,
    output reg          emulate_nm_0,
    output reg          emulate_acc,

    // NM emulation block stim injection (sim/emulation only)
    output wire         nm1_stim_ld,
    output wire         nm0_stim_ld, 
    output reg [2:0]    nm1_num_stims,
    output reg [2:0]    nm0_num_stims, 

    output reg [15:0] mode_dbg,
    output wire [DEBUG_BUS_SIZE-1:0] debug
);

assign PREADY = 1'b1; 
assign PSLVERR = 1'b0;      

assign apb_addr = PADDR;
assign apb_data_wr = PWDATA;

reg scope_trigger;

assign wr_enable = (PENABLE &&  PWRITE && PSEL);
assign rd_enable = (!PENABLE && !PWRITE && PSEL);

//// System address map (base addr 0x30000000)
//
// -addr-   ------------- function ---------------- --direction-- --tested in--
// 0x0000   HDL command word                        write         nm_if_apb.v and here (for scope trigger debug signal)
// 0x0004   reset valid, reset data                 write         nm_if_apb.v
// 0x0008   debug select                            write         here
// 0x000c   mode word                               write         here
// 0x00n0   NMn D1 Tx data                          write         nm_if_apb.v
// 0x00n4   NMn D2 Tx data                          write         nm_if_apb.v
// 0x00n8   NMn ADC vector lo                       write         nm_if_apb.v
// 0x00nC   NMn ADC vector hi                       write         nm_if_apb.v
// 0x01n0   NMn stim frame count                    write         here          debug only, does not affect normal operation
// 0x0034   output label                          	write
// 0x0038   output distance                         write

// 0x0000   HDL status word                         read          nm_if_apb.v
// 0x0004   reset readback                          read          nm_if_apb.v
// 0x0008   ADC data via PDMA                       read          nm_if_apb.v     disabled if pdma_en is high
// 0x000c   mode word                               read          here
// 0x00n0   NMn D1 Tx data readback                 read          nm_if_apb.v
// 0x00n4   NMn D2 Tx data readback                 read          nm_if_apb.v
// 0x00n8   NMn ACK data                            read          nm_if_apb.v
// 0x00nC   NMn ADC FFT data                        read          nm_if_apb.v
// 0x0030   gesture mode and label                  read
// 0x1000   Accelerometer status                    read          acc_if.v 
// 0x1010   Latest accelerometer X data sample      read          acc_if.v      debug only, does not affect normal operation
// 0x1020   Latest accelerometer Y data sample      read          acc_if.v      debug only, does not affect normal operation
// 0x1030   Latest accelerometer Z data sample      read          acc_if.v      debug only, does not affect normal operation

// 0x1xx0   Accelerometer register read/write       read/write    here, acc_if.v and acc_apb_proc.v

//
// Top level write address decoder
//

assign nm0_stim_ld = (PADDR == 16'h0100) && wr_enable;
assign nm1_stim_ld = (PADDR == 16'h0110) && wr_enable;

always @(posedge PCLK or negedge PRESETN) begin
    if (!PRESETN) begin
        debug_sel     <= 0;
        pdma_en       <= 0;
        acc_irq_en    <= 0;
        artifact_en   <= 0;
        fft_en        <= 0;
        emulate_acc   <= 0;
        emulate_nm_0  <= 0;
        emulate_nm_1  <= 0;
        emulate_pdma  <= 0;
        fft_channel   <= 0;
        scope_trigger <= 0;  // sim/emulation only
        nm0_num_stims <= 0;  // sim/emulation only
        nm1_num_stims <= 0;  // sim/emulation only
        mode_dbg      <= 0;  // debug only

    end

    else if (wr_enable) begin
        case (PADDR)
            16'h0000:
                scope_trigger <= PWDATA[16];

            16'h0008:
                // debug output source selection
                debug_sel <= PWDATA[4:0];

           	16'h000C:
            begin
                pdma_en       <= PWDATA[0];     // enable PDMA block in cm_if (disables PDMA channel read from MSS)
                acc_irq_en    <= PWDATA[1];     // enable accelerometer IRQ (normal or emulated mode)
                artifact_en   <= PWDATA[2];     // enable artifact cancellation in the ADC stream
                fft_en        <= PWDATA[3];     // enable FFT in NM channel blocks
                emulate_acc   <= PWDATA[4];     // enable accelerometer emulator in HDL (sim/emulation only)
                emulate_nm_0  <= PWDATA[5];     // enable NM0 emulator in HDL (sim/emulation only)
                emulate_nm_1  <= PWDATA[6];     // enable NM1 emulator in HDL (sim/emulation only)
                emulate_pdma  <= PWDATA[7];     // enable PDMA data ready to fifo pop loopback (simulation only)
                fft_channel   <= PWDATA[27:16]; // channel on which to perform FFTs (NM1: 27:22, NM1: 21:16)
                mode_dbg      <= {PWDATA[27:16],PWDATA[3:0]};
            end

            16'h0100:
                nm0_num_stims <= PWDATA[2:0];

            16'h0110:
                nm1_num_stims <= PWDATA[2:0];

        endcase
    end
end

//
// Top level read address decoder
// Defaults to PDMA channel
//

always @ (*) begin
    if (PADDR[15:12] == 4'h1)
        PRDATA = acc_PRDATA;
    else if (PADDR == 16'h000c) begin
        PRDATA[0] = pdma_en; 
        PRDATA[1] = acc_irq_en; 
        PRDATA[2] = artifact_en;
        PRDATA[3] = fft_en;
        PRDATA[4] = emulate_acc;
        PRDATA[5] = emulate_nm_0;
        PRDATA[6] = emulate_nm_1;
        PRDATA[7] = emulate_pdma;
        PRDATA[15:8] = 0;
        PRDATA[27:16] = fft_channel;
        PRDATA[31:28] = 0;
    end else
        PRDATA = nmif_PRDATA;
end

localparam ASSIGNED_DEBUG_BITS = 3;

assign debug = {{DEBUG_BUS_SIZE-ASSIGNED_DEBUG_BITS{1'b0}}, 
    nm0_stim_ld,    // 1
    wr_enable,      // 1
    rd_enable,      // 1
    scope_trigger   // 1
};

endmodule


