CC      = gcc
CPP     = g++

OPTIMIZE = -O3

CFLAGS   = $(OPTIMIZE)
CPPFLAGS = $(OPTIMIZE)

OBJS     = main.o debug_position_snap.o pg_pipe.o pg_util.o pg_module.o

.c.o:
	$(CC) -c $< $(CFLAGS)


all : run.e run.v mk_eight

#------------------------------------------------------------------------------
run.e : $(OBJS)
	$(CPP) $(OPTIMIZE) $(OBJS) -o run.e

#------------------------------------------------------------------------------
mk_eight : mk_eight.C
	$(CPP) mk_eight.C -o mk_eight

#------------------------------------------------------------------------------
OBJS.V    = main.o debug_position_snap.o pg_pipev.o pg_util.o
run.v : $(OBJS.V)
	$(CPP) $(OPTIMIZE) $(OBJS.V) -o run.v -lpcidriver -L/pciDriver/lib -lpgr -L./

clean : 
	rm -rf *~ *.o .*~ run.e mk_eight run.v
c : clean


# -----------------------------------------------------------------------------
RUN_PARA = 0.0001 100.0 0.2
EXE1 = ./mk_eight |$< $(RUN_PARA)
EXE2 = cat init/init.8noji.dat |$< $(RUN_PARA)
EXE3 = cat init/init.xxx |$< 0.05 2000.0 200.0
EXE4 = cat init/init.yyy |$< 0.05 2000.0 200.0

e : run.e
	$(EXE1)

e2 : run.e
	$(EXE2)

e3 : run.e
	$(EXE3)

e4 : run.e
	$(EXE4)


v : run.v
	$(EXE1)

v2 : run.v
	$(EXE2)

v3 : run.v
	$(EXE3)

v4 : run.v
	$(EXE4)




