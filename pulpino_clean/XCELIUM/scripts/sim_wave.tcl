window new WaveWindow -name "Waveform"
window new browser -name "DesignWindow"
waveform using {Waveform}
waveform add -signals tb.top_i.clk
waveform add -signals tb.top_i.clk_int
waveform add -signals tb.top_i.fetch_enable_i
waveform add -signals tb.top_i.gpio_out
waveform add -signals tb.top_i.spi_clk_i
waveform add -signals tb.top_i.spi_cs_i
waveform add -signals tb.top_i.spi_sdi0_i
waveform add -signals tb.top_i.spi_sdi1_i
waveform add -signals tb.top_i.spi_sdi2_i
waveform add -signals tb.top_i.spi_sdi3_i

console submit -using simulator -wait yes {probe -create -shm tb.top_i.gpio_out tb.top_i.spi_clk_i tb.top_i.spi_cs_i tb.top_i.spi_sdi0_i tb.top_i.spi_sdi1_i tb.top_i.spi_sdi2_i tb.top_i.spi_sdi3_i tb.top_i.clk tb.top_i.fetch_enable_i}
