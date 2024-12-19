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
    input   logic                       output_length_byte,    

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

    logic   [7:0]   addr_cntr_s;
    logic   [7:0]   addr_s;

    // for keccak_copro
    logic           clk_s;
    logic           rst_n_s;
    logic           start_s;
    reg [63:0]      din_s;
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
                if (start)      n_state = WRITE;
            WRITE:  // write input from local RAM into accel buffer
                if (start_s)    n_state = WAIT;
            WAIT:   // wait for the accel to compute the hash
                if (ready_s)    n_state = READ;
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
        unique case (state)
            IDLE : begin
                // NULL
            end

            WRITE: begin // write input from local RAM into accel buffer
                mem_en_a                = 1'b1;
                mem_we_a                = 1'b0; // read
                mem_be_a                = 1'b1; // enable burst
                mem_en_b                = 1'b1;
                mem_we_b                = 1'b0; // read
                mem_be_b                = 1'b1; // enable burst
                mem_addr_a              = addr_s;
                mem_addr_b              = addr_s + 1;                
                din_s[31:0]             = mem_rdata_a;
                din_s[63:32]            = mem_rdata_b;
            end

            WAIT: begin
                addr_s                  = 0;
                mem_en_a                = 1'b0;
                mem_en_b                = 1'b0;      

            end

            READ: begin  // read hash from accel buffer into local RAM
                mem_en_a                = 1'b1; // enable memory
                mem_we_a                = 1'b1; // write
                mem_be_a                = 1'b1; // enable burst
                mem_en_b                = 1'b1;
                mem_we_b                = 1'b1; // write
                mem_be_b                = 1'b1; // enable burst
                mem_addr_a              = addr_s;
                mem_addr_b              = addr_s + 1; 
                mem_wdata_a             = dout_s[31:0];
                mem_wdata_b             = dout_s[63:32];
            end

            DONE : begin
                accel_state     = ST_DONE;
            end

        endcase
    end


    // keccak copro control
    always_ff @(posedge clk, negedge rst_n)
    begin
        if (!rst_n) begin
            start_s          = 1'b0;
        end
        else begin
            unique case (state)
                IDLE : begin
                    din_valid_s   = 1'b0;

                end

                WRITE :
                    if (addr_cntr_s > output_length_byte) din_valid_s = 1'b1;

                WAIT: begin
                    start_s     = 1'b1;
                    ready_s     = 1'b1;     // extract directly after first permutation 
                end

                READ: begin
                    start_s     = 1'b0;
                end


                DONE : begin
                    done = 1'b1;        // feedback for CPU - where to put??
                end

                default : begin
                    // NULL
                end
            endcase
        end
    end

    // address generator
    always_ff @(posedge clk, negedge rst_n)
    begin
        if (!rst_n) begin
            addr_s          = 0;    
            addr_cntr_s     = 0;
        end
        else begin
            case (state)

                WRITE: begin
                    if (output_length_byte > addr_cntr_s) begin       
                        addr_s      = addr_cntr_s/4;                      // word addressable RAM, word = 32 bit
                        addr_cntr_s   = addr_cntr_s + 8;                    // 64 bit are transferred at a time
                    end
                end

                WAIT: addr_cntr_s = 0;

                READ: begin
                    if (output_length_byte > addr_cntr_s) begin       
                        addr_s      = addr_cntr_s/4;                      // word addressable RAM, word = 32 bit
                        addr_cntr_s   = addr_cntr_s + 8;                    // 64 bit are transferred at a time
                    end
                end

                default: addr_cntr_s = 0;

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
    // assign done         = done_s;    // output

endmodule
