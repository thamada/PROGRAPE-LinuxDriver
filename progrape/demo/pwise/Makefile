CC = gcc -O4 -Wall -static
CC = gcc -g -Wall -static
CC = icc -Wall
CC = icc -O4 -Wall
CC = gcc -O4 -Wall

HEADER = nbodysim.h

EMUDIR = ./pgpg
EMUDIR = ./pgr

OBJS = main.o force.o \
       debug_position.o energy.o \
       leapflog.o leapflog_half.o \
       pg_util.o \

O_VHD = pg_pipev.o 
O_EMU = $(EMUDIR)/pg_module.o $(EMUDIR)/pg_pipe.o  

INC = -I./
LDLIBS = -lm -L.  -lpgr $(INC)\


all: run.vhd run.emu

run.vhd: $(OBJS) $(HEADER) $(O_VHD)
	$(CC)	$(O_VHD) $(OBJS)  -o run.vhd $(LDLIBS) -lpcidriver -L/pciDriver/

run.emu: $(OBJS) $(HEADER) $(O_EMU)
	$(CC)	$(O_EMU) $(OBJS)  -o run.emu $(LDLIBS)



GL_INCDIR = /home/hamada/Mesa-5.1/include
GL_LIBDIR = /home/hamada/Mesa-5.1/lib
GL_LIBS = -L$(GL_LIBDIR) -lglut -lGL -lGLU

show:
	gcc showAnim.c -o aho -lm $(GL_LIBS) -I$(GL_INCDIR)

#	./aho ./log.tmp
#	rm -rf ./aho

c : clean

clean: 
	rm -rf *.o pgpg/*.o *~ .*~ run.vhd run.emu
