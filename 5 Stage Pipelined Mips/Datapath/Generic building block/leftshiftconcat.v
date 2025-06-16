
/*
// Shift Left 2
module sl2 (
    input [31:0] a,
    output [31:0] y
);

  assign y = a << 2;

endmodule

*/

//leftshiftconcat ls2(instrD[25:0],instr[31:28],z);   // not understood why
module leftshiftconcat(
			input[3:0]a,
			input[25:0]b,
			output[31:0]result
);

assign result={b,a<<2};
endmodule
