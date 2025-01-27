module Decoder (
    instr_op_i,
    RegWrite_o,
    ALUOp_o,
    ALUSrc_o,
    RegDst_o,
    Jump_o,
    Branch_o,
    BranchType_o,
    MemRead_o,
    MemWrite_o,
    MemtoReg_o
);

  //I/O ports
  input [6-1:0] instr_op_i;

  output RegWrite_o;
  output [3-1:0] ALUOp_o;
  output ALUSrc_o;
  output RegDst_o;
  output Jump_o;
  output Branch_o;
  output BranchType_o;
  output MemRead_o;
  output MemWrite_o;
  output MemtoReg_o;

  //Internal Signals
  wire RegWrite_o;
  wire [3-1:0] ALUOp_o;
  wire ALUSrc_o;
  wire RegDst_o;
  wire Jump_o;
  wire Branch_o;
  wire BranchType_o;
  wire MemRead_o;
  wire MemWrite_o;
  wire MemtoReg_o;

  //Main function
  /*your code here*/
  // Format parameter
  wire R_type, addi, lw, sw, beq, bne, jump;
  wire jal;
  wire blt, bnez, bgez;

  // Define format
  assign R_type = (instr_op_i == 6'b000000) ? 1 : 0;
  assign addi   = (instr_op_i == 6'b010011) ? 1 : 0;
  assign lw     = (instr_op_i == 6'b011000) ? 1 : 0;
  assign sw     = (instr_op_i == 6'b101000) ? 1 : 0;
  assign beq    = (instr_op_i == 6'b011001) ? 1 : 0;
  assign bne    = (instr_op_i == 6'b011010) ? 1 : 0;
  assign jump   = (instr_op_i == 6'b001100) ? 1 : 0;
  assign jal    = (instr_op_i == 6'b001111) ? 1 : 0;
  assign blt    = (instr_op_i == 6'b011100) ? 1 : 0;
  assign bnez   = (instr_op_i == 6'b011101) ? 1 : 0;
  assign bgez   = (instr_op_i == 6'b011110) ? 1 : 0;

  // Wire the control signal and the format
  assign RegWrite_o   = (R_type | addi | lw | jal) ? 1 : 0;
  assign ALUOp_o      = (R_type)           ? 3'b010 :
                        (addi | lw | sw)   ? 3'b000 :
                        (beq | bne | bnez) ? 3'b001 :
                        (blt | bgez)       ? 3'b011 : 3'b000;
  assign ALUSrc_o     = (addi | lw | sw) ? 1 : 0;
  assign RegDst_o     = (R_type) ? 1 : 0;
  assign Jump_o       = (jump | jal) ? 1 : 0;
  assign Branch_o     = (beq | bne | blt | bnez | bgez) ? 1 : 0;
  assign BranchType_o = (bne | blt | bnez) ? 1 : 0; // bne choose 1
  assign MemRead_o    = (lw) ? 1 : 0;
  assign MemWrite_o   = (sw) ? 1 : 0;
  assign MemtoReg_o   = (lw) ? 1 : 0;

endmodule
