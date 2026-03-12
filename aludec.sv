module aludec(input  logic       opb5,
              input  logic [2:0] funct3,
              input  logic       funct7b5, 
              input  logic [6:0] funct7,    // ADICIONADO: funct7 completo
              input  logic [1:0] ALUOp,
              output logic [3:0] ALUControl);

  logic RtypeSub;
  logic RtypeMulDiv;  // Nova lógica para MUL/DIV
  
  //Lógica do RtypeSub
  assign RtypeSub = funct7b5 & opb5;  // TRUE for R-type subtract instruction
  
  //Lógica específica para MUL/DIV (funct7 = 0000001)
  assign RtypeMulDiv = (funct7 == 7'b0000001) & opb5;  // MUL/DIV: funct7=0000001, R-type

  always_comb
    case(ALUOp)
      2'b00: 
        ALUControl = 4'b0000; // lw, sw -> ADD
        
      2'b01: begin // Branch instructions
        case (funct3)
          3'b000: ALUControl = 4'b0001; // beq -> sub
          3'b001: ALUControl = 4'b0001; // bne -> sub  
          3'b100: ALUControl = 4'b0101; // blt -> slt
          3'b101: ALUControl = 4'b0101; // bge -> slt
          default: ALUControl = 4'bxxxx;
        endcase
      end
      
      2'b10: begin // R-type instructions
        case(funct3)
          3'b000: begin
            if (RtypeMulDiv)      // MUL: funct3=000, funct7=0000001, R-type
              ALUControl = 4'b1000; // mul
            else if (RtypeSub)    // SUB: funct3=000, funct7b5=1, R-type
              ALUControl = 4'b0001; // sub
            else
              ALUControl = 4'b0000; // add
          end
          3'b001: ALUControl = 4'b0100; // sll
          3'b010: ALUControl = 4'b0101; // slt
          3'b100: begin
            if (RtypeMulDiv)      // DIV: funct3=100, funct7=0000001, R-type
              ALUControl = 4'b1001; // div
            else
              ALUControl = 4'b0110; // xor
          end
          3'b101: begin
            if (~funct7b5)
              ALUControl = 4'b0111; // srl
            else
              ALUControl = 4'bxxxx; // sra não implementado
          end
          3'b110: ALUControl = 4'b0011; // or
          3'b111: ALUControl = 4'b0010; // and
          default: ALUControl = 4'bxxxx;
        endcase
      end
      
      2'b11: begin // I-type ALU instructions
        case(funct3)
          3'b000: ALUControl = 4'b0000; // addi
          3'b001: ALUControl = 4'b0100; // slli
          3'b010: ALUControl = 4'b0101; // slti
          3'b100: ALUControl = 4'b0110; // xori
          3'b110: ALUControl = 4'b0011; // ori
          3'b111: ALUControl = 4'b0010; // andi
          default: ALUControl = 4'bxxxx;
        endcase
      end
      
      default: ALUControl = 4'bxxxx;
    endcase
endmodule