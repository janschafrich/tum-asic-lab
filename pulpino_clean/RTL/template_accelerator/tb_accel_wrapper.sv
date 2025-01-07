///////////////////////////////////////////////////////////////////////////////
// @file     tb_accelerator_template.sv
// @brief    Testbench for the accelerator template
// @author   Jan-Eric Schäfrich <patrick.karl@tum.de>
// @license  TBD
///////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ns

module tb_accel_wrapper ();

localparam MEM_ADDR_WIDTH = 32;
localparam MEM_DATA_WIDTH = 32;
localparam MEM_DEPTH = 16;          // 16 32-bit words = 512 bit


logic                           rst_n_s;
logic                           clk_s;
acc_state_t                     accel_state_s;          
acc_error_t                     accel_error_s;

logic                           start_s;
logic                           done_s;
logic [5:0]                     output_length_byte_s;

logic                           mem_en_s;
logic [MEM_ADDR_WIDTH-1:0]      mem_addr_s;
logic                           mem_we_s;
logic [MEM_DATA_WIDTH/8-1:0]    mem_be_s;
logic [MEM_DATA_WIDTH-1:0]      mem_wdata_s;
logic [MEM_DATA_WIDTH-1:0]      mem_rdata_s;

integer                         i = 0;



/// reset & clock
initial begin 
    rst_n_s = 1'b0;
    #5
    rst_n_s = 1'b1;
    clk_s   = 1'b1;
end

always #5 clk_s = ~clk_s;


// DUT
accel_wrapper
#(
    .MEM_ADDR_WIDTH     (MEM_ADDR_WIDTH),
    .MEM_DATA_WIDTH     (MEM_DATA_WIDTH),
    .MEM_DEPTH          (MEM_DEPTH)
) 
accel_wrapper_inst
(
    .clk                (clk_s),
    .rst_n              (rst_n_s),
    .accel_state        (accel_state_s),
    .accel_error        (accel_error_s),
    .start              (start_s),
    .done               (done_s),
    .output_length_byte (output_length_byte_s),
    .mem_en             (mem_en_s),
    .mem_addr           (mem_addr_s),
    .mem_we             (mem_we_s),
    .mem_wdata          (mem_wdata_s),
    .mem_be             (mem_be_s),
    .mem_rdata          (mem_rdata_s)
);

assign mem_be_s     = 4'hf;


// stimuli  
// write
initial begin 
    start_s         = 1'b0;
    mem_en_s        = 1'b1;
    mem_we_s        = 1'b1;

    for (i = 0; i <= 168; i = i + 4) begin
        @ (posedge clk_s)
        mem_addr_s = i / 4;
        if (i == 0)         mem_wdata_s = 32'h5555_5555;
        else if (i == 4)    mem_wdata_s = 32'h8000_0000;   
        else if (i == 164)  mem_wdata_s = 32'h0000_0001;
        else                mem_wdata_s = 32'h0000_0000;
    end
    if (i > 168)           start_s = 1'b1;

end


// read
// always @ (posedge done_s)
// begin
//     if (done_s)
//     begin


//         mem_en_s        = 1'b1;
//         mem_addr_s      = 0;
//         mem_we_s        = 1'b0;
//     // mem_rdata
//     end

// end


endmodule
