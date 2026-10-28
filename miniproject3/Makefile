filename = top
pcf_file = ../iceBlinkPico.pcf

build:
	yosys -p "synth_ice40 -noabc -top top -json $(filename).json" $(filename).sv
	nextpnr-ice40 --up5k --package sg48 --json $(filename).json --pcf $(pcf_file) --asc $(filename).asc
	icepack $(filename).asc $(filename).bin

sim:
	iverilog -g2012 -s game_of_life_tb -o game_sim game_of_life_tb.sv game_of_life.sv
	vvp game_sim

prog: #for sram
	dfu-util --device 1d50:6146 --alt 0 -D $(filename).bin -R

clean:
	rm -rf $(filename).blif $(filename).asc $(filename).json $(filename).bin