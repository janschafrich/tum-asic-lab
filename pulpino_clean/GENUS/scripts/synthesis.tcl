####################
# GENERIC SETTINGS #
####################
set root_path       ../..
set constr_path     ../constraints
set innovus_path    $root_path/INNOVUS

set RTL         $root_path/RTL
set IPS         $RTL/ips

# set some generics parameters
set_db hdl_verilog_defines "SYNTHESIS Skywater130"
set_db max_cpus_per_server 2
set_db super_thread_servers {localhost}
set_db information_level 9
#set_db hdl_parameter_naming_style ""

####################
# LIBRARY PATHS
####################
source $innovus_path/scripts/library_paths.tcl


####################
# READ LIBS + LEFS #
####################
read_lib ${LIB_FILES_TC}
set_db lef_library ${LEF_FILES}


#############
# READ RTL  #
#############
# read main files
source $root_path/src_files.tcl
set_db init_hdl_search_path $INCLUDES
read_hdl -mixvlog $SOURCES
read_hdl -vhdl $SOURCES_VHDL_UART



# read ASIC synthesis specific files
# read_hdl -sv $RTL/rtl_synthesis/pulpino_top_pad.sv
read_hdl -sv $RTL/rtl_synthesis/sp_ram_bank.sv


#############
# ELABORATE #
#############
# check the design structure
elaborate pulpino_top

# check if everything is fine
check_design -unresolved

# read constraints file
read_sdc $constr_path/constraints.sdc


#############
# SYNTHESIS #
#############

syn_gen

syn_map

syn_opt


#################
# WRITE RESULTS #
#################
report timing > ../reports/timing.rpt
report_area -detail > ../reports/area.rpt

write_hdl > ../outputs/netlist.v
write_sdc > ../outputs/constraints.sdc
write_sdf > ../outputs/delays.sdf
