find . -type f -name "*.sv" -execdir echo "Format {}" && verible-verilog-format --inplace {} \;
