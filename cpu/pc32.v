`include "defines.v"

module pc32
    (ib, bv,
    we, wd,
    iaddrout, reset,
    r_en, mod_en,
    clk);
    // is branch, branch value,
    // write enable, write data
    // instruction (address) out, clock
    // enable

    input signed [`FULLW-1:0] bv, wd;
    input ib, clk, we, reset, r_en, mod_en;
    output reg [`FULLW-1:0] iaddrout;

    reg signed [`FULLW-1:0] ctr;

    always @(posedge clk) begin
        if (mod_en) begin
            if (reset) begin
                ctr <= 0;
            end
            else if (we) begin
                ctr <= wd;
            end
            else begin
                if (ib) ctr <= ctr + bv + 8; // TO-DO: REMOVE FOR LAB 3
                else ctr <= ctr + 4;
            end
        end
        else ctr <= ctr;
        // emit last value if not enabled
        if (r_en) iaddrout <= ctr;
        else iaddrout <= iaddrout;
    end

endmodule