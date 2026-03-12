module controller(input  logic [6:0] op,
                  input  logic [2:0] funct3,
                  input  logic       funct7b5,
                  input  logic [6:0] funct7,   
                  input  logic       Zero,
                  input  logic       LT,
                  output logic [1:0] ResultSrc,
                  output logic       MemWrite,
                  output logic       PCSrc, ALUSrc,
                  output logic       RegWrite, Jump,
                  output logic [1:0] ImmSrc,
                  output logic [3:0] ALUControl);

  logic [1:0] ALUOp;
  logic       Branch;

  maindec md(op, ResultSrc, MemWrite, Branch,
             ALUSrc, RegWrite, Jump, ImmSrc, ALUOp);
             
  aludec  ad(op[5], funct3, funct7b5, funct7, ALUOp, ALUControl); // PASSANDO funct7 completo

  assign PCSrc = Jump | (Branch & ((funct3 == 3'b000 && Zero)  ||  // beq
                                   (funct3 == 3'b001 && ~Zero) || // bne
                                   (funct3 == 3'b100 && LT)    || // blt
                                   (funct3 == 3'b101 && ~LT)));   // bge
endmodule