///////////////////////////////////////////////////////////////////////////////
// @file     accel_wrapper.sv
// @brief    Wrapper for actual accelerator logic
// @author   Patrick Karl <patrick.karl@tum.de>
// @license  TBD
///////////////////////////////////////////////////////////////////////////////

import cfg_types_pkg::*;

module accel_wrapper
#(
    parameter MEM_ADDR_WIDTH    = 10,
    parameter MEM_DATA_WIDTH    = 32,
    parameter MEM_DEPTH         = 1024
)(
    // Clock and Reset
    input   logic                           clk,
    input   logic                           rst_n,

    output  acc_state_t                     accel_state,          
    output  acc_error_t                     accel_error,

    input   logic                           start,
    output  logic                           done,
    input   logic [7:0]                     max_cnt,
    input   logic [7:0]                     incr,

    input   logic                           mem_en,
    input   logic [MEM_ADDR_WIDTH-1:0]      mem_addr,
    input   logic                           mem_we,
    input   logic [MEM_DATA_WIDTH/8-1:0]    mem_be,
    input   logic [MEM_DATA_WIDTH-1:0]      mem_wdata,
    output  logic [MEM_DATA_WIDTH-1:0]      mem_rdata
);


    // Accelerator memory connection
    logic                           accel_mem_en_a;
    logic [MEM_ADDR_WIDTH-1:0]      accel_mem_addr_a;
    logic                           accel_mem_we_a;
    logic [MEM_DATA_WIDTH-1:0]      accel_mem_rdata_a;
    logic [MEM_DATA_WIDTH-1:0]      accel_mem_wdata_a;
    logic [MEM_DATA_WIDTH/8-1:0]    accel_mem_be_a;

    // Accelerator memory connection
    logic                           accel_mem_en_b;
    logic [MEM_ADDR_WIDTH-1:0]      accel_mem_addr_b;
    logic                           accel_mem_we_b;
    logic [MEM_DATA_WIDTH-1:0]      accel_mem_rdata_b;
    logic [MEM_DATA_WIDTH-1:0]      accel_mem_wdata_b;
    logic [MEM_DATA_WIDTH/8-1:0]    accel_mem_be_b;

    // Dual port mem port a
    logic                           mem_en_a_int;
    logic [MEM_ADDR_WIDTH-1:0]      mem_addr_a_int;
    logic                           mem_we_a_int;
    logic [MEM_DATA_WIDTH/8-1:0]    mem_be_a_int;
    logic [MEM_DATA_WIDTH-1:0]      mem_rdata_a_int;
    logic [MEM_DATA_WIDTH-1:0]      mem_wdata_a_int;



    ///////////////////////////////////////////////////////
    // Accelerator
    ///////////////////////////////////////////////////////
    example_add
    #(
        .DATA_WIDTH ( MEM_DATA_WIDTH    ),
        .ADDR_WIDTH ( MEM_ADDR_WIDTH    ) 
    )
    example_add_inst
    (
        .clk            ( clk               ),
        .rst_n          ( rst_n             ),

        .accel_state    ( accel_state       ),
        .accel_error    ( accel_error       ),

        .start          ( start             ),
        .done           ( done              ),
        .max_cnt        ( max_cnt           ),
        .incr           ( incr              ),

        .mem_en_a       ( accel_mem_en_a    ),
        .mem_addr_a     ( accel_mem_addr_a  ),
        .mem_we_a       ( accel_mem_we_a    ),
        .mem_rdata_a    ( accel_mem_rdata_a ),
        .mem_wdata_a    ( accel_mem_wdata_a ),
        .mem_be_a       ( accel_mem_be_a    ),

        .mem_en_b       ( accel_mem_en_b    ),
        .mem_addr_b     ( accel_mem_addr_b  ),
        .mem_we_b       ( accel_mem_we_b    ),
        .mem_rdata_b    ( accel_mem_rdata_b ),
        .mem_wdata_b    ( accel_mem_wdata_b ),
        .mem_be_b       ( accel_mem_be_b    )
    );


    ///////////////////////////////////////////////////////
    // True Dual Port RAM
    ///////////////////////////////////////////////////////
    true_dp_ram
    #(
      .ADDR_WIDTH ( MEM_ADDR_WIDTH      ),
      .DATA_WIDTH ( MEM_DATA_WIDTH      ),
      .DEPTH      ( MEM_DEPTH           )
    )
    ram_inst
    (
      .clk_a_i      ( clk               ),
      .en_a_i       ( mem_en_a_int      ),
      .addr_a_i     ( mem_addr_a_int    ),
      .wdata_a_i    ( mem_wdata_a_int   ),
      .rdata_a_o    ( mem_rdata_a_int   ),
      .we_a_i       ( mem_we_a_int      ),
      .be_a_i       ( mem_be_a_int      ),

      .clk_b_i      ( clk               ),
      .en_b_i       ( accel_mem_en_a    ),
      .addr_b_i     ( accel_mem_addr_a  ),
      .wdata_b_i    ( accel_mem_wdata_a ),
      .rdata_b_o    ( accel_mem_rdata_a ),
      .we_b_i       ( accel_mem_we_a    ),
      .be_b_i       ( accel_mem_be_a    )
    );


    ///////////////////////////////////////////////////////
    // Multiplex memory port a
    ///////////////////////////////////////////////////////
    assign mem_en_a_int         = start ? accel_mem_en_b    : mem_en;
    assign mem_addr_a_int       = start ? accel_mem_addr_b  : mem_addr;
    assign mem_we_a_int         = start ? accel_mem_we_b    : mem_we;  
    assign mem_wdata_a_int      = start ? accel_mem_wdata_b : mem_wdata;
    assign mem_be_a_int         = start ? accel_mem_be_b    : mem_be;

    assign mem_rdata            = mem_rdata_a_int;
    assign accel_mem_rdata_b    = mem_rdata_a_int;

endmodule
