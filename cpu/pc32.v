module pc32
    (ib, bv,
    we, wd,
    iaddrout, reset,
    clk);
    // is branch, branch value,
    // write enable, write data
    // instruction (address) out, clock

    input [31:0] bv, wd;
    input ib, clk, we, reset;
    output reg [31:0] iaddrout;

    reg [31:0] ctr;

    always @(posedge clk) begin
        if (reset) ctr <= 0;
        else if (we) ctr <= wd;
        else if (ib) ctr <= ctr + bv;
        else ctr <= ctr+4;
        iaddrout <= ctr;
    end

endmodule