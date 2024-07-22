import types::instr_t;
import types::alu_arg_sel_t;
import types::alu_op_t;
import types::instr_format_t;
import types::rd_data_sel_t;

module cpu(axi4_lite_if.manager imem_bus, dmem_bus);
   
   logic aclk, aresetn;
   assign aclk = imem_bus.aclk;
   assign aresetn = imem_bus.aresetn;
   
   // Instruction fetch stage
   logic [31:0] pc, next_pc;
   logic	take_next_pc, ifu_stall, ifu_ready;
   instr_t instr;
   
   ifu ifu(.ifu_stall, .ifu_ready, .imem_bus, .pc, .next_pc, .take_next_pc, .instr); 

   // Decode immediates
   instr_format_t instr_format_sel;
   logic [31:0] imm_uimm;
   logic [31:0] lui_imm; // Extract from instr
   
   immgen immgen(.instr_format_sel, .instr, .imm_uimm);
   
   // Register file stage
   logic [4:0] rd, rs1, rs2;
   assign rd = instr.r_type.rd;
   assign rs1 = instr.r_type.rs1;
   assign rs2 = instr.r_type.rs2;
   
   logic write_en; // write to the register file
   logic [31:0]	rd_data; // data to write to the register file
   logic [31:0]	rs1_data, rs2_data; // Outputs from regfile to ex stages
   
   regfile regfile(.aclk, .aresetn, .write_en, .rd_data,
      .rd, .rs1, .rs2, .rs1_data, .rs2_data);
      
   // Exec/ALU stage
   alu_op_t alu_op; // Set from decoding the instr
   alu_arg_sel_t alu_arg_sel; // Set from decoding the instr
   logic [31:0] a, b; // Inputs to the ALU -- use mux to select
   logic [31:0]	r; // output from ALU to mem and writeback stage
   logic	zero; // Zero flag from ALU

   alu_mux alu_mux(.alu_arg_sel, .alu_op, .rs1_data, 
      .rs2_data, .imm_uimm, .pc, .a, .b);
   
   alu alu(.a, .b, .alu_op, .r, .zero);

   // Memory stage (load/store unit)
   logic lsu_valid, lsu_ready, lsu_write_en;
   logic [31:0]	lsu_rdata, lsu_wdata, lsu_addr;
   
   lsu lsu(.lsu_valid, .lsu_ready, .lsu_write_en, .lsu_rdata, 
      .lsu_wdata, .lsu_addr, .dmem_bus);

   // Write back stage
   rd_data_sel_t rd_data_sel; // Decode from instr
   
   wb_mux wb_mux(.rd_data_sel, .r, .lsu_rdata, .pc,
      .instr, .lui_imm, .rd_data);
   
endmodule
