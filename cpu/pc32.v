`include "defines.v"

module pc32
    (ib, bv,
    we, wd,
    iaddrout, reset,
    mod_en, clk);
    // is branch, branch value,
    // write enable, write data
    // instruction (address) out, clock
    // enable

    input signed [`FULLW-1:0] bv, wd;
    input ib, clk, we, reset, mod_en;
    output reg [`FULLW-1:0] iaddrout;

    reg signed [`FULLW-1:0] ctr;

    always @(posedge clk) begin
        if (reset) ctr <= 0;
        else if (mod_en) begin
            if (we) begin
                ctr <= wd;
            end
            else begin
                if (ib) ctr <= iaddrout + bv;
                else ctr <= ctr + 4;
            end
            iaddrout <= ctr;
        end
        else iaddrout <= iaddrout;
    end

endmodule