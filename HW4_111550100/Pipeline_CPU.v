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
`include "Pipe_Reg.v"

module Pipeline_CPU (
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

  // IF/ID
  wire [31: 0] instr_if2id;

  // ID/EXE
  wire [31: 0] instr_id2exe;
  wire [31: 0] read_data1_id2exe;
  wire [31: 0] read_data2_id2exe;
  wire [31: 0] sign_exten_data_id2exe;
  wire [31: 0] zero_filled_data_id2exe;
  wire [ 2: 0] ALU_op_id2exe;
  wire RegWrite_id2exe, ALUSrc_id2exe, RegDst_id2exe, MemRead_id2exe;
  wire MemWrite_id2exe, MemtoReg_id2exe;

  // EXE/MEM
  wire [ 4: 0] write_register_exe2mem;
  wire [31: 0] read_data2_exe2mem;
  wire [31: 0] Rd_data_exe2mem;
  wire RegWrite_exe2mem, MemRead_exe2mem, MemWrite_exe2mem, MemtoReg_exe2mem;

  // MEM/WB
  wire [31: 0] Rd_data_mem2wb;
  wire [31: 0] Mem_data_mem2wb;
  wire [ 4: 0] write_register_mem2wb;
  wire RegWrite_mem2wb, MemtoReg_mem2wb;

  //modules

  //-----------------------------------------
  //                  IF
  //-----------------------------------------
  Program_Counter PC (
      .clk_i(clk_i),
      .rst_n(rst_n),
      .pc_in_i(pc_in),
      .pc_out_o(pc_out)
  );
  
  Adder Adder1 (
      .src1_i(pc_out),
      .src2_i(32'd4),
      .sum_o (pc_in)
  );

  Instr_Memory IM (
      .pc_addr_i(pc_out),
      .instr_o  (instruction)
  );

  //---------------IF  /  ID-----------------
  Pipe_Reg #(
      .size(32)
  ) PR_instr_ifid (
      .clk_i (clk_i),
      .rst_n (rst_n),
      .data_i (instruction),
      .data_o (instr_if2id)
  );
  
  //-----------------------------------------
  //                  ID
  //-----------------------------------------
  Reg_File RF (
      .clk_i(clk_i),
      .rst_n(rst_n),
      .RSaddr_i(instr_if2id[25:21]),
      .RTaddr_i(instr_if2id[20:16]),
      .RDaddr_i(write_register_mem2wb),
      .RDdata_i(write_data),
      .RegWrite_i(RegWrite_mem2wb & (~Jr)),
      .RSdata_o(read_data_1),
      .RTdata_o(read_data_2)
  );

  Decoder Decoder (
      .instr_op_i(instr_if2id[31:26]),
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

  Sign_Extend SE (
      .data_i(instr_if2id[15: 0]),
      .data_o(sign_exten_data)
  );

  Zero_Filled ZF (
      .data_i(instr_if2id[15: 0]),
      .data_o(zero_filled_data)
  );

  //---------------ID  /  EXE----------------
  Pipe_Reg #(
      .size(32)
  ) PR_instr_idexe (
      .clk_i (clk_i),
      .rst_n (rst_n),
      .data_i (instr_if2id),
      .data_o (instr_id2exe)
  );
  
  Pipe_Reg #(
      .size(64)
  ) PR_RS_RTdata_idexe (
      .clk_i (clk_i),
      .rst_n (rst_n),
      .data_i ({read_data_1, read_data_2}),
      .data_o ({read_data1_id2exe, read_data2_id2exe})
  );

  Pipe_Reg #(
      .size(32)
  ) PR_sign_extren_idexe (
      .clk_i (clk_i),
      .rst_n (rst_n),
      .data_i (sign_exten_data),
      .data_o (sign_exten_data_id2exe)
  );
  
  Pipe_Reg #(
      .size(9)
  ) PR_control_idexe (
      .clk_i (clk_i),
      .rst_n (rst_n),
      .data_i ({ALUOp, RegWrite, ALUSrc, RegDst, MemRead, MemWrite, MemtoReg}),
      .data_o ({ALU_op_id2exe, RegWrite_id2exe, ALUSrc_id2exe, RegDst_id2exe, MemRead_id2exe, MemWrite_id2exe, MemtoReg_id2exe})
  );

  //-----------------------------------------
  //                  EXE
  //-----------------------------------------

  Mux2to1 #(
      .size(5)
  ) Mux_rt_rd (
      .data0_i (instr_id2exe[20:16]),
      .data1_i (instr_id2exe[15:11]),
      .select_i(RegDst_id2exe),
      .data_o  (write_register)
  );
  
  ALU_Ctrl AC (
      .funct_i(instr_id2exe[ 5: 0]),
      .ALUOp_i(ALU_op_id2exe),
      .ALU_operation_o(ALU_operation),
      .FURslt_o(FURslt),
      .leftRight_o(leftRight),
      .shiftVar_o(shiftVar),
      .jr_o(Jr)
  );

  Mux2to1 #(
      .size(32)
  ) ALU_src2Src (
      .data0_i (read_data2_id2exe),
      .data1_i (sign_exten_data_id2exe),
      .select_i(ALUSrc_id2exe),
      .data_o  (ALUSrc_data_B)
  );

  ALU ALU (
      .aluSrc1(read_data1_id2exe),
      .aluSrc2(ALUSrc_data_B),
      .ALU_operation_i(ALU_operation),
      .result(ALU_result),
      .zero(Zero),
      .overflow(Overflow)
  );

  Mux2to1 #(
      .size(32)
  ) ALU_Shamt (
      .data0_i ({27'b0, instr_id2exe[10: 6]}),
      .data1_i (read_data1_id2exe),
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
      .data2_i (zero_filled_data_id2exe),
      .select_i(FURslt),
      .data_o  (Rd_data)
  );

  //--------------EXE  /  MEM----------------

  Pipe_Reg #(
      .size(69)
  ) PR_data_exemem (
      .clk_i (clk_i),
      .rst_n (rst_n),
      .data_i ({Rd_data, read_data2_id2exe, write_register}),
      .data_o ({Rd_data_exe2mem, read_data2_exe2mem, write_register_exe2mem})
  );

  Pipe_Reg #(
      .size(4)
  ) PR_control_exemem (
      .clk_i (clk_i),
      .rst_n (rst_n),
      .data_i ({RegWrite_id2exe, MemRead_id2exe, MemWrite_id2exe, MemtoReg_id2exe}),
      .data_o ({RegWrite_exe2mem, MemRead_exe2mem, MemWrite_exe2mem, MemtoReg_exe2mem})
  );

  //-----------------------------------------
  //                  MEM
  //-----------------------------------------

  Data_Memory DM (
      .clk_i(clk_i),
      .addr_i(Rd_data_exe2mem),
      .data_i(read_data2_exe2mem),
      .MemRead_i(MemRead_exe2mem),
      .MemWrite_i(MemWrite_exe2mem),
      .data_o(Mem_data)
  );

  //--------------MEM  /  WB-----------------

  Pipe_Reg #(
      .size(69)
  ) PR_data_memwb (
      .clk_i (clk_i),
      .rst_n (rst_n),
      .data_i ({Rd_data_exe2mem, Mem_data, write_register_exe2mem}),
      .data_o ({Rd_data_mem2wb, Mem_data_mem2wb, write_register_mem2wb})
  );

  Pipe_Reg #(
      .size(2)
  ) PR_control_memwb (
      .clk_i (clk_i),
      .rst_n (rst_n),
      .data_i ({RegWrite_exe2mem, MemtoReg_exe2mem}),
      .data_o ({RegWrite_mem2wb, MemtoReg_mem2wb})
  );
  
  //-----------------------------------------
  //                  WB
  //-----------------------------------------

  Mux2to1 #(
      .size(32)
  ) Mux_Write (
      .data0_i(Rd_data_mem2wb),
      .data1_i(Mem_data_mem2wb),
      .select_i(MemtoReg_mem2wb),
      .data_o(write_data)
  );

endmodule



