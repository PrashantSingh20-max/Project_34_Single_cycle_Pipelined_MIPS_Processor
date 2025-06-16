
module dmem (
    input clk,
    input we,
    input [31:0] a,
    input [31:0] wd,
    output reg [31:0] rd
);

  reg [31:0] RAM[63:0];
  assign rd = RAM[a[31:2]];
integer i;
  always @(posedge clk)
    if (we) RAM[a[31:2]] <= wd;
initial begin
          $display("Data Memory Contents (RAM[0] to RAM[25]):");
    for (i = 0; i <= 25; i = i + 1) begin
        $display("RAM[%0d] = %h", i, RAM[i]);
    end
end
endmodule