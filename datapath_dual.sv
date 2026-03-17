module datapath_dual(
    input  logic        clk, reset,

    // INSTRUÇÃO 0
    input  logic [1:0]  ResultSrc0, ImmSrc0,
    input  logic        ALUSrc0, RegWrite0, PCSrc0,
    input  logic [4:0]  ALUControl0,

    // INSTRUÇÃO 1
    input  logic [1:0]  ResultSrc1, ImmSrc1,
    input  logic        ALUSrc1, RegWrite1,
    input  logic [4:0]  ALUControl1,

    // outputs
    output logic [31:0] PC,
    output logic        Zero0, LT0,
    output logic        Zero1, LT1,

    // instruções vindas da memória (fetch)
    input  logic [31:0] Instr0F, Instr1F,

    // interface com memória de dados
    input  logic [31:0] ReadData0, ReadData1,
    output logic [31:0] ALUResult0, ALUResult1,
    output logic [31:0] WriteData0, WriteData1
);

  // ======== PC logic ========
  logic [31:0] PCF, PCNext, PCPlus4, PCPlus8, PCTarget; 
  assign PC = PCF;

  // ======== Holding register (Instr1) ========
  //Serve para guardar a Instr1F quando detectamos hazard
  logic        hold_valid;
  logic [31:0] hold_instr;

  // ======== Instruções efetivas ========
  logic [31:0] Instr0, Instr1;
  assign Instr0 = Instr0F;

  // ======== Hazard signals ========
  logic dual_ok, flush1;
  logic stall1;
  assign stall1 = ~dual_ok;

  // ======== Unidade de Hazard ========
    hazard_unit hu (
    .inst1_op (Instr0[6:0]),
    .inst1_rs1(Instr0[19:15]),
    .inst1_rs2(Instr0[24:20]),
    .inst1_rd (Instr0[11:7]),
    .inst1_is_muldiv_op(1'b0),
    .inst1_reg_write(RegWrite0),

    .inst2_op (Instr1F[6:0]),
    .inst2_rs1(Instr1F[19:15]),
    .inst2_rs2(Instr1F[24:20]),
    .inst2_rd (Instr1F[11:7]),
    .inst2_is_muldiv_op(1'b0),

    .dual_ok(dual_ok),
    .flush_instr2(flush1)
);



  // ======== PC increments and branch target ========
  assign PCPlus4 = PCF + 32'd4;
  assign PCPlus8 = PCF + 32'd8;

  logic [31:0] ImmExt0;
  extend ext0_for_pc (Instr0[31:7], ImmSrc0, ImmExt0);
  assign PCTarget = PCF + ImmExt0;

  // ======== NOP instruction ========
  localparam logic [31:0] NOP = 32'h00000013; // addi x0,x0,0

  // ======== Seleção da Instrução 1  ========
  // Se flush1 -> NOP.
  // Se stall1 e NÃO flush1 -> NOP (stalla Instr1).
  // Se hold_valid -> emite a guardada.
  // Caso contrário -> instr1 fetch normal.
  always_comb begin
    if (flush1)
      Instr1 = NOP;
    else if (stall1 && !flush1)
      Instr1 = NOP;          // trava Instr1 durante o stall (ignorado se flush1)
    else if (hold_valid)
      Instr1 = hold_instr;   // usa a guardada
    else
      Instr1 = Instr1F;      // normal
  end

  // ======== Atualização do PC e Holding Register ========
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      PCF        <= 32'b0;
      hold_valid <= 1'b0;
      hold_instr <= 32'b0;
    end else begin
      PCF <= PCNext;

      // prioridade: flush > stall > limpar hold
      if (flush1) begin
        // se há flush, descartamos qualquer instrução guardada IMEDIATAMENTE
        hold_valid <= 1'b0;
        hold_instr <= 32'b0;   // <-- limpeza imediata para evitar ciclo extra
      end
      else if (stall1) begin
        // guarda a Instr1F para emitir no próximo ciclo
        hold_valid <= 1'b1;
        hold_instr <= Instr1F;
      end
      else if (hold_valid) begin
        // havia uma instr guardada e ela foi emitida neste ciclo: agora limpar
        hold_valid <= 1'b0;
      end
      else begin
        hold_valid <= 1'b0;
      end
    end
  end

  // ======== Lógica de avanço do PC ========
  always_comb begin
    if (PCSrc0)
      PCNext = PCTarget;
    else if (stall1)
      PCNext = PCPlus4;
    else
      PCNext = PCPlus8;
  end

  // ======== Register File ========
  logic [31:0] RD0_1, RD0_2, RD1_1, RD1_2;
  logic [31:0] Result0, Result1;

  regfile_dual rf(
    .clk(clk),
    .we1(RegWrite0),
    .we2(RegWrite1),
    .a1(Instr0[19:15]), .a2(Instr0[24:20]),
    .a3(Instr1[19:15]), .a4(Instr1[24:20]),
    .wdA(Instr0[11:7]), .wdB(Instr1[11:7]),
    .wd1(Result0), .wd2(Result1),
    .rd1(RD0_1), .rd2(RD0_2),
    .rd3(RD1_1), .rd4(RD1_2)
  );

  // ======== ALU0 ========
  logic [31:0] SrcA0, SrcB0;
  assign SrcA0 = RD0_1;
  assign WriteData0 = RD0_2;
  assign SrcB0 = (ALUSrc0 ? ImmExt0 : WriteData0);

  alu alu0(SrcA0, SrcB0, ALUControl0, ALUResult0, Zero0, LT0);
  mux3 #(32) resultmux0(ALUResult0, ReadData0, PCPlus4, ResultSrc0, Result0);

  // ======== ALU1 ========
  logic [31:0] ImmExt1, SrcA1, SrcB1;
  extend ext1 (Instr1[31:7], ImmSrc1, ImmExt1);

  assign SrcA1 = RD1_1;
  assign WriteData1 = RD1_2;
  assign SrcB1 = (ALUSrc1 ? ImmExt1 : WriteData1);

  alu alu1(SrcA1, SrcB1, ALUControl1, ALUResult1, Zero1, LT1);
  mux3 #(32) resultmux1(ALUResult1, ReadData1, PCPlus4, ResultSrc1, Result1);

endmodule
