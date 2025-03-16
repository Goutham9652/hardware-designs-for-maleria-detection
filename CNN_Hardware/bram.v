`timescale 1ns / 1ps


module bram_h #(
    parameter RAM_WIDTH             = 4,
    parameter RAM_ADDR_BITS_VECTOR  = 6,
    parameter INIT_START_ADDR_VECTOR= 0,
    parameter INIT_END_ADDR_VECTOR  = 63
)(
    input  [RAM_ADDR_BITS_VECTOR-1:0] addr_vector, 
    output [RAM_WIDTH-1:0]            dataOut 
);
    (* RAM_STYLE = "BLOCK" *) reg [RAM_WIDTH-1:0] b_ram [0:(2**RAM_ADDR_BITS_VECTOR)-1];

    initial begin
        $readmemb("D:/Eng_Stuff/majorProject/CNN_16/h_scv.txt", b_ram,
                  INIT_START_ADDR_VECTOR, INIT_END_ADDR_VECTOR);
    end

    // Asynchronous read
    assign dataOut = b_ram[addr_vector];
    
endmodule