interface axi4_lite_if #(
    parameter int ADDR_WIDTH = 32,
    parameter int DATA_WIDTH = 32
) (input logic aclk, aresetn);
   
   // Read address channel
   logic arvalid, arready;
   logic [ADDR_WIDTH - 1:0] araddr;
   
   // Read data channel
   logic		    rvalid, rready;
   logic [DATA_WIDTH - 1:0] rdata;

   // Write address channel
   logic		    awvalid, awready;
   logic [ADDR_WIDTH - 1:0] awaddr;

   // Write response channel
   logic		    wvalid, wready;
   logic [DATA_WIDTH - 1:0] wdata;

   // Write response channel
   logic		    bvalid, bready;
   logic [2:0]		    bresp;

   clocking manager_cb @(posedge aclk);
      default input #1step output negedge;
      output arready, rvalid, rdata, awready, wready, bvalid, bresp;
      input  aclk, aresetn, arvalid, araddr, rready, awvalid, awaddr, wvalid, wdata, bready;
   endclocking

   clocking subordinate_cb @(posedge aclk);
      default input #1step output negedge;
      output arvalid, araddr, rready, awvalid, awaddr, wvalid, wdata, bready;
      input  aclk, aresetn, arready, rvalid, rdata, awready, wready, bvalid, bresp;
   endclocking

   modport manager(clocking manager_cb);
   modport subordinate(clocking subordinate_cb);

endinterface
