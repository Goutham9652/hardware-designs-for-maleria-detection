
`timescale 1ns / 1ps

module cnn_classifier_tb;
    
    reg [255:0] binary_image;
    wire result;

   cnn_classifier uut(
            .binary_image(binary_image),
            .result(result)
   );
   
    integer i, j;
    
    initial begin
        
        
        // Initialize 16x16 binary input image
//        binary_image = 256'b0000011101100000000111111111000000111111111110000111111111111100111111111111110011111111111111101111111111111110111111111111111111111111111111110111111111111111011111111111111001111111111111100011111111111110000111111111110000000111111100000000000111000000;
        binary_image = 256'b0000000000000000001000100000000000000011000000000110111100000000111111111000000000111111100000100001111111110010000001111111000000000111111100000000011111111000000011111111100000001111111100000000011111000000000001110000000000000010000000000000000000000000;
        
        // Wait for convolution to complete
        #2000;
        
        // Open a file for writing the feature map output
     
        
        $display("Feature Map Output:");
        for (i = 0; i < 14; i = i + 1) begin
            for (j = 0; j < 14; j = j + 1) begin
                $write("%h", uut.featuremap[(i*14 + j)*4 +: 4]);
                
            end
            $display("");
       
        end
      
        
        // Wait for padding
        #50;
        $display("Padded 16x16 Matrix:");
        for (i = 0; i < 16; i = i + 1) begin
            for (j = 0; j < 16; j = j + 1) begin
                $write("%h", uut.padded[(i*16 + j)*4 +: 4]);
            end
            $display("");
        end
        
        // Wait for pooling
        #50;
        $display("Pooled 8x8 Output:");
        for (i = 0; i < 8; i = i + 1) begin
            for (j = 0; j < 8; j = j + 1) begin
                $write("%h", uut.pooled[(i*8 + j)*4 +: 4]);
            end
            $display("");
        end
        
        // Wait for classification to complete
        #660;
        
        // Display final classification result
        $display("Final Classification Result: %b", result);
        
        $finish;
    end
    

endmodule


