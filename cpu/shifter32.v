`include "defines.v"

module shifter32
    (shiftby, shiftin, shiftcode,
    cflag,
    out, carryout);
    
    input signed [`FULLW-1 : 0] shiftin;
    input [`WIDTH-1 : 0] shiftby;
    input [`SHIFTCODEW-1 : 0] shiftcode;
    input cflag;
    output reg [`FULLW-1 : 0] out;
    output reg carryout;

    always @(*) begin
        case (shiftcode)
            `LSL: begin
                out = shiftin << shiftby;
                if (shiftby != 0) begin 
                    carryout = shiftin[`FULLW - shiftby];
                end
                else begin
                    carryout = cflag; 
                end
            end
            `LSR: begin
                if (shiftby != 0) begin 
                    out = shiftin >> shiftby;
                    carryout = shiftin[shiftby - 1];
                end
                else begin // shiftby 0 in LSR case means shift by 32
                    carryout = shiftin[`FULLW-1];
                    out = 0;
                end
            end
            `ASR: begin
                if (shiftby != 0) begin 
                    carryout = shiftin[shiftby - 1];
                    out = shiftin >>> shiftby;
                end
                else begin // shiftby 0 in ASR case means shift by 32
                    carryout = shiftin[`FULLW-1];
                    if (shiftin[`FULLW-1]) out = {`FULLW{1'b1}};
                    else out = 0;
                end
            end
            `ROR: begin
                if (shiftby != 0) begin 
                    out = (shiftin >> shiftby) | (shiftin << (`FULLW-shiftby));
                    carryout = out[`FULLW-1];
                end
                else begin // shiftby 0 in ROR case is RRX
                    out = ({31'b0, cflag} << (`FULLW-1)) | (shiftin >> 1);
                    carryout = shiftin[0]; 
                end
            end
        endcase
    end

endmodule