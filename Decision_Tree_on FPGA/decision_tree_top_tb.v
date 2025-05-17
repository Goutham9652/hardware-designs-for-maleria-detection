`timescale 1ns / 1ps
module decision_tree_tb();
    // Test bench signals
    reg clk;
    reg rst;
    reg start;
    wire [1:0] class_out;
    wire process_done;
    
    // Instantiate the top module
    decision_tree_top uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .class_out(class_out),
        .process_done(process_done)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 100MHz clock
    end
    
    // Test sequence
    initial begin
        // Initialize
        rst = 1;
        start = 0;
        
        // Reset for a few cycles
        #20;
        rst = 0;
        
        // Wait a bit before starting
        #30;
        start = 1;
        
        // Clear start signal after one cycle
        #10;
        start = 0;
        
        // Wait for process to complete
        wait (process_done);
        
        $display("Final classification result: %b", class_out);
        
        // Allow some time to observe final state
        #1000;
        $finish;
    end
    
    // Monitor signals
    initial begin
        $monitor("Time=%0t, State=%0d, Class=%0b, Done=%0b", 
                 $time, uut.state, class_out, process_done);
    end
endmodule