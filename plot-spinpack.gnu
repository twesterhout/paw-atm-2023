#!/usr/bin/gnuplot --persist

set terminal pdfcairo size 6cm, 5cm \
    transparent enhanced color \
    font "Linux Libertine O,10"

load "plot-common.gnu"

set output "assets/speedup-spinpack.pdf"
lines_ls = 'u (column("numLocales")):(column("matrixVectorProductSpeedup")) with lines'
points_ls = 'u (column("numLocales")):(column("matrixVectorProductSpeedup")) with points'
points_border_ls = 'u (column("numLocales")):(column("matrixVectorProductSpeedup")) with points'
lines_sp = 'u (column("numLocales")):(column("hamiltonSpeedup")) with lines'
points_sp = 'u (column("numLocales")):(column("hamiltonSpeedup")) with points'
points_border_sp = 'u (column("numLocales")):(column("hamiltonSpeedup")) with points'

set xtics 4
set xtics add ("1" 1)
set ytics 4
set xlabel "Number of nodes\n{/=8(128 cores per node)}" font "Linux Libertine O,10"
set ylabel "Speedup over the fastest 1-node run\n{/=8 (40 spins LS: 124.6 s; 42 spins LS: 509.6 s)}"
set key top left

plot [1:32][0:32] \
    x ls 1 lw 3 lc rgb "#cc000000" dt (10, 14) notitle, \
    "data/processed/matrixVectorProduct_42.csv" @lines_ls ls 2 lw 3 notitle, "" @points_ls ls 2 pt 5 ps 0.7 lw 2 title "LS (42 spins)", "" @points_border_ls ls 2 pt 4 lc "black" ps 0.7 lw 1 notitle, \
    "data/processed/matrixVectorProduct_40.csv" @lines_ls ls 1 lw 3 notitle, "" @points_ls ls 1 pt 5 ps 0.7 lw 2 title "LS (40 spins)", "" @points_border_ls ls 1 pt 4 lc "black" ps 0.7 lw 1 notitle, \
    "data/processed/spinpack_42.csv" @lines_sp ls 3 lw 3 notitle, "" @points_sp ls 3 pt 7 ps 0.7 lw 2 title "SPINPACK (42 spins)", "" @points_border_sp ls 3 pt 6 lc "black" ps 0.7 lw 1 notitle, \
    "data/processed/spinpack_40.csv" @lines_sp ls 4 lw 3 notitle, "" @points_sp ls 4 pt 7 ps 0.7 lw 2 title "SPINPACK (40 spins)", "" @points_border_sp ls 4 pt 6 lc "black" ps 0.7 lw 1 notitle

set output
_ = convert_pdf_to_png("assets/speedup-spinpack")
