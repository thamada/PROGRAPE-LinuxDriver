#define FIXED_IRQN (18)

/*
 * progrape.c -- the device driver for PROGRAPE(-4,...)
 *
 * Copyright (C) 2006-2007 Tsuyoshi Hamada(hamada@progrape.jp).
 * All rights reserved.
 *
 * The source code in this file can be freely used, 
 * so long as an acknowledgment from Tsuyoshi Hamada.
 * 
 * The source code in this file can be modified, branched, and
 * redistributed in source or binary form under the following situations.
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

#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/mm.h>
#include <linux/config.h>
#include <linux/pci.h>      // Symbols for pci_{read,write}_config_
#include <linux/types.h>    // u8,u16,u32,u64 
#include <linux/ioport.h>   // IORESOURCE_IO
#include <linux/dma-mapping.h>
#include <linux/sched.h>
#include <linux/version.h>
#include <linux/interrupt.h>// request_irq(), free_irq()
#include <asm/io.h>         // ioremap(), iounmap(), iowrite32()
#include <asm/pgtable.h>    // pgprot_noncached()
#include <asm/page.h>       // get_order(), virt_to_page()
#include <asm/uaccess.h>    // access_ok()


/* history
 *
 * 2006/07/11: developping start by Tsuyoshi Hamada
 */

#include "progrape.h"

#ifndef PG_MODULE_NAME
#define PG_MODULE_NAME "progrape"
#endif


int pg_major =   PROGRAPE_MAJOR;
int pg_minor =   0;
int pg_nr_devs = PROGRAPE_NR_DEVS; // number of char devs
module_param(pg_major,   int, S_IRUGO);
module_param(pg_minor,   int, S_IRUGO);
module_param(pg_nr_devs, int, S_IRUGO);

int pg_nr_pci_devs = 0;            // number of devices founded by kernel pci core

static struct pg_dev *pg_devices;  // allocated in progrape_init_module


int pg_ioctl(struct inode *i, struct file *fp, unsigned int c, unsigned long a);
static int pg_open       (struct inode *inode, struct file *file);
static int pg_close      (struct inode *inode, struct file *file);
static int pg_mmap       (struct file *fp, struct vm_area_struct *vma);

struct file_operations pg_fops = {
	.owner   = THIS_MODULE,
	.ioctl   = pg_ioctl,
	.open    = pg_open,
	.release = pg_close,
	.mmap    = pg_mmap,
};

static void pg_vma_open                (struct vm_area_struct *v);
static void pg_vma_close               (struct vm_area_struct *v);
static struct page  *pg_vma_nopage     (struct vm_area_struct *v, unsigned long adr, int *t);
static struct page  *pg_dmar_vma_nopage(struct vm_area_struct *v, unsigned long adr, int *t);
static struct page  *pg_dmaw_vma_nopage(struct vm_area_struct *v, unsigned long adr, int *t);

static struct vm_operations_struct pg_remap_vm_ops = {
  .open   = pg_vma_open,
  .close  = pg_vma_close,
  .nopage = pg_vma_nopage,
};

static struct vm_operations_struct pg_dmar_vm_ops = {
  .open   = pg_vma_open,
  .close  = pg_vma_close,
  .nopage = pg_dmar_vma_nopage,
};

static struct vm_operations_struct pg_dmaw_vm_ops = {
  .open   = pg_vma_open,
  .close  = pg_vma_close,
  .nopage = pg_dmaw_vma_nopage,
};

static inline unsigned long pg_get_dmabufsize(void)
{
  // << PG4 ifpga BRAM = 64KBytes = (0x1<<16) Bytes >>
  //  return ((unsigned long)(0x1<<16));           // 64 KB : BRAM
  //  return ((unsigned long)(0x1<<12));           //  4 KB : x86 linux
  //  return ((unsigned long)(dev->pci_mem_size)); // 16 MB : BAR0
  //  return ((unsigned long)(PAGE_SIZE));         // system 1 page
  return ((unsigned long)(PG_DMA_BUFSIZE));
}

// DANGER! it's from /usr/src/linux/mm/internal.h
static inline void set_page_count(struct page *page, int v)
{
  atomic_set(&page->_count, v);
}

static void free_dmabuf(int order, struct pci_dev *dev,  unsigned long *va, dma_addr_t pa)
{

  {
    ///////// set_page_count() @ <linux/mm.h>,
    ///////// try to use dma_free_coherent() for future version.
    int i;
    struct page *page_top = virt_to_page((unsigned long)va);
    for(i=1;i<(1<<order);i++) set_page_count(page_top + i, 0);
    pci_free_consistent(dev, PAGE_SIZE * (1<<order), va, pa);
  }

  //  dma_free_coherent(dev, PAGE_SIZE * (1<<order), va, pa);

}

void pg_vma_open(struct vm_area_struct *vma)
{
  _PDEBUG("called pg_vma open, virtual %lx, physical %lx\n", vma->vm_start, vma->vm_pgoff << PAGE_SHIFT);
}

void pg_vma_close(struct vm_area_struct *vma)
{
  _PDEBUG("called pg_vma_close()\n");
}

static struct page *pg_vma_nopage     (struct vm_area_struct *vma, unsigned long address, int *type)
{
  _PDEBUG("Called: pg_vma_nopage()\n");
  return (NOPAGE_SIGBUS);
}


static struct page *pg_dmar_vma_nopage(struct vm_area_struct *vma, unsigned long address, int *type)
{
  ////////// See Linux Device Drivers Vol. 3 pp. 435
  struct pg_dev *dev = vma->vm_file->private_data;
  struct page* page_ptr;
  unsigned long offset;
  _PDEBUG("Called: pg_dmar_vma_nopage()\n");

  offset = address - vma->vm_start + ((vma->vm_pgoff)<<PAGE_SHIFT);
  page_ptr = virt_to_page((unsigned long)(dev->buf_dmar) + offset);
  get_page(page_ptr);

  return (page_ptr);
}

static struct page *pg_dmaw_vma_nopage(struct vm_area_struct *vma, unsigned long address, int *type)
{
  struct pg_dev *dev = vma->vm_file->private_data;
  struct page* page_ptr;
  unsigned long offset;
  _PDEBUG("Called: pg_dmaw_vma_nopage()\n");

  offset = address - vma->vm_start + ((vma->vm_pgoff)<<PAGE_SHIFT);
  page_ptr = virt_to_page((unsigned long)(dev->buf_dmaw) + offset);
  get_page(page_ptr);

  return (page_ptr);
}

static int pg_mmap (struct file *fp, struct vm_area_struct *vma)
{
  struct pg_dev *dev = fp->private_data;
  int retval = 0;
  unsigned long off       = (vma->vm_pgoff) << PAGE_SHIFT;
  unsigned long vsize     = (vma->vm_end) - (vma->vm_start);
  unsigned long virtual   = vma->vm_start;
  unsigned long physical  = 0;
  unsigned long mmap_mode = dev->mmap_mode;

  _PDEBUG("called mmap, MMAP_MODE = %ld\n",mmap_mode);

  // Set physical for BAR's mmap
  switch (mmap_mode){
  case MMAP_REG_PIOW : // for REG (BAR0) Write Only
  case MMAP_REG_PIOR : // for REG (BAR0) Read Only
  case MMAP_REG_PIORW: // for REG (BAR0)
    physical = dev->pci_reg_adr & PCI_BASE_ADDRESS_MEM_MASK;
    break;
  case MMAP_MEM_PIOW : // for MEM (BAR1) Write Only
  case MMAP_MEM_PIOR : // for MEM (BAR1) Read Only
  case MMAP_MEM_PIORW: // for MEM (BAR1)
  case MMAP_MEM_PIOW_PREFETCH:
    physical = dev->pci_mem_adr & PCI_BASE_ADDRESS_MEM_MASK;
    break;
  default:
    physical = dev->pci_reg_adr & PCI_BASE_ADDRESS_MEM_MASK;
  }

  switch (mmap_mode){
  case MMAP_REG_PIOW : // for REG (BAR0) Write Only
  case MMAP_REG_PIOR : // for REG (BAR0) Read Only
  case MMAP_REG_PIORW: // for REG (BAR0)
  case MMAP_MEM_PIOW : // for MEM (BAR1) Write Only
  case MMAP_MEM_PIOR : // for MEM (BAR1) Read Only
  case MMAP_MEM_PIORW: // for MEM (BAR1)
  case MMAP_MEM_PIOW_PREFETCH:
    {
      //unsigned long psize = dev->pci_reg_size - off;
      physical += off;
      vma->vm_flags |= VM_RESERVED;  
      _PDEBUG("called pg_mmap\n");
      _PDEBUG(" + vsize 0x%lx\n", vsize);
      _PDEBUG(" + psize 0x%lx\n", psize);
      _PDEBUG(" + off   0x%lx\n", off);
      _PDEBUG(" + virt  0x%lx\n", virtual);
      _PDEBUG(" + phys  0x%lx\n", physical);
      /* --------------------------------------------
      if(vsize > psize){
	PDEBUG("vsize > psize: return (-EINVAL)\n");
	return (-EINVAL); // range is too short.
      }
      ----------------------------------------------- */
      retval = remap_pfn_range(vma, virtual, 
			       (physical>>PAGE_SHIFT), vsize, vma->vm_page_prot);
      if(retval){
	PDEBUG("error remap_pfn_range()\n ");
	return (-EAGAIN); 
      }
      vma->vm_ops = &pg_remap_vm_ops;
      pg_vma_open(vma);
    }
    break;

  case MMAP_BUF_DMAW:
    vma->vm_ops = &pg_dmaw_vm_ops;
    /*******************************************************  NON Coherency **
    **************************************************************************/

    vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);

    ////////////                    <asm/pgtable.h>
    ////////////                    to mark a page protection value as "uncacheable".
    vma->vm_flags |= (VM_RESERVED | VM_IO);
    pg_vma_open(vma);
    break;

  case MMAP_BUF_DMAR:
    vma->vm_ops = &pg_dmar_vm_ops;
    vma->vm_flags |= VM_RESERVED | VM_IO;
    pg_vma_open(vma);
    break;

  default:
    PDEBUG("incompatible mmap mode(%lx) @ %s:%d\n",mmap_mode,__FILE__, __LINE__);
    return (-EINVAL);
  }
    
  if(retval) retval = (-EAGAIN);

  return (retval);
}

void __usleep(unsigned int usec)
{
  wait_queue_head_t w;
  init_waitqueue_head(&w);
  wait_event_interruptible_timeout(w, 0, usec*HZ/1000000);
}

int pg_dmatransfer(struct pg_dev* dev, dma_addr_t bus_adr, unsigned long size, int is_write)
{
  unsigned char *bar0buf;
  _PDEBUG("called pg_dmatransfer(). size = 0x%lx.\n",size);

  { // I-O memory mapping
    unsigned long b0ad = dev->pci_reg_adr;
    unsigned long b0sz = dev->pci_reg_size;
    bar0buf = (unsigned char*) ioremap_nocache(b0ad, b0sz);
  }

  { // DMA_PCI_ADRS:
    // LOCAL_ADRS:
    // DMA_COUNT:
    unsigned long sram_ad = 0; // address for Block-RAM on the IFPGA.
    iowrite32(((u32)(bus_adr)), (void __iomem *)(bar0buf+  REG_DMA_PCI_ADRS  ));
    iowrite32(((u32)(sram_ad)), (void __iomem *)(bar0buf+  REG_DMA_LOCAL_ADRS));

    size &= (~(PG_PCITRANS_64BIT<<2));
    iowrite32(((u32)(size)),    (void __iomem *)(bar0buf+  REG_DMA_COUNT     )); // (size) bytes!

    _PDEBUG(" + DMA buf phys adr %lx\n", (unsigned long)bus_adr);
    _PDEBUG(" + SRAM adr %lx\n", sram_ad);
  }

  { // DMA_INTERVAL:
    unsigned int burst = 0;  // DMA Length
    unsigned int inter = 0;  // DMA Interval
    u32 cmd = (u32)((burst<<16)|(inter));
    iowrite32(cmd, (void __iomem *)(bar0buf+  REG_DMA_INTERVAL));
  }

  { // Prepare DMA
    iowrite32(0,   (void __iomem *)(bar0buf+  REG_INT_STAT)); // ... clear
    iowrite32(0,   (void __iomem *)(bar0buf+  REG_DMA_CTRL)); // ... clear
    iowrite32(0,   (void __iomem *)(bar0buf+  REG_DMA_STAT)); // ... clear
    iowrite32(1,   (void __iomem *)(bar0buf+  REG_INT_MASK)); // [1:Enable INT/ 0:Disable INT]
  }

  { // DMA_CTRL and start ...
    //////////////////////            reserved  :  DMA_CTRL(31 downto 5)
    unsigned int dma_dir   = is_write;          // DMA_CTRL(4)  [1:HOST->BOARD/ 0:HOST<-BOARD]
    unsigned int dma_mode  = 0x1;               // DMA_CTRL(3 downto 2)
    unsigned int dma_64_32 = PG_PCITRANS_64BIT; // DMA_CTRL(1)  [1:64bit/ 0:32bit]
    unsigned int dma_start = 0x1;               // DMA_CTRL(0)
    u32 cmd = (u32)((dma_dir<<4) | (dma_mode<<2) | (dma_64_32<<1) | dma_start);
    iowrite32(cmd, (void __iomem *)(bar0buf+  REG_DMA_CTRL)); // start DMA
  }

  { //WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW wait
    int ret;
    (dev->wq_count) = 0;
    _PDEBUG("Wait Interrupt ....\n");
    ret = wait_event_interruptible(dev->wq,  (dev->wq_count) > 0 );
    if(ret){
      PDEBUG("wait_event_interruptible return %d.  %s:%d\n", ret, __FILE__, __LINE__);
      return (-ERESTARTSYS);
    }
    _PDEBUG("%ld times interrupt asserted.\n", dev->wq_count);
  } //WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW wait

  iounmap((void __iomem *)bar0buf);
  return (0);
}

// ---------------------
// NO INTERRUPT VERSION
// ---------------------
int __pg_dmatransfer(struct pg_dev* dev, dma_addr_t bus_adr, unsigned long size, int is_write)
{
  unsigned char *bar0buf;
  _PDEBUG("called pg_dmatransfer(). size = 0x%lx.\n",size);

  { // I-O memory mapping
    unsigned long b0ad = dev->pci_reg_adr;
    unsigned long b0sz = dev->pci_reg_size;
    bar0buf = (unsigned char*) ioremap_nocache(b0ad, b0sz);
  }

  { // DMA_PCI_ADRS:
    // LOCAL_ADRS:
    // DMA_COUNT:
    unsigned long sram_ad = 0; // address for Block-RAM on the IFPGA.
    iowrite32(((u32)(bus_adr)), (void __iomem *)(bar0buf+  REG_DMA_PCI_ADRS  ));
    iowrite32(((u32)(sram_ad)), (void __iomem *)(bar0buf+  REG_DMA_LOCAL_ADRS));

    size &= (~(PG_PCITRANS_64BIT<<2));
    iowrite32(((u32)(size)),    (void __iomem *)(bar0buf+  REG_DMA_COUNT     )); // (size) bytes!

    _PDEBUG(" + DMA buf phys adr %lx\n", (unsigned long)bus_adr);
    _PDEBUG(" + SRAM adr %lx\n", sram_ad);
  }

  { // DMA_INTERVAL:
    unsigned int burst = 0;  // DMA Length
    unsigned int inter = 0;  // DMA Interval
    u32 cmd = (u32)((burst<<16)|(inter));
    iowrite32(cmd, (void __iomem *)(bar0buf+  REG_DMA_INTERVAL));
  }

  { // Prepare DMA
    iowrite32(0,   (void __iomem *)(bar0buf+  REG_INT_STAT)); // ... clear
    iowrite32(0,   (void __iomem *)(bar0buf+  REG_DMA_CTRL)); // ... clear
    iowrite32(0,   (void __iomem *)(bar0buf+  REG_DMA_STAT)); // ... clear
    iowrite32(0,   (void __iomem *)(bar0buf+  REG_INT_MASK)); // [1:Enable INT/ 0:Disable INT]
  }

  { // DMA_CTRL and start ...
    //////////////////////            reserved  :  DMA_CTRL(31 downto 5)
    unsigned int dma_dir   = is_write;          // DMA_CTRL(4)  [1:HOST->BOARD/ 0:HOST<-BOARD]
    unsigned int dma_mode  = 0x1;               // DMA_CTRL(3 downto 2)
    unsigned int dma_64_32 = PG_PCITRANS_64BIT; // DMA_CTRL(1)  [1:64bit/ 0:32bit]
    unsigned int dma_start = 0x1;               // DMA_CTRL(0)
    u32 cmd = (u32)((dma_dir<<4) | (dma_mode<<2) | (dma_64_32<<1) | dma_start);
    iowrite32(cmd, (void __iomem *)(bar0buf+  REG_DMA_CTRL)); // start DMA
  }

  { //WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW wait
    if(is_write)
      __usleep(1000);      
    else 
      __usleep(1000000);
  } //WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW wait

  iowrite32(0,   (void __iomem *)(bar0buf+  REG_INT_STAT)); // ... clear
  iowrite32(0,   (void __iomem *)(bar0buf+  REG_INT_MASK)); // [1:Enable INT/ 0:Disable INT]
  iowrite32(0,   (void __iomem *)(bar0buf+  REG_DMA_CTRL)); // ... clear
  iounmap((void __iomem *)bar0buf);
  return (0);
}



void do_test(struct pg_dev *dev){
  int i;
  unsigned long dmabuf_size = pg_get_dmabufsize();

  PDEBUG("* do_test() !!!!!!!!!!!!!!!\n");

  for(i=0;i<(dmabuf_size>>2);i++){
    dev->buf_dmaw[i] = 0x07070707;
    dev->buf_dmar[i] = 0x77778888;
  }
  dev->buf_dmaw[(dmabuf_size>>2)-1] = 0xCCCC9999;

}

int pg_ioctl(struct inode *inode, struct file *fp,
		unsigned int cmd, unsigned long arg)
{
  struct pg_dev *dev = fp->private_data;
  int err = 0, retval = 0;
  
  // Decode & Check cmd before access_ok() 
  if (_IOC_TYPE(cmd) != PG_IOC_MAGIC) return (-ENOTTY);
  if (_IOC_NR(cmd) > PG_IOC_MAXNR)    return (-ENOTTY);

  // Verify the arg with access_ok()
  //   -> See Linux Device Drivers Vol. 3 pp. 141-142 about access_ok()
  if (_IOC_DIR(cmd) & _IOC_READ)
    err = !access_ok(VERIFY_WRITE, (void __user *)arg, _IOC_SIZE(cmd));
  else if (_IOC_DIR(cmd) & _IOC_WRITE)
    err = !access_ok(VERIFY_READ,  (void __user *)arg, _IOC_SIZE(cmd));
  if (err) return (-EFAULT);

  switch(cmd) {

  case IOC_SV_MMAPMODE:
    dev->mmap_mode = (unsigned long)arg;
    _PDEBUG("IOC_SV_MMAPMODE : %lx\n", dev->mmap_mode);
    break;

  case IOC_GV_REG_ADR:
    retval = dev->pci_reg_adr;
    break;

  case IOC_GV_REG_SIZE:
    retval = dev->pci_reg_size;
    break;

  case IOC_GV_MEM_ADR:
    retval = dev->pci_mem_adr;
    break;

  case IOC_GV_MEM_SIZE:
    retval = dev->pci_mem_size;
    break;

  case IOC_SP_FPGA_INFO:
    {
      char s[NB_FPGA_INFO];
      /* --- if root only, uncomment ----------------
	if (! capable (CAP_SYS_ADMIN)) return (-EPERM); 
       ---------------------------------------------- */
      retval = __copy_from_user(s,(char __user *)arg, sizeof(s));
      strcpy(dev->fpga_info, s);
    }
    break;

  case IOC_GP_FPGA_INFO:
    {
      char s[NB_FPGA_INFO];
      strcpy(s, dev->fpga_info);
      retval = __copy_to_user((char __user *)arg,  s, sizeof(s));
    }

    break;

  case IOC_GV_PCICFG:
    {
      u32 val;
      int dword_adr = (((int)arg)<<2); // for DWORD addressing(I hate Byte addressing)
      if(pci_read_config_dword(dev->pcidev,dword_adr, &val)){
	PDEBUG("IOC_GV_PCICFG failed (%d) @ %s:%d\n",retval,__FILE__ ,__LINE__);
	retval = (-EAGAIN);
      }
      retval = (int)val;
    }
    break;

  case IOC_SV_DMAW:
    {
      int is_write       = 1;
      unsigned long size = (unsigned long) arg;
      dma_addr_t bus_adr = dev->buf_dmaw_pa;
      retval = pg_dmatransfer(dev, bus_adr, size, is_write);

      if(retval){
	PDEBUG("IOC_SV_DMAW. Something goes wrong at %s:%d.\n", __FILE__, __LINE__);
	retval = (-EAGAIN);
      }
      break;
    }

  case IOC_SV_DMAR:
    {
      int is_write       = 0;
      unsigned long size = (unsigned long) arg;
      dma_addr_t bus_adr = dev->buf_dmar_pa;
      retval = pg_dmatransfer(dev, bus_adr, size, is_write);
      break;
    }

  case IOC_GV_DMA_SIZE:
    retval = pg_get_dmabufsize();
    return (retval);
    break;

  default:  /* redundant, as cmd was checked against MAXNR */
    return (-ENOTTY);
  }

  return (retval);
}

static irqreturn_t pg_interrupt_handler(int irq, void *dev_id, struct pt_regs *regs)
{
  struct pg_dev *dev = dev_id;

  _PDEBUG("          <-------- interrupt handler on IRQ(%d).\n",irq);

  { // diasseert Interrupt signal
    unsigned long b0ad = dev->pci_reg_adr;
    unsigned long b0sz = dev->pci_reg_size;
    unsigned char *bar0buf = (unsigned char*) ioremap_nocache(b0ad, b0sz);
    iowrite32(0,   (void __iomem *)(bar0buf+  REG_INT_STAT)); // ... clear
    iowrite32(0,   (void __iomem *)(bar0buf+  REG_INT_MASK)); // [1:Enable INT/ 0:Disable INT]
    iowrite32(0,   (void __iomem *)(bar0buf+  REG_DMA_CTRL)); // ... clear
    iounmap((void __iomem *)bar0buf);
  }

  (dev->wq_count)++;
  //  PDEBUG("          <-------- interrupt handler on IRQ(%d) %d.\n",irq, dev->wq_count);
  //  __usleep(300);
  wake_up_interruptible(&(dev->wq));

  return (IRQ_HANDLED);
}

    
static int pg_open(struct inode *inode, struct file *file)
{
  struct pg_dev *dev;
  dev = container_of(inode->i_cdev, struct pg_dev, cdev); // find me
  file->private_data = dev;                               // backup me

  if(down_interruptible(&(dev->sem_open))) return (-ERESTARTSYS);

  { // install interrupt handler
    int ret;
    u8 irq_num;
    unsigned long flag;
    //    pci_read_config_byte(dev->pcidev, PCI_INTERRUPT_LINE, &irq_num);
    irq_num = dev->pci_irq_num;

    //    flag = SA_SHIRQ | SA_INTERRUPT | SA_TRIGGER_HIGH;
    flag = SA_SHIRQ;
    ret = request_irq((unsigned int)irq_num, pg_interrupt_handler, flag, PG_MODULE_NAME, (void*)dev);
    if(ret) return (-EBUSY);
  }

  (dev->ntimes_open)++;
  PDEBUG("'%s' opens %s%d : %ld times\n", current->comm, PG_MODULE_NAME, iminor(inode), dev->ntimes_open);
  return (0); // 0: success
}

static int pg_close(struct inode *inode, struct file *file)
{
  struct pg_dev *dev;
  dev = file->private_data;

  { // uninstall interrupt handler
    u8 irq_num;
    //    pci_read_config_byte(dev->pcidev, PCI_INTERRUPT_LINE, &irq_num);
    irq_num = dev->pci_irq_num;

    free_irq((unsigned int)irq_num, (void *)dev);
  }

  up(&(dev->sem_open));
  PDEBUG("'%s' closes %s%d.\n", current->comm, PG_MODULE_NAME, iminor(inode));
  return (0); // 0: success
}



/* ----------------------------------------------------------- *
 * The module stuff 
 * ----------------------------------------------------------- */


// The list of pci_device_id. It should be registerd to the pci_driver->id_table
static struct pci_device_id
pg_ids[  ] = {{PCI_DEVICE(PCI_VENDOR_ID_PG,PCI_DEVICE_ID_PG), },{ 0,}};

// pci_device_id should be exported to user space. 
MODULE_DEVICE_TABLE(pci, pg_ids);


static int pg_pci_probe(struct pci_dev *dev, const struct pci_device_id *id)
{
  // Do probing type stuff here. Like calling request_region();
  // This function called by pci_register_driver() at init_module.
  int err = 0;
  static int nth_probes = 0;
  PDEBUG("%d-th device probed by kernel.\n", nth_probes);
  err = pci_enable_device(dev);
  if(err){
    PDEBUG("Error pci_enable_device(dev); %s|%d\n",__FILE__, __LINE__);
  }

  {
    u32 base_adr[6];
    u16 vendor_id,  device_id, cmd, status;
    u8 revision_id, max_lat, min_gnt, int_line, int_pin;
    pci_read_config_word(dev, PCI_VENDOR_ID,    &vendor_id);
    pci_read_config_word(dev, PCI_DEVICE_ID,    &device_id);
    pci_read_config_word(dev, PCI_STATUS,       &status);
    pci_read_config_word(dev, PCI_COMMAND, &cmd);
    pci_read_config_byte(dev, PCI_REVISION_ID,  &revision_id);
    pci_read_config_byte(dev, PCI_MIN_GNT, &min_gnt);
    pci_read_config_byte(dev, PCI_MAX_LAT, &max_lat);
    pci_read_config_byte(dev, PCI_INTERRUPT_LINE, &int_line);
    pci_read_config_byte(dev, PCI_INTERRUPT_PIN,  &int_pin);
    pci_read_config_dword(dev,PCI_BASE_ADDRESS_0, &base_adr[0]);
    pci_read_config_dword(dev,PCI_BASE_ADDRESS_1, &base_adr[1]);
    pci_read_config_dword(dev,PCI_BASE_ADDRESS_2, &base_adr[2]);
    pci_read_config_dword(dev,PCI_BASE_ADDRESS_3, &base_adr[3]);
    pci_read_config_dword(dev,PCI_BASE_ADDRESS_4, &base_adr[4]);
    pci_read_config_dword(dev,PCI_BASE_ADDRESS_5, &base_adr[5]);

    PDEBUG("--- IFPGA PCI CONFIG SPACE   ---\n");
    PDEBUG("PCI_VENDOR_ID      : 0x%04X\n",vendor_id);
    PDEBUG("PCI_DEVICE_ID      : 0x%04X\n",device_id);
    PDEBUG("PCI_REVISION_ID    : 0x%02X\n",revision_id);
    PDEBUG("PCI_INTERRUPT_LINE : 0x%X\n",int_line);
    PDEBUG("PCI_INTERRUPT_PIN  : 0x%X\n",int_pin);
    _PDEBUG("PCI_STATUS         : 0x%04X\n",status);
    _PDEBUG(" + 66MHZ CAPABLE   : %X\n",0x1U & (status>>5));
    _PDEBUG(" + DEVCEL TIMING   : %X\n",0x3U & (status>>9));
    _PDEBUG("PCI_MIN_GNT        : 0x%02X\n",min_gnt);
    _PDEBUG("PCI_MAX_LAT        : 0x%02X\n",max_lat);
    _PDEBUG("PCI_COMMAND        : 0x%04X\n",cmd);
    _PDEBUG(" + ENABLE BUSMASTER: %01X\n",0x1U&(cmd>>2));
    _PDEBUG(" + ENABLE MEMORY   : %01X\n",0x1U&(cmd>>1));
    _PDEBUG(" + ENABLE I/O      : %01X\n",0x1U&(cmd));
    PDEBUG("PCI_BASE_ADDRESS_0 : 0x%08X\n",base_adr[0]);
    PDEBUG("PCI_BASE_ADDRESS_1 : 0x%08X\n",base_adr[1]);
    _PDEBUG("PCI_BASE_ADDRESS_2 : 0x%08X\n",base_adr[2]);
    _PDEBUG("PCI_BASE_ADDRESS_3 : 0x%08X\n",base_adr[3]);
    _PDEBUG("PCI_BASE_ADDRESS_4 : 0x%08X\n",base_adr[4]);
    _PDEBUG("PCI_BASE_ADDRESS_5 : 0x%08X\n",base_adr[5]);
    _PDEBUG("--------------------------------\n");
  }
  if(0){
    u8 revision;
    pci_read_config_byte(dev, PCI_REVISION_ID, &revision);
    if (PCI_REVISION_ID_PG != revision) {
      PDEBUG("REVISION MISSING: 0x%X != 0x%X\n",revision, PCI_REVISION_ID_PG);
      return (-ENODEV);
    }
  }

  // Install a pci_devices
  if( PROGRAPE_NR_DEVS > nth_probes ){
    unsigned long start, end, size, flag;
    u8 irq_num;

    pg_devices[nth_probes].pcidev       = dev;  // Don't use after pci_unregister_driver().

    pci_read_config_byte(dev, PCI_INTERRUPT_LINE, &irq_num);
    //    irq_num = FIXED_IRQN;
    //    irq_num = 28;
    PDEBUG("@@@@@@@@@@@@@@@@@@@@@@ IRQ_NUM = %d\n",irq_num);

    pg_devices[nth_probes].pci_irq_num  = (unsigned long)irq_num;


    start = pci_resource_start (dev, 0);  // @ <linux/pci.h>
    end   = pci_resource_end   (dev, 0);  // @ <linux/pci.h>
    flag  = pci_resource_flags (dev, 0);  // @ <linux/pci.h>
    if(end != start) size = end - start + 1; else size = 0;
    pg_devices[nth_probes].pci_reg_adr  = 0xffffffff & start;
    pg_devices[nth_probes].pci_reg_size = 0xffffffff & size;
    pg_devices[nth_probes].pci_reg_flag = 0xffffffff & flag;

    start = pci_resource_start (dev, 1);
    end   = pci_resource_end   (dev, 1);
    flag  = pci_resource_flags (dev, 1);
    if(end != start) size = end - start + 1; else size = 0;
    pg_devices[nth_probes].pci_mem_adr  = 0xffffffff & start;
    pg_devices[nth_probes].pci_mem_size = 0xffffffff & size;
    pg_devices[nth_probes].pci_mem_flag = 0xffffffff & flag;


    pci_set_master(dev);

  }else{
    return (-ENODEV);
  }


  {
    nth_probes++;
    pg_nr_pci_devs = nth_probes;
  }


  return (0);
}

static void pg_pci_remove(struct pci_dev *dev)
{
  // clean up any allocated resources and stuff here. like call release_region();
  PDEBUG("call pci_driver.remove()\n");
}

static struct pci_driver pci_driver = {
  .name     = PG_MODULE_NAME,
  .id_table = pg_ids,
  .probe    = pg_pci_probe,
  .remove   = pg_pci_remove,
};


/*
 * Set up the char_dev structure for this device to Kernel.
 */
static void pg_setup_cdev(struct pg_dev *dev, int index)
{
  int err;
  dev_t devno = MKDEV(pg_major, pg_minor + index);
  cdev_init(&dev->cdev, &pg_fops);

  dev->cdev.owner = THIS_MODULE;
  dev->cdev.ops = &pg_fops;
  err = cdev_add (&dev->cdev, devno, 1);
  if(err){
    PDEBUG( "Error %d adding %s%d", err, PG_MODULE_NAME, index);
  }
}



/* 
 * The cleanup function.
 */
static void pg_cleanup_module(void)
{
  { // ---------------------------- about DMA buffer
    unsigned long dmabuf_size = pg_get_dmabufsize();
    int i;
    for(i=0; i<pg_nr_pci_devs; i++){
      struct pg_dev *dev = &(pg_devices[i]);
      free_dmabuf(get_order(dmabuf_size), dev->pcidev,  dev->buf_dmar, dev->buf_dmar_pa);
      free_dmabuf(get_order(dmabuf_size), dev->pcidev,  dev->buf_dmaw, dev->buf_dmaw_pa);
    }
  } // ---------------------------- about DMA buffer


  { // ---------------------------- about kernel pci core
    pci_unregister_driver(&pci_driver);
  } // ---------------------------- about kernel pci core


  { // ---------------------------- about char dev
    int i;
    dev_t devno = MKDEV(pg_major, pg_minor);
    if (pg_devices) {
      for (i = 0; i < pg_nr_devs; i++) {
	cdev_del(&pg_devices[i].cdev);
      }
      kfree(pg_devices);
    }
    unregister_chrdev_region(devno, pg_nr_devs);
  } // ---------------------------- about char dev

  PDEBUG("module unloaded.\n\n");
  PDEBUG("bye (- u -)/~~~~~~~\n");
  PDEBUG("bye (*'> v <'*)\n");
  PDEBUG("bye (.^_^.)\n");
  PDEBUG("bye........\n\n");
}


/* 
 * The initialization function.
 */
static int pg_init_module(void)
{
  int result;

  { // ---------------------------- about char dev
    int i;
    dev_t dev = 0;

    if (pg_major) {
      dev = MKDEV(pg_major, pg_minor);
      result = register_chrdev_region(dev, pg_nr_devs, PG_MODULE_NAME);
    } else {
      result = alloc_chrdev_region(&dev, pg_minor, pg_nr_devs, PG_MODULE_NAME);
      pg_major = MAJOR(dev);
    }
    if (result < 0) {
      PDEBUG("can't get major %d\n", pg_major);
      return (result);
    }


    // allocate the devices
    pg_devices = kmalloc(pg_nr_devs * sizeof(struct pg_dev), GFP_KERNEL);
    if (!pg_devices) {
      result = (-ENOMEM);
      goto init_fail;
    }
    memset(pg_devices, 0, pg_nr_devs * sizeof(struct pg_dev));

    /* Initialize each device. */
    for (i = 0; i < pg_nr_devs; i++) {
      init_MUTEX(&pg_devices[i].sem);
      init_MUTEX(&pg_devices[i].sem_open);
      init_waitqueue_head(&pg_devices[i].wq);
      pg_setup_cdev(&pg_devices[i], i);
      pg_devices[i].ntimes_open = 0;
      pg_devices[i].mmap_mode = MMAP_REG_PIORW;
      strcpy(pg_devices[i].fpga_info, "no bitfile loaded");
    }
  } // ---------------------------- about char dev


  { // ---------------------------- about kernel pci core
    int i;
    result = pci_register_driver(&pci_driver); // This function calls pg_pci_probe()
    if(result<0){
      PDEBUG("failed to pci_register_driver %d\n",result);
      goto init_fail;
    }
    if(pg_nr_pci_devs ==1) PDEBUG("Kernel found 1 device.\n");
    if(pg_nr_pci_devs > 1) PDEBUG("Kernel found %d devices.\n", pg_nr_devs);

    for(i=0;i<pg_nr_pci_devs;i++){
      PDEBUG("DEV %d BAR0 = 0x%lx (%ld bytes)\n",
	     i, pg_devices[i].pci_reg_adr, pg_devices[i].pci_reg_size);
      PDEBUG("DEV %d BAR1 = 0x%lx (%ld bytes)\n",
	     i, pg_devices[i].pci_mem_adr, pg_devices[i].pci_mem_size);
    }

  } // ---------------------------- about kernel pci core

  { // ---------------------------- about DMA buffers
    int i;
    for(i=0; i<pg_nr_pci_devs; i++){
      struct pg_dev *dev = &(pg_devices[i]);
      struct page *page_ptr;
      u64 dma_mask = 0xFFFFFFFF;
      unsigned long dmabuf_size = pg_get_dmabufsize();
      int ii;

      if(  pci_set_dma_mask(dev->pcidev, dma_mask)  ){
	PDEBUG("pci_set_dma_mask() bad. %s:%d\n",__FILE__, __LINE__);
	return (-ENODEV);
      }
      _PDEBUG("DMA mask = 0x%llx.\n",dma_mask);

      if(  pci_set_consistent_dma_mask(dev->pcidev, dma_mask)  ){
	PDEBUG("pci_set_consistent_dma_mask() bad. %s:%d\n",__FILE__, __LINE__);
	return (-ENODEV);
      }
      _PDEBUG("consistent DMA mask = 0x%llx.\n",dma_mask);

      // ----------------- Buffer for DMAR 
      (dev->buf_dmar) = pci_alloc_consistent(dev->pcidev, dmabuf_size, &(dev->buf_dmar_pa));
      /* -------------------------------------------------------------------------------------
	 (dev->buf_dmar) = dma_alloc_coherent  (dev->pcidev, dmabuf_size, &(dev->buf_dmar_pa));
	 ------------------------------------------------------------------------------------- */
      if (dev->buf_dmar == NULL){
	PDEBUG("failed dma_alloc_coherent(). %s:%d\n",__FILE__, __LINE__);
	for(ii=i-1; ii>= 0; ii--){
	  struct pg_dev *x = &(pg_devices[ii]);
	  free_dmabuf(get_order(dmabuf_size), x->pcidev, x->buf_dmar, x->buf_dmar_pa);
	}
	for(ii=i-1; ii>=0; ii--){
	  struct pg_dev *x = &(pg_devices[ii]);
	  free_dmabuf(get_order(dmabuf_size), x->pcidev, x->buf_dmaw, x->buf_dmaw_pa);
	}
	return (-ENOMEM);
      }
      page_ptr = virt_to_page((unsigned long)(dev->buf_dmar));
      for(ii=1; ii<(1 << get_order(dmabuf_size)); ii++){
	set_page_count(page_ptr + ii, 1);
      }

      // ----------------- Buffer for DMAW 
      (dev->buf_dmaw) = pci_alloc_consistent(dev->pcidev, dmabuf_size, &(dev->buf_dmaw_pa));
      /* -------------------------------------------------------------------------------------
	 (dev->buf_dmaw) = dma_alloc_coherent  (dev->pcidev, dmabuf_size, &(dev->buf_dmaw_pa));
	 ------------------------------------------------------------------------------------- */
      if (dev->buf_dmaw == NULL){
	PDEBUG("failed dma_alloc_coherent(). %s:%d\n",__FILE__, __LINE__);
	for(ii=i; ii>=0; ii--){
	  struct pg_dev *x = &(pg_devices[ii]);
	  free_dmabuf(get_order(dmabuf_size), x->pcidev, x->buf_dmar, x->buf_dmar_pa);
	}
	for (ii = i-1; ii >= 0; ii--) {
	  struct pg_dev *x = &(pg_devices[ii]);
	  free_dmabuf(get_order(dmabuf_size), x->pcidev, x->buf_dmaw, x->buf_dmaw_pa);
	}
	return (-ENOMEM);
      }
      page_ptr = virt_to_page((unsigned long)(dev->buf_dmaw));
      for (ii = 1; ii < (1 << get_order(dmabuf_size)); ii++) {
	set_page_count(page_ptr + ii, 1);
      }

      PDEBUG("Alloc DMAW buf (va 0x%08lx),(pa 0x%08lx),(size %ld KB)\n",
	     (unsigned long)dev->buf_dmaw, (unsigned long)dev->buf_dmaw_pa, dmabuf_size/1024);

      PDEBUG("Alloc DMAR buf (va 0x%08lx),(pa 0x%08lx),(size %ld KB)\n",
	     (unsigned long)dev->buf_dmar, (unsigned long)dev->buf_dmar_pa, dmabuf_size/1024);


      { // Initialize buffers for DMA-W and DMA-R
	int i;
	for(i=0;i<(dmabuf_size>>2);i++){
	  dev->buf_dmaw[i] = 0x10000002;
	  dev->buf_dmar[i] = 0x69696969;
	}
	dev->buf_dmaw[(dmabuf_size>>2)-1] = 0xCCCC9999;
      }


    }
  } // ---------------------------- about DMA buffer

  if(PG_PCITRANS_64BIT){
    PDEBUG("module loaded with PCI Trans 64-bit.\n");
  }else{
    PDEBUG("module loaded with PCI Trans 32-bit.\n");
  }
  return (0); // 0 : succeed

  // --- if any fails ---
 init_fail:
  pg_cleanup_module();
  return (result);
}

MODULE_AUTHOR("Tsuyoshi Hamada");
MODULE_LICENSE("Dual BSD/GPL");

module_init(pg_init_module);
module_exit(pg_cleanup_module);
