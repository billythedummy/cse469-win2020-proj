`include "defines.v"

module pc32
    (ib, bv,
    we, wd,
    iaddrout, reset,
    clk, en);
    // is branch, branch value,
    // write enable, write data
    // instruction (address) out, clock
    // enable

    input signed [`FULLW-1:0] bv, wd;
    input ib, clk, we, reset, en;
    output reg [`FULLW-1:0] iaddrout;

    reg signed [`FULLW-1:0] ctr;

    always @(posedge clk) begin
        if (en) begin
            if (reset) begin
                ctr <= 0;
            end
            else if (we) begin
                ctr <= wd;
            end
            else begin
                if (ib) ctr <= ctr + bv;
                else ctr <= ctr + 4;
            end
            iaddrout <= ctr;
        end
        else iaddrout <= 0;
    end

endmodule