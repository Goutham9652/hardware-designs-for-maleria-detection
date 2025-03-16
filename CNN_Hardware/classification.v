`timescale 1ns / 1ps


module classification (
    input  [0:255] test_vector, // Flattened test vector: 64 values × 4 bits = 256 bits
    output         result       // Output decision: 1 indicates (for example) diseased
);
    // Instantiate BRAMs for all 64 entries using a generate loop.
    // The outputs are collected in arrays.
    wire [3:0] h_mem[0:63];
    wire [3:0] d_mem[0:63];
    
    genvar idx;
    generate
        for (idx = 0; idx < 64; idx = idx+1) begin : bram_inst
            bram_h h_inst (
                .addr_vector(idx),
                .dataOut(h_mem[idx])
            );
            bram_d d_inst (
                .addr_vector(idx),
                .dataOut(d_mem[idx])
            );
        end
    endgenerate
    
    // Compute the accumulated distances using a combinational process.
    integer i;
    reg [10:0] distance_h;
    reg [10:0] distance_d;
    reg        result_reg;
    reg [3:0] test_val;
    reg [3:0] diff_h;
    reg [3:0] diff_d;
    always @(*) begin
        distance_h = 0;
        distance_d = 0;
        for (i = 0; i < 64; i = i + 1) begin
            // Extract the 4-bit test value corresponding to index i
            
            test_val = test_vector[i*4 +: 4];
            
            // Compute absolute difference for healthy reference
            if (test_val >= h_mem[i])
                diff_h = test_val - h_mem[i];
            else
                diff_h = h_mem[i] - test_val;
            
            // Compute absolute difference for diseased reference
            if (test_val >= d_mem[i])
                diff_d = test_val - d_mem[i];
            else
                diff_d = d_mem[i] - test_val;
                
            distance_h = distance_h + diff_h;
            distance_d = distance_d + diff_d;
        end
        // Final decision: result is 1 if healthy distance is less than diseased distance.
        result_reg = (distance_h < distance_d) ? 1'b0 : 1'b1;
    end
    
    assign result = result_reg;
    
endmodule
