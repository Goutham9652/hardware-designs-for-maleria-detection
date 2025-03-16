`timescale 1ns / 1ps

module padding (
    input [0:783] input_matrix,  // Flattened 14x14 input (4-bit elements)
    output [0:1023] output_matrix // Flattened 16x16 output (one-padded)
);

    // Loop through all 16x16 output positions
    generate
        genvar row, col;
        for (row = 0; row < 16; row = row + 1) begin : GEN_ROW
            for (col = 0; col < 16; col = col + 1) begin : GEN_COL
                // Assign output pixel
                if (row == 0 || row == 15 || col == 0 || col == 15) begin
                    // Border: Zero-padding
                    assign output_matrix[(row*16 + col)*4 +:4] = 4'b1;
                end else begin
                    // Map input to output (offset by 1 due to padding)
                    assign output_matrix[(row*16 + col)*4 +:4] = 
                        input_matrix[((row-1)*14 + (col-1))*4 +:4];
                end
            end
        end
    endgenerate

endmodule