`include "Program_Counter.v"
`include "Adder.v"
`include "Instr_Memory.v"
`include "Mux2to1.v"
`include "Mux3to1.v"
`include "Reg_File.v"
`include "Decoder.v"
`include "ALU_Ctrl.v"
`include "Sign_Extend.v"
`include "Zero_Filled.v"
`include "ALU.v"
`include "Shifter.v"
`include "Data_Memory.v"

module Simple_Single_CPU (
    clk_i,
    rst_n
);

  //I/O port
  input clk_i;
  input rst_n;

  //Internal Signles
  wire [31: 0] pc_in, pc_out, pc_add4;
  wire [31: 0] sign_exten_data;
  wire [31: 0] pc_branch;
  wire [31: 0] pc_add4_branch;
  wire Branch, type_zero;
  wire [31: 0] instruction;
  wire [31: 0] pc_next;
  wire Jump;
  wire RegDst;
  wire BranchType;
  wire [ 4: 0] rs_rt, write_register;
  wire [31: 0] write_data;
  wire RegWrite, Jr;
  wire [31: 0] read_data_1, read_data_2;
  wire [ 2: 0] ALUOp;
  wire ALUSrc, MemRead, MemWrite, MemtoReg;
  wire [ 3: 0] ALU_operation;
  wire [ 1: 0] FURslt;
  wire leftRight, shiftVar;
  wire [31: 0] zero_filled_data;
  wire [31: 0] ALUSrc_data_B;
  wire [31: 0] ALU_result;
  wire Zero, Overflow;
  wire [31: 0] shamt;
  wire [31: 0] shifter_result;
  wire [31: 0] Rd_data;
  wire [31: 0] Mem_data;
  wire [31: 0] write_data_temp;

  //modules
  // 1
  Program_Counter PC (
      .clk_i(clk_i),
      .rst_n(rst_n),
      .pc_in_i(pc_in),
      .pc_out_o(pc_out)
  );
  
  // 2
  Adder Adder1 (
      .src1_i(pc_out),
      .src2_i(32'd4),
      .sum_o (pc_add4)
  );
  
  // 3
  Adder Adder2 (
      .src1_i(pc_add4),
      .src2_i(sign_exten_data << 2),
      .sum_o (pc_branch)
  );

  // 4
  Mux2to1 #(
      .size(32)
  ) Mux_branch (
      .data0_i (pc_add4),
      .data1_i (pc_branch),
      .select_i(Branch & type_zero),
      .data_o  (pc_add4_branch)
  );

  // 5
  Mux2to1 #(
      .size(32)
  ) Mux_jump (
      .data0_i (pc_add4_branch),
      .data1_i ({pc_add4[31:28], instruction[25: 0], 2'b00}),
      .select_i(Jump),
      .data_o  (pc_next)
  );

  //!!!!
  Mux2to1 #(
      .size(1)
  ) Mux_zero_type (
      .data0_i (Zero),
      .data1_i (~Zero),
      .select_i(BranchType),
      .data_o  (type_zero)
  );

  //!!!!!!!!!!!!!!!!!!!!!!!!!
  Mux2to1 #(
      .size(32)
  ) Mux_Jr_to_pc (
      .data0_i (pc_next),
      .data1_i (read_data_1),
      .select_i(Jr),
      .data_o  (pc_in)
  );

  Instr_Memory IM (
      .pc_addr_i(pc_out),
      .instr_o  (instruction)
  );
  
  // ????????????
  Mux2to1 #(
      .size(5)
  ) Mux_rt_rd (
      .data0_i (instruction[20:16]),
      .data1_i (instruction[15:11]),
      .select_i(RegDst),
      .data_o  (rs_rt)
  );
  
  // 7
  Mux2to1 #(
      .size(5)
  ) Mux_Write_Reg (
      .data0_i (rs_rt),
      .data1_i (5'd31),
      .select_i(Jump),
      .data_o  (write_register)
  );

  Reg_File RF (
      .clk_i(clk_i),
      .rst_n(rst_n),
      .RSaddr_i(instruction[25:21]),
      .RTaddr_i(instruction[20:16]),
      .RDaddr_i(write_register),
      .RDdata_i(write_data),
      .RegWrite_i(RegWrite & (~Jr)),
      .RSdata_o(read_data_1),
      .RTdata_o(read_data_2)
  );

  Decoder Decoder (
      .instr_op_i(instruction[31:26]),
      .RegWrite_o(RegWrite),
      .ALUOp_o(ALUOp),
      .ALUSrc_o(ALUSrc),
      .RegDst_o(RegDst),
      .Jump_o(Jump),
      .Branch_o(Branch),
      .BranchType_o(BranchType),
      .MemRead_o(MemRead),
      .MemWrite_o(MemWrite),
      .MemtoReg_o(MemtoReg)
  );

  ALU_Ctrl AC (
      .funct_i(instruction[ 5: 0]),
      .ALUOp_i(ALUOp),
      .ALU_operation_o(ALU_operation),
      .FURslt_o(FURslt),
      .leftRight_o(leftRight),
      .shiftVar_o(shiftVar),
      .jr_o(Jr)
  );

  Sign_Extend SE (
      .data_i(instruction[15: 0]),
      .data_o(sign_exten_data)
  );

  Zero_Filled ZF (
      .data_i(instruction[15: 0]),
      .data_o(zero_filled_data)
  );

  Mux2to1 #(
      .size(32)
  ) ALU_src2Src (
      .data0_i (read_data_2),
      .data1_i (sign_exten_data),
      .select_i(ALUSrc),
      .data_o  (ALUSrc_data_B)
  );

  ALU ALU (
      .aluSrc1(read_data_1),
      .aluSrc2(ALUSrc_data_B),
      .ALU_operation_i(ALU_operation),
      .result(ALU_result),
      .zero(Zero),
      .overflow(Overflow)
  );

  //!!!!!!!
  Mux2to1 #(
      .size(32)
  ) ALU_Shamt (
      .data0_i ({27'b0, instruction[10: 6]}),
      .data1_i (read_data_1), // no bigger than 32bit
      .select_i(shiftVar),
      .data_o  (shamt)
  );

  Shifter shifter (
      .result(shifter_result),
      .leftRight(leftRight),
      .shamt(shamt),
      .sftSrc(ALUSrc_data_B)
  );

  Mux3to1 #(
      .size(32)
  ) RDdata_Source (
      .data0_i (ALU_result),
      .data1_i (shifter_result),
      .data2_i (zero_filled_data),
      .select_i(FURslt),
      .data_o  (Rd_data)
  );

  Data_Memory DM (
      .clk_i(clk_i),
      .addr_i(Rd_data),
      .data_i(read_data_2),
      .MemRead_i(MemRead),
      .MemWrite_i(MemWrite),
      .data_o(Mem_data)
  );

  Mux2to1 #(
      .size(32)
  ) Mux_Write (
      .data0_i(Rd_data),
      .data1_i(Mem_data),
      .select_i(MemtoReg), // ????
      .data_o(write_data_temp)
  );

  //!!!!!!!
  Mux2to1 #(
      .size(32)
  ) Mux_Jal (
      .data0_i(write_data_temp),
      .data1_i(pc_add4),
      .select_i(Jump),
      .data_o(write_data)
  );

endmodule



