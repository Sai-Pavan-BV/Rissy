`timescale 1ns/1ns

/**
 * Instruction Decoder Module
 * 
 * This module decodes 16-bit RISC instructions and generates control signals
 * for the processor datapath. It supports various instruction formats including
 * R-type (register), I-type (immediate), and J-type (jump) instructions.
 * 
 * Supported Instructions:
 * - ADD: Register addition
 * - NDU: NAND operation
 * - LW:  Load word from memory
 * - SW:  Store word to memory
 * - BEQ: Branch if equal
 * - JAL: Jump and link
 * 
 * @param clk          System clock signal
 * @param inst         16-bit instruction to decode
 * @param flags        Status flags from ALU [1:0] = {carry, zero}
 * @param w_en         Register write enable output
 * @param load_store   Memory load/store control (1=load, 0=store)
 * @param pc_inc       Program counter increment control
 * @param RA_add       Register A read address
 * @param RB_add       Register B read address  
 * @param alu_op       ALU operation code
 * @param write_add    Register write address
 * @param immediate    Immediate value for I-type instructions
 * @param bra_counter  Branch counter for multi-cycle operations
 */
module decoder (
    input  wire        clk,          // System clock
    input  wire [15:0] inst,         // Instruction input
    input  wire [1:0]  flags,        // ALU status flags
    output reg         w_en,         // Register write enable
    output reg         load_store,   // Memory operation control
    output reg         pc_inc,       // PC increment control
    output reg  [2:0]  RA_add,       // Register A address
    output reg  [2:0]  RB_add,       // Register B address
    output reg  [2:0]  alu_op,       // ALU operation code
    output reg  [2:0]  write_add,    // Register write address
    output reg  [15:0] immediate,    // Immediate value
    output reg         bra_counter   // Branch counter
);

    // Instruction opcodes (bits [15:12])
    parameter ADD = 4'h0,   // Addition
              NDU = 4'h2,   // NAND operation
              LW  = 4'h4,   // Load word
              SW  = 4'h5,   // Store word
              BEQ = 4'hc,   // Branch if equal
              JAL = 4'h8;   // Jump and link

    // Initialize control signals
    initial begin
        bra_counter <= 1'b0;
        pc_inc      <= 1'b0;
    end
    // Main instruction decode logic
    always @(*) begin
        if (clk) begin
            case (inst[15:12])
                ADD: begin
                    // R-type: ADD rd, rs, rt
                    alu_op    <= 3'b000;           // Arithmetic addition
                    RA_add    <= inst[11:9];       // Source register A
                    RB_add    <= inst[8:6];        // Source register B
                    write_add <= inst[5:3];        // Destination register
                    w_en      <= 1'b1;             // Enable register write
                    immediate <= 16'hxxxx;         // Not used
                    load_store<= 1'bx;             // Don't care
                    pc_inc    <= 1'b1;             // Increment PC
                end
                
                NDU: begin
                    // R-type: NDU rd, rs, rt (NAND operation)
                    alu_op    <= 3'b001;           // NAND operation
                    RA_add    <= inst[11:9];       // Source register A
                    RB_add    <= inst[8:6];        // Source register B
                    write_add <= inst[5:3];        // Destination register
                    w_en      <= 1'b1;             // Enable register write
                    immediate <= 16'hxxxx;         // Not used
                    load_store<= 1'bx;             // Don't care
                    pc_inc    <= 1'b1;             // Increment PC
                end
                
                LW: begin
                    // I-type: LW rt, offset(rs)
                    alu_op    <= 3'b111;           // Memory address calculation
                    RA_add    <= 3'hx;             // Not used
                    RB_add    <= inst[8:6];        // Base register
                    write_add <= inst[11:9];       // Destination register
                    w_en      <= 1'b1;             // Enable register write
                    immediate <= {10'h000, inst[5:0]}; // 6-bit offset
                    load_store<= 1'b1;             // Load operation
                    pc_inc    <= 1'b1;             // Increment PC
                end
                
                SW: begin
                    // I-type: SW rt, offset(rs)
                    alu_op    <= 3'b111;           // Memory address calculation
                    RA_add    <= inst[11:9];       // Source register (data)
                    RB_add    <= inst[8:6];        // Base register
                    write_add <= 3'hx;             // Not used
                    w_en      <= 1'b0;             // Disable register write
                    immediate <= {10'h000, inst[5:0]}; // 6-bit offset
                    load_store<= 1'b0;             // Store operation
                    pc_inc    <= 1'b1;             // Increment PC
                end
                
                BEQ: begin
                    // Branch if equal instruction (2-cycle operation)
                    if (!bra_counter) begin
                        // First cycle: Compare registers
                        alu_op    <= 3'b010;           // Equality comparison
                        RA_add    <= inst[11:9];       // First register to compare
                        RB_add    <= inst[8:6];        // Second register to compare
                        write_add <= 3'hx;             // Not used
                        w_en      <= 1'b0;             // No register write
                        immediate <= 16'hxxxx;         // Not used
                        load_store<= 1'b0;             // Not a memory operation
                        
                        if (flags[0]) begin             // If equal (zero flag set)
                            pc_inc <= 1'b0;            // Don't increment PC (prepare for branch)
                        end else begin
                            pc_inc <= 1'b1;            // Increment PC (no branch)
                        end
                    end
                    
                    if (bra_counter) begin
                        // Second cycle: Execute branch if condition was satisfied
                        alu_op    <= 3'b011;           // Address calculation
                        RA_add    <= 3'hx;             // Not used
                        RB_add    <= 3'h7;             // PC register (R7)
                        write_add <= 3'h7;             // Write back to PC
                        w_en      <= 1'b1;             // Enable write
                        load_store<= 1'b0;             // Not a memory operation
                        // Calculate branch target: PC + offset - 2
                        immediate <= ({10'h000, inst[5:0]} - 16'h0002);
                        pc_inc    <= 1'b1;             // Increment PC after branch
                    end
                end
                
                JAL: begin
                    // Jump and link instruction (2-cycle operation)
                    if (!bra_counter) begin
                        // First cycle: Save return address
                        alu_op    <= 3'b011;           // Address calculation
                        RA_add    <= 3'hx;             // Not used
                        RB_add    <= 3'd7;             // PC register (R7)
                        write_add <= inst[11:9];       // Link register
                        w_en      <= 1'b1;             // Enable write
                        immediate <= 16'h0002;         // Return address = PC + 2
                        load_store<= 1'b0;             // Not a memory operation
                        pc_inc    <= 1'b0;             // Don't increment PC yet
                    end
                    
                    if (bra_counter) begin
                        // Second cycle: Jump to target address
                        alu_op    <= 3'b011;           // Address calculation
                        RA_add    <= 3'hx;             // Not used
                        RB_add    <= 3'h7;             // PC register (R7)
                        write_add <= 3'h7;             // Write back to PC
                        w_en      <= 1'b1;             // Enable write
                        load_store<= 1'b0;             // Not a memory operation
                        // Calculate jump target: address - 2
                        immediate <= ({7'h00, inst[8:0]} - 16'h0002);
                        pc_inc    <= 1'b1;             // Increment PC after jump
                    end
                end
                
                default: begin
                    // Default case for undefined instructions
                    alu_op    <= 3'b000;
                    RA_add    <= 3'h0;
                    RB_add    <= 3'h0;
                    write_add <= 3'h0;
                    w_en      <= 1'b0;
                    immediate <= 16'h0000;
                    load_store<= 1'b0;
                    pc_inc    <= 1'b1;
                end
            endcase
        end
    end

    // Branch counter logic (tracks multi-cycle operations)
    always @(*) begin
        if (!clk) begin
            bra_counter <= ~pc_inc;
        end
    end

endmodule

/**
 * Decoder Testbench Module
 * 
 * This testbench verifies the functionality of the instruction decoder
 * by testing various instruction types and flag conditions.
 */
module dec_tb();
    // Testbench signals
    reg        clk;
    reg [1:0]  flags;
    reg [15:0] inst;
    
    wire        w_en, load_store, pc_inc;
    wire [2:0]  RA_add, RB_add, alu_op, write_add;
    wire [15:0] immediate;
    wire        bra_counter;

    // Instantiate decoder under test
    decoder dut (
        .clk(clk),
        .inst(inst),
        .flags(flags),
        .w_en(w_en),
        .load_store(load_store),
        .pc_inc(pc_inc),
        .RA_add(RA_add),
        .RB_add(RB_add),
        .alu_op(alu_op),
        .write_add(write_add),
        .immediate(immediate),
        .bra_counter(bra_counter)
    );

    // Clock generation - 10ns period (100MHz)
    always #5 clk = ~clk;

    // Test stimulus
    initial begin
        // Initialize signals
        clk <= 1'b0;
        
        // Test BEQ instruction
        #4;
        inst <= 16'hc282;  // BEQ instruction
        flags <= 2'b00;    // Zero flag clear
        
        #2;
        flags <= 2'b01;    // Zero flag set
        
        #8;
        inst <= 16'hc242;  // Another BEQ instruction
        
        #20 $finish;
    end

    // Monitor outputs
    initial begin
        $monitor("Time=%0t: inst=%h, flags=%b, w_en=%b, pc_inc=%b, alu_op=%b, bra_counter=%b", 
                 $time, inst, flags, w_en, pc_inc, alu_op, bra_counter);
    end

endmodule
