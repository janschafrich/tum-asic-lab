///////////////////////////////////////////////////////////////////////////////
// @file     tb_config_reg.sv
// @brief    Testbench for the configuration register
// @author   Patrick Karl <patrick.karl@tum.de>
// @license  TBD
///////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ns

module tb_config_reg
();

    localparam ASYNC_READ_C             = 1;
    localparam REGISTER_STATUS_C        = 0;
    localparam DATA_WIDTH_C             = 16;

    localparam N_CTRL_WORDS_C           = 2;
    localparam N_STAT_WORDS_C           = 4;

    localparam ADDR_WIDTH_C             = $clog2(N_CTRL_WORDS_C+N_STAT_WORDS_C);

    logic clk_s; 
    logic rst_n_s;

    logic [DATA_WIDTH_C-1:0]    ctrl_vec_s [N_CTRL_WORDS_C];
    logic [DATA_WIDTH_C-1:0]    stat_vec_s [N_STAT_WORDS_C];
    logic                       stat_en_s;

    logic                       mem_en_s;
    logic [ADDR_WIDTH_C-1:0]    mem_addr_s;
    logic                       mem_we_s;
    logic [DATA_WIDTH_C/8-1:0]  mem_be_s;
    logic [DATA_WIDTH_C-1:0]    mem_wdata_s;
    logic [DATA_WIDTH_C-1:0]    mem_rdata_s;

    int cnt_s;

    enum {IDLE, WRITE_CFG, READ_STATUS, READ_CTRL} state_s, n_state_s;


    ////////////////////////////////////////////////////////////////////////
    // Clock, Reset
    ////////////////////////////////////////////////////////////////////////
    initial begin
        clk_s   = 1'b0;
        rst_n_s = 1'b0;
        #20 rst_n_s = 1'b1;
        $display("%d", ADDR_WIDTH_C);
    end 

    always #5 clk_s = ~ clk_s;


    ////////////////////////////////////////////////////////////////////////
    // DUT
    ////////////////////////////////////////////////////////////////////////
    config_reg
    #(
        .ASYNC_READ(ASYNC_READ_C),
        .ADDR_WIDTH(ADDR_WIDTH_C),
        .DATA_WIDTH(DATA_WIDTH_C),
        .N_CTRL_WORDS(N_CTRL_WORDS_C),
        .N_STAT_WORDS(N_STAT_WORDS_C),
        .REGISTER_STATUS(REGISTER_STATUS_C)
    )
    i_dut
    (
        .clk(clk_s),
        .arst_n(rst_n_s),

        .ctrl_vec(ctrl_vec_s),
        .stat_vec(stat_vec_s),
        .stat_en(stat_en_s),

        .en(mem_en_s),
        .addr(mem_addr_s),
        .we(mem_we_s),
        .be(mem_be_s),
        .wdata(mem_wdata_s),
        .rdata(mem_rdata_s)
    );

    genvar i;
    generate
        for (i=0; i<N_STAT_WORDS_C; i++)
            assign stat_vec_s[i] = {i};
    endgenerate


    ////////////////////////////////////////////////////////////////////////
    // Stimuli
    ////////////////////////////////////////////////////////////////////////
    always_ff @(posedge clk_s, negedge rst_n_s)
        if (!rst_n_s)   state_s <= IDLE;
        else            state_s <= n_state_s;

    always_comb begin: next_state
        n_state_s = state_s;
        unique case (state_s)
            IDLE :  
                if (N_CTRL_WORDS_C > 0) 
                    n_state_s = WRITE_CFG;
                else 
                    n_state_s = READ_STATUS;

            WRITE_CFG :
                if (cnt_s >= N_CTRL_WORDS_C - 1)
                    if (N_STAT_WORDS_C > 0) 
                        n_state_s = READ_STATUS;
                    else
                        n_state_s = IDLE;

            READ_STATUS :
                if (cnt_s >= N_STAT_WORDS_C - 1) 
                    if(N_CTRL_WORDS_C > 0)
                        n_state_s = READ_CTRL;
                    else
                        n_state_s = IDLE;

            READ_CTRL :
                if (cnt_s >= N_CTRL_WORDS_C - 1) 
                    n_state_s = IDLE;
        endcase
    end : next_state

    always_comb begin: mem_stimul

        // Defaults
        mem_en_s    = 1'b0;
        mem_addr_s  = '0;
        mem_we_s    = 1'b0;
        mem_be_s    = '0;
        mem_wdata_s = 'x;
        stat_en_s   = 1'b1;
        
        unique case (state_s)
            WRITE_CFG : begin
                mem_en_s    = 1'b1;
                mem_addr_s  = cnt_s;
                mem_we_s    = 1'b1;
                /* mem_be_s    = $urandom_range(2**(DATA_WIDTH_C/8)-1); */
                mem_be_s    = '1;
                for (int i=0; i<DATA_WIDTH_C/8; i++)
                    mem_wdata_s[8*i+7 -:8] = (DATA_WIDTH_C/8)*cnt_s + i;
            end 

            READ_STATUS : begin
                mem_en_s    = 1'b1;
                mem_addr_s  = N_CTRL_WORDS_C + cnt_s;
                mem_we_s    = 1'b0;
                mem_be_s    = '0;
            end

            READ_CTRL : begin
                mem_en_s    = 1'b1;
                mem_addr_s  = cnt_s;
                mem_we_s    = 1'b0;
                mem_be_s    = '0;
            end

            default : begin
                mem_en_s    = 1'b0;
                mem_addr_s  = '0;
                mem_we_s    = 1'b0;
                mem_be_s    = '0;
                mem_wdata_s = 'x;
            end
        endcase
    end : mem_stimul

    always_ff @(posedge clk_s, negedge rst_n_s) begin : counter
        if (!rst_n_s) 
            cnt_s <= 0;
        else begin
            unique case (state_s) 
                WRITE_CFG :
                    if (cnt_s >= N_CTRL_WORDS_C - 1)    cnt_s <= 0;
                    else                                cnt_s <= cnt_s + 1;
                READ_STATUS :
                    if (cnt_s >= N_STAT_WORDS_C - 1)    cnt_s <= 0;
                    else                                cnt_s <= cnt_s + 1;
                READ_CTRL :
                    if (cnt_s >= N_CTRL_WORDS_C - 1)    cnt_s <= 0;
                    else                                cnt_s <= cnt_s + 1;
                default : cnt_s <= 0;
            endcase
        end
    end : counter

endmodule
