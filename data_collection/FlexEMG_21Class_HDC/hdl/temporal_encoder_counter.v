`include "const.vh"

module temporal_encoder_counter
(
    // global ports
    input Clk_CI, Reset_RI,

    // handshaking
    input ValidIn_SI, ReadyIn_SI,
    output reg ReadyOut_SO, ValidOut_SO,

    // inputs
    input [`MODE_WIDTH-1:0] ModeIn_SI, 
    input [`LABEL_WIDTH-1:0] LabelIn_DI, 
    input [0:`HV_DIMENSION-1] HypervectorIn_DI,

    output [`MODE_WIDTH-1:0] ModeOut_SO,
    output [`LABEL_WIDTH-1:0] LabelOut_DO,
    output [0:`HV_DIMENSION-1] HypervectorOut_DO
);

// FSM state definitions
localparam IDLE = 2'd0;
localparam FORWARD_TRAINING = 2'd1;
localparam ACCEPT_INPUT = 2'd2;
localparam FORWARD_QUERY = 2'd3;

// NGRAM fill counter width
localparam FILL_NGRAM_COUNTER_WIDTH = `ceilLog2(`NGRAM_SIZE);

// input buffers
reg [1:0] ModeIn_SP;
wire [1:0] ModeIn_SN;
reg [`LABEL_WIDTH-1:0] LabelIn_DP;
wire [`LABEL_WIDTH-1:0] LabelIn_DN;

// ngram data registers
reg [0:`HV_DIMENSION-1] NGram_DP [1:`NGRAM_SIZE-1]; 
wire [0:`HV_DIMENSION-1] NGram_DN [1:`NGRAM_SIZE-1];

// fsm control registers
reg [1:0] prev_state, next_state;
reg [FILL_NGRAM_COUNTER_WIDTH-1 : 0] FillNGramCntr_SP;
wire [FILL_NGRAM_COUNTER_WIDTH-1 : 0] FillNGramCntr_SN;
reg NGramFullMemory_SP;
wire NGramFullMemory_SN;

// data path signals
reg [0:`HV_DIMENSION-1] BindNGramOut_D, result;
// status signals
wire ModeChange_S, LabelChange_S, NGramFull_S, BundleCounterFed_S;
// control signals
reg InputBuffersEN_S, NGramEN_S, BundleCounterEN_S, FirstHypervector_S, FillNGramCntrEN_S, FillNGramCntrCLR_S, NGramFullMemoryEN_S;


integer i;
genvar y;

// input signals
assign ModeIn_SN  = ModeIn_SI;
assign LabelIn_DN = LabelIn_DI;

// NGram permutation
assign NGram_DN[1] = {HypervectorIn_DI[`HV_DIMENSION-1], HypervectorIn_DI[0:`HV_DIMENSION-2]};
generate 
    for (y=2; y<`NGRAM_SIZE; y=y+1) begin
        assign NGram_DN[y] = {NGram_DP[y-1][`HV_DIMENSION-1], NGram_DP[y-1][0:`HV_DIMENSION-2]};
    end
endgenerate

// NGram binding
always @ (*) begin
    result = HypervectorIn_DI;
    for (i=1; i<`NGRAM_SIZE; i=i+1) begin
        result = result ^ NGram_DP[i];
    end
    BindNGramOut_D = result;
end

// NGram bundling
bundle_counter TemporalAccum(
    .Clk_CI                 (Clk_CI),
    .Reset_RI               (Reset_RI),
    .Enable_SI              (BundleCounterEN_S),
    .FirstHypervector_SI    (FirstHypervector_S),
    .HypervectorIn_DI       (BindNGramOut_D),
    .HypervectorOut_DO      (HypervectorOut_DO)
);

// output signals
assign ModeOut_SO  = ModeIn_SP;
assign LabelOut_DO = LabelIn_DP;

// CONTROLLER

// label comparison
assign ModeChange_S  = (ModeIn_SI != ModeIn_SP) ? 1'b1 : 1'b0;
assign LabelChange_S = (LabelIn_DI != LabelIn_DP) ? 1'b1 : 1'b0;

// NGram filling counter
assign NGramFull_S = (FillNGramCntr_SP == {FILL_NGRAM_COUNTER_WIDTH{1'b0}}) ? 1'b1 : 1'b0;
assign FillNGramCntr_SN = FillNGramCntr_SP - 1;

// Full NGram memory
assign BundleCounterFed_S = ((NGramFull_S == 1'b1) && (NGramFullMemory_SP == 1'b0)) ? 1'b0 : 1'b1;
assign NGramFullMemory_SN = NGramFull_S;

//FSM
always @ (*) begin
    next_state = IDLE;

    ReadyOut_SO = 1'b0;
    ValidOut_SO = 1'b0;

    InputBuffersEN_S = 1'b0;
    NGramEN_S = 1'b0;
    BundleCounterEN_S = 1'b0;
    FirstHypervector_S = 1'b0;
    FillNGramCntrEN_S = 1'b0;
    FillNGramCntrCLR_S = 1'b0;
    NGramFullMemoryEN_S = 1'b0;

    case(prev_state)
        IDLE: begin
            if (ValidIn_SI == 1'b0) begin
                next_state = IDLE;
                ReadyOut_SO = 1'b1;
            end else begin
                if ((ModeIn_SI == `MODE_TRAIN) || (ModeIn_SI == `MODE_UPDATE)) begin
                    if (ModeChange_S == 1'b0) begin
                        if (LabelChange_S == 1'b0) begin
                          next_state             = IDLE;
                          ReadyOut_SO            = 1'b1;
                          InputBuffersEN_S       = 1'b1;
                          NGramEN_S              = 1'b1;
                          NGramFullMemoryEN_S    = 1'b1;

                          BundleCounterEN_S      = (NGramFull_S == 1'b1) ? 1'b1 : 1'b0;
                          FirstHypervector_S     = ((NGramFull_S == 1'b1) && (BundleCounterFed_S == 1'b0)) ? 1'b1 : 1'b0;
                          FillNGramCntrEN_S      = (NGramFull_S == 1'b0) ? 1'b1 : 1'b0;
                        end else begin
                          next_state         = (ReadyIn_SI == 1'b0) ? FORWARD_TRAINING : ACCEPT_INPUT;
                          ValidOut_SO        = 1'b1;
                          FillNGramCntrCLR_S = 1'b1;
                        end
                    end else begin
                        next_state          = IDLE;
                        ReadyOut_SO         = 1'b1;
                        InputBuffersEN_S    = 1'b1;
                        NGramEN_S           = 1'b1;
                        FillNGramCntrEN_S   = 1'b1;
                        NGramFullMemoryEN_S = 1'b1;
                    end
                end else begin
                    if (ModeChange_S == 1'b0) begin
                        next_state             = FORWARD_QUERY;
                        ReadyOut_SO            = 1'b1;
                        InputBuffersEN_S       = 1'b1;
                        NGramEN_S              = 1'b1;
                        BundleCounterEN_S      = 1'b1;
                        FirstHypervector_S    = 1'b1;
                    end else begin
                        next_state         = (ReadyIn_SI == 1'b0) ? IDLE : FORWARD_QUERY;
                        ValidOut_SO        = 1'b1;
                        if (ReadyIn_SI == 1'b1) begin
                            ReadyOut_SO        = 1'b1;
                            InputBuffersEN_S   = 1'b1;
                            NGramEN_S          = 1'b1;
                            BundleCounterEN_S  = 1'b1;
                            FirstHypervector_S = 1'b1;
                            FillNGramCntrCLR_S = 1'b1;
                        end
                    end
                end
            end
        end

        FORWARD_TRAINING: begin
            next_state = (ReadyIn_SI == 1'b0) ? FORWARD_TRAINING : IDLE;
            ValidOut_SO = 1'b1;
            if (ReadyIn_SI == 1'b1) begin
                ReadyOut_SO            = 1'b1;
                InputBuffersEN_S       = 1'b1;
                NGramEN_S              = 1'b1;
                FillNGramCntrEN_S      = 1'b1;
                NGramFullMemoryEN_S    = 1'b1; 
            end
        end

        ACCEPT_INPUT: begin
            next_state             = IDLE;
            ReadyOut_SO            = 1'b1;
            InputBuffersEN_S       = 1'b1;
            NGramEN_S              = 1'b1;
            FillNGramCntrEN_S      = 1'b1;
            NGramFullMemoryEN_S    = 1'b1;
        end

        FORWARD_QUERY: begin
            next_state      = (ReadyIn_SI == 1'b0) ? FORWARD_QUERY : IDLE;
            ValidOut_SO = 1'b1;
        end
        default: ;
    endcase
end

// input buffers
always @ (posedge Clk_CI) begin
    if (Reset_RI == 1'b1) begin
        ModeIn_SP  <= `MODE_PREDICT;
        LabelIn_DP <= {`LABEL_WIDTH{1'b0}};
    end else if (InputBuffersEN_S == 1'b1) begin
        ModeIn_SP  <= ModeIn_SN;
        LabelIn_DP <= LabelIn_DN;
    end
end

// Data registers
always @ (posedge Clk_CI) begin
    if (Reset_RI == 1'b1) begin
        for (i=1; i < `NGRAM_SIZE; i=i+1) NGram_DP[i] <= {`HV_DIMENSION{1'b0}};
    end else if (NGramEN_S == 1'b1) begin
        for (i=1; i < `NGRAM_SIZE; i=i+1) NGram_DP[i] <= NGram_DN[i];
    end
end

// Control registers
// Fill NGram counter
always @ (posedge Clk_CI) begin
    if ((Reset_RI == 1'b1) || (FillNGramCntrCLR_S == 1'b1)) begin
        FillNGramCntr_SP <= `NGRAM_SIZE-1;
    end else if (FillNGramCntrEN_S == 1'b1) begin
        FillNGramCntr_SP <= FillNGramCntr_SN;
    end
end

// NGram full memory
always @(posedge Clk_CI) begin
    if (Reset_RI == 1'b1) begin
        NGramFullMemory_SP <= 1'b0;
    end else if (NGramFullMemoryEN_S == 1'b1) begin
        NGramFullMemory_SP <= NGramFullMemory_SN;
    end
end

//FSM
always @ (posedge Clk_CI) begin
    if (Reset_RI == 1'b1) begin
        prev_state <= IDLE;
    end else begin
        prev_state <= next_state;
    end
end
    
endmodule
