`timescale 1ns/1ns

/**
 * 2-to-1 Multiplexer Module
 * 
 * This module implements a simple 2-to-1 multiplexer for 16-bit data.
 * It selects between two input data sources based on a control signal.
 * This is commonly used in the processor datapath for selecting between
 * different data sources (e.g., register data vs immediate values).
 * 
 * @param sel     Selection control signal (0=data_1, 1=data_2)
 * @param data_1  First input data source (selected when sel=0)
 * @param data_2  Second input data source (selected when sel=1)
 * @param data    Output data (selected input based on sel)
 */
module multiplex (
    input  wire        sel,     // Selection control
    input  wire [15:0] data_1,  // Input 1
    input  wire [15:0] data_2,  // Input 2
    output reg  [15:0] data     // Output
);

    // Multiplexer logic
    always @(*) begin
        case (sel)
            1'b0: data <= data_1;  // Select first input
            1'b1: data <= data_2;  // Select second input
        endcase
    end

endmodule
