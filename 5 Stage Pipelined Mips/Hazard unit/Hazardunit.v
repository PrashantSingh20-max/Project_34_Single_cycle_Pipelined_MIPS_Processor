
module hazard_unit (
			input[4:0]rsD,rtD,rsE,rtE,
			input[4:0]writeregE,writeregM,writeregW,
			input regwriteE,regwriteM,regwriteW,
			input memtoregE,memtoregM,
			input branchD,
			output reg[1:0]forwardaE,forwardbE,
			output forwardaD,forwardbD,
			output stallF,stallD,flushE,
			input jumpD  
);

 
//forwarding to decode stage
// Forwarding is necessary when an instruction in the Execute stage
// has a source register matching the destination register of an instruction
// in the Memory or Writeback stage.

//forwarding source to D stage
assign forwardaD=(rsD!=0 & rsD==writeregM & regwriteM);
assign forwardbD=(rtD!=0 & rtD==writeregM & regwriteM);

//forward source to E stage
 always @(*) begin
        forwardaE = 2'b00;
        forwardbE = 2'b00;

        if (rsE != 0) begin
            if ((rsE == writeregM) && regwriteM)
                forwardaE = 2'b10;
            else if ((rsE == writeregW) && regwriteW)
                forwardaE = 2'b01;
        end

        if (rtE != 0) begin
            if ((rtE == writeregM) && regwriteM)
                forwardbE = 2'b10;
            else if ((rtE == writeregW) && regwriteW)
                forwardbE = 2'b01;
        end
    end

//stall logic
wire lwstallD, branchstallD;
assign lwstallD = memtoregE && ((rtE == rsD) || (rtE == rtD));
 assign branchstallD = branchD &&
                         ((regwriteE && ((writeregE == rsD) || (writeregE == rtD))) ||
                          (memtoregM && ((writeregM == rsD) || (writeregM == rtD))));assign stallD=lwstallD | branchstallD;


assign stallD = lwstallD || branchstallD;

//stalling D stalls all previous stage
 assign stallF = stallD;

 // stalling D flushes next stage
 assign flushE = stallD;
 // Note: not necessary to stall D stage on store 
 //       if source comes from load;
 //       instead, another bypass network could 
 //       be added from W to M
endmodule

