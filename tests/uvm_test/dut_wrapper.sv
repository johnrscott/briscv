`include "config.svh"

module dut_wrapper(
   reg_if _if
);

   reg_ctrl #(
      .ADDR_WIDTH(`ADDR_WIDTH),
      .DATA_WIDTH(`DATA_WIDTH),
   ) (
      .clk(_if.clk),
      .rst(_if.rst),
      .addr(_if.addr),
      .valid(_if.valid),
      .wr(_if.wr),
      .wdata(_if.wdata),
      .rdata(_if.rdata),
      .ready(_id.ready)
   );

endmodule
