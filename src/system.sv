module system(logic aclk, logic aresetn);
   
   // For now, separate instruction and data memories.
   // Data memory also has peripheral devices.
   axi4_lite_if imem_bus(.aclk, .aresetn);
   axi4_lite_if dmem_bus(.aclk, .aresetn);

   // Instruction and data memory are simple AXI4-Lite
   // wrappers for arrays for now.
   axi4_lite_mem imem(.bus(imem_bus));
   axi4_lite_mem dmem(.bus(dmem_bus));

   cpu cpu(.imem_bus, .dmem_bus);
   
endmodule
