//
// alu.sv : unidade logica-aritmetica p/ algumas instrucoes
//
// Simulação: Waverform9.vwf

module alu(input  logic [31:0] a, b,
           input  logic [3:0]  alucontrol,
           output logic [31:0] result,
           output logic        zero,
           output logic        LT);

  logic [31:0] condinvb, sum;
  logic        v;              // overflow
  logic        isAddSub;       // true when is add or subtract operation

  assign condinvb = alucontrol[0] ? ~b : b;
  assign sum = a + condinvb + alucontrol[0];
  assign isAddSub = ~alucontrol[2] & ~alucontrol[1] |
                    ~alucontrol[1] & alucontrol[0];

  always_comb
    case (alucontrol)
      4'b0000:  result = sum;              // add, addi
      4'b0001:  result = sum;              // subtract
      4'b0010:  result = a & b;            // and, andi
      4'b0011:  result = a | b;            // or, ori
      4'b0100:  result = a << b[4:0];      // sll (logical shift left)
      4'b0101:  result = sum[31] ^ v;      // slt, slti
      4'b0110:  result = a ^ b;            // xor, xori
      4'b0111:  result = a >> b[4:0];      // srl (logical shift right)
      4'b1000:  result = a * b;            // mul
      4'b1001:  result = (b == 0) ? 32'hFFFFFFFF : a / b;  // div com proteção
      default:  result = 32'bx;
    endcase

  assign zero = (result == 32'b0);
  assign v = ~(alucontrol[0] ^ a[31] ^ b[31]) & (a[31] ^ sum[31]) & isAddSub;
  assign LT = sum[31] ^ v;     // LT é verdadeiro se SLT gerar 1
endmodule