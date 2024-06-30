module top (
   input logic	       clk, rst,
   input logic	       inc_counter,
   input logic	       rst_counter,
   output logic [31:0] counter
);

   always_ff @(posedge clk)
     if (rst | rst_counter)
       counter <= 0;
     else if (inc_counter)
       counter <= counter + 1;

`ifdef FORMAL


   default disable iff (rst);
   default clocking @(posedge clk);
   endclocking
   
`endif
 
   
endmodule // top

