//controller c(clk,reset,instrD[31:26],instrD[5:0],orpcsrcD,flushE,alucontrolE,alusrcE,
//		regdstE,memwriteM,regwriteW,memtoregW,equalD,pcsrcD);
module controller(
		input clk,reset,
		//decode stage cntrl signal
		input[5:0]opD,
		input[5:0]functD,
		output orpcsrcD,
		//Execute stage cntrl signal
		input flushE,
		//for datapath and hazard unit
		output[2:0]alucontrolE,
		output alusrcE,
		output regdstE,
		//Memory stage cntrl Signal
		output memwriteM,
		//Memory stage cntrl Signal
		output regwriteW,
		output memtoregW,

		input equalD,
		output[1:0]pcsrcD
		
);

//pipelined cntrl Signal
wire regwriteD,regwriteE,regwriteM;
wire memtoregD,memtoregE,memtoregM;
wire memwriteD,memwriteE;
wire [2:0]alucontrolD;
wire alusrcD;
wire regdstD;
wire branchD;
wire [1:0]aluopD;
wire jump;

assign orpcsrcD=pcsrcD[1] | pcsrcD[0];
//decode stage logic
maindecoder md(opD,memtoregD,memwriteD,branchD,alusrcD,regdstD,regwriteD,jumpD,aluopD);
aludec ad(functD,aluopD,alucontrolD);


//execute stage pipeline control reg
floprc #(8) controlregE(clk,reset,flushE,{regwriteD,memtoregD,memwriteD,alucontrolD,alusrcD,regdstD},
					{regwriteE,memtoregE,memwriteE,alucontrolE,alusrcE,regdstE});

assign pcsrcD = (jumpD)              ? 2'b10 :  // Jump
                (branchD & equalD)   ? 2'b01 :  // Branch taken
                                      2'b00;   // PC + 4 (default)

//memory stage pipeline control reg
flopr#(3) controlregM(clk,reset,{regwriteE,memtoregE,memwriteE},
			        {regwriteM,memtoregM,memwriteM}
);

//writeback stage pipeline reg
flopr #(2) controlregW(clk,reset,{regwriteM,memtoregM},{regwriteW,memtoregW});

endmodule


