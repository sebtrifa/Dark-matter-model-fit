#!/bin/bash
for i in {84..84}; do
cat > /storage/st14136/zprime-test/MG5_aMC_v2_6_1/i.sh <<EOF
$i
EOF
a=$(sed -n "$i p" /storage/st14136/zprime-test/MG5_aMC_v2_6_1/my.sh)
b=$(sed -n "$i p" /storage/st14136/zprime-test/MG5_aMC_v2_6_1/mx.sh)
c=$(sed -n "$i p" /storage/st14136/zprime-test/MG5_aMC_v2_6_1/gx.sh)
d=$(sed -n "$i p" /storage/st14136/zprime-test/MG5_aMC_v2_6_1/gq.sh)
cd /storage/st14136
./flush1_myinputs.sh
cd /storage/st14136/zprime-test/MG5_aMC_v2_6_1/
./bin/mg5_aMC myinputs.dat
cd /storage/st14136
./exec_cards.sh
./flush2_myinputs.sh
cd /storage/st14136/zprime-test/MG5_aMC_v2_6_1/
./bin/mg5_aMC myinputs.dat
cat >> /storage/st14136/results.txt <<EOF
$a $b $d $c $(sed '7q;d' /storage/st14136/zprime-test/MG5_aMC_v2_6_1/$a-$b-$d-$c/Events/run_02_LO/summary.txt)
EOF
done
