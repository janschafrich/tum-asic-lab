### Variables
# Margins
## Placement Margin for Macros
set MARGIN 30
## Halo Dimension X
set PLACEMENT_MARGIN 20
## Halo Dimension Y
set Y_PLACEMENT_MARGIN 11.52

# Power and routing layers (QA/QB supports widths between 1.2-35), we use QB and LB due to their vertical/horizontal orientation.
set PWR_LAYER_V met4
set PWR_LAYER_H met5
set PWR_LAYERS [list top $PWR_LAYER_H bottom $PWR_LAYER_H left $PWR_LAYER_V right $PWR_LAYER_V]
set PWR_WIDTH 16.5
set PWR_SPACING 1.6
set PWR_STRIPE_SPACING 16.5
set PWR_WIDTH_LIST [list top $PWR_WIDTH bottom $PWR_WIDTH left $PWR_WIDTH right $PWR_WIDTH]
set PWR_SPACING_LIST [list top $PWR_SPACING bottom $PWR_SPACING left $PWR_SPACING right $PWR_SPACING]


# Define layer ranges for power routing:
## Lowest possible metal layer to connect std.-cell and mem power pins
set ROUTING_BOTTOM_METAL met1
## Highest level M1 pins are allowed to connect to
set ROUTING_TOP_METAL met5

# Macro names and existance definitions
set CORE_LOGIC pulpino_top_inst_core_region_i
set SPRAM_INSTR pulpino_top_inst/core_region_i/instr_mem_sp_ram_wrap_i_sp_ram_bank_i_bank0
set SPRAM_DATA pulpino_top_inst/core_region_i/data_mem_sp_ram_bank_i_bank0
set DPRAM_ACCEL pulpino_top_inst/accelerator_i_accel_wrapper_inst_ram_inst_dp_ram_i

#########################
### Specify Floorplan ###
#########################
# die = core_box + io_box
# create a floorplan with a die box of size 2500x2500 and spacing between core_edge to die_edge of 240 around all sides
#                  die: width height, margins from io->die: Left Bottom Right Top
floorPlan -site unit -d 2499.84 2500.09 240 240.13 240 240.13 -coreMarginsBy die

### Place memory macros
#         1
#       -----
#    4  |   | 2
#       |   |
#       -----
#         3                                            ref_edge                          ref_edge vertical_offset obj_edge    ref_edge horz_offset obj_edge
create_relative_floorplan -place $SPRAM_DATA  -ref_type core_boundary -horizontal_edge_separate "1 0 1" -vertical_edge_separate "0 0 0" -orient R0
create_relative_floorplan -place $SPRAM_INSTR -ref_type core_boundary -horizontal_edge_separate "1 0 1" -vertical_edge_separate "2 0 2" -orient R0
#                                                                                               
create_relative_floorplan -place $DPRAM_ACCEL -ref_type core_boundary -horizontal_edge_separate "3 0 3" -vertical_edge_separate "2 0 2" -orient R0

snapFPlan -guide -block -stdCell -ioPad -pin -pinGuide -routeBlk -pinBlk -ptnCore -placeBlk -macroPin

### Add placement halo left bottom right top
addHaloToBlock 20 20 0 0 $SPRAM_INSTR
addHaloToBlock 0 20 20 0 $SPRAM_DATA
# what do the numberes mean? distance at four sides?
addHaloToBlock 0 20 20 0 $DPRAM_ACCEL

#################################
### Connect global power nets ###
#################################
clearGlobalNets
globalNetConnect VDD -type pgpin -pin VPWR -inst * -verbose -netlistOverride
globalNetConnect VSS -type pgpin -pin VGND -inst * -verbose -netlistOverride

globalNetConnect VDD -type tiehi -pin VPWR -inst * -override -verbose -netlistOverride
globalNetConnect VSS -type tielo -pin VGND -inst * -override -verbose -netlistOverride

### Memory global net connects:
globalNetConnect VSS -type pgpin -pin vssd1 -inst *  -verbose -netlistOverride
globalNetConnect VDD -type pgpin -pin vccd1 -inst *  -verbose -netlistOverride

# VDDC/VSSC (Connect here to avoid constraints with power rings routed above)
globalNetConnect VDD -type pgpin -pin VDDC -inst * -override -verbose -netlistOverride
globalNetConnect VSS -type pgpin -pin VSSC -inst * -override -verbose -netlistOverride

### Add IO filler cells
### No IO fillers in Skywater130 available yet

### Add power rings on met5 and met4 as these rings are source point for both power grids and all block rings
setAddRingMode -ring_target default -skip_crossing_trunks none -stacked_via_top_layer $ROUTING_TOP_METAL -stacked_via_bottom_layer $ROUTING_BOTTOM_METAL -orthogonal_only true -skip_via_on_pin {  standardcell } -skip_via_on_wire_shape {  noshape }
addRing -nets {VDD VSS} -type core_rings -follow core -layer $PWR_LAYERS -width $PWR_WIDTH -spacing $PWR_SPACING -offset $PWR_SPACING -center 0 -threshold 0 -jog_distance 0 -snap_wire_center_to_grid None

# Connect PWR-Pins to rings before rings are congested with connections to die objects
sroute -connect { padPin padRing } -layerChangeRange { met1 met5 } -blockPinTarget { nearestTarget } -padPinPortConnect { allPort oneGeom } -padPinTarget { nearestTarget } -corePinTarget { firstAfterRowEnd } -floatingStripeTarget { blockring padring ring stripe ringpin blockpin followpin } -allowJogging 1 -crossoverViaLayerRange { met1 met5 } -nets { VDD VSS } -allowLayerChange 1 -blockPin useLef -targetViaLayerRange { met1 met5 }

# Add PWR rings around memories to provide endpoints for std. cells pwr connections
selectInst $SPRAM_INSTR
addRing -nets {VDD VSS} -type block_rings -around selected -layer $PWR_LAYERS -width $PWR_WIDTH_LIST -spacing $PWR_SPACING_LIST -offset $PWR_SPACING_LIST -center 0 -skip_side {right top} -threshold 0 -jog_distance 0 -snap_wire_center_to_grid None -extend_corner {br lt}
deselectAll
selectInst $SPRAM_DATA
addRing -nets {VDD VSS} -type block_rings -around selected -layer $PWR_LAYERS -width $PWR_WIDTH_LIST -spacing $PWR_SPACING_LIST -offset $PWR_SPACING_LIST -center 0 -skip_side {left top} -threshold 0 -jog_distance 0 -snap_wire_center_to_grid None  -extend_corner {bl rt}
deselectAll

# Add power stripes above std. cells
setAddStripeMode -extend_to_first_ring true -ignore_block_check false -break_at none -route_over_rows_only false -rows_without_stripes_only false -extend_to_closest_target ring -stop_at_last_wire_for_area false -partial_set_thru_domain false -ignore_nondefault_domains false -trim_antenna_back_to_shape none -spacing_type edge_to_edge -spacing_from_block 0 -stripe_min_length stripe_width -stacked_via_top_layer $ROUTING_TOP_METAL -stacked_via_bottom_layer $ROUTING_BOTTOM_METAL -via_using_exact_crossover_size false -split_vias false -orthogonal_only true -allow_jog { padcore_ring  block_ring } -skip_via_on_pin {  standardcell } -skip_via_on_wire_shape {  noshape   }

addStripe -nets {VDD VSS} -layer $PWR_LAYER_V -direction vertical -width $PWR_WIDTH -spacing $PWR_SPACING -set_to_set_distance 60 -start_from left -start_offset 0 -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit $ROUTING_TOP_METAL -padcore_ring_bottom_layer_limit $ROUTING_BOTTOM_METAL -block_ring_top_layer_limit $ROUTING_TOP_METAL -block_ring_bottom_layer_limit $ROUTING_BOTTOM_METAL -use_wire_group 0 -snap_wire_center_to_grid None

#####################
### Special Route ###
#####################

# Route VDD VSS from M1 to C5, i.e. connect all macros and std. cell pins to the low level power grid)
setSrouteMode -viaConnectToShape { ring stripe blockring blockpin coverpin noshape blockwire corewire followpin iowire }
sroute -connect { blockPin corePin floatingStripe } -layerChangeRange { met1 met5 } -blockPinTarget { nearestTarget } -padPinPortConnect { allPort oneGeom } -padPinTarget { nearestTarget } -corePinTarget { firstAfterRowEnd } -floatingStripeTarget { blockring ring stripe ringpin blockpin followpin } -allowJogging 1 -crossoverViaLayerRange { met1 met5 } -nets { VDD VSS } -allowLayerChange 1 -blockPin useLef -targetViaLayerRange { met1 met5 }

# Check for errors
checkFPlan -outFile result.txt
