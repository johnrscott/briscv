`include "alu.sv"
`include "alu_if.sv"
`include "uvm_macros.svh"

import uvm_pkg::*;

class alu_transaction extends uvm_sequence_item;
   rand bit [31:0] a;
   rand bit [31:0] b;
   bit [2:0]	   r;
   
   function new(string name = "");
      super.new(name);
   endfunction
   
   `uvm_object_utils_begin(alu_transaction)
      `uvm_field_int(a, UVM_ALL_ON)
      `uvm_field_int(b, UVM_ALL_ON)
      `uvm_field_int(r, UVM_ALL_ON)
   `uvm_object_utils_end
   
endclass

class alu_sequence extends uvm_sequence#(alu_transaction);
   `uvm_object_utils(alu_sequence)
   
   function new(string name = "");
      super.new(name);
   endfunction
   
   task body();
      alu_transaction alu_tx;
      
      repeat(15) begin
         alu_tx = alu_transaction::type_id::create();
	 
         start_item(alu_tx);
         assert(alu_tx.randomize());
         finish_item(alu_tx);
      end
   endtask
endclass // alu_sequence

typedef uvm_sequencer#(alu_transaction) alu_sequencer;

module alu_tb_top;
   
   // Interface declaration
   alu_if vif();
   
   // Connects the Interface to the DUT
   alu dut(.a(vif.a), .b(vif.b), .alu_op(vif.alu_op), .r(vif.r), .zero(vif.zero));
   
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
