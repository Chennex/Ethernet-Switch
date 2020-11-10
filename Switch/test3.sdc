## Generated SDC file "test3.out.sdc"

## Copyright (C) 1991-2011 Altera Corporation
## Your use of Altera Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Altera Program License 
## Subscription Agreement, Altera MegaCore Function License 
## Agreement, or other applicable license agreement, including, 
## without limitation, that your use is for the sole purpose of 
## programming logic devices manufactured by Altera and sold by 
## Altera or its authorized distributors.  Please refer to the 
## applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus II"
## VERSION "Version 10.1 Build 197 01/19/2011 Service Pack 1 SJ Full Version"

## DATE    "Tue Oct 25 14:24:18 2011"

##
## DEVICE  "EP4SGX230KF40C2"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {altera_reserved_tck} -period 100.000 -waveform { 0.000 50.000 } [get_ports {altera_reserved_tck}]
create_clock -name {clk_100} -period 10.000 -waveform { 0.000 5.000 } [get_ports {clk_100}]
create_clock -name {clk125} -period 8.000 -waveform { 0.000 4.000 } [get_pins {GEx4|pll|altpll_component|auto_generated|pll1|clk[0]}]


#**************************************************************
# Create Generated Clock
#**************************************************************



#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {clk125}] -rise_to [get_clocks {clk125}]  0.060 
set_clock_uncertainty -rise_from [get_clocks {clk125}] -fall_to [get_clocks {clk125}]  0.060 
set_clock_uncertainty -fall_from [get_clocks {clk125}] -rise_to [get_clocks {clk125}]  0.060 
set_clock_uncertainty -fall_from [get_clocks {clk125}] -fall_to [get_clocks {clk125}]  0.060 
set_clock_uncertainty -rise_from [get_clocks {altera_reserved_tck}] -rise_to [get_clocks {altera_reserved_tck}]  0.020 
set_clock_uncertainty -rise_from [get_clocks {altera_reserved_tck}] -fall_to [get_clocks {altera_reserved_tck}]  0.020 
set_clock_uncertainty -fall_from [get_clocks {altera_reserved_tck}] -rise_to [get_clocks {altera_reserved_tck}]  0.020 
set_clock_uncertainty -fall_from [get_clocks {altera_reserved_tck}] -fall_to [get_clocks {altera_reserved_tck}]  0.020 
set_clock_uncertainty -rise_from [get_clocks {clk_100}] -rise_to [get_clocks {clk125}]  0.110 
set_clock_uncertainty -rise_from [get_clocks {clk_100}] -fall_to [get_clocks {clk125}]  0.110 
set_clock_uncertainty -rise_from [get_clocks {clk_100}] -rise_to [get_clocks {clk_100}]  0.060 
set_clock_uncertainty -rise_from [get_clocks {clk_100}] -fall_to [get_clocks {clk_100}]  0.060 
set_clock_uncertainty -fall_from [get_clocks {clk_100}] -rise_to [get_clocks {clk125}]  0.110 
set_clock_uncertainty -fall_from [get_clocks {clk_100}] -fall_to [get_clocks {clk125}]  0.110 
set_clock_uncertainty -fall_from [get_clocks {clk_100}] -rise_to [get_clocks {clk_100}]  0.060 
set_clock_uncertainty -fall_from [get_clocks {clk_100}] -fall_to [get_clocks {clk_100}]  0.060 


#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************

set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 


#**************************************************************
# Set False Path
#**************************************************************

set_false_path -to [get_keepers {*altera_std_synchronizer:*|din_s1}]
set_false_path -from [get_keepers {*rdptr_g*}] -to [get_keepers {*ws_dgrp|dffpipe_fd9:dffpipe19|dffe20a*}]
set_false_path -from [get_keepers {*delayed_wrptr_g*}] -to [get_keepers {*rs_dgwp|dffpipe_ed9:dffpipe14|dffe15a*}]


#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

