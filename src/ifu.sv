import types::instr_t;

module ifu(
   input logic		ifu_stall,
   output logic		ifu_ready,

   output		instr_t instr,
   output logic [31:0]	pc,

   input logic [31:0]	next_pc,
   input logic		take_next_pc, // 1 for next_pc, 0 for pc += 4

   axi4_lite_if.manager	imem_bus
);

   
   
endmodule
