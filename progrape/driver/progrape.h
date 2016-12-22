/*
 * progrape.h -- the device driver header for PROGRAPE-4
 *
 * Copyright (C) 2006-2007 Tsuyoshi Hamada.
 *                                All rights reserved.
 *
 * The source code in this file can be freely used, 
 * so long as an acknowledgment from Tsuyoshi Hamada.
 * 
 * The source code in this file can be modified, branched, and
 * redistributed in source or binary form in the following situation.  
 * If you want to modify, redistribute or make another version based on
 * this source code, you should get distinct agreement from Tsuyoshi
 * Hamada.  The modified, redistributed or branched(another version based
 * on this source code) source code should include the citation that the
 * code comes from the "progrape.c by Tsuyoshi Hamada".
 * 
 * No warranty is attached; 
 * I cannot take responsibility for errors or fitness for use.
 *
 */
#ifndef _PROGRAPE_H_
#define _PROGRAPE_H_

#include <linux/ioctl.h> /* for the _IOW etc */

// -------------------------------------------------------------------- for DEBUG
/*
 * Macros to help debugging
 */
#undef PDEBUG             /* undef it, just in case */
#ifdef DEBUG
#  ifdef __KERNEL__
     /* This one if debugging is on, and kernel space */
#    define PDEBUG(fmt, args...) printk( KERN_DEBUG "progrape: " fmt, ## args)
#  else
     /* This one for user space */
#    define PDEBUG(fmt, args...) fprintf(stderr, fmt, ## args)
#  endif
#else
#  define PDEBUG(fmt, args...) /* not debugging: nothing */
#endif

#undef _PDEBUG
#define _PDEBUG(fmt, args...) /* nothing: it's a placeholder */
// -------------------------------------------------------------------- for DEBUG. 

/* 
 * IOCTL definitions
 */

#define PG_IOC_MAGIC (7)
/*
 * SP : Set by Pointer
 * SV : Set by Value
 * GP : Get by Pointer
 * GV : Get by Value
 */
#define IOC_SV_MMAPMODE  _IOW(PG_IOC_MAGIC,  1, unsigned)
#define IOC_GV_REG_ADR   _IOR(PG_IOC_MAGIC,  2, unsigned long)
#define IOC_GV_REG_SIZE  _IOR(PG_IOC_MAGIC,  3, unsigned long)
#define IOC_GV_MEM_ADR   _IOR(PG_IOC_MAGIC,  4, unsigned long)
#define IOC_GV_MEM_SIZE  _IOR(PG_IOC_MAGIC,  5, unsigned long)
#define IOC_SP_FPGA_INFO _IOW(PG_IOC_MAGIC,  6, char* )
#define IOC_GP_FPGA_INFO _IOR(PG_IOC_MAGIC,  7, char* )
#define IOC_GV_PCICFG    _IOR(PG_IOC_MAGIC,  8, unsigned long)
#define IOC_SV_DMAW      _IOW(PG_IOC_MAGIC,  9, unsigned long)
#define IOC_SV_DMAR      _IOW(PG_IOC_MAGIC, 10, unsigned long)
#define IOC_GV_DMA_SIZE  _IOR(PG_IOC_MAGIC, 11, unsigned long)

#define PG_IOC_MAXNR (11)

/*
 * modes for pg_mmap
 * "pcidev->mmap_mode" has one of these mode.
 */
enum {
  MMAP_REG_PIOW = 0,      // bar0 for PG4, 0
  MMAP_REG_PIOR,          // bar0 for PG4, 1
  MMAP_REG_PIORW,         // bar0 for PG4, 2
  MMAP_MEM_PIOW,          // bar1 for PG4, 3
  MMAP_MEM_PIOR,          // bar1 for PG4, 4
  MMAP_MEM_PIORW,         // bar1 for PG4, 5
  MMAP_MEM_PIOW_PREFETCH, // bar1 for PG4, 6
  MMAP_BUF_DMAW,          // DMABUF for Host->Device direction, 7
  MMAP_BUF_DMAR,          // DMABUF for Device->Host direction, 8
};

#define NB_FPGA_INFO (256)  // Length(Bytes) of the FPGA information


/* 
 * IFPGA register definitions
 */
#define REG_PFPGA_RST         (0x04)
#define REG_INT_STAT          (0x10)
#define REG_INT_MASK          (0x14)
#define REG_DMA_PCI_ADRS      (0x20)
#define REG_DMA_LOCAL_ADRS    (0x24)
#define REG_DMA_COUNT         (0x28)
#define REG_DMA_CTRL          (0x2C)
#define REG_DMA_INTERVAL      (0x30)
#define REG_DMA_STAT          (0x34)


#ifdef __KERNEL__
// -------------------------------------------------------------------- Private Members
#include <linux/cdev.h>
#include <asm/semaphore.h> // struct semaphore
#include <linux/wait.h>    // wait_queue_head_t

struct pg_dev {
  struct pci_dev *pcidev;  // only for my debugging. Don't use it.
  unsigned long *buf_dmar; // Kernel logical address     ,also called CPU address
  unsigned long *buf_dmaw; // Kernel logical address     ,also called CPU address
  dma_addr_t buf_dmar_pa;  // bus address (type) for DMA ,also called physical address
  dma_addr_t buf_dmaw_pa;  // bus address (type) for DMA ,also called physical address
  unsigned long pci_reg_adr;
  unsigned long pci_reg_size;
  unsigned long pci_reg_flag;
  unsigned long pci_mem_adr;
  unsigned long pci_mem_size;
  unsigned long pci_mem_flag;  // IORESOURCE_{IO,MEM,PREFETCH,READONLY} @<linux/ioport.h>
  unsigned long pci_irq_num;
  unsigned long mmap_mode;
  wait_queue_head_t wq;        // wait queue for interrupt handler -> tasklet in future
  unsigned long wq_count;      // wait counter for interrupt handler
  struct semaphore sem;        // mutual exclusion semaphore
  struct semaphore sem_open;   // lock device while a person is opening it.
  unsigned long ntimes_open;   // the number of times for pg_open()
  struct cdev cdev;	       // Char device structure
  char fpga_info[NB_FPGA_INFO];// text for FPGA information (for bitfile)
};

#ifndef PROGRAPE_MAJOR
#    define PROGRAPE_MAJOR 0  // dynamically allocated if 0
#endif 

#ifndef PROGRAPE_MAJOR
#    define PROGRAPE_MAJOR 0  // dynamically allocated if 0
#endif 

// Number of maximum character device
#ifndef PROGRAPE_NR_DEVS
#    define PROGRAPE_NR_DEVS 1
#endif 

// -------------------------------------------------------------------- Private Members.
#endif


// for the different configurable parameters
extern int pg_major;
extern int pg_minor;
extern int pg_nr_devs;

// Prototyepes for shared functions
int check_license(void);
int get_license(void);


// --- ISA bridge: Advanced Micro Devices [AMD] AMD-8111 LPC (rev 05)
#undef PCI_VENDOR_ID_PG
#undef PCI_DEVICE_ID_PG
#undef PCI_REVISION_ID_PG
#define PCI_VENDOR_ID_PG   (0x1022)
#define PCI_DEVICE_ID_PG   (0x7468)
#define PCI_REVISION_ID_PG (0x05)

// --- PCI bridge: Advanced Micro Devices [AMD] AMD-8131 PCI-X Bridge (rev 12)
#undef PCI_VENDOR_ID_PG
#undef PCI_DEVICE_ID_PG
#undef PCI_REVISION_ID_PG
#define PCI_VENDOR_ID_PG   (0x1022)
#define PCI_DEVICE_ID_PG   (0x7450)
#define PCI_REVISION_ID_PG (0x12)

// --- PROGRAPE-4 
#undef PCI_VENDOR_ID_PG
#undef PCI_DEVICE_ID_PG
#undef PCI_REVISION_ID_PG
#define PCI_VENDOR_ID_PG   (0x1679)
#define PCI_DEVICE_ID_PG   (0x0005)
#define PCI_REVISION_ID_PG (0x00)


#define PG_DMA_BUFSIZE (0x1<<16) // 64 KB : IFPGA Block-RAM size 
//#define PG_DMA_BUFSIZE (0x1<<12) // 4 KB : IFPGA Block-RAM size 
#define PG_PCITRANS_64BIT (1)    // 1: 64-bit / 0: 32-bit

#endif // _PROGRAPE_H_
