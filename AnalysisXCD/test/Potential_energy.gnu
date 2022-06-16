
reset
###############################################################################
set term wxt 1 enhanced dashed size 1800,1200 font "Arial,10"
set multiplot layout 3,4
set encoding iso_8859_1

set style line 1 lt 1 ps 0.4 lc rgb "black"  pt 4 lw 2.0
set style line 2 lt 2 ps 0.4 lc rgb "blue"  pt 4 lw 2.0
set style line 3 lt 2 ps 0.4 lc rgb "blue"   pt 4 lw 2.0
set style line 4 lt 1 ps 0.4 lc rgb "green"  pt 4 lw 2.0
set style line 5 lt 2 ps 0.4 lc rgb "yellow" pt 4 lw 2.0
set style line 6 lt 2 ps 0.4 lc rgb "orange" pt 4 lw 2.0

f1="./Potential_energy.dat"

# CALCULATE THE MAX AND MIN VALUE FOR Y-axis
stats f1 skip 1 nooutput
maxcol = STATS_columns
min_value=+1e10
max_value=-1e10
do for [icol=2:maxcol:2] {
    stats f1 u icol nooutput
    if (STATS_max > max_value) {
        max_value=STATS_max
    }
    if (STATS_min < min_value) {
        min_value=STATS_min
    }
}

delta=0.01
if (min_value > 0) {
    min_value=min_value-min_value*delta
} else {
    min_value=min_value+min_value*delta
}
if (max_value > 0) {
    max_value=max_value+max_value*delta
} else {
    max_value=max_value-max_value*delta
}
set yrange[min_value:max_value]
set xlabel "Time (ps)"
set ylabel "Energy (kcal/mol)"

iframe=1
do for [icol=2:maxcol:2] {
    set title sprintf("Potential energy. Frame %d",iframe)
    plot f1 u icol-1:icol w l ls 1 notitle 
    iframe=iframe+1
}
unset multiplot


reset
###############################################################################
set term wxt 2 enhanced dashed size 400,400 font "Arial,10"
set multiplot layout 1,1
set encoding iso_8859_1

set style line 1 lt 1 ps 1.0 lc rgb "black"  pt 6 lw 2.0
f1="./Potential_energy_avg.dat"

set xrange[0:"11"]

set xlabel "Frame #"
set ylabel "Energy (kcal/mol)"

plot f1 u 1:2:3  with errorbars ls 1 notitle 

unset multiplot

