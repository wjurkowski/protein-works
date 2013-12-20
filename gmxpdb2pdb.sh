sed s/CYN/CYS/ $1 > out
sed s/CYX/CYS/ out > out2
sed s/HID/HIS/ out2 > out
sed s/HIE/HIS/ out > out2
sed s/LYP/LYS/ out2 > out
sed s/GLH/GLU/ out > out2
sed s/NALA/"ALA "/ out2 > out
sed s/NASN/"ASN "/ out > out2
sed s/NTYR/"TYR "/ out2 > out
sed s/CTYR/"TYR "/ out > out2
sed s/CARG/"ARG "/ out2 > out
sed s/CSER/"SER "/ out > out2
sed s/NZ/NH/ out2 > out
egrep -v "MC|MN|MH" out > out2
egrep -v "HG|HD|HH|HE" out2 > ${1%.pdb}_pp.pdb
babel -d -ipdb ${1%.pdb}_pp.pdb -opdb ${1%.pdb}_bb.pdb
rm -f out out2
