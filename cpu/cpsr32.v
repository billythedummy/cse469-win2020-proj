module cpsr32
    (we, flagsin, out, clk);
    // write enable, flags in, out, clock
    input we, clk;
    input [3:0] flagsin;
    output reg [31:0] out;

    reg [7:0] register [0:3];

    integer index;
    always @(posedge clk) begin
        if (we) begin
            register[0][7:4] <= flagsin; // big endian
        end
        for (index=0; index<4; index=index+1) begin
            out[(4-index-1)*8 +: 8] <= register[index];
        end
    end

    // LAB 1 CPSR
    initial $readmemh("testcode/hexcode_tests/lab1_cpsr.mem", register);

endmodule