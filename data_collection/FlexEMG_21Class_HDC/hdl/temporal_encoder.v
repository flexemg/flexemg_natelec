`include "const.vh"

module temporal_encoder
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

reg [1:0] ModeIn_SP;
wire [1:0] ModeIn_SN;
wire [`LABEL_WIDTH-1:0] LabelIn_DN;
reg [`LABEL_WIDTH-1:0] LabelIn_DP;
reg [0:`HV_DIMENSION-1] NGram_DP [1:`NGRAM_SIZE-1]; 
wire [0:`HV_DIMENSION-1] NGram_DN [1:`NGRAM_SIZE-1];
//reg [0:`HV_DIMENSION-1] ngram_row;
reg [1:0] FSM_SP, FSM_SN;
reg [`FILL_NGRAM_COUNTER_WIDTH-1 : 0] FillNGramCntr_SP;
wire [`FILL_NGRAM_COUNTER_WIDTH-1 : 0] FillNGramCntr_SN;
reg [0 : `HV_DIMENSION-1] BindNGramOut_D, result;
wire ModeChange_S, LabelChange_S, NGramFull_S;
reg InputBuffersEN_S, NGramEN_S, BundledHypervectorEN_S, CycleShiftRegEN_S, CycleShiftRegCLR_S, FillNGramCntrEN_S, FillNGramCntrCLR_S;

localparam 
  idle = 2'd0,
  forward_training = 2'd1,
  accept_input = 2'd2,
  forward_query = 2'd3,
  FILL_NGRAM_COUNTER_WIDTH = `ceilLog2(`NGRAM_SIZE);

integer i, j, sum;
genvar y;
//reg [0:`HV_DIMENSION-1] ngram_row;

similarity_bundler TemporalAccum (Clk_CI, Reset_RI, BundledHypervectorEN_S, CycleShiftRegEN_S, CycleShiftRegCLR_S, BindNGramOut_D, HypervectorOut_DO);

//input signals
assign ModeIn_SN  = ModeIn_SI;
assign LabelIn_DN = LabelIn_DI;

//NGram permutation
assign NGram_DN[1] = {HypervectorIn_DI[`HV_DIMENSION-1], HypervectorIn_DI[0:`HV_DIMENSION-2]};
generate 
  for (y=2; y<`NGRAM_SIZE; y=y+1) begin
      //assign NGram_DN[i][0] = NGram_DP[i-1][`HV_DIMENSION-1];
      //assign NGram_DN[i][0:`HV_DIMENSION-2] = NGram_DP[i-1][0:`HV_DIMENSION-2];
      assign NGram_DN[y] = {NGram_DP[y-1][`HV_DIMENSION-1], NGram_DP[y-1][0:`HV_DIMENSION-2]};
  end
endgenerate

//NGram binding
always @ (*) begin
  result = HypervectorIn_DI;
  for (i=1; i<`NGRAM_SIZE; i=i+1) begin
    result = result ^ NGram_DP[i];
  end
  BindNGramOut_D = result;
end

//output signals
assign ModeOut_SO  = ModeIn_SP;
assign LabelOut_DO = LabelIn_DP;

//label comparison
assign ModeChange_S  = (ModeIn_SI != ModeIn_SP) ? 1'b1 : 1'b0;
assign LabelChange_S = (LabelIn_DI != LabelIn_DP) ? 1'b1 : 1'b0;

//NGram filling counter
generate
  if (`NGRAM_SIZE > 1) begin
    assign NGramFull_S = (FillNGramCntr_SP == {FILL_NGRAM_COUNTER_WIDTH{1'b0}}) ? 1'b1 : 1'b0;
    assign FillNGramCntr_SN = FillNGramCntr_SP -1;
  end
endgenerate

//FSM
always @ (*) begin
  FSM_SN = idle;
  ReadyOut_SO = 1'b0;
  ValidOut_SO = 1'b0;
  InputBuffersEN_S = 1'b0;
  NGramEN_S = 1'b0;
  BundledHypervectorEN_S = 1'b0;
  CycleShiftRegEN_S = 1'b0;
  CycleShiftRegCLR_S = 1'b0;
  FillNGramCntrEN_S = 1'b0;
  FillNGramCntrCLR_S = 1'b0;

  case(FSM_SP)
    idle: begin
      if (ValidIn_SI == 1'b0) begin
        FSM_SN = idle;
        ReadyOut_SO = 1'b1;
      end else begin
        if ((ModeIn_SI == `MODE_TRAIN) || (ModeIn_SI == `MODE_UPDATE)) begin
          if (ModeChange_S == 1'b0) begin
            if (LabelChange_S == 1'b0) begin
              FSM_SN                 = idle;
              ReadyOut_SO            = 1'b1;
              InputBuffersEN_S       = 1'b1;
              NGramEN_S              = 1'b1;
              BundledHypervectorEN_S = (NGramFull_S == 1'b1) ? 1'b1 : 1'b0;
              CycleShiftRegEN_S      = (NGramFull_S == 1'b1) ? 1'b1 : 1'b0;
              FillNGramCntrEN_S      = (NGramFull_S == 1'b0) ? 1'b1 : 1'b0;
            end else begin
              FSM_SN             = (ReadyIn_SI == 1'b0) ? forward_training : accept_input;
              ValidOut_SO        = 1'b1;
              CycleShiftRegCLR_S = 1'b1;
              FillNGramCntrCLR_S = 1'b1;
            end
          end else begin
            FSM_SN            = idle;
            ReadyOut_SO       = 1'b1;
            InputBuffersEN_S  = 1'b1;
            NGramEN_S         = 1'b1;
            FillNGramCntrEN_S = 1'b1;
          end
        end else begin
          if (ModeChange_S == 1'b0) begin
            FSM_SN                 = forward_query;
            ReadyOut_SO            = 1'b1;
            InputBuffersEN_S       = 1'b1;
            NGramEN_S              = 1'b1;
            BundledHypervectorEN_S = 1'b1;
          end else begin
            FSM_SN             = (ReadyIn_SI == 1'b0) ? forward_training : accept_input;
            ValidOut_SO        = 1'b1;
            CycleShiftRegCLR_S = 1'b1;
            FillNGramCntrCLR_S = 1'b1;
          end
        end
      end
    end

    forward_training: begin
      ValidOut_SO = 1'b1;
      if (ReadyIn_SI == 1'b0) begin
        FSM_SN = forward_training;
      end else begin
        FSM_SN                 = ((ModeIn_SI == `MODE_TRAIN) || (ModeIn_SI == `MODE_UPDATE)) ? idle : forward_query;
        ReadyOut_SO            = 1'b1;
        InputBuffersEN_S       = 1'b1;
        NGramEN_S              = 1'b1;
        BundledHypervectorEN_S = (ModeIn_SI == `MODE_PREDICT) ? 1'b1 : 1'b0;
        FillNGramCntrEN_S      = ((ModeIn_SI == `MODE_TRAIN) || (ModeIn_SI == `MODE_UPDATE)) ? 1'b1 : 1'b0;
      end
    end

    accept_input: begin
      FSM_SN                 = ((ModeIn_SI == `MODE_TRAIN) || (ModeIn_SI == `MODE_UPDATE)) ? idle : forward_query;
      ReadyOut_SO            = 1'b1;
      InputBuffersEN_S       = 1'b1;
      NGramEN_S              = 1'b1;
      BundledHypervectorEN_S = (ModeIn_SI == `MODE_PREDICT) ? 1'b1 : 1'b0;
      FillNGramCntrEN_S      = ((ModeIn_SI == `MODE_TRAIN) || (ModeIn_SI == `MODE_UPDATE)) ? 1'b1 : 1'b0;
    end

    forward_query: begin
      FSM_SN      = (ReadyIn_SI == 1'b0) ? forward_query : idle;
      ValidOut_SO = 1'b1;
    end
  endcase
end

//input buffers
always @ (posedge Clk_CI) begin
  if (Reset_RI == 1'b1) begin
    ModeIn_SP  <= `MODE_PREDICT;
    LabelIn_DP <= {`LABEL_WIDTH{1'b0}};
  end else if (InputBuffersEN_S == 1'b1) begin
    ModeIn_SP  <= ModeIn_SN;
    LabelIn_DP <= LabelIn_DN;
  end
end

//Data registers
//NGram
always @ (posedge Clk_CI) begin
  if (Reset_RI == 1'b1) begin
    for (i=1; i < `NGRAM_SIZE; i=i+1) NGram_DP[i] <= {`HV_DIMENSION{1'b0}};
  end 
  else if (NGramEN_S == 1'b1) begin
    for (i=1; i < `NGRAM_SIZE; i=i+1) NGram_DP[i] <= NGram_DN[i];
  end
end

//Control registers
//Fill NGram counter
always @ (posedge Clk_CI) begin
  if ((Reset_RI==1'b1) || (FillNGramCntrCLR_S==1'b1)) begin
    FillNGramCntr_SP <= `NGRAM_SIZE-1;
  end else if (FillNGramCntrEN_S == 1'b1) begin
    FillNGramCntr_SP <= FillNGramCntr_SN;
  end
end

//FSM
always @ (posedge Clk_CI) begin
  if (Reset_RI == 1'b1) begin
    FSM_SP <= idle;
  end else begin
    FSM_SP <= FSM_SN;
  end
end
    
endmodule












