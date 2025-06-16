//datapath dp(clk,reset,pcsrcD,stallF,pcF,instrF,equalD,instrD[31:26],instrD[5:0],stallD,orpcsrcD,
	//	flushE,forwardaE,forwardbE,forwardaD,forwardbD,regdstE,alusrcE,alucontrolE,memwriteM,
//		writedataM, aluresultM,readdataM,memtoregW,regwriteW,rsD,rtD,rsE,rtE,
//		forwardaD,forwardbD,instrD);

module datapath( 
		input clk,reset,
		input [1:0]pcsrcD,
		//fetch stage
		input stallF,
		output[31:0]pcF,
		input[31:0]instrF,
		//decode stage signal
		output equalD,
		output[6:0]opD,
		output[5:0]functD,
		input stallD,
		input orpcsrcD,
		//execute stage signal
		input flushE,
		input[1:0]forwardaE,forwardbE,
			
		input regdstE,
		input alusrcE,
		input [2:0]alucontrolE,
		
		//memory stage signal
		input memwriteM,
		output [31:0] writedataM, aluresultM,
		input[31:0]readdataM,
		//output [4:0]writeregM,
		//writeback stage signal
		input memtoregW,
		input regwriteW,
		//hazard unit signal
		output [4:0] rsD,rtD,rsE,rtE,

		input forwardaD,forwardbD,
		output[31:0]instrD

);

wire[31:0]pcnextF,pcplus4F,pcbranchD,z;
//fetch stage pipeline register and logic
mux3    #(31)pcmux(pcplus4F,pcbranchD,z ,pcsrcD,pcnextF);
flopenr #(32)pcreg(clk,reset,~stallF,pcnextF,pcF);
adder      pcadd(pcF,32'h4,pcplus4F);

////////////////////////////////////////////////////////////////////////////

wire[31:0]rd1D,rd2D,equala,equalb;
wire[31:0]signimmD,signimmDresult,pcplus4D;
//decode stage pipeline register and logic
flopenrc #(64) regD(clk,reset,orpcsrcD,~stallD,
		  {instrF,pcplus4F},{instrD,pcplus4D});

assign opD=instrD[31:26];
assign functD=instrD[5:0];

assign rs1D=instrD[25:21];   //source register 1 in decode stage
assign rs2D=instrD[20:16];   // source register 2 in decode stage
assign rdD=instrD[15:11];      //destination register

regfile rf(clk,regwriteW,rs1D,rs2D,writeregW,resultW,rd1D,rd2D);  //resultW=WD3,rs1D=A,rs2D=A2,rdW=A3
signext signext(instrD[15:0],signimmD);
sl2 ls(signimmD,signimmDresult);
adder branchadd(signimmDresult,pcplus4D,pcbranchD);
leftshiftconcat ls2(pcplus4F[31:28],instrD[25:0],z);   // not understood why

mux2 #(32)rd1(rd1D,aluoutM,forwardaD,equala);
mux2 #(32)rd2(rd2D,aluoutM,forwardbD,equalb);

comparator comp(equala,equalb,equalD);


//execute stage signal

wire[31:0]rd1E,rd2E;
wire[31:0]signimmE;
wire[31:0]srcaE,srcbE;
wire[31:0]writedataE;
wire[31:0]aluresultE;
wire[4:0]writeregE;


//execute stage logic
floprc #(111) regE(clk,reset,flushE,{rd1D,rd2D,rsD,rtD,rdD,signimmD},
				 {rd1E,rd2E,rsE,rtE,rdE,signimmE}
);
mux2 #(32) muxinexecutestage(rtE,rdE,regdstE,writeregE);
mux3 #(32) faemux(rd1E,resultW,aluoutM,forwardaE,srcaE); //forwarding in execute stage mux
mux3 #(32) fbemux(rd2E,resultW,aluoutM,forwardbE,writedataE);
mux2 #(32) srcbmux(writedataE,signimmE,alusrcE,srcbE);

alu32 alu(srcaE,srcbE,alucontrolE,aluresultE);

///////////////////
wire[4:0]writeregM;
//memory stage pipeline
flopr #(69)regM(clk,reset,{aluresultE,writedataE,writeregE}
                       ,{aluresultM,writedataM,writeregM}
);

///////////
wire[31:0]readdataW;
wire[31:0] aluoutW;
//wire[31:0] resultW;
//wire[4:0]writeregW;
//writeback stage pipeline reg and logic
flopr #(69) regW( clk,reset,{readdataM,aluoutM,writeregM},
			  {readdataW,aluoutW,writeregW}
);

mux2 #(32) resultmux(readdataW,aluoutW,memtoregW,resultW);


endmodule
