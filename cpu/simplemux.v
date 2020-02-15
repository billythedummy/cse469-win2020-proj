// Simple 2:1 Mux

module simplemux #(parameter WIDTH=8) (out, in1, in2, sel);
    output reg [WIDTH-1:0] out;
    input [WIDTH-1:0] in1;
    input [WIDTH-1:0] in2;
    input sel;

    always @(*) begin
        if (sel)
            out = in2;
        else
            out = in1;
    end
endmodule