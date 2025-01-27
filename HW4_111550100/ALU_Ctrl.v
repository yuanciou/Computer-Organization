module ALU_Ctrl (
    funct_i,
    ALUOp_i,
    ALU_operation_o,
    FURslt_o,
    leftRight_o,
    shiftVar_o, // handle shift variable:1 shamt:0
    jr_o // handle jr
);

  //I/O ports
  input [6-1:0] funct_i;
  input [3-1:0] ALUOp_i;

  output [4-1:0] ALU_operation_o;
  output [2-1:0] FURslt_o;
  output leftRight_o, shiftVar_o, jr_o;

  //Internal Signals
  wire [4-1:0] ALU_operation_o;
  wire [2-1:0] FURslt_o;
  wire leftRight_o, shiftVar_o, jr_o;

  //Main function
  /*your code here*/
  assign {ALU_operation_o, FURslt_o} = (ALUOp_i == 3'b010) ? ( // R-type
                                          (funct_i == 6'b100011) ? {4'b0010, 2'b00} :      // add 
                                          (funct_i == 6'b010011) ? {4'b0110, 2'b00} :      // sub
                                          (funct_i == 6'b011111) ? {4'b0000, 2'b00} :      // and
                                          (funct_i == 6'b101111) ? {4'b0001, 2'b00} :      // or
                                          (funct_i == 6'b010000) ? {4'b1100, 2'b00} :      // nor
                                          (funct_i == 6'b010100) ? {4'b0111, 2'b00} :      // slt
                                          (funct_i == 6'b010010) ? {4'b0010, 2'b01} :      //sll
                                          (funct_i == 6'b100010) ? {4'b0010, 2'b01} :      //srl
                                          (funct_i == 6'b011000) ? {4'b0010, 2'b01} :      //sllv
                                          (funct_i == 6'b101000) ? {4'b0010, 2'b01} : 0) : //srlv
                                       (ALUOp_i == 3'b000) ? {4'b0010, 2'b00} :    // addi lw sw
                                       (ALUOp_i == 3'b001) ? {4'b0110, 2'b00} :    // beq bne bnez
                                       (ALUOp_i == 3'b011) ? {4'b0111, 2'b00} : 0; // blt bqez
  
  assign leftRight_o = (ALUOp_i == 3'b010) ? (((funct_i == 6'b100010) || (funct_i == 6'b101000)) ? 1'b1 : 1'b0) : 1'b0; // srl srlv
  assign shiftVar_o =  (ALUOp_i == 3'b010) ? (((funct_i == 6'b011000) || (funct_i == 6'b101000)) ? 1'b1 : 1'b0) : 1'b0; // sllv srlv
  assign jr_o = (ALUOp_i == 3'b010) ? ((funct_i == 6'b000001) ? 1'b1 : 1'b0) : 1'b0; // jr

endmodule
