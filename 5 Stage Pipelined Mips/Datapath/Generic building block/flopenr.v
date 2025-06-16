
module flopenr #(parameter width=8)
  ( input clk,reset,en,
   input [width-1:0]d,
   output reg[width-1:0]q
  );
  
  always @(posedge clk,posedge reset)
    
      if(reset)
        q<=0;
      else if(en)
        q<=d;

      endmodule
      
      