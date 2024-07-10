module ifu(
   input logic		clk, rst,

   input logic		stall_in,
   output logic		stall_out,    // 0 means instr and pc are valid

   output logic [31:0]	instr,
   output logic [31:0]	pc,

   input logic [31:0]	next_pc,
   input logic		take_next_pc, // 1 for next_pc, 0 for pc += 4

   axi4_lite_if.manager	imem_bus


);

   
endmodule
