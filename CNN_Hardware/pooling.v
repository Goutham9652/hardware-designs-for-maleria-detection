`timescale 1ns / 1ps

module pooling (
    input [0:1023] input_matrix,  // Flattened 16x16 input (4-bit elements)
    output [0:255] output_matrix  // Flattened 8x8 output (4-bit elements)
);

    // Generate 8x8 output by processing 2x2 blocks
    generate
        genvar i, j;
        for (i = 0; i < 8; i = i + 1) begin : ROW
            for (j = 0; j < 8; j = j + 1) begin : COL
                // Extract 2x2 block from input_matrix
                wire [3:0] a = input_matrix[ ((2*i)*16 + 2*j)*4 +:4];
                wire [3:0] b = input_matrix[ ((2*i)*16 + (2*j+1))*4 +:4];
                wire [3:0] c = input_matrix[ ((2*i+1)*16 + 2*j)*4 +:4];
                wire [3:0] d = input_matrix[ ((2*i+1)*16 + (2*j+1))*4 +:4];

                // Compute max of the 2x2 block
                wire [3:0] max1 = (a > b) ? a : b;
                wire [3:0] max2 = (c > d) ? c : d;
                wire [3:0] max_final = (max1 > max2) ? max1 : max2;

                // Assign to output
                assign output_matrix[(i*8 + j)*4 +:4] = max_final;
            end
        end
    endgenerate

endmodule