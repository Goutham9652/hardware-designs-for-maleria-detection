`timescale 1ns / 1ps

module cnn_classifier(
    input clk,
    input [255:0] binary_image, 
    output wire result // 1 for diseased, 0 for healthy
);

    wire [783:0] featuremap;  // 14x14 output (4 bits per element)
    wire [1023:0] padded;     // 16x16 padded feature map (4 bits per element)
    wire [255:0] pooled;      // 8x8 output (4 bits per element)

    // Instantiating Convolution Layer
    Conv conv_inst(
       
        .input_matrix(binary_image),
        .output_feature_map(featuremap)
    );

    // Instantiating Padding Layer
    padding pad_inst(
        .input_matrix(featuremap),
        .output_matrix(padded)
    );

    // Instantiating Pooling Layer
    pooling pool_inst(
        .input_matrix(padded),
        .output_matrix(pooled)
    );

    // Instantiating Classification Layer
    classification class_inst(
        
        .test_vector(pooled),
        .result(result)
    );

endmodule
