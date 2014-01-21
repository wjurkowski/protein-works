#!/bin/bash
FILE=$1
# read $FILE using the file descriptors
# takes UniprotAC on input
exec 3<&0
exec 0<$FILE

while read line
do 
	ffile="$line.fasta"
	if [ -f $ffile ] 
	then 
		echo $ffile exists
	else
		echo $ffile to be downloaded 
	wget http://www.uniprot.org/uniprot/$ffile 2>/dev/null 
	fi
	
done
exec 0<&3
