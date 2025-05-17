
`timescale 1ns / 1ps
module classification (
    input clk,                      // Clock input
    input rst,                      // Reset signal
    input start_classification,     // Start classification signal
    input [11:0] bin_0,             // Histogram bin inputs
    input [11:0] bin_38,
    input [11:0] bin_39,
    input [11:0] bin_34,
    output reg [1:0] classification, // Class output
    output reg classification_done   // Classification done signal
);
    // State definitions
    localparam IDLE = 1'b0;
    localparam CLASSIFYING = 1'b1;
    
    reg state;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            classification <= 2'b00;
            classification_done <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    if (start_classification) begin
                        state <= CLASSIFYING;
                        classification_done <= 1'b0;
                    end
                end
                
                CLASSIFYING: begin
                    // Decision Tree Classification
                    if (bin_38 <= 12'd16) begin
                        if (bin_39 <= 12'd10) begin
                            if (bin_0 <= 12'd1638)
                                classification <= 2'b00; // Class 0
                            else
                                classification <= 2'b01; // Class 1
                        end 
                        else begin
                            if (bin_34 <= 12'd4)
                                classification <= 2'b00; // Class 0
                            else
                                classification <= 2'b01; // Class 1
                        end
                    end 
                    else begin
                        classification <= 2'b01; // Class 1
                    end
                    
                    classification_done <= 1'b1;
                    state <= IDLE; // Return to IDLE state for next classification
                end
            endcase
        end
    end
    
    // For simulation debugging
    always @(state) begin
        case(state)
            IDLE: $display("Classification: IDLE state");
            CLASSIFYING: $display("Classification: CLASSIFYING state");
        endcase
    end
    
    always @(classification_done) begin
        if (classification_done)
            $display("Classification complete: Result = %b", classification);
    end
endmodule
