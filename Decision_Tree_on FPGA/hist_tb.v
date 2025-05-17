`timescale 1ns / 1ps

module hist_tb();
    reg clk, rst;
    wire [11:0] count;
    wire [5:0] pixel;
    reg write_enable;
    wire done_histogram;
    // Clock generation (100 MHz)
    initial clk = 0; 
    always #5 clk = ~clk;
    

    // Instantiate modules
    counter u_counter (
        .clk_in(clk),
        .rst(rst),
        .count(count)
    );

    mux_N_1 u_mux (
        .sel(count),
        .pixel_out(pixel)
    );

    histogram_bram u_hist (
        .clk(clk),
        .pixel_value(pixel),
        .write_enable(write_enable),
        .done_histogram(done_histogram)
    );

    // Control logic
    initial begin
        rst = 1; // Reset counter
        #10;
        rst = 0; // Start counting

        // Wait for counter to reach 4095 (process all pixels)
        wait (count == 4095);
        #100; // Allow final increment to complete

        // Trigger histogram write
        write_enable = 1;
        #10;
        write_enable = 0;

        $finish;
    end

endmodule