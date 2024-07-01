module tb_top();

   import uvm_pkg::*;

   bit clk, rst;
   always #10 clk = ~clk;
   
   registers_if rif(.rst, .clk);
   registers registers_0(.rif);

   initial begin
      #100;

      rst = 1;
      #20;
      rst = 0;
      
      $finish;
   end
   
endmodule
