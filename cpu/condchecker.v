module condchecker
    (codein, cpsrin, shouldexecout);

    // CPSR: 0 - Zero, 1 - Carry, 2 - Negative, 3 - oVerflow
    input [3:0] codein, cpsrin;

    output reg shouldexecout;

    wire Z, C, N, V, sel;
    assign Z = cpsrin[0];
    assign C = cpsrin[1];
    assign N = cpsrin[2];
    assign V = cpsrin[3];
    assign sel = codein[0];
    wire [2:0] code;
    assign code = codein[3:1];

    always @(*) begin
        if (codein == 4'b1110) begin //Always
            shouldexecout = 1;
        end
        else if (code == 3'b0) begin //Equal and Not equal
            shouldexecout = sel ^ Z;
        end
        else if (code == 3'b001) begin // Carry set/ unsigned higher or same and Carry clear/ unsigned lower
            shouldexecout = sel ^ C;
        end
        else if (code == 3'b010) begin // Negative and Positive
            shouldexecout = sel ^ N;
        end
        else if (code == 3'b011) begin // Overflow and No Overflow
            shouldexecout = sel ^ V;
        end
        else if (code == 3'b100) begin // Unsigned Higher and Unsigned lower or same
            shouldexecout = sel ^ (C & ~Z); 
        end
        else if (code == 3'b101) begin // Signed Greater Than or Equal and Signed less than
            shouldexecout = sel ^ (N == V); 
        end
        else if (code == 3'b110) begin // Signed Greater Than and Signed Less Than or Equal
            shouldexecout = sel ^ (~Z & N == V); 
        end
    end

endmodule