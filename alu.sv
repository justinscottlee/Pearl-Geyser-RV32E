`include "defines.vh"

module alu (
    input logic [3:0] operation,    // alu operation code
    input logic [31:0] a, b,        // 32-bit operands
    output logic [31:0] result,     // 32-bit result
    output logic zero,              // flag indicating the result is zero
    output logic negative,          // flag indicating the result is negative
    output logic carry              // flag indicating an over/underflow in addition or subtraction
);

// set flags based on result
assign zero = (result == 32'b0);
assign negative = result[31];

always_comb begin
    carry = 1'b0;   // default carry flag to 0 for operations where it isn't applicable
    case (operation)
    `ALU_ADD: begin
        result = a + b;
        carry = (result < a);   // if an overflow(carry) occured, the result is less than both operands
    end
    `ALU_SUB: begin
        result = a - b;
        carry = (a < b);    // if an underflow(carry) occurred, a was less than b
    end
    `ALU_AND:   result = a & b;
    `ALU_OR:    result = a | b;
    `ALU_XOR:   result = a ^ b;
    //  shift operations use 5 low bits because (2^5 - 1) = 31 bits of shift-capability
    `ALU_SLL:   result = a << b[4:0];
    `ALU_SRL:   result = a >> b[4:0];
    `ALU_SRA:   result = a >>> b[4:0];
    default:    result = 32'b0;
    endcase
end

endmodule