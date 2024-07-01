module registers(
   registers_if rif
);

   logic [31:0] reg0;
   logic [31:0]	reg1;
   logic [31:0]	reg2;
   logic [31:0]	reg3;

   // This device never stalls
   assign rif.ready = 1;
   
   always_ff @(posedge rif.clk) begin: reset_and_write
     if (rif.rst) begin
	reg0 <= 32'd0;
	reg1 <= 32'd0;
	reg2 <= 32'd0;
	reg3 <= 32'd0;
     end
     else if (rif.wr & rif.ready & rif.valid)
       case (rif.addr)
	 2'b00: reg0 <= rif.wdata;
	 2'b01: reg1 <= rif.wdata;
	 2'b10: reg2 <= rif.wdata;
	 2'b11: reg3 <= rif.wdata;
       endcase
   end

   always_comb begin: read
      case (rif.addr)
	2'b00: rif.rdata = reg0;
	2'b01: rif.rdata = reg1;
	2'b10: rif.rdata = reg2;
	2'b11: rif.rdata = reg3;
      endcase
   end
     
endmodule
