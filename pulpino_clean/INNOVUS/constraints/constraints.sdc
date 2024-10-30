# ####################################################################

#  Created by Genus(TM) Synthesis Solution 19.14-s108_1 on Tue Oct 25 11:38:00 CEST 2022

# ####################################################################

set sdc_version 2.0

set_units -capacitance 1000fF
set_units -time 1000ps

# Set the current design
current_design pulpino_top

create_clock -name "CLK" -period 50.0 -waveform {0.0 25.0} [get_pins PAD_clk/IN]
set_clock_transition 2.0 [get_clocks CLK]
create_clock -name "SPI_SCK" -period 80.0 -waveform {0.0 40.0} [get_pins PAD_spi_clk_i/IN]
set_clock_transition 2.0 [get_clocks SPI_SCK]
create_clock -name "TCK" -period 50.0 -waveform {0.0 25.0} [get_pins PAD_tck_i/IN]
set_clock_transition 2.0 [get_clocks TCK]
set_load -pin_load 20.0 [get_pins PAD_tdo_o/OUT]
set_false_path -from [list \
  [get_pins PAD_rst_n/IN]  \
  [get_pins PAD_clk_sel_i/IN]  \
  [get_pins PAD_uart_rx/IN]  \
  [get_pins PAD_uart_cts/IN]  \
  [get_pins PAD_uart_dsr/IN]  \
  [get_pins PAD_fetch_enable_i/IN] ]
set_clock_groups -name "group1" -asynchronous -group [get_clocks CLK] -group [get_clocks SPI_SCK] -group [get_clocks TCK]
set_clock_gating_check -setup 0.0 
set_input_delay -clock [get_clocks SPI_SCK] -clock_fall -add_delay -max 6.9 [get_pins PAD_spi_cs_i/IN]
set_input_delay -clock [get_clocks SPI_SCK] -clock_fall -add_delay -max 6.9 [get_pins PAD_spi_sdi0_i/IN]
set_input_delay -clock [get_clocks SPI_SCK] -clock_fall -add_delay -max 6.9 [get_pins PAD_spi_sdi1_i/IN]
set_input_delay -clock [get_clocks SPI_SCK] -clock_fall -add_delay -max 6.9 [get_pins PAD_spi_sdi2_i/IN]
set_input_delay -clock [get_clocks SPI_SCK] -clock_fall -add_delay -max 6.9 [get_pins PAD_spi_sdi3_i/IN]
set_input_delay -clock [get_clocks SPI_SCK] -clock_fall -add_delay -min 1.3 [get_pins PAD_spi_cs_i/IN]
set_input_delay -clock [get_clocks SPI_SCK] -clock_fall -add_delay -min 1.3 [get_pins PAD_spi_sdi0_i/IN]
set_input_delay -clock [get_clocks SPI_SCK] -clock_fall -add_delay -min 1.3 [get_pins PAD_spi_sdi1_i/IN]
set_input_delay -clock [get_clocks SPI_SCK] -clock_fall -add_delay -min 1.3 [get_pins PAD_spi_sdi2_i/IN]
set_input_delay -clock [get_clocks SPI_SCK] -clock_fall -add_delay -min 1.3 [get_pins PAD_spi_sdi3_i/IN]
set_input_delay -clock [get_clocks TCK] -add_delay 10.0 [get_pins PAD_trstn_i/IN]
set_input_delay -clock [get_clocks TCK] -add_delay 10.0 [get_pins PAD_tms_i/IN]
set_input_delay -clock [get_clocks TCK] -add_delay 10.0 [get_pins PAD_tdi_i/IN]
set_output_delay -clock [get_clocks TCK] -clock_fall -add_delay 10.0 [get_pins PAD_tdo_o/OUT]
set_clock_latency -source -max 5.9 [get_clocks SPI_SCK]
set_clock_latency -source -min 2.3 [get_clocks SPI_SCK]
set_clock_latency -source -max 5.9 [get_clocks TCK]
set_clock_latency -source -min 2.3 [get_clocks TCK]
