set terminal postscript eps enhanced color;
set output "time.eps";

set title ""
 
set xlabel "Input Size (thousands of lines)"
set ylabel "Time (s)"

plot "../data/colocations-cpp-mean.csv" using ($2/1000):3:7 notitle with errorbars, \
     "../data/colocations-cpp-mean.csv" using ($2/1000):3:7 title "G++" with lines, \
     "../data/colocations-hs-mean.csv" using ($2/1000):3:7 notitle with errorbars, \
     "../data/colocations-hs-mean.csv" using ($2/1000):3:7 title "GHC" with lines

set terminal png
set output "time.png"
replot

set terminal postscript eps enhanced color;
set output "memory.eps";

set title ""
 
set xlabel "Input Size (thousands of lines)"
set ylabel "Maximum Memory Used (GB)"

plot "../data/colocations-cpp-mean.csv" using ($2/1000):($4/1024.0**2):($8/1024**2) notitle with errorbars, \
     "../data/colocations-cpp-mean.csv" using ($2/1000):($4/1024.0**2):($8/1024**2) title "G++" with lines, \
     "../data/colocations-hs-mean.csv" using ($2/1000):($4/1024.0**2):($8/1024**2) notitle with errorbars, \
     "../data/colocations-hs-mean.csv" using ($2/1000):($4/1024.0**2):($8/1024**2) title "GHC" with lines

set terminal png
set output "memory.png"
replot
