module idec32  //instruction decoder
    (iin, cpsrin,
    alu_out, r1_out, r2_out,
    cpsrs_out, reg_we, mem_we,
    clk);
    // instruction in, CPSR in, ALU out, R1 out, R2 out,
    // should set CPSR out, register write enable, memory write enable,
    // clock

    input [31:0] iin;
    input [3:0] cpsrin;
    output reg [3:0] alu_out, r1_out, r2_out;
    output reg cpsrs_out, reg_we, mem_we;
    input clk;

    wire [3:0] cond_intermediate, icond;
    wire [2:0] opcode;
    assign icond = iin[31:28];
    assign cond_intermediate = cpsrin ~^ icond;
    assign opcode = iin[27:25];

    always_ff @(posedge clk) begin
        // check condition, no-op (output 0) if dont match
        if ( (icond & cond_intermediate) != 0) begin
            alu_out <= 4'b0;
            r1_out <= 4'b0;
            r2_out <= 4'b0;
            cpsrs_out <= 0;
            reg_we <= 0;
            mem_we <= 0;
        end
        else if ( opcode == 3'b00X ) begin // logical/arithmetic
            alu_out <= iin[24:21];
            cpsrs_out <= iin[20];
            r1_out <= iin[19:16];
            r2_out <= iin[15:12];
        end
        else if (opcode == 3'b01X) begin // load/store
            reg_we <= iin[20]; // include or post increment?
            mem_we <= ~iin[20];
            r1_out <= iin[19:16];
            r2_out <= iin[15:12];
        end
        else if (opcode == 3'b101) begin // branch
            
        end
    end


endmodule