////////////////////////////////////// ADDRESS OF IFPGA REGISTERS
#define PIPE_DMA_STAT      0x0   // gpreg0(0) : pipe calc sts | available but not used in api
#define PIPE_RST           0x4
#define CNF_CMD_ADR       0x80
#define CNF_DAT_ADR       0x84
#define PIPE_DMA_WRITE    0x88   // unused
#define PIPE_DMA_READ     0x8C   // unused
#define NPIPE_IFPGA       0x8C  // PGPG_REG3 @ ifpga.vhd

/********************************************************************
 * PIPE_DMA_WRITE (31 downto 28) : pfpga chip select
 *       "        (27 downto 19) : num of 64-bit WARD
 *       "        (18 downto  0) : offset of pfpga address
 *
 * PIPE_DMA_READ  (31 downto 28) : pfpga chip select
 *       "        (27 downto 19) : num of 64-bit WARD
 *       "        (18 downto  0) : offset of pfpga address
 ********************************************************************/

/*****************************************************
0x5000 - 0x501f : i 0
0x5020 - 0x503f : i 1
0x5040 - 0x505f : i 2
0x5060 - 0x507f : i 3
0x5080 - 0x5fff : -- none --

0x6000 - 0x60ff : f 0
0x6100 - 0x61ff : f 1
0x6200 - 0x62ff : f 2
0x6300 - 0x63ff : f 3
0x6400 - 0x6fff : -- none --

0x7000          : set n
0x7001          : run

0x40000 -       : j
********************************************/
#define ADR_IPSET 0x5000
#define ADR_FOSET 0x6000
#define ADR_SETN  0x7000
#define ADR_RUN   0x7008

#define ADR_JPSET 0x40000
