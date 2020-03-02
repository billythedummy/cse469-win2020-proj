`include "defines.v"

localparam EQ = 3'b000;
localparam CARRY = 3'b001;
localparam NEG = 3'b010;
localparam OVER = 3'b011;
localparam UNSIGNED = 3'b100;
localparam SIGNED_GTE = 3'b101;
localparam SIGNED_LTE = 3'b110;
localparam ALWAYS = 3'b111;

module condchecker
    (codein, cpsrin, shouldexecout);

    // CPSR: 0 - V, 1 - C, 2 - Z, 3 - N
    input [`FLAGS_W-1:0] codein, cpsrin;
    output reg shouldexecout;

    wire Ze, C, N, V, sel;
    assign Ze = cpsrin[`Z_i];
    assign C = cpsrin[`C_i];
    assign N = cpsrin[`N_i];
    assign V = cpsrin[`V_i];
    assign sel = codein[0];
    wire [2:0] code;
    assign code = codein[3:1];

    always @(*) begin
        case (code) 
            EQ : shouldexecout = sel ^ Ze; // Eq, Neq
            CARRY : shouldexecout = sel ^ C; // Carry set/ unsigned higher or same and Carry clear/ unsigned lower
            NEG : shouldexecout = sel ^ N; // Negative and Positive
            OVER : shouldexecout = sel ^ V; // Overflow and No Overflow
            UNSIGNED : shouldexecout = sel ^ (C & ~Ze); // Unsigned Higher and Unsigned lower or same
            SIGNED_GTE : shouldexecout = sel ^ ~(N ^ V); // Signed Greater Than or Equal and Signed less than
            SIGNED_LTE : shouldexecout = sel ^ (~Ze & ~(N ^ V)); // Signed Greater Than and Signed Less Than or Equal
            ALWAYS : shouldexecout = 1; //Always
        endcase
    end

endmodule