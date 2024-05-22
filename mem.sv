module mem (
    input clk, rst, wen, 
    input logic [15:0] waddr, wdata,
    input logic [15:0] raddr1, raddr2,
    output logic [15:0] rdata1, rdata2
);

logic [15:0] mem [0:65535];
initial begin
    $readmemh("cpu.mem", mem, 0, 32767);
end

always_ff @(posedge clk) begin
    if (rst) begin
        rdata1 <= 0;
        rdata2 <= 0;
    end else begin
        if (wen)
            mem[waddr] <= wdata;
        else begin
            rdata1 <= mem[raddr1];
            rdata2 <= mem[raddr2];
        end
    end
end

endmodule