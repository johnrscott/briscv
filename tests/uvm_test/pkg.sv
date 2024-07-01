`include "config.svh"

package pkg;

   import uvm_pkg::*;
   
   class reg_item extends uvm_sequence_item;
      rand bit [`ADDR_WIDTH-1:0] addr;
      rand bit [`DATA_WIDTH-1:0] wdata;
      rand bit			 wr;
      bit [`DATA_WIDTH-1:0]	 rdata;

      `uvm_object_utils_begin(reg_item)
	 `uvm_field_int(addr, UVM_DEFAULT)
	 `uvm_field_int(wdata, UVM_DEFAULT)
	 `uvm_field_int(rdata, UVM_DEFAULT)
	 `uvm_field_int(wr, UVM_DEFAULT)
      `uvm_object_utils_end

      virtual function string convert_to_str();
	 return $sformatf("addr=0x%0h wr=0x%0h wdata=0x%0h rdata=0x%0h", addr, wr, wdata, rdata);
      endfunction // convert_to_str

      function new(string name = "reg_item")
	super.new(name);
      endfunction

   endclass

   class driver extends uvm_driver #(reg_item);

      `uvm_component_utils(driver)

      function new (string name = "driver", uvm_component parent=null)
	super.new(name, parent);
      endfunction // new

      virtual reg_if vif;

      virtual function void build_phase(uvm_phase phase);
	 super.build_phase(phase);
	 if (!uvm_config_db #(virtual reg_if)::get(this, "", "reg_vif", vif))
	   `uvm_fatal("DRV", "Could not get vif");
      endfunction // build_phase

      virtual task drive_item(reg_item item);
	 vif.set <= valid;
	 vif.addr <= item.addr;
	 vif.wr <= item.wr;
	 vif.wdata <= item.wdata;

	 @(posedge vif.clk);
	 while (!vif.ready) begin
	    `uvm_info("DRV", "Wait until ready is high", UVM_LOW)
	    @(posedge vif.clk);
	 end

	 vif.valid <= 0;
      endtask
      
   endclass

   class monitor extends uvm_monitor;

      `uvm_component_utils(monitor)

      function new(string name = "monitor", uvm_component parent = null)
	super.new(name, parent);
      endfunction // new

      uvm_analysis_port #(reg_item) mon_analysis_port;
      virtual reg_if vif;
      semaphore	sema4;

      virtual function void build_phase(uvm_phase build);
	 super.build_phase(phase);

	 if (!uvm_config_db #(virtual reg_if)::get(this, "", "reg_if", vif))
	   `uvm_fatal("MON", "Could not get vif");
	 
      endfunction


      virtual task run_phase(uvm_phase phase);

	 super.run_phase(phase);

	 forever begin
	    reg_item item = new;
	    item.add = vif.addr;
	    item.wr = vif.wr;
	    item.wdata = vif.wdata;

	    if (!vif.wr) begin
	       @(posedge vif.clk)
		 item.rdata = vif.rdata;
	    end

	    `uvm_info(get_type_name(), $sformatf("Monitor found package %s", item.convert_to_str(), UVM_LOW))

	    mon_analysis_port.write(item);
	    
	 end
	 
      endtask
   endclass

   class agent extends uvm_agent;

      `uvm_component_utils(agent)

      function new(string name = "agent", uvm_component parent = null)
	super.new(name, parent);
      endfunction // new

      driver d0;
      monitor m0;
      uvm_sequencer #(reg_item) s0;

      virtual function void build_phase(uvm_phase phase);
	 s0 = uvm_sequencer#(reg_item)::type_id::create("s0", this);
	 d0 = driver::type_id::create("d0", this);
	 m0 = monitor::type_id::create("m0", this);
      endfunction // build_phase

      virtual function void connect_phase(uvm_phase phase);
	 super.connect_phase(phase);
	 d0.seq_item_port.connect(s0.seq_item_export);
      endfunction
      
      
   endclass

   class scoreboard extends uvm_scoreboard;

      `uvm_component_utils(scoreboard)

      function new(string name = "scoreboard", uvm_component parent = null)
	super.new(name, parent);
      endfunction // new
      
      reg_item refq[`DEPTH];
      uvm_analysis_imp #(reg_item, scoreboard) analysis_imp;

      virtual function void build_phase(uvm_phase phase);
	 super.build_phase(phase);
	 analysis_imp = new("analysis_imp", this);
      endfunction // build_phase

      virtual function write(reg_item item);

	 if (item.wr) begin
	    if (refq[item.addr] == null)
	      refq[item.addr] = new;

	    refq[item.addr] = item;
	    `uvm_info(get_type_name(), $sformatf("Store addr=0x%0h wr=0x%0h data=0x%0h", item.addr, item.wr, item.wdata), UVM_LOW)
	 end

	 if (!item.wr) begin
	    if (refq[item.addr] == null)
	      if (item.rdata != `h1234)
		`uvm_error (get_type_name(), $sformatf("First time read, addr=0x%0h exp=1234 act=0x%0h", item.addr, item.rdata), UVM_LOW)
	      else
		`uvm_error (get_type_name(), $sformatf("PASS! First time read, addr=0x%0h exp=1234 act=0x%0h", item.addr, item.rdata), UVM_LOW)
	    else
	      if (item.rdata != refq[item.addr].wdata)
		`uvm_error(get_type_name(), $sformatf("addr=0x%0h exp=0x%0h act=0x%0h", item.addr, refq[item.addr].wdata, item.rdata), UVM_LOW)
	      else
		`uvm_error(get_type_name(), $sformatf("PASS! addr=0x%0h exp=0x%0h act=0x%0h", item.addr, refq[item.addr].wdata, item.rdata), UVM_LOW)
	 end // if (!item.wr)
	 
      endfunction
      
   endclass

   class env extends uvm_env;
      
      `uvm_component_utils(env)

      function new(string name = "env", uvm_component parent = null)
	super.new(name, parent);
      endfunction // new

      agent a0;
      scoreboard sb0;

      virtual function void build_phase(uvm_phase phase);
	 super.build_phase(phase);
	 agent = agent::type_id::create("a0", this);
	 sb0 = scoreboard::type_id::create("sb0", this);
      endfunction // build_phase

      virtual function void connect_phase(uvm_phase phase)
	super.connect_phase(phase);
	 a0.m0.mon_analysis_port.connect(sb0.analysis_imp);
      endfunction
      
   endclass
   
   class test extends uvm_test;
      
      `uvm_component_utils(test)

      function new(string name = "test", uvm_component parent = null)
	super.new(name, parent);
      endfunction // new

      env e0;
      virtual reg_if vif;
      
      virtual function void build_phase(uvm_phase phase);
	 super.build_phase(phase);
	 e0.env::type_id::create("e0", this);
	 if (!uvm_config_db#(virtual reg_if)::get(this, "", "reg_if", vif))
	   `uvm_fatal("TEST", "Did not get vif");

	 uvm_config_db #(virtual reg_id)::set(this, "e0.a0.*", "reg_vif", vif);

      endfunction // build_phase

      virtual task run_phase(uvm_phase phase);
	 gen_item_seq seq = gen_item_seq::type_id::create("seq");

	 phase.raise_objection(this);
	 
	 apply_reset();
	 seq.randomize() with {num inside {[20:30]}; };
	 seq.start(e0.a0.s0);
	 #200;

	 phase.drop_objection()
	 
      endtask

      virtual task apply_reset();
	 vif.rst <= 1;
	 repeat(5) @(posedge vif.clk);
	 vif <= 0;
	 repeat(10) @(posedge vif.clk)
      endtask	 

   endclass // test

   class gen_item_seq extends uvm_sequence;

      `uvm_component_utils(gen_item_seq)

      function new(string name = "gen_item_seq")
	super.new(name);
      endfunction // new

      rand int num;

      constraint c1 { soft num inside {[2:5]}; }

      virtual task body();
	 for (int i = 0; i < num; i++) begin
	    reg_item item = reg_item::type_id::create("reg_item");
	    start_item(item);
	    `uvm_info("SEQ", $sformatf("Generate new item: "), UVM_LOW)
	    item.print();
	    finish_item(item);
	 end
	 `uvm_info("SEQ", $sformatf("Done generate of %0d items", num), UVM_LOW)
      endtask
      

   endclass
      
      
endpackage
