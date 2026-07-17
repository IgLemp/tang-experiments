build:
	yosys -p "read_verilog -sv main.v; synth_gowin -json main.json -family gw2a"
	nextpnr-himbaechel --json main.json --write pnrmain.json --device GW2AR-LV18QN88C8/I7 --vopt family=GW2A-18C --vopt cst=tangnano20k.cst
	gowin_pack -d GW2A-18C -o pack.fs pnrmain.json

load:
	openFPGALoader -b tangnano20k pack.fs

sim:
	iverilog main.v -g2012

clean:
	rm -f *.json *.fs *-unpacked.v abc.history

define test_module
	iverilog -g2012 -s $(1)_tb ./testbench/$(1)_tb.v ./modules/$(1).v -o./testbench/$(1)_tb.vvp
	vvp ./testbench/$(1)_tb.vvp -o ./testbench/$(1).vcd
endef

test:
	$(call test_module,rs232)
