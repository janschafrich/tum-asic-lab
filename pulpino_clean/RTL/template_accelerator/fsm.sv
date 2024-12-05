///////////////////////////////////////////////////////////////////////////////
// @file     example_add.sv
// @brief    Example adder for accelerator template
// @author   Patrick Karl <patrick.karl@tum.de>
// @license  TBD
///////////////////////////////////////////////////////////////////////////////

import cfg_types_pkg::*;

module fsm
#(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)
(
    input   logic                       clk,
    input   logic                       rst_n,

    output  acc_state_t                 accel_state,
    output  acc_error_t                 accel_error,

    input   logic                       start,     
    output  logic                       done,      
    input   logic [7:0]                 max_cnt,
    input   logic [7:0]                 incr,

    output  logic                       mem_en_a,
    output  logic [ADDR_WIDTH-1:0]      mem_addr_a,
    output  logic                       mem_we_a,
    output  logic [DATA_WIDTH-1:0]      mem_wdata_a,
    output  logic [DATA_WIDTH/8-1:0]    mem_be_a,
    input   logic [DATA_WIDTH-1:0]      mem_rdata_a,

    output  logic                       mem_en_b,
    output  logic [ADDR_WIDTH-1:0]      mem_addr_b,
    output  logic                       mem_we_b,
    output  logic [DATA_WIDTH-1:0]      mem_wdata_b,
    output  logic [DATA_WIDTH/8-1:0]    mem_be_b,
    input   logic [DATA_WIDTH-1:0]      mem_rdata_b
);

    enum {IDLE, READ, WRITE} state, n_state;

    // Address counter
    logic [7:0]             addr_cnt;
    logic                   en_mem;
    logic                   wr_mem;

    //////////////////////////////////////////////////////////////////
    // Assignments
    //////////////////////////////////////////////////////////////////
    assign mem_en_a     = en_mem;
    assign mem_en_b     = en_mem;

    assign mem_we_a     = wr_mem;
    assign mem_we_b     = wr_mem;

    assign mem_addr_a   = addr_cnt;
    assign mem_addr_b   = addr_cnt + max_cnt/2;

    genvar i;
    generate
        for (i=0; i<DATA_WIDTH/8; i++) begin
            assign mem_wdata_a[8*i+7 -:8]   = mem_rdata_a[8*i+7 -:8] + incr;
            assign mem_be_a[i]              = 1'b1;

            assign mem_wdata_b[8*i+7 -:8]   = mem_rdata_b[8*i+7 -:8] + incr;
            assign mem_be_b[i]              = 1'b1;
        end
    endgenerate


    //////////////////////////////////////////////////////////////////
    // FSM
    //////////////////////////////////////////////////////////////////

    // State register
    always_ff @(posedge clk, negedge rst_n)
        if (!rst_n) state <= IDLE;
        else        state <= n_state;

    // Next state logic
    always_comb begin
        n_state = state; 
        unique case (state)
            IDLE: 
                if (start) n_state = READ;

            READ: 
                n_state = WRITE;

            WRITE: 
                if (addr_cnt >= max_cnt / 2 - 1) 
                    n_state = IDLE;
                else
                    n_state = READ;
        endcase
    end

    // Memory control
    always_comb
    begin
        // Defaults
        wr_mem      = 1'b0;
        en_mem      = 1'b0;
        accel_state = ST_IDLE;
        done        = 1'b0;
        if (max_cnt[0]) accel_error = ER_INVALID_CFG;
        else            accel_error = ER_OKAY;


        unique case (state)
            IDLE : begin
                // NULL
            end

            READ : begin
                accel_state = ST_RUNNING;
                en_mem      = 1'b1;
            end

            WRITE : begin
                accel_state = ST_RUNNING;
                en_mem      = 1'b1;
                wr_mem      = 1'b1;
                if (addr_cnt >= max_cnt / 2 - 1) 
                    done = 1'b1;
            end

        endcase
    end


    // Address counter
    always_ff @(posedge clk, negedge rst_n)
    begin
        if (!rst_n) 
            addr_cnt <= '0;
        else begin
            unique case (state)
                IDLE : 
                    addr_cnt <= '0;

                WRITE : 
                    if (addr_cnt >= max_cnt / 2 - 1)    addr_cnt <= '0;
                    else                                addr_cnt <= addr_cnt + 1;

                default : begin
                    // NULL
                end
            endcase
        end
    end

endmodule
