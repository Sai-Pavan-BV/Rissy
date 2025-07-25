
#!/usr/bin/env python3
"""
Rissy Processor Assembler

This Python script assembles human-readable assembly code into machine code
for the Rissy 16-bit RISC processor. It supports the complete instruction set
and generates Verilog-compatible hex output for program memory initialization.

Supported Instructions:
- ADD rd, rs, rt    : Add two registers
- NDA rd, rs, rt    : NAND two registers  
- LW  rt, rs, imm   : Load word from memory
- SW  rt, rs, imm   : Store word to memory
- BEQ rs, rt, imm   : Branch if equal
- JAL rd, imm       : Jump and link

Author: Rissy Development Team
Version: 1.0
"""

# Instruction opcode mappings (4-bit opcodes)
opcodes = {
    "ADD": "0000",  # R-type: Addition
    "NDA": "0010",  # R-type: NAND operation
    "LW":  "0100",  # I-type: Load word
    "SW":  "0101",  # I-type: Store word
    "BEQ": "1100",  # I-type: Branch if equal
    "JAL": "1000"   # J-type: Jump and link
}

# Register name to binary mapping (3-bit register addresses)
registers = {
    "R0": "000",  # General purpose register 0
    "R1": "001",  # General purpose register 1
    "R2": "010",  # General purpose register 2
    "R3": "011",  # General purpose register 3
    "R4": "100",  # General purpose register 4
    "R5": "101",  # General purpose register 5
    "R6": "110",  # General purpose register 6
    "R7": "111"   # Program Counter (PC)
}

# Sample assembly program for testing
test_program = [
    "LW R5 R1 0",      # Load word from memory[R1+0] into R5
    "ADD R3 R5 R1",    # Add R5 and R1, store result in R3
    "SW R3 R0 1",      # Store R3 to memory[R0+1]
    "LW R3 R0 1",      # Load word from memory[R0+1] into R3
    "ADD R3 R3 R1",    # Add R3 and R1, store result in R3
    "ADD R3 R3 R0",    # Add R3 and R0, store result in R3
    "JAL R1 12"        # Jump to address 12, save return address in R1
]


def binary_to_hex(binary_string):
    """
    Convert a binary string to a 4-character hexadecimal string.
    
    Args:
        binary_string (str): 16-bit binary string
        
    Returns:
        str: 4-character hexadecimal string (uppercase)
    """
    decimal_value = int(binary_string, 2)
    hex_value = hex(decimal_value)[2:].upper().zfill(4)
    return hex_value


def decimal_to_binary_6(decimal_value):
    """
    Convert decimal to 6-bit binary string (for I-type immediate values).
    
    Args:
        decimal_value (int): Decimal value to convert
        
    Returns:
        str: 6-bit binary string
    """
    return bin(decimal_value)[2:].zfill(6)


def decimal_to_binary_9(decimal_value):
    """
    Convert decimal to 9-bit binary string (for J-type immediate values).
    
    Args:
        decimal_value (int): Decimal value to convert
        
    Returns:
        str: 9-bit binary string
    """
    return bin(decimal_value)[2:].zfill(9)


def assemble_instruction(instruction):
    """
    Assemble a single instruction into 16-bit machine code.
    
    Args:
        instruction (str): Assembly instruction string
        
    Returns:
        str: 4-character hexadecimal machine code
        
    Instruction Formats:
        R-type: [opcode:4][rs:3][rt:3][rd:3][unused:3]
        I-type: [opcode:4][rt:3][rs:3][immediate:6]
        J-type: [opcode:4][rd:3][immediate:9]
    """
    parts = instruction.strip().split()
    opcode = opcodes[parts[0]]
    
    if parts[0] in ["ADD", "NDA"]:
        # R-type instructions: opcode + rs + rt + rd + padding
        rd = registers[parts[1]]  # Destination register
        rs = registers[parts[2]]  # Source register 1
        rt = registers[parts[3]]  # Source register 2
        machine_code = opcode + rs + rt + rd + "000"
        
    elif parts[0] in ["LW", "SW", "BEQ"]:
        # I-type instructions: opcode + rt + rs + immediate
        rt = registers[parts[1]]  # Target/source register
        rs = registers[parts[2]]  # Base register
        immediate = decimal_to_binary_6(int(parts[3]))
        machine_code = opcode + rt + rs + immediate
        
    elif parts[0] == "JAL":
        # J-type instruction: opcode + rd + immediate
        rd = registers[parts[1]]  # Link register
        immediate = decimal_to_binary_9(int(parts[2]))
        machine_code = opcode + rd + immediate
        
    else:
        raise ValueError(f"Unknown instruction: {parts[0]}")
    
    return binary_to_hex(machine_code)


def assemble_program(program):
    """
    Assemble a complete program and generate Verilog memory initialization.
    
    Args:
        program (list): List of assembly instruction strings
        
    Returns:
        None (prints Verilog initialization statements)
    """
    print("// Rissy Processor Program Memory Initialization")
    print("// Generated by Rissy Assembler")
    print("//")
    
    for index, instruction in enumerate(program):
        machine_code = assemble_instruction(instruction)
        mem_low = 2 * index
        mem_high = 2 * index + 1
        
        print(f"{{prog_mem[{mem_high}], prog_mem[{mem_low}]}} = 16'h{machine_code}; "
              f"// {instruction}")


if __name__ == "__main__":
    print(__doc__)
    print("Assembling test program...")
    print("=" * 60)
    assemble_program(test_program)

