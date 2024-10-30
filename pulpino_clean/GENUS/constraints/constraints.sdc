#TIME - ns
#CAPACITANCE - pF
set_units -time 1.0ns
set_units -capacitance 1.0pF

# CREATE CORE CLOCK
set CORECLK_PERIOD 50.0;
create_clock -period $CORECLK_PERIOD -name CLK [get_port clk]
# Reactivate if new std. cells have more useable delays, values are reasonable
#set_clock_uncertainty -setup 0.2 CLK
#set_clock_uncertainty -hold  0.1 CLK
# ToDo: Evaluate on current board with Oszi...
# Based on: https://cdn-reichelt.de/documents/datenblatt/B400/XO32.pdf
set_clock_transition 2 CLK
set_clock_latency -source 0 CLK

# How reasonable are these settings?
set DEFAULT_CORECLK_IN_DELAY [expr 0.2 * $CORECLK_PERIOD];
set DEFAULT_CORECLK_OUT_DELAY [expr 0.2 * $CORECLK_PERIOD]; 

# CREATE SPI CLOCK
# SPI is a CPOL=0, CPHA=0, but with a twist: first data is sampled 1,5 SPI_CLK periods after CS->0, then always at SPI_CLK->1.
# Flo W. has given I/O delays for the PCB:
# Every signal is routed through exactly one LVC125
# LVC125 has a minimum t_pd of 1.0 and a maximum of 4.6 (datasheet https://www.ti.com/lit/ds/symlink/sn74lvc125a.pdf)
# Minimum input delay of CLK is 1.0+1.3=2.3 (one fast LVC125 + 220mm of 100R PCB trace where signals travel with approx. 5.7ps/mm)
# Maximum input delay of CLK is 1*4.6+1.3=5.9 (one slow LVC125 + 220mm of PCB trace)
# Maximum I/O delay for signal is MISO passing one slow LVC125 + 220mm of 100R PCB trace + input delay of SoM => 4.6+1.3+18=23.9 ns. This signal has to arrive after 1/2 clock period.
# With enough safety overhead, 80ns clock period seems sensible.
# 80ns equal 12.5 MHz, should be enough.
set SPICLK_PERIOD 80.0;
set SPICLK_MIN_INSERTION_DELAY 2.3;
set SPICLK_MAX_INSERTION_DELAY 5.9;

# For CW308, MOSI passes one LVC125, so input delay is minumum (1.0+1.3)=2.3 and maximum (4.6+1.3)=5.9
# SoM has an output propagation delay of minimum -1ns and maximum 1ns:
# For SoM_SPI, MOSI passes one LVC125, so input delay is minimum (1.0+1.3-1.0)=1.3 and maximum (4.6+1.3+1.0)=6.9
set DEFAULT_SPICLK_MIN_IN_DELAY 1.3;
set DEFAULT_SPICLK_MAX_IN_DELAY 6.9;

# Outputs all only pass one LVC125, which has between 1.0 and 4.6ns delay and again an estimated 220mm of PCB trace.
# Additionally, inside the SoM, SPI has an input delay of 18ns
# This gives an output delay of minimum 1.0+1.3+18=20.3 and maximum 4.6+1.3+18=23.9
set DEFAULT_SPICLK_MIN_OUT_DELAY 20.3;
set DEFAULT_SPICLK_MAX_OUT_DELAY 24.0;

create_clock -period $SPICLK_PERIOD -name SPI_SCK [get_port spi_clk_i]
# Reactivate based on new logic cells
#set_clock_uncertainty -setup 0.2 SPI_SCK
#set_clock_uncertainty -hold  0.1 SPI_SCK
set_clock_transition 2 SPI_SCK
#Do not use set clock latency (-early/-late) here! This has to be done with -min/-max.
set_clock_latency -source -min $SPICLK_MIN_INSERTION_DELAY SPI_SCK
set_clock_latency -source -max $SPICLK_MAX_INSERTION_DELAY SPI_SCK

# CREATE JTAG CLOCK
set JTAGCLK_PERIOD 50.0;
set DEFAULT_JTAGCLK_IN_DELAY  [expr 0.2 * $JTAGCLK_PERIOD];
create_clock -period $JTAGCLK_PERIOD  -name TCK [get_port tck_i]
# Reactivate based on new logic cells
#set_clock_uncertainty -setup 0.2 TCK
#set_clock_uncertainty -hold  0.1 TCK
set_clock_transition 2 TCK
# for safety, specify a varying clock latency here.
set_clock_latency -source -min $SPICLK_MIN_INSERTION_DELAY TCK
set_clock_latency -source -max $SPICLK_MAX_INSERTION_DELAY TCK

#DEFINE FALSE PATH BETWEEN CLOCKS
set_clock_groups -name group1 -asynchronous -group [get_clocks {CLK}]  -group [get_clocks {SPI_SCK}] -group [get_clocks {TCK}]

# DEFINE PORT GROUPS FOR SUBSEQUENT COMMANDS
set CLOCKS [ concat [get_ports clk] [get_ports spi_clk_i] [get_ports tck_i] ]
set RST_PORTS [ concat [get_ports rst_n] [get_ports trstn_i] ]
set CLK_RST_PORTS [concat $CLOCKS $RST_PORTS]

set SPI_INPUTS [\
    concat [get_ports spi_cs_i]\
    [get_ports spi_sdi*_i]\
]
set JTAG_INPUTS [\
    concat [get_ports trstn_i]\
    [get_ports tms_i]\
    [get_ports tdi_i]\
]
set CORE_INPUTS [\
    concat [get_ports rst_n]\
    [get_ports clk_sel_i]\
    [get_ports fetch_enable_i]\
    [get_ports spi_master_sdi0_i]\
    [get_ports scl_i_o]\
    [get_ports sda_i_o]\
    [get_ports uart_rx]\
    [get_ports uart_cts]\
    [get_ports uart_dsr]\
    [get_ports gpio_in_out_*]\
]

set CORE_OUTPUTS [\
    concat [get_ports spi_master_csn*_o]\
    [get_ports spi_master_mode_o_*]\
    [get_ports spi_master_*_o]\
    [get_ports scl_i_o]\
    [get_ports sda_i_o]\
    [get_ports uart_tx]\
    [get_ports uart_rts]\
    [get_ports uart_dtr]\
    [get_ports gpio_in_out_*]\
]

set SPI_OUTPUTS [\
    concat [get_ports spi_mode_o_*]\
    [get_ports spi_sdo*_o]
]

set JTAG_OUTPUTS [\
    concat [get_ports tdo_o]\
]

set IN_PORTS [\
    concat $CORE_INPUTS $SPI_INPUTS $JTAG_INPUTS \
]

set OUT_PORTS [\
    concat $CORE_OUTPUTS $SPI_OUTPUTS $JTAG_OUTPUTS \
]

# SET INPUT DELAYS
# unlogisches Setting für ASYNC; testen was ohne passiert...
#set_input_delay -clock CLK $DEFAULT_CORECLK_IN_DELAY $CORE_INPUTS
#TODO: Remove SPI Signals and add synchronous again
# TODO: SPI-Master?
# TODO: I2C Clock definieren...
# I2C clock divider
# Constrain SPI for FLLCLK...
# Setze für False Paths für Asyn. Elemente
set_input_delay -clock SPI_SCK -clock_fall -max $DEFAULT_SPICLK_MAX_IN_DELAY $SPI_INPUTS
set_input_delay -clock SPI_SCK -clock_fall -min $DEFAULT_SPICLK_MIN_IN_DELAY $SPI_INPUTS
set_input_delay -clock TCK $DEFAULT_JTAGCLK_IN_DELAY $JTAG_INPUTS
# set_drive 1 $IN_PORTS

# SET OUTPUT DELAYS
# unlogisches Setting für ASYNC; testen was ohne passiert...
#set_output_delay -clock CLK $DEFAULT_CORECLK_OUT_DELAY $CORE_OUTPUTS
set_output_delay -clock SPI_SCK -clock_fall -max $DEFAULT_SPICLK_MAX_OUT_DELAY $SPI_OUTPUTS
set_output_delay -clock SPI_SCK -clock_fall -min $DEFAULT_SPICLK_MIN_OUT_DELAY $SPI_OUTPUTS
set_output_delay -clock TCK -clock_fall $DEFAULT_CORECLK_OUT_DELAY $JTAG_OUTPUTS
# Wenn die Pads nach Innovus ausgelagert werden: Müssen wir dann I/O Loads für die Signale an die PADs definieren?
set_load 20 $OUT_PORTS

# Possibly add End Point
# SET FALSE PATH FROM RESET PIN TO RESET SYNCHRONIZER
set_false_path -from [vfind port:pulpino_top/rst_n]
set_false_path -from [vfind port:pulpino_top/clk_sel_i]
# SET FALSE PATH FROM UART INPUTS, SYNCHRONIZED IN UART PERIPHERAL
set_false_path -from [vfind port:pulpino_top/uart_rx]
set_false_path -from [vfind port:pulpino_top/uart_cts]
set_false_path -from [vfind port:pulpino_top/uart_dsr]
# SET FALSE PATH FROM GPIO IN, AS SYNCHRONIZED IN GPIO PERIPHERAL
set_false_path -from [vfind port:pulpino_top/gpio_in_out_*]
#set_disable_timing -from RXEN -to Y [vfind -regexp \[0-9\](?!_BOND) inst:pulpino_top/PAD_gpio_in_out_*]
# SET FALSE PATH FROM I2C IN, AS SYNCHRONIZED IN I2C PERIPHERAL
set_false_path -from [vfind port:pulpino_top/scl_i_o]
set_false_path -from [vfind port:pulpino_top/sda_i_o]
# SET FALSE PATH FROM FETCH_ENABLE IN, AS SYNCHRONIZED IN EVENT UNIT PERIPHERAL
set_false_path -from [vfind port:pulpino_top/fetch_enable_i]
# NOTE: DO NOT SET FALSE PATH FOR SPI MASTER INPUTS, THEY ARE NOT SYNCHRONIZED!

# SET I/O LOAD
# adapted from dtmf_chip.sdc of AdvGenusLabs
#set_driving_cell -lib_cell IUMB -library u065gioll25mvir_33_tc -no_design_rule -pin PAD -from_pin DO [all_inputs]
#set_driving_cell -lib_cell IUMB -library u065gioll25mvir_33_tc -no_design_rule -pin TODO: Correct PIN for Input (e.g. Y) -from_pin DO [all_inputs]
# capacitance of PAD OF IUMB from the library
