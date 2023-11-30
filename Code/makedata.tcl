#############################################################################
##
##
##
#############################################################################
##   ____  ____
##  /   /\/   /
## /___/  \  /
## \   \   \/    Core:          sem
##  \   \        Module:        makedata
##  /   /        Filename:      makedata.tcl
## /___/   /\    Purpose:       Format bitgen output into VMF, MCS, and BIN
## \   \  /  \
##  \___\/\___\
##
#############################################################################
##
## (c) Copyright 2010 - 2019 Xilinx, Inc. All rights reserved.
##
## This file contains confidential and proprietary information
## of Xilinx, Inc. and is protected under U.S. and
## international copyright and other intellectual property
## laws.
##
## DISCLAIMER
## This disclaimer is not a license and does not grant any
## rights to the materials distributed herewith. Except as
## otherwise provided in a valid license issued to you by
## Xilinx, and to the maximum extent permitted by applicable
## law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
## WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
## AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
## BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
## INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
## (2) Xilinx shall not be liable (whether in contract or tort,
## including negligence, or under any other theory of
## liability) for any loss or damage of any kind or nature
## related to, arising under or in connection with these
## materials, including for any direct, or any indirect,
## special, incidental, or consequential loss or damage
## (including loss of data, profits, goodwill, or any type of
## loss or damage suffered as a result of any action brought
## by a third party) even if such damage or loss was
## reasonably foreseeable or Xilinx had been advised of the
## possibility of the same.
##
## CRITICAL APPLICATIONS
## Xilinx products are not designed or intended to be fail-
## safe, or for use in any application requiring fail-safe
## performance, such as life-support or safety devices or
## systems, Class III medical devices, nuclear facilities,
## applications related to the deployment of airbags, or any
## other applications that could lead to death, personal
## injury, or severe property or environmental damage
## (individually and collectively, "Critical
## Applications"). Customer assumes the sole risk and
## liability of any use of Xilinx products in Critical
## Applications, subject only to applicable laws and
## regulations governing limitations on product liability.
##
## THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
## PART OF THIS FILE AT ALL TIMES. 
##
#############################################################################
##
## Script Description:
##
## The bitgen application generates essential bit and frame data in a "binary
## ascii" format that must be formatted as VMF for simulation purposes and as
## MCS or BIN for device programming purposes.
##
#############################################################################

proc trim_and_convert_file {srcfile dstfile headerlen} {
  set inputfile [open $srcfile r]
  for {set i 0} {$i < $headerlen} {incr i 1} {
    if {[gets $inputfile line] < 0} {
      puts "File $srcfile has fewer than $headerlen lines."
      return
    }
  }
  set datalen 0
  set outputfile [open $dstfile w]
  while {[gets $inputfile line] >= 0} {
    set num 0
    set power 1
    for {set i [string length $line]} {$i > 0} {incr i -1} {
      if {[string index $line [expr {$i - 1}]] eq "1"} {
        incr num $power
      } 
      set power [expr $power * 2]
    }
    set byte0 [expr {($num >>  0) & 255}]
    set byte1 [expr {($num >>  8) & 255}]
    set byte2 [expr {($num >> 16) & 255}]
    set byte3 [expr {($num >> 24) & 255}]
    puts $outputfile [format "%02X" $byte0]
    puts $outputfile [format "%02X" $byte1]
    puts $outputfile [format "%02X" $byte2]
    puts $outputfile [format "%02X" $byte3]
    incr datalen 4
  }
  close $inputfile
  close $outputfile
  return $datalen
}

proc generate_index_file {dstfile ebc_exists ebc_length ebd_exists ebd_length} {
  if {$ebc_exists == 1} {
    if {$ebd_exists == 1} {
      set ebc_ptr [expr {128 + 404}]
      set ebd_ptr [expr {128 + 404 + $ebc_length}]
    } else {
      set ebc_ptr [expr {128 + 404}]
      set ebd_ptr [expr {0}]
    }
  } else {
    set ebc_ptr [expr {0}]
    set ebd_ptr [expr {128 + 404}]
  }
  set outputfile [open $dstfile w]
  set byte0 [expr {($ebc_ptr >>  0) & 255}]
  set byte1 [expr {($ebc_ptr >>  8) & 255}]
  set byte2 [expr {($ebc_ptr >> 16) & 255}]
  set byte3 [expr {($ebc_ptr >> 24) & 255}]
  puts $outputfile [format "%02X" $byte0]
  puts $outputfile [format "%02X" $byte1]
  puts $outputfile [format "%02X" $byte2]
  puts $outputfile [format "%02X" $byte3]
  set byte0 [expr {($ebd_ptr >>  0) & 255}]
  set byte1 [expr {($ebd_ptr >>  8) & 255}]
  set byte2 [expr {($ebd_ptr >> 16) & 255}]
  set byte3 [expr {($ebd_ptr >> 24) & 255}]
  puts $outputfile [format "%02X" $byte0]
  puts $outputfile [format "%02X" $byte1]
  puts $outputfile [format "%02X" $byte2]
  puts $outputfile [format "%02X" $byte3]
  for {set i 0} {$i < 120} {incr i 1} {
    puts $outputfile [format "%02X" 255]
  }
  close $outputfile
  return 0
}

proc generate_vmf {dstfile indexfile ebc_exists ebc_trim ebd_exists ebd_trim} {
  set outputfile [open $dstfile w]
  puts $outputfile "@00"
  set inputfile [open $indexfile r]
  while {[gets $inputfile line] >= 0} {
    if {[string length $line] >= 0} {
      puts $outputfile $line
    }
  }
  close $inputfile
  if {$ebc_exists == 1} {
    set inputfile [open $ebc_trim r]
    while {[gets $inputfile line] >= 0} {
      if {[string length $line] >= 0} {
        puts $outputfile $line
      }
    }
    close $inputfile
  }
  if {$ebd_exists == 1} {
    set inputfile [open $ebd_trim r]
    while {[gets $inputfile line] >= 0} {
      if {[string length $line] >= 0} {
        puts $outputfile $line
      }
    }
    close $inputfile
  }
  close $outputfile
  return 0
}

proc generate_bin_from_vmf {dstfile vmffile} {
  set inputfile [open $vmffile r]
  set outputfile [open $dstfile w]
  fconfigure $outputfile -translation binary -encoding binary
  gets $inputfile line
  while {[gets $inputfile line] >= 0} {
    if {[string length $line] >= 0} {
      puts -nonewline $outputfile [binary format c [expr "0x$line"]]
    }
  }
  close $inputfile
  close $outputfile
  return 0
}

proc generate_mcs_from_vmf {dstfile vmffile} {
  set inputfile [open $vmffile r]
  set outputfile [open $dstfile w]
  gets $inputfile line
  set keep_reading 1
  set address0 0
  set address1 0
  set address2 0
  set address3 0
  while {$keep_reading == 1} {
    if {$address0 == 0 && $address1 == 00} {
      puts -nonewline $outputfile ":02000004"
      puts -nonewline $outputfile [format "%02X" $address3]
      puts -nonewline $outputfile [format "%02X" $address2]
      set checksum [expr {-6 - $address3 - $address2}]
      set checksum [expr {$checksum & 255}]
      puts            $outputfile [format "%02X" $checksum]
    }
    if {[gets $inputfile line] >= 0 && $keep_reading == 1} {
      set temp00 [expr "0x00$line"]
    } else {
      set temp00 255
      set keep_reading 0
    }
    if {[gets $inputfile line] >= 0 && $keep_reading == 1} {
      set temp01 [expr "0x00$line"]
    } else {
      set temp01 255
      set keep_reading 0
    }
    if {[gets $inputfile line] >= 0 && $keep_reading == 1} {
      set temp02 [expr "0x00$line"]
    } else {
      set temp02 255
      set keep_reading 0
    }
    if {[gets $inputfile line] >= 0 && $keep_reading == 1} {
      set temp03 [expr "0x00$line"]
    } else {
      set temp03 255
      set keep_reading 0
    }
    if {[gets $inputfile line] >= 0 && $keep_reading == 1} {
      set temp04 [expr "0x00$line"]
    } else {
      set temp04 255
      set keep_reading 0
    }
    if {[gets $inputfile line] >= 0 && $keep_reading == 1} {
      set temp05 [expr "0x00$line"]
    } else {
      set temp05 255
      set keep_reading 0
    }
    if {[gets $inputfile line] >= 0 && $keep_reading == 1} {
      set temp06 [expr "0x00$line"]
    } else {
      set temp06 255
      set keep_reading 0
    }
    if {[gets $inputfile line] >= 0 && $keep_reading == 1} {
      set temp07 [expr "0x00$line"]
    } else {
      set temp07 255
      set keep_reading 0
    }
    if {[gets $inputfile line] >= 0 && $keep_reading == 1} {
      set temp08 [expr "0x00$line"]
    } else {
      set temp08 255
      set keep_reading 0
    }
    if {[gets $inputfile line] >= 0 && $keep_reading == 1} {
      set temp09 [expr "0x00$line"]
    } else {
      set temp09 255
      set keep_reading 0
    }
    if {[gets $inputfile line] >= 0 && $keep_reading == 1} {
      set temp0A [expr "0x00$line"]
    } else {
      set temp0A 255
      set keep_reading 0
    }
    if {[gets $inputfile line] >= 0 && $keep_reading == 1} {
      set temp0B [expr "0x00$line"]
    } else {
      set temp0B 255
      set keep_reading 0
    }
    if {[gets $inputfile line] >= 0 && $keep_reading == 1} {
      set temp0C [expr "0x00$line"]
    } else {
      set temp0C 255
      set keep_reading 0
    }
    if {[gets $inputfile line] >= 0 && $keep_reading == 1} {
      set temp0D [expr "0x00$line"]
    } else {
      set temp0D 255
      set keep_reading 0
    }
    if {[gets $inputfile line] >= 0 && $keep_reading == 1} {
      set temp0E [expr "0x00$line"]
    } else {
      set temp0E 255
      set keep_reading 0
    }
    if {[gets $inputfile line] >= 0 && $keep_reading == 1} {
      set temp0F [expr "0x00$line"]
    } else {
      set temp0F 255
      set keep_reading 0
    }
    puts -nonewline $outputfile ":10"
    puts -nonewline $outputfile [format "%02X" $address1]
    puts -nonewline $outputfile [format "%02X" $address0]
    puts -nonewline $outputfile "00"
    puts -nonewline $outputfile [format "%02X" $temp00]
    puts -nonewline $outputfile [format "%02X" $temp01]
    puts -nonewline $outputfile [format "%02X" $temp02]
    puts -nonewline $outputfile [format "%02X" $temp03]
    puts -nonewline $outputfile [format "%02X" $temp04]
    puts -nonewline $outputfile [format "%02X" $temp05]
    puts -nonewline $outputfile [format "%02X" $temp06]
    puts -nonewline $outputfile [format "%02X" $temp07]
    puts -nonewline $outputfile [format "%02X" $temp08]
    puts -nonewline $outputfile [format "%02X" $temp09]
    puts -nonewline $outputfile [format "%02X" $temp0A]
    puts -nonewline $outputfile [format "%02X" $temp0B]
    puts -nonewline $outputfile [format "%02X" $temp0C]
    puts -nonewline $outputfile [format "%02X" $temp0D]
    puts -nonewline $outputfile [format "%02X" $temp0E]
    puts -nonewline $outputfile [format "%02X" $temp0F]
    set checksum [expr {-16 - $address1 - $address0}]
    set checksum [expr {$checksum - $temp00 - $temp01 - $temp02 - $temp03}]
    set checksum [expr {$checksum - $temp04 - $temp05 - $temp06 - $temp07}]
    set checksum [expr {$checksum - $temp08 - $temp09 - $temp0A - $temp0B}]
    set checksum [expr {$checksum - $temp0C - $temp0D - $temp0E - $temp0F}]
    set checksum [expr {$checksum & 255}]
    puts            $outputfile [format "%02X" $checksum]
    set address0 [expr {$address0 + 16}]
    if {$address0 >= 256} {
      set address0 0
      set address1 [expr {$address1 + 1}]
    }
    if {$address1 >= 256} {
      set address1 0
      set address2 [expr {$address2 + 1}]
    }
    if {$address2 >= 256} {
      set address2 0
      set address3 [expr {$address3 + 1}]
    }
  }
  puts $outputfile ":00000001FF"
  close $outputfile
  close $inputfile
  return 0
}

proc makedata {args} {
  set argc [llength $args]
  set argv $args

puts "Xilinx 7 Series SEM data format utility starting."

if {$argc != 5} {
  if {$argc != 3} {
    puts "Usage:"
    puts "   makedata -ebc ebcfilename -ebd ebdfilename outfilebase"
    puts "   makedata -ebd ebdfilename -ebc ebcfilename outfilebase"
    puts "   makedata -ebc ebcfilename outfilebase"
    puts "   makedata -ebd ebdfilename outfilebase"
    puts " "
    puts "Example:"
    puts "   makedata -ebc top.ebc -ebd top.ebd spi_flash"
    puts " "
    puts "EBC and EBD files are generated by bitgen, with -g essentialbits:yes"
    puts "The outfilebase is the base name of the output file(s) that will be"
    puts "generated by this utility.  Those files are MCS, BIN, and VMF files"
    puts "used for memory initialization."
    return
  }
}

puts " "
puts "Legal number of arguments."

if {$argc == 3} {
  puts "There are three arguments."
  if {[lindex $argv 0] == "-ebc"} {
    set ebc_exists 1
    set ebc_file "[lindex $argv 1]"
    if {[file exists $ebc_file] != 1} {
      puts "Specified EBC file does not exist.";
      return
    }
    set ebd_exists 0
    set ebd_file " "
    set vmf_file "[lindex $argv 2].vmf"
    set bin_file "[lindex $argv 2].bin"
    set mcs_file "[lindex $argv 2].mcs"
  } elseif {[lindex $argv 0] == "-ebd"} {
    set ebd_exists 1
    set ebd_file "[lindex $argv 1]"
    if {[file exists $ebd_file] != 1} {
      puts "Specified EBD file does not exist.";
      return
    }
    set ebc_exists 0
    set ebc_file " "
    set vmf_file "[lindex $argv 2].vmf"
    set bin_file "[lindex $argv 2].bin"
    set mcs_file "[lindex $argv 2].mcs"
  } else {
    puts "Unexpected input arguments."
    return
  }
}

if {$argc == 5} {
  puts "There are five arguments."
  if {[lindex $argv 0] == "-ebc" && [lindex $argv 2] == "-ebd"} {
    set ebc_exists 1
    set ebc_file "[lindex $argv 1]"
    if {[file exists $ebc_file] != 1} {
      puts "Specified EBC file does not exist.";
      return
    }
    set ebd_exists 1
    set ebd_file "[lindex $argv 3]"
    if {[file exists $ebd_file] != 1} {
      puts "Specified EBD file does not exist.";
      return
    }
    set vmf_file "[lindex $argv 4].vmf"
    set bin_file "[lindex $argv 4].bin"
    set mcs_file "[lindex $argv 4].mcs"
  } elseif {[lindex $argv 0] == "-ebd" && [lindex $argv 2] == "-ebc"} {
    set ebd_exists 1
    set ebd_file "[lindex $argv 1]"
    if {[file exists $ebd_file] != 1} {
      puts "Specified EBD file does not exist.";
      return
    }
    set ebc_exists 1
    set ebc_file "[lindex $argv 3]"
    if {[file exists $ebc_file] != 1} {
      puts "Specified EBC file does not exist.";
      return
    }
    set vmf_file "[lindex $argv 4].vmf"
    set bin_file "[lindex $argv 4].bin"
    set mcs_file "[lindex $argv 4].mcs"
  } else {
    puts "Unexpected input arguments."
    return
  }
}

puts " "
if {$ebc_exists == 1} {
  puts "Trimming the EBC file $ebc_file"
  set ebc_length [trim_and_convert_file $ebc_file "ebc_trim.txt" 8]
  puts "  Contains $ebc_length bytes"
} else {
  set ebc_length 0
}
if {$ebd_exists == 1} {
  puts "Trimming the EBD file $ebd_file"
  set ebd_length [trim_and_convert_file $ebd_file "ebd_trim.txt" 8]
  puts "  Contains $ebd_length bytes"
} else {
  set ebd_length 0
}

puts "Generating the data index file."
generate_index_file "index.txt" $ebc_exists $ebc_length $ebd_exists $ebd_length
puts "  Contains 128 bytes"

puts " "

puts "Generating the VMF file $vmf_file"
generate_vmf $vmf_file "index.txt" $ebc_exists "ebc_trim.txt" $ebd_exists "ebd_trim.txt"

puts "Generating the BIN file $bin_file"
generate_bin_from_vmf $bin_file $vmf_file

puts "Generating the MCS file $mcs_file"
generate_mcs_from_vmf $mcs_file $vmf_file

puts " "

puts "Xilinx 7 Series SEM data format utility finished."
return 0
} ;
