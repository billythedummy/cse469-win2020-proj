`include "defines.v"

module shifterdec
    (optype, in,
    rm, bypass_rm, should_bypass_rm, shiftcode, shiftby);

    input [`OP_TYPE_W-1 : 0] optype;
    input [`SHIFTER_OPERAND_W-1 : 0] in;

    output reg [`REGAW-1:0] rm;
    output reg [`FULLW-1:0] bypass_rm;
    output reg should_bypass_rm;
    output reg [`SHIFTCODEW-1:0] shiftcode;
    output reg [`WIDTH-1:0] shiftby; // actually only 5 bits, but verilog shifts can only operate on 8/32 bits

    always @(*) begin
        case (optype)
            `OP_DATA_SHIFT: begin
                rm = in[0 +: `REGAW];
                bypass_rm = 0; // dont care
                should_bypass_rm = 0;
                shiftcode = in[`SHIFTCODE_START +: `SHIFTCODEW];
                shiftby = {{(`WIDTH-`SHIFTIMM_W){1'b0}}, in[`SHIFTIMM_START +: `SHIFTIMM_W]};
            end
            `OP_DATA_ROR: begin
                rm = 0; // dont care
                bypass_rm = {{(`FULLW-`WIDTH){1'b0}}, in[0+:`WIDTH]};
                should_bypass_rm = 1;
                shiftcode = `ROR;
                shiftby = {{(`WIDTH-`RORIMM_W){1'b0}}, in[`RORIMM_START +: `RORIMM_W]};
            end
            `OP_LDSTR_IMM: begin
                rm = 0; // dont care
                bypass_rm = {{(`FULLW-`SHIFTER_OPERAND_W){1'b0}}, in};
                should_bypass_rm = 1;
                shiftcode = `LSL; //only LSL shiftby 0 has no special meaning and is PASS
                shiftby = 0;
            end
            `OP_LDSTR_REG: begin
                rm = in[0 +: `REGAW];
                bypass_rm = 0; // dont care
                should_bypass_rm = 0;
                shiftcode = in[`SHIFTCODE_START +: `SHIFTCODEW];
                shiftby = {{(`WIDTH-`SHIFTIMM_W){1'b0}}, in[`SHIFTIMM_START +: `SHIFTIMM_W]};
            end
            default: begin 
                // branch, dont care bec not handled by ALU
                rm = 0;
                bypass_rm = 0;
                should_bypass_rm = 0;
                shiftcode = 0;
                shiftby = 0;
            end
        endcase
    end

endmodule