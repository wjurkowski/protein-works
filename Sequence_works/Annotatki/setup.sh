echo "module add blast/2.2.18" >> run_$1
echo "mkdir /scratch/wik-$1" >> run_$1
echo "cp ~/komoda/create_profile_db.pl /scratch/wik-$1/" >>run_$1
echo "cd /scratch/wik-$1" >> run_$1

while read F 
 do
  echo "cp  ~/komoda/paczki/paka-$F.tgz /scratch/wik-$1/" >> run_$1
  echo "tar -zxf paka-$F.tgz" >> run_$1
  echo "rm -f paka-$F.tgz" >> run_$1
done < $1
 
while read F 
 do
  echo "perl create_profile_db.pl -psiblast $F dir-$F profile-gt ~/komoda/blastdb/&" >> run_$1
done < $1 

echo "wait" >> run_$1

echo "cd ../" >> run_$1
echo "tar -zcf wik-$1.tgz /scratch/wik-$1" >> run_$1
echo "mv wik-$1.tgz ~/komoda/zrobione/" >> run_$1

