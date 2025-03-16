`timescale 1ns / 1ps

module bram #(
    parameter RAM_WIDTH  = 256,
    parameter RAM_ADDR_BITS = 9 ,
    parameter DATA_FILE  = "knn_rom.txt",
    parameter INIT_START_ADDR = 0,
    parameter INIT_END_ADDR = 299 )

(   input                                clk,
    input                                r,
    input                                w,
    input  [RAM_ADDR_BITS - 1 : 0]       addr,
    input  [RAM_WIDTH - 1 : 0]           dataIn,
    output  reg [RAM_WIDTH - 1 : 0]           dataOut );
    
    (* RAM_STYLE = "BLOCK" *)
    reg [RAM_WIDTH-1 : 0] b_ram [2**RAM_ADDR_BITS-1 : 0];
    
//    initial $readmemb(DATA_FILE, b_ram, INIT_START_ADDR,INIT_END_ADDR );
initial $readmemb("A:/majorProject/ROMs/knn_rom.txt", b_ram, INIT_START_ADDR, INIT_END_ADDR);

    
    always @(posedge clk)
     begin
        if(r) begin
            if(w) begin
            b_ram[addr] <= dataIn;  end
            dataOut <= b_ram[addr];
        end
     end
    
endmodule