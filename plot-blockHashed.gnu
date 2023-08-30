set terminal pdfcairo size 6cm, 3.5cm \
    transparent enhanced color \
    font "Linux Libertine O,10"

load "plot-common.gnu"

set output "assets/time-arrFromBlockToHashed.pdf"
lines = 'u (column("numLocales")):(column("arrFromBlockToHashed")) with lines'
points = 'u (column("numLocales")):(column("arrFromBlockToHashed")) with points'
points_border = 'u (column("numLocales")):(column("arrFromBlockToHashed")) with points'

set border back
set xlabel "Number of nodes\n{/=8(128 cores per node)}"
set ylabel "Time, s"
set key top right
set xtics 8
set xtics add ("1" 1)
set ytics 0.4

plot [1:32] \
    "data/processed/arrFromBlockToHashed_42.csv" @lines ls 3 lw 3 notitle, "" @points ls 3 pt 5 ps 0.7 lw 2 title "42 spins", "" @points_border ls 3 pt 4 lc "black" ps 0.7 lw 1 notitle, \
    "data/processed/arrFromBlockToHashed_40.csv" @lines ls 2 lw 3 notitle, "" @points ls 2 pt 9 ps 0.8 lw 2 title "40 spins", "" @points_border ls 2 pt 8 lc "black" ps 0.8 lw 1 notitle

set output
_ = convert_pdf_to_png("assets/time-arrFromBlockToHashed")

set output "assets/time-arrFromHashedToBlock.pdf"
lines = 'u (column("numLocales")):(column("arrFromHashedToBlock")) with lines'
points = 'u (column("numLocales")):(column("arrFromHashedToBlock")) with points'
points_border = 'u (column("numLocales")):(column("arrFromHashedToBlock")) with points'

plot [1:32] \
    "data/processed/arrFromHashedToBlock_42.csv" @lines ls 3 lw 3 notitle, "" @points ls 3 pt 5 ps 0.7 lw 2 title "42 spins", "" @points_border ls 3 pt 4 lc "black" ps 0.7 lw 1 notitle, \
    "data/processed/arrFromHashedToBlock_40.csv" @lines ls 2 lw 3 notitle, "" @points ls 2 pt 9 ps 0.8 lw 2 title "40 spins", "" @points_border ls 2 pt 8 lc "black" ps 0.8 lw 1 notitle

set output
_ = convert_pdf_to_png("assets/time-arrFromHashedToBlock")
