#!/usr/bin/env -S vivado -mode batch -source

create_project -in_memory -part xc7a35ticsg324-1L

# Read all SystemVerilog sources
read_verilog -sv [ glob ../*.sv ]

launch_simulation

xelab
