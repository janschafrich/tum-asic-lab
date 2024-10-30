################################################################################
# util.tcl                                                                     #
#                                                                              #
# Utility functions to load timing libraries                                   #
# Tm                                                                           #
################################################################################

# Searchs subdirs (one level) and adds all files with the given pattern exluding all files with the exclude pattern
proc collect_all_files_of_type { basepath {filetype ""} {exclude_pattern ""} } {
   # Init empty list for resulting files
   set result_list ""
   # Iterate over all subdirs in current main dir
   foreach dir [glob -directory $basepath -type d * ] {
       # Get all matching files from current subdir
       set raw_filelist [glob -directory $dir -type f -nocomplain $filetype]
       # Remove elements with exclude_pattern
       set cleaned_list [lsearch -inline -all -not $raw_filelist $exclude_pattern]
       # Append all elements from cleaned_list to result_list
       lappend result_list {*}$cleaned_list
   }
   return $result_list
}

# Takes a path and shortens it to a specified length to align log files
proc util_shorten_path { filepath {maxlen 90} {ratio 0.25} } {
    set    f    [ file tail    $filepath ]
    append p    [ file dirname $filepath ] "/"
    set    plen [ string length $p ]

    # Check whether the path needs to be shorted anyway
    if { [ string length "${filepath}" ] <= $maxlen } {
        return "${filepath}"
    }

    # If yes, check if the file name alone is larger than the specified max length
    # If not, print only the file name and indicate that it had been shorted
    # We do handle the corner case that the string length is just a bit over
    # the edge of needing to be shorted and thus gets longer, as <//> is inserted

    set avlen [ expr $maxlen - [ string length $f ] ]
    if { $avlen < 2 } {
        return "${f}"
    }

    # Most often the subdirectories to the right are more interesting, so we
    # define a ratio that determines how many percent are taken from the left
    # and how many from the right. The llen value is bounded to at least one.
    set llen [ expr max(int(floor($avlen * $ratio)), 1) ]
    set rlen [ expr $avlen - $llen              ]
    set li   [ expr $llen - 1          ]
    set ri   [ expr $plen - $rlen  ]

    set pleft  [ string range "$p" 0   $li   ]
    set pright [ string range "$p" $ri $plen ]

    return "${pleft}<//>${pright}${f}"
}

proc add_timing_file { corner aggregate_suffix basename file_path {filetype -1} } {
    # This is a internal util proc.
    # Do not call this method directly, as this inserts variables into stackframe 1 level *above* the caller.
    # Please use one of add_timing_file_tc, add_timing_file_bc, add_timing_file_wc instead.

    set corner [string toupper $corner]

    # Check whether the file actually exists, otherwise throw an error
    # Use the given construct to also catch symbolic links pointing to nowhere
    if { [ expr {![catch {file lstat $file_path finfo}]} ] == 0 } {
        return -code error "Error while including timing file \"$file_path\" - File does not exist"
    }

    # Perform auto detection of file type if not specified explicitely (as e.g. required for CCS)
    if { $filetype == -1 } {
        regsub -nocase {^\.} [file extension $file_path] "" filetype
        set filetype [ string toupper $filetype ]

        # If the file is zipped, use the second to last extension
        if { "${filetype}" == "GZ" } {
            regsub -nocase {^\.} [file extension [file rootname $file_path ]] "" filetype
            set filetype [ string toupper $filetype ]
        }
    }

    set filetype [ string toupper $filetype ]
    set gname    "${filetype}${aggregate_suffix}"

    # Verify proper handling for the specified filetype is implemented
    switch -exact $filetype {
        "AOCV" -
        "DB"   -
        "LIB"  {
            set idvar ${filetype}_${basename}_${corner}
        }

        "CCS_LIB" {
            set idvar "LIB_CCS_${basename}_${corner}"
        }

        "CCS_DB" {
            set idvar "DB_CCS_${basename}_${corner}"
        }

        default {
            return -code error "Error while including timing file \"$file_path\" - Supplied file type \"${filetype}\" is not implemented"
        }
    }

    upvar 2 $idvar local_id
    upvar 2 $gname aggvar

    # Check if the variable exists already. In this case throw an error
    if { [info exists local_id] } {
        return -code error "Error while including timing file \"$file_path\" - Attempting to dynamically create variable ${idvar},
                            however it already exists. Maybe you try to include a lib and ccs lib without specifying a ccs parameter for the latter?"
    }
    set local_id ${file_path}

    # Pick one, either directly insert the path into aggvar or the variable names
    # append aggvar   "\${${idvar}} "
    append aggvar   "${file_path} "

    puts "Include file [ util_shorten_path ${file_path} ] as [ format %-28s ${idvar} ] | type [ format %-7s ${filetype} ] | grouped in ${gname}"
}

proc add_timing_file_tc { basename file_path {filetype -1} } {
    add_timing_file "TC" "_FILES_TC" ${basename} ${file_path} ${filetype}
}

proc add_timing_file_bc { basename file_path {filetype -1} } {
    add_timing_file "BC" "_FILES_BC" ${basename} ${file_path} ${filetype}
}

proc add_timing_file_wc { basename file_path {filetype -1} } {
    add_timing_file "WC" "_FILES_WC" ${basename} ${file_path} ${filetype}
}

####################################################################################################
# Innovus Specific Functions                                                                       #
####################################################################################################

if {[get_db program_short_name] == "innovus"} {
    namespace eval sec {
        namespace eval innovus {
            # Innovus current session ID -> just assembled from date and time
            variable in_sid     [ clock format   [ clock seconds ] -format {innovus_%Y%m%d%H%M} ]
            variable in_savedir [ file normalize [ file join [ file dirname [ info script ] ] \
                                  "${INNOVUS_SAVE_DESIGN_EXPORT_DIR}" ${in_sid} ] ]

            # Variables for export portability fixing
            #   Regex to blacklist certain path prefixes to prevent being replaced
            variable save_design_export_fix_dir_blacklist_regex "^(/storage|/nas)"
            #   Max tolerated file size to copy in MB
            variable save_design_export_fix_max_file_size 1

            puts "Detected Innovus Instance. Including tool specific TUM sec functions"
            puts "Using Innovus session design export directory ${sec::innovus::in_savedir}"
            puts "Directory will be created upon first design save"
            puts ""
            puts "Save design export fix parameters:"
            puts "save_design_export_fix_dir_blacklist_regex : ${save_design_export_fix_dir_blacklist_regex}"
            puts "save_design_export_fix_max_file_size       : ${save_design_export_fix_max_file_size} MB"

            # SaveDesign wrapper to write out non-blocking
            proc save_design_in_background { design_name args } {
                variable in_savedir
                mkdir -p "${in_savedir}"
                set design_savedir [ file join "${in_savedir}" ${design_name} ]
                puts "Saving current design to ${design_savedir}"
                puts "Invoking Innovus method saveDesign ${design_savedir} -no_wait ${design_savedir}.log $args"
                set cmd "::saveDesign ${design_savedir} -no_wait ${design_savedir}.log ${args}"
                eval "${cmd}"
            }

            # SaveDesign wrapper supporting all arguments
            proc save_design { design_name args } {
                variable in_savedir
                mkdir -p "${in_savedir}"
                set design_savefile [ file join "${in_savedir}" ${design_name} ]
                puts "Saving current design to ${design_savefile}"
                puts "Invoking Innovus method saveDesign $args ${design_savefile}"
                set cmd "::saveDesign ${args} ${design_savefile}"
                eval "${cmd}"
                # When saving, innovus will create a file to source the design
                # and put the design in a folder with the extension .dat
                # Example: final.enc is the script final.enc.dat is the folder
                return ${design_savefile}
            }

            proc save_design_export_fix {baseDir} {
                variable save_design_export_fix_dir_blacklist_regex
                variable save_design_export_fix_max_file_size

                set fileList {}
                set dirList $baseDir
                set pattern *

                puts "Running export fixing script to replace some symlinks created by saveDesign that"
                puts "are not in shared folders and thus inaccessible for others beyond the creating user"
                puts "Following symlinks will _not_ be replaced"
                puts "  * Filesize over ${save_design_export_fix_max_file_size} MB"
                puts "  * Link points to given exclude path regex ${save_design_export_fix_dir_blacklist_regex}"
                puts ""
                puts "Recursing into folder ${baseDir}"

                while {[llength $dirList] > 0} {
                    set subDir  [lindex $dirList     0]
                    set dirList [lreplace $dirList 0 0]

                    foreach entry [glob -nocomplain [file join $subDir *]] {
                        if {[file isdirectory $entry]} {
                            lappend dirList $entry
                        } elseif [string match $pattern $entry] {
                            # lappend fileList $entry

                            # If the file is not a link -> continue
                            if { [ file type $entry ] != "link" } \
                                continue

                            # Retrieve the location the link is pointing to
                            set ll [ file readlink "${entry}" ]

                            # If the link location is a directory -> continue
                            if { [ file isdirectory "${ll}" ] } \
                                continue

                            # If the link location matches the blacklist -> continue
                            if { [ regexp "${save_design_export_fix_dir_blacklist_regex}" "${ll}" ] } \
                                continue

                            # If the file size exceeds the max_size, skip
                            set fsize [ expr [ file size "${ll}" ].0 / 1000000 ]
                            if { ${fsize} > ${save_design_export_fix_max_file_size} } \
                                continue

                            puts "Replacing link ${entry} with original file ${ll} of size ${fsize} MBytes"
                            file delete "${entry}"
                            file copy   "${ll}" "${entry}"
                        }
                    }
                }
                puts "Changing group to users and make the folder writeable"
                chgrp -R users "${baseDir}"
                chmod -R g+rw  "${baseDir}"
                puts "Export fix done"
                puts ""
                return
            }
            # end proc save_design_fix
        } # end namespace innovus
    } # end namespace sec
}

