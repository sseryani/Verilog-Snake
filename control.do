vlib work

vlog -timescale 1ns/1ns control.v

vsim control

log {/*}
add wave {/*}


force {clk} 0 0, 1 5 -r 10
force {reset} 0 0, 1 11
force {update} 0 0, 1 50 -r 100
force {has_collided} 0
force {isDead} 0
force {title_done} 0 0, 1 20
run 1000000ns