imageScreenshot 2025-06-18 002318![Screenshot 2025-06-18 002318](https://github.com/user-attachments/assets/3f51af91-d9c3-44ec-8d0c-b5913e1c4bc9)

5 Stage Single Cycle MIPS Processore with a Hazard Unit 5 Stage include => Fetch->Decode->Execute->Memory->writeback.

Hazards are classified as data hazards or control hazards. A data hazard occurs when an instruction tries to read a register that has not yet been written back by a previous instruction. A control hazard occurs when the decision of what instruction to fetch next has not been made by the time the fetch takes place.

Solving Data Hazards with Forwarding

Forwarding is necessary when an instruction in the Execute stage has a source register matching the destination register of an instructionin the Memory or Writeback stage.

The hazard detection unit computes control signals for the forwarding multiplexers to choose operands from the register file or from the results in the Memory or Writeback stage.

//Forward to Execute Stage from Either //->Memory stage //->Writeback stage

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
Forwarding is sufficient to solve RAW data hazards when the result is computed in the Execute stage of an instruction, because its result can then be forwarded to the Execute stage of the next instruction.

Unfortunately, the lw instruction does not finish reading data until the end of the Memory stage, so its result cannot be forwarded to the Execute stage of the next instruction.

We say that the lw instruction has a two-cycle latency, because a dependent instruction cannot use its result until two cycles later.

There is no way to solve this hazard with forwarding.

The alternative solution is to stall the pipeline, holding up operation until the data is available.

When a stage is stalled, all previous stages must also be stalled, so that no subsequent instructions are lost.

The pipeline register directly after the stalled stage must be cleared to prevent bogus information from propagating forward.

The hazard unit examines the instruction in the Execute stage

If it is lw and its destination register (rtE) matches either source operand of the instruction in the Decode stage (rsD or rtD), that instruction must be stalled in the Decode stage until the source operand is ready Stalls are supported by adding enable inputs (EN) to the Fetch and Decode pipeline registers and a synchronous reset/clear (CLR) input to the Execute pipeline register.

When a lw stall occurs, StallD and StallF are asserted to force the Decode and Fetch stage pipeline registers to hold their old values. FlushE is also asserted to clear the contents of the Execute stage pipeline register, introducing a bubble

The MemtoReg signal is asserted for the lw instruction. Hence, the logic to compute the stalls and flushes is

assign lwstallD = memtoregE && ((rtE == rsD) || (rtE == rtD));
stallF=stallD=flushE=lwstall
The beq instruction presents a control hazard An alternative is to predict whether the branch will be taken and begin executing instructions based on the prediction. In particular, suppose that we predict that branches are not taken and simply continue executing the program in order If the branch should have been taken, the three instructions following the branch must be flushed (discarded) by clearing the pipeline registers for those instructions. These wasted instruction cycles are called the branch misprediction penalty. We could reduce the branch misprediction penalty if the branch decision could be made earlier. Making the decision simply requires comparing the values of two registers. Using a dedicated equality com parator is much faster than performing a subtraction and zero detection. If the comparator is fast enough, it could be moved back into the Decode stage, so that the operands are read from the register file and compared to determine the next PC by the end of the Decode stage. Unfortunately, the early branch decision hardware introduces a new RAW data hazard. Specifically, if one of the source operands for the branch was computed by a previous instruction and has not yet been written into the register file, the branch will read the wrong operand value from the reg ister file. As before, we can solve the data hazard by forwarding the correct value if it is available or by stalling the pipeline until the data is ready. If a result is in the Writeback stage, it will be written in the first half of the cycle and read during the second half, so no hazard exists. If the result of an ALU instruction is in the Memory stage, it can be forwarded to the equality comparator through two new multiplexers. If the result of an ALU instruction is in the Execute stage or the result of a lw instruction is in the Memory stage, the pipeline must be stalled at the Decode stage until the result is ready.

    assign forwardaD=(rsD!=0 & rsD==writeregM & regwriteM);
    assign forwardbD=(rtD!=0 & rtD==writeregM & regwriteM);

    assign branchstallD = branchD &&
                     ((regwriteE && ((writeregE == rsD) || (writeregE == rtD))) ||
                      (memtoregM && ((writeregM == rsD) || (writeregM == rtD))));assign stallD=lwstallD | branchstallD;

      stallF=stallD=flushE=lwstall | branchstallD
