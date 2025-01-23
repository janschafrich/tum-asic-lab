setMultiCpuUsage -localCpu max
set init_design_uniquify 1

####################
##  LOAD DESIGN   ##
####################
source ../scripts/load_design_gf.tcl

setFillerMode -core { sky130_fd_sc_ls__fill_1 sky130_fd_sc_ls__fill_2 sky130_fd_sc_ls__fill_4 sky130_fd_sc_ls__fill_8 }
checkDesign -netlist

source ../scripts/floorplanning.tcl

####################
## Cell Placement ##
####################
dbSet [ dbGet -p top.insts.name $SPRAM_INSTR].pStatus FIXED
dbSet [ dbGet -p top.insts.name $SPRAM_DATA].pStatus FIXED
dbSet [ dbGet -p top.insts.name $DPRAM_ACCEL].pStatus FIXED

### Place standard cells
setOptMode -fixFanoutLoad true -setupTargetSlack 0.05 -holdTargetSlack 0.04
place_opt_design
checkPlace
refinePlace

####################
## Clock Tree Syn ##
####################
set_analysis_view  -setup {func_view_tc func_view_wc} -hold {func_view_tc func_view_bc}
setAnalysisMode -cppr both
# TASK: Define non-default routing rule 
# FOR TRUNK:
add_ndr -name CTS_2W2S -width_multiplier {met1:met5 2} -spacing_multiplier {met1:met5 2} -generate_via
add_ndr -name CTS_2W1S -width_multiplier {met1:met5 2} -generate_via
# create_route_type -non_default_rule CTS_2W2S -name 
# FOR LEAF:

# create a routing type for CTS
create_route_type -non_default_rule CTS_2W2S -name trunk_rule -top_preferred_layer met5 -bottom_preferred_layer met4 -shield_net VSS 
create_route_type -non_default_rule CTS_2W1S -name leaf_rule -top_preferred_layer met3 -bottom_preferred_layer met2
# apply properties to leaf and trunk type clock nets
set_ccopt_property -net_type leaf route_type leaf_rule
set_ccopt_property -net_type trunk route_type trunk_rule

create_ccopt_clock_tree_spec
ccopt_design

### Optimize after CTS
optDesign -postCTS -drv
optDesign -postCTS -setup -hold

checkPlace
refinePlace
checkPlace
checkFiller
addFiller -prefix FILLER

## checkpoint 16.01.2025



####################
##    Routing     ##
####################
setNanoRouteMode -drouteFixAntenna true
setNanoRouteMode -routeInsertAntennaDiode false
setNanoRouteMode -routeWithSiDriven true -routeWithTimingDriven true
setDesignMode -topRoutingLayer met5
setNanoRouteMode -quiet -routeBottomRoutingLayer default
routeDesign -globalDetail

### Optimize after routing
setAnalysisMode -analysisType onChipVariation -cppr both
setOptMode -fixCap true -fixTran true -fixFanoutLoad true
optDesign -postRoute -setup -hold
verify_drc
optDesign -postRoute -drv

checkPlace
refinePlace

### Timing analysis post-routing
setAnalysisMode -checkType hold
report_timing -check_type hold
setAnalysisMode -checkType setup
report_timing -check_type setup

### Fix antenna violations
verifyProcessAntenna -error 10000
routeDesign -globalDetail

####################
##  Post-Process. ##
####################
for {set i 0} {$i < 3} {incr i} {
    checkPlace
	checkFiller
	verify_drc
	addFiller -fixDRC
	ecoRoute -target
}

####################
## Verify/Report  ##
####################
### Verify design
verify_drc -report ../reports/drc.rpt
verifyConnectivity -report ../reports/connectivity.rpt
verifyProcessAntenna -report ../reports/antenna.rpt
verifyACLimit -report ../reports/aclimit.rpt -detailed -toggle 1.0
verify_PG_short
checkFiller

## checkpoint 21.01.

### Write output and reports
reportGateCount -outfile ../reports/gatecount.rpt
check_timing -verbose > ../reports/timing_check.rpt
report_timing > ../reports/timing.rpt

saveNetlist -excludeLeafCell ../outputs/netlist_sim.v
write_sdf -min_view func_view_bc -typ_view func_view_tc -max_view func_view_wc -recompute_parallel_arcs ../outputs/final.sdf
defOut ../outputs/final.def.gz

### Generate GDSII
# streamOut ../outputs/pulpino_clean.gds -mapFile $GDS_MAP -libName DesignLib -merge $GDS_FILES -uniquifyCellNames -units 1000 -mode ALL -outputMacros
suspend
