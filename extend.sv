//
// extend.sv : extensão de sinal p/ 32 bits
//
// Simulação: Waverform3.vwf
//


module extend(input logic [31:7] instr,
				input logic [1:0] immsrc,
				output logic [31:0] immext);
				
	always_comb
		case(immsrc)
		// I−type
		2'b00: immext = {{20{instr[31]}}, instr[31:20]};  
		// S−type (stores)
		2'b01: immext = {{20{instr[31]}}, instr[31:25], instr[11:7]};
		// B−type (branches)
		2'b10: immext = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
		// J−type (jal)
		2'b11: immext = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
		
		default: immext = 32'bx; // undefined
	endcase
endmodule




// Instruções de máquina referentes a programa riscv-inst-immm.asm
//   p/ uso em simulação quartus de bloco extend.vs
//
// ffc3a303   --> lw x6, -4(x7)          Tipo-I immsrc= 00

// 0043ae03   --> lw x28, 4(x7)           Tipo-I immsrc= 00

// 002e8e93   --> add1 x29, x29, 2       Tipo-I immsrc= 00

// 01d3a423   --> sw x29, 8(x7)           Tipo-S immsrc= 01


// 000e8e63   --> beq x29, x0, 28       Tipo-B immsrc= 10

// 008000ef   --> jal x1, 8   (jal printResult)      Tipo-J immsrc= 11

// 0140006f   --> jal x0, 20  (j fimPrograma)        Tipo-J immsrc= 11
