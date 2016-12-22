-- Copyright(C) 2004 - Tsuyoshi Hamada
-- 2004/12/26 MEM_ADA : 14bit(64KB)->17bit(512KB)
-- 2004/12/02 MEM_ADA : 10bit(4KB) ->14bit(64KB)

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;


entity pcicnt is
  port (
  -- Interface to PCI Logicore.
        FRAMEQ_N        : in    std_logic;               -- Latched FRAME# Signal
        REQ64Q_N        : in    std_logic;               -- Latched REQ64# Signal
        TRDYQ_N         : in    std_logic;               -- Latched TRDY# Signal
        IRDYQ_N         : in    std_logic;               -- Latched IRDY# Signal
        STOPQ_N         : in    std_logic;               -- Latched STOP# Signal
        DEVSELQ_N       : in    std_logic;               -- Latched DEVSEL# Signal
        ACK64Q_N        : in    std_logic;               -- Latched ACK64# Signal

        ADDR            : in    std_logic_vector( 31 downto 0);    -- Latched Target Address Bus
        ADIO            : inout std_logic_vector( 63 downto 0);    -- Internal Address/Data Bus

        CFG_VLD         : in    std_logic;               -- Configulation Cycle Valid
        CFG_HIT         : in    std_logic;               -- Configuration Cycle Start
        C_TERM          : out   std_logic;               -- Configuraton Cycle Terminate Signal
        C_READY         : out   std_logic;               -- Configuration Data Transfer Ready Signal

        ADDR_VLD        : in    std_logic;               -- Internal Address Valid
        BASE_HIT        : in    std_logic_vector(  7 downto 0);    -- Base Address Hit

        S_CYCLE64       : in    std_logic;               -- 64 bit Transaction Go On
        S_TERM          : out   std_logic;               -- Target Transaction Terminate Signal
        S_READY         : out   std_logic;               -- Target Transaction Data Transfer Ready Siganl
        S_ABORT         : out   std_logic;               -- Target Abort Request Signal
        S_WRDN          : in    std_logic;               -- Target Transaction Data Direction (0:Write, 1:Read)
        S_SRC_EN        : in    std_logic;               -- Target Transaction Data Source Enable
        S_DATA_VLD      : in    std_logic;               -- Target Transaction Data Phase Valid Signal
        S_CBE           : in    std_logic_vector(  7 downto 0);    -- Target Command & Byte Enable Signal
        PCI_CMD         : in    std_logic_vector( 15 downto 0);    -- Latched Bus Command

        REQUEST         : out   std_logic;               -- REQ# Signal Assert Request
        REQUEST64       : out   std_logic;               -- REQ64# Signal Assert Request
        REQUESTHOLD     : out   std_logic;               -- Extended REQ# Signal Assert Request (Not Use)
        COMPLETE        : out   std_logic;               -- Initiator Transaction End Signal

        M_WRDN          : out   std_logic;               -- Initiator Transaction Data Direction (0:Write, 1:Read)
        M_READY         : out   std_logic;               -- Initiator Transaction Data Transfer Ready Siganl
        M_SRC_EN        : in    std_logic;               -- Initiator Transaction Data Source Enable
        M_DATA_VLD      : in    std_logic;               -- Initiator Transaction Data Phase Valid Signal
        M_CBE           : out   std_logic_vector(  7 downto 0);    -- Initiator Command & Byte Enable Signal

        TIME_OUT        : in    std_logic;               -- Latency Timer Timeout Signal
        M_FAIL64        : in    std_logic;               -- 64 bit Transaction Fail Signal
        CFG_SELF        : out   std_logic;               -- Self Configuration Start Signal

        M_DATA          : in    std_logic;               -- Data Transfer State
        DR_BUS          : in    std_logic;               -- Bus Park State
        I_IDLE          : in    std_logic;               -- Initiator Idle State
        M_ADDR_N        : in    std_logic;               -- Initiator Address State
        IDLE            : in    std_logic;               -- Target Idle State
        B_BUSY          : in    std_logic;               -- PCI Bus Busy State
        S_DATA          : in    std_logic;               -- Target Data Transfer State
        BACKOFF         : in    std_logic;               -- Target State Machine Transaction End State

        SLOT64          : out   std_logic;               -- 64 bit Extended Signal Eable
        INTR_N          : out   std_logic;               -- Interrupt Request
        PERRQ_N         : in    std_logic;               -- latched PERR# Signal
        SERRQ_N         : in    std_logic;               -- Latched SERR# Signal
        KEEPOUT         : out   std_logic;               -- ADIO Bus Disable Request Signal

        CSR             : in    std_logic_vector( 39 downto 0);    -- Command/Status Register State
        SUB_DATA        : out   std_logic_vector( 31 downto 0);    -- Sub-Identification
        CFG             : in    std_logic_vector(255 downto 0);    -- Confiuration Data

        RST             : in    std_logic;               -- PCI Bus Reset
        CLK             : in    std_logic;               -- PCI bus Clock

  -- Internal Register Access Control Signal
    REG_AD      : out  std_logic_vector( 7 downto 0);    -- REGCNT R/W Address
    REG_WE      : out  std_logic;                        -- REGCNT Write Enable
    REG_RE      : out  std_logic;                        -- REGCNT Read Enable
    REG_DTI     : out  std_logic_vector(31 downto 0);    -- REGCNT Write Data
    REG_DTO     : in  std_logic_vector(31 downto 0);     -- REGCNT Read Data
    REG_DTOEN   : in  std_logic;                         -- REGCNT Read Data Enable

  -- Internal Memory Access Control Signal
    -- PCI R/W ports
    MEM_ADA     : out  std_logic_vector(19 downto 0);    -- DPRAM Port A R/W Address
    MEM_WEHA    : out  std_logic;                        -- DPRAM Port A Write Enable (High Word)
    MEM_WELA    : out  std_logic;                        -- DPRAM Port A Write Enable (Low  Word)
    MEM_REA     : out  std_logic;                        -- DPRAM Port A Read Enable
    MEM_DTIA    : out  std_logic_vector(63 downto 0);    -- DPRAM Port A Write Data
    MEM_DTOA    : in  std_logic_vector(63 downto 0);     -- DPRAM Port A Read Data
    MEM_DTOEN   : in  std_logic;                         -- DPRAM Port A Read Data Enable

    DMAEND_INT  : out  std_logic;                        -- DMA End Interrupt On Request
    INT_REQ     : in  std_logic;                         -- PCI Interrupt On Request

--################################
--##    for Debug
--################################
    DEBUG_OUT    : out  std_logic_vector( 7 downto 0)
  );
end pcicnt;


architecture pcicnt_rtl of pcicnt is

--------------------------------------------------
-- Components
--------------------------------------------------

component PCI_TARGETCNT
  port (
  -- Interface to PCI Logicore.
        FRAMEQ_N        : in    std_logic;              -- Latched FRAME# Signal
        REQ64Q_N        : in    std_logic;              -- Latched REQ64# Signal
        TRDYQ_N         : in    std_logic;              -- Latched TRDY# Signal
        IRDYQ_N         : in    std_logic;              -- Latched IRDY# Signal
        STOPQ_N         : in    std_logic;              -- Latched STOP# Signal
        DEVSELQ_N       : in    std_logic;              -- Latched DEVSEL# Signal
        ACK64Q_N        : in    std_logic;              -- Latched ACK64# Signal

        ADDR            : in    std_logic_vector( 31 downto 0);    -- Latched Target Address Bus
        ADIO            : inout std_logic_vector( 63 downto 0);    -- Internal Address/Data Bus

        CFG_VLD         : in    std_logic;              -- Configulation Cycle Valid
        CFG_HIT         : in    std_logic;              -- Configuration Cycle Start
        C_TERM          : out   std_logic;              -- Configuraton Cycle Terminate Signal
        C_READY         : out   std_logic;              -- Configuration Data Transfer Ready Signal

        ADDR_VLD        : in    std_logic;              -- Internal Address Valid
        BASE_HIT        : in    std_logic_vector(  7 downto 0);    -- Base Address Hit

        S_CYCLE64       : in    std_logic;              -- 64 bit Transaction Go On
        S_TERM          : out   std_logic;              -- Target Transaction Terminate Signal
        S_READY         : out   std_logic;              -- Target Transaction Data Transfer Ready Siganl
        S_ABORT         : out   std_logic;              -- Target Abort Request Signal
        S_WRDN          : in    std_logic;              -- Target Transaction Data Direction (0:Write, 1:Read)
        S_SRC_EN        : in    std_logic;              -- Target Transaction Data Source Enable
        S_DATA_VLD      : in    std_logic;              -- Target Transaction Data Phase Valid Signal
        S_CBE           : in    std_logic_vector(  7 downto 0);    -- Target Command & Byte Enable Signal
        PCI_CMD         : in    std_logic_vector( 15 downto 0);    -- Latched Bus Command

        IDLE            : in    std_logic;              -- Target Idle State
        B_BUSY          : in    std_logic;              -- PCI Bus Busy State
        S_DATA          : in    std_logic;              -- Target Data Transfer State
        BACKOFF         : in    std_logic;              -- Target State Machine Transaction End State

        SLOT64          : out   std_logic;              -- 64 bit Extended Signal Eable
        PERRQ_N         : in    std_logic;              -- latched PERR# Signal
        SERRQ_N         : in    std_logic;              -- Latched SERR# Signal
        KEEPOUT         : out   std_logic;              -- ADIO Bus Disable Request Signal

        CSR             : in    std_logic_vector( 39 downto 0);    -- Command/Status Register State
        SUB_DATA        : out   std_logic_vector( 31 downto 0);    -- Sub-Identification
        CFG             : in    std_logic_vector(255 downto 0);    -- Confiuration Data

        RST             : in    std_logic;              -- PCI Bus Reset
        CLK             : in    std_logic;              -- PCI bus Clock

  -- Internal Block Target Access Control Signal
    TARGET_AD    : out  std_logic_vector(31 downto 0);    -- Target Access Address

    FIFO_RDDT    : in  std_logic_vector(63 downto 0);    -- FIFO Read Data
    FIFO_RDTEN    : in  std_logic;              -- FIFO Read Data Enable Signel

  -- Base Address 0 Area (Internal Register) Target Access Control Signal
    BAR0_WRDT    : out  std_logic_vector(31 downto 0);    -- BAR0 Area Target Access Write Data
    BAR0_WR      : out  std_logic_vector( 3 downto 0);    -- BAR0 Area Target Access Write Signal
    BAR0_RD      : out  std_logic;              -- BAR0 Area Target Access Read  Signal

  -- Base Address 1 Area (Internal Memoery) Target Access Control Signal
    BAR1_WRDT    : out  std_logic_vector(63 downto 0);    -- BAR1 Area Target Access Write Data
    BAR1_WR      : out  std_logic_vector( 7 downto 0);    -- BAR1 Area Target Access Write Signal
    BAR1_RD      : out  std_logic              -- BAR1 Area Target Access Read  Signal
    );
end component;


component PCI_DMACNT
  port (
    RST       : in  std_logic;              -- PCI Bus Reset
    CLK       : in  std_logic;              -- PCI bus Clock

    FRAMEQ_N    : in  std_logic;              -- Latched FRAME# Signal
    REQ64Q_N    : in  std_logic;              -- Latched REQ64# Signal
    TRDYQ_N     : in  std_logic;              -- Latched TRDY# Signal
    IRDYQ_N     : in  std_logic;              -- Latched IRDY# Signal
    STOPQ_N     : in  std_logic;              -- Latched STOP# Signal
    DEVSELQ_N    : in  std_logic;              -- Latched DEVSEL# Signal
    ACK64Q_N    : in  std_logic;              -- Latched ACK64# Signal

    ADIO      : inout std_logic_vector( 63 downto 0);    -- Internal Address/Data Bus

    REQUEST     : out  std_logic;              -- REQ# Signal Assert Request
    REQUEST64    : out  std_logic;              -- REQ64# Signal Assert Request
    REQUESTHOLD   : out  std_logic;              -- Extended REQ# Signal Assert Request (Not Use)
    COMPLETE    : out  std_logic;              -- Initiator Transaction End Signal

    M_WRDN      : out  std_logic;              -- Initiator Transaction Data Direction (0:Write, 1:Read)
    M_READY     : out  std_logic;              -- Initiator Transaction Data Transfer Ready Siganl
    M_SRC_EN    : in  std_logic;              -- Initiator Transaction Data Source Enable
    M_DATA_VLD    : in  std_logic;              -- Initiator Transaction Data Phase Valid Signal
    M_CBE      : out  std_logic_vector(  7 downto 0);    -- Initiator Command & Byte Enable Signal

    TIME_OUT    : in  std_logic;              -- Latency Timer Timeout Signal
    M_FAIL64    : in  std_logic;              -- 64 bit Transaction Fail Signal
    CFG_SELF    : out  std_logic;              -- Self Configuration Start Signal

    M_DATA      : in  std_logic;              -- Data Transfer State
    DR_BUS      : in  std_logic;              -- Bus Park State
    I_IDLE      : in  std_logic;              -- Initiator Idle State
    M_ADDR_N    : in  std_logic;              -- Initiator Address State

    PERRQ_N     : in  std_logic;              -- latched PERR# Signal
    SERRQ_N     : in  std_logic;              -- Latched SERR# Signal

    CSR       : in  std_logic_vector( 39 downto 0);    -- Command/Status Register State
    CFG       : in  std_logic_vector(255 downto 0);    -- Confiuration Data

  -- DMA Register R/W ports
    DMAREG_AD    : in  std_logic_vector( 7 downto 0);    -- PCI_DMACNT R/W Address
    DMAREG_WE    : in  std_logic;              -- PCI_DMACNT Write Enable
    DMAREG_RE    : in  std_logic;              -- PCI_DMACNT Read Enable
    DMAREG_DTI    : in  std_logic_vector(31 downto 0);    -- PCI_DMACNT Write Data
    DMAREG_DTO    : out  std_logic_vector(31 downto 0);    -- PCI_DMACNT Read Data
    DMAREG_DTOEN  : out  std_logic;              -- PCI_DMACNT Read Data Enable

  -- Internal DMA Access Control Signal
    DMA_ADRS    : out  std_logic_vector(31 downto 0);    -- Internal Memory DMA Access Address

    DMA_WRDT    : out  std_logic_vector(63 downto 0);    -- Internal Memory DMA Access Write Data
    DMA_WRT      : out  std_logic_vector( 7 downto 0);    -- Internal Memory DMA Access Write Signal
    DMA_READ    : out  std_logic;              -- Internal Memory DMA Access Read  Signal

    FIFO_RDDT    : in  std_logic_vector(63 downto 0);    -- FIFO Read Data
    FIFO_RDTEN    : in  std_logic;              -- FIFO Read Data Enable Signel

    DMATRNS_ENB    : out  std_logic;              -- PCI DMA Transfer Enable

    DMAEND_INT    : out  std_logic;                -- DMA End Interrupt On Request



--################################
--##    for Debug
--################################


    DEBUG_OUT    : out  std_logic_vector( 7 downto 0)



    );
end component;


component PCI_RDTFIFO
  port (
    RST       : in  std_logic;              -- PCI Bus Reset
    CLK       : in  std_logic;              -- PCI bus Clock

    FIFO_ENB    : in  std_logic;              -- FIFO Enable Signal

  -- FIFO Data Write ports
    FIFO_WRDT    : in  std_logic_vector(63 downto 0);    -- FIFO Write Data
    FIFO_WE      : in  std_logic;                -- FIFO Write Enable

  -- FIFO Data Read ports
    FIFO_RE      : in  std_logic;              -- FIFO Read Enable
    FIFO_RDDT    : out  std_logic_vector(63 downto 0);    -- FIFO Read Data
    FIFO_RDTEN    : out  std_logic              -- FIFO Read Data Enable
    );
end component;


--------------------------------------------------
-- signals
--------------------------------------------------

  -- Internal Block Target Access Control Signal
  signal  TARGET_AD    : std_logic_vector(31 downto 0);    -- Target Access Address

  -- Base Address 0 Area (Internal Register) Target Access Control Signal
  signal  BAR0_WRDT    : std_logic_vector(31 downto 0);    -- BAR0 Area Target Access Write Data
  signal  BAR0_WR      : std_logic_vector( 3 downto 0);    -- BAR0 Area Target Access Write Signal
  signal  BAR0_RD      : std_logic;              -- BAR0 Area Target Access Read  Signal

  -- Base Address 1 Area (Internal Memoery) Target Access Control Signal
  signal  BAR1_WRDT    : std_logic_vector(63 downto 0);    -- BAR1 Area Target Access Write Data
  signal  BAR1_WR      : std_logic_vector( 7 downto 0);    -- BAR1 Area Target Access Write Signal
  signal  BAR1_RD      : std_logic;              -- BAR1 Area Target Access Read  Signal

  -- DMA Register R/W ports
  signal  DMAREG_AD    : std_logic_vector( 7 downto 0);    -- PCI_DMACNT R/W Address
  signal  DMAREG_WE    : std_logic;              -- PCI_DMACNT Write Enable
  signal  DMAREG_RE    : std_logic;              -- PCI_DMACNT Read Enable
  signal  DMAREG_DTI    : std_logic_vector(31 downto 0);    -- PCI_DMACNT Write Data
  signal  DMAREG_DTO    : std_logic_vector(31 downto 0);    -- PCI_DMACNT Read Data
  signal  DMAREG_DTOEN  : std_logic;              -- PCI_DMACNT Read Data Enable

  -- Internal DMA Access Control Signal
  signal  DMA_ADRS    : std_logic_vector(31 downto 0);    -- Internal Memory DMA Access Address

  signal  DMA_WRDT    : std_logic_vector(63 downto 0);    -- Internal Memory DMA Access Write Data
  signal  DMA_WRT      : std_logic_vector( 7 downto 0);    -- Internal Memory DMA Access Write Signal
  signal  DMA_READ    : std_logic;              -- Internal Memory DMA Access Read  Signal

  signal  DMATRNS_ENB    : std_logic;              -- PCI DMA Transfer Enable

  -- FIFO Control Signal
  signal  FIFO_ENB    : std_logic;              -- FIFO Enable Signal

  -- FIFO Data Write ports
  signal  FIFO_WRDT    : std_logic_vector(63 downto 0);    -- FIFO Write Data
  signal  FIFO_WE      : std_logic;                -- FIFO Write Enable

  -- FIFO Data Read ports
  signal  FIFO_RE      : std_logic;              -- FIFO Read Enable
  signal  FIFO_RDDT    : std_logic_vector(63 downto 0);    -- FIFO Read Data
  signal  FIFO_RDTEN    : std_logic;              -- FIFO Read Data Enable


begin

--***************************************************************
--* instantiate sub-blocks
--***************************************************************

  u0 : PCI_TARGETCNT port map (
  -- Interface to PCI Logicore.
    FRAMEQ_N    =>  FRAMEQ_N,                -- Latched FRAME# Signal
    REQ64Q_N    =>  REQ64Q_N,                -- Latched REQ64# Signal
    TRDYQ_N     =>  TRDYQ_N,                -- Latched TRDY# Signal
    IRDYQ_N     =>  IRDYQ_N,                -- Latched IRDY# Signal
    STOPQ_N     =>  STOPQ_N,                -- Latched STOP# Signal
    DEVSELQ_N    =>  DEVSELQ_N,                -- Latched DEVSEL# Signal
    ACK64Q_N    =>  ACK64Q_N,                -- Latched ACK64# Signal

    ADDR      =>  ADDR,                  -- Latched Target Address Bus
    ADIO      =>  ADIO,                  -- Internal Address/Data Bus

    CFG_VLD     =>  CFG_VLD,                -- Configulation Cycle Valid
    CFG_HIT     =>  CFG_HIT,                -- Configuration Cycle Start
    C_TERM      =>  C_TERM,                  -- Configuraton Cycle Terminate Signal
    C_READY     =>  C_READY,                -- Configuration Data Transfer Ready Signal

    ADDR_VLD    =>  ADDR_VLD,                -- Internal Address Valid
    BASE_HIT    =>  BASE_HIT,                -- Base Address Hit

    S_CYCLE64    =>  S_CYCLE64,                -- 64 bit Transaction Go On
    S_TERM      =>  S_TERM,                  -- Target Transaction Terminate Signal
    S_READY     =>  S_READY,                -- Target Transaction Data Transfer Ready Siganl
    S_ABORT     =>  S_ABORT,                -- Target Abort Request Signal
    S_WRDN      =>  S_WRDN,                  -- Target Transaction Data Direction (0:Write, 1:Read)
    S_SRC_EN    =>  S_SRC_EN,                -- Target Transaction Data Source Enable
    S_DATA_VLD    =>  S_DATA_VLD,                -- Target Transaction Data Phase Valid Signal
    S_CBE      =>  S_CBE,                  -- Target Command & Byte Enable Signal
    PCI_CMD     =>  PCI_CMD,                -- Latched Bus Command

    IDLE      =>  IDLE,                  -- Target Idle State
    B_BUSY      =>  B_BUSY,                  -- PCI Bus Busy State
    S_DATA      =>  S_DATA,                  -- Target Data Transfer State
    BACKOFF     =>  BACKOFF,                -- Target State Machine Transaction End State

    SLOT64      =>  SLOT64,                  -- 64 bit Extended Signal Eable
    PERRQ_N     =>  PERRQ_N,                -- latched PERR# Signal
    SERRQ_N     =>  SERRQ_N,                -- Latched SERR# Signal
    KEEPOUT     =>  KEEPOUT,                -- ADIO Bus Disable Request Signal

    CSR       =>  CSR,                  -- Command/Status Register State
    SUB_DATA    =>  SUB_DATA,                -- Sub-Identification
    CFG       =>  CFG,                  -- Confiuration Data

    RST       =>  RST,                  -- PCI Bus Reset
    CLK       =>  CLK,                  -- PCI bus Clock

  -- Internal Block Target Access Control Signal
    TARGET_AD    =>  TARGET_AD,                -- Target Access Address

    FIFO_RDDT    =>  FIFO_RDDT,                -- FIFO Read Data
    FIFO_RDTEN    =>  FIFO_RDTEN,                -- FIFO Read Data Enable Signel

  -- Base Address 0 Area (Internal Register) Target Access Control Signal
    BAR0_WRDT    =>  BAR0_WRDT,                -- BAR0 Area Target Access Write Data
    BAR0_WR      =>  BAR0_WR,                -- BAR0 Area Target Access Write Signal
    BAR0_RD      =>  BAR0_RD,                -- BAR0 Area Target Access Read  Signal

  -- Base Address 1 Area (Internal Memoery) Target Access Control Signal
    BAR1_WRDT    =>  BAR1_WRDT,                -- BAR1 Area Target Access Write Data
    BAR1_WR      =>  BAR1_WR,                -- BAR1 Area Target Access Write Signal
    BAR1_RD      =>  BAR1_RD                  -- BAR1 Area Target Access Read  Signal
    );


  u1 : PCI_RDTFIFO port map (
    RST       =>  RST,                  -- PCI Bus Reset
    CLK       =>  CLK,                  -- PCI bus Clock

    FIFO_ENB    =>  FIFO_ENB,                -- FIFO Enable Signal

  -- FIFO Data Write ports
    FIFO_WRDT    =>  FIFO_WRDT,                -- FIFO Write Data
    FIFO_WE      =>  FIFO_WE,                -- FIFO Write Enable

  -- FIFO Data Read ports
    FIFO_RE      =>  FIFO_RE,                -- FIFO Read Enable
    FIFO_RDDT    =>  FIFO_RDDT,                -- FIFO Read Data
    FIFO_RDTEN    =>  FIFO_RDTEN                -- FIFO Read Data Enable
    );


  u2 : PCI_DMACNT port map (
    RST       =>  RST,                  -- PCI Bus Reset
    CLK       =>  CLK,                  -- PCI bus Clock

    FRAMEQ_N    =>  FRAMEQ_N,                -- Latched FRAME# Signal
    REQ64Q_N    =>  REQ64Q_N,                -- Latched REQ64# Signal
    TRDYQ_N     =>  TRDYQ_N,                -- Latched TRDY# Signal
    IRDYQ_N     =>  IRDYQ_N,                -- Latched IRDY# Signal
    STOPQ_N     =>  STOPQ_N,                -- Latched STOP# Signal
    DEVSELQ_N    =>  DEVSELQ_N,                -- Latched DEVSEL# Signal
    ACK64Q_N    =>  ACK64Q_N,                -- Latched ACK64# Signal

    ADIO      =>  ADIO,                  -- Internal Address/Data Bus

    REQUEST     =>  REQUEST,                -- REQ# Signal Assert Request
    REQUEST64    =>  REQUEST64,                -- REQ64# Signal Assert Request
    REQUESTHOLD   =>  REQUESTHOLD,              -- Extended REQ# Signal Assert Request (Not Use)
    COMPLETE    =>  COMPLETE,                -- Initiator Transaction End Signal

    M_WRDN      =>  M_WRDN,                  -- Initiator Transaction Data Direction (0:Write, 1:Read)
    M_READY     =>  M_READY,                -- Initiator Transaction Data Transfer Ready Siganl
    M_SRC_EN    =>  M_SRC_EN,                -- Initiator Transaction Data Source Enable
    M_DATA_VLD    =>  M_DATA_VLD,                -- Initiator Transaction Data Phase Valid Signal
    M_CBE      =>  M_CBE,                  -- Initiator Command & Byte Enable Signal

    TIME_OUT    =>  TIME_OUT,                -- Latency Timer Timeout Signal
    M_FAIL64    =>  M_FAIL64,                -- 64 bit Transaction Fail Signal
    CFG_SELF    =>  CFG_SELF,                -- Self Configuration Start Signal

    M_DATA      =>  M_DATA,                  -- Data Transfer State
    DR_BUS      =>  DR_BUS,                  -- Bus Park State
    I_IDLE      =>  I_IDLE,                  -- Initiator Idle State
    M_ADDR_N    =>  M_ADDR_N,                -- Initiator Address State

    PERRQ_N     =>  PERRQ_N,                -- latched PERR# Signal
    SERRQ_N     =>  SERRQ_N,                -- Latched SERR# Signal

    CSR       =>  CSR,                  -- Command/Status Register State
    CFG       =>  CFG,                  -- Confiuration Data

  -- DMA Register R/W ports
    DMAREG_AD    =>  DMAREG_AD,                -- PCI_DMACNT R/W Address
    DMAREG_WE    =>  DMAREG_WE,                -- PCI_DMACNT Write Enable
    DMAREG_RE    =>  DMAREG_RE,                -- PCI_DMACNT Read Enable
    DMAREG_DTI    =>  DMAREG_DTI,                -- PCI_DMACNT Write Data
    DMAREG_DTO    =>  DMAREG_DTO,                -- PCI_DMACNT Read Data
    DMAREG_DTOEN  =>  DMAREG_DTOEN,              -- PCI_DMACNT Read Data Enable

  -- Internal DMA Access Control Signal
    DMA_ADRS    =>  DMA_ADRS,                -- Internal Memory DMA Access Address

    DMA_WRDT    =>  DMA_WRDT,                -- Internal Memory DMA Access Write Data
    DMA_WRT      =>  DMA_WRT,                -- Internal Memory DMA Access Write Signal
    DMA_READ    =>  DMA_READ,                -- Internal Memory DMA Access Read  Signal

    FIFO_RDDT    =>  FIFO_RDDT,                -- FIFO Read Data
    FIFO_RDTEN    =>  FIFO_RDTEN,                -- FIFO Read Data Enable Signel

    DMATRNS_ENB    =>  DMATRNS_ENB,              -- PCI DMA Transfer Enable

    DMAEND_INT    =>  DMAEND_INT,                -- DMA End Interrupt On Request



--################################
--##    for Debug
--################################



    DEBUG_OUT    =>  DEBUG_OUT                -- DMA End Interrupt On Request
    );





--***************************************************************
--*
--*  Internal Register (BAR0) Area Access Signal Control Block
--*
--***************************************************************

--------------------------------------------------------------------------------
-- Internal Register (BAR0) Area Address Output Control Process
--------------------------------------------------------------------------------

  process (RST,CLK) begin
    if (RST='1') then
      DMAREG_AD <= (others=>'0');
    elsif (CLK'event and CLK='1') then
      DMAREG_AD <= TARGET_AD( 7 downto 0);              ------ Target Access Address Output
    end if;
  end process;

    REG_AD <= DMAREG_AD;

--------------------------------------------------------------------------------
-- Internal Register (BAR0) Area Write Enable Signal Output Control Process
--------------------------------------------------------------------------------

  process (RST,CLK) begin
    if (RST='1') then
      DMAREG_WE <= '0';
    elsif (CLK'event and CLK='1') then
      DMAREG_WE <= BAR0_WR(3) or BAR0_WR(2) or BAR0_WR(1) or BAR0_WR(0);  -- Low Word Write Enable Set
    end if;
  end process;

    REG_WE <= DMAREG_WE;

--------------------------------------------------------------------------------
-- Internal Register (BAR0) Area Write Data Output Control Process
--------------------------------------------------------------------------------

  process (RST,CLK) begin
    if (RST='1') then
      DMAREG_DTI <= (others=>'0');
    elsif (CLK'event and CLK='1') then
      if (BAR0_WR/="0000") then                    ------ BAR0 Area Data Write ?
        DMAREG_DTI <= BAR0_WRDT;                  ------ Write Data Output
      else
        DMAREG_DTI <= (others=>'0');
      end if;
    end if;
  end process;

    REG_DTI <= DMAREG_DTI;                        ------ Write Data Output

--------------------------------------------------------------------------------
-- Internal Register (BAR0) Area Read Enable Signal Output Control Process
--------------------------------------------------------------------------------

  process (RST,CLK) begin
    if (RST='1') then
      DMAREG_RE <= '0';
    elsif (CLK'event and CLK='1') then
      DMAREG_RE <= BAR0_RD;                        ------ BAR0 Area Data Read Signal Set
    end if;
  end process;

    REG_RE <= DMAREG_RE;


--***************************************************************
--*
--*  Internal Memory (BAR1) Area Access Signal Control Block
--*
--***************************************************************

--------------------------------------------------------------------------------
-- Internal Memory (BAR1) Area Address Output Control Process
--------------------------------------------------------------------------------

  process (RST,CLK) begin
    if (RST='1') then
      MEM_ADA <= (others=>'0');
    elsif (CLK'event and CLK='1') then
      if (DMATRNS_ENB='1') then                    ------ DMA Access ?
        MEM_ADA <= DMA_ADRS(21 downto 2);          ------ DMA Access Address Output
      else
        MEM_ADA <= TARGET_AD(21 downto 2);         ------ Target Access Address Output
      end if;
    end if;
  end process;

--------------------------------------------------------------------------------
-- Internal Memory (BAR1) Area Write Enable Signal Output Control Process
--------------------------------------------------------------------------------

  process (RST,CLK) begin
    if (RST='1') then
      MEM_WEHA <= '0';
      MEM_WELA <= '0';
    elsif (CLK'event and CLK='1') then
      if (DMATRNS_ENB='1') then                        -- DMA Access ?
        MEM_WEHA <= DMA_WRT(7) or DMA_WRT(6) or DMA_WRT(5) or DMA_WRT(4);  -- High Word Write Enable Set
        MEM_WELA <= DMA_WRT(3) or DMA_WRT(2) or DMA_WRT(1) or DMA_WRT(0);  -- Low  Word Write Enable Set
      else
        MEM_WEHA <= BAR1_WR(7) or BAR1_WR(6) or BAR1_WR(5) or BAR1_WR(4);  -- High Word Write Enable Set
        MEM_WELA <= BAR1_WR(3) or BAR1_WR(2) or BAR1_WR(1) or BAR1_WR(0);  -- Low  Word Write Enable Set
      end if;
    end if;
  end process;

--------------------------------------------------------------------------------
-- Internal Memory (BAR1) Area Write Data Output Control Process
--------------------------------------------------------------------------------

  process (RST,CLK) begin
    if (RST='1') then
      MEM_DTIA <= (others=>'0');
    elsif (CLK'event and CLK='1') then
      if (DMATRNS_ENB='1') then                    ------ DMA Access ?
        MEM_DTIA <= DMA_WRDT;                    ------ DMA Write Data Output
      elsif (BAR1_WR/="00000000") then                ------ BAR1 Area Data Write ?
        MEM_DTIA <= BAR1_WRDT;                    ------ Traget Access Write Data Output
      else
        MEM_DTIA <= (others=>'0');
      end if;
    end if;
  end process;

--------------------------------------------------------------------------------
-- Internal Memory (BAR1) Area Read Enable Signal Output Control Process
--------------------------------------------------------------------------------

  process (RST,CLK) begin
    if (RST='1') then
      MEM_REA <= '0';
    elsif (CLK'event and CLK='1') then
      MEM_REA <= BAR1_RD or DMA_READ;                  ------ Memory Read Signal Set
    end if;
  end process;


--***************************************************************
--*
--*  Data Read FIFO Control Block
--*
--***************************************************************

--------------------------------------------------------------------------------
-- FIFO Enable Signal Output Control Process
--------------------------------------------------------------------------------

    FIFO_ENB <= S_DATA or M_DATA or DMATRNS_ENB;            ------ PCI Data Phase Set

--------------------------------------------------------------------------------
-- FIFO Write Data Select Control Process
--------------------------------------------------------------------------------

  process (MEM_DTOEN,MEM_DTOA,REG_DTOEN,REG_DTO,
                DMAREG_DTOEN,DMAREG_DTO) begin
    if (DMAREG_DTOEN='1') then                      ------ BAR0 DMA Register Read Data Available ?
      FIFO_WRDT(31 downto  0) <= DMAREG_DTO;              ------ BAR0 DMA Register Read Data Select
      FIFO_WRDT(63 downto 32) <= (others=>'0');            ------ BAR0 High Word Clear
    elsif (REG_DTOEN='1') then                      ------ BAR0 Register Read Data Available ?
      FIFO_WRDT(31 downto  0) <= REG_DTO;                ------ BAR0 Register Read Data Select
      FIFO_WRDT(63 downto 32) <= (others=>'0');            ------ BAR0 High Word Clear
    elsif (MEM_DTOEN='1') then                      ------ BAR1 Memory Read Data Available ?
      FIFO_WRDT <= MEM_DTOA;                      ------ BAR1 Memory Read Data Select
    else
      FIFO_WRDT <= (others=>'0');
    end if;
  end process;

--------------------------------------------------------------------------------
-- FIFO Write Enable SIgnal Control Process
--------------------------------------------------------------------------------

    FIFO_WE <= REG_DTOEN or MEM_DTOEN or DMAREG_DTOEN;

--------------------------------------------------------------------------------
-- FIFO Read Enable SIgnal Control Process
--------------------------------------------------------------------------------

    FIFO_RE <= S_SRC_EN or M_SRC_EN;



--***************************************************************
--*
--*  PCI interrupt Request Control Block
--*
--***************************************************************

--------------------------------------------------------------------------------
-- PCI Interrupt Request Output Control Process
--------------------------------------------------------------------------------

    INTR_N <= not INT_REQ;

end pcicnt_rtl;
