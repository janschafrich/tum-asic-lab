# ####################################################################

#  Created by Genus(TM) Synthesis Solution 19.14-s108_1 on Tue Jan 14 12:26:21 CET 2025

# ####################################################################

set sdc_version 2.0

set_units -capacitance 1000fF
set_units -time 1000ps

# Set the current design
current_design pulpino_top

create_clock -name "CLK" -period 50.0 -waveform {0.0 25.0} [get_ports clk]
set_clock_transition 2.0 [get_clocks CLK]
create_clock -name "SPI_SCK" -period 80.0 -waveform {0.0 40.0} [get_ports spi_clk_i]
set_clock_transition 2.0 [get_clocks SPI_SCK]
create_clock -name "TCK" -period 50.0 -waveform {0.0 25.0} [get_ports tck_i]
set_clock_transition 2.0 [get_clocks TCK]
set_load -pin_load 20.0 [get_ports tdo_o]
set_false_path -from [list \
  [get_ports rst_n]  \
  [get_ports clk_sel_i]  \
  [get_ports uart_rx]  \
  [get_ports uart_cts]  \
  [get_ports uart_dsr]  \
  [get_ports fetch_enable_i] ]
set_clock_groups -name "group1" -asynchronous -group [get_clocks CLK] -group [get_clocks SPI_SCK] -group [get_clocks TCK]
set_clock_gating_check -setup 0.0 
set_input_delay -clock [get_clocks SPI_SCK] -clock_fall -add_delay -max 6.9 [get_ports spi_cs_i]
set_input_delay -clock [get_clocks SPI_SCK] -clock_fall -add_delay -max 6.9 [get_ports spi_sdi0_i]
set_input_delay -clock [get_clocks SPI_SCK] -clock_fall -add_delay -max 6.9 [get_ports spi_sdi1_i]
set_input_delay -clock [get_clocks SPI_SCK] -clock_fall -add_delay -max 6.9 [get_ports spi_sdi2_i]
set_input_delay -clock [get_clocks SPI_SCK] -clock_fall -add_delay -max 6.9 [get_ports spi_sdi3_i]
set_input_delay -clock [get_clocks SPI_SCK] -clock_fall -add_delay -min 1.3 [get_ports spi_cs_i]
set_input_delay -clock [get_clocks SPI_SCK] -clock_fall -add_delay -min 1.3 [get_ports spi_sdi0_i]
set_input_delay -clock [get_clocks SPI_SCK] -clock_fall -add_delay -min 1.3 [get_ports spi_sdi1_i]
set_input_delay -clock [get_clocks SPI_SCK] -clock_fall -add_delay -min 1.3 [get_ports spi_sdi2_i]
set_input_delay -clock [get_clocks SPI_SCK] -clock_fall -add_delay -min 1.3 [get_ports spi_sdi3_i]
set_input_delay -clock [get_clocks TCK] -add_delay 10.0 [get_ports trstn_i]
set_input_delay -clock [get_clocks TCK] -add_delay 10.0 [get_ports tms_i]
set_input_delay -clock [get_clocks TCK] -add_delay 10.0 [get_ports tdi_i]
set_output_delay -clock [get_clocks TCK] -clock_fall -add_delay 10.0 [get_ports tdo_o]
set_clock_latency -source -max 5.9 [get_clocks SPI_SCK]
set_clock_latency -source -min 2.3 [get_clocks SPI_SCK]
set_clock_latency -source -max 5.9 [get_clocks TCK]
set_clock_latency -source -min 2.3 [get_clocks TCK]
