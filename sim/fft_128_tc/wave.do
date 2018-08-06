vsim -view vsim.wlf
add wave -position insertpoint vsim:/TB/FFT/SU1/*
#onerror {resume}
#quietly WaveActivateNextPane {} 0
#TreeUpdate [SetDefaultTree]
#WaveRestoreCursors {{Cursor 1} {0 ns} 0}
#quietly wave cursor active 0
configure wave -namecolwidth 125
#configure wave -valuecolwidth 40
#configure wave -justifyvalue left
#configure wave -signalnamewidth 1
#configure wave -snapdistance 10
#configure wave -datasetprefix 0
#configure wave -rowmargin 4
#configure wave -childrowmargin 2
#configure wave -gridoffset 0
#configure wave -gridperiod 1
#configure wave -griddelta 40
#configure wave -timeline 0
#configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {600 ns}
