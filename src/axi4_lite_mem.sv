module axi4_lite_mem(
   axif_lite_if.subordinate bus
);
   
   logic [31:0] words[1024];
   logic	write_en;

   // Write whenever the write address/write
   // data channels are ready
   assign write_en = (
      bus.awvalid & bus.awready & 
      bus.wvalid & bus.wready
   );
   
   always_ff @(bus.aclk) begin: write
      if (!bus.aresetn)
	words = '{ default: '0 };
      else if (write_en)
	words[bus.awaddr[31:2]] = bus.wdata;
   end

   // Always return read data in one cycle
   assign bus.rvalid = 1;
   assign bus.rdata = words[bus.araddr];

   // There is no test for back pressure yet
   
endmodule // axi4_lite_mem

