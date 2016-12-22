#/* v1.2
# * Makefile -- Makefile for device driver for PROGRAPE(-4,...)
# *
# * Copyright (C) 2006-2007 Tsuyoshi Hamada(hamada@progrape.jp).
# * All rights reserved.
# */

# Comment/uncomment the following line to disable/enable debugging
DEBUG = y

obj-m	:= progrape.o

KERNELDIR ?= /lib/modules/$(shell uname -r)/build
PWD       := $(shell pwd)

# Add your debugging flag (or not) to CFLAGS
# It is available for the GNU cpp (extended ANSI C preprocessor)

ifeq ($(DEBUG),y)
  DEBFLAGS = -O -g -DDEBUG # "-O" is needed to expand inlines
else
  DEBFLAGS = -O2
endif

CFLAGS += $(DEBFLAGS)

all:
	$(MAKE) -C $(KERNELDIR) M=$(PWD)

clean:
	rm -rf *.o *~ core .depend .*.cmd *.ko *.mod.c .tmp_versions

c : clean

l :
	sudo ./dev_load
	@lsmod |head 
	@ls -la /dev/ |grep progrape
	@sudo tail -20 /var/log/kern.log
u :
	sudo ./dev_unload
	@lsmod |head 
	@sudo tail -20 /var/log/kern.log

load : l
	@echo '---------------------------------'
	@echo 'progrape: device driver loaded.'
	@echo '---------------------------------'

unload : u
	@echo '---------------------------------'
	@echo 'progrape: device driver unloaded.' 
	@echo '---------------------------------'

d : 
	@sync
	@sync
	@sync
	@make c
	@make
	@make l
	@make u
