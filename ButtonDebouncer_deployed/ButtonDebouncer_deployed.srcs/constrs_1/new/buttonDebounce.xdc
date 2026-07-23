#######################################################################
## ButtonDebouncer -- AX7A035B (XC7A35T FGG484)
## Pins from AX7A035B User Manual REV 1.1 / ALINX demo XDCs
#######################################################################

## --- Configuration --------------------------------------------------
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 50 [current_design]

## --- 200 MHz differential system clock -- Bank 34, 1.5 V ------------
create_clock -period 5.000 -name sys_clk [get_ports sys_clk_p]
set_property PACKAGE_PIN R4 [get_ports sys_clk_p]
set_property IOSTANDARD DIFF_SSTL15 [get_ports sys_clk_p]
set_property PACKAGE_PIN T4 [get_ports sys_clk_n]
set_property IOSTANDARD DIFF_SSTL15 [get_ports sys_clk_n]

## --- RESET key (active low) -----------------------------------------
set_property PACKAGE_PIN F15 [get_ports rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports rst_n]
set_false_path -from [get_ports rst_n]

## --- KEY1 (active low: pressed = 0) ---------------------------------
set_property PACKAGE_PIN L19 [get_ports key_n]
set_property IOSTANDARD LVCMOS33 [get_ports key_n]
set_false_path -from [get_ports key_n]

## --- Carrier LED1 (drive 0 = lit) -----------------------------------
set_property PACKAGE_PIN L13 [get_ports led]
set_property IOSTANDARD LVCMOS33 [get_ports led]