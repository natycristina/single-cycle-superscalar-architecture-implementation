module regfile_dual(
    input  logic        clk,
    input  logic        we1, we2,
    input  logic [4:0]  a1, a2, a3, a4,  // 4 leituras
    input  logic [4:0]  wdA, wdB,        // 2 destinos
    input  logic [31:0] wd1, wd2,        // 2 dados
    output logic [31:0] rd1, rd2, rd3, rd4
);
    logic [31:0] rf[31:0];

    // Escrita dupla
    always_ff @(posedge clk) begin
        if (we1 && wdA != 0) rf[wdA] <= wd1;
        if (we2 && wdB != 0 && wdB != wdA) rf[wdB] <= wd2;
    end

    assign rd1 = (a1 != 0) ? rf[a1] : 0;
    assign rd2 = (a2 != 0) ? rf[a2] : 0;
    assign rd3 = (a3 != 0) ? rf[a3] : 0;
    assign rd4 = (a4 != 0) ? rf[a4] : 0;

endmodule
