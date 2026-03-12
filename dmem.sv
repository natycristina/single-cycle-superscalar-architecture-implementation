
//
// dmem.sv : memoria de dados
//
// Simulacao: Waverform8.vwf
//
// Funciona como memora RAM (leitura e escrita).
// -lê uma porta combinacionalmente (a/rd)
//   ou grava essa porta na borda de subida do clock (a/wd/we)
// -word aligned - leitura em endereços múltiplos de 4

// Capacidade de armazenamento: 64 posicoes de 32 bits.)
//

module dmem(input logic clk, we,
				input logic [31:0] a, wd,
				output logic [31:0] rd);
	
	logic [31:0] RAM[63:0];
	
	assign rd = RAM[a[31:2]]; // word aligned 
	
	always_ff @(posedge clk)
		if (we) RAM[a[31:2]] <= wd;
		
endmodule