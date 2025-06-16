//  mipspipe mips(clk, reset, pc, instr, memwrite, dataadr, writedata, readdata, RegWriteW);
module mipspipe( input clk,reset,
		output [31:0]pcF,
		input[31:0]instrF,
		output memwriteM,
		output[31:0]aluoutM,writedataM,
		input[31:0]readdataM
);

wire[5:0] opD;
wire[5:0] funct;
wire[1:0]pcsrcD;
wire orpcsrcD;
wire equalD;
wire alusrcE;
wire[2:0]alucontrolE;

wire memtoregW;

wire [1:0]  forwardaE, forwardbE;
wire  stallF, stallD, flushE; 

wire [4:0] rsD, rtD, rsE, rtE;
wire memtoregE,regwriteE,regwriteM,regwriteW;
wire branchD,jumpD;
wire[31:0] instrD;
controller c(clk,reset,instrD[31:26],instrD[5:0],orpcsrcD,flushE,alucontrolE,alusrcE,
		regdstE,memwriteM,regwriteW,memtoregW,equalD,pcsrcD);



datapath dp(clk,reset,pcsrcD,stallF,pcF,instrF,equalD,instrD[31:26],instrD[5:0],stallD,orpcsrcD,
		flushE,forwardaE,forwardbE,regdstE,alusrcE,alucontrolE,memwriteM,
		writedataM, aluresultM,readdataM,memtoregW,regwriteW,rsD,rtD,rsE,rtE,
		forwardaD,forwardbD,instrD);



hazard_unit hu(rsD,rtD,rsE,rtE,writeregE,writeregM,writeregW,regwriteE,regwriteM,regwriteW,
		memtoregE,memtoregM,branchD,forwardaE,forwardbE,stallF,stallD,flushE,jumpD );
endmodule