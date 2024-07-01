module tb_top();

   import uvm_pkg::*;
   import tests_pkg::*;
   
   bit clk, rst;
   always #10 clk = ~clk;
   
   registers_if rif(.rst, .clk);
   registers registers_0(.rif);

   initial begin

      uvm_config_db #(virtual registers_if)::set(null, "uvm_test_top", "rif", rif);

      run_test("registers_test");
      
   end
   
endmodule
