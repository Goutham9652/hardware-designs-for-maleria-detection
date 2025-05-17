

`timescale 1ns / 1ps
module counter(
    input clk,               // Clock input
    input rst,               // Reset signal
    input enable,            // Enable counting
    input [11:0] max_count,  // Maximum count value
    output reg count_done,   // Done signal when max_count is reached
    output reg [11:0] count  // Current count value
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            count <= 12'b0;
            count_done <= 1'b0;
        end else if (enable) begin
            if (count == max_count) begin
                count_done <= 1'b1;
                // Keep count at max value
            end else begin
                count <= count + 1;
                count_done <= 1'b0;
            end
        end
    end
endmodule