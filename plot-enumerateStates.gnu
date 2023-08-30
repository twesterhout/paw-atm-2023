#!/usr/bin/gnuplot --persist

set terminal pdfcairo size 6cm, 5cm \
    transparent enhanced color \
    font "Linux Libertine O,10"

load "plot-common.gnu"

set key top left
set border back
set xlabel "Number of nodes\n{/=8(128 cores per nodes)}"
set ylabel "Speedup over the 1-node run\n{/=8 (40 spins: 102.1 s; 42 spins: 407.5 s)" font "Linux Libertine O,10" offset -1.5,0
set xtics 8
set xtics add ("1" 1)
set ytics 8
set ytics add ("1" 1)

set output "assets/speedup-enumerateStates.pdf"
lines = 'u (column("numLocales")):(column("enumerateStatesSpeedup")) with lines'
points = 'u (column("numLocales")):(column("enumerateStatesSpeedup")) with points'
points_border = 'u (column("numLocales")):(column("enumerateStatesSpeedup")) with points'

plot [1:32][1:32] \
    x ls 1 lw 3 lc rgb "#cc000000" dt (10, 14) notitle, \
    "data/processed/enumerateStates_42.csv" @lines ls 3 lw 3 notitle, "" @points ls 3 pt 5 ps 0.7 lw 2 title "42 spins", "" @points_border ls 3 pt 4 lc "black" ps 0.7 lw 1 notitle, \
    "data/processed/enumerateStates_40.csv" @lines ls 2 lw 3 notitle, "" @points ls 2 pt 9 ps 0.8 lw 2 title "40 spins", "" @points_border ls 2 pt 8 lc "black" ps 0.8 lw 1 notitle
