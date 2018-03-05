#!/bin/bash
i=$(sed -n "1p" /storage/st14136/zprime-test/MG5_aMC_v2_6_1/i.sh)
a=$(sed -n "$i p" /storage/st14136/zprime-test/MG5_aMC_v2_6_1/my.sh)
b=$(sed -n "$i p" /storage/st14136/zprime-test/MG5_aMC_v2_6_1/mx.sh)
c=$(sed -n "$i p" /storage/st14136/zprime-test/MG5_aMC_v2_6_1/gx.sh)
d=$(sed -n "$i p" /storage/st14136/zprime-test/MG5_aMC_v2_6_1/gq.sh)

cat > /storage/st14136/zprime-test/MG5_aMC_v2_6_1/myinputs.dat <<EOF
import model DMsimp_s_spin1
generate p p > xd xd~ j [QCD]
output $a-$b-$d-$c
launch
1
0
EOF

