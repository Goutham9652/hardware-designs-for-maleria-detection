`timescale 1ns / 1ps

module padding #(
    parameter INPUT_SIZE = 62,      // From conv output
    parameter OUTPUT_SIZE = INPUT_SIZE + 2,
    parameter INPUT_BITS = INPUT_SIZE * INPUT_SIZE * 4,
    parameter OUTPUT_BITS = OUTPUT_SIZE * OUTPUT_SIZE * 4
) (
    input clk,                      // Clock signal
    input rst,                      // Reset signal
    input start,                    // Start signal to begin padding
    input [INPUT_BITS-1:0] input_matrix,
    output reg [OUTPUT_BITS-1:0] output_matrix,
    output reg done                 // Done signal when padding completes
);

    // Define state machine states
    localparam IDLE = 1'b0;
    localparam PROCESSING = 1'b1;
    
    // State register
    reg state;
    integer row, col;
    // Combinational padding logic (now registered)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            output_matrix <= 0;
            done <= 0;
            state <= IDLE;
        end else begin
            case (state)
                IDLE: begin
                    done <= 0;
                    if (start) begin
                        state <= PROCESSING;
                        // Apply padding in one clock cycle (combinational operation registered)
                        for (row = 0; row < OUTPUT_SIZE; row = row + 1) begin
                            for ( col = 0; col < OUTPUT_SIZE; col = col + 1) begin
                                if (row == 0 || row == OUTPUT_SIZE-1 || col == 0 || col == OUTPUT_SIZE-1) begin
                                    // Border: One-padding
                                    output_matrix[(row*OUTPUT_SIZE + col)*4 +:4] <= 4'b1;
                                end else begin
                                    // Map input to output (offset by 1 due to padding)
                                    output_matrix[(row*OUTPUT_SIZE + col)*4 +:4] <= 
                                        input_matrix[((row-1)*INPUT_SIZE + (col-1))*4 +:4];
                                end
                            end
                        end
                    end
                end
                
                PROCESSING: begin
                    // Operation completes in one clock cycle
                    done <= 1;
                    if (~start) begin  // Wait for start to go low before returning to IDLE
                        state <= IDLE;
                    end
                end
            endcase
        end
    end

endmodule