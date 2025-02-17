///////////////////////////////////////////////////////////////////////////////
// @file     tb_accel_wrapper.sv
// @brief    Testbench for the accelerator wrapper
// @author   Jan-Eric Schäfrich
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
logic [5:0]                     output_length_byte_r;

logic                           mem_en_s;
logic [MEM_ADDR_WIDTH-1:0]      mem_addr_s;
logic                           mem_we_s;
logic [MEM_DATA_WIDTH/8-1:0]    mem_be_s;
logic [MEM_DATA_WIDTH-1:0]      mem_wdata_s;
logic [MEM_DATA_WIDTH-1:0]      mem_rdata_s;

integer                         i = 0;
integer                         output_length_byte_s;

// reset & clock
initial begin 
    rst_n_s = 1'b0;
    #5
    rst_n_s = 1'b1;
    clk_s   = 1'b1;
end

always #5 clk_s = ~clk_s;       // period of 10 ns


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
    .output_length_byte (output_length_byte_r),
    .mem_en             (mem_en_s),
    .mem_addr           (mem_addr_s),
    .mem_we             (mem_we_s),
    .mem_wdata          (mem_wdata_s),
    .mem_be             (mem_be_s),
    .mem_rdata          (mem_rdata_s)
);

assign mem_be_s     = 4'hf;     // enable all bytes of a word

// stimuli  
// write
initial begin 
    start_s                 = 1'b0;
    mem_en_s                = 1'b1;
    mem_we_s                = 1'b1;
    output_length_byte_r    = 63;       // 512 bit / 8 bit/Byte
    output_length_byte_s    = output_length_byte_r + 1;   

    // initialize memory
    for (i = 0; i <= 42; i = i + 1) begin   // 42 x 32bit words
        @ (posedge clk_s)                   // wait on clock edge
        mem_addr_s = i;                     
        // input data 16 x 32 = 512 = max output length
        if (i < (output_length_byte_s/4))           mem_wdata_s = 32'hffff_ffff; 
        // padding
        else if (i == (output_length_byte_s/4))     mem_wdata_s = 32'h0000_001F;
        else if (i == 41)                           mem_wdata_s = 32'h8000_0000;
        else                                        mem_wdata_s = 32'h0000_0000;
    end
    
    if (i > 41)           start_s = 1'b1;

end

endmodule
