`timescale 1ns / 1ps

module MAC_UNIT(
    input  [8:0] a,
    output [3:0] sum
);
    wire [8:0] mult;
    wire [1:0] s1, s2, s3, s4;
    wire [2:0] s11, s12;
    wire [3:0] s111;

    // Partial multiplications: only bits 0,2,4,6,8 are used (others are zeroed)
    assign mult[0] = a[0] & 1'b1;
    assign mult[1] = a[1] & 1'b0;
    assign mult[2] = a[2] & 1'b1;
    assign mult[3] = a[3] & 1'b0;
    assign mult[4] = a[4] & 1'b1;
    assign mult[5] = a[5] & 1'b0;
    assign mult[6] = a[6] & 1'b1;
    assign mult[7] = a[7] & 1'b0;
    assign mult[8] = a[8] & 1'b1;

    // Partial sums
    assign s1 = mult[0] + mult[1];
    assign s2 = mult[2] + mult[3];
    assign s3 = mult[4] + mult[5];
    assign s4 = mult[6] + mult[7];
    
    assign s11 = s1 + s2;
    assign s12 = s3 + s4;
    assign s111 = s11 + s12;
    
    // Final sum = (a[0] + a[2] + a[4] + a[6]) + a[8]
    assign sum = s111 + mult[8];
    
endmodule