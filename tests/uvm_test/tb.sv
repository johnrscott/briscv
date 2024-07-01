module tb_top();

   import uvm_pkg::*;
   import pkg::*
   
   bit clk;
   always #10 clk <= ~clk;

   reg_if reg_if_0(clk);
   dut_wrapper dut_wrapper_0(._if(dut_if_0));

   initial begin
      uvm_config_db #(virtual dut_if)::set (null, "uvm_test_top", "reg_if", dut_if1);
      run_test("test");
   end

   initial begin
      $dumpvars;
      $dumpfile("dump.vcd");
   end
   
endmodule
