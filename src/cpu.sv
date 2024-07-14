module cpu(axi4_lite_if.manager imem_bus, dmem_bus);

   logic [31:0] instr, pc, next_pc;
   logic take_next_pc, ifu_stall_in, ifu_stall_out;
   
   ifu ifu(
      .aclk, .aresetn, .ifu_stall_in, .ifu_stall_out,
      .imem_bus, .pc, .next_pc, .take_next_pc
   ); 

   

   
endmodule
