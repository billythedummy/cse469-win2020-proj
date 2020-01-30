`include "defines.v"

module condchecker
    (codein, cpsrin, shouldexecout);

    // CPSR: 0 - Zero, 1 - Carry, 2 - Negative, 3 - oVerflow
    input [3:0] codein, cpsrin;
    output reg shouldexecout;

    wire Ze, C, N, V, sel;
    assign Ze = cpsrin[0];
    assign C = cpsrin[1];
    assign N = cpsrin[2];
    assign V = cpsrin[3];
    assign sel = codein[0];
    wire [2:0] code;
    assign code = codein[3:1];

    always @(*) begin
        case (code) 
            3'b000 : shouldexecout = sel ^ Ze; // Eq, Neq
            3'b001 : shouldexecout = sel ^ C; // Carry set/ unsigned higher or same and Carry clear/ unsigned lower
            3'b010 : shouldexecout = sel ^ N; // Negative and Positive
            3'b011 : shouldexecout = sel ^ V; // Overflow and No Overflow
            3'b100 : shouldexecout = sel ^ (C & ~Ze); // Unsigned Higher and Unsigned lower or same
            3'b101 : shouldexecout = sel ^ ~(N ^ V); // Signed Greater Than or Equal and Signed less than
            3'b110 : shouldexecout = sel ^ (~Ze & ~(N ^ V)); // Signed Greater Than and Signed Less Than or Equal
            3'b111 : shouldexecout = 1; //Always
        endcase
    end

endmodule