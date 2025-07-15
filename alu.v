
`timescale 1ns/1ns

/**
 * ALU (Arithmetic Logic Unit) Module
 * 
 * This module implements a 16-bit ALU with support for arithmetic and logic operations.
 * The ALU performs operations based on the alu_op control signal and sets appropriate flags.
 * 
 * Features:
 * - 16-bit data path
 * - 4 operation modes: ADD, NAND, EQUAL, MEMORY_ADD
 * - Carry and Zero flag generation
 * - Clock-synchronized operation
 * 
 * @param clk      Clock signal for synchronization
 * @param alu_op   2-bit operation code to select ALU function
 * @param data_a   16-bit first operand
 * @param data_b   16-bit second operand
 * @param result   16-bit ALU output result
 * @param flags    2-bit flag register [1:0] = {carry, zero}
 */
module alu (
    input  wire        clk,      // Clock signal
    input  wire [1:0]  alu_op,   // Operation select
    input  wire [15:0] data_a,   // First operand
    input  wire [15:0] data_b,   // Second operand
    output reg  [15:0] result,   // ALU result
    output reg  [1:0]  flags     // Status flags: [1]=carry, [0]=zero
);

    // ALU Operation Codes
    parameter ADD_ARITH = 2'b00,  // Arithmetic addition with carry
              NAND_OP   = 2'b01,  // Bitwise NAND operation
              EQUAL     = 2'b10,  // Equality check (subtract and test)
              ADD_MEM   = 2'b11;  // Memory address addition

    // Initialize flags to zero at start
    initial begin
        flags <= 2'b00;
    end

    // ALU operation logic - combinational with clock enable
    always @(*) begin
        if (clk) begin
            case (alu_op)
                ADD_ARITH: begin
                    // Arithmetic addition with carry detection
                    {flags[1], result} = data_a + data_b;
                    flags[0] <= (result == 0) ? 1 : 0;  // Set zero flag
                end
                
                NAND_OP: begin
                    // Bitwise NAND operation
                    result = ~(data_a & data_b);
                    flags[1] <= 1'b0;  // Clear carry flag
                    flags[0] <= (result == 0) ? 1 : 0;  // Set zero flag
                end
                
                EQUAL: begin
                    // Equality check by subtraction
                    flags[0] <= (result == 0) ? 1 : 0;  // Zero flag indicates equality
                    result <= data_a - data_b;
                    flags[1] <= 1'b0;  // Clear carry flag
                end
                
                ADD_MEM: begin
                    // Memory address addition (no carry)
                    result = data_a + data_b;
                    flags[0] <= ~|result;  // Zero flag using reduction OR
                    flags[1] <= 1'b0;  // Clear carry flag
                end
                
                default: begin
                    // Default case for undefined operations
                    result <= 16'h0000;
                    flags <= 2'b00;
                end
            endcase
        end
    end

endmodule

/**
 * ALU Testbench Module
 * 
 * This testbench verifies the functionality of the ALU module by testing
 * various operations and input combinations.
 */
module alu_tb();
    // Testbench signals
    reg        clk;
    reg [1:0]  alu_op;
    reg [15:0] data_a, data_b;
    
    wire [15:0] result;
    wire [1:0]  flags;

    // Instantiate the ALU under test
    alu dut (
        .clk(clk),
        .alu_op(alu_op),
        .data_a(data_a),
        .data_b(data_b),
        .result(result),
        .flags(flags)
    );

    // Clock generation - 10ns period (100MHz)
    always #5 clk = ~clk;

    // Test stimulus
    initial begin
        // Initialize signals
        clk = 0;
        alu_op = 2'b10;  // Fixed: use 2-bit value instead of 3-bit
        data_a = 16'd3;  // Fixed: use proper bit width
        data_b = 16'd3;  // Fixed: use proper bit width
        
        // Add more comprehensive test cases here
        #10;
        $display("Time=%0t: alu_op=%b, data_a=%d, data_b=%d, result=%d, flags=%b", 
                 $time, alu_op, data_a, data_b, result, flags);
        
        // Test other operations
        #10 alu_op = 2'b00; // ADD_ARITH
        #10 $display("Time=%0t: alu_op=%b, data_a=%d, data_b=%d, result=%d, flags=%b", 
                     $time, alu_op, data_a, data_b, result, flags);
        
        #20 $finish;
    end

endmodule
