`timescale 1ns / 1ps
module Conv (
    input  [255:0] input_matrix,       // 16x16 binary input (each bit is one pixel)
    output [783:0] output_feature_map   // 14x14 output (each element is 4 bits)
);
               
    genvar i, j;
    generate
        // Loop over output rows (0 to 13) and columns (0 to 13)
        for (i = 0; i < 14; i = i + 1) begin : row_loop
            for (j = 0; j < 14; j = j + 1) begin : col_loop
                
                 wire [8:0] window;
                wire [3:0] mac_result;
                
                assign window = {
                    input_matrix[((i+2)*16 + (j+2))],
                    input_matrix[((i+2)*16 + (j+1))],
                    input_matrix[((i+2)*16 + j)],
                    input_matrix[((i+1)*16 + (j+2))],
                    input_matrix[((i+1)*16 + (j+1))],
                    input_matrix[((i+1)*16 + j)],
                    input_matrix[((i)*16 + (j+2))],
                    input_matrix[((i)*16 + (j+1))],
                    input_matrix[((i)*16 + j)]
                };
                
                // Instantiate the combinational MAC_UNIT
                MAC_UNIT mac_inst (
                    .a(window),
                    .sum(mac_result)
                );
                
                
                assign output_feature_map[((i*14 + j)*4) +: 4] = mac_result;
            end
        end
    endgenerate
endmodule
