window new WaveWindow -name "Waveform"
window new browser -name "DesignWindow"
waveform using {Waveform}
waveform add -signals tb_accel_wrapper.clk_s
waveform add -signals tb_accel_wrapper.rst_n_s
waveform add -signals tb_accel_wrapper.start_s
waveform add -signals tb_accel_wrapper.accel_wrapper_inst.ram_inst.mem[0:15]
waveform add -signals tb_accel_wrapper.accel_wrapper_inst.ram_inst.en_a_i
waveform add -signals tb_accel_wrapper.accel_wrapper_inst.ram_inst.en_b_i
waveform add -signals tb_accel_wrapper.accel_wrapper_inst.ram_inst.we_a_i
waveform add -signals tb_accel_wrapper.accel_wrapper_inst.ram_inst.we_b_i
waveform add -signals tb_accel_wrapper.accel_wrapper_inst.ram_inst.addr_a_i[31:0]
waveform add -signals tb_accel_wrapper.accel_wrapper_inst.ram_inst.addr_b_i[31:0]
waveform add -signals tb_accel_wrapper.accel_wrapper_inst.ram_inst.wdata_a_i[31:0]
waveform add -signals tb_accel_wrapper.accel_wrapper_inst.ram_inst.wdata_b_i[31:0]
waveform add -signals tb_accel_wrapper.accel_wrapper_inst.ram_inst.rdata_a_o[31:0]
waveform add -signals tb_accel_wrapper.accel_wrapper_inst.ram_inst.rdata_b_o[31:0]
waveform add -signals tb_accel_wrapper.accel_wrapper_inst.accel_fsm_inst.state
waveform add -signals tb_accel_wrapper.accel_wrapper_inst.accel_fsm_inst.output_length_byte[5:0]
waveform add -signals tb_accel_wrapper.accel_wrapper_inst.accel_fsm_inst.start_hash
waveform add -signals tb_accel_wrapper.accel_wrapper_inst.accel_fsm_inst.addr_cntr_s[7:0]
waveform add -signals tb_accel_wrapper.accel_wrapper_inst.accel_fsm_inst.din_valid_s
waveform add -signals tb_accel_wrapper.accel_wrapper_inst.accel_fsm_inst.last_block_s
waveform add -signals tb_accel_wrapper.accel_wrapper_inst.accel_fsm_inst.done
waveform add -signals tb_accel_wrapper.accel_wrapper_inst.accel_fsm_inst.keccak_inst:buffer_in:buffer_data
waveform add -signals tb_accel_wrapper.accel_wrapper_inst.accel_fsm_inst.keccak_inst:buffer_in:mode
waveform add -signals tb_accel_wrapper.accel_wrapper_inst.accel_fsm_inst.keccak_inst:buffer_in:last_block
waveform add -signals tb_accel_wrapper.accel_wrapper_inst.accel_fsm_inst.keccak_inst:buffer_in:din_buffer_in
waveform add -signals tb_accel_wrapper.accel_wrapper_inst.accel_fsm_inst.keccak_inst:buffer_in:din_buffer_in_valid
waveform add -signals tb_accel_wrapper.accel_wrapper_inst.accel_fsm_inst.keccak_inst:buffer_in:dout_buffer_out
waveform add -signals tb_accel_wrapper.accel_wrapper_inst.accel_fsm_inst.keccak_inst:buffer_in:dout_buffer_out_valid



console submit -using simulator -wait yes {probe -create -shm tb.top_i.gpio_out tb.top_i.spi_clk_i tb.top_i.spi_cs_i tb.top_i.spi_sdi0_i tb.top_i.spi_sdi1_i tb.top_i.spi_sdi2_i tb.top_i.spi_sdi3_i tb.top_i.clk tb.top_i.fetch_enable_i}
