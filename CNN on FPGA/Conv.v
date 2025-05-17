`timescale 1ns / 1ps
module Conv #(
    parameter INPUT_SIZE = 64,      // 8, 32, or 64
    parameter KERNEL_SIZE = 3,
    parameter OUTPUT_SIZE = INPUT_SIZE - KERNEL_SIZE + 1,
    parameter INPUT_BITS = INPUT_SIZE * INPUT_SIZE,
    parameter OUTPUT_BITS = OUTPUT_SIZE * OUTPUT_SIZE * 4
) (
    input clk,                          // Clock signal
    input rst,                          // Reset signal
    input start,                        // Start signal to begin convolution
    input [INPUT_BITS-1:0] input_matrix,
    output [OUTPUT_BITS-1:0] output_feature_map,
    output reg done                     // Done signal when convolution completes
);
    
    // Define state machine states
    localparam IDLE = 2'b00;
    localparam PROCESSING = 2'b01;
    localparam FINISHED = 2'b10;
    
    // State registers
    reg [1:0] state, next_state;
    
    // Position counters
    reg [$clog2(OUTPUT_SIZE)-1:0] i_pos, j_pos;
    wire [$clog2(OUTPUT_SIZE)-1:0] next_i, next_j;
    
    // Register for storing output
    reg [OUTPUT_BITS-1:0] output_reg;
    
    // Window extraction logic
    wire [8:0] window;
    wire [3:0] mac_result;
    
    // Assign the window based on current i_pos and j_pos
    assign window = {
        input_matrix[(i_pos+2)*INPUT_SIZE + j_pos+2],
        input_matrix[(i_pos+2)*INPUT_SIZE + j_pos+1],
        input_matrix[(i_pos+2)*INPUT_SIZE + j_pos],
        input_matrix[(i_pos+1)*INPUT_SIZE + j_pos+2],
        input_matrix[(i_pos+1)*INPUT_SIZE + j_pos+1],
        input_matrix[(i_pos+1)*INPUT_SIZE + j_pos],
        input_matrix[i_pos*INPUT_SIZE + j_pos+2],
        input_matrix[i_pos*INPUT_SIZE + j_pos+1],
        input_matrix[i_pos*INPUT_SIZE + j_pos]
    };
    
    // Instantiate MAC unit
    MAC_Unit mac_inst (
        .a(window),
        .sum(mac_result)
    );
    
    // Calculate next position
    assign next_j = (j_pos == OUTPUT_SIZE - 1) ? 0 : j_pos + 1;
    assign next_i = (j_pos == OUTPUT_SIZE - 1) ? 
                    ((i_pos == OUTPUT_SIZE - 1) ? 0 : i_pos + 1) : 
                    i_pos;
    
    // State machine - sequential logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            i_pos <= 0;
            j_pos <= 0;
            done <= 0;
            output_reg <= 0;
        end else begin
            state <= next_state;
            
            // Update position counters based on state
            if (state == PROCESSING) begin
                i_pos <= next_i;
                j_pos <= next_j;
                
                // Update output register
                output_reg[(i_pos*OUTPUT_SIZE + j_pos)*4 +: 4] <= mac_result;
            end else if (state == IDLE) begin
                i_pos <= 0;
                j_pos <= 0;
                done <= 0;
            end else if (state == FINISHED) begin
                done <= 1;
            end
        end
    end
    
    // State machine - combinational logic
    always @(*) begin
        case (state)
            IDLE: begin
                if (start)
                    next_state = PROCESSING;
                else
                    next_state = IDLE;
            end
            
            PROCESSING: begin
                // Check if this is the last window
                if (i_pos == OUTPUT_SIZE - 1 && j_pos == OUTPUT_SIZE - 1)
                    next_state = FINISHED;
                else
                    next_state = PROCESSING;
            end
            
            FINISHED: begin
                if (!start)  // Wait until start is de-asserted
                    next_state = IDLE;
                else
                    next_state = FINISHED;
            end
            
            default: next_state = IDLE;
        endcase
    end
    
    // Output assignment
    assign output_feature_map = output_reg;
    
endmodule