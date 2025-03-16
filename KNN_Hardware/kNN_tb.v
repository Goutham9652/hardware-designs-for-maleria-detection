`timescale 1ns / 1ps

module kNN_tb;

    reg clk;
    reg rst;
    reg [255:0] test_image;
    reg valid;
    wire [8:0] current_min;
    wire [8:0] min_row;
    wire result;

    // Instantiate the system module
    kNN uut (
        .clk(clk),
        .rst(rst),
        .test_image(test_image),
        .valid(valid),
        .current_min(current_min),
        .min_row(min_row),
        .result(result)
    );

    // Clock generation with longer period
    initial clk = 0;
    always #5 clk = ~clk;  // Clock period of 10 ns (adjust as needed)

    // Debugging statements
    always @(posedge clk) begin
        $display("Time: %0t | Row Counter: %d | Min Val: %d | Min Row: %d | Result: %b",
                  $time, uut.row_counter, uut.current_min, uut.min_row, uut.result);
    end

    initial begin
        // Initial conditions
        rst = 1;
        valid = 0;
        test_image = 256'b0000011111000000000011111110000000011111111100000011111111111000011111111111100001111111111111101111111111111111111111111111111111111001111111111111100111111111011111111001111100111111110111110011111111110011000111111111111100001111111111100000001111100000;

        // Reset pulse
        #10 rst = 0;

        // Start the operation
        valid = 1;

        // Run the simulation for sufficient time
        #6000 $finish; // Adjust this value if necessary
    end

endmodule

