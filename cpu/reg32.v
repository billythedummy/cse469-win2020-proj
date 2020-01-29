module reg32
    (in1, in2,
    we, wd, wa,
    out1, out2,
    ib, bv, bl, iaddrout,
    reset, clk); 
    // input1, input2
    // write-enable, write-data (register write back), write-address
    // output1, output2,
    // isBranch, branchValue, branch should link, instruction out
    // reset clock

    // might need a b line for ldrb

    // default last addr (r15 in this case) is PC

    input [3:0] in1, in2, wa;
    input we, ib, clk, bl, reset;
    input [31:0] wd, bv;

    output reg [31:0] out1, out2, iaddrout;

    reg [7:0] mem [0:15*4-1]; // not including pc (own module)
    wire ispc; // is write for program counter
    assign ispc = we & (wa == 15); 
    pc32 pc (.ib(ib), .bv(bv), .we(ispc), .wd(wd), .iaddrout(iaddrout), .clk(clk), .reset(reset));

    integer index;
    always @(posedge clk) begin
        // no reset for other registers..
        // write
        if (we & !ispc) begin
            for (index=0; index<4; index=index+1) begin
                mem[ {28'b0, wa}*4 + index] <= wd[(4-index-1)*8 +: 8];
            end
        end
        // out
        for (index=0; index<4; index=index+1) begin
            out2[(4-index-1)*8 +: 8] <= mem[{28'b0, in2}*4 + index];
        end
        for (index=0; index<4; index=index+1) begin
            out1[(4-index-1)*8 +: 8] <= mem[{28'b0, in1}*4 + index];
        end
    end

    // LAB 1 REGISTERS
    initial $readmemh("testcode/hexcode_tests/lab1_reg.mem", mem);
endmodule