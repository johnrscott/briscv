import types::alu_op_t;

interface alu_if;
   logic [31:0] a;
   logic [31:0]	b;
   alu_op_t	alu_op;
   logic [31:0]	r;
   logic	zero;
endinterface
