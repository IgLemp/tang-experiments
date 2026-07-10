build:
	yosys -p "read_verilog -sv main.v; synth_gowin -json main.json -family gw2a"
	nextpnr-himbaechel --json main.json --write pnrmain.json --device GW2AR-LV18QN88C8/I7 --vopt family=GW2A-18C --vopt cst=tangnano20k.cst
	gowin_pack -d GW2A-18C -o pack.fs pnrmain.json

load:
	openFPGALoader -b tangnano20k pack.fs


clean:
	rm -f *.json *.fs *-unpacked.v
