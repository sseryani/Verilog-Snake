vlib work

vlog -timescale 1ns/1ns combined_gui.v

vsim combined_gui

log {/*}
add wave {/*}


force {clk} 0 0, 1 5 -r 10
force {reset} 0 0, 1 11
force {start} 0 0, 1 50 -r 100
force {isDead} 0
run 1000000ns
