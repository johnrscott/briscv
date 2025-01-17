import types::rd_data_sel_t;
import types::instr_t;

/// Write data for rd in register file
///
/// The rd_data_sel arguments selects between the inputs:
///
/// 000: main_alu_result,
/// for register-register, register-immediate, and auipc instructions
///
/// 001: data_mem_rdata
/// for load instructions
///
/// 010: csr_rdata
/// for Zicsr instruction
///
/// 011: pc_plus_4
/// for unconditional jump instructions
///
/// 100: { instr[31:12], 12{1'b0} } (from instr input)
/// for lui instruction
///
module wb_mux(
   input	       rd_data_sel_t rd_data_sel, // pick what to write to rd	
   input logic [31:0]  r,			  // the output from the main ALU
   input logic [31:0]  lsu_rdata,		  // data output from data memory bus
   input logic [31:0]  csr_rdata,		  // data output from CSR bus
   input logic [31:0]  pc,			  // current program counter
   input	       instr_t instr,		  // current instruction
   input logic [31:0]  lui_imm,			  // Immediate to store in rd
   output logic [31:0] rd_data			  // data to be written back to register file
);
   
   always_comb begin
      case (rd_data_sel)
	types::MAIN_ALU_RESULT: rd_data = r;
	types::DATA_MEM_RDATA: rd_data = lsu_rdata;
	types::CSR_RDATA: rd_data = csr_rdata;
	types::PC_PLUS_4: rd_data = pc + 4;
	types::LUI_IMM: rd_data = lui_imm;
	default: rd_data = 0;
      endcase
   end
      
endmodule
