`timescale 1ns/1ns

/**
 * Rissy CPU Core Module
 * 
 * This is the top-level module for the Rissy RISC processor. It integrates all
 * the processor components including the register file, decoder, ALU, memory,
 * and multiplexers to form a complete 16-bit RISC CPU.
 * 
 * Features:
 * - 16-bit RISC architecture
 * - 8 general-purpose registers (R0-R7)
 * - Support for arithmetic, logic, load/store, and branch instructions
 * - Harvard architecture with separate instruction and data memory
 * - Program counter (PC) management
 * 
 * @param clk       System clock signal
 * @param rst       Reset signal (active high)
 * @param inst      16-bit instruction input from instruction memory
 * @param address   Current program counter (PC) address output
 * @param result    ALU computation result output
 * @param flags     Status flags from ALU [1:0] = {carry, zero}
 * @param bc        Branch counter signal
 * @param d1        Debug output: ALU operand A
 * @param d2        Debug output: ALU operand B
 */
module Rissy (
    input  wire        clk,      // System clock
    input  wire        rst,      // Reset signal
    input  wire [15:0] inst,     // Instruction from memory
    output reg  [15:0] address,  // Program counter address
    output reg  [15:0] result,   // ALU result
    output reg  [1:0]  flags,    // Status flags
    output reg         bc,       // Branch counter
    output reg  [15:0] d1,       // Debug: data A
    output reg  [15:0] d2        // Debug: data B
);

    // Internal wire declarations
    wire [2:0]  in_write_add;           // Register write address
    wire [15:0] in_address;             // Internal PC address  
    wire [15:0] in_data_a, in_data_b;   // Register file outputs
    wire [15:0] data_a;                 // ALU input A (after mux)
    wire        in_w_en;                // Register write enable
    wire        in_load_store;          // Memory load/store control
    wire        in_pc_inc;              // PC increment control
    wire [2:0]  in_RA_add, in_RB_add;   // Register read addresses
    wire [2:0]  in_alu_op;              // ALU operation code
    wire [15:0] in_immediate;           // Immediate value from decoder
    wire [15:0] in_result;              // ALU result
    wire [15:0] write_data;             // Data to write to register
    wire [15:0] mem_data;               // Memory data
    wire [1:0]  in_flags;               // ALU flags
    wire        in_bc;                  // Internal branch counter

    // Register file instance
    reg_file r (
        .clk(clk),
        .rst(rst),
        .w_en(in_w_en),
        .pc_inc(in_pc_inc),
        .write_data(write_data),
        .write_add(in_write_add),
        .RA_add(in_RA_add),
        .RB_add(in_RB_add),
        .address(in_address),
        .data_a(in_data_a),
        .data_b(in_data_b)
    );

    // Instruction decoder instance
    decoder d (
        .clk(clk),
        .inst(inst),
        .flags(in_flags),
        .w_en(in_w_en),
        .load_store(in_load_store),
        .pc_inc(in_pc_inc),
        .RA_add(in_RA_add),
        .RB_add(in_RB_add),
        .alu_op(in_alu_op),
        .write_add(in_write_add),
        .immediate(in_immediate),
        .bra_counter(in_bc)
    );

    // ALU input multiplexer (selects between register data and immediate)
    multiplex m_alu (
        .sel(in_alu_op[1] & in_alu_op[0]),
        .data_1(in_data_a),
        .data_2(in_immediate),
        .data(data_a)
    );

    // Register write-back multiplexer (selects between ALU result and memory data)
    multiplex m_reg (
        .sel(in_alu_op[2]),
        .data_1(in_result),
        .data_2(mem_data),
        .data(write_data)
    );

    // ALU instance
    alu a (
        .clk(clk),
        .alu_op(in_alu_op[1:0]),
        .data_a(data_a),
        .data_b(in_data_b),
        .result(in_result),
        .flags(in_flags)
    );

    // Memory instance
    memory m (
        .clk(clk),
        .load_store(in_load_store),
        .en(in_alu_op[2]),
        .data(mem_data),
        .add(in_result[7:0])  // Use lower 8 bits of ALU result as address
    );

    // Output assignments
    always @(*) begin
        address <= in_address;
        flags   <= in_flags;
        result  <= in_result;
        bc      <= in_bc;
        d1      <= data_a;
        d2      <= in_data_b;
    end

    // Memory data tri-state control
    assign mem_data = (in_alu_op[2] & !in_load_store) ? in_data_a : 16'hzzzz;

endmodule

/**
 * Instruction Cache and Testbench Module
 * 
 * This module serves as both an instruction memory cache and a testbench
 * for the Rissy processor. It contains a small program memory and provides
 * instructions to the processor core for execution.
 * 
 * Features:
 * - 16-byte instruction memory (8 instructions max)
 * - Automatic instruction fetch based on PC
 * - Sample program for testing processor functionality
 */
module instruction_cache();
    // Testbench signals
    reg        clk, rst;
    reg [15:0] inst;
    
    wire [15:0] address, result, d1, d2;
    wire [1:0]  flags;
    wire        bc;

    // Rissy processor instance
    Rissy r (
        .clk(clk),
        .rst(rst),
        .inst(inst),
        .address(address),
        .result(result),
        .flags(flags),
        .bc(bc),
        .d1(d1),
        .d2(d2)
    );

    // Program memory - 16 bytes (8 instructions)
    reg [7:0] prog_mem[15:0];

    // Clock generation - 10ns period (100MHz)
    always #5 clk = ~clk;

    // Test program initialization
    initial begin
        clk = 0;
        
        // Reset sequence
        #1 rst = 1;
        #2 rst = 0;
        
        // Load test program into memory
        {prog_mem[1], prog_mem[0]} = 16'h0ba0;  // Never use branch as first instruction
        {prog_mem[3], prog_mem[2]} = 16'h8204;  // Sample instruction
        {prog_mem[5], prog_mem[4]} = 16'h44c5;  // Sample instruction
        {prog_mem[7], prog_mem[6]} = 16'h0220;  // Sample instruction
    end

    // Instruction fetch logic
    always @(*) begin
        if (clk) begin
            inst = {prog_mem[address + 1], prog_mem[address]};
        end
    end

endmodule


