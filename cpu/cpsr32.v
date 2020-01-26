module cpsr32
    (we, flagsin, out, clk);
    // write enable, flags in, out, clock
    input we, clk;
    input [3:0] flagsin;
    output reg [31:0] out;

    reg [31:0] register;

    always @(posedge clk) begin
        if (we) begin
            register[31:28] <= flagsin;
        end
        out <= register;
    end

endmodule