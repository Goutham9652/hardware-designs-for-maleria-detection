  
`timescale 1ns / 1ps

module kNN (
    input clk,
    input rst,
    input [255:0] test_image,   // this is the bitstream of 16x16 binary matrix (preprocessed image's matrix)
    input valid,
    output reg [8:0] current_min,
    output reg [8:0] min_row,
    output reg result
);

    reg [255:0] reference_image;   // temp reg for storing fetched data from the Block Ram
    reg [255:0] difference_image;
    reg [8:0] white_pixel_count;
    
    reg [8:0] row_counter;
    reg [8:0] bram_addr; // Address for BRAM
    wire [255:0] bram_data_out; // Data output from BRAM

    // FSM States
    reg [1:0] state;
    localparam IDLE = 2'b00, 
               READ = 2'b01, 
               PROCESS = 2'b10, 
               DONE = 2'b11;

    // Instantiate BRAM
    bram #(
        .RAM_WIDTH(256),
        .RAM_ADDR_BITS(9),
        .INIT_START_ADDR(0),
        .INIT_END_ADDR(299)
    ) bram_inst (
        .clk(clk),
        .r(1'b1),
        .w(1'b0),
        .addr(bram_addr),
        .dataIn(256'b0),
        .dataOut(bram_data_out)
    );

    integer i;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset all signals
            state <= IDLE;
            bram_addr <= 0;
            row_counter <= 0;
            min_row <= 0;
            result <= 0;
            
            current_min <= 9'b111111111;
        end else begin
            case (state)
                IDLE: begin
                    if (valid) begin
                        row_counter <= 0;
                        bram_addr <= 0;
                        current_min <= 9'b111111111;
                        min_row <= 0;
                        
                        
                        state <= READ;
                    end
                end

                READ: begin
                    // Wait for BRAM data to be valid
                    reference_image <= bram_data_out;
                    state <= PROCESS;
                end

                PROCESS: begin
                    // Compute difference and count white pixels
                    difference_image = reference_image ^ test_image;
                    white_pixel_count = 0;
                    for (i = 0; i < 256; i = i + 1) begin
                        if (difference_image[i]) 
                            white_pixel_count = white_pixel_count + 1;
                    end

                    // Update minimum values
                    if (white_pixel_count < current_min) begin
                        current_min <= white_pixel_count;
                        min_row <= row_counter ; 
                        result <= (row_counter >= 150)? 1'b1:1'b0 ;
                    end

                    // Move to the next row or finish
                    if (row_counter < 299) begin
                        row_counter <= row_counter + 1;
                        bram_addr <= row_counter + 1;
                        state <= READ;
                    end else begin
                        state <= DONE;
                    end
                end

                DONE: begin
                    // Stay in DONE or return to IDLE if valid goes low
                    if (!valid) 
                        state <= IDLE;
                end
            endcase
        end
    end
endmodule


