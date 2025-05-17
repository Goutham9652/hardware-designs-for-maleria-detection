
`timescale 1ns / 1ps
module histogram_bram (
    input clk,                  // Clock for synchronization
    input rst,                  // Reset signal
    input start,                // Start histogram computation
    input [5:0] pixel_value,    // 6-bit pixel input
    input update_enable,        // Enable signal for histogram update
    output reg done_histogram,  // Signal when histogram computation is complete
    output reg [11:0] bin_0,    // Direct output of histogram[0]
    output reg [11:0] bin_38,   // Direct output of histogram[38]
    output reg [11:0] bin_39,   // Direct output of histogram[39]
    output reg [11:0] bin_34    // Direct output of histogram[34]
);
    reg [11:0] histogram [0:63]; // 64 bins
    integer i;
    
    // State definitions
    localparam IDLE = 2'b00;
    localparam COMPUTING = 2'b01;
    localparam FINISHED = 2'b10;
    
    reg [1:0] state;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset logic
            state <= IDLE;
            done_histogram <= 1'b0;
            
            // Reset all histogram bins
            for (i = 0; i < 64; i=i+1) 
                histogram[i] <= 12'b0;
                
            // Reset output bin values
            bin_0 <= 12'b0;
            bin_38 <= 12'b0;
            bin_39 <= 12'b0;
            bin_34 <= 12'b0;
        end else begin
            case (state)
                IDLE: begin
                    if (start) begin
                        state <= COMPUTING;
                        done_histogram <= 1'b0;
                    end
                end
                
                COMPUTING: begin
                    // Update histogram on clock edge when enabled
                    if (update_enable) begin
                        histogram[pixel_value] <= histogram[pixel_value] + 1;
                    end else begin
                        // When update is no longer enabled, move to FINISHED state
                        state <= FINISHED;
                    end
                end
                
                FINISHED: begin
                    // Assign bin outputs
                    bin_0 <= histogram[0];
                    bin_38 <= histogram[38];
                    bin_39 <= histogram[39];
                    bin_34 <= histogram[34];
                    
                    done_histogram <= 1'b1;
                    // Stay in this state until reset
                end
            endcase
        end
    end
    
    // For simulation debugging
    always @(state) begin
        case(state)
            IDLE: $display("Histogram: IDLE state");
            COMPUTING: $display("Histogram: COMPUTING state");
            FINISHED: $display("Histogram: FINISHED state - Final counts: bin_0=%d, bin_34=%d, bin_38=%d, bin_39=%d", 
                       histogram[0], histogram[34], histogram[38], histogram[39]);
        endcase
    end
endmodule
