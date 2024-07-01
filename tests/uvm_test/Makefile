# Simple Makefile to run Vivado simulator
# (xelab + xsim) for UVM testbenches

# This is passed to the xelab tool, which elaborates the
# design and testbench
LIBS=uvm

# All outputs are stored in this directory (xelab and xsim
# are both run from inside this directory)
OUTPUT_DIR=build

# Run the simulation snapshot using xsim
.PHONY: run
run: Makefile ${OUTPUT_DIR}/xsim.dir/sim_snapshot
	cd ${OUTPUT_DIR}/; xsim sim_snapshot -gui


# ${OUTPUT_DIR} the simulation snapshot using xelab. This
# is used to run the simulation using xsim. --debug all is
# required to compile with trace information.
${OUTPUT_DIR}/xsim.dir/sim_snapshot: Makefile tb_top.sv
	mkdir -p ${OUTPUT_DIR}/
	cd ${OUTPUT_DIR}/; xelab -L ${LIBS} -prj ../tb_top.prj --debug all tb_top -s sim_snapshot

.PHONY: clean
clean:
	rm -rf ${OUTPUT_DIR}/
