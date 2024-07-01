`include "uvm_macros.svh"

package tests_pkg;

   import uvm_pkg::*;
   
   class registers_test extends uvm_test;

      `uvm_component_utils(registers_test)

      function new(string name = "registers_test", uvm_component parent = null);
	super.new(name, parent);
      endfunction

      virtual function void build_phase(uvm_phase phase);
	 super.build_phase(phase);
	 
	 
	 
      endfunction

      virtual function void end_of_elaboration_phase(uvm_phase phase);
	 uvm_top.print_topology();
      endfunction
      

      virtual task run_phase(uvm_phase phase);

	 `uvm_info("TEST", "This is a test", UVM_MEDIUM);
	 
      endtask
      
   endclass

endpackage
