proc load_calibre {} {
global env
if {![info exists env(CALIBRE_HOME)] || $env(CALIBRE_HOME)==""} {
puts "Environment variable CALIBRE_HOME not set. Calibre 
interface NOT loaded."
return
}
set etclf [file join $env(CALIBRE_HOME) lib cal_enc.tcl]
if {![file readable $etclf]} {
puts "Could not find Calibre initialization files. Calibre interface
not loaded."
return
}
if {[catch {source $etclf} msg]} {
puts "ERROR while loading Calibre interface: $msg"
}
}
load_calibre
