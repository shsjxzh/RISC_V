//全局
`define RstEnable 1'b1  //复位信号
`define RstDisable 1'b0 
`define ZeroWord 32'h00000000
`define WriteEnable 1'b1   //使其能写的信号
`define WriteDisable 1'b0
`define ReadEnable 1'b1    //使其能读的信号
`define ReadDisable 1'b0

`define OpkindBus  3:0
`define OpcmdBus   6:0

`define InstValid 1'b0  //指令有效
`define InstInvalid 1'b1
`define Stop 1'b1
`define NoStop 1'b0
`define InDelaySlot 1'b1
`define NotInDelaySlot 1'b0
`define Branch 1'b1
`define NotBranch 1'b0
`define InterruptAssert 1'b1
`define InterruptNotAssert 1'b0
`define TrapAssert 1'b1
`define TrapNotAssert 1'b0
`define True_v 1'b1
`define False_v 1'b0
`define ChipEnable 1'b1
`define ChipDisable 1'b0


//指令存储器inst_rom
`define InstAddrBus 31:0    //ROM指令地址宽度
`define InstBus 31:0        //ROM数据宽度
`define InstMemNum 2048    //注意一下这个单位
`define InstMemNumLog2 11

//用于memory访问
`define MemAddrBus 31:0
`define MemDataBus 31:0
`define ByteWidth  7:0

//先不要搞那么大
//`define DataMemNum 131072
//`define DataMemNumLog2 17
`define DataMemNum 2048 
`define DataMemNumLog2 11

//通用寄存器regfile
`define RegAddrBus 4:0
`define RegBus 31:0
`define RegWidth 32
`define DoubleRegWidth 64
`define DoubleRegBus 63:0
`define RegNum 32
`define RegNumLog2 5        //用于寄存器寻址的二进制位数
`define NONRegAddr 5'b00000

// Code by Evensgn
// Last Modify: 2017-12-16
// id 阶段的操作内容

//==================  Instruction opcode in RISC-V ================== 

// Reset
//`define OP_NON      7'b0000000

`define OP_LUI      7'b0110111
`define OP_AUIPC    7'b0010111
`define OP_JAL      7'b1101111
`define OP_JALR     7'b1100111
`define OP_BRANCH   7'b1100011
`define OP_LOAD     7'b0000011
`define OP_STORE    7'b0100011
`define OP_OP_IMM   7'b0010011
`define OP_OP       7'b0110011

//fence指令应用于多核之中，不需要我们实现
//`define OP_MISC_MEM 7'b0001111

//================== Instruction funct3 in RISC-V ================== 
//Reset
//`define FUNCT3_NON  3'b000

// JALR
`define FUNCT3_JALR 3'b000
// BRANCH
`define FUNCT3_BEQ  3'b000
`define FUNCT3_BNE  3'b001
`define FUNCT3_BLT  3'b100
`define FUNCT3_BGE  3'b101
`define FUNCT3_BLTU 3'b110
`define FUNCT3_BGEU 3'b111
// LOAD
`define FUNCT3_LB   3'b000
`define FUNCT3_LH   3'b001
`define FUNCT3_LW   3'b010
`define FUNCT3_LBU  3'b100
`define FUNCT3_LHU  3'b101
// STORE
`define FUNCT3_SB   3'b000
`define FUNCT3_SH   3'b001
`define FUNCT3_SW   3'b010
// OP-IMM
`define FUNCT3_ADDI      3'b000
`define FUNCT3_SLTI      3'b010
`define FUNCT3_SLTIU     3'b011
`define FUNCT3_XORI      3'b100
`define FUNCT3_ORI       3'b110
`define FUNCT3_ANDI      3'b111
`define FUNCT3_SLLI      3'b001
`define FUNCT3_SRLI_SRAI 3'b101
// OP
`define FUNCT3_ADD_SUB 3'b000
`define FUNCT3_SLL     3'b001
`define FUNCT3_SLT     3'b010
`define FUNCT3_SLTU    3'b011
`define FUNCT3_XOR     3'b100
`define FUNCT3_SRL_SRA 3'b101
`define FUNCT3_OR      3'b110
`define FUNCT3_AND     3'b111
// MISC-MEM
`define FUNCT3_FENCE  3'b000
`define FUNCT3_FENCEI 3'b001

//================== Instruction funct7 in RISC-V ==================
//Reset
//`define FUNCT7_NON  1'b0
 
`define FUNCT7_SLLI 1'b0
// SRLI_SRAI
`define FUNCT7_SRLI 1'b0
`define FUNCT7_SRAI 1'b1
// ADD_SUB
`define FUNCT7_ADD  1'b0
`define FUNCT7_SUB  1'b1
`define FUNCT7_SLL  1'b0
`define FUNCT7_SLT  1'b0
`define FUNCT7_SLTU 1'b0
`define FUNCT7_XOR  1'b0
// SRL_SRA
`define FUNCT7_SRL 1'b0
`define FUNCT7_SRA 1'b1
`define FUNCT7_OR  1'b0
`define FUNCT7_AND 1'b0

//================== operate type define ==================
`define EXE_NON_TYPE         3'b000

`define EXE_LOGIC_TYPE       3'b001
`define EXE_SHIFT_TYPE       3'b010
`define EXE_ARITHMETIC_TYPE  3'b011
`define EXE_JUMP_TYPE        3'b100
`define EXE_LOAD_TYPE        3'b101
`define EXE_STORE_TYPE       3'b110

//================== operate command define ==================
`define EXE_NON_OP   6'b000000

//logic
`define EXE_OR      6'b000001
`define EXE_AND     6'b000010
`define EXE_XOR     6'b000011
`define EXE_LUI     6'b001011  //new

//arithmetic
`define EXE_ADD     6'b000100
`define EXE_SUB     6'b000101
`define EXE_SLT     6'b000110
`define EXE_SLTU    6'b000111

//shift
`define EXE_SRL     6'b001000
`define EXE_SRA     6'b001001
`define EXE_SLL     6'b001010

//no jump
//banch
`define EXE_BEQ     6'b001100
`define EXE_BNE     6'b001101
`define EXE_BLT     6'b001110
`define EXE_BGE     6'b001111
`define EXE_BLTU    6'b010000
`define EXE_BGEU    6'b010001

//load
`define EXE_LB      6'b010010
`define EXE_LH      6'b010011
`define EXE_LW      6'b010100
`define EXE_LBU     6'b010101
`define EXE_LHU     6'b010110

//store
`define EXE_SB      6'b010111
`define EXE_SH      6'b011000
`define EXE_SW      6'b011001