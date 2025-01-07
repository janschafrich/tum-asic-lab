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
    input   logic [5:0]                 output_length_byte,    

    output  logic                       mem_en_a,           // port enable
    output  logic [ADDR_WIDTH-1:0]      mem_addr_a,         // address for port a
    output  logic                       mem_we_a,           // write enable
    output  logic [DATA_WIDTH-1:0]      mem_wdata_a,        // send data
    output  logic [DATA_WIDTH/8-1:0]    mem_be_a,           // byte of word enable
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
    
    enum {IDLE, WRITE, WAIT_HASH, READ, DONE}  state, n_state;

    localparam RATE_BIT_COUNT = 1344;        // 1344 bits

    integer  i;

    logic   [7:0]   byte_cntr_s;
    logic   [7:0]   addr_s;

    // for keccak_copro
    logic           clk_s;
    logic           rst_n_s;
    logic           start_hash;
    logic [63:0]    din_s;
    logic           din_valid_s;
    logic           buffer_full_s;
    logic           last_block_s;
    logic           ready_s;
    logic [63:0]    dout_s;
    logic           dout_valid_s;                    

    //////////////////////////////////////////////////////////////////
    // Keccak Copro
    //////////////////////////////////////////////////////////////////

    keccak #() keccak_inst 
    (
        .clk            (clk_s),
        .rst_n          (rst_n_s),
        .start          (start_hash),
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
                if (start)      n_state = WRITE;
            WRITE:  // write input from local RAM into accel buffer
                if ((byte_cntr_s >= RATE_BIT_COUNT/8) && (last_block_s == 1'b1)) n_state = WAIT_HASH;
            WAIT_HASH:   // wait for the accel to compute the hash
                if (dout_valid_s)    n_state = READ;
            READ:   // read hash from accel buffer into local RAM
                if ((byte_cntr_s >= output_length_byte) && (dout_valid_s == 1'b1)) n_state = DONE;
            DONE: begin
                // transition to idle with reset
            end
        endcase
    end

    // Memory control
    always_comb     // blocking assignments for combinatorial logic
    begin    
        // default behavior
        mem_en_a    = 1'b0;
        mem_en_b    = 1'b0;
        mem_be_a    = 4'hf; // enable all bytes of the word
        mem_be_b    = 4'hf; // enable all bytes of the word
        mem_we_a    = 1'b0; // read
        mem_we_b    = 1'b0; // read  
        unique case (state)
            IDLE : begin
                // NULL
            end

            WRITE: begin // write input from local RAM into accel buffer
                mem_en_a                = 1'b1;
                mem_en_b                = 1'b1;
            end

            WAIT_HASH: begin
                // do nothing
            end

            READ: begin  // read hash from accel buffer into local RAM
                mem_en_a                = 1'b1; // enable memory
                mem_en_b                = 1'b1;
                mem_we_a                = 1'b1; // write
                mem_we_b                = 1'b1; // write
            end

            DONE : begin
            end
        endcase
    end


    // keccak copro control
    always_ff @(posedge clk, negedge rst_n) // nonblocking (<=) assignments to describe sequential logic
    begin
        if (!rst_n) begin
            din_valid_s     <= 1'b0;
            addr_s          <= 0;
            byte_cntr_s     <= 0;
            start_hash      <= 1'b0;
            last_block_s    <= 1'b0;
        end
        else begin
            start_hash      <= 1'b0;
            din_valid_s     <= 1'b0;
            last_block_s    <= 1'b0;
            addr_s          <= 0;

            unique case (state)
                IDLE : begin
                    // do nothing
                end

                WRITE : begin
                    if (byte_cntr_s < RATE_BIT_COUNT/8) begin       
                        addr_s      <= byte_cntr_s/4;                      // word addressable RAM, word = 32 bit
                        byte_cntr_s <= byte_cntr_s + 8;
                        din_valid_s <= 1'b1;
                    end                    // 64 bit are transferred at a time
                    if (byte_cntr_s == RATE_BIT_COUNT/8) begin
                        start_hash      <= 1'b1;
                        last_block_s    <= 1'b1;
                    end
                end

                WAIT_HASH: begin
                    byte_cntr_s     <= 0;
                   //extract directly after first permutation 
                end

                READ: begin
                     if (byte_cntr_s < output_length_byte) begin       
                        addr_s      <= byte_cntr_s/4;                      // word addressable RAM, word = 32 bit
                        byte_cntr_s <= byte_cntr_s + 8;                    // 64 bit are transferred at a time
                    end
                end

                DONE : begin
                end
            endcase
        end
    end


    // output control
    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin

        end else begin
            done = 1'b0;
            case (state)
                IDLE: begin
                    accel_state = ST_IDLE;
                end
                WRITE: begin
                    accel_state = ST_WRITE;
                end

                // START_ACCEL_ST: begin
                //     accel_state = ST_START_ACCEL;
                // end
                WAIT_HASH: begin
                    accel_state = ST_WAIT;
                end

                READ: begin
                    accel_state = ST_READ;
                end
                DONE: begin
                    done        = 1'b1;
                    accel_state = ST_DONE;
                end
            endcase
        end
    end

    //////////////////////////////////////////////////////////////////
    // Assignments
    //////////////////////////////////////////////////////////////////    
    assign clk_s        = clk;
    assign rst_n_s      = rst_n;

    // assign start_hash     = start_hash;        

    assign mem_addr_a       = addr_s + 1;       // port a is multiplexed between cpu and accel
    assign mem_addr_b       = addr_s;           // port b is always connected with accel
    assign mem_wdata_a      = dout_s[31:0];
    assign mem_wdata_b      = dout_s[63:32];
    assign din_s[31:0]      = mem_rdata_a;
    assign din_s[63:32]     = mem_rdata_b;

endmodule
