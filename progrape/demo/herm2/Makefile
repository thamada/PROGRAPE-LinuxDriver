CC      = gcc
CPP     = g++

OPTIMIZE = -O3

CFLAGS   = $(OPTIMIZE)
CPPFLAGS = $(OPTIMIZE)

OBJS     = main.o force.o debug_position_snap.o pg_pipe.o pg_util.o pg_module.o

.c.o:
	$(CC) -c $< $(CFLAGS)


all : run.e run.v mk_eight

#------------------------------------------------------------------------------
run.e : $(OBJS)
	$(CPP) $(OPTIMIZE) $(OBJS) -o run.e


clean : 
	rm -rf *~ *.o .*~ run.e mk_eight
c : clean


# -----------------------------------------------------------------------------
RUN_PARA = 0.00001 100.0 0.2
EXE1 = @cat init.xxx |$< 0.01 0.05 0.01 > x~
EXE2 = @cat init.8noji.dat |$< $(RUN_PARA)

EXE_GNUPLOT = ./plot

e : run.e
	cd x;make
	make run.e
	$(EXE1)
	$(EXE_GNUPLOT)

ee : run.e
	$(EXE2)


s : 
	head -5 init.xxx

