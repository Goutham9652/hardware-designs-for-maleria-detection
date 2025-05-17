`timescale 1ns / 1ps

module pooling #(
    parameter INPUT_SIZE = 64,      // After padding
    parameter OUTPUT_SIZE = INPUT_SIZE / 2,
    parameter INPUT_BITS = INPUT_SIZE * INPUT_SIZE * 4,
    parameter OUTPUT_BITS = OUTPUT_SIZE * OUTPUT_SIZE * 4
) (
    input clk,                      // Clock signal
    input rst,                      // Reset signal
    input start,                    // Start signal to begin pooling
    input [INPUT_BITS-1:0] input_matrix,
    output reg [OUTPUT_BITS-1:0] output_matrix,
    output reg done                 // Done signal when pooling completes
);

    // Define state machine states
    localparam IDLE = 1'b0;
    localparam PROCESSING = 1'b1;
    
    // State register
    reg state;
    reg [3:0] a,b,c,d,max1, max2, max_final;
    
    integer i,j;
    // Combinational pooling logic (now registered)
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
                        // Apply max pooling in one clock cycle
                        for (i = 0; i < OUTPUT_SIZE; i = i + 1) begin
                            for ( j = 0; j < OUTPUT_SIZE; j = j + 1) begin
                                // Get the 2x2 window values
                                  a = input_matrix[((2*i)*INPUT_SIZE + 2*j)*4 +:4];
                                  b = input_matrix[((2*i)*INPUT_SIZE + (2*j+1))*4 +:4];
                                  c = input_matrix[((2*i+1)*INPUT_SIZE + 2*j)*4 +:4];
                                  d = input_matrix[((2*i+1)*INPUT_SIZE + (2*j+1))*4 +:4];
                                
                                // Find maximum in 2x2 window
                                  max1 = (a > b) ? a : b;
                                  max2 = (c > d) ? c : d;
                                  max_final = (max1 > max2) ? max1 : max2;
                                
                                output_matrix[(i*OUTPUT_SIZE + j)*4 +:4] <= max_final;
                            end
                        end
                    end
                end
                
                PROCESSING: begin
                    
                    done <= 1;
                    
                    if (~start) begin  // Wait for start to go low before returning to IDLE
                        state <= IDLE;
                    end
                end
            endcase
        end
    end

endmodule