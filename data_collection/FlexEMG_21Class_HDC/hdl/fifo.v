`include "const.vh"

module fifo #(
    parameter data_width = 8,
    parameter fifo_depth = 32,
    parameter addr_width = `ceilLog2(fifo_depth)
) (
    input clk, rst,
    
    // Write side
    input wr_en,
    input [data_width-1:0] din,

    // Read side
    input rd_en,
    output reg [data_width-1:0] dout
);
    reg [data_width-1:0] data [fifo_depth-1:0];
    reg [addr_width-1:0] rd_ptr, wr_ptr;
    reg [addr_width:0] entry_counter = 0;    

    integer i;

    assign full = entry_counter == fifo_depth;
    assign empty = entry_counter == 0;

    // Update entry_counter
    always @ (posedge clk) begin
        if (rst) begin
            entry_counter <= 0;
        end
        else if (wr_en && ~rd_en) begin
            entry_counter <= entry_counter + 1;
        end
        else if (rd_en && ~wr_en) begin
            entry_counter <= entry_counter - 1;
        end
        else begin
            entry_counter <= entry_counter;
        end
    end

    // Update read pointer
    always @ (posedge clk) begin
        if (rst) begin
            rd_ptr <= 0;
        end
        else if (rd_en) begin
            rd_ptr <= rd_ptr + 1;
        end
        else begin
            rd_ptr <= rd_ptr;
        end
    end

    // Update write pointer
    always @ (posedge clk) begin
        if (rst) begin
            wr_ptr <= 0;
        end
        else if (wr_en) begin
            wr_ptr <= wr_ptr + 1;
        end
        else begin
            wr_ptr <= wr_ptr;
        end
    end

    // Update internal data array
    always @ (posedge clk) begin
        if (rst) begin
            for (i=0; i < fifo_depth; i=i+1) data[i] <= {data_width{1'b0}};
        end
        else if (wr_en) begin
            data[wr_ptr] <= din;
        end
        else begin
            data[wr_ptr] <= data[wr_ptr];
        end
    end

    // Update data out
    always @ (posedge clk) begin
        if (rst) begin
            dout <= 0;
        end
        else if (rd_en) begin
            dout <= data[rd_ptr];
        end
        else begin
            dout <= dout;
        end
    end

endmodule
