module top_dual (
    input  logic        clk, reset,
	 output logic [31:0] PC_DBG,
	 output logic [31:0] Instr0_DBG, Instr1_DBG,
    output logic [31:0] WriteData0, DataAdr0, WriteData1, DataAdr1,
    output logic        MemWrite0, MemWrite1
);

  logic [31:0] PC, Instr0, Instr1;
  logic [31:0] ReadData0, ReadData1;

  // === CPU dual-issue ===
  riscvsingle_dual cpu(
      .clk(clk), .reset(reset),
      .PC(PC),
      .Instr0(Instr0), .Instr1(Instr1),
      .MemWrite0(MemWrite0), .MemWrite1(MemWrite1),
      .ALUResult0(DataAdr0), .ALUResult1(DataAdr1),
      .WriteData0(WriteData0), .WriteData1(WriteData1),
      .ReadData0(ReadData0), .ReadData1(ReadData1)
  );

  // === Memória de instruções ===
  imem_dual imem(
      .a  (PC),
      .rd1(Instr0),
      .rd2(Instr1)
  );

  // ============================
  // === MEMÓRIA DE DADOS ÚNICA ===
  // ============================

  // Sinais de acesso multiplexados
  logic        mem_we;
  logic [31:0] mem_addr, mem_wdata, mem_rdata;

  // Escolhe qual instruções acessa a memória
  // Prioridade: se a instruçõeso 0 for de memória até ela usa a RAM
  // caso contrário, se a instrução 1 for de memória até ela usa a RAM
  always_comb begin
    if (MemWrite0 || (DataAdr0[31:2] != 0 && MemWrite1 == 0)) begin
      // acesso da instrução 0
      mem_we     = MemWrite0;
      mem_addr   = DataAdr0;
      mem_wdata  = WriteData0;
      // leitura devolve para porta 0
      ReadData0  = mem_rdata;
      ReadData1  = 32'b0;   // sem leitura para a instrução 1
    end else begin
      // acesso da instrução 1
      mem_we     = MemWrite1;
      mem_addr   = DataAdr1;
      mem_wdata  = WriteData1;
      ReadData0  = 32'b0;
      ReadData1  = mem_rdata;
    end
  end

  // Instância única de memória
  dmem dmem0(
      .clk(clk),
      .we(mem_we),
      .a (mem_addr),
      .wd(mem_wdata),
      .rd(mem_rdata)
  );
  
  assign PC_DBG = PC;
  assign Instr0_DBG = Instr0;
  assign Instr1_DBG = Instr1;

endmodule
