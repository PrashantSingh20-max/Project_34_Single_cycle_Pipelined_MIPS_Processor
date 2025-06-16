/*
module top(input  clk, reset,);
  
  // instantiate processor and memories
  mipspipe mips();
  imem imem(); // used for instruction 
  dmem dmem(); // used for memory 
endmodule

*/

module top(input  clk, reset,
          output  [31:0] writedataM, aluoutM,
          output  memwriteM);
  wire [31:0] pcF, instrF, readdataM;
  // instantiate processor and memories
  mipspipe mips(clk, reset, pcF, instrF, memwriteM, aluoutM, writedataM, readdataM);
  imem imem(pcF[7:2], instrF); // used for instruction 
  dmem dmem(clk, memwriteM, aluoutM, writedataM, readdataM); // used for memory 
endmodule
