module regfile
    #(parameter WORD=4,
        parameter WIDTH=8,
        parameter ADDR_WIDTH=4) 
    (in1, in2,
    we, wd, wa,
    out1, out2,
    pt, clk); 
    // input1, input2
    // write-enable, write-data (register write back), write-address, write enable
    // output1, output2
    // passthrough value, clock

    // might need a b line for ldrb

    input [ADDR_WIDTH*WIDTH-1:0] in1, in2;
    //input [ADDR_WIDTH*WIDTH-1:0] in2;

    input we, pt;
    input [WORD*WIDTH-1:0] wd;
    input [ADDR_WIDTH*WIDTH-1:0] wa;

    output reg [WORD*WIDTH-1:0] out1, out2;
    //output reg [WORD*WIDTH-1:0] out2;
    input clk;

    reg [(1 << ADDR_WIDTH) - 1:0][WIDTH-1:0] mem;

    always_ff @(posedge clk) begin
        // write
        if (we) begin
            mem[ wa +: WORD ] <= wd;
        end

        if (pt) begin
            out2 <= in2;
        end
        else begin
            out2 <= mem[in2 +: WORD];
        end
        out1 <= mem[in1 +: WORD];
    end
endmodule