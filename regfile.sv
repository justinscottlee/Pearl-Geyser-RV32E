module regfile (
    input logic clk, rst_n,                 // system clock and active low reset
    input logic we,                         // active high, write enable
    input logic [3:0] rs1, rs2, rd,         // register address for source 1, source 2, and destination
    input logic [31:0] rd_data,             // 32-bit data to write
    output logic [31:0] rs1_data, rs2_data  // 32-bit data read from source 1 and source 2
);

logic [31:0] regfile[1:15]; // registers 1 thru 15 (register 0 is hardwired to all zeros)

// asynchronous read from rs1 and rs2
assign rs1_data = (rs1 == 0) ? 32'd0 : regfile[rs1];
assign rs2_data = (rs2 == 0) ? 32'd0 : regfile[rs2];

always_ff @ (posedge clk) begin
    if (!rst_n) begin
        // reset all registers to zero
        for (int i = 1; i < 16; i++) begin
            regfile[i] <= 32'd0;
        end
    end else if (we && rd != 0) begin
        // write if write enable is true and destination register is not 0
        regfile[rd] <= rd_data;
    end
end

endmodule