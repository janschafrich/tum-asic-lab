///////////////////////////////////////////////////////////////////////////////
// @file     tb_accelerator_template.sv
// @brief    Testbench for the accelerator template
// @author   Patrick Karl <patrick.karl@tum.de>
// @license  TBD
///////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ns

module tb_accelerator_wrapper
();

    localparam AXI_ADDR_WIDTH   = 32;   // AXI4 slave address width
    localparam INT_ADDR_WIDTH   = 20;   // internal accelerator address width
    localparam DATA_WIDTH       = 32;   // data width of whole system

    localparam CTRL_WORDS       = 4;    // number of control words
    localparam STAT_WORDS       = 4;    // number of status words
    localparam MAX_CNT_ADDR     = 64;   // max data memory address
    localparam INCREMENT        = 1;    // Adder increment
    localparam DEPTH            = 256;  // data memory depth
    
    // Don't change below
    localparam MAX_WORDS        = (CTRL_WORDS > STAT_WORDS) ? CTRL_WORDS : STAT_WORDS;
    localparam MAX_WORD_BITS    = (MAX_WORDS > 1) ? $clog2(MAX_WORDS) : 1;

    // memory map
    localparam CTRL_BASE_ADDR   = 0;
    localparam STAT_BASE_ADDR   = CTRL_WORDS;
    localparam DATA_BASE_ADDR   = 1 << (INT_ADDR_WIDTH-1);


    logic                       clk_s     = 1'b0;
    logic                       rst_n_s   = 1'b0;
    logic                       done_s;

    logic                       mem_req_s;
    logic [INT_ADDR_WIDTH-1:0]  mem_addr_s;
    logic                       mem_we_s;
    logic [DATA_WIDTH/8-1:0]    mem_be_s;
    logic [DATA_WIDTH-1:0]      mem_rdata_s;
    logic [DATA_WIDTH-1:0]      mem_wdata_s;

    int data_cnt_s, addr_cnt_s;     // signals

    enum {  IDLE,
            WRITE_DATA,
            WRITE_MAX_CNT_START,
            READ_CTRL,
            READ_STATUS,
            WAIT_DONE,
            READ_RESULT } state_s, n_state_s;



    ////////////////////////////////////////////////////////////////////////
    // Clock, Reset
    ////////////////////////////////////////////////////////////////////////
    initial begin
        #20 rst_n_s = 1'b1;
    end 

    always #5 clk_s = ~ clk_s;


    //////////////////////////////////////////////////////////////
    // DUT
    //////////////////////////////////////////////////////////////
    accel_top_wrapper
    #(
        .INT_ADDR_WIDTH ( INT_ADDR_WIDTH    ),
        .DATA_WIDTH     ( DATA_WIDTH        ),
        .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH    ),
        .AXI_ID_WIDTH   ( 1                 ),
        .AXI_USER_WIDTH ( 1                 ),
        .MEM_DEPTH      ( DEPTH             ),
        .CTRL_WORDS     ( CTRL_WORDS        ),
        .STAT_WORDS     ( STAT_WORDS        )
    )
    dut
    (
        .clk            ( clk_s         ),
        .rst_n          ( rst_n_s       ),
        .testmode_i     ( 1'b0          ),
        .done           ( done_s        ),

        .axi_mem_req    ( mem_req_s     ),
        .axi_mem_addr   ( mem_addr_s    ),
        .axi_mem_we     ( mem_we_s      ),
        .axi_mem_be     ( mem_be_s      ),
        .axi_mem_rdata  ( mem_rdata_s   ),
        .axi_mem_wdata  ( mem_wdata_s   )
    );


    ///////////////////////////////////////////////////////////////
    // Stimuli
    ///////////////////////////////////////////////////////////////
    always_ff @(posedge clk_s, negedge rst_n_s)
    begin
        if (!rst_n_s)   state_s <= IDLE;
        else            state_s <= n_state_s;
    end

    always_comb
    begin
        n_state_s = state_s;
        unique case (state_s)
            IDLE :
                n_state_s = WRITE_DATA;

            WRITE_DATA :
                if (addr_cnt_s >= MAX_CNT_ADDR - 1)   
                    n_state_s = WRITE_MAX_CNT_START;
                
            WRITE_MAX_CNT_START :
                n_state_s = READ_CTRL;

            READ_CTRL : 
                if (addr_cnt_s >= CTRL_WORDS - 1)
                    n_state_s = READ_STATUS;

            READ_STATUS : 
                if (addr_cnt_s >= STAT_WORDS - 1)
                    n_state_s = WAIT_DONE;

            WAIT_DONE : 
                if (done_s)
                    n_state_s <= READ_RESULT;

            READ_RESULT :
                if (addr_cnt_s >= MAX_CNT_ADDR - 1)
                    n_state_s <= IDLE;
                
        endcase
    end


    always_comb
    begin

        // Defaults
        // 3.2.4 low level bus interface??
        mem_req_s   = 1'b0;
        mem_addr_s  = addr_cnt_s;
        mem_we_s    = 1'b0;
        mem_be_s    = '0;
        mem_wdata_s = 'x;

        unique case (state_s)
            WRITE_DATA : begin
                mem_req_s   = 1'b1;
                mem_addr_s  = DATA_BASE_ADDR + addr_cnt_s;
                mem_we_s    = 1'b1;
                mem_be_s    = '1;
                for (int i=0; i<DATA_WIDTH/8; i++)
                    mem_wdata_s[8*i + 7 -:8] = (DATA_WIDTH/8)*data_cnt_s + i;
            end

            WRITE_MAX_CNT_START : begin
                mem_req_s           = 1'b1;
                mem_addr_s          = CTRL_BASE_ADDR;
                mem_we_s            = 1'b1;
                mem_be_s            = 7;
                mem_wdata_s[7:0]    = 8'h01;
                mem_wdata_s[15:8]   = MAX_CNT_ADDR;
                mem_wdata_s[23:16]  = INCREMENT;
            end

            READ_CTRL : begin
                mem_req_s           = 1'b1;
                mem_addr_s          = CTRL_BASE_ADDR + addr_cnt_s;
            end

            READ_STATUS : begin
                mem_req_s           = 1'b1;
                mem_addr_s          = STAT_BASE_ADDR + addr_cnt_s;
            end
            
            READ_RESULT : begin
                mem_addr_s  = DATA_BASE_ADDR + addr_cnt_s;
                mem_req_s   = 1'b1;
            end

            default : begin
                // NULL
            end 

        endcase
    end


    // reset
    always_ff @(posedge clk_s, negedge rst_n_s)
    begin
        if (!rst_n_s) begin
            data_cnt_s <= 0;
            addr_cnt_s <= 0;
        end else begin
            unique case (state_s)
                WRITE_DATA : begin
                    if (data_cnt_s >= MAX_CNT_ADDR - 1)
                        data_cnt_s <= 0;
                    else
                        data_cnt_s++;

                    if (addr_cnt_s >= MAX_CNT_ADDR - 1) 
                        addr_cnt_s <= 0;
                    else
                        addr_cnt_s++;
                end

                READ_CTRL : 
                    if (addr_cnt_s >= CTRL_WORDS - 1)
                        addr_cnt_s <= 0;
                    else
                        addr_cnt_s++;

                READ_STATUS : 
                    if (addr_cnt_s >= STAT_WORDS - 1)
                        addr_cnt_s <= 0;
                    else
                        addr_cnt_s++;

                READ_RESULT :
                    if (addr_cnt_s >= MAX_CNT_ADDR - 1) 
                        addr_cnt_s <= 0;
                    else
                        addr_cnt_s++;

                default : begin
                    data_cnt_s <= 0;
                    addr_cnt_s <= 0;
                end
            endcase
        end
    end

endmodule
