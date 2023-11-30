#############################################################################
##
##
##
#############################################################################
##   ____  ____
##  /   /\/   /
## /___/  \  /
## \   \   \/    Core:          sem
##  \   \        Module:        sem_0_sem_example
##  /   /        Filename:      sem_0_sem_example.xdc
## /___/   /\    Purpose:       Constraints for the example design.
## \   \  /  \   *
##  \___\/\___ ##
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
## Constraint Description:
##
## These constraints are for physical implementation of the system level
## design example.
##
## The SEM controller initializes and manages the FPGA integrated silicon
## features for soft error mitigation.  When the controller is included
## in a design, do not include any design constraints related to these
## features.  Similarly, do not use any related bitgen options other than
## those for generating essential bit data files.
#############################################################################

########################################
## Controller: Internal Timing constraints
########################################

## The controller clock PERIOD constraint is propagated into the controller
## from the system level design example, where a PERIOD constraint is applied
## on the external clock input pin.

## The FRAME_ECC primitive is not considered a synchronous timing point,
## although it is. As a result, paths between FRAME_ECC and the controller
## are not analyzed by the PERIOD constraint. These constraints are placed
## to supplement the PERIOD coverage to ensure the nets are fully constrained.

set_max_delay -datapath_only -from [get_pins example_cfg/example_frame_ecc/*] 124.000 -quiet
set_max_delay -datapath_only -from [get_pins example_cfg/example_frame_ecc/*] -to [all_outputs] 250.000 -quiet

########################################
## Example Design: Master Clock
########################################

## Constraints on the clock net, including the clock PERIOD constraint.

create_clock -period 125.000 -name clk [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]

########################################
## Example Design: Status Pins
########################################

## Constraints on the external status pins. These are expected to
## be used as asynchronous "flag" outputs, although they can be used
## as synchronous outputs with respect to the "clk" input signal.
## The timing constraints are therefore intended to make sure the
## timing paths are analyzed, rather than unconstrained. It is also
## possible to use these as internal signals between the status port
## and user-supplied logic to observe the status port. In such use,
## the signals would be covered by PERIOD constraint.

set_property DRIVE 8 [get_ports status_initialization]
set_property SLEW FAST [get_ports status_initialization]
set_property IOSTANDARD LVCMOS33 [get_ports status_initialization]

set_property DRIVE 8 [get_ports status_observation]
set_property SLEW FAST [get_ports status_observation]
set_property IOSTANDARD LVCMOS33 [get_ports status_observation]

set_property DRIVE 8 [get_ports status_correction]
set_property SLEW FAST [get_ports status_correction]
set_property IOSTANDARD LVCMOS33 [get_ports status_correction]

set_property DRIVE 8 [get_ports status_classification]
set_property SLEW FAST [get_ports status_classification]
set_property IOSTANDARD LVCMOS33 [get_ports status_classification]

set_property DRIVE 8 [get_ports status_injection]
set_property SLEW FAST [get_ports status_injection]
set_property IOSTANDARD LVCMOS33 [get_ports status_injection]

set_property DRIVE 8 [get_ports status_uncorrectable]
set_property SLEW FAST [get_ports status_uncorrectable]
set_property IOSTANDARD LVCMOS33 [get_ports status_uncorrectable]

set_property DRIVE 8 [get_ports status_essential]
set_property SLEW FAST [get_ports status_essential]
set_property IOSTANDARD LVCMOS33 [get_ports status_essential]

set_property DRIVE 8 [get_ports status_heartbeat]
set_property SLEW FAST [get_ports status_heartbeat]
set_property IOSTANDARD LVCMOS33 [get_ports status_heartbeat]

set_output_delay -clock clk -max -125.000 [get_ports {status_observation status_correction status_classification status_injection status_uncorrectable status_essential status_heartbeat status_initialization}]
set_output_delay -clock clk -min 0.000 [get_ports {status_observation status_correction status_classification status_injection status_uncorrectable status_essential status_heartbeat status_initialization}]

########################################
## Example Design: MON Shim and Pins
########################################

## Constraints on the MON shim external pins, for reproducibility.
## The timing analysis by trce need not be reviewed for these pins
## as the serial communications interface is asynchronous.

set_property DRIVE 8 [get_ports monitor_tx]
set_property SLEW FAST [get_ports monitor_tx]
set_property IOSTANDARD LVCMOS33 [get_ports monitor_tx]

set_property IOSTANDARD LVCMOS33 [get_ports monitor_rx]

set_input_delay -clock clk -max -125.000 [get_ports monitor_rx]
set_input_delay -clock clk -min 250.000 [get_ports monitor_rx]
set_output_delay -clock clk -max -125.000 [get_ports monitor_tx]
set_output_delay -clock clk -min 0.000 [get_ports monitor_tx]

########################################
## Example Design: EXT Shim and Pins
########################################

## Constraints on the EXT shim external pins, for reproducibility.
## The timing analysis by trce must be reviewed in conjunction with
## the documented external memory timing budget to determine the
## maximum frequency of the design, including the effects of the
## external memory system design.

set_property IOB TRUE [get_cells example_ext/example_ext_byte/ext_c_ofd]
set_property IOB TRUE [get_cells example_ext/example_ext_byte/ext_d_ofd]
set_property IOB TRUE [get_cells example_ext/example_ext_byte/ext_q_ifd]
set_property IOB TRUE [get_cells example_ext/ext_s_ofd]

set_property DRIVE 8 [get_ports external_c]
set_property SLEW FAST [get_ports external_c]
set_property IOSTANDARD LVCMOS33 [get_ports external_c]

set_property DRIVE 8 [get_ports external_d]
set_property SLEW FAST [get_ports external_d]
set_property IOSTANDARD LVCMOS33 [get_ports external_d]

set_property DRIVE 8 [get_ports external_s_n]
set_property SLEW FAST [get_ports external_s_n]
set_property IOSTANDARD LVCMOS33 [get_ports external_s_n]

set_property IOSTANDARD LVCMOS33 [get_ports external_q]

set_input_delay -clock clk -max -125.000 [get_ports external_q]
set_input_delay -clock clk -min 250.000 [get_ports external_q]
set_output_delay -clock clk -max -125.000 [get_ports {external_d external_s_n external_c}]
set_output_delay -clock clk -min 0.000 [get_ports {external_d external_s_n external_c}]

########################################
## Example Design: Logic Placement
########################################

## Constraints on logic placement. The controller and its
## shims, which are the soft error mitigation solution, need
## to be reasonably area constrained.  This keeps everything
## near the configuration logic and also helps in generating
## a reasonable slice count estimate for reliability estimates.

create_pblock SEM_CONTROLLER
add_cells_to_pblock [get_pblocks SEM_CONTROLLER] [get_cells example_mon/*]
add_cells_to_pblock [get_pblocks SEM_CONTROLLER] [get_cells example_ext/*]
add_cells_to_pblock [get_pblocks SEM_CONTROLLER] [get_cells {example_controller example_ext example_mon}]
resize_pblock [get_pblocks SEM_CONTROLLER] -add {SLICE_X0Y0:SLICE_X31Y20}
resize_pblock [get_pblocks SEM_CONTROLLER] -add {RAMB18_X0Y0:RAMB18_X0Y3}
resize_pblock [get_pblocks SEM_CONTROLLER] -add {RAMB36_X0Y2:RAMB36_X0Y6}

## Prohibit addition of unrelated logic into this group...
## UCF: AREA_GROUP "SEM_CONTROLLER" GROUP = CLOSED ;
## There is currently no equivalent to this.

## Allow placement of unrelated components in the range...
## UCF: AREA_GROUP "SEM_CONTROLLER" PLACE = OPEN ;
## There is currently no equivalent to this.

## Force ICAP to the required (top) site in the device.
## Force FRAME_ECC to the required (only) site in the device.
set_property LOC FRAME_ECC_X0Y0 [get_cells example_cfg/example_frame_ecc]
set_property LOC ICAP_X0Y1 [get_cells example_cfg/example_icap]

########################################
## Example Design: I/O Placement
########################################

## To place the I/O, uncomment the following template and
## annotate with desired pin location for each signal.

## set_property LOC <pin loc> [get_ports clk]
## set_property LOC <pin loc> [get_ports status_initialization]
## set_property LOC <pin loc> [get_ports status_observation]
## set_property LOC <pin loc> [get_ports status_correction]
## set_property LOC <pin loc> [get_ports status_classification]
## set_property LOC <pin loc> [get_ports status_injection]
## set_property LOC <pin loc> [get_ports status_uncorrectable]
## set_property LOC <pin loc> [get_ports status_essential]
## set_property LOC <pin loc> [get_ports status_heartbeat]
## set_property LOC <pin loc> [get_ports monitor_tx]
## set_property LOC <pin loc> [get_ports monitor_rx]
## set_property LOC <pin loc> [get_ports external_c]
## set_property LOC <pin loc> [get_ports external_d]
## set_property LOC <pin loc> [get_ports external_q]
## set_property LOC <pin loc> [get_ports external_s_n]

########################################
## Vivado Properties: Essential Bits
########################################

## This property enables essential bits generation in Vivado.

set_property BITSTREAM.SEU.ESSENTIALBITS yes [current_design]

#############################################################################
##
#############################################################################

set_property PACKAGE_PIN W5 [get_ports clk]
set_property PACKAGE_PIN B18 [get_ports monitor_rx]
set_property PACKAGE_PIN A18 [get_ports monitor_tx]
set_property PACKAGE_PIN L1 [get_ports status_classification]
set_property PACKAGE_PIN P1 [get_ports status_correction]
set_property PACKAGE_PIN N3 [get_ports status_essential]
set_property PACKAGE_PIN P3 [get_ports status_heartbeat]
set_property PACKAGE_PIN U3 [get_ports status_initialization]
set_property PACKAGE_PIN W3 [get_ports status_injection]
set_property PACKAGE_PIN V3 [get_ports status_observation]
set_property PACKAGE_PIN V13 [get_ports status_uncorrectable]
set_property PACKAGE_PIN K18 [get_ports external_c]
set_property PACKAGE_PIN G18 [get_ports external_s_n]
set_property PACKAGE_PIN D19 [get_ports external_d]
set_property PACKAGE_PIN D18 [get_ports external_q]

set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets icap_clk]
