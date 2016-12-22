#Time-stamp: "2006-03-12 02:56:07 hamada"
#for ISE8.1i

all      : xst ngdbuild map par trce bitgen
xst      : proj/top.ngc
ngdbuild : proj/top.ngd
map      : proj/top_map.ncd
par      : proj/top.ncd
trce     : proj/top.twr
bitgen   : proj/top.bit



# XST(Synthesis)
proj/top.ngc : top.vhd
	cd proj;rm -f proj.ise proj.ise_ISE_Backup top_summary.html
	cd proj;touch -t 0002222222 *
	cd proj;xst -intstyle xflow -ifn top.xst -ofn top.syr

# NGDBUILD(Translate)
proj/top.ngd : proj/top.ngc
	cd proj;ngdbuild  -intstyle xflow -dd _ngo -nt timestamp -uc ../top.ucf -p xc3s5000-fg900-5 top.ngc top.ngd

# MAP
proj/top_map.ncd: proj/top.ngd
	cd proj; \
        map \
        -intstyle xflow     \
        -p xc3s5000-fg900-5 \
        -detail        \
        -timing        \
        -register_duplication  \
        -logic_opt on -ol high \
        -xe c          \
        -c 100         \
        -t 1           \
        -cm speed      \
        -pr b          \
        -k 4           \
        -o top_map.ncd \
        top.ngd        \
        top.pcf


# PAR
proj/top.ncd: proj/top_map.ncd
	cd proj;\
        par -w -intstyle xflow \
        -ol high -pl high -rl high \
        -xe c \
        -t 1 \
        top_map.ncd top.ncd top.pcf

#	cd proj;par -ise "./proj" -w -intstyle xflow -pl std -rl std -xe c -t 1 -n 0 -s 3 top_map.ncd ./mppr_result.dir top.pcf
#	cd proj;par -ise "./proj" -w -intstyle ise -pl high -rl high -xe c -t 1 -n 3 -s 3 top_map.ncd ./mppr_result.dir top.pcf


# TRCE
proj/top.twr: proj/top.ncd
	cd proj;trce -intstyle xflow -e 30 -l 3 -s 5 top.ncd -o top.twr top.pcf


# BITGEN
proj/top.bit: proj/top.ncd
	cd proj;bitgen -intstyle xflow -f top.ut top.ncd
	cp proj/top.bit ./top.bit

clean:
	rm -rf proj *~ .*~ top.bit
	tar xvfps proj.tar


