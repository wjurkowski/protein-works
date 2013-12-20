#split sdf file 
csplit -k -s -n 5 -f model. $1 '%^ZINC%' '/^ZINC/' '{*}'
