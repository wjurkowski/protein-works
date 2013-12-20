set a=`grep ENDMDL $1 | wc -l`
set b=`expr $a - 2`
csplit -k -s -n 3 -f model. $1 '/^ENDMDL/+1' '{'$b'}'
foreach f (model.[0-9][0-9][0-9]) 
	set nm = `echo $f | awk '{print substr($0,7)}'`
	@ nm++
	set nnm=$nm
	set new = model.$nnm.pdb
	echo $new
	mv $f $new
end

