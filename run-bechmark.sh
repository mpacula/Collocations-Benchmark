#!/bin/bash

basedir=$( dirname $0 )

samples=30
input_sizes=$( seq 10000 10000 100000 )
for program in colocations-cpp colocations-hs; do
    echo "Timing $program"
    echo "#program n time_seconds max_memory_kbytes" > "$basedir/data/$program-times.csv"
    for n in $input_sizes; do
        echo "  n=" $n
        for sample in $( seq 1 $samples ); do
            echo "    sample="$sample
            time=$( head -n $n "$basedir/data/input.txt" | /usr/bin/time -f "%e    %M" "$basedir/$program" 2>&1 1>/dev/null )
            printf "%-20s%-20s%-20s\n" $program $n "$time" >> "$basedir/data/$program-times.csv"
        done
    done
done
