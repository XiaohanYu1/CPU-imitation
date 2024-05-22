module core (
    input logic clk, rst,
    output logic [255:0] debug
);

    logic [15:0] instruction;
    logic [31:0] rf_r1_out, rf_r2_out;
    logic [3:0] alu_flags;
    logic [3:0] r1addr, r2addr;
    logic rf_wen;
    logic [3:0] waddr;
    logic [3:0] aluop;
    logic [31:0] alu_in1, alu_in2;
    logic [15:0] pc, next_pc;

    assign debug[15:0] = instruction;

    ctrl cl (
        .clk(clk), .rst(rst), .instruction(instruction),
        .rf_r1_out(rf_r1_out), .rf_r2_out(rf_r2_out),
        .r1addr(r1addr), .r2addr(r2addr), .rf_wen(rf_wen), .waddr(waddr),
        .aluop(aluop), .alu_in1(alu_in1), .alu_in2(alu_in2), .alu_flags(alu_flags),
        .pc(pc), .next_pc(next_pc)
    );

    logic [31:0] alu_out;
    alu a (
        .clk(clk), .rst(rst),
        .a(alu_in1), .b(alu_in2), .alu_op(aluop), .out(alu_out),
        .N(alu_flags[3]), .Z(alu_flags[2]), 
        .C(alu_flags[1]), .V(alu_flags[0])
    );

    regfile rf (
        .clk(clk), .rst(rst), .wen(rf_wen), 
        .r1(r1addr), .r2(r2addr), .w(waddr),
        .wdata(alu_out), .r1data(rf_r1_out), .r2data(rf_r2_out)
    );

    // not using any other ports just yet.
    /* verilator lint_off PINMISSING */
    mem m (
        .clk(clk), .rst(rst), 
        .raddr1(pc), .rdata1(instruction)
    );

endmodule