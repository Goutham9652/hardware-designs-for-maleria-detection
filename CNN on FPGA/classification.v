`timescale 1ns / 1ps

module classification #(
    parameter VECTOR_SIZE = 1024,    // 16, 256, or 1024
    parameter VECTOR_BITS = VECTOR_SIZE * 4
) (
    input clk,                      // Clock signal
    input rst,                      // Reset signal
    input start,                    // Start classification
    input [VECTOR_BITS-1:0] test_vector,
    output reg result,              // Classification result
    output reg done                 // Done signal
);

    // BRAM instances (now synchronous)
    wire [3:0] h_data_out;
    wire [3:0] d_data_out;
    reg [$clog2(VECTOR_SIZE)-1:0] addr;
    
    bram_h h_inst (
        .clk(clk),
        .addr(addr),
        .data_out(h_data_out)
    );
    
    bram_d d_inst (
        .clk(clk),
        .addr(addr),
        .data_out(d_data_out)
    );

    // State machine
    localparam IDLE = 0;
    localparam CALCULATING = 1;
    localparam FINISHED = 2;
    
    reg [1:0] state;
    
    reg [15:0] distance_h;
    reg [15:0] distance_d;
    reg [3:0] test_val, diff_h,diff_d;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            addr <= 0;
            distance_h <= 0;
            distance_d <= 0;
            result <= 0;
            done <= 0;
        end else begin
            case (state)
                IDLE: begin
                    done <= 0;
                    if (start) begin
                        state <= CALCULATING;
                        addr <= 0;
                        distance_h <= 0;
                        distance_d <= 0;
                    end
                end
                
                CALCULATING: begin
                    // Get absolute differences
                     test_val = test_vector[addr*4 +:4];
                     diff_h = (test_val >= h_data_out) ? 
                                      (test_val - h_data_out) : 
                                      (h_data_out - test_val);
                    diff_d = (test_val >= d_data_out) ? 
                                      (test_val - d_data_out) : 
                                      (d_data_out - test_val);
                    
                    // Accumulate distances
                    distance_h <= distance_h + diff_h;
                    distance_d <= distance_d + diff_d;
                    
                    // Check if finished
                    if (addr == VECTOR_SIZE-1) begin
                        state <= FINISHED;
                        result <= (distance_h + diff_h < distance_d + diff_d) ? 1'b0 : 1'b1;
                    end else begin
                        addr <= addr + 1;
                    end
                end
                
                FINISHED: begin
                    done <= 1;
                    if (~start) begin
                        state <= IDLE;
                    end
                end
            endcase
        end
    end

endmodule