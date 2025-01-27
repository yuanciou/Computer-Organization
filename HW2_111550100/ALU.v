`include "ALU_1bit.v"
module ALU (
    aluSrc1,
    aluSrc2,
    invertA,
    invertB,
    operation,
    result,
    zero,
    overflow
);

  //I/O ports
  input [32-1:0] aluSrc1;
  input [32-1:0] aluSrc2;
  input invertA;
  input invertB;
  input [2-1:0] operation;

  output [32-1:0] result;
  output zero;
  output overflow;

  //Internal Signals
  wire [32-1:0] result;
  wire zero;
  wire overflow;

  //Main function
  /*your code here*/
  wire [31: 0] carry;
  wire set;
  ALU_1bit ALU0(
    aluSrc1[0],
    aluSrc2[0],
    invertA,
    invertB,
    operation,
    invertB,
    set,
    result[0],
    carry[0]
  );

  genvar i;
  generate
    for(i = 1; i<=30; i = i+1)begin
      ALU_1bit ALU301(
        aluSrc1[i],
        aluSrc2[i],
        invertA,
        invertB,
        operation,
        carry[i-1],
        1'b0,
        result[i],
        carry[i]
      );
    end
  endgenerate

  ALU_1bit_31 ALU31(
    aluSrc1[31],
    aluSrc2[31],
    invertA,
    invertB,
    operation,
    carry[30],
    1'b0,
    result[31],
    overflow,
    set
  );

  assign zero = ~|result;

endmodule
