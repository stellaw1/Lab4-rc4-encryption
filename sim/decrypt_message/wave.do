onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /decrypt_message_tb/dut/clk
add wave -noupdate /decrypt_message_tb/dut/reset
add wave -noupdate /decrypt_message_tb/dut/start
add wave -noupdate /decrypt_message_tb/dut/s_read_data
add wave -noupdate /decrypt_message_tb/dut/rom_read_data
add wave -noupdate /decrypt_message_tb/dut/s_write
add wave -noupdate /decrypt_message_tb/dut/ram_write
add wave -noupdate /decrypt_message_tb/dut/s_address
add wave -noupdate /decrypt_message_tb/dut/ram_address
add wave -noupdate /decrypt_message_tb/dut/rom_address
add wave -noupdate /decrypt_message_tb/dut/s_write_data
add wave -noupdate /decrypt_message_tb/dut/ram_write_data
add wave -noupdate /decrypt_message_tb/dut/finish
add wave -noupdate /decrypt_message_tb/dut/state
add wave -noupdate /decrypt_message_tb/dut/i
add wave -noupdate /decrypt_message_tb/dut/j
add wave -noupdate /decrypt_message_tb/dut/k
add wave -noupdate /decrypt_message_tb/dut/f
add wave -noupdate /decrypt_message_tb/dut/si
add wave -noupdate /decrypt_message_tb/dut/sj
add wave -noupdate /decrypt_message_tb/dut/romk
add wave -noupdate /decrypt_message_tb/dut/en_si
add wave -noupdate /decrypt_message_tb/dut/en_sj
add wave -noupdate /decrypt_message_tb/dut/en_f
add wave -noupdate /decrypt_message_tb/dut/en_k
add wave -noupdate /decrypt_message_tb/dut/addr_i
add wave -noupdate /decrypt_message_tb/dut/addr_j
add wave -noupdate /decrypt_message_tb/dut/addr_sum
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 127
configure wave -valuecolwidth 39
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {10999 ps} {12053 ps}
