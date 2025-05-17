module bram_h #(
    parameter RAM_WIDTH = 4,
    parameter RAM_DEPTH = 1024,
    parameter INIT_FILE = "D:/Eng_Stuff/majorProject/ROMs/cnn/h_scv_64x64.txt"
)(
    input clk,
    input [$clog2(RAM_DEPTH)-1:0] addr,
    output reg [RAM_WIDTH-1:0] data_out
);
    (* ram_style = "block" *) reg [RAM_WIDTH-1:0] bram [0:RAM_DEPTH-1];

    initial begin
        if (INIT_FILE != "") begin
            $readmemb(INIT_FILE, bram);
        end
    end

    always @(posedge clk) begin
        data_out <= bram[addr];
    end
endmodule