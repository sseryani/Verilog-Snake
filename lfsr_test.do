vlib work

vlog -timescale 1ns/1ns lfsr.v

vsim lfsr

log {/*}
add wave {/*}


force {clk} 0 0, 1 5 -r 10
force {reset} 0 0, 1 11
force {enable} 0 0, 1 20 -r 30
run 500ns