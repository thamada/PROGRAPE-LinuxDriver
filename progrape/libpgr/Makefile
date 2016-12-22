#Time-stamp: <2006-08-01 15:29:11 hamada>

CC	= icc
CFLAGS	= -O3 -I./

CC	= gcc
CFLAGS	= -O -Wall -I./

OBJS_PG4LIB = pg4.o

all: libpgr.a

libpgr.a : pg4.o pgrapi.o
	ar -r $@ pg4.o pgrapi.o
	ranlib $@

pg4.o: pg4.c
	$(CC) $(CFLAGS) -c $< -I../driver

pgrapi.o: pgrapi.c
	$(CC) $(CFLAGS) -c $< 

clean : 
	rm -rf *~ .*~ test *.o *.a config_fpga

c : clean
