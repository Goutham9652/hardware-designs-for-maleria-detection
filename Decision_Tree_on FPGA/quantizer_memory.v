
`timescale 1ns / 1ps
module quantizer_memory(
    input clk,                    // Clock input
    input write_enable,           // Write enable signal
    input [11:0] write_addr,      // Write address
    input [5:0] write_data,       // Data to write
    input [11:0] read_addr,       // Read address
    output reg [5:0] read_data    // Data output
);

    // Memory to store 4096 6-bit quantized values
    reg [5:0] memory [0:4095];
    
    // Read operation (async)
    always @(*) begin
        read_data = memory[read_addr];
    end
    
    // Write operation (sync)
    always @(posedge clk) begin
        if (write_enable) begin
            memory[write_addr] <= write_data;
        end
    end
endmodule