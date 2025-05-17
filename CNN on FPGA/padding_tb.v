`timescale 1ns / 1ps

module padding_tb;

    // Parameters
    parameter INPUT_SIZE = 14;  // Using smaller size for easier verification
    parameter OUTPUT_SIZE = INPUT_SIZE + 2;
    parameter INPUT_BITS = INPUT_SIZE * INPUT_SIZE * 4;
    parameter OUTPUT_BITS = OUTPUT_SIZE * OUTPUT_SIZE * 4;
    
    // Test duration
    parameter TEST_DURATION = 1000;
    
    // Inputs
    reg clk;
    reg rst;
    reg start;
    reg [INPUT_BITS-1:0] input_matrix;
    
    // Outputs
    wire [OUTPUT_BITS-1:0] output_matrix;
    wire done;
    
    // Instantiate the Unit Under Test (UUT)
    padding #(
        .INPUT_SIZE(INPUT_SIZE),
        .OUTPUT_SIZE(OUTPUT_SIZE),
        .INPUT_BITS(INPUT_BITS),
        .OUTPUT_BITS(OUTPUT_BITS)
    ) uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .input_matrix(input_matrix),
        .output_matrix(output_matrix),
        .done(done)
    );
    
    // Clock generation (100MHz)
    always #5 clk = ~clk;
    
    // Test stimulus
    initial begin
        // Initialize Inputs
        clk = 0;
        rst = 1;
        start = 0;
        
        // Simple test pattern (4x4 input, each element is 4 bits)
        // Each value equals its position for easy verification
        input_matrix = 784'h1123445544311012445555554411245555555554413455555555554335555555555554355555555555544555555555555545555555555555455555555555544555555555555434555555555543245555555554411244555555441111234454433110;
        
        // Reset sequence
        #20;
        rst = 0;
        #10;
        
        // Test case 1: Normal operation
        $display("[%0t] Test Case 1: Normal padding operation", $time);
        start = 1;
        wait(done);
        #10;
        start = 0;
        print_results();
        
       
        #100;
        $display("\n[%0t] Simulation completed", $time);
        $finish;
    end
    
    // Task to print input and output matrices
    task print_results;
        begin
            $display("Input Matrix (%0dx%0d):", INPUT_SIZE, INPUT_SIZE);
            print_matrix(input_matrix, INPUT_SIZE, INPUT_SIZE);
            
            $display("\nOutput Matrix with Padding (%0dx%0d):", OUTPUT_SIZE, OUTPUT_SIZE);
            print_matrix(output_matrix, OUTPUT_SIZE, OUTPUT_SIZE);
            
            $display("Done signal: %b", done);
            $display("----------------------------------------");
        end
    endtask
    
    // Generic matrix printing task
    task print_matrix;
        input [OUTPUT_BITS-1:0] matrix;
        input integer rows, cols;
        integer i, j;
        begin
            for (i = 0; i < rows; i = i + 1) begin
                $write("Row %0d: ", i);
                for (j = 0; j < cols; j = j + 1) begin
                    $write("%h ", matrix[(i*cols + j)*4 +:4]);
                end
                $display("");
            end
        end
    endtask
    
    // Simulation timeout
    initial begin
        #TEST_DURATION;
        $display("\n[%0t] Error: Simulation timed out", $time);
        $finish;
    end
    
endmodule