///////////////////////////////////////////////////////////////////////////////
// @file     example_add.sv
// @brief    Example adder for accelerator template
// @author   Patrick Karl <patrick.karl@tum.de>
// @license  TBD
///////////////////////////////////////////////////////////////////////////////

import cfg_types_pkg::*;

module accel_fsm
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

    output  logic                       mem_en_a,           // port enable
    output  logic [ADDR_WIDTH-1:0]      mem_addr_a,         // address for port a
    output  logic                       mem_we_a,           // write enable
    output  logic [DATA_WIDTH-1:0]      mem_wdata_a,        // send data
    output  logic [DATA_WIDTH/8-1:0]    mem_be_a,           // burst enable? = bursts of 4 Byte
    input   logic [DATA_WIDTH-1:0]      mem_rdata_a,        // receive data

    output  logic                       mem_en_b,
    output  logic [ADDR_WIDTH-1:0]      mem_addr_b,
    output  logic                       mem_we_b,
    output  logic [DATA_WIDTH-1:0]      mem_wdata_b,
    output  logic [DATA_WIDTH/8-1:0]    mem_be_b,
    input   logic [DATA_WIDTH-1:0]      mem_rdata_b
);

    //////////////////////////////////////////////////////////////////
    // Signals to connect ports
    //////////////////////////////////////////////////////////////////
    
    enum {IDLE, WRITE, WAIT, READ, DONE}  state, n_state;

    // for keccak_copro
    logic           clk_s;
    logic           rst_n_s;
    logic           start_s;
    logic reg [63:0]din_s;
    logic           din_valid_s;
    logic           buffer_full_s;
    logic           last_block_s;
    logic           ready_s;
    logic [63:0]    dout_s;
    logic           dout_valid_s;                    

    //////////////////////////////////////////////////////////////////
    // Keccak Copro
    //////////////////////////////////////////////////////////////////

    keccap #() keccap_inst 
    (
        .clk            (clk_s),
        .rst_n          (rst_n_s),
        .start          (start_s),
        .din            (din_s),
        .din_valid      (din_valid_s),
        .buffer_full    (buffer_full_s),
        .last_block     (last_block_s),
        .ready          (ready_s),
        .dout           (dout_s),
        .dout_valid     (dout_valid_s)
    );


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
                if (start)          n_state = WRITE;
            WRITE:  // write input from local RAM into accel buffer
                if (buffer_full_s)    n_state = WAIT;
            WAIT:   // wait for the accel to compute the hash
                if (ready_s)        n_state = READ;
            READ:   // read hash from accel buffer into local RAM
                                                           n_state = DONE;
            DONE: begin
                // transition to idle with reset
            end
        endcase
    end

    // Memory control
    always_comb
    begin
        // Defaults
        accel_state = ST_IDLE;
        accel_error = ER_OKAY;
        wr_mem      = 1'b0;
        en_mem      = 1'b0;         
        unique case (state)
            IDLE : begin
                // NULL
            end

            RUNNING : begin
                accel_state = ST_RUNNING;
                en_mem      = 1'b1;
            end

            RD_REQ: begin
                accel_state             = ST_RD_REQ;
                // read lower half through port A
                mem_addr_a              = addr_s[31:0];
                data_from_mem_s[31:0]   = mem_rdata_a;
                mem_en_a                = 1'b1;

                // read upper half through port B
                mem_addr_b              = addr_s[31:0] + 1;     // word addressing
                data_from_mem_s[63:32]  = mem_rdata_b;
                mem_en_b                = 1'b1;
            end

            WR_REQ: begin
                accel_state             = ST_WR_REQ;
                // write lower half through port A
                mem_addr_a              = addr_s[31:0];
                mem_wdata_a             = data_to_mem_s[31:0];
                mem_en_a                = 1'b1;
                // write upper half through port B
                mem_addr_b              = addr_s[31:0] + 4;
                mem_wdata_b             = data_to_mem_s[63:32];
                mem_en_b                = 1'b1;
            end

            DONE : begin
                accel_state     = ST_DONE;
                en_mem          = 1'b0;
            end

        endcase
    end


    // keccak copro control
    always_ff @(posedge clk, negedge rst_n)
    begin
        if (!rst_n) begin
            done_s          = 1'b0;
            start           = 1'b0;
            data_from_mem_s = 0;
        end
        else begin
            unique case (state)
                IDLE : begin
                    // nothing to do
                    if  (enR_s == 1'b1 || enW_s == 1'b1) accel_error = ER_IDLE;
                end

                WRITE : begin

                end

                WAIT:

                READ:


                DONE : begin
                    if  (enR_s == 1'b1 || enW_s == 1'b1) accel_error = ER_MEM;
                end

                default : begin
                    // NULL
                end
            endcase
        end
    end

    //////////////////////////////////////////////////////////////////
    // Assignments
    //////////////////////////////////////////////////////////////////
    // assign mem_we_a    = 1'b0;        // use a only for reading
    // assign mem_we_b    = 1'b1;        // use b only for writing
    
    assign clk_s        = clk;
    assign rst_n_s      = rst_n;

    assign start_s      = start;     // input   
    assign done         = done_s;    // output

endmodule
