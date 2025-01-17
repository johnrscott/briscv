`include "uvm_macros.svh"

import uvm_pkg::*;

class alu_transaction extends uvm_sequence_item;
   rand bit [31:0] a;
   rand bit [31:0] b;
   rand types::funct3_t op;
   rand bit op_mod;
   bit [31:0] r;
   bit	     zero;
   
   function new(string name = "");
      super.new(name);
   endfunction
   
   `uvm_object_utils_begin(alu_transaction)
      `uvm_field_int(a, UVM_ALL_ON)
      `uvm_field_int(b, UVM_ALL_ON)
      `uvm_field_enum(types::funct3_t, op, UVM_ALL_ON)
      `uvm_field_int(op_mod, UVM_ALL_ON)
      `uvm_field_int(r, UVM_ALL_ON)
      `uvm_field_int(zero, UVM_ALL_ON)
   `uvm_object_utils_end
   
endclass

class alu_sequence extends uvm_sequence#(alu_transaction);
   `uvm_object_utils(alu_sequence)
   
   function new(string name = "");
      super.new(name);
   endfunction
   
   task body();
      alu_transaction alu_tx;
      
      repeat(10000) begin
         alu_tx = alu_transaction::type_id::create();
	 
         start_item(alu_tx);
         assert(alu_tx.randomize());
	 finish_item(alu_tx);
      end
      
   endtask
endclass // alu_sequence

typedef uvm_sequencer#(alu_transaction) alu_sequencer;

class alu_driver extends uvm_driver#(alu_transaction);
   `uvm_component_utils(alu_driver)
   
   // Interface declaration
   protected virtual alu_if vif;
   
   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction: new
   
   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      void'(uvm_resource_db#(virtual alu_if)::read_by_name(.scope("ifs"), .name("alu_if"), .val(vif)));
   endfunction: build_phase

   virtual task drive();

      alu_transaction alu_tx;
      types::alu_op_t alu_op;
      
      forever begin
	 
	 seq_item_port.get_next_item(alu_tx);
	 `uvm_info("DRV", "Driving DUT", UVM_LOW);
	 
	 alu_op = '{ op: alu_tx.op, op_mod: alu_tx.op_mod };

	 vif.a = alu_tx.a;
	 vif.b = alu_tx.b;
	 vif.alu_op = alu_op;

	 #1;

	 seq_item_port.item_done();

      end
	 
   endtask
   
   task run_phase(uvm_phase phase);

      // Our code here
      drive();

   endtask: run_phase

endclass // simpleadder_driver

class alu_monitor_before extends uvm_monitor;
   `uvm_component_utils(alu_monitor_before)
   
   uvm_analysis_port#(alu_transaction) mon_ap_before;
   
   virtual alu_if vif;
   
   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction
   
   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      
      if (!uvm_resource_db#(virtual alu_if)::read_by_name("ifs","alu_if", vif))
	`uvm_error(get_type_name(), "Failed to get alu_if in alu_monitor_before");
      
      mon_ap_before = new(.name("mon_ap_before"), .parent(this));
   endfunction: build_phase
   
   task run_phase(uvm_phase phase);

      alu_transaction alu_tx = alu_transaction::type_id::create("alu_tx", this);
      
      forever begin

	 // Read raw data and send to scoreboard
	 alu_tx.a = vif.a; 
	 alu_tx.b = vif.b;
	 alu_tx.op = vif.alu_op.op;
	 alu_tx.op_mod = vif.alu_op.op_mod;
	 
	 // Read the outputs from the virtual interface
	 alu_tx.r = vif.r; 
	 alu_tx.zero = vif.zero;
	 
	 mon_ap_before.write(alu_tx);

	 // Delay before next read
	 #1;
	 
      end

   endtask // run_phase
   
endclass // alu_monitor_before

class alu_monitor_after extends uvm_monitor;
   `uvm_component_utils(alu_monitor_after)
   
   uvm_analysis_port#(alu_transaction) mon_ap_after;
   
   virtual alu_if vif;
   
   alu_transaction alu_tx_cg;

   // This construction is called an embedded covergroup -- it
   // behaves like a variable, not a type
   covergroup alu_cg;
      a_cp:     coverpoint alu_tx_cg.a;
      b_cp:     coverpoint alu_tx_cg.b;
      cross a_cp, b_cp;
   endgroup // alu_cg

   function new(string name, uvm_component parent);
      super.new(name, parent);

      alu_tx_cg = new;
      
      alu_cg = new;
   endfunction // new
   
   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      
      if (!uvm_resource_db#(virtual alu_if)::read_by_name("ifs", "alu_if", vif))
	`uvm_error(get_type_name(), "alu_if not found in alu_monitor_after");
	
      mon_ap_after= new(.name("mon_ap_after"), .parent(this));

   endfunction: build_phase
   
   task run_phase(uvm_phase phase);
      
      alu_transaction alu_tx = alu_transaction::type_id::create("alu_tx", this);
      
      forever begin
	 
	 // Read raw data and send to scoreboard
	 alu_tx.a = vif.a; 
	 alu_tx.b = vif.b; 
	 alu_tx.op = vif.alu_op.op;
	 alu_tx.op_mod = vif.alu_op.op_mod;

	 // Sample covergroup
	 alu_cg.sample();
	 `uvm_info("coverage", $sformatf("Coverage is %d", alu_cg.get_coverage()) , UVM_LOW);
	 
	 // Use the inputs from vif to calculate the
	 // expected outputs and store them in alu_tx
	 case (vif.alu_op.op)
	   types::FUNCT3_ADD:
	     // op_mod turns addition into subtraction 
	     if (vif.alu_op.op_mod)
	       alu_tx.r = vif.a - vif.b;
	     else
	       alu_tx.r = vif.a + vif.b;
	   types::FUNCT3_OR: alu_tx.r = vif.a | vif.b;
	   types::FUNCT3_AND: alu_tx.r = vif.a & vif.b;
	   types::FUNCT3_XOR: alu_tx.r = vif.a ^ vif.b;
	   types::FUNCT3_SLL: alu_tx.r = vif.a << vif.b[4:0];
	   types::FUNCT3_SRL: 
	      // op_mod determines arithmetic instead of default logical
	      if (vif.alu_op.op_mod)
		alu_tx.r = $signed(vif.a) >>> vif.b[4:0];
	      else
		alu_tx.r = vif.a >> vif.b[4:0];
	   types::FUNCT3_SLTU: alu_tx.r = vif.a < vif.b ? 1 : 0;
	   types::FUNCT3_SLT: alu_tx.r = $signed(vif.a) < $signed(vif.b) ? 1 : 0;
	 endcase

	 // Calculate the zero flag
	 alu_tx.zero = alu_tx.r == 0 ? 1 : 0;

	 mon_ap_after.write(alu_tx);
	 
	 // Delay 
	 #1;
	 
      end
      
   endtask // run_phase
   
endclass

class alu_agent extends uvm_agent;
   `uvm_component_utils(alu_agent)
   
   // Analysis ports to connect the monitors to the scoreboard
   uvm_analysis_port#(alu_transaction) agent_ap_before;
   uvm_analysis_port#(alu_transaction) agent_ap_after;
   
   alu_sequencer alu_seqr;
   alu_driver alu_drvr;
   alu_monitor_before alu_mon_before;
   alu_monitor_after alu_mon_after;
   
   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction: new
   
   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      
      agent_ap_before = new(.name("agent_ap_before"), .parent(this));
      agent_ap_after = new(.name("agent_ap_after"), .parent(this));
      
      alu_seqr = alu_sequencer::type_id::create("alu_seqr", this);
      alu_drvr = alu_driver::type_id::create("alu_drvr", this);
      alu_mon_before = alu_monitor_before::type_id::create("alu_mon_before", this);
      alu_mon_after = alu_monitor_after::type_id::create("alu_mon_after", this);
      
   endfunction // build_phase
   
   function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      alu_drvr.seq_item_port.connect(alu_seqr.seq_item_export);
      alu_mon_before.mon_ap_before.connect(agent_ap_before);
      alu_mon_after.mon_ap_after.connect(agent_ap_after);
      endfunction // connect_phase
   
endclass // alu_agent

class alu_scoreboard extends uvm_scoreboard;
   `uvm_component_utils(alu_scoreboard)
   
   uvm_analysis_export #(alu_transaction) sb_export_before;
   uvm_analysis_export #(alu_transaction) sb_export_after;
   
   uvm_tlm_analysis_fifo #(alu_transaction) before_fifo;
   uvm_tlm_analysis_fifo #(alu_transaction) after_fifo;
   
   alu_transaction transaction_before;
   alu_transaction transaction_after;
   
   function new(string name, uvm_component parent);
      super.new(name, parent);
      transaction_before = new("transaction_before");
      transaction_after = new("transaction_after");
   endfunction // new
   
   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      sb_export_before = new("sb_export_before", this);
      sb_export_after = new("sb_export_after", this);
      
      before_fifo = new("before_fifo", this);
      after_fifo = new("after_fifo", this);
   endfunction // build_phase
   
   function void connect_phase(uvm_phase phase);
      sb_export_before.connect(before_fifo.analysis_export);
      sb_export_after.connect(after_fifo.analysis_export);
   endfunction // connect_phase
   
   task run();
      forever begin
         before_fifo.get(transaction_before);
         after_fifo.get(transaction_after);
         compare();
      end
   endtask // run
   
   virtual function void compare();
      if((transaction_before.r == transaction_after.r)
	 & (transaction_before.zero == transaction_after.zero)) begin
         `uvm_info("compare", "Result test: OK!", UVM_LOW);
      end else begin
         `uvm_info("compare", "Result test: Fail!", UVM_LOW);
	 `uvm_info("compare", "Expected transaction:", UVM_LOW);
	 transaction_after.print();
	 `uvm_info("compare", "Actual transaction:", UVM_LOW);
	 transaction_before.print();
	 `uvm_error("compare", "ALU result failed");
      end

   endfunction // compare
   
endclass // alu_scoreboard

class alu_env extends uvm_env;
   `uvm_component_utils(alu_env)
   
   alu_agent alu_agnt;
   alu_scoreboard alu_sb;
   
   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction
   
   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      alu_agnt = alu_agent::type_id::create("alu_agnt", this);
      alu_sb = alu_scoreboard::type_id::create("alu_sb", this);
   endfunction // build_phase
   
   function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      alu_agnt.agent_ap_before.connect(alu_sb.sb_export_before);
      alu_agnt.agent_ap_after.connect(alu_sb.sb_export_after);
   endfunction // connect_phase
   
endclass // alu_env

class alu_test extends uvm_test;
   `uvm_component_utils(alu_test)
   
   alu_env env;
   
   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction
   
   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      env = alu_env::type_id::create("alu_env", this);
   endfunction // build_phase
   
   
   task run_phase(uvm_phase phase);
      alu_sequence alu_seq;
      
      phase.raise_objection(.obj(this));
      `uvm_info(get_type_name(), "Starting test", UVM_LOW);
      
      alu_seq = alu_sequence::type_id::create("alu_seq", this);

      assert(alu_seq.randomize());

      alu_seq.start(env.alu_agnt.alu_seqr);
      
      phase.drop_objection(.obj(this));

   endtask // run_phase
   
endclass // alu_test


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
      run_test("alu_test");

   end
   
   // Variable initialization
   // initial begin
   //    vif.sig_clock = 1'b1;
   // end
   
   // Clock generation
   // always
   //   #5 vif.sig_clock = ~vif.sig_clock;
endmodule
