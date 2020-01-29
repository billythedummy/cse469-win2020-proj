module pc32
    (ib, bv,
    we, wd,
    iaddrout, reset,
    clk);
    // is branch, branch value,
    // write enable, write data
    // instruction (address) out, clock

    input signed [31:0] bv, wd;
    input ib, clk, we, reset;
    output reg [31:0] iaddrout;

    reg signed [31:0] wdff;
    reg signed [31:0] ctr;

    always @(posedge clk) begin
        wdff <= wd;
        if (reset) begin
            iaddrout <= 0;
            ctr <= 0;
            wdff <= 0;
        end
        else if (we) begin
            ctr <= wdff;
            iaddrout <= wdff;
        end
        else begin
            if (ib) ctr <= ctr + bv;
            else ctr <= ctr + 4;
            iaddrout <= ctr;
        end
    end

endmodule