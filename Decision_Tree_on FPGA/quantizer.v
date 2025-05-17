
`timescale 1ns / 1ps
module quantizer(
    input clk,                  // Clock input for synchronization
    input rst,                  // Reset signal
    input start,                // Start signal to begin quantization
    output reg done,            // Done signal to indicate completion
    output reg [5:0] q_data,    // Quantized output data
    output reg [11:0] q_addr    // Address for storing quantized data
);
    
    // For simulation purposes, we'll still use file I/O
    // In actual FPGA implementation, this would be replaced with memory or direct input
    reg [23:0] RGB [0:4095];    // Array to store 4096 RGB values
    reg [5:0] new_color [0:4095]; // Array for quantized outputs
    
    // State definitions
    localparam IDLE = 2'b00;
    localparam PROCESS = 2'b01;
    localparam OUTPUT = 2'b10;
    localparam FINISHED = 2'b11;
    
    reg [1:0] state;
    reg [11:0] process_count;
    
    // Load RGB data in initial block (simulation only)
    // In actual FPGA, this would come from memory or input ports
    initial begin
        $readmemh("D:/Eng_Stuff/majorProject/Decision_Tree/test_infected_txt/test_infected_27.txt", RGB, 0, 4095);
    end
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            process_count <= 12'd0;
            done <= 1'b0;
            q_addr <= 12'd0;
        end else begin
            case (state)
                IDLE: begin
                    if (start) begin
                        state <= PROCESS;
                        process_count <= 12'd0;
                        done <= 1'b0;
                    end
                end
                
                PROCESS: begin
                    // Process one pixel per clock cycle
                    new_color[process_count] <= ((RGB[process_count][23:16] * 16) + 
                                               (RGB[process_count][15:8] * 4) + 
                                               (RGB[process_count][7:0] * 1)) / 85;
                    
                    if (process_count == 12'd4095) begin
                        state <= OUTPUT;
                        process_count <= 12'd0;
                        q_addr <= 12'd0;
                    end else begin
                        process_count <= process_count + 1;
                    end
                end
                
                OUTPUT: begin
                    // Output quantized data, one pixel per clock cycle
                    q_data <= new_color[q_addr];
                    
                    if (q_addr == 12'd4095) begin
                        state <= FINISHED;
                    end else begin
                        q_addr <= q_addr + 1;
                    end
                end
                
                FINISHED: begin
                    done <= 1'b1;
                    // Stay in this state until reset
                end
            endcase
        end
    end

    // For simulation debugging
    always @(state) begin
        case(state)
            IDLE: $display("Quantizer: IDLE state");
            PROCESS: $display("Quantizer: PROCESS state");
            OUTPUT: $display("Quantizer: OUTPUT state");
            FINISHED: $display("Quantizer: FINISHED state, quantization complete");
        endcase
    end
endmodule