Input:
src1-4: 48 bit source address, the number equals the source port
dst1-4: 48 bit destination address, the number equals the source port
readport: The port that is ready for being read, eg 0011 = ports 1 and 2 are ready

Output:
ackport: Output used for acknowledging inputs. When an input has been read the ackport reflects this
writeport: The "final" output. Signifies where the packet should go ("1111" is broadcast)

Timing:
Has the same reaction time as a ram.
Might be a good idea to have a register save the output port as it's only there for 1 clock cycle
and the longest path is from the RAM to the output