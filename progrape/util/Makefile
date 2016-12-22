# Time-stamp: "2007-01-07 04:17:15 hamada"
#
# Copyright(c) 2006 by Tsuyoshi Hamada 2006. All rights reserved.
#

CC          = gcc
CFLAGS      = -O -Wall
CFLAGS      = -g -Wall
INCLUDEDIRS = -I../pg4
LIBDIRS     = -L../libpgr ../pg4/pg4.o
LDLIBS      = 

#TARGET = $(filter-out xxx yyy, $(patsubst %.c,%,$(wildcard *.c)))
TARGET = ifpga_get_barinfo pfpga_info pfpga_reset pfpga_conf pfpga_conf_a  \
	ifpga_bram_dump ifpga_bram_clear 

.c:
	$(CC) $< -o $* $(CFLAGS) $(INCLUDEDIRS) $(LDLIBS) $(LIBDIRS)


all: $(TARGET)


ifpga_get_barinfo  : ifpga_get_barinfo.c
pfpga_info         : pfpga_info.c
pfpga_reset        : pfpga_reset.c 
pfpga_conf         : pfpga_conf.c
pfpga_conf_a       : pfpga_conf_a.c 
ifpga_bram_dump    : ifpga_bram_dump.c
ifpga_bram_clear   : ifpga_bram_clear.c
ifpga_dma_status   : ifpga_dma_status.c
ifpga_dma_reset    : ifpga_dma_reset.c

# --------------------------------------------------
install :
	cp $(TARGET) /usr/local/bin/
	cp mtrr mtrr.off s.irq_count s.kbuf s.kbuf.rm /usr/local/bin/


uninstall :
	cd /usr/local/bin/; rm -f $(TARGET)

clean : 
	rm -rf *~ .*~ test *.o *.a $(TARGET)

c : clean
