//Memory modules
module imem (
    input  [5:0] a,
    output [31:0] rd
);
    reg [31:0] RAM[63:0];
integer i;
    initial begin
    
    $readmemh("memfile.dat", RAM);

    $display("Instruction Memory Contents (RAM[0] to RAM[25]):");
    for (i = 0; i <= 25; i = i + 1) begin
        $display("RAM[%0d] = %h", i, RAM[i]);
    end
end


assign rd=RAM[a]; //word aligned
endmodule