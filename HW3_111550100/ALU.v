module ALU (
    aluSrc1,
    aluSrc2,
    ALU_operation_i,
    result,
    zero,
    overflow
);

  //I/O ports
  input [32-1:0] aluSrc1;
  input [32-1:0] aluSrc2;
  input [4-1:0] ALU_operation_i;

  output [32-1:0] result;
  output zero;
  output overflow;

  //Internal Signals
  wire [32-1:0] result;
  wire zero;
  wire overflow;

  //Main function
  /*your code here*/
  assign result = (ALU_operation_i == 4'b0000) ? aluSrc1 & aluSrc2 :
                  (ALU_operation_i == 4'b0001) ? aluSrc1 | aluSrc2 :
                  (ALU_operation_i == 4'b0010) ? aluSrc1 + aluSrc2 :
                  (ALU_operation_i == 4'b0110) ? aluSrc1 - aluSrc2 :
                  (ALU_operation_i == 4'b0111) ? $signed(aluSrc1) < $signed(aluSrc2) : 
                  (ALU_operation_i == 4'b1100) ? (~(aluSrc1 | aluSrc2)) : 32'd0;
  assign zero = ~(|result);
  assign overflow = ((ALU_operation_i == 4'b0010 && aluSrc1[31] == 1'b0 && aluSrc2[31] == 1'b0 && result[31] == 1'b1) || 
                     (ALU_operation_i == 4'b0010 && aluSrc1[31] == 1'b1 && aluSrc2[31] == 1'b1 && result[31] == 1'b0) ||
                     (ALU_operation_i == 4'b0110 && aluSrc1[31] == 1'b0 && aluSrc2[31] == 1'b1 && result[31] == 1'b1) || 
                     (ALU_operation_i == 4'b0110 && aluSrc1[31] == 1'b1 && aluSrc2[31] == 1'b0 && result[31] == 1'b0)) ? 1 : 0;

endmodule
