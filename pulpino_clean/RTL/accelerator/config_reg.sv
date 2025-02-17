///////////////////////////////////////////////////////////////////////////////
// @file     config_reg.sv
// @brief    Simple configuration register for control and status data
// @author   Patrick Karl <patrick.karl@tum.de>
// @license  TBD
///////////////////////////////////////////////////////////////////////////////

module config_reg
#(
    parameter ASYNC_READ        = 0,
    parameter ADDR_WIDTH        = 32,
    parameter DATA_WIDTH        = 32,
    parameter N_CTRL_WORDS      = 4,        // at least one - written to by CPU
    parameter N_STAT_WORDS      = 4,        // at least one - read by CPU
    parameter REGISTER_STATUS   = 0
)(
    // Clock and Reset
    input   logic                       clk,
    input   logic                       arst_n,

    output  logic [DATA_WIDTH-1:0]      ctrl_vec [N_CTRL_WORDS],

    input   logic [DATA_WIDTH-1:0]      stat_vec [N_STAT_WORDS],
    input   logic                       stat_en,

    input   logic                       en,
    input   logic [ADDR_WIDTH-1:0]      addr,
    input   logic                       we,
    input   logic [DATA_WIDTH/8-1:0]    be,
    input   logic [DATA_WIDTH-1:0]      wdata,
    output  logic [DATA_WIDTH-1:0]      rdata
);

    logic [DATA_WIDTH-1:0]              ctrl_reg [N_CTRL_WORDS];
    logic [DATA_WIDTH-1:0]              stat_readout [N_STAT_WORDS];

    logic is_config;
    logic is_status;

    assign is_config = (addr < N_CTRL_WORDS) ? 1'b1 : 1'b0;
    assign is_status = (addr >= N_CTRL_WORDS && addr < N_CTRL_WORDS+N_STAT_WORDS) ? 1'b1 : 1'b0;

    ////////////////////////////////////////////////////////////////////
    // Control register
    ////////////////////////////////////////////////////////////////////
    if (N_CTRL_WORDS > 0) begin

        always_ff @(posedge clk, negedge arst_n)
        begin
            if (!arst_n)
                ctrl_reg <= '{default:'0};
            else begin
                if (en && we && is_config) begin
                    for (int i=0; i<DATA_WIDTH/8; i++) begin
                        if (be[i] == 1'b1) ctrl_reg[addr][8*i+7 -:8] <= wdata[8*i+7 -:8];
                    end 
                end 
            end 
        end
        assign ctrl_vec = ctrl_reg;
    end


    ////////////////////////////////////////////////////////////////////
    // Optionally register status
    ////////////////////////////////////////////////////////////////////
    if (N_STAT_WORDS > 0) begin
        if (REGISTER_STATUS) begin

            always_ff @(posedge clk)
            begin
                if (stat_en) stat_readout <= stat_vec;
            end

        end else begin

            assign stat_readout = stat_vec;

        end
    end


    ////////////////////////////////////////////////////////////////////
    // Data read out
    ////////////////////////////////////////////////////////////////////
    if (ASYNC_READ) begin

        // Output asynchronously.
        always_comb 
        begin
            rdata = '0;
            if (en && !we) begin
                if (is_status)
                    rdata = stat_readout[addr-N_CTRL_WORDS];
                else if (is_config)
                    rdata = ctrl_reg[addr];
            end
        end

    end else begin

        // Registered output slice of status / control vector.
        always_ff @(posedge clk, negedge arst_n)
        begin
            if (!arst_n) begin
                rdata <= '0;
            end else if (en && !we) begin
                if (is_status)
                    rdata <= stat_readout[addr-N_CTRL_WORDS];
                else if (is_config)
                    rdata <= ctrl_reg[addr];
            end
        end

    end

endmodule

