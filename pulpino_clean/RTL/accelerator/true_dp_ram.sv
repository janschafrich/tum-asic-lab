// Copyright 2017 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the “License”); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an “AS IS” BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

// Changes made by Patrick Karl <patrick.karl@tum.de
// Chair of Security in Information Technology
// Department of Electrical and Computer Engineering
// Technical University of Munich (TUM), Germany
//
`include "config.sv"

module true_dp_ram
  #(
    parameter ADDR_WIDTH    = 10,
    parameter DATA_WIDTH    = 32,
    parameter DEPTH         = 1024
  )(
    // Clock and Reset
    input  logic                        clk_a_i,
    input  logic                        en_a_i,
    input  logic [ADDR_WIDTH-1:0]       addr_a_i,
    input  logic [DATA_WIDTH-1:0]       wdata_a_i,
    output logic [DATA_WIDTH-1:0]       rdata_a_o,
    input  logic                        we_a_i,
    input  logic [DATA_WIDTH/8-1:0]     be_a_i,

    input  logic                        clk_b_i,
    input  logic                        en_b_i,
    input  logic [ADDR_WIDTH-1:0]       addr_b_i,
    input  logic [DATA_WIDTH-1:0]       wdata_b_i,
    output logic [DATA_WIDTH-1:0]       rdata_b_o,
    input  logic                        we_b_i,
    input  logic [DATA_WIDTH/8-1:0]     be_b_i
  );

    `ifdef ASIC
        sky130_sram_8kbyte_2rw_32x2048_8 dp_ram_i (
            // Port 0: RW
            .clk0(clk_a_i),
            .csb0(!en_a_i),
            .web0(!we_a_i),
            .wmask0(be_a_i),
            .addr0(addr_a_i),
            .din0(wdata_a_i),
            .dout0(rdata_a_o),
            // Port 1: RW
            .clk1(clk_b_i),
            .csb1(!en_b_i),
            .web1(!we_b_i),
            .wmask1(be_b_i),
            .addr1(addr_b_i),
            .din1(wdata_b_i),
            .dout1(rdata_b_o)
        );
    `else

        logic [DATA_WIDTH-1:0] mem[DEPTH];

        always @(posedge clk_a_i)
        begin
            if (en_a_i) begin
                if (we_a_i)
                    for (int i=0; i<DATA_WIDTH/8; i++)
                        if (be_a_i[i])
                            mem[addr_a_i][8*i + 7 -:8] <= wdata_a_i[8*i + 7 -:8];
                rdata_a_o <= mem[addr_a_i];
            end
        end

        always @(posedge clk_b_i)
        begin
            if (en_b_i) begin
                if (we_b_i)
                    for (int i=0; i<DATA_WIDTH/8; i++)
                        if (be_b_i[i])
                            mem[addr_b_i][8*i +7 -:8] <= wdata_b_i[8*i + 7 -:8];
                rdata_b_o <= mem[addr_b_i];
            end
        end

    `endif

endmodule
