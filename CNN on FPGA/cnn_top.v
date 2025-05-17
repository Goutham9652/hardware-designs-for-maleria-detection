`timescale 1ns / 1ps
module cnn_top #(
    parameter INPUT_SIZE = 64,
    parameter KERNEL_SIZE = 3,
    parameter CONV_OUTPUT_SIZE = INPUT_SIZE - KERNEL_SIZE + 1,    // 62
    parameter PAD_OUTPUT_SIZE = CONV_OUTPUT_SIZE + 2,            // 64
    parameter POOL_OUTPUT_SIZE = PAD_OUTPUT_SIZE / 2,            // 32
    
    // Bit width calculations
    parameter INPUT_BITS = INPUT_SIZE * INPUT_SIZE,
    parameter CONV_OUTPUT_BITS = CONV_OUTPUT_SIZE * CONV_OUTPUT_SIZE * 4,
    parameter PAD_OUTPUT_BITS = PAD_OUTPUT_SIZE * PAD_OUTPUT_SIZE * 4,
    parameter POOL_OUTPUT_BITS = POOL_OUTPUT_SIZE * POOL_OUTPUT_SIZE * 4,
    parameter VECTOR_BITS = POOL_OUTPUT_BITS  // Feature vector size
)(
    input clk,
    input rst,
    input start,
    input [INPUT_BITS-1:0] input_image,
    output result,         // 1: Diseased, 0: Healthy
    output reg done
);
    // Define the control states
    localparam IDLE = 3'b000;
    localparam CONV_STAGE = 3'b001;
    localparam PADDING_STAGE = 3'b010;
    localparam POOLING_STAGE = 3'b011;
    localparam CLASSIFY_STAGE = 3'b100;
    localparam FINISHED = 3'b101;
    
    // State register
    reg [2:0] state, next_state;
    
    // Intermediate results
    wire [CONV_OUTPUT_BITS-1:0] conv_output;
    wire [PAD_OUTPUT_BITS-1:0] pad_output;
    wire [POOL_OUTPUT_BITS-1:0] pool_output;
    
    // Module control signals
    reg conv_start, pad_start, pool_start, classify_start;
    wire conv_done, pad_done, pool_done, classify_done;
    
    // Convolution module (Step 2a)
    Conv #(
        .INPUT_SIZE(INPUT_SIZE),
        .KERNEL_SIZE(KERNEL_SIZE),
        .OUTPUT_SIZE(CONV_OUTPUT_SIZE),
        .INPUT_BITS(INPUT_BITS),
        .OUTPUT_BITS(CONV_OUTPUT_BITS)
    ) conv_module (
        .clk(clk),
        .rst(rst),
        .start(conv_start),
        .input_matrix(input_image),
        .output_feature_map(conv_output),
        .done(conv_done)
    );
    
    // Padding module (between Step 2a and 2b)
    padding #(
        .INPUT_SIZE(CONV_OUTPUT_SIZE),
        .OUTPUT_SIZE(PAD_OUTPUT_SIZE),
        .INPUT_BITS(CONV_OUTPUT_BITS),
        .OUTPUT_BITS(PAD_OUTPUT_BITS)
    ) pad_module (
        .clk(clk),
        .rst(rst),
        .start(pad_start),
        .input_matrix(conv_output),
        .output_matrix(pad_output),
        .done(pad_done)
    );
    
    // Pooling module (Step 2b)
    pooling #(
        .INPUT_SIZE(PAD_OUTPUT_SIZE),
        .OUTPUT_SIZE(POOL_OUTPUT_SIZE),
        .INPUT_BITS(PAD_OUTPUT_BITS),
        .OUTPUT_BITS(POOL_OUTPUT_BITS)
    ) pool_module (
        .clk(clk),
        .rst(rst),
        .start(pool_start),
        .input_matrix(pad_output),
        .output_matrix(pool_output),
        .done(pool_done)
    );
    
    // Classification module (Step 3)
    classification #(
        .VECTOR_SIZE(POOL_OUTPUT_SIZE * POOL_OUTPUT_SIZE),
        .VECTOR_BITS(POOL_OUTPUT_BITS)
    ) classify_module (
        .clk(clk),
        .rst(rst),
        .start(classify_start),
        .test_vector(pool_output),
        .result(result),
        .done(classify_done)
    );
    
    // State machine - sequential logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            done <= 0;
            conv_start <= 0;
            pad_start <= 0;
            pool_start <= 0;
            classify_start <= 0;
        end else begin
            state <= next_state;
            
            // Default values
            conv_start <= 0;
            pad_start <= 0;
            pool_start <= 0;
            classify_start <= 0;
            done <= 0;
            
            case (state)
                IDLE: begin
                    if (start)
                        conv_start <= 1;  // Start convolution when top module start is asserted
                end
                
                CONV_STAGE: begin
                    conv_start <= 1;  // Keep conv_start high until conv_done
                    if (conv_done)
                        pad_start <= 1;  // Start padding when convolution is done
                end
                
                PADDING_STAGE: begin
                    pad_start <= 1;  // Keep pad_start high until pad_done
                    if (pad_done)
                        pool_start <= 1;  // Start pooling when padding is done
                end
                
                POOLING_STAGE: begin
                    pool_start <= 1;  // Keep pool_start high until pool_done
                    if (pool_done)
                        classify_start <= 1;  // Start classification when pooling is done
                end
                
                CLASSIFY_STAGE: begin
                    classify_start <= 1;  // Keep classify_start high until classify_done
                end
                
                FINISHED: begin
                    done <= 1;  // Assert done signal when processing is complete
                end
            endcase
        end
    end
    
    // State machine - combinational logic
    always @(*) begin
        next_state = state;  // Default: stay in current state
        
        case (state)
            IDLE: begin
                if (start)
                    next_state = CONV_STAGE;
            end
            
            CONV_STAGE: begin
                if (conv_done)
                    next_state = PADDING_STAGE;
            end
            
            PADDING_STAGE: begin
                if (pad_done)
                    next_state = POOLING_STAGE;
            end
            
            POOLING_STAGE: begin
                if (pool_done)
                    next_state = CLASSIFY_STAGE;
            end
            
            CLASSIFY_STAGE: begin
                if (classify_done)
                    next_state = FINISHED;
            end
            
            FINISHED: begin
                if (!start)  // Return to IDLE when start is de-asserted
                    next_state = IDLE;
            end
            
            default: next_state = IDLE;
        endcase
    end
    
endmodule