onerror {quit -f}
vlib work
vlog -work work Risc-V-Superescalar.vo
vlog -work work Risc-V-Superescalar.vt
vsim -novopt -c -t 1ps -L cycloneiv_ver -L altera_ver -L altera_mf_ver -L 220model_ver -L sgate work.top_dual_vlg_vec_tst
vcd file -direction Risc-V-Superescalar.msim.vcd
vcd add -internal top_dual_vlg_vec_tst/*
vcd add -internal top_dual_vlg_vec_tst/i1/*
add wave /*
run -all
