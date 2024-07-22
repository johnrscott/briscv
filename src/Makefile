# Simple Makefile to run Vivado simulator
# (xelab + xsim) for UVM testbenches

# This is passed to the xelab tool, which elaborates the
# design and testbench
LIBS=uvm

# All outputs are stored in this directory (xelab and xsim
# are both run from inside this directory)
OUTPUT_DIR=build

# Put each SystemVerilog source file on a new line in this
# file to include it in the elaboration.
FILES=files.prj

# Top module name
TOP=axi4_lite_mem_tb_top

# This is listed first so that the default makefile target
# is a simple build -- this can be used to check for file
# syntax errors etc.
#
# ${OUTPUT_DIR} the simulation snapshot using xelab. This
# is used to run the simulation using xsim. --debug all is
# required to compile with trace information.
${OUTPUT_DIR}/xsim.dir/sim_snapshot: Makefile *.sv ${FILES}
	mkdir -p ${OUTPUT_DIR}/
	cd ${OUTPUT_DIR}/; xelab -L ${LIBS} -prj ../${FILES} --debug all ${TOP} -s sim_snapshot

.PHONY: clean
clean:
	rm -rf ${OUTPUT_DIR}/

# Run the UVM simulation and print the results to stdout.
# Does not open a graphical window
.PHONY: run
run: Makefile ${OUTPUT_DIR}/xsim.dir/sim_snapshot
	cd ${OUTPUT_DIR}/; xsim sim_snapshot -R

# Open the graphical viewer to show traces
.PHONY: gui
gui: Makefile ${OUTPUT_DIR}/xsim.dir/sim_snapshot
	cd ${OUTPUT_DIR}/; xsim sim_snapshot -gui
