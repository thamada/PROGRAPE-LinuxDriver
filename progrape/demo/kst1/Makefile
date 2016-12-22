CC = icc -O
CC = gcc -Wall


S_HOST = force.c
S_EMU  = pg_pipe.c pg_module.c pg_util.c
S_VHD  = pg_pipev.c pg_util.c libpgr.a


all:
	$(CC) main.c force.c -o run.host

all.0 : 
	$(CC) main.c pg_pipe.c pg_module.c pg_util.c pg_pipev.c libpgr.a -o run.x  -lm


host : 
	$(CC) main.c read_data.c  $(S_HOST) -o run.host -lm

emu : 
	$(CC) main.c read_data.c  $(S_EMU)  -o run.emu  -lm

vhd : 
	$(CC) main.c read_data.c  $(S_VHD)  -o run.vhd  -lm


check : 
	./run.emu  ./Dfile/init.100 ./Dfile/init.300 >xxx.emu
	./run.vhd  ./Dfile/init.100 ./Dfile/init.300 >xxx.vhd
	md5sum xxx.emu xxx.vhd


check.0 : all
	./run.emu  ./Dfile/init.10 ./Dfile/init.8K >xxx.emu
	./run.vhd  ./Dfile/init.10 ./Dfile/init.8K >xxx.vhd
	md5sum xxx.host xxx.emu xxx.vhd

c:
	rm -rf *~ .*~ *.o run.x run.host run.emu run.vhd

clean: c

