`timescale 1ns/1ns

/**
 * Memory Module
 * 
 * This module implements a 256x16-bit data memory with support for both
 * load and store operations. The memory uses bidirectional data bus
 * and tri-state logic for proper bus control.
 * 
 * Features:
 * - 256 words of 16-bit memory (512 bytes total)
 * - Bidirectional data bus with tri-state control
 * - Support for load (read) and store (write) operations
 * - Clock-synchronized operations
 * - Initialized with sequential values for testing
 * 
 * @param clk         System clock signal
 * @param load_store  Operation control (1=load/read, 0=store/write)
 * @param en          Memory enable signal
 * @param data        Bidirectional 16-bit data bus
 * @param add         8-bit memory address (0-255)
 */
module memory (
    input  wire        clk,        // System clock
    input  wire        load_store, // 1=load, 0=store
    input  wire        en,         // Memory enable
    inout  wire [15:0] data,       // Bidirectional data bus
    input  wire [7:0]  add         // Memory address
);

    // Memory array - 256 words of 16 bits each
    reg [15:0] mem[255:0];
    
    // Output data register for load operations
    reg [15:0] data_o;
    
    // Loop variable for initialization
    integer i;

    // Initialize memory with sequential values
    initial begin
        for (i = 0; i < 256; i = i + 1) begin
            mem[i] <= i;
        end
    end

    // Tri-state control for bidirectional data bus
    // Drive bus only during load operations when enabled
    assign data = (en & load_store) ? data_o : 16'hzzzz;

    // Memory operation logic
    always @(*) begin
        if (clk) begin
            if (en) begin
                if (!load_store) begin
                    // Store operation: write data to memory
                    mem[add] <= data;
                end else begin
                    // Load operation: read data from memory
                    data_o <= mem[add];
                end
            end
        end
    end

endmodule

/**
 * Memory Testbench Module
 * 
 * This testbench verifies the functionality of the memory module
 * by testing both store and load operations.
 */
module mem_test();
    // Testbench signals
    reg        clk, load_store, en;
    wire [15:0] data;
    reg  [15:0] data_o;
    reg  [7:0]  add;

    // Tri-state control for testbench data driving
    assign data = (!load_store) ? data_o : 16'hzzzz;

    // Memory instance under test
    memory dut (
        .clk(clk),
        .load_store(load_store),
        .en(en),
        .data(data),
        .add(add)
    );

    // Clock generation - 10ns period (100MHz)
    always #5 clk = ~clk;

    // Test stimulus
    initial begin
        // Initialize signals
        clk = 0;
        
        #5;
        en = 1;
        
        // Test store operation
        load_store = 0;      // Store mode
        data_o = $random;    // Random data to store
        add = 0;             // Address 0
        
        #10;
        // Test load operation
        load_store = 1;      // Load mode
        add = 0;             // Same address
        data_o = $random;    // This won't drive the bus in load mode
        
        #10 $finish;
    end

    // Monitor memory operations
    initial begin
        $monitor("Time=%0t: clk=%b, en=%b, load_store=%b, add=%d, data=%h", 
                 $time, clk, en, load_store, add, data);
    end

endmodule
