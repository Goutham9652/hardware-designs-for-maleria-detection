`timescale 1ns / 1ps
module decision_tree_top (
    input clk,               // Global Clock
    input rst,               // Reset
    input start,             // Start signal for the entire process
    output wire [1:0] class_out,  // Final classification output
    output wire process_done      // Signal indicating entire process is complete
);
    // State machine definitions
    localparam IDLE = 3'b000;
    localparam QUANTIZING = 3'b001;
    localparam HISTOGRAMMING = 3'b010;
    localparam CLASSIFYING = 3'b011;
    localparam DONE = 3'b100;
    
    reg [2:0] state;
    
    // Internal control signals
    reg quant_start;
    reg hist_start;
    reg classify_start;
    reg counter_enable;
    reg mem_write_enable;
    
    // Status signals from modules
    wire quant_done;
    wire count_done;
    wire hist_done;
    wire classify_done;
    
    // Data signals
    wire [5:0] quantized_pixel;
    wire [5:0] pixel_for_hist;
    wire [11:0] quant_addr;
    wire [11:0] pixel_counter;
    
    // Histogram Bin Values
    wire [11:0] bin_0;
    wire [11:0] bin_38;
    wire [11:0] bin_39;
    wire [11:0] bin_34;
    
    // Classification output
    wire [1:0] classification_result;
    
    // Instantiate Quantizer
    quantizer quant_inst (
        .clk(clk),
        .rst(rst),
        .start(quant_start),
        .done(quant_done),
        .q_data(quantized_pixel),
        .q_addr(quant_addr)
    );
    
    // Memory to store quantized pixels
    quantizer_memory mem_inst (
        .clk(clk),
        .write_enable(mem_write_enable),
        .write_addr(quant_addr),
        .write_data(quantized_pixel),
        .read_addr(pixel_counter),
        .read_data(pixel_for_hist)
    );
    
    // Counter for addressing pixels during histogram computation
    counter counter_inst (
        .clk(clk),
        .rst(rst),
        .enable(counter_enable),
        .max_count(12'd4095),
        .count_done(count_done),
        .count(pixel_counter)
    );
    
    // Histogram BRAM to Compute Histogram
    histogram_bram hist_inst (
        .clk(clk),
        .rst(rst),
        .start(hist_start),
        .pixel_value(pixel_for_hist),
        .update_enable(counter_enable),
        .done_histogram(hist_done),
        .bin_0(bin_0),
        .bin_38(bin_38),
        .bin_39(bin_39),
        .bin_34(bin_34)
    );
    
    // Classification Module
    classification classify_inst (
        .clk(clk),
        .rst(rst),
        .start_classification(classify_start),
        .bin_0(bin_0),
        .bin_38(bin_38),
        .bin_39(bin_39),
        .bin_34(bin_34),
        .classification(classification_result),
        .classification_done(classify_done)
    );
    
    // Connect outputs
    assign class_out = classification_result;
    assign process_done = (state == DONE);
    
    // Main state machine for controlling the flow
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            quant_start <= 1'b0;
            mem_write_enable <= 1'b0;
            hist_start <= 1'b0;
            counter_enable <= 1'b0;
            classify_start <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    if (start) begin
                        state <= QUANTIZING;
                        quant_start <= 1'b1;
                    end
                end
                
                QUANTIZING: begin
                    quant_start <= 1'b0; // Clear start signal after one cycle
                    mem_write_enable <= 1'b1; // Enable writing to memory
                    
                    if (quant_done) begin
                        mem_write_enable <= 1'b0;
                        state <= HISTOGRAMMING;
                        hist_start <= 1'b1;
                        counter_enable <= 1'b1; // Start the counter for histogram
                    end
                end
                
                HISTOGRAMMING: begin
                    hist_start <= 1'b0; // Clear start signal after one cycle
                    
                    if (count_done) begin
                        counter_enable <= 1'b0; // Stop counter once all pixels processed
                    end
                    
                    if (hist_done) begin
                        state <= CLASSIFYING;
                        classify_start <= 1'b1;
                    end
                end
                
                CLASSIFYING: begin
                    classify_start <= 1'b0; // Clear start signal after one cycle
                    
                    if (classify_done) begin
                        state <= DONE;
                    end
                end
                
                DONE: begin
                    // Stay in DONE state until reset
                end
            endcase
        end
    end
    
    // For simulation debugging
    always @(state) begin
        case(state)
            IDLE: $display("Top: IDLE state");
            QUANTIZING: $display("Top: QUANTIZING state");
            HISTOGRAMMING: $display("Top: HISTOGRAMMING state");
            CLASSIFYING: $display("Top: CLASSIFYING state");
            DONE: $display("Top: DONE state - Final classification: %b", class_out);
        endcase
    end
endmodule