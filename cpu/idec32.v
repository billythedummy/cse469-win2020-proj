module idec32  //instruction decoder
    (iin, cpsrin, ispb,
    alu_out, rn_out, rd_out,
    cpsrs_out, reg_we, mem_we,
    ib, bv, bl);
    // instruction in, CPSR in, is previous instruction branch in
    // ALU out, Rn out, Rd out, 
    // should set CPSR out, register write enable, memory write enable,
    // instruction branch out, branch value out, branch should link (store in r14)
    // clock

    input [31:0] iin;
    input ispb;
    input [3:0] cpsrin;
    output reg [3:0] alu_out, rn_out, rd_out;
    output reg cpsrs_out, reg_we, mem_we, ib, bl;
    output reg [31:0] bv;

    wire [2:0] opcode;
    wire shouldexec;
    assign opcode = iin[27:25];

    condchecker check (.codein(iin[31:28]), .cpsrin(cpsrin), .shouldexecout(shouldexec));

    always @(*) begin
        // no-op if not passed
        alu_out = 4'b0;
        rn_out = 4'b0;
        rd_out = 4'b0;
        cpsrs_out = 0;
        reg_we = 0;
        mem_we = 0;
        ib = 0;
        bl = 0;
        bv = 32'b0;
        // cond code passed
        if (shouldexec && iin != 32'b0 && !ispb) begin
            case (opcode)
                3'b000: begin // logical/arithmetic
                    // I bit is CONTROL BIT see manual
                    // TO-DO: 12 bit shifter handling
                    alu_out = iin[24:21];
                    rn_out = iin[19:16];
                    rd_out = iin[15:12];
                    cpsrs_out = iin[20];
                    reg_we = 1;
                    mem_we = 0;
                    ib = 0;
                    bl = 0;
                    bv = 32'b0;
                end
                3'b010: begin // load/store
                    // TO-DO: 12 bit shifter handling
                    alu_out = iin[24:21]; // THIS SHOULD BE PASSTHROUGH CODE FOR ALU
                    rn_out = iin[19:16];
                    rd_out = iin[15:12];
                    cpsrs_out = 0; // LOAD STORE DOES NOT CHANGE CPSR FLAGS: http://infocenter.arm.com/help/index.jsp?topic=/com.arm.doc.dui0552a/BABFGBDD.html
                    reg_we = iin[20]; // include or post increment?
                    mem_we = ~iin[20];
                    ib = 0;
                    bl = 0;
                    bv = 32'b0;
                end
                3'b101: begin // branch
                    // This takes 2 cycles so when this is done, PC = PC + 8
                    alu_out = 4'b0;
                    rn_out = 4'b0;
                    rd_out = 4'b0;
                    cpsrs_out = 0;
                    reg_we = 0; // might need to change this
                    mem_we = 0;
                    ib = 1;
                    bl = iin[24];
                    bv = {{6{iin[23]}}, iin[23:0], 2'b0}; // 32 bit
                end
                default: begin // not sure/ unsupported, just no-op
                    alu_out = 4'b0;
                    rn_out = 4'b0;
                    rd_out = 4'b0;
                    cpsrs_out = 0;
                    reg_we = 0;
                    mem_we = 0;
                    ib = 0;
                    bl = 0;
                    bv = 32'b0;
                end
            endcase
        end
    end


endmodule