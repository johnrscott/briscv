
module tb_top();

   import uvm_pkg::*;


   bit clk;
   always #10 clk = ~clk;

   initial begin
      #100;
      $finish;
   end
   
endmodule
