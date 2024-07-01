interface reg_if(input logic clk);
   logic rst;
   logic [7:0] addr;
   logic [15:0]	wdata;
   logic [15:0]	rdata;
   logic	wr;
   logic	valid;
   logic	ready; 
endinterface
