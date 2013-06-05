#!/bin/bash

# Script to perform automatic seeding over a range of specified temperatues

temps="\
400 \
410 \
420 \
430 \
440 \
450 \
460 \
470 \
480 \
490 \
500 \
510 \
520 \
530 \
540 \
550 \
560 \
570 \
580 \
590 \
600 \
"

for t in $temps; do

    mkdir $t
    cp 1000K_preparation/REV* $t
    cp second_stage_inputs/* $t
    cd $t

    /home/boates/software/dl_poly/copy
    sed s/TEMPERATURE/$t.0/g CONTROL.template > CONTROL
    qsub dl.par

    cd ../

done

exit 0
    
