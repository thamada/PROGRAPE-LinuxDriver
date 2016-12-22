#MAIN_OPTION = -DDUMP_LOG -DCALC_ENERGY # for RESULT CHECK /w Energy Calc
MAIN_OPTION = -DDUMP_LOG               # for RESULT CHECK /wo Energy Calc
#MAIN_OPTION = -DPROFILE_FORCE_ONLY     # for PERFORMANCE CHECK ONLY

# ----------------------------------- for Intel CC
CC = icc
CFLAGS	= -Wall -static -O3
#CFLAGS	= -Wall -static -O3 -xW -Ob2 -tpp6 -rcd 
#CFLAGS	= -Wall -O4
#CFLAGS	= -Wall -O2

# ----------------------------------- for GNU CC
CC = gcc
#CFLAGS	= -Wall -g
CFLAGS	= -Wall -O3 -pipe



LDLIBS = -lm 

OBJS = main.c debug_func_force.o \
       energy.o init_particles.o \
       leapflog.o leapflog_half.o \
       writelog.o \
       debug_position.o \
       debug_position_snap.o \
       flops.o pg_util.o \
       debug.o

O_HST = force.o
O_EMU = pg_module.o pg_pipe.o 
O_VHD = pg_pipev.o

OPT_HST = -DHOST
OPT_EMU = -DEMU
OPT_VHD = -DVHDL -lpgr -L../../libpgr 

all : host emu vhd rmobj

host: $(OBJS) $(O_HST) 
	$(CC) $(O_HST) $(OBJS)  -o run.host $(LDLIBS) $(MAIN_OPTION) $(OPT_HST)

emu:  $(OBJS) $(O_EMU)
	$(CC) $(O_EMU) $(OBJS)  -o run.emu  $(LDLIBS) $(MAIN_OPTION) $(OPT_EMU)

vhd: $(OBJS) $(O_VHD)
	$(CC) $(O_VHD) $(OBJS)  -o run.vhd  $(LDLIBS) $(MAIN_OPTION) $(OPT_VHD)

rmobj : 
	rm -f *.o

c : clean

clean: 
	rm -rf *.o *~ .*~ run.host run.emu run.vhd

