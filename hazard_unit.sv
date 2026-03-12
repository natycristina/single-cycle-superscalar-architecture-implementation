module hazard_unit(
    // Entradas da Instrução 1 (Instr0 no Datapath)
    input  logic [6:0] inst1_op,
    input  logic [4:0] inst1_rs1,
    input  logic [4:0] inst1_rs2,
    input  logic [4:0] inst1_rd,
    input  logic       inst1_is_muldiv_op,
    input  logic       inst1_reg_write,

    // Entradas da Instrução 2 (Instr1F no Datapath)
    input  logic [6:0] inst2_op,           
    input  logic [4:0] inst2_rs1,
    input  logic [4:0] inst2_rs2,
    input  logic [4:0] inst2_rd,
    input  logic       inst2_is_muldiv_op,

    // Saídas de Controle
    output logic dual_ok,
    output logic flush_instr2
);

    // Detecta branch/jump
    logic inst1_is_branch_or_jump;
    logic inst2_is_branch_or_jump;
	 logic inst1_is_mem_op;
	 logic inst2_is_mem_op;

	 assign inst1_is_mem_op = (inst1_op == 7'b0000011) || (inst1_op == 7'b0100011);
	 assign inst2_is_mem_op = (inst2_op == 7'b0000011) || (inst2_op == 7'b0100011);


    always_comb begin
        // Detecta opcodes de branch e jump
        inst1_is_branch_or_jump =
            (inst1_op == 7'b1100011) ||  // BEQ, BNE, etc.
            (inst1_op == 7'b1101111) ||  // JAL
            (inst1_op == 7'b1100111);    // JALR

        inst2_is_branch_or_jump =
            (inst2_op == 7'b1100011) ||  // BEQ, BNE, etc.
            (inst2_op == 7'b1101111) ||  // JAL
            (inst2_op == 7'b1100111);    // JALR

        // Valores padrão
        dual_ok = 1'b1;
        flush_instr2 = 1'b0;

        // --- Regras de serialização ---

        // Se a primeira é branch/jump → sozinha
        if (inst1_is_branch_or_jump) begin
            dual_ok = 1'b0;
            flush_instr2 = 1'b1;
        end

        //Se a segunda é branch/jump → também deve executar sozinha
        else if (inst2_is_branch_or_jump) begin
            dual_ok = 1'b0;
            flush_instr2 = 1'b1;
        end

        // --- Outras dependências ---
        else begin
            // RAW hazard
            if ((inst1_reg_write && inst1_rd != 5'd0) &&
                ((inst2_rs1 == inst1_rd) || (inst2_rs2 == inst1_rd))) begin
                dual_ok = 1'b0;
                flush_instr2 = 1'b1;
            end

            // WAW hazard
            if ((inst1_reg_write && inst1_rd != 5'd0) &&
                (inst1_rd == inst2_rd)) begin
                dual_ok = 1'b0;
                flush_instr2 = 1'b1;
            end

            // Estrutural (memória)
            if (inst1_is_mem_op && inst2_is_mem_op) begin
                dual_ok = 1'b0;
                flush_instr2 = 1'b1;
            end

            // Estrutural (mul/div)
            if (inst1_is_muldiv_op && inst2_is_muldiv_op) begin
                dual_ok = 1'b0;
                flush_instr2 = 1'b1;
            end
        end
    end

endmodule
