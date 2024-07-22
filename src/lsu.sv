module lsu(

   input logic		lsu_valid, // Set to indicate read/write should start 
   input logic		lsu_write_en,  // Set to perform write
   output logic		lsu_ready, // Set to indicate operation complete/data valid
   
   input logic [31:0]	lsu_addr,
   input logic [31:0]	lsu_wdata,
   output logic [31:0]	lsu_rdata,
   
   axi4_lite_if.manager	dmem_bus
);


endmodule
