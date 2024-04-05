
opcodes = {
    "ADD" : "0000",
    "NDA"  : "0010",
    "LW"   : "0100",
    "SW"  : "0101",
    "BEQ" : "1100",
    "JAL"  : "1000"
}

reg ={
    "R0" : "000",
    "R1" : "001",
    "R2" : "010",
    "R3" : "011",
    "R4" : "100",
    "R5" : "101",
    "R6" : "110",
    "R7" : "111"
}

file=["LW R5 R1 0",                            #write code here
      "ADD R3 R5 R1",                       
      "SW R3 R0 1",                         
        "LW R3 R0 1",                       
        "ADD R3 R3 R1",
        "ADD R3 R3 R0",
        "JAL R1 12"]                    
def binary_to_hex(binary):
    decimal = int(binary, 2)
    hex_value = hex(decimal)[2:].zfill(4)
    return hex_value

def decimal_to_binary_6(decimal):
    binary = bin(decimal)[2:].zfill(6)
    return binary

def decimal_to_binary_9(decimal):
    binary = bin(decimal)[2:].zfill(9)
    return binary

def assemble(instruction):
    parts = instruction.split()
    if parts[0] == "ADD" or parts[0] == "NDA":
        opcode = (opcodes[parts[0]]+reg[parts[2]]+reg[parts[3]]+reg[parts[1]]+"000")
    elif parts[0] == "LW" or parts[0] == "SW" or parts[0] == "BEQ":
        opcode = (opcodes[parts[0]]+reg[parts[1]]+reg[parts[2]]+str(decimal_to_binary_6(int(parts[3]))) )
    elif parts[0] == "JAL":
        opcode = (opcodes[parts[0]]+reg[parts[1]]+str(decimal_to_binary_9(int(parts[2]))) )
    return binary_to_hex(opcode)

def assemble_code(file):
    for x in range(len(file)):
        print("{{prog_mem[{0}],prog_mem[{1}]}} = 16'h{2};".format(2*x+1, 2*x, assemble(file[x])))

assemble_code(file)

