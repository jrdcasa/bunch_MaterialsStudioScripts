import logging
import pandas as pd
import re


# =============================================================================
template = """
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

f1=#FILEDATA#

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
set xlabel #XLABEL#
set ylabel #YLABEL#

iframe=1
do for [icol=2:maxcol:2] {
    set title sprintf("#TITLELEGEND#. Frame %d",iframe)
    plot f1 u icol-1:icol w l ls 1 notitle 
    iframe=iframe+1
}
unset multiplot
"""

template_gnu = """
reset
###############################################################################
set term wxt 2 enhanced dashed size 400,400 font "Arial,10"
set multiplot layout 1,1
set encoding iso_8859_1

set style line 1 lt 1 ps 1.0 lc rgb "black"  pt 6 lw 2.0
f1=#FILEDATA#

set xrange[0:#NPOINTS#]

set xlabel #XLABEL#
set ylabel #YLABEL#

plot f1 u 1:2:3  with errorbars ls 1 notitle 

unset multiplot

"""


# =============================================================================
def prepare_data_plots(df_dict, label, meandata=None):

    isfirst = True
    df_all = None
    for key, idf in df_dict.items():
        if isfirst:
            isfirst = False
            df_all = idf
        else:
            df_all = pd.concat([df_all, idf], ignore_index=False, axis=1)

    header_list = list(df_all.columns)
    buff = df_all.to_csv(None, sep=' ', index=False, float_format="%.12f", header=False)

    xlabel = header_list[0]
    ylabel = header_list[1]
    try:
        title = label.replace("_", " ")
    except AttributeError:
        title = label

    # Write data
    label_underscore = re.sub(" ", "_", label)
    filenamedat = "{}.dat".format(label_underscore)
    with open(filenamedat, 'w') as f:
        f.writelines("# ")
        for item in header_list:
            f.writelines("{} ".format(item))
        f.writelines("\n")
        f.writelines(buff)

    # Write gnu template
    filenamegnu = "{}.gnu".format(label_underscore)
    t = template.replace("#FILEDATA#", "\"./{}\"".format(filenamedat))
    t = t.replace("#XLABEL#", "\"{}\"".format(xlabel))
    t = t.replace("#YLABEL#", "\"{}\"".format(ylabel))
    t = t.replace("#TITLELEGEND#", "{}".format(title))
    with open(filenamegnu, 'w') as f:
        f.writelines(t)

    if meandata is not None:
        filenameavg = "{}_avg.dat".format(label_underscore)
        with open(filenameavg, 'w') as f:
            i = 1
            for item in meandata:
                f.writelines("{} {} {}\n".format(i, item[0], item[1]))
                i += 1

        # Append gnu template
        filenamegnu = "{}.gnu".format(label_underscore)
        tgnu = template_gnu.replace("#FILEDATA#", "\"./{}\"".format(filenameavg))
        tgnu = tgnu.replace("#XLABEL#", "\"{}\"".format("Frame #"))
        tgnu = tgnu.replace("#YLABEL#", "\"{}\"".format(ylabel))
        tgnu = tgnu.replace("#NPOINTS#", "\"{}\"".format(len(meandata)+1))
        with open(filenamegnu, 'a') as f:
            f.writelines("\n")
            f.writelines(tgnu)

    return df_all
