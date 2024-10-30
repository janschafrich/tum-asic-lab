///////////////////////////////////////////////////////////////////////////////
// @file     cfg_types_pkg.sv
// @brief    Contains some configuration for the accelerator template
// @author   Patrick Karl <patrick.karl@tum.de>
// @license  TBD
///////////////////////////////////////////////////////////////////////////////

`ifndef CFG_TYPES_PKG_SV
`define CFG_TYPES_PKG_SV

package cfg_types_pkg;
    // Status encoding
    typedef enum logic [3:0] {  ST_IDLE    = 4'h0, 
                                ST_RUNNING = 4'h1   } acc_state_t;

    // Error encoding
    typedef enum logic [3:0] {  ER_OKAY         = 4'h0,
                                ER_INVALID_CFG  = 4'h1, 
                                ER_OTHERS       = 4'h2  } acc_error_t;
endpackage
`endif
