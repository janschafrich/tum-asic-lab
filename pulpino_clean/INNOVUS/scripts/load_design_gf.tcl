### General settings
setDesignMode -process 130
puts "Skywater130 process"

### Library paths extracted to extra file, as they are needed by timing analysis
source ../scripts/library_paths.tcl

### Loading design
source ../scripts/Default_gf.globals
init_design
