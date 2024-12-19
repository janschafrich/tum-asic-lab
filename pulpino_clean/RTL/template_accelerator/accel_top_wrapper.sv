///////////////////////////////////////////////////////////////////////////////
// @file     accel_top_wrapper.sv
// @brief    Top-level wrapper for the accelerator template
// @author   Patrick Karl <patrick.karl@tum.de>
// @license  TBD
///////////////////////////////////////////////////////////////////////////////

`include "axi_bus.sv"
import cfg_types_pkg::*;


module accel_top_wrapper
#(
    parameter AXI_ADDR_WIDTH        = 32,
    parameter AXI_ID_WIDTH          = 4,
    parameter AXI_USER_WIDTH        = 1,
    parameter INT_ADDR_WIDTH        = 20,
    parameter DATA_WIDTH            = 32,
    parameter MEM_DEPTH             = 1024,
    parameter CTRL_WORDS            = 2,
    parameter STAT_WORDS            = 2
)(
    // Clock and Reset
    input   logic                   clk,
    input   logic                   rst_n,
    input   logic                   testmode_i,
    output  logic                   done,

    // input logic                     axi_mem_req  ,
    // input logic[INT_ADDR_WIDTH-1:0] axi_mem_addr ,
    // input logic                     axi_mem_we   ,
    // input logic[DATA_WIDTH/8-1:0]   axi_mem_be   ,
    // input logic[DATA_WIDTH-1:0]     axi_mem_rdata,
    // input logic[DATA_WIDTH-1:0]     axi_mem_wdata

    AXI_BUS.Slave                   axi_slave
);


    //////////////////////////////////////////////////////////////////////////
    // Decalarations
    //////////////////////////////////////////////////////////////////////////

    // Determining number of address bits for config register
    localparam CFG_ADDR_BITS = $clog2(CTRL_WORDS + STAT_WORDS);
    localparam ALIGN_BITS = $clog2(DATA_WIDTH/8);

    // Struct for clearing start bit
    typedef struct {
        logic                           en;
        logic [CFG_ADDR_BITS-1:0]       addr;
        logic                           we;
        logic [DATA_WIDTH/8-1:0]        be;
        logic [DATA_WIDTH-1:0]          wdata;
    } clear_t;

    clear_t CTRL_CLEAR_START;

    assign CTRL_CLEAR_START.en    = 1'b1;
    assign CTRL_CLEAR_START.addr  = '0;
    assign CTRL_CLEAR_START.we    = 1'b1;
    assign CTRL_CLEAR_START.be    = 1;
    assign CTRL_CLEAR_START.wdata = '0;


    // Bus from AXI to Memory
    logic                       axi_mem_req;
    logic                       axi_mem_en;
    logic [INT_ADDR_WIDTH-1:0]  axi_mem_addr_tmp;
    logic [INT_ADDR_WIDTH-1:0]  axi_mem_addr;
    logic                       axi_mem_we;
    logic [DATA_WIDTH/8-1:0]    axi_mem_be;
    logic [DATA_WIDTH-1:0]      axi_mem_wdata;
    logic [DATA_WIDTH-1:0]      axi_mem_rdata;

    logic [DATA_WIDTH-1:0]      axi_mem_rdata_acc;

    // Bus to config reg
    logic                       cfg_en;
    logic [CFG_ADDR_BITS-1:0]   cfg_addr;
    logic                       cfg_we;
    logic [DATA_WIDTH/8-1:0]    cfg_be;
    logic [DATA_WIDTH-1:0]      cfg_wdata;
    logic [DATA_WIDTH-1:0]      cfg_rdata;
    logic                       addr_is_config, addr_is_config_reg;


    // Accelerator gets address 
    logic [INT_ADDR_WIDTH-1:0]  acc_addr;

    // Config and control signals
    logic [DATA_WIDTH-1:0]      control_vec [CTRL_WORDS];
    logic [DATA_WIDTH-1:0]      status_vec  [STAT_WORDS];

    // Accelerator state and error
    acc_state_t accel_state;
    acc_error_t accel_err;
    logic done_int;


    // Accelerator configuration
    logic       start_int;
    logic [5:0] output_length_d_byte;
    // logic [7:0] max_cnt_int;
    // logic [7:0] incr;


    //////////////////////////////////////////////////////////////////////////////////////
    // Configuration Register Multiplexing for start-bit clearing
    //////////////////////////////////////////////////////////////////////////////////////
    assign cfg_en           = !done_int ? (axi_mem_req && addr_is_config)   : CTRL_CLEAR_START.en;
    assign cfg_addr         = !done_int ? axi_mem_addr[CFG_ADDR_BITS-1:0]   : CTRL_CLEAR_START.addr; 
    assign cfg_we           = !done_int ? axi_mem_we                        : CTRL_CLEAR_START.we;
    assign cfg_be           = !done_int ? axi_mem_be                        : CTRL_CLEAR_START.be;
    assign cfg_wdata        = !done_int ? axi_mem_wdata                     : CTRL_CLEAR_START.wdata;

    assign done = done_int;

    // Read is always delayed one cycle, so also delay this multiplexer to not overwrite data
    // that is just about to be read
    assign axi_mem_rdata    = addr_is_config_reg ? cfg_rdata : axi_mem_rdata_acc;

    always_ff @(posedge clk)
    begin
        addr_is_config_reg <= addr_is_config;
    end

    // Distinguish between cfg and data
    assign addr_is_config   = (axi_mem_addr[INT_ADDR_WIDTH-1]) ? 1'b0 : 1'b1;


    //////////////////////////////////////////////////////////////////////////////////////
    // Configuration Register
    //////////////////////////////////////////////////////////////////////////////////////
    config_reg
    #(
        .ASYNC_READ     ( 0                 ),      // parameters
        .ADDR_WIDTH     ( CFG_ADDR_BITS     ),
        .DATA_WIDTH     ( DATA_WIDTH        ),
        .N_CTRL_WORDS   ( CTRL_WORDS        ),
        .N_STAT_WORDS   ( STAT_WORDS        ),
        .REGISTER_STATUS( 1'b1              )
    )
    config_reg_inst                                 // ports
    (
        .clk            ( clk           ),
        .arst_n         ( rst_n         ),

        .en             ( cfg_en        ),
        .addr           ( cfg_addr      ),
        .we             ( cfg_we        ),
        .be             ( cfg_be        ),
        .wdata          ( cfg_wdata     ),
        .rdata          ( cfg_rdata     ),

        .ctrl_vec       ( control_vec   ),
        .stat_vec       ( status_vec    ),
        .stat_en        ( 1'b1          )
    );


    //////////////////////////////////////////////////////////////////////////////////////
    // Config reg connections -  connect register to memory file
    //////////////////////////////////////////////////////////////////////////////////////
    assign status_vec[0][7:0]   = {accel_err, accel_state};
    assign start_int            = control_vec[0][0];            // bit 0 of word 0 is the start signal of type integer
    assign output_length_d_byte = control_vec[0][13:8];         // 6 bit, max 512 bit / 64 Byte hash length. 

    genvar i,j;
    generate
        for (i=1; i<STAT_WORDS; i++)
            for (j=0; j<DATA_WIDTH/8; j++)
                assign status_vec[i][8*j + 7 -:8] = j + DATA_WIDTH/8*i;
    endgenerate


    //////////////////////////////////////////////////////////////////////////////////////
    // AXI to memory bus conversion
    //////////////////////////////////////////////////////////////////////////////////////
    axi_mem_if_SP_wrap
    #(
      .AXI_ADDR_WIDTH  ( AXI_ADDR_WIDTH         ),
      .AXI_DATA_WIDTH  ( DATA_WIDTH             ),
      .AXI_ID_WIDTH    ( AXI_ID_WIDTH           ),
      .AXI_USER_WIDTH  ( AXI_USER_WIDTH         ),
      .MEM_ADDR_WIDTH  ( INT_ADDR_WIDTH         )
    )
    axi_mem_if
    (
        .clk         ( clk              ),
        .rst_n       ( rst_n            ),
        .test_en_i   ( testmode_i       ),

        .mem_req_o   ( axi_mem_req      ),
        .mem_addr_o  ( axi_mem_addr_tmp ),
        .mem_we_o    ( axi_mem_we       ),
        .mem_be_o    ( axi_mem_be       ),
        .mem_rdata_i ( axi_mem_rdata    ),
        .mem_wdata_o ( axi_mem_wdata    ),

        .slave       ( axi_slave        )
    );
    assign axi_mem_addr = {axi_mem_addr_tmp[INT_ADDR_WIDTH-ALIGN_BITS-1:0], {ALIGN_BITS{1'b0}}};


    //////////////////////////////////////////////////////////////////////////////////////
    // Accelerator
    //////////////////////////////////////////////////////////////////////////////////////
    accel_wrapper
    #(
        .MEM_ADDR_WIDTH ( $clog2(MEM_DEPTH) ),
        .MEM_DATA_WIDTH ( DATA_WIDTH        ),
        .MEM_DEPTH      ( MEM_DEPTH         )
    )
    accel_wrapper_inst
    (
        .clk            ( clk               ),
        .rst_n          ( rst_n             ),

        .accel_state    ( accel_state       ),
        .accel_error    ( accel_err         ),
        
        .start          ( start_int         ),
        .done           ( done_int          ),
        .output_length_byte (output_length_d_byte),
        // .max_cnt        ( max_cnt_int       ),
        // .incr           ( incr              ),

        .mem_en         ( axi_mem_en        ),
        .mem_addr       ( acc_addr          ),
        .mem_we         ( axi_mem_we        ),
        .mem_be         ( axi_mem_be        ),
        .mem_wdata      ( axi_mem_wdata     ),
        .mem_rdata      ( axi_mem_rdata_acc )
    );

    assign acc_addr     = axi_mem_addr[$clog2(MEM_DEPTH)+ALIGN_BITS-1:ALIGN_BITS];
    assign axi_mem_en   = axi_mem_req && !addr_is_config;



endmodule
