 module alu (
input clk, rst,
input [31:0] a, b,
input [3:0] alu_op,
output logic [31:0] out,
output logic N, Z, C, V
);
    always_comb begin : blockName
        case (alu_op)
        4'b0000: out = a + b;
        4'b0001: out = a - b;
        4'b0010: out = a * b;
        default: out = 32'b0;
        endcase
    end

  always_comb begin
    N = out[31];
    Z = (out == 32'b0);
    C = (alu_op == 4'b0000) ? (a + b < a) : (a - b > a);
    V = (alu_op == 4'b0000) ? ((~(a[31] ^ b[31]) & (a[31] ^ out[31]))) : ((a[31] ^ b[31]) & (a[31] ^ out[31]));
    end
    
endmodule