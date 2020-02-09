`include "defines.v"

localparam OP_TYPE_W = 3; 
localparam OP_LOGICAL_SHIFT = 3'b000;
localparam OP_LOGICAL_ROR = 3'b001;
localparam OP_LDSTR = 3'b010;
localparam OP_BRANCH = 3'b101;

module idec32  //instruction decoder
    (iin, cpsrin, ispb,
    alu_out,
    rn_out, rd_out, rm_out,
    bypass_Rm,
    should_bypass_Rm,
    cpsrs_out, reg_we, mem_we,
    shiftcode, shiftby,
    ib, bv, bl);
    // instruction in, CPSR in, is previous instruction branch in
    // ALU out, Rn out, Rd out, 
    // should set CPSR out, register write enable, memory write enable,
    // instruction branch out, branch value out, branch should link (store in r14)
    // clock

    input [`FULLW-1 : 0] iin;
    input ispb;
    input [`FLAGSW-1 : 0] cpsrin;
    output reg [`ALUAW-1 : 0] alu_out;
    output reg [`REGAW-1 : 0] rn_out, rd_out, rm_out;
    output reg cpsrs_out, reg_we, mem_we, ib, bl, should_bypass_Rm;
    output reg [`FULLW-1 : 0] bv, bypass_Rm;
    output reg [`WIDTH-1 : 0] shiftby;
    output reg [`SHIFTCODEW-1 : 0] shiftcode;

    wire [OP_TYPE_W-1 : 0] optype;
    wire shouldexec;
    assign optype = iin[27:25];

    condchecker check (.codein(iin[31:28]), .cpsrin(cpsrin), .shouldexecout(shouldexec));

    always @(*) begin
        // no-op if not passed
        // TO-DO: SHOULD MODIFY FLAGS
        alu_out = 4'b0;
        rn_out = 4'b0;
        rd_out = 4'b0;
        rm_out = 4'b0;
        cpsrs_out = 0;
        reg_we = 0;
        mem_we = 0;
        ib = 0;
        bl = 0;
        should_bypass_Rm = 0;
        bv = 32'b0;
        shiftby = 8'b0;
        bypass_Rm = 32'b0;
        // cond code passed
        if (shouldexec && iin != 32'b0 && !ispb) begin
            case (optype)
                OP_LOGICAL_SHIFT: begin // logical/arithmetic, modifies c flags
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
                OP_LOGICAL_ROR: begin // logical/arithmetic, rotate immediate, shouldnt modify c flags if rotate imm == 0
                    // shifter inputs
                    should_bypass_Rm = 1;
                    shiftcode = `ROR;
                    shiftby = {4'b0, iin[11:8]} << 1; // *2
                    bypass_Rm = {24'b0, iin[7:0]};
                    // alu inputs
                    alu_out = iin[24:21];
                    // regfile inputs
                    rn_out = iin[19:16];
                    rd_out = iin[15:12];
                    // others
                    cpsrs_out = iin[20];
                    reg_we = 1;
                    mem_we = 0;
                    ib = 0;
                    bl = 0;
                    bv = 32'b0;
                end
                OP_LDSTR: begin // load/store
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
                OP_BRANCH: begin // branch
                    // This takes 2 cycles so when this is done, PC = PC + 8
                    alu_out = 4'b0;
                    rn_out = 4'b0;
                    rd_out = 4'b0;
                    cpsrs_out = 0;
                    reg_we = 0; // might need to change this
                    mem_we = 0;
                    ib = 1;
                    bl = iin[24];
                    bv = {{6{iin[23]}}, iin[23:0], 2'b0}; // sign extend and << 2
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