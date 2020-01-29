module dff (d, q, clk);
    input d, clk;
    output q;

    always @(posedge clk) begin
        q <= d;
    end
endmodule