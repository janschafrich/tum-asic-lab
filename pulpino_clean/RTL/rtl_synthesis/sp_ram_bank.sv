module sp_ram_bank(clk_i, rstn_i, en_i, addr_i, wdata_i, rdata_o, we_i, be_i);
    parameter NUM_BANKS = 1;
    parameter BANK_SIZE = 1;
    parameter DATA_WIDTH = 32;
    parameter ADDR_WIDTH = 16;

    input  logic clk_i;
    input  logic rstn_i;
    input  logic en_i;
    input  logic [ADDR_WIDTH-1:0] addr_i;
    input  logic [DATA_WIDTH-1:0] wdata_i;
    output  logic [DATA_WIDTH-1:0] rdata_o;
    input  logic we_i;
    input  logic [3:0] be_i;

    logic [DATA_WIDTH-1:0] rdata_o_int;
    logic [ADDR_WIDTH-1:0] addr_i_int;
    logic [ADDR_WIDTH-1:0] addr_i_int_top_fixed;

    assign rdata_o = rdata_o_int;
    assign addr_i_int = addr_i >> 2;
    assign addr_i_int_top_fixed = {1'b0, addr_i_int[10:0]};

    sky130_sram_8kbyte_1rw_32x2048_8 bank0(
        .clk0(clk_i),
	.csb0(~en_i),
	.web0(~we_i),
	.wmask0(be_i),
	.addr0(addr_i_int_top_fixed),
	.din0(wdata_i),
	.dout0(rdata_o_int)
    );
endmodule
