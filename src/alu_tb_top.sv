`include "alu.sv"
`include "alu_if.sv"

module alu_tb_top;
   import uvm_pkg::*;
   
   // Interface declaration
   alu_if vif();
   
   // Connects the Interface to the DUT
   alu dut(.a(vif.a), .b(vif.b), .alu_op(vif.alu_op), .r(vif.r), .zero(zero));
   
   initial begin
      
      // Registers the Interface in the configuration block
      // so that other blocks can use it
      uvm_resource_db#(virtual alu_if)::set(
	 .scope("ifs"), .name("alu_if"), .val(vif)
      );
      
      // Executes the test
      run_test();
   
   end
 
   // Variable initialization
   initial begin
      vif.sig_clock = 1'b1;
   end
   
   // Clock generation
   // always
   //   #5 vif.sig_clock = ~vif.sig_clock;
endmodule
