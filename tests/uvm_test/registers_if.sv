interface registers_if (input logic clk, rst);
   logic	       ready;
   logic	       valid;
   
   logic [1:0]   addr;
   logic [31:0]  wdata;
   logic [31:0] rdata;
   logic	wr;
endinterface
