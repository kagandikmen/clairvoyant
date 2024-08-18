# Constraints for Xilinx' PYNQ-Z1 Board
# Copyright (c) 2024, Kagan Dikmen

# 100 MHz clock signal
set_property -dict { PACKAGE_PIN H16    IOSTANDARD LVCMOS33 } [get_ports clk]
    create_clock -add -name clk -period 10.00 -waveform {0 5} [get_ports clk]

# Reset
set_property -dict { PACKAGE_PIN D19    IOSTANDARD LVCMOS33 } [get_ports reset_n]

# not really used, is there so that Vivado does not optimise everything away
set_property -dict { PACKAGE_PIN R14    IOSTANDARD LVCMOS33 } [get_ports uart0_txd]