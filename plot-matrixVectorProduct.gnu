#!/usr/bin/gnuplot --persist

set terminal pdfcairo size 6cm, 4cm \
    transparent enhanced color \
    font "Linux Libertine O,10"

load "plot-common.gnu"

set key top left
set xlabel "Number of nodes\n{/=8(128 cores per node)}"
set ylabel "Speedup over the fastest 1-node run\n{/=8(40 spins LS: 124.6 s; 42 spins LS: 509.6 s)}" offset -1,-1
set xtics 16
set mxtics 2 
set xtics add ("1" 1)
set ytics 16 format " %g"
set ytics add ("1" 1)
set mytics 2

lines = 'u (column("numLocales")):(column("matrixVectorProductSpeedup")) with lines'
points = 'u (column("numLocales")):(column("matrixVectorProductSpeedup")) with points'
points_border = 'u (column("numLocales")):(column("matrixVectorProductSpeedup")) with points'

set output "assets/speedup-matrixVectorProduct-small.pdf"
plot [1:64][1:64] \
    x ls 1 lw 3 lc rgb "#cc000000" dt (10, 14) notitle, \
    "data/processed/matrixVectorProduct_42.csv" @lines ls 1 lw 3 notitle, "" @points ls 1 pt 5 ps 0.7 lw 2 title "42 spins", "" @points_border ls 1 pt 4 lc "black" ps 0.7 lw 1 notitle, \
    "data/processed/matrixVectorProduct_40.csv" @lines ls 2 lw 3 notitle, "" @points ls 2 pt 9 ps 0.8 lw 2 title "40 spins", "" @points_border ls 2 pt 8 lc "black" ps 0.8 lw 1 notitle 

set output
_ = convert_pdf_to_png("assets/speedup-matrixVectorProduct-small")

set xtics auto
set ytics auto format "%g"
set mytics default
set logscale x 2
set logscale y 2
set ylabel "Speedup over the fastest few-node run\n{/=8 (44 spins LS, 4 nodes: 585.1 s;}\n{/=8 46 spins LS, 16 nodes: 583.9 s)}" offset -2,-1.5

set output "assets/speedup-matrixVectorProduct-big.pdf"

plot [4:256][0.9:64] \
    1 + (x - 4) / 4 ls 1 lw 3 lc rgb "#cc000000" dt (10, 14) notitle, \
    "data/processed/matrixVectorProduct_44.csv" @lines ls 3 lw 3 notitle, "" @points ls 3 pt 7 ps 0.7 lw 2 title "44 spins", "" @points_border ls 3 pt 6 lc "black" ps 0.7 lw 1 notitle, \
    (x >= 16? 1 + (x - 16) / 16 : 1/0) ls 1 lw 3 lc rgb "#cc000000" dt (10, 14) notitle, \
    "data/processed/matrixVectorProduct_46.csv" @lines ls 4 lw 3 notitle, "" @points ls 4 pt 9 ps 0.8 lw 2 title "46 spins", "" @points_border ls 4 pt 8 lc "black" ps 0.8 lw 1 notitle

set output
_ = convert_pdf_to_png("assets/speedup-matrixVectorProduct-big")
