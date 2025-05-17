`timescale 1ns / 1ps

module Conv_tb;

    // Parameters
    parameter INPUT_SIZE = 16;
    parameter KERNEL_SIZE = 3;
    parameter OUTPUT_SIZE = INPUT_SIZE - KERNEL_SIZE + 1;
    parameter INPUT_BITS = INPUT_SIZE * INPUT_SIZE;
    parameter OUTPUT_BITS = OUTPUT_SIZE * OUTPUT_SIZE * 4;
    
    // Inputs
    reg clk;
    reg rst;
    reg start;
    reg [INPUT_BITS-1:0] input_matrix;
    
    // Outputs
    wire [OUTPUT_BITS-1:0] output_feature_map;
    wire done;
    
    // Instantiate the Unit Under Test (UUT)
    Conv #(
        .INPUT_SIZE(INPUT_SIZE),
        .KERNEL_SIZE(KERNEL_SIZE)
    ) uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .input_matrix(input_matrix),
        .output_feature_map(output_feature_map),
        .done(done)
    );
    
    // Clock generation
    always #5 clk = ~clk;
    
    initial begin
        // Initialize Inputs
        clk = 0;
        rst = 1;
        start = 0;
        
        // Define the input matrix (16x16)
        input_matrix = 256'b0000001111000000000011111111000000111111111110000011111111111100011111111111111001111111111111100111111111111111011111111111111111111111111111111111111111111111011111111111111001111111111111100011111111111100001111111111100000001111111100000000001110000000;
        
        // Wait 10 ns for global reset to finish
        #10;
        rst = 0;
        
        // Start the convolution
        #10;
        start = 1;
        #10;
        start = 0;
        
        // Wait for the operation to complete
        wait(done);
        #100;
        
        // Display results
        $display("Input Matrix:");
        print_matrix(input_matrix, INPUT_SIZE);
        
        $display("\nOutput Feature Map:");
        print_output_map(output_feature_map, OUTPUT_SIZE);
        
        $finish;
    end
    
    // Helper task to print input matrix
    task print_matrix;
        input [INPUT_BITS-1:0] matrix;
        input integer size;
        integer i, j;
        begin
            for (i = 0; i < size; i = i + 1) begin
                $write("Row %2d: ", i);
                for (j = 0; j < size; j = j + 1) begin
                    $write("%b ", matrix[i*size + j]);
                end
                $display("");
            end
        end
    endtask
    
    // Helper task to print output feature map
    task print_output_map;
        input [OUTPUT_BITS-1:0] out_map;
        input integer size;
        integer i, j;
        begin
            for (i = 0; i < size; i = i + 1) begin
                $write("Row %2d: ", i);
                for (j = 0; j < size; j = j + 1) begin
                    $write("%h ", out_map[(i*size + j)*4 +: 4]);
                end
                $display("");
            end
        end
    endtask
    
endmodule