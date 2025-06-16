module maindecoder (
    input  [5:0] op,
    output       memtoreg,
    output       memwrite,
    output       branch,
    output       alusrc,
    output       regdst,
    output       regwrite,
    output       jump,
    output [1:0] aluop
);

    reg [8:0] controls;

    // Control word layout:
    // {regwrite, regdst, alusrc, branch, memwrite, memtoreg, jump, aluop[1:0]}
    assign {regwrite, regdst, alusrc, branch, memwrite, memtoreg, jump, aluop} = controls;

    always @(*) begin
        case (op)
            6'b000000: controls = 9'b110000010; // R-type
            6'b100011: controls = 9'b101001000; // LW
            6'b101011: controls = 9'b001010000; // SW
            6'b000100: controls = 9'b000100001; // BEQ
            6'b001000: controls = 9'b101000000; // ADDI
            6'b000010: controls = 9'b000000100; // JUMP
            default:   controls = 9'bxxxxxxxxx; // Undefined
        endcase
    end

endmodule

