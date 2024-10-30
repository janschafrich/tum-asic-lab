module pulpino_top_pad(
    // Clock and Reset
    inout clk_pad,
    inout rst_n_pad,
    inout fetch_enable_i_pad,
    inout clk_sel_i_pad,

    // SPI Slave
    inout spi_clk_i_pad,
    inout spi_cs_i_pad,
    inout spi_mode_o_pad_0,
    inout spi_mode_o_pad_1,
    inout spi_sdo0_o_pad,
    inout spi_sdo1_o_pad,
    inout spi_sdo2_o_pad,
    inout spi_sdo3_o_pad,
    inout spi_sdi0_i_pad,
    inout spi_sdi1_i_pad,
    inout spi_sdi2_i_pad,
    inout spi_sdi3_i_pad,

    // SPI Master
    inout spi_master_clk_o_pad,
    inout spi_master_csn0_o_pad,
    inout spi_master_csn1_o_pad,
    inout spi_master_csn2_o_pad,
    inout spi_master_csn3_o_pad,
    inout spi_master_mode_o_pad_0,
    inout spi_master_mode_o_pad_1,
    inout spi_master_sdo0_o_pad,
    inout spi_master_sdo1_o_pad,
    inout spi_master_sdo2_o_pad,
    inout spi_master_sdo3_o_pad,
    inout spi_master_sdi0_i_pad,
    inout spi_master_sdi1_i_pad,
    inout spi_master_sdi2_i_pad,
    inout spi_master_sdi3_i_pad,

    // I2C
    inout scl_pad_i_o_pad,
    inout sda_pad_i_o_pad,

    // UART / RS-232
    inout uart_tx_pad,
    inout uart_rx_pad,
    inout uart_rts_pad,
    inout uart_dtr_pad,
    inout uart_cts_pad,
    inout uart_dsr_pad,

    // GPIO
    inout gpio_in_out_pad_0,
    inout gpio_in_out_pad_1,
    inout gpio_in_out_pad_2,
    inout gpio_in_out_pad_3,
    inout gpio_in_out_pad_4,
    inout gpio_in_out_pad_5,
    inout gpio_in_out_pad_6,
    inout gpio_in_out_pad_7,

    // JTAG signals
    inout tck_i_pad,
    inout trstn_i_pad,
    inout tms_i_pad,
    inout tdi_i_pad,
    inout tdo_o_pad
);

    // Clock and Reset
    wire clk_int;
    wire rst_n_int;
    wire fetch_enable_i_int;
    wire clk_sel_i_int;

    // SPI Slave
    wire spi_clk_i_int;
    wire spi_cs_i_int;
    wire [1:0] spi_mode_o_int;
    wire spi_sdo0_o_int;
    wire spi_sdo1_o_int;
    wire spi_sdo2_o_int;
    wire spi_sdo3_o_int;
    wire spi_sdi0_i_int;
    wire spi_sdi1_i_int;
    wire spi_sdi2_i_int;
    wire spi_sdi3_i_int;

    // SPI Master
    wire spi_master_clk_o_int;
    wire spi_master_csn0_o_int;
    wire spi_master_csn1_o_int;
    wire spi_master_csn2_o_int;
    wire spi_master_csn3_o_int;
    wire [1:0] spi_master_mode_o_int;
    wire spi_master_sdo0_o_int;
    wire spi_master_sdo1_o_int;
    wire spi_master_sdo2_o_int;
    wire spi_master_sdo3_o_int;
    wire spi_master_sdi0_i_int;
    wire spi_master_sdi1_i_int;
    wire spi_master_sdi2_i_int;
    wire spi_master_sdi3_i_int;

    // I2C
    wire scl_pad_i_int;
    wire scl_pad_o_int;
    wire scl_padoen_o_int;
    wire sda_pad_i_int;
    wire sda_pad_o_int;
    wire sda_padoen_o_int;

    // UART
    wire uart_tx_int;
    wire uart_rx_int;
    wire uart_rts_int;
    wire uart_dtr_int;
    wire uart_cts_int;
    wire uart_dsr_int;

    // GPIO
    wire [31:0] gpio_in_int;
    wire [31:0] gpio_out_int;
    wire [31:0] gpio_dir_int;

    assign gpio_in_int[8] = 1'b0;
    assign gpio_in_int[9] = 1'b0;
    assign gpio_in_int[10] = 1'b0;
    assign gpio_in_int[11] = 1'b0;
    assign gpio_in_int[12] = 1'b0;
    assign gpio_in_int[13] = 1'b0;
    assign gpio_in_int[14] = 1'b0;
    assign gpio_in_int[15] = 1'b0;
    assign gpio_in_int[16] = 1'b0;
    assign gpio_in_int[17] = 1'b0;
    assign gpio_in_int[18] = 1'b0;
    assign gpio_in_int[19] = 1'b0;
    assign gpio_in_int[20] = 1'b0;
    assign gpio_in_int[21] = 1'b0;
    assign gpio_in_int[22] = 1'b0;
    assign gpio_in_int[23] = 1'b0;
    assign gpio_in_int[24] = 1'b0;
    assign gpio_in_int[25] = 1'b0;
    assign gpio_in_int[26] = 1'b0;
    assign gpio_in_int[27] = 1'b0;
    assign gpio_in_int[28] = 1'b0;
    assign gpio_in_int[29] = 1'b0;
    assign gpio_in_int[30] = 1'b0;
    assign gpio_in_int[31] = 1'b0;

    // PAD Configuration 
    wire [191:0] gpio_padcfg_port;

    wire [5:0] gpio_padcfg_int_0;
    wire [5:0] gpio_padcfg_int_1;
    wire [5:0] gpio_padcfg_int_2;
    wire [5:0] gpio_padcfg_int_3;
    wire [5:0] gpio_padcfg_int_4;
    wire [5:0] gpio_padcfg_int_5;
    wire [5:0] gpio_padcfg_int_6;
    wire [5:0] gpio_padcfg_int_7;
    wire [5:0] gpio_padcfg_int_8;
    wire [5:0] gpio_padcfg_int_9;
    wire [5:0] gpio_padcfg_int_10;
    wire [5:0] gpio_padcfg_int_11;
    wire [5:0] gpio_padcfg_int_12;
    wire [5:0] gpio_padcfg_int_13;
    wire [5:0] gpio_padcfg_int_14;
    wire [5:0] gpio_padcfg_int_15;
    wire [5:0] gpio_padcfg_int_16;
    wire [5:0] gpio_padcfg_int_17;
    wire [5:0] gpio_padcfg_int_18;
    wire [5:0] gpio_padcfg_int_19;
    wire [5:0] gpio_padcfg_int_20;
    wire [5:0] gpio_padcfg_int_21;
    wire [5:0] gpio_padcfg_int_22;
    wire [5:0] gpio_padcfg_int_23;
    wire [5:0] gpio_padcfg_int_24;
    wire [5:0] gpio_padcfg_int_25;
    wire [5:0] gpio_padcfg_int_26;
    wire [5:0] gpio_padcfg_int_27;
    wire [5:0] gpio_padcfg_int_28;
    wire [5:0] gpio_padcfg_int_29;
    wire [5:0] gpio_padcfg_int_30;
    wire [5:0] gpio_padcfg_int_31;

    assign gpio_padcfg_int_0 = gpio_padcfg_port[5:0];
    assign gpio_padcfg_int_1 = gpio_padcfg_port[11:6];
    assign gpio_padcfg_int_2 = gpio_padcfg_port[17:12];
    assign gpio_padcfg_int_3 = gpio_padcfg_port[23:18];
    assign gpio_padcfg_int_4 = gpio_padcfg_port[29:24];
    assign gpio_padcfg_int_5 = gpio_padcfg_port[35:30];
    assign gpio_padcfg_int_6 = gpio_padcfg_port[41:36];
    assign gpio_padcfg_int_7 = gpio_padcfg_port[47:42];
    assign gpio_padcfg_int_8 = gpio_padcfg_port[53:48];
    assign gpio_padcfg_int_9 = gpio_padcfg_port[59:54];
    assign gpio_padcfg_int_10 = gpio_padcfg_port[65:60];
    assign gpio_padcfg_int_11 = gpio_padcfg_port[71:66];
    assign gpio_padcfg_int_12 = gpio_padcfg_port[77:72];
    assign gpio_padcfg_int_13 = gpio_padcfg_port[83:78];
    assign gpio_padcfg_int_14 = gpio_padcfg_port[89:84];
    assign gpio_padcfg_int_15 = gpio_padcfg_port[95:90];
    assign gpio_padcfg_int_16 = gpio_padcfg_port[101:96];
    assign gpio_padcfg_int_17 = gpio_padcfg_port[107:102];
    assign gpio_padcfg_int_18 = gpio_padcfg_port[113:108];
    assign gpio_padcfg_int_19 = gpio_padcfg_port[119:114];
    assign gpio_padcfg_int_20 = gpio_padcfg_port[125:120];
    assign gpio_padcfg_int_21 = gpio_padcfg_port[131:126];
    assign gpio_padcfg_int_22 = gpio_padcfg_port[137:132];
    assign gpio_padcfg_int_23 = gpio_padcfg_port[143:138];
    assign gpio_padcfg_int_24 = gpio_padcfg_port[149:144];
    assign gpio_padcfg_int_25 = gpio_padcfg_port[155:150];
    assign gpio_padcfg_int_26 = gpio_padcfg_port[161:156];
    assign gpio_padcfg_int_27 = gpio_padcfg_port[167:162];
    assign gpio_padcfg_int_28 = gpio_padcfg_port[173:168];
    assign gpio_padcfg_int_29 = gpio_padcfg_port[179:174];
    assign gpio_padcfg_int_30 = gpio_padcfg_port[185:180];
    assign gpio_padcfg_int_31 = gpio_padcfg_port[191:186];

    wire [191:0] pad_cfg_port;

    wire [5:0] pad_cfg_int_0;
    wire [5:0] pad_cfg_int_1;
    wire [5:0] pad_cfg_int_2;
    wire [5:0] pad_cfg_int_3;
    wire [5:0] pad_cfg_int_4;
    wire [5:0] pad_cfg_int_5;
    wire [5:0] pad_cfg_int_6;
    wire [5:0] pad_cfg_int_7;
    wire [5:0] pad_cfg_int_8;
    wire [5:0] pad_cfg_int_9;
    wire [5:0] pad_cfg_int_10;
    wire [5:0] pad_cfg_int_11;
    wire [5:0] pad_cfg_int_12;
    wire [5:0] pad_cfg_int_13;
    wire [5:0] pad_cfg_int_14;
    wire [5:0] pad_cfg_int_15;
    wire [5:0] pad_cfg_int_16;
    wire [5:0] pad_cfg_int_17;
    wire [5:0] pad_cfg_int_18;
    wire [5:0] pad_cfg_int_19;
    wire [5:0] pad_cfg_int_20;
    wire [5:0] pad_cfg_int_21;
    wire [5:0] pad_cfg_int_22;
    wire [5:0] pad_cfg_int_23;
    wire [5:0] pad_cfg_int_24;
    wire [5:0] pad_cfg_int_25;
    wire [5:0] pad_cfg_int_26;
    wire [5:0] pad_cfg_int_27;
    wire [5:0] pad_cfg_int_28;
    wire [5:0] pad_cfg_int_29;
    wire [5:0] pad_cfg_int_30;
    wire [5:0] pad_cfg_int_31;
    
    assign pad_cfg_int_0 = pad_cfg_port[5:0];
    assign pad_cfg_int_1 = pad_cfg_port[11:6];
    assign pad_cfg_int_2 = pad_cfg_port[17:12];
    assign pad_cfg_int_3 = pad_cfg_port[23:18];
    assign pad_cfg_int_4 = pad_cfg_port[29:24];
    assign pad_cfg_int_5 = pad_cfg_port[35:30];
    assign pad_cfg_int_6 = pad_cfg_port[41:36];
    assign pad_cfg_int_7 = pad_cfg_port[47:42];
    assign pad_cfg_int_8 = pad_cfg_port[53:48];
    assign pad_cfg_int_9 = pad_cfg_port[59:54];
    assign pad_cfg_int_10 = pad_cfg_port[65:60];
    assign pad_cfg_int_11 = pad_cfg_port[71:66];
    assign pad_cfg_int_12 = pad_cfg_port[77:72];
    assign pad_cfg_int_13 = pad_cfg_port[83:78];
    assign pad_cfg_int_14 = pad_cfg_port[89:84];
    assign pad_cfg_int_15 = pad_cfg_port[95:90];
    assign pad_cfg_int_16 = pad_cfg_port[101:96];
    assign pad_cfg_int_17 = pad_cfg_port[107:102];
    assign pad_cfg_int_18 = pad_cfg_port[113:108];
    assign pad_cfg_int_19 = pad_cfg_port[119:114];
    assign pad_cfg_int_20 = pad_cfg_port[125:120];
    assign pad_cfg_int_21 = pad_cfg_port[131:126];
    assign pad_cfg_int_22 = pad_cfg_port[137:132];
    assign pad_cfg_int_23 = pad_cfg_port[143:138];
    assign pad_cfg_int_24 = pad_cfg_port[149:144];
    assign pad_cfg_int_25 = pad_cfg_port[155:150];
    assign pad_cfg_int_26 = pad_cfg_port[161:156];
    assign pad_cfg_int_27 = pad_cfg_port[167:162];
    assign pad_cfg_int_28 = pad_cfg_port[173:168];
    assign pad_cfg_int_29 = pad_cfg_port[179:174];
    assign pad_cfg_int_30 = pad_cfg_port[185:180];
    assign pad_cfg_int_31 = pad_cfg_port[191:186];

    // JTAG signals
    wire tck_i_int;
    wire trstn_i_int;
    wire tms_i_int;
    wire tdi_i_int;
    wire tdo_o_int;


    pulpino_top
    pulpino_top_inst
    (
        // Clock and Reset
        .clk(clk_int),
        .rst_n(rst_n_int),

        .clk_sel_i(clk_sel_i_int),
        .testmode_i(1'b0),
        .fetch_enable_i(fetch_enable_i_int),
        .scan_enable_i(1'b0),

        //SPI Slave
        .spi_clk_i(spi_clk_i_int),
        .spi_cs_i(spi_cs_i_int),
        .spi_mode_o(spi_mode_o_int),
        .spi_sdo0_o(spi_sdo0_o_int),
        .spi_sdo1_o(spi_sdo1_o_int),
        .spi_sdo2_o(spi_sdo2_o_int),
        .spi_sdo3_o(spi_sdo3_o_int),
        .spi_sdi0_i(spi_sdi0_i_int),
        .spi_sdi1_i(spi_sdi1_i_int),
        .spi_sdi2_i(spi_sdi2_i_int),
        .spi_sdi3_i(spi_sdi3_i_int),

        //SPI Master
        .spi_master_clk_o  (spi_master_clk_o_int),
        .spi_master_csn0_o (spi_master_csn0_o_int),
        .spi_master_csn1_o (spi_master_csn1_o_int),
        .spi_master_csn2_o (spi_master_csn2_o_int),
        .spi_master_csn3_o (spi_master_csn3_o_int),
        .spi_master_mode_o (spi_master_mode_o_int),
        .spi_master_sdo0_o (spi_master_sdo0_o_int),
        .spi_master_sdo1_o (spi_master_sdo1_o_int),
        .spi_master_sdo2_o (spi_master_sdo2_o_int),
        .spi_master_sdo3_o (spi_master_sdo3_o_int),
        .spi_master_sdi0_i (spi_master_sdi0_i_int),
        .spi_master_sdi1_i (spi_master_sdi1_i_int),
        .spi_master_sdi2_i (spi_master_sdi2_i_int),
        .spi_master_sdi3_i (spi_master_sdi3_i_int),

        .scl_pad_i         (scl_pad_i_int),
        .scl_pad_o         (scl_pad_o_int),
        .scl_padoen_o      (scl_padoen_o_int),
        .sda_pad_i         (sda_pad_i_int),
        .sda_pad_o         (sda_pad_o_int),
        .sda_padoen_o      (sda_padoen_o_int),

        .uart_tx           (uart_tx_int),
        .uart_rx           (uart_rx_int),
        .uart_rts          (uart_rts_int),
        .uart_dtr          (uart_dtr_int),
        .uart_cts          (uart_cts_int),
        .uart_dsr          (uart_dsr_int),

        .gpio_in           (gpio_in_int),
        .gpio_out          (gpio_out_int),
        .gpio_dir          (gpio_dir_int),

        .gpio_padcfg       (gpio_padcfg_port),
        .pad_cfg_o         (pad_cfg_port),

        // JTAG signals
        .tck_i             (tck_i_int),
        .trstn_i           (trstn_i_int),
        .tms_i             (tms_i_int),
        .tdi_i             (tdi_i_int),
        .tdo_o             (tdo_o_int)
    );


    ////////////////////////////// IO Cells //////////////////////////////
    //////////////////////////////
    ////    BIAS_GENERATOR    ////
    //////////////////////////////
    // Generates IO Biasing (VREFN, VREFP, POCN, SWING1V8)
    // 3.3V: MODE_SEL=0, MODE=0

    // Bias Generator
    //IN22FDX_GPIO33_10M19S40PI_BIAS_GENERATOR_H PAD_BIAS_GENERATOR (.VREFN(), .VREFP(), .POCN(), .SWING1V8(), .MODE18(1'b0), .MODE_SEL(1'b0), .MODE());  // MODE_SEL 0 for 3.3V


    //////////////////////////////
    //// Clock and Reset pads ////
    //////////////////////////////
    // Inputs
    sky130_fd_io__top_gpiov2 PAD_clk (.PAD(clk_pad), .DM(3'b000), .HLD_H_N(1'b1), .IN(clk_int), .INP_DIS(1'b0), .IB_MODE_SEL(1'b0), .ENABLE_H(1'b1), .ENABLE_VDDA_H(1'b1), .ENABLE_INP_H(1'b0), .OE_N(1'b1),
                                 .TIE_HI_ESD(), .TIE_LO_ESD(), .SLOW(1'b0), .VTRIP_SEL(1'b0), .HLD_OVR(1'b0), .ANALOG_EN(1'b0), .ANALOG_SEL(), .ENABLE_VDDIO(1'b1), .ENABLE_VSWITCH_H(1'b1),
                                 .ANALOG_POL(), .OUT(), .AMUXBUS_A(), .AMUXBUS_B()
                                );
    sky130_fd_io__top_gpiov2 PAD_rst_n ();
    sky130_fd_io__top_gpiov2 PAD_fetch_enable_i ();
    sky130_fd_io__top_gpiov2 PAD_clk_sel_i ();

    //////////////////////////////
    //// SPI Slave            ////
    //////////////////////////////
    // Inputs
    sky130_fd_io__top_gpiov2 PAD_spi_clk_i ();
    sky130_fd_io__top_gpiov2 PAD_spi_cs_i ();

    // Outputs
    sky130_fd_io__top_gpiov2 PAD_spi_mode_o_0 ();
    sky130_fd_io__top_gpiov2 PAD_spi_mode_o_1 ();
    sky130_fd_io__top_gpiov2 PAD_spi_sdo0_o ();
    sky130_fd_io__top_gpiov2 PAD_spi_sdo1_o ();
    sky130_fd_io__top_gpiov2 PAD_spi_sdo2_o ();
    sky130_fd_io__top_gpiov2 PAD_spi_sdo3_o ();

    // Inputs
    sky130_fd_io__top_gpiov2 PAD_spi_sdi0_i ();
    sky130_fd_io__top_gpiov2 PAD_spi_sdi1_i ();
    sky130_fd_io__top_gpiov2 PAD_spi_sdi2_i ();
    sky130_fd_io__top_gpiov2 PAD_spi_sdi3_i ();

    //////////////////////////////
    //// SPI MASTER           ////
    //////////////////////////////
    // Outputs
    sky130_fd_io__top_gpiov2 PAD_spi_master_clk_o ();

    sky130_fd_io__top_gpiov2 PAD_spi_master_csn0_o ();
    sky130_fd_io__top_gpiov2 PAD_spi_master_csn1_o ();
    sky130_fd_io__top_gpiov2 PAD_spi_master_csn2_o ();
    sky130_fd_io__top_gpiov2 PAD_spi_master_csn3_o ();

    sky130_fd_io__top_gpiov2 PAD_spi_master_mode_o_0 ();
    sky130_fd_io__top_gpiov2 PAD_spi_master_mode_o_1 ();

    sky130_fd_io__top_gpiov2 PAD_spi_master_sdo0_o ();
    sky130_fd_io__top_gpiov2 PAD_spi_master_sdo1_o ();
    sky130_fd_io__top_gpiov2 PAD_spi_master_sdo2_o ();
    sky130_fd_io__top_gpiov2 PAD_spi_master_sdo3_o ();

    // Inputs
    sky130_fd_io__top_gpiov2 PAD_spi_master_sdi0_i ();
    sky130_fd_io__top_gpiov2 PAD_spi_master_sdi1_i ();
    sky130_fd_io__top_gpiov2 PAD_spi_master_sdi2_i ();
    sky130_fd_io__top_gpiov2 PAD_spi_master_sdi3_i ();

    //////////////////////////////
    //// I2C                  ////
    // Inouts
    //////////////////////////////
    sky130_fd_io__top_gpiov2 PAD_scl_pad_i_o ();
    sky130_fd_io__top_gpiov2 PAD_sda_pad_i_o ();

    //////////////////////////////
    //// UART                 ////
    //////////////////////////////
    // Outputs

    sky130_fd_io__top_gpiov2 PAD_uart_tx ();

    // Inputs
    sky130_fd_io__top_gpiov2 PAD_uart_rx ();

    // Outputs
    sky130_fd_io__top_gpiov2 PAD_uart_rts ();
    sky130_fd_io__top_gpiov2 PAD_uart_dtr ();

    // Inputs
    sky130_fd_io__top_gpiov2 PAD_uart_cts ();
    sky130_fd_io__top_gpiov2 PAD_uart_dsr ();


    //////////////////////////////
    //// JTAG pads            ////
    //////////////////////////////
    // Inputs
    sky130_fd_io__top_gpiov2 PAD_tck_i ();
    sky130_fd_io__top_gpiov2 PAD_trstn_i ();
    sky130_fd_io__top_gpiov2 PAD_tms_i ();
    sky130_fd_io__top_gpiov2 PAD_tdi_i ();

    // Output
    sky130_fd_io__top_gpiov2 PAD_tdo_o ();


    //////////////////////////////
    //// GPIO Interface       ////
    //////////////////////////////
    sky130_fd_io__top_gpiov2 PAD_gpio_in_out_0 ();
    sky130_fd_io__top_gpiov2 PAD_gpio_in_out_1 ();
    sky130_fd_io__top_gpiov2 PAD_gpio_in_out_2 ();
    sky130_fd_io__top_gpiov2 PAD_gpio_in_out_3 ();
    sky130_fd_io__top_gpiov2 PAD_gpio_in_out_4 ();
    sky130_fd_io__top_gpiov2 PAD_gpio_in_out_5 ();
    sky130_fd_io__top_gpiov2 PAD_gpio_in_out_6 ();
    sky130_fd_io__top_gpiov2 PAD_gpio_in_out_7 ();
endmodule
