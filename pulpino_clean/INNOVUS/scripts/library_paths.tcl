### Library Paths

# Parameters for util.tcl
set INNOVUS_SAVE_DESIGN_EXPORT_DIR "../outputs/saved_designs"

# Load util.tcl residing in the same directory as library_paths_gf.tcl
source [file join [file dirname [info script]] "../../INNOVUS/scripts/util.tcl"]

# Directories backend / frontend
set SKY130_DIR /nas/ei/share/pdks/skywater/skywater130/skywater-pdk/libraries

# Select Standard Cells to include. 1 means include, 0 means do not include
set USE_STDCELLS_SC_HS		0
set USE_STDCELLS_SC_MS		0
set USE_STDCELLS_SC_LS		1
set USE_STDCELLS_SC_LP		0
set USE_STDCELLS_SC_HVL		0
set USE_STDCELLS_SC_HD		0
set USE_STDCELLS_SC_HDLL	0
set USE_STDCELLS_IO		1
set USE_STDCELLS_PR		0
set USE_STDCELLS_PR_RERAM	0
set USE_MEM_8K			1
set USE_MEM_8K_2RW		1

# Comments on abbreviations/cell names:
# HS: High Speed, Placement Compatible with MS, LS, LP, i.e. can be used concurrently
# MS: Medium Speed, Placement Compatible with HS, LS, LP, i.e. can be used concurrently
# LS: Low Speed, Placement Compatible with HS, MS, LP, i.e. can be used concurrently
# LP: Low Power, yet to be implemented, Placement Compatible with HS, MS, LS, i.e. can be used concurrently
# HVL: High voltage, yet to be implemented larger, placement not compatible
# HD: High Density, yet to be implemented, smaller
# HDLL: High Density Low Leakage, yet to be implemented
# IO: IO Cells
# PR: Cell Primitives, yet to be implemented (i.e. single transistors etc.)primarily for analog flow
# PR_RERAM: As above, but RERAM tec.

# Comment on activation:
# Currently only HS, MS, LS are supported, i.e. at least one of those *must* be active
# IO must be active, too

# Directories logic cells
set STDCELLS_DIR_SC_HS		${SKY130_DIR}/sky130_fd_sc_hs/latest
set STDCELLS_DIR_SC_MS		${SKY130_DIR}/sky130_fd_sc_ms/latest
set STDCELLS_DIR_SC_LS		${SKY130_DIR}/sky130_fd_sc_ls/latest
set STDCELLS_DIR_SC_LP		${SKY130_DIR}/sky130_fd_sc_lp/latest
set STDCELLS_DIR_SC_HVL		${SKY130_DIR}/sky130_fd_sc_hvl/latest
set STDCELLS_DIR_SC_HD		${SKY130_DIR}/sky130_fd_sc_hd/latest
set STDCELLS_DIR_SC_HDLL	${SKY130_DIR}/sky130_fd_sc_hdll/latest
set STDCELLS_DIR_IO		${SKY130_DIR}/sky130_fd_io/latest
set STDCELLS_DIR_PR		${SKY130_DIR}/sky130_fd_pr/latest
set STDCELLS_DIR_PR_RERAM	${SKY130_DIR}/sky130_fd_pr_reram/latest
set DIR_MEM_8K			/nas/ei/share/pdks/skywater/skywater130/sky130_sram_8kbyte_1rw_32x2048_8_1spare
set DIR_MEM_8K_2RW		/nas/ei/share/pdks/skywater/skywater130/sky130_sram_8kbyte_2rw_32x2048_8

# LEF Files
set TECH_LEF     ${SKY130_DIR}/sky130_fd_sc_ls/latest/tech/sky130_fd_sc_ls.tlef
append LEF_FILES ${TECH_LEF} " "

######################################################################################################################################################
# Standard Cells                                                                                                                                     #
######################################################################################################################################################

if { $USE_STDCELLS_SC_LS == 1} {
    puts "USE_STDCELLS_SC_LS defined -> Including STDCELL Library LS (Low Speed)"
    # -> Typical Case
    add_timing_file_tc STDCELLS_SC_LS ${STDCELLS_DIR_SC_LS}/timing/sky130_fd_sc_ls__tt_025C_1v80.lib
    add_timing_file_tc STDCELLS_SC_LS ${STDCELLS_DIR_SC_LS}/timing/sky130_fd_sc_ls__tt_025C_1v80_ccsnoise.lib   CCS_LIB
    # -> Best Case
    add_timing_file_bc STDCELLS_SC_LS ${STDCELLS_DIR_SC_LS}/timing/sky130_fd_sc_ls__ff_n40C_1v95.lib
    add_timing_file_bc STDCELLS_SC_LS ${STDCELLS_DIR_SC_LS}/timing/sky130_fd_sc_ls__ff_n40C_1v95_ccsnoise.lib   CCS_LIB
    # -> Worst Case
    add_timing_file_wc STDCELLS_SC_LS ${STDCELLS_DIR_SC_LS}/timing/sky130_fd_sc_ls__ss_n40C_1v60.lib
    add_timing_file_wc STDCELLS_SC_LS ${STDCELLS_DIR_SC_LS}/timing/sky130_fd_sc_ls__ss_n40C_1v60_ccsnoise.lib   CCS_LIB
    
    # Add LEF files from all cell subdirs
    set LEF_STDCELLS_SC_LS [collect_all_files_of_type ${STDCELLS_DIR_SC_LS}/cells *.lef *magic*]
    append LEF_FILES            ${LEF_STDCELLS_SC_LS} " "
    
    # Add GDS files from all cell subdirs
    set GDS_STDCELLS_SC_LS [collect_all_files_of_type ${STDCELLS_DIR_SC_LS}/cells *.gds]
    append GDS_FILES            ${GDS_STDCELLS_SC_LS} " "
}

if { $USE_STDCELLS_SC_MS == 1} {
    puts "USE_STDCELLS_SC_MS defined -> Including STDCELL Library MS (Medium Speed)"
    # -> Typical Case
    add_timing_file_tc STDCELLS_SC_MS ${STDCELLS_DIR_SC_MS}/timing/sky130_fd_sc_ms__tt_025C_1v80.lib
    add_timing_file_tc STDCELLS_SC_MS ${STDCELLS_DIR_SC_MS}/timing/sky130_fd_sc_ms__tt_025C_1v80_ccsnoise.lib   CCS_LIB
    # -> Best Case
    add_timing_file_bc STDCELLS_SC_MS ${STDCELLS_DIR_SC_MS}/timing/sky130_fd_sc_ms__ff_n40C_1v95.lib
    add_timing_file_bc STDCELLS_SC_MS ${STDCELLS_DIR_SC_MS}/timing/sky130_fd_sc_ms__ff_n40C_1v95_ccsnoise.lib   CCS_LIB
    # -> Worst Case
    add_timing_file_wc STDCELLS_SC_MS ${STDCELLS_DIR_SC_MS}/timing/sky130_fd_sc_ms__ss_n40C_1v60.lib
    add_timing_file_wc STDCELLS_SC_MS ${STDCELLS_DIR_SC_MS}/timing/sky130_fd_sc_ms__ss_n40C_1v60_ccsnoise.lib   CCS_LIB
    
    # Add LEF files from all cell subdirs
    set LEF_STDCELLS_SC_MS [collect_all_files_of_type ${STDCELLS_DIR_SC_MS}/cells *.lef *magic*]
    append LEF_FILES            ${LEF_STDCELLS_SC_MS} " "
    
    # Add GDS files from all cell subdirs
    set GDS_STDCELLS_SC_MS [collect_all_files_of_type ${STDCELLS_DIR_SC_MS}/cells *.gds]
    append GDS_FILES            ${GDS_STDCELLS_SC_MS} " "
}

if { $USE_STDCELLS_SC_HS == 1} {
    puts "USE_STDCELLS_SC_MS defined -> Including STDCELL Library MS (Medium Speed)"
    # -> Typical Case
    add_timing_file_tc STDCELLS_SC_HS ${STDCELLS_DIR_SC_HS}/timing/sky130_fd_sc_hs__tt_025C_1v80.lib
    add_timing_file_tc STDCELLS_SC_HS ${STDCELLS_DIR_SC_HS}/timing/sky130_fd_sc_hs__tt_025C_1v80_ccsnoise.lib   CCS_LIB
    # -> Best Case
    add_timing_file_bc STDCELLS_SC_HS ${STDCELLS_DIR_SC_HS}/timing/sky130_fd_sc_hs__ff_n40C_1v95.lib
    add_timing_file_bc STDCELLS_SC_HS ${STDCELLS_DIR_SC_HS}/timing/sky130_fd_sc_hs__ff_n40C_1v95_ccsnoise.lib   CCS_LIB
    # -> Worst Case
    add_timing_file_wc STDCELLS_SC_HS ${STDCELLS_DIR_SC_HS}/timing/sky130_fd_sc_hs__ss_n40C_1v60.lib
    add_timing_file_wc STDCELLS_SC_HS ${STDCELLS_DIR_SC_HS}/timing/sky130_fd_sc_hs__ss_n40C_1v60_ccsnoise.lib   CCS_LIB
    
    # Add LEF files from all cell subdirs
    set LEF_STDCELLS_SC_HS [collect_all_files_of_type ${STDCELLS_DIR_SC_HS}/cells *.lef *magic*]
    append LEF_FILES            ${LEF_STDCELLS_SC_HS} " "
    
    # Add GDS files from all cell subdirs
    set GDS_STDCELLS_SC_HS [collect_all_files_of_type ${STDCELLS_DIR_SC_HS}/cells *.gds]
    append GDS_FILES            ${GDS_STDCELLS_SC_HS} " "
}

######################################################################################################################################################
# I/O Cells                                                                                                                                          #
######################################################################################################################################################
if { $USE_STDCELLS_IO == 1} {
    puts "USE_STDCELLS_IO defined -> Including IO cells"
    # Add LEF files from all cell subdirs
    set LEF_IOCELLS  [ collect_all_files_of_type ${STDCELLS_DIR_IO}/cells *.lef *magic*]
    append LEF_FILES ${LEF_IOCELLS} " "
    
    # Add GDS files from all cell subdirs
    set GDS_STDCELLS_IO [collect_all_files_of_type ${STDCELLS_DIR_IO}/cells *.gds]
    append GDS_FILES            ${GDS_STDCELLS_IO} " "
}

######################################################################################################################################################
# MEMCELL 8K 1RW (DATA + INSTR)                                                                                                                          #
######################################################################################################################################################
if { $USE_MEM_8K == 1} {
    puts "USE_MEM_8K defined -> Including Macro for 8K SRAM memory"
    # -> Typical Case
    add_timing_file_tc MEM_8K ${DIR_MEM_8K}/sky130_sram_8kbyte_1rw_32x2048_8_TT_1p8V_25C.lib
    add_timing_file_bc MEM_8K ${DIR_MEM_8K}/sky130_sram_8kbyte_1rw_32x2048_8_TT_1p8V_25C.lib
    add_timing_file_wc MEM_8K ${DIR_MEM_8K}/sky130_sram_8kbyte_1rw_32x2048_8_TT_1p8V_25C.lib

    set LEF_MEM_8K ${DIR_MEM_8K}/sky130_sram_8kbyte_1rw_32x2048_8.lef
    append LEF_FILES		${LEF_MEM_8K} " "

    set GDS_MEM_8K ${DIR_MEM_8K}/sky130_sram_8kbyte_1rw_32x2048_8.gds
    append GDS_FILES		${GDS_MEM_8K} " "
}

######################################################################################################################################################
# MEMCELL 8K 2RW (DATA + INSTR)                                                                                                                          #
######################################################################################################################################################
if { $USE_MEM_8K_2RW == 1} {
    puts "USE_MEM_8K_2RW defined -> Including Macro for 8K SRAM memory with two ports"
    # -> Typical Case
    add_timing_file_tc MEM_8K_2RW ${DIR_MEM_8K_2RW}/sky130_sram_8kbyte_2rw_32x2048_8_TT_1p8V_25C.lib
    add_timing_file_bc MEM_8K_2RW ${DIR_MEM_8K_2RW}/sky130_sram_8kbyte_2rw_32x2048_8_TT_1p8V_25C.lib
    add_timing_file_wc MEM_8K_2RW ${DIR_MEM_8K_2RW}/sky130_sram_8kbyte_2rw_32x2048_8_TT_1p8V_25C.lib

    set LEF_MEM_8K_2RW ${DIR_MEM_8K_2RW}/sky130_sram_8kbyte_2rw_32x2048_8.lef
    append LEF_FILES		${LEF_MEM_8K_2RW} " "

    set GDS_MEM_8K_2RW ${DIR_MEM_8K_2RW}/sky130_sram_8kbyte_2rw_32x2048_8.gds
    append GDS_FILES		${GDS_MEM_8K_2RW} " "
}

if {[ info exists USE_STDCELLS_CSC28SL ]} {
######################################################################################################################################################

# GDS files
# Maybe use colored version?
set GDS_MAP ${GF22BE_DIR}/PlaceRoute/Innovus/Techfiles/${GF22_METAL_STACK}/22FDSOI_${GF22_METAL_STACK}_edi2gds_colored.layermap

append GDS_FILES "${GF22FE_DIR}/v-io_in_3p3v_ae_gpio_fs/IN22FDX_GPIO33_10M19S40PI_BE_RELV03R00SZ/gds/IN22FDX_GPIO33_10M19S40PI.gds" " "
append GDS_FILES "${MEMCELL_SPMAIN_DIR}/gds/IN22FDX_S1D_NFRG_W16384B032M16C256.gds"    " "

append GDS_FILES "${MEMCELL_SPNTT_DIR}/gds/IN22FDX_S1D_NFRG_W04096B039M08C256.gds"     " "
append GDS_FILES "${MEMCELL_DPNTT_DIR}/gds/IN22FDX_SDPV_NFVG_W04096B039M08C128.gds"    " "
append GDS_FILES "${MEMCELL_SPSIKE_DIR}/gds/IN22FDX_S1D_NFRG_W01040B192M04C256.gds"    " "
append GDS_FILES "${MEMCELL_DPSIKE_DIR}/gds/IN22FDX_SDPV_NFVG_W01024B080M04C128.gds"   " "

append GDS_FILES "${MEMCELL_ROHQC_DIR}/gds/IN22FDX_ROMI_FRG_W05120B032M16C064.gds"     " "
append GDS_FILES "${MEMCELL_W320HQC_DIR}/gds/IN22FDX_S1D_NFRG_W00320B064M04C128.gds"   " "
append GDS_FILES "${MEMCELL_W560HQC_DIR}/gds/IN22FDX_S1D_NFRG_W00560B064M04C128.gds"   " "
append GDS_FILES "${MEMCELL_W8192HQC_DIR}/gds/IN22FDX_S1D_NFRG_W08192B032M08C256.gds"  " "
append GDS_FILES "${MEMCELL_W16384HQC_DIR}/gds/IN22FDX_S1D_NFRG_W16384B032M08C256.gds" " "

append GDS_FILES "${FLLCELL_DIR}/GDS/gf22_FLL.flat.gds" " "
}

# Constraints files
set CONSTRAINTS_TC ../constraints/constraints.sdc
