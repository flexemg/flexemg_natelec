`timescale 1ns/100ps

module cm_tb;

localparam DEBUG_BUS_SIZE = 32;

wire          PCLK;	
wire          PRESETN;

// APB interface
wire          PENABLE;
wire          PSEL;
wire          PWRITE;
wire [15:0]   PADDR;
wire [31:0]   PWDATA;
wire          PREADY;
wire          PSLVERR;
wire [31:0]   PRDATA;

// NM interface
wire          N2C_DATA_0;
wire          N2C_DATA_1;
wire          C2N_DATA_0;
wire          C2N_DATA_1;
wire          C2N_VALID_0;
wire          C2N_VALID_1;

// Accelerometer interface
wire          ACC_CLK;	
wire          ACC_IRQ;
wire          I2C_SCL;
wire          I2C_SDA_I;
wire          I2C_SDA_O;
wire          ACC_FIFO_OVERFLOW;
    
// ADC PDMA channel interrupt
wire          PDMA_IRQ_REQ;
wire          PDMA_DATA_RDY; 

// cmam_if
cm_top cm_top_0 (
    .PCLK(PCLK),
    .ACC_CLK(ACC_CLK),
    .PRESETN(PRESETN),

    .PADDR(PADDR),
    .PENABLE(PENABLE),
    .PSEL(PSEL),
    .PWRITE(PWRITE),
    .PWDATA(PWDATA),
    .PRDATA(PRDATA),
    .PREADY(),
    .PSLVERR(),

    .N2C_DATA_0(N2C_DATA_0),
    .C2N_DATA_0(C2N_DATA_0),
    .C2N_VALID_0(C2N_VALID_0),

    .N2C_DATA_1(N2C_DATA_1),
    .C2N_DATA_1(C2N_DATA_1),
    .C2N_VALID_1(C2N_VALID_1),

    .ACK_RDY_IRQ_REQ(ACK_RDY_IRQ_REQ),
    .ACC_IRQ(ACC_IRQ),
    .FFT_IRQ_REQ(FFT_IRQ_REQ),
    .PDMA_DONE_IRQ_REQ(PDMA_DONE_IRQ_REQ),

    .PDMA_DATA_RDY(PDMA_DATA_RDY),

    .I2C_SDA_I(I2C_SDA_I),
    .I2C_SCL(I2C_SCL),
    .I2C_SDA_O(I2C_SDA_O),

    .acc_fifo_overflow(ACC_FIFO_OVERFLOW),

    .top_debug(),
    .DEBUG()
);

endmodule
