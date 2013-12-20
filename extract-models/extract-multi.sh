set a=`grep ENDMDL $1 | wc -l`
set b=`expr $a - 2`
csplit -k -s -n 3 -f model. $1 '/^ENDMDL/+1' '{'$b'}'
foreach f (model.[0-9][0-9][0-9]) 
	mv $f $f.pdb
end

