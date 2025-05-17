`timescale 1ns / 1ps

module classification_tb;

    parameter VECTOR_SIZE = 64;  // Reduced for simulation
    parameter VECTOR_BITS = VECTOR_SIZE * 4;
    
    reg clk;
    reg rst;
    reg start;
    reg [VECTOR_BITS-1:0] test_vector;
    wire result;
    wire done;
    
    classification #(
        .VECTOR_SIZE(VECTOR_SIZE)
    ) uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .test_vector(test_vector),
        .result(result),
        .done(done)
    );
    
    always #5 clk = ~clk;
    
    initial begin
        clk = 0;
        rst = 1;
        start = 0;
        
        // Simple test pattern
        test_vector = 256'h1245541125555541355555544555555545555555455555542555554112454311;
        
        #20;
        rst = 0;
        #10;
        
        // Start classification
        start = 1;
        #10;
        start = 0;
        
        // Wait for completion
        wait(done);
        #20;
        
        $display("Classification result: %b (0=h, 1=d)", result);
        $finish;
    end
    
endmodule