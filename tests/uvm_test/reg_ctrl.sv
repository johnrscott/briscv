module reg_ctrl #(
   parameter ADDR_WIDTH = 8,
   parameter DATA_WIDTH = 16,
   parameter DEPTH = 256,
   parameter RESET_VAL = 16'h1234
) (
   input logic			 clk, rst,
   input [ADDR_WIDTH-1:0]	 addr,
   input logic			 valid,
   input logic			 wr,
   input [DATA_WIDTH-1:0]	 wdata,
   output logic [DATA_WIDTH-1:0] rdata,
   output logic			 ready
);
 
   // Nothing yet
  
endmodule
