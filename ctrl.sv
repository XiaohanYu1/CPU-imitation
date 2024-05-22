module ctrl (
    input logic clk, rst,
    input logic [15:0] instruction,
    input logic [31:0] rf_r1_out, rf_r2_out,
    input logic [3:0] alu_flags,

    output logic [3:0] r1addr, r2addr,
    output logic rf_wen,
    output logic [3:0] waddr,
    output logic [3:0] aluop,
    output logic [31:0] alu_in1, alu_in2,
    output logic [15:0] pc, next_pc
);

    // in one clock cycle, we will:
    // decode instruction into {opc, rd (branch dest/dest reg), rs1, rs2}
    // read rs1 and rs2 from register file
    // execute the instruction on rs1 and rs2 (or imm if applicable)
    //   for branches, add relative offset to PC register
    // write the result to rs1 in register file

    logic [3:0] rs1, rs2, rd, opc;
    assign {opc, rd, rs1, rs2} = instruction;

    logic N, Z, C, V;
    assign {N,Z,C,V} = alu_flags;

    always_ff @(posedge clk, posedge rst)
        if (rst)
            pc <= 0;
        else
            pc <= next_pc;

    always_comb begin
        case(opc)
            0, 1, 2, 3, 4, 5: begin
                next_pc = pc + 1;
            end
            6,7,8,9: begin
                if ((opc == 6 && Z) || (opc == 7 && ~Z) || (opc == 8 && N) || (opc == 9 && (~N && ~Z))) begin
                    next_pc = pc + {12'b0, rd};
                    next_pc[15:4] = 0;
                end
                else
                    next_pc = pc + 1;
            end
        endcase
    end

    always_latch begin
        case(opc)
            0,1,2: begin
                // add r1, r2, r3
                r1addr = rs1;
                r2addr = rs2;
                rf_wen = 1'b1;
                waddr = rd;
                aluop = opc;
                alu_in1 = rf_r1_out;
                alu_in2 = rf_r2_out;
            end
            3,4,5: begin
                // addi r1, r2, 3
                r1addr = rs1;
                r2addr = rs2;
                rf_wen = 1'b1;
                waddr = rd;
                aluop = opc - 3;
                alu_in1 = rf_r1_out;
                alu_in2 = {28'b0, rs2};
            end
            6,7,8,9: begin
                // beq r1, r3, loop ()
                r1addr = rs1;
                r2addr = rs2;
                rf_wen = 1'b0;
                waddr = 0;
                aluop = 1;
                alu_in1 = rf_r1_out;
                alu_in2 = rf_r2_out;
            end
        endcase
    end
endmodule


/*
    logic [3:0] rs1, rs2, op2, opc;
    assign {rs1, rs2, op2, opc} = instruction;

    logic will_branch;
    logic N, Z, C, V;
    assign {N, Z, C, V} = alu_flags;
    
    always_ff @(posedge clk, posedge rst) begin : fetch
        if (rst) begin
            pc <= 0;
        end
        else begin
            pc <= next_pc;
        end
    end
    
    always_comb begin : decode_n_execute
        will_branch = 0;
        case(opc)
            0,1,2: begin
                r1addr = rs1; r2addr = rs2; aluop = op2; waddr = rs1;
                next_pc = pc + 16'h2;
                rf_wen = 1;
            end
            3,4,5: begin
                r1addr = rs1; aluop = op2; waddr = rs1;
                next_pc = pc + 16'h2;
                rf_wen = 1;
            end
            6,7,8,9: begin
                r1addr = rs1; r2addr = rs2; aluop = 1;   // sub
                will_branch = (opc == 6 && Z) || (opc == 7 && ~Z) || 
                                (opc == 8 && N) || (opc == 9 && (!N || Z));

                if (will_branch)
                    if (op2[3])
                        next_pc = pc - {13'b0, op2[2:0]};
                    else
                        next_pc = pc + {13'b0, op2[2:0]};
                else
                    next_pc = pc + 2;
                rf_wen = 0;
            end
            default: begin
                // WHAT?
            end
        endcase
    end

    assign alu_in1 = rf_r1_out;
    assign alu_in2 = (opc == 3 || opc == 4 || opc == 5) ? {28'b0, rs2} : rf_r2_out; 
*/