// Simple 2:1 Mux

module simplemux #(parameter width=8) (out, in1, in2, sel);
    output reg [width-1:0] out;
    input [width-1:0] in1;
    input [width-1:0] in2;
    input sel;

    always_comb begin
        if (sel)
            out = in2;
        else
            out = in1;
    end
endmodule