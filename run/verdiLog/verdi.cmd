simSetSimulator "-vcssv" -exec "/home/student/Documents/168_Honours/CBP/run/simv" \
           -args
debImport "-dbdir" "/home/student/Documents/168_Honours/CBP/run/simv.daidir"
debLoadSimResult /home/student/Documents/168_Honours/CBP/run/axi_intcnt.fsdb
wvCreateWindow
verdiWindowResize -win $_Verdi_1 "340" "92" "900" "700"
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
