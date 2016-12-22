PGDIR   = /tmp/progrape

CC 	= icc
CFLAGS	= -c -O3 -I$(PGDIR)/pg4/
CFLAGS	= -c -O -pipe -I$(PGDIR)/pg4/

CC 	= gcc
CFLAGS	= -c -Wall -O2 -pipe -I$(PGDIR)/pg4/


TARGET	= test

test: clean test.o 
	$(CC) -o test test.o $(PGDIR)/pg4/pg4.o 

clean:
	rm -f *.o *~ test
	cd ../pg4/;make clean;make

d:
	ifpga_bram_dump|head -20
	ifpga_bram_clear

c: clean

