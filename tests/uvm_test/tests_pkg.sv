`include "uvm_macros.svh"

package tests_pkg;

   import uvm_pkg::*;

   class reg_item extends uvm_sequence_item;

      // Bus data
      rand bit	      wr;
      rand bit [1:0] addr;
      rand bit [31:0] wdata;
      bit [31:0]      rdata;

      // Handshake
      rand bit	      ready;
      bit	      valid;

      `uvm_object_utils_begin(reg_item)
	 `uvm_field_int(wr, UVM_DEFAULT);
	 `uvm_field_int(addr, UVM_DEFAULT);
	 `uvm_field_int(wdata, UVM_DEFAULT);
	 `uvm_field_int(rdata, UVM_DEFAULT);
	 `uvm_field_int(ready, UVM_DEFAULT);
	 `uvm_field_int(valid, UVM_DEFAULT);
      `uvm_object_utils_end

      virtual function string convert2string();
	 return $sformatf("wr=0x%0h addr=0x%0h wdata=0x%0h rdata=0x%0h ready=0x%0h valid=0x%0h",
			  wr, addr, wdata, rdata, ready, valid);
      endfunction
      
      function new (string name = "reg_item");
	 super.new(name);
      endfunction // new
      
   endclass

   class registers_driver extends uvm_driver #(reg_item);

      `uvm_component_utils(registers_driver)
      
      function new (string name = "registers_driver", uvm_component parent = null);
	 super.new(name, parent);
      endfunction // new

      // This is the interface used to communicate with the
      // device under test. It comes from the uvm_config_db,
      // which was populated in the top-level testbench
      virtual registers_if rif;

      virtual function void build_phase(uvm_phase phase);
	 super.build_phase(phase);
	 if (!uvm_config_db#(virtual registers_if)::get(this, "", "rif", rif))
	   `uvm_fatal(get_type_name(), "Failed to get interface handle for rif");
	 
      endfunction

      // Send transactions from the sequencer to the device
      virtual task run_phase(uvm_phase phase);
	 super.run_phase(phase);
	 forever begin
	    reg_item item;
	    
	    seq_item_port.get_next_item(item);
	    `uvm_info("DRV", "Waiting for item from sequencer", UVM_LOW);
	    drive_item(item);
	    seq_item_port.item_done();
	 end
      endtask

      task drive_item(reg_item item);

	 rif.wr = item.wr;
	 rif.addr = item.addr;
	 rif.wdata = item.wdata;
	 rif.valid = 1; // Maybe this shouldn't be in the reg_item?
	 @(posedge rif.clk);
	 while (!rif.ready) begin
	    `uvm_info("DRV", "Wait until ready is high", UVM_LOW);
	    @(posedge rif.clk);
	 end

	 rif.valid = 0;
	
      endtask
      
   endclass
   
   // The agent combines the driver, monitor and sequencer. It is responsible
   // for sending transactions from the sequencer to the driver (and to the dut)
   // and receiving data back to the monitor.
   class registers_agent extends uvm_agent;

      `uvm_component_utils(registers_agent)
      
      function new (string name = "registers_agent", uvm_component parent = null);
	 super.new(name, parent);
      endfunction
      
      registers_driver d0;
      uvm_sequencer #(reg_item) s0;

      virtual function void build_phase(uvm_phase phase);
	 super.build_phase(phase);
	 d0 = registers_driver::type_id::create("d0", this);
	 s0 = uvm_sequencer #(reg_item)::type_id::create("s0", this);
      endfunction

      virtual function void connect_phase(uvm_phase phase);
	 super.connect_phase(phase);
	 d0.seq_item_port.connect(s0.seq_item_export);
      endfunction
      
   endclass

   // The environment is the top-level unit associated with testing a system.
   // It holds all the details about the system-test, such as agents, scoreboards,
   // etc. It is included in tests, which configure the environment, but since
   // the environment is separate from the test, it can be more easily reused
   class registers_env extends uvm_env;

      `uvm_component_utils(registers_env)
      
      function new (string name = "registers_env", uvm_component parent = null);
	 super.new(name, parent);
      endfunction

      // Members
      // agents
      // functional coverage
      // scoreboard

      registers_agent a0;

      function void build_phase(uvm_phase phase);
	 super.build_phase(phase);

	 a0 = registers_agent::type_id::create("a0", this);
	 
      endfunction

      function void connect_phase(uvm_phase phase);
	 super.connect_phase(phase);

	 // Connect up the agents here
	 
      endfunction
      
   endclass
   
   // The test is the top-level name that is run in a call to `run_test` in the
   // top test bench. It can instantiate and configure one or multiple environments
   // for testing systems in the design.
   class registers_test extends uvm_test;

      `uvm_component_utils(registers_test)

      function new(string name = "registers_test", uvm_component parent = null);
	super.new(name, parent);
      endfunction

      registers_env e0;
      virtual registers_if rif;
      
      virtual function void build_phase(uvm_phase phase);
	 super.build_phase(phase);
	 e0 = registers_env::type_id::create("e0", this);
	 if(!uvm_config_db #(virtual registers_if)::get(this, "", "rif", rif))
	   `uvm_fatal("TEST", "Failed to get rif interface");
      endfunction

      virtual function void end_of_elaboration_phase(uvm_phase phase);
	 uvm_top.print_topology();
      endfunction
      

      virtual task run_phase(uvm_phase phase);

	 phase.raise_objection(this);
	 
	 `uvm_info("TEST", "This is a test", UVM_MEDIUM);

	 phase.drop_objection(this);
	 
      endtask
      
   endclass

         
endpackage
