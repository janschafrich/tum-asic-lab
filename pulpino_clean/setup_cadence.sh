########################################
# Initial setup file for Cadence tools #
# Date 2022-10-11                      #
########################################

#Set language to C for Cadence
export LANG C

###################
# Licence section #
###################
export LM_LICENSE_FILE=5280@cadencelic.regent.e-technik.tu-muenchen.de:2100@xilinxlic.regent.e-technik.tu-muenchen.de:1717@mentorlic.regent.e-technik.tu-muenchen.de:1702@tueisec-licenses.sec.ei.tum.de:2300@licenses.lis.ei.tum.de:27000@licenses.lis.ei.tum.de


################################################
# Cadence tools                                #
################################################
export PATH="${PATH}:/nfs/tools/cadence/GENUS/GENUS_19.14.000-ISR4/bin"
alias genus='/nfs/tools/cadence/GENUS/GENUS_19.14.000-ISR4/bin/genus'
alias lec='/nfs/tools/cadence/CONFRML/CONFRML_19.10.300/bin/lec -nolicwait -ecogxl'

module load cadence/SSV/20.11
module load cadence/INNOVUS/20.11

# Setup Xcelium
module load cadence/XCELIUM/21.03.009

#setup quantus
module use /nas/ei/share/sec/tools/modulefiles
module load cadence/EXT/19.13

################################################
# Mentor tools                                 #
################################################
export MGLS_LICENSE_FILE=5280@cadencelic.regent.e-technik.tu-muenchen.de:2100@xilinxlic.regent.e-technik.tu-muenchen.de:1717@mentorlic.regent.e-technik.tu-muenchen.de:1702@tueisec-licenses.sec.ei.tum.de:2300@licenses.lis.ei.tum.de:27000@licenses.lis.ei.tum.de

module load mentor/calibre/2021.2_28.15
