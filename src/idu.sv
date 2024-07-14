import types::instr_t;

// Combinational register file and immediate generation
module idu(
   input logic	       aclk, aresetn,

   input	       instr_t instr,
   input logic [31:0]  pc, rd_data,
   output logic [31:0] rs1_data, rs2_data,
   output logic [31:0] imm_uimm
);
   
   regfile regfile(
      .resetn,
      .aclk,
      .write_en,
      .rd_data,
      .rs1_data,
      .rs2_data,
      .rd(instr.r_type.rd),
      .rs1(instr.r_type.rs1),
      .rs2(instr.r_type.rs2)
   );

   logic    imm_sel;

   immgen immgen(.imm_sel, .instr, .imm_uimm);

   

endmodule
