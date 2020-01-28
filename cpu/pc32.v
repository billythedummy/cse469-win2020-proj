module pc32
    (ib, bv,
    we, wd,
    iout, clk);
    // is branch, branch value,
    // write enable, write data
    // instruction (address) out, clock

    input [31:0] bv, wd;
    input ib, clk, we;
    output reg [31:0] iout;

    reg [31:0] ctr;

    always @(posedge clk) begin
        // write enable has highest precedence
        if (we) begin
            ctr <= wd;
        end
        else if (ib) begin
            ctr <= ctr + bv;
        end
        else begin
            ctr <= ctr + 4;
        end
        iout <= ctr;
    end

endmodule