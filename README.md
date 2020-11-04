# Ethernet Switch
 
VHDL Ethernet Switch Implementation for a board in the Stratix family. Includes three major modules:

Frame Check Sequence (FCS), taking 8 bits per clock cycle parralel inputs from 4 different ethernet ports and does error detection.
Crossbar, handles routing packets from inputs from the FCS to output ports. Implemented with pure cross-point queuing in mind.
MAC Learning, procedurally learns which MAC addresses are on the different ports, allowing for data to be routed to the correct locations. Searching implemented with hashmapping.


Currently only the FCS submodule is done, and is subject to more changes.
