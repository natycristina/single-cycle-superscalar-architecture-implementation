module imem_dual(
    input  logic [31:0] a,
    output logic [31:0] rd1, rd2
);
    logic [31:0] RAM[63:0];

    initial $readmemh("hexa_de_todas.txt", RAM);
	//initial $readmemh("WAW.txt", RAM);
	 

    assign rd1 = RAM[a[31:2]];
    assign rd2 = RAM[a[31:2] + 1];  // proxima instrucao

endmodule
