`timescale 1ns/1ns

/**
 * Register File Module
 * 
 * This module implements the processor's register file with 8 general-purpose
 * registers (R0-R7). Register R7 serves as the program counter (PC).
 * The module supports dual-port read and single-port write operations.
 * 
 * Features:
 * - 8 registers of 16 bits each (R0-R7)
 * - R7 is used as Program Counter (PC)
 * - Dual-port read (can read two registers simultaneously)
 * - Single-port write with write enable control
 * - PC increment functionality
 * - Reset capability with default initialization
 * 
 * @param clk        System clock signal
 * @param rst        Reset signal (active high)
 * @param w_en       Write enable for register write operations
 * @param pc_inc     PC increment control signal
 * @param write_data 16-bit data to write to register
 * @param write_add  3-bit address of register to write (0-7)
 * @param RA_add     3-bit address of first register to read
 * @param RB_add     3-bit address of second register to read
 * @param address    Current PC value (contents of R7)
 * @param data_a     Data from first read port (register RA_add)
 * @param data_b     Data from second read port (register RB_add)
 */
module reg_file (
    input  wire        clk,        // System clock
    input  wire        rst,        // Reset signal
    input  wire        w_en,       // Write enable
    input  wire        pc_inc,     // PC increment control
    input  wire [15:0] write_data, // Data to write
    input  wire [2:0]  write_add,  // Write address
    input  wire [2:0]  RA_add,     // Read address A
    input  wire [2:0]  RB_add,     // Read address B
    output reg  [15:0] address,    // PC output
    output reg  [15:0] data_a,     // Read data A
    output reg  [15:0] data_b      // Read data B
);

    // Register file - 8 registers of 16 bits each
    reg [15:0] mem[7:0];
    
    // Loop variable for initialization
    integer i;

    // Register file control logic
    always @(clk, rst) begin
        if (rst) begin
            // Reset: Initialize registers with default values
            for (i = 0; i < 7; i = i + 1) begin
                mem[i] = i;  // R0=0, R1=1, ..., R6=6
            end
            mem[7] = 16'h0000;  // PC (R7) starts at address 0
        end else begin
            if (clk) begin
                // PC increment logic (positive edge)
                if (pc_inc) begin
                    mem[7] = mem[7] + 16'h0002;  // Increment PC by 2 (word addressing)
                end
            end else begin
                // Register write logic (negative edge)
                if (w_en) begin
                    mem[write_add] <= write_data;
                end
            end
        end
    end

    // Read port logic - combinational
    always @(*) begin
        if (clk) begin
            address <= mem[7];        // Output current PC value
            data_a  <= mem[RA_add];   // Read port A
            data_b  <= mem[RB_add];   // Read port B
        end
    end

endmodule

