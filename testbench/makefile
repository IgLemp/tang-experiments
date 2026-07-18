define test_module
	iverilog -g2012 -s $(2)_tb ./$(2)_tb.v ../modules/$(1).v -o./$(2)_tb.vvp
	vvp ./$(2)_tb.vvp -o ./$(2).vcd
endef

test:
	$(call test_module,rs232,rs232)
	$(call test_module,rs232,rs232_echo)
