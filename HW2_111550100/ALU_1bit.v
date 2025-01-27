`include "Full_adder.v"
module ALU_1bit (
    a,
    b,
    invertA,
    invertB,
    operation,
    carryIn,
    less,
    result,
    carryOut
);

  //I/O ports
  input a;
  input b;
  input invertA;
  input invertB;
  input [2-1:0] operation;
  input carryIn;
  input less;

  output result;
  output carryOut;

  //Internal Signals
  wire result;
  wire carryOut;

  //Main function
  /*your code here*/
  wire true_a, true_b;
  assign true_a = (invertA) ? ~a : a;
  assign true_b = (invertB) ? ~b : b;

  wire sum;
  Full_adder F(carryIn, true_a, true_b, sum, carryOut);

  assign result = (operation[1]) ? ((operation[0]) ? sum :true_a | true_b) : ((operation[0]) ? less : true_a & true_b);

endmodule

module ALU_1bit_31 (
    a,
    b,
    invertA,
    invertB,
    operation,
    carryIn,
    less,
    result,
    overflow,
    set
);

  //I/O ports
  input a;
  input b;
  input invertA;
  input invertB;
  input [2-1:0] operation;
  input carryIn;
  input less;

  output result;
  output overflow, set;

  //Internal Signals
  wire result;
  wire carryOut;

  //Main function
  /*your code here*/
  wire true_a, true_b;
  assign true_a = (invertA) ? ~a : a;
  assign true_b = (invertB) ? ~b : b;

  wire sum;
  Full_adder F(carryIn, true_a, true_b, sum, carryOut);
  assign overflow = (operation == 2'b11) ? carryIn ^ carryOut : 0;
  assign set = (carryIn ^ carryOut) ^ sum;

  assign result = (operation[1]) ? ((operation[0]) ? sum :true_a | true_b) : ((operation[0]) ? less : true_a & true_b);

endmodule