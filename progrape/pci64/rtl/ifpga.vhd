-- Top of the Interface FPGA
-- by Tsuyoshi Hamada (2004)

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

entity ifpga is
  port (
  -- PCI ports; do not modify names!
    AD        : inout std_logic_vector(63 downto 0);
    CBE       : inout std_logic_vector( 7 downto 0);
    PAR       : inout std_logic;
    PAR64      : inout std_logic;
    FRAME_N     : inout std_logic;
    REQ64_N     : inout std_logic;
    TRDY_N      : inout std_logic;
    IRDY_N      : inout std_logic;
    STOP_N      : inout std_logic;
    DEVSEL_N    : inout std_logic;
    ACK64_N     : inout std_logic;
    IDSEL      : in  std_logic;
    INTR_A      : out  std_logic;
    PERR_N      : inout std_logic;
    SERR_N      : inout std_logic;
    REQ_N      : out  std_logic;
    GNT_N      : in  std_logic;
    RST_N      : in  std_logic;
    PCLK      : in  std_logic;

   -- PFPGA SIDE -----------------------------------------------------
    PFPGA_RST : out std_logic_vector(3 downto 0); -- Active High
   -- DBUS
    DBUS  : inout std_logic_vector(63 downto 0);
   -- CBUS
    CBUS0 : inout std_logic_vector(7 downto 0);
    CBUS1 : inout std_logic_vector(7 downto 0);
    CBUS2 : inout std_logic_vector(7 downto 0);
    CBUS3 : inout std_logic_vector(7 downto 0);

   -- PFPGA CONFIG
    CFG_D         : out  std_logic_vector(7 downto 0);  -- DATA
    CFG_CCLK      : out  std_logic;           -- CCLK
    CFG_PROG_B0   : out  std_logic;           -- PFPGA0����PROG_B
    CFG_PROG_B1   : out  std_logic;           -- PFPGA1����PROG_B
    CFG_PROG_B2   : out  std_logic;           -- PFPGA2����PROG_B
    CFG_PROG_B3   : out  std_logic;           -- PFPGA3����PROG_B
    CFG_CS_B0     : out  std_logic;           -- PFPGA0����CS_B
    CFG_CS_B1     : out  std_logic;           -- PFPGA1����CS_B
    CFG_CS_B2     : out  std_logic;           -- PFPGA2����CS_B
    CFG_CS_B3     : out  std_logic;           -- PFPGA3����CS_B
    CFG_RDWR_B    : out  std_logic;           -- RD/WR_B
    CFG_INIT_B0   : in  std_logic;     -- PFPGA0����INIT_B
    CFG_INIT_B1   : in  std_logic;     -- PFPGA1����INIT_B
    CFG_INIT_B2   : in  std_logic;     -- PFPGA2����INIT_B
    CFG_INIT_B3   : in  std_logic;     -- PFPGA3����INIT_B


  -- PFPGA CLOCK
    CK66_IFPGA   : out std_logic; --  66MHz clock to self chip( CK66)
    CK66         : in  std_logic; --  66MHz clock from self chip(CK66_IFPGA)
    CK66_PFPGA0  : out std_logic;
    CK66_PFPGA1  : out std_logic;
    CK66_PFPGA2  : out std_logic;
    CK66_PFPGA3  : out std_logic;

  -- Add user I/O ports here
    PLED_OUT    : out  std_logic_vector(3 downto 0);  -- LED Output (LED 0..3)
    LLED_OUT    : out  std_logic_vector(3 downto 0)   -- LED Output (LED 4..7)
  );
end ifpga;


architecture rtl of ifpga is


--------------------------------------------------
-- Components
--------------------------------------------------

-- Component declaration of PCI Interface

component pcim_lc
  port (
  -- PCI ports; do not modify names!
    AD_IO      : inout std_logic_vector( 63 downto 0);
    CBE_IO      : inout std_logic_vector(  7 downto 0);
    PAR_IO      : inout std_logic;
    PAR64_IO    : inout std_logic;
    FRAME_IO    : inout std_logic;
    REQ64_IO    : inout std_logic;
    TRDY_IO     : inout std_logic;
    IRDY_IO     : inout std_logic;
    STOP_IO     : inout std_logic;
    DEVSEL_IO    : inout std_logic;
    ACK64_IO    : inout std_logic;
    IDSEL_I     : in  std_logic;
    INTA_O      : out  std_logic;
    PERR_IO     : inout std_logic;
    SERR_IO     : inout std_logic;
    REQ_O      : out  std_logic;
    GNT_I      : in  std_logic;
    RST_I      : in  std_logic;
    PCLK      : in  std_logic;
    CFG       : in  std_logic_vector(255 downto 0);
    FRAMEQ_N    : out  std_logic;
    REQ64Q_N    : out  std_logic;
    TRDYQ_N     : out  std_logic;
    IRDYQ_N     : out  std_logic;
    STOPQ_N     : out  std_logic;
    DEVSELQ_N    : out  std_logic;
    ACK64Q_N    : out  std_logic;
    ADDR      : out  std_logic_vector( 31 downto 0);
    ADIO      : inout std_logic_vector( 63 downto 0);
    CFG_VLD     : out  std_logic;
    CFG_HIT     : out  std_logic;
    C_TERM      : in  std_logic;
    C_READY     : in  std_logic;
    ADDR_VLD    : out  std_logic;
    BASE_HIT    : out  std_logic_vector(  7 downto 0);
    S_CYCLE64    : out  std_logic;
    S_TERM      : in  std_logic;
    S_READY     : in  std_logic;
    S_ABORT     : in  std_logic;
    S_WRDN      : out  std_logic;
    S_SRC_EN    : out  std_logic;
    S_DATA_VLD    : out  std_logic;
    S_CBE      : out  std_logic_vector(  7 downto 0);
    PCI_CMD     : out  std_logic_vector( 15 downto 0);
    REQUEST     : in  std_logic;
    REQUEST64    : in  std_logic;
    REQUESTHOLD   : in  std_logic;
    COMPLETE    : in  std_logic;
    M_WRDN      : in  std_logic;
    M_READY     : in  std_logic;
    M_SRC_EN    : out  std_logic;
    M_DATA_VLD    : out  std_logic;
    M_CBE      : in  std_logic_vector(  7 downto 0);
    TIME_OUT    : out  std_logic;
    M_FAIL64    : out  std_logic;
    CFG_SELF    : in  std_logic;
    M_DATA      : out  std_logic;
    DR_BUS      : out  std_logic;
    I_IDLE      : out  std_logic;
    M_ADDR_N    : out  std_logic;
    IDLE      : out  std_logic;
    B_BUSY      : out  std_logic;
    S_DATA      : out  std_logic;
    BACKOFF     : out  std_logic;
    SLOT64      : in  std_logic;
    INTR_N      : in  std_logic;
    PERRQ_N     : out  std_logic;
    SERRQ_N     : out  std_logic;
    KEEPOUT     : in  std_logic;
    CSR       : out  std_logic_vector( 39 downto 0);
    SUB_DATA    : in  std_logic_vector( 31 downto 0);
    RST       : inout std_logic;
    CLK       : inout std_logic
  );
end component;

  -- Component declaration for Configuration
component CFG
  port (
    CFG       : out  std_logic_vector(255 downto 0)
  );
end component;


  -- Component declaration of Userapp

component pcicnt
  port (
  -- Interface to PCI Logicore.
    FRAMEQ_N    : in  std_logic;              -- Latched FRAME# Signal
    REQ64Q_N    : in  std_logic;              -- Latched REQ64# Signal
    TRDYQ_N     : in  std_logic;              -- Latched TRDY# Signal
    IRDYQ_N     : in  std_logic;              -- Latched IRDY# Signal
    STOPQ_N     : in  std_logic;              -- Latched STOP# Signal
    DEVSELQ_N   : in  std_logic;              -- Latched DEVSEL# Signal
    ACK64Q_N    : in  std_logic;              -- Latched ACK64# Signal

    ADDR        : in  std_logic_vector( 31 downto 0);    -- Latched Target Address Bus
    ADIO        : inout std_logic_vector( 63 downto 0);    -- Internal Address/Data Bus

    CFG_VLD     : in  std_logic;              -- Configulation Cycle Valid
    CFG_HIT     : in  std_logic;              -- Configuration Cycle Start
    C_TERM      : out  std_logic;              -- Configuraton Cycle Terminate Signal
    C_READY     : out  std_logic;              -- Configuration Data Transfer Ready Signal

    ADDR_VLD    : in  std_logic;              -- Internal Address Valid
    BASE_HIT    : in  std_logic_vector(  7 downto 0);    -- Base Address Hit

    S_CYCLE64   : in  std_logic;              -- 64 bit Transaction Go On
    S_TERM      : out  std_logic;              -- Target Transaction Terminate Signal
    S_READY     : out  std_logic;              -- Target Transaction Data Transfer Ready Siganl
    S_ABORT     : out  std_logic;              -- Target Abort Request Signal
    S_WRDN      : in  std_logic;              -- Target Transaction Data Direction (0:Write, 1:Read)
    S_SRC_EN    : in  std_logic;              -- Target Transaction Data Source Enable
    S_DATA_VLD  : in  std_logic;              -- Target Transaction Data Phase Valid Signal
    S_CBE       : in  std_logic_vector(  7 downto 0);    -- Target Command & Byte Enable Signal
    PCI_CMD     : in  std_logic_vector( 15 downto 0);    -- Latched Bus Command

    REQUEST     : out  std_logic;              -- REQ# Signal Assert Request
    REQUEST64   : out  std_logic;              -- REQ64# Signal Assert Request
    REQUESTHOLD : out  std_logic;              -- Extended REQ# Signal Assert Request (Not Use)
    COMPLETE    : out  std_logic;              -- Initiator Transaction End Signal

    M_WRDN      : out  std_logic;              -- Initiator Transaction Data Direction (0:Write, 1:Read)
    M_READY     : out  std_logic;              -- Initiator Transaction Data Transfer Ready Siganl
    M_SRC_EN    : in  std_logic;              -- Initiator Transaction Data Source Enable
    M_DATA_VLD  : in  std_logic;              -- Initiator Transaction Data Phase Valid Signal
    M_CBE       : out  std_logic_vector(  7 downto 0);    -- Initiator Command & Byte Enable Signal

    TIME_OUT    : in  std_logic;              -- Latency Timer Timeout Signal
    M_FAIL64    : in  std_logic;              -- 64 bit Transaction Fail Signal
    CFG_SELF    : out  std_logic;              -- Self Configuration Start Signal

    M_DATA      : in  std_logic;              -- Data Transfer State
    DR_BUS      : in  std_logic;              -- Bus Park State
    I_IDLE      : in  std_logic;              -- Initiator Idle State
    M_ADDR_N    : in  std_logic;              -- Initiator Address State
    IDLE        : in  std_logic;              -- Target Idle State
    B_BUSY      : in  std_logic;              -- PCI Bus Busy State
    S_DATA      : in  std_logic;              -- Target Data Transfer State
    BACKOFF     : in  std_logic;              -- Target State Machine Transaction End State

    SLOT64      : out  std_logic;              -- 64 bit Extended Signal Eable
    INTR_N      : out  std_logic;              -- Interrupt Request
    PERRQ_N     : in  std_logic;              -- latched PERR# Signal
    SERRQ_N     : in  std_logic;              -- Latched SERR# Signal
    KEEPOUT     : out  std_logic;              -- ADIO Bus Disable Request Signal

    CSR         : in  std_logic_vector( 39 downto 0);    -- Command/Status Register State
    SUB_DATA    : out  std_logic_vector( 31 downto 0);    -- Sub-Identification
    CFG         : in  std_logic_vector(255 downto 0);    -- Confiuration Data

    RST         : in  std_logic;              -- PCI Bus Reset
    CLK         : in  std_logic;              -- PCI bus Clock

  -- Internal Register Access Control Signal
    REG_AD      : out  std_logic_vector( 7 downto 0);    -- REGCNT R/W Address
    REG_WE      : out  std_logic;              -- REGCNT Write Enable
    REG_RE      : out  std_logic;              -- REGCNT Read Enable
    REG_DTI     : out  std_logic_vector(31 downto 0);    -- REGCNT Write Data
    REG_DTO     : in  std_logic_vector(31 downto 0);    -- REGCNT Read Data
    REG_DTOEN   : in  std_logic;              -- REGCNT Read Data Enable

  -- Internal Memory Access Control Signal
    MEM_ADA     : out  std_logic_vector(19 downto 0);    -- DPRAM Port A R/W Address
    MEM_WEHA    : out  std_logic;              -- DPRAM Port A Write Enable (High Word)
    MEM_WELA    : out  std_logic;              -- DPRAM Port A Write Enable (Low  Word)
    MEM_REA     : out  std_logic;              -- DPRAM Port A Read Enable
    MEM_DTIA    : out  std_logic_vector(63 downto 0);    -- DPRAM Port A Write Data
    MEM_DTOA    : in  std_logic_vector(63 downto 0);    -- DPRAM Port A Read Data
    MEM_DTOEN   : in  std_logic;              -- DPRAM Port A Read Data Enable

    DMAEND_INT  : out  std_logic;                -- DMA End Interrupt On Request
    INT_REQ     : in  std_logic;                -- PCI Interrupt On Request



--################################
--##    for Debug
--################################


    DEBUG_OUT    : out  std_logic_vector( 7 downto 0)



  );
end component;


component REGCNT
  port (
    RST       : in  std_logic;  -- PCI Bus Reset
    CLK       : in  std_logic;  -- PCI bus Clock
    -- PCI R/W ports
    REG_AD      : in  std_logic_vector( 7 downto 0);   -- REGCNT R/W Address
    REG_WE      : in  std_logic;                       -- REGCNT Write Enable
    REG_RE      : in  std_logic;                       -- REGCNT Read Enable
    REG_DTI      : in  std_logic_vector(31 downto 0);  -- REGCNT Write Data
    REG_DTO      : out  std_logic_vector(31 downto 0); -- REGCNT Read Data
    REG_DTOEN    : out  std_logic;                     -- REGCNT Read Data Enable
    -- USER Application Interface ports
    LED_CNT      : out  std_logic_vector( 7 downto 0); -- LED Control Signal
    DIPSW      : in  std_logic_vector( 3 downto 0);    -- DIPSW Signal
    DMAEND_INT    : in  std_logic;                 -- DMA End Interrupt On Request
    PSW_ON0      : in  std_logic;                  -- User Interrupt 0 On Request
    PSW_ON1      : in  std_logic;                  -- User Interrupt 1 On Request
    USERINT2_ON    : in  std_logic;                -- User Interrupt 2 On Request
    GPREG0 : in  std_logic_vector(31 downto 0);    -- Read Only Register
    GPREG1 : out std_logic_vector(31 downto 0);    -- Read Only Register
    PGPG_REG0 : out std_logic_vector(31 downto 0);
    PGPG_REG1 : out std_logic_vector(31 downto 0);
    PGPG_REG2 : out std_logic_vector(31 downto 0);
    PGPG_REG3 : out std_logic_vector(31 downto 0);
    Hit_PGPG_REG2 : out std_logic;
    Hit_PGPG_REG3 : out std_logic;
    INT_REQ      : out  std_logic                   -- Interrupt Request
    );
end component;


component DPRAM
  port (
    RST       : in  std_logic;                          -- PCI Bus Reset
    CLK       : in  std_logic;                          -- PCI bus Clock
    CLKB      : in  std_logic;                          -- Port B Clock
    -- PCI R/W ports
    MEM_ADA      : in  std_logic_vector(13 downto 0);   -- DPRAM Port A R/W Address
    MEM_WEHA    : in  std_logic;                        -- DPRAM Port A Write Enable (High Word)
    MEM_WELA    : in  std_logic;                        -- DPRAM Port A Write Enable (Low  Word)
    MEM_REA      : in  std_logic;                       -- DPRAM Port A Read Enable
    MEM_DTIA    : in  std_logic_vector(63 downto 0);    -- DPRAM Port A Write Data
    MEM_DTOA    : out  std_logic_vector(63 downto 0);   -- DPRAM Port A Read Data
    MEM_DTOEN    : out  std_logic;                      -- DPRAM Port A Read Data Enable
    -- USER Application R/W ports
    MEM_ADB      : in  std_logic_vector(12 downto 0);   -- DPRAM Port B R/W Address
    MEM_WEHB    : in  std_logic;                        -- DPRAM Port B Write Enable (High Word)
    MEM_WELB    : in  std_logic;                        -- DPRAM Port B Write Enable (Low  Word)
    MEM_DTIB    : in  std_logic_vector(63 downto 0);    -- DPRAM Port B Write Data
    MEM_DTOB    : out  std_logic_vector(63 downto 0)    -- DPRAM Port B Read Data
    );
end component;


component USER
  port (
    RST         : in  std_logic;                     -- PCI Bus Reset
    CLK         : in  std_logic;                     -- PCI bus Clock
    PSW_IN      : in  std_logic_vector( 1 downto 0); -- Push SW Input
    DIPSW       : out  std_logic_vector( 3 downto 0);-- DIPSW Signal
    PSW_ON0     : out  std_logic;                    -- User Interrupt 0 On Request
    PSW_ON1     : out  std_logic;                    -- User Interrupt 1 On Request
    USERINT2_ON : out  std_logic                     -- User Interrupt 2 On Request
    );
end component;

component pfpga_config
  port( clk   : in std_logic;
        rst_n : in std_logic;
        cmd_reg  : in std_logic_vector(8 downto 0);
        data_reg : in std_logic_vector(31 downto 0);
	-- Pipeline FPGA side
        CFG_D         : out  std_logic_vector(7 downto 0);  -- DATA
        CFG_CCLK      : out  std_logic;           -- CCLK
        CFG_PROG_B0   : out  std_logic;           -- PFPGA0����PROG_B
        CFG_PROG_B1   : out  std_logic;           -- PFPGA1����PROG_B
        CFG_PROG_B2   : out  std_logic;           -- PFPGA2����PROG_B
        CFG_PROG_B3   : out  std_logic;           -- PFPGA3����PROG_B
        CFG_CS_B0     : out  std_logic;           -- PFPGA0����CS_B
        CFG_CS_B1     : out  std_logic;           -- PFPGA1����CS_B
        CFG_CS_B2     : out  std_logic;           -- PFPGA2����CS_B
        CFG_CS_B3     : out  std_logic;           -- PFPGA3����CS_B
        CFG_RDWR_B    : out  std_logic);          -- RD/WR_B
end component;

component FDDRRSE
  port(
    Q        : out  std_logic;      -- DDR output
    D0        : in  std_logic;      -- data in to fddr
    D1        : in  std_logic;      -- data in to fddr
    C0        : in  std_logic;      -- clock
    C1        : in  std_logic;      -- inversee of C0
    CE        : in  std_logic;      -- clock enable
    R        : in  std_logic;       -- reset
    S        : in  std_logic        -- set
);
end component;

component dcm_ps_f
  generic(
    PS  : integer
  );
  port(
    RST          : in  std_logic;     -- ���Z�b�g
    CLK_IN        : in  std_logic;    -- �N���b�N����
    CLK_FB_IN      : in  std_logic;   -- �N���b�NFB����
    CLK_OUT        : out  std_logic   -- �N���b�N�o��
  );
end component;

component LOCAL_IO
  generic (NBIT_L_ADRO : integer := 3);
  port (
    
    CALC_STS : in std_logic;                               -- from PFPGA CBUS INPUT (1: pipe done, 0: pipe idle or running) 
    NPIPE : in std_logic_vector(7 downto 0) := "00000001"; -- from PGPG_REG3
    BUSY_LOCAL_READ : out std_logic :='0';                 -- to GPREG0(0)

    -- pcicnt input
    MEM_ADA  : in std_logic_vector(19 downto 0);     -- DPRAM Port B R/W Address
    MEM_WEHA : in std_logic;
    MEM_WELA : in std_logic;
    MEM_DTIA : in std_logic_vector(63 downto 0);

    -- CBUS/DBUS
    DMAW_ENABLE : out std_logic_vector(3 downto 0); -- for 4 pfpga chip
    DMAR_ENABLE : out std_logic_vector(3 downto 0); -- for 4 pfpga chip
    DBUS_Port : out std_logic_vector(63 downto 0);
    DBUS_idata: in std_logic_vector(63 downto 0);
    DBUS_HiZ  : out std_logic;

    -- DPRAM R/W ports
    MEM_ADB     : out std_logic_vector(12 downto 0);     -- DPRAM Port B R/W Address
    MEM_WEHB    : out std_logic;                         -- DPRAM Port B Write Enable (High Word)
    MEM_WELB    : out std_logic;                         -- DPRAM Port B Write Enable (Low  Word)
    MEM_DTIB    : out std_logic_vector(63 downto 0);     -- DPRAM Port B Write Data
    MEM_DTOB    : in  std_logic_vector(63 downto 0);     -- DPRAM Port B Read Data

    RST : in  std_logic;
    CLK : in  std_logic
    );
end component;


component WRITECOMB_CHECK
  port (
    MEM_WEHA : in std_logic;
    MEM_WELA : in std_logic;
    IS_ERR : out std_logic_vector(25 downto 0);
    RST : in  std_logic;
    CLK : in  std_logic
    );
end component;

component FIFOFIFO
  port (
    -- pcicnt input
    MEM_ADA  : in std_logic_vector(19 downto 0);     -- DPRAM Port B R/W Address
    MEM_WEHA : in std_logic;
    MEM_WELA : in std_logic;
    MEM_DTIA : in std_logic_vector(63 downto 0);
    -- output
    MEM_AD     : out std_logic_vector(31 downto 0);
    MEM_WE     : out std_logic;
    MEM_DTI    : out std_logic_vector(63 downto 0);

    RST : in  std_logic;
    CLK : in  std_logic
    );
end component;


--------------------------------------------------
-- signals
--------------------------------------------------

  -- Internal signals; do not modify names!

  signal FRAMEQ_N      : std_logic;                -- Latched FRAME# Signal
  signal REQ64Q_N      : std_logic;                -- Latched REQ64# Signal
  signal TRDYQ_N      : std_logic;                -- Latched TRDY# Signal
  signal IRDYQ_N      : std_logic;                -- Latched IRDY# Signal
  signal STOPQ_N      : std_logic;                -- Latched STOP# Signal
  signal DEVSELQ_N    : std_logic;                -- Latched DEVSEL# Signal
  signal ACK64Q_N      : std_logic;                -- Latched ACK64# Signal

  signal ADDR        : std_logic_vector( 31 downto 0);      -- Latched Target Address Bus
  signal ADIO        : std_logic_vector( 63 downto 0);      -- Internal Address/Data Bus

  signal CFG_VLD      : std_logic;                -- Configulation Cycle Valid
  signal CFG_HIT      : std_logic;                -- Configuration Cycle Start
  signal C_TERM       : std_logic;                -- Configuraton Cycle Terminate Signal
  signal C_READY      : std_logic;                -- Configuration Data Transfer Ready Signal

  signal ADDR_VLD      : std_logic;                -- Internal Address Valid
  signal BASE_HIT      : std_logic_vector(  7 downto 0);      -- Base Address Hit

  signal S_CYCLE64    : std_logic;                -- 64 bit Transaction Go On
  signal S_TERM       : std_logic;                -- Target Transaction Terminate Signal
  signal S_READY      : std_logic;                -- Target Transaction Data Transfer Ready Siganl
  signal S_ABORT      : std_logic;                -- Target Abort Request Signal
  signal S_WRDN       : std_logic;                -- Target Transaction Data Direction (0:Write, 1:Read)
  signal S_SRC_EN      : std_logic;                -- Target Transaction Data Source Enable
  signal S_DATA_VLD     : std_logic;                -- Target Transaction Data Phase Valid Signal
  signal S_CBE      : std_logic_vector(  7 downto 0);      -- Target Command & Byte Enable Signal
                                    -- Latched Bus Command
  signal PCI_CMD      : std_logic_vector( 15 downto 0);
  signal REQUEST      : std_logic;                -- REQ# Signal Assert Request
  signal REQUEST64    : std_logic;                -- REQ64# Signal Assert Request
  signal REQUESTHOLD    : std_logic;                -- Extended REQ# Signal Assert Request (Not Use)
  signal COMPLETE      : std_logic;                -- Initiator Transaction End Signal

  signal M_WRDN       : std_logic;                -- Initiator Transaction Data Direction (0:Write, 1:Read)
  signal M_READY      : std_logic;                -- Initiator Transaction Data Transfer Ready Siganl
  signal M_SRC_EN      : std_logic;                -- Initiator Transaction Data Source Enable
  signal M_DATA_VLD     : std_logic;                -- Initiator Transaction Data Phase Valid Signal
  signal M_CBE      : std_logic_vector(  7 downto 0);      -- Initiator Command & Byte Enable Signal

  signal TIME_OUT      : std_logic;                -- Latency Timer Timeout Signal
  signal M_FAIL64      : std_logic;                -- 64 bit Transaction Fail Signal
  signal CFG_SELF      : std_logic;                -- Self Configuration Start Signal

  signal M_DATA       : std_logic;                -- Data Transfer State
  signal DR_BUS       : std_logic;                -- Bus Park State
  signal I_IDLE       : std_logic;                -- Initiator Idle State
  signal M_ADDR_N      : std_logic;                -- Initiator Address State
  signal IDLE        : std_logic;                -- Target Idle State
  signal B_BUSY       : std_logic;                -- PCI Bus Busy State
  signal S_DATA       : std_logic;                -- Target Data Transfer State
  signal BACKOFF      : std_logic;                -- Target State Machine Transaction End State

  signal SLOT64       : std_logic;                -- 64 bit Extended Signal Eable
  signal INTR_N       : std_logic;                -- Interrupt Request
  signal PERRQ_N      : std_logic;                -- latched PERR# Signal
  signal SERRQ_N      : std_logic;                -- Latched SERR# Signal
  signal KEEPOUT      : std_logic;                -- ADIO Bus Disable Request Signal

  signal CSR        : std_logic_vector( 39 downto 0);      -- Command/Status Register State
  signal SUB_DATA      : std_logic_vector( 31 downto 0);      -- Sub-Identification
  signal CFG_BUS      : std_logic_vector(255 downto 0);      -- Confiuration Data

  signal RST        : std_logic;                -- PCI Bus Reset
  signal CLK        : std_logic;                -- PCI bus Clock

  -- Internal Register Access Control Signal
  signal  REG_AD      : std_logic_vector( 7 downto 0);      -- REGCNT R/W Address
  signal  REG_WE      : std_logic;                -- REGCNT Write Enable
  signal  REG_RE      : std_logic;                -- REGCNT Read Enable
  signal  REG_DTI      : std_logic_vector(31 downto 0);      -- REGCNT Write Data
  signal  REG_DTO      : std_logic_vector(31 downto 0);      -- REGCNT Read Data
  signal  REG_DTOEN    : std_logic;                -- REGCNT Read Data Enable

  -- USER Application Interface ports
  signal  LED_CNT      : std_logic_vector( 7 downto 0);      -- LED Control Signal
  signal  DIPSW      : std_logic_vector( 3 downto 0);      -- DIPSW Signal

  signal  DMAEND_INT    : std_logic;                  -- DMA End Interrupt On Request
  signal  PSW_ON0      : std_logic;                  -- User Interrupt 0 On Request
  signal  PSW_ON1      : std_logic;                  -- User Interrupt 1 On Request
  signal  USERINT2_ON    : std_logic;                  -- User Interrupt 2 On Request

  signal  INT_REQ      : std_logic;                -- Interrupt Request

  -- Internal Memory Access from PCI Control Signal
  signal  MEM_ADA      : std_logic_vector(19 downto 0);      -- DPRAM Port A R/W Address
  signal  MEM_WEHA    : std_logic;                -- DPRAM Port A Write Enable (High Word)
  signal  MEM_WELA    : std_logic;                -- DPRAM Port A Write Enable (Low  Word)
  signal  MEM_REA      : std_logic;                -- DPRAM Port A Read Enable
  signal  MEM_DTIA    : std_logic_vector(63 downto 0);      -- DPRAM Port A Write Data
  signal  MEM_DTOA    : std_logic_vector(63 downto 0);      -- DPRAM Port A Read Data
  signal  MEM_DTOEN    : std_logic;                -- DPRAM Port A Read Data Enable

  -- Internal Memory Access from User Application Control Signal
  signal  MEM_ADB      : std_logic_vector(12 downto 0);      -- DPRAM Port B R/W Address
  signal  MEM_WEHB    : std_logic;                  -- DPRAM Port B Write Enable (High Word)
  signal  MEM_WELB    : std_logic;                  -- DPRAM Port B Write Enable (Low  Word)
  signal  MEM_DTIB    : std_logic_vector(63 downto 0);      -- DPRAM Port B Write Data
  signal  MEM_DTOB    : std_logic_vector(63 downto 0);      -- DPRAM Port B Read Data


  -- for PGPG
  constant  const_0 : std_logic :='0';
  constant  const_1 : std_logic :='1';
  signal CK66_DCM   : std_logic;
  signal xCK66_DCM  : std_logic;
  signal GPREG0_ff : std_logic_vector(31 downto 0); -- REGCNF <- (0):CALC_END(FOGET READY), (31 downto 6):WRITECOMB_CHECK
  signal GPREG1_ff : std_logic_vector(31 downto 0); -- REGCNF -> PFPGA_DMA
  signal PGPG_REG0_ff : std_logic_vector(31 downto 0); -- REGCNF -> PFPGA_DMA
  signal PGPG_REG1_ff : std_logic_vector(31 downto 0); -- REGCNF -> PFPGA_DMA
  signal PGPG_REG2_ff : std_logic_vector(31 downto 0); -- REGCNF -> PFPGA_DMA  # RESERVED!
  signal PGPG_REG3_ff : std_logic_vector(31 downto 0); -- REGCNF -> PFPGA_DMA
  signal Hit_PGPG_REG2_ff      : std_logic;            -- REGCNF -> PFPGA_DMA  # RESERVED!
  signal Hit_PGPG_REG2_ff0     : std_logic;            -- REGCNF -> PFPGA_DMA  # RESERVED!
  signal Hit_PGPG_REG2_ff_CK66 : std_logic;            -- REGCNF -> PFPGA_DMA  # RESERVED!
  signal Hit_PGPG_REG3_ff      : std_logic;            -- REGCNF -> PFPGA_DMA  # NOT USED!
  signal Hit_PGPG_REG3_ff0     : std_logic;            -- REGCNF -> PFPGA_DMA  # NOT USED!
  signal Hit_PGPG_REG3_ff_CK66 : std_logic;            -- REGCNF -> PFPGA_DMA -- Bugfixed Hit_PGPG_REG3
  signal DBUS_Port  : std_logic_vector(63 downto 0) := (others=>'0'); -- PFPGA_DMA -> PFPGA
  signal DBUS_idata : std_logic_vector(63 downto 0) := (others=>'0'); -- PFPGA_DMA <- PFPGA
  signal DBUS_HiZ   : std_logic;
  signal DMAW_ENABLE : std_logic_vector(3 downto 0);
  signal DMAR_ENABLE : std_logic_vector(3 downto 0);
  signal PFPGA_DMA_STS : std_logic_vector(31 downto 0) :=(others=>'0'); -- -> GPREG0_ff
  signal PFPGA_PIPE_STS : std_logic_vector(3 downto 0) :=(others=>'0'); -- -> GPREG0_ff
  -- FIFOFIFO
  signal FIFO_WE  : std_logic;
  signal FIFO_AD  : std_logic_vector(31 downto 0);
  signal FIFO_DTI : std_logic_vector(63 downto 0);
  -- LOCAL_IO
  signal BUSY_LOCAL_READ : std_logic;

  -- FF for PFPGA COnfiguration Pins
  signal CFG_INIT_B0_iff, CFG_INIT_B1_iff, CFG_INIT_B2_iff, CFG_INIT_B3_iff : std_logic;
  signal CFG_D_o : std_logic_vector(7 downto 0);
  signal CFG_CCLK_o,CFG_RDWR_B_o                                    : std_logic;
  signal CFG_PROG_B0_o, CFG_PROG_B1_o, CFG_PROG_B2_o, CFG_PROG_B3_o : std_logic;
  signal CFG_CS_B0_o, CFG_CS_B1_o, CFG_CS_B2_o, CFG_CS_B3_o         : std_logic;

  -- LED
  signal LED_ff : std_logic_vector(7 downto 0);

--################################
--##    for Debug
--################################
  signal  DEBUG_OUT    : std_logic_vector( 7 downto 0);
  signal  DEBUG_SIG    : std_logic_vector(13 downto 0);
  signal  DEBUG_CS_CLK0 : std_logic := '0';
  signal  DEBUG_CS_CLK1 : std_logic;


  signal CLK_CFG : std_logic;

  constant PSW_IN : std_logic_vector(1 downto 0) := (others=>'1');
  signal DSW_OUT : std_logic_vector(1 downto 0) := (others=>'1');

begin


  -- Do not modify any port, signal, or instance
  -- names related to the PCI Interface!

  PCI_CORE : pcim_lc port map (
    AD_IO      => AD,
    CBE_IO      => CBE,
    PAR_IO      => PAR,
    PAR64_IO    => PAR64,
    FRAME_IO    => FRAME_N,
    REQ64_IO    => REQ64_N,
    TRDY_IO     => TRDY_N,
    IRDY_IO     => IRDY_N,
    STOP_IO     => STOP_N,
    DEVSEL_IO    => DEVSEL_N,
    ACK64_IO    => ACK64_N,
    IDSEL_I     => IDSEL,
    INTA_O      => INTR_A,
    PERR_IO     => PERR_N,
    SERR_IO     => SERR_N,
    REQ_O      => REQ_N,
    GNT_I      => GNT_N,
    RST_I      => RST_N,
    PCLK      => PCLK,

    FRAMEQ_N    => FRAMEQ_N,                -- Latched FRAME# Signal
    REQ64Q_N    => REQ64Q_N,                -- Latched REQ64# Signal
    TRDYQ_N     => TRDYQ_N,                 -- Latched TRDY# Signal
    IRDYQ_N     => IRDYQ_N,                 -- Latched IRDY# Signal
    STOPQ_N     => STOPQ_N,                 -- Latched STOP# Signal
    DEVSELQ_N    => DEVSELQ_N,                -- Latched DEVSEL# Signal
    ACK64Q_N    => ACK64Q_N,                -- Latched ACK64# Signal

    ADDR      => ADDR,                  -- Latched Target Address Bus
    ADIO      => ADIO,                  -- Internal Address/Data Bus

    CFG_VLD     => CFG_VLD,                 -- Configulation Cycle Valid
    CFG_HIT     => CFG_HIT,                 -- Configuration Cycle Start
    C_TERM      => C_TERM,                  -- Configuraton Cycle Terminate Signal
    C_READY     => C_READY,                 -- Configuration Data Transfer Ready Signal

    ADDR_VLD    => ADDR_VLD,                -- Internal Address Valid
    BASE_HIT    => BASE_HIT,                -- Base Address Hit

    S_CYCLE64    => S_CYCLE64,                -- 64 bit Transaction Go On
    S_TERM      => S_TERM,                  -- Target Transaction Terminate Signal
    S_READY     => S_READY,                 -- Target Transaction Data Transfer Ready Siganl
    S_ABORT     => S_ABORT,                 -- Target Abort Request Signal
    S_WRDN      => S_WRDN,                  -- Target Transaction Data Direction (0:Write, 1:Read)
    S_SRC_EN    => S_SRC_EN,                -- Target Transaction Data Source Enable
    S_DATA_VLD    => S_DATA_VLD,                -- Target Transaction Data Phase Valid Signal
    S_CBE      => S_CBE,                  -- Target Command & Byte Enable Signal
    PCI_CMD     => PCI_CMD,                 -- Latched Bus Command

    REQUEST     => REQUEST,                 -- REQ# Signal Assert Request
    REQUEST64    => REQUEST64,                -- REQ64# Signal Assert Request
    REQUESTHOLD   => REQUESTHOLD,               -- Extended REQ# Signal Assert Request (Not Use)
    COMPLETE    => COMPLETE,                -- Initiator Transaction End Signal

    M_WRDN      => M_WRDN,                  -- Initiator Transaction Data Direction (0:Write, 1:Read)
    M_READY     => M_READY,                 -- Initiator Transaction Data Transfer Ready Siganl
    M_SRC_EN    => M_SRC_EN,                -- Initiator Transaction Data Source Enable
    M_DATA_VLD    => M_DATA_VLD,                -- Initiator Transaction Data Phase Valid Signal
    M_CBE      => M_CBE,                  -- Initiator Command & Byte Enable Signal

    TIME_OUT    => TIME_OUT,                -- Latency Timer Timeout Signal
    M_FAIL64    => M_FAIL64,                -- 64 bit Transaction Fail Signal
    CFG_SELF    => CFG_SELF,                -- Self Configuration Start Signal

    M_DATA      => M_DATA,                  -- Data Transfer State
    DR_BUS      => DR_BUS,                  -- Bus Park State
    I_IDLE      => I_IDLE,                  -- Initiator Idle State
    M_ADDR_N    => M_ADDR_N,                -- Initiator Address State
    IDLE      => IDLE,                  -- Target Idle State
    B_BUSY      => B_BUSY,                  -- PCI Bus Busy State
    S_DATA      => S_DATA,                  -- Target Data Transfer State
    BACKOFF     => BACKOFF,                 -- Target State Machine Transaction End State

    SLOT64      => SLOT64,                  -- 64 bit Extended Signal Eable
    INTR_N      => INTR_N,                  -- Interrupt Request
    PERRQ_N     => PERRQ_N,                 -- latched PERR# Signal
    SERRQ_N     => SERRQ_N,                 -- Latched SERR# Signal
    KEEPOUT     => KEEPOUT,                 -- ADIO Bus Disable Request Signal

    CSR       => CSR,                   -- Command/Status Register State
    SUB_DATA    => SUB_DATA,                -- Sub-Identification
    CFG       => CFG_BUS,                 -- Confiuration Data

    RST       => RST,                   -- PCI Bus Reset
    CLK       => CLK                    -- PCI bus Clock
  );


  -- Instantiate the configuration module

  CFG_INST : CFG port map (CFG => CFG_BUS);


  -- Instantiate the user application

  PCI_CNT : pcicnt port map (
    FRAMEQ_N    => FRAMEQ_N,                -- Latched FRAME# Signal
    REQ64Q_N    => REQ64Q_N,                -- Latched REQ64# Signal
    TRDYQ_N     => TRDYQ_N,                 -- Latched TRDY# Signal
    IRDYQ_N     => IRDYQ_N,                 -- Latched IRDY# Signal
    STOPQ_N     => STOPQ_N,                 -- Latched STOP# Signal
    DEVSELQ_N    => DEVSELQ_N,                -- Latched DEVSEL# Signal
    ACK64Q_N    => ACK64Q_N,                -- Latched ACK64# Signal

    ADDR      => ADDR,                  -- Latched Target Address Bus
    ADIO      => ADIO,                  -- Internal Address/Data Bus

    CFG_VLD     => CFG_VLD,                 -- Configulation Cycle Valid
    CFG_HIT     => CFG_HIT,                 -- Configuration Cycle Start
    C_TERM      => C_TERM,                  -- Configuraton Cycle Terminate Signal
    C_READY     => C_READY,                 -- Configuration Data Transfer Ready Signal

    ADDR_VLD    => ADDR_VLD,                -- Internal Address Valid
    BASE_HIT    => BASE_HIT,                -- Base Address Hit

    S_CYCLE64    => S_CYCLE64,                -- 64 bit Transaction Go On
    S_TERM      => S_TERM,                  -- Target Transaction Terminate Signal
    S_READY     => S_READY,                 -- Target Transaction Data Transfer Ready Siganl
    S_ABORT     => S_ABORT,                 -- Target Abort Request Signal
    S_WRDN      => S_WRDN,                  -- Target Transaction Data Direction (0:Write, 1:Read)
    S_SRC_EN    => S_SRC_EN,                -- Target Transaction Data Source Enable
    S_DATA_VLD    => S_DATA_VLD,                -- Target Transaction Data Phase Valid Signal
    S_CBE      => S_CBE,                  -- Target Command & Byte Enable Signal
    PCI_CMD     => PCI_CMD,                 -- Latched Bus Command

    REQUEST     => REQUEST,                 -- REQ# Signal Assert Request
    REQUEST64    => REQUEST64,                -- REQ64# Signal Assert Request
    REQUESTHOLD   => REQUESTHOLD,               -- Extended REQ# Signal Assert Request (Not Use)
    COMPLETE    => COMPLETE,                -- Initiator Transaction End Signal

    M_WRDN      => M_WRDN,                  -- Initiator Transaction Data Direction (0:Write, 1:Read)
    M_READY     => M_READY,                 -- Initiator Transaction Data Transfer Ready Siganl
    M_SRC_EN    => M_SRC_EN,                -- Initiator Transaction Data Source Enable
    M_DATA_VLD    => M_DATA_VLD,                -- Initiator Transaction Data Phase Valid Signal
    M_CBE      => M_CBE,                  -- Initiator Command & Byte Enable Signal

    TIME_OUT    => TIME_OUT,                -- Latency Timer Timeout Signal
    M_FAIL64    => M_FAIL64,                -- 64 bit Transaction Fail Signal
    CFG_SELF    => CFG_SELF,                -- Self Configuration Start Signal

    M_DATA      => M_DATA,                  -- Data Transfer State
    DR_BUS      => DR_BUS,                  -- Bus Park State
    I_IDLE      => I_IDLE,                  -- Initiator Idle State
    M_ADDR_N    => M_ADDR_N,                -- Initiator Address State
    IDLE      => IDLE,                  -- Target Idle State
    B_BUSY      => B_BUSY,                  -- PCI Bus Busy State
    S_DATA      => S_DATA,                  -- Target Data Transfer State
    BACKOFF     => BACKOFF,                 -- Target State Machine Transaction End State

    SLOT64      => SLOT64,                  -- 64 bit Extended Signal Eable
    INTR_N      => INTR_N,                  -- Interrupt Request
    PERRQ_N     => PERRQ_N,                 -- latched PERR# Signal
    SERRQ_N     => SERRQ_N,                 -- Latched SERR# Signal
    KEEPOUT     => KEEPOUT,                 -- ADIO Bus Disable Request Signal

    CSR       => CSR,                   -- Command/Status Register State
    SUB_DATA    => SUB_DATA,                -- Sub-Identification
    CFG       => CFG_BUS,                 -- Confiuration Data

    RST       => RST,                   -- PCI Bus Reset
    CLK       => CLK,                   -- PCI bus Clock

  -- Internal Register Access Control Signal
    REG_AD      => REG_AD,                  -- REGCNT R/W Address
    REG_WE      => REG_WE,                  -- REGCNT Write Enable
    REG_RE      => REG_RE,                  -- REGCNT Read Enable
    REG_DTI      => REG_DTI,                  -- REGCNT Write Data
    REG_DTO      => REG_DTO,                  -- REGCNT Read Data
    REG_DTOEN    => REG_DTOEN,                -- REGCNT Read Data Enable

  -- Internal Memory Access Control Signal
    MEM_ADA     => MEM_ADA,                  -- DPRAM Port A R/W Address
    MEM_WEHA     => MEM_WEHA,                -- DPRAM Port A Write Enable (High Word)
    MEM_WELA     => MEM_WELA,                -- DPRAM Port A Write Enable (Low  Word)
    MEM_REA     => MEM_REA,                  -- DPRAM Port A Read Enable
    MEM_DTIA     => MEM_DTIA,                -- DPRAM Port A Write Data
    MEM_DTOA     => MEM_DTOA,                -- DPRAM Port A Read Data
    MEM_DTOEN     => MEM_DTOEN,                -- DPRAM Port A Read Data Enable

    DMAEND_INT    => DMAEND_INT,                -- DMA End Interrupt On Request
    INT_REQ      => INT_REQ,                  -- PCI Interrupt On Request




--################################
--##    for Debug
--################################



    DEBUG_OUT    =>  DEBUG_OUT                -- DMA End Interrupt On Request
  );

  reg0 : REGCNT port map (
    RST       => RST,                   -- PCI Bus Reset
    CLK       => CLK,                   -- PCI bus Clock

    -- PCI R/W ports
    REG_AD      => REG_AD,                  -- REGCNT R/W Address
    REG_WE      => REG_WE,                  -- REGCNT Write Enable
    REG_RE      => REG_RE,                  -- REGCNT Read Enable
    REG_DTI      => REG_DTI,                  -- REGCNT Write Data
    REG_DTO      => REG_DTO,                  -- REGCNT Read Data
    REG_DTOEN    => REG_DTOEN,                -- REGCNT Read Data Enable

    -- USER Application Interface ports
    LED_CNT      => LED_CNT,                  -- LED Control Signal
    DIPSW      => DIPSW,                  -- DIPSW Signal

    DMAEND_INT    => DMAEND_INT,                -- DMA End Interrupt On Request
    PSW_ON0      => PSW_ON0,                  -- User Interrupt 0 On Request
    PSW_ON1      => PSW_ON1,                  -- User Interrupt 1 On Request
    USERINT2_ON    => USERINT2_ON,                -- User Interrupt 2 On Request

    GPREG0 => GPREG0_ff,         -- from PFPGA_DMA_STS/ PFPGA_PIPE_STS
    GPREG1 => GPREG1_ff,         -- to PFPGA_RST
    PGPG_REG0 => PGPG_REG0_ff,   -- to PFPGA_DMA
    PGPG_REG1 => PGPG_REG1_ff,   -- to PFPGA_DMA
    PGPG_REG2 => PGPG_REG2_ff,   -- to PFPGA_DMA
    PGPG_REG3 => PGPG_REG3_ff,   -- to PFPGA_DMA
    Hit_PGPG_REG2 => Hit_PGPG_REG2_ff,   -- to PFPGA_DMA
    Hit_PGPG_REG3 => Hit_PGPG_REG3_ff,   -- to PFPGA_DMA

    INT_REQ      => INT_REQ                  -- Interrupt Request
  );


  dp0 : DPRAM port map (
    RST         => RST,                   -- PCI Bus Reset
    CLK         => CLK,                   -- PCI bus Clock
--hoge
--    CLKB      => CK66,                  -- Port B Clock
    CLKB        => CLK,                   -- Port B Clock

    -- PCI R/W ports

--  ========================================================================================= �ǂ��ɂ�����!
    MEM_ADA     => MEM_ADA(13 downto 0),  -- DPRAM Port A R/W Address
    MEM_WEHA    => MEM_WEHA,              -- DPRAM Port A Write Enable (High Word)
    MEM_WELA    => MEM_WELA,              -- DPRAM Port A Write Enable (Low  Word)
    MEM_DTIA    => MEM_DTIA,              -- DPRAM Port A Write Data
--    MEM_ADA     => (others=>'0'),
--    MEM_WEHA    => '0',
--    MEM_WELA    => '0',
--    MEM_DTIA    => (others=>'0'),
--  =========================================================================================

    MEM_REA     => MEM_REA,               -- DPRAM Port A Read Enable
    MEM_DTOA    => MEM_DTOA,              -- DPRAM Port A Read Data
    MEM_DTOEN   => MEM_DTOEN,             -- DPRAM Port A Read Data Enable

    -- USER Application R/W ports
    MEM_ADB     => MEM_ADB,               -- DPRAM Port B R/W Address
    MEM_WEHB    => MEM_WEHB,              -- DPRAM Port B Write Enable (High Word)
    MEM_WELB    => MEM_WELB,              -- DPRAM Port B Write Enable (Low  Word)
    MEM_DTIB    => MEM_DTIB,              -- DPRAM Port B Write Data
    MEM_DTOB    => MEM_DTOB               -- DPRAM Port B Read Data
    );


  user0 : USER port map (
    RST         => RST,           -- PCI Bus Reset
    CLK         => CLK,           -- PCI bus Clock
    PSW_IN      => PSW_IN,        -- Push SW Input
    DIPSW       => DIPSW,         -- DIPSW Signal
    PSW_ON0     => PSW_ON0,       -- User Interrupt 0 On Request
    PSW_ON1     => PSW_ON1,       -- User Interrupt 1 On Request
    USERINT2_ON => USERINT2_ON    -- User Interrupt 2 On Request
    );

--***************************************************************
--*
--*  FPGA Reserve PIN Control Block
--*
--***************************************************************
--    CNT2 <= (others=>'Z');
--    CNT4 <= (others=>'Z');
--    RES   <= (others=>'Z');

--################################
--##    for Debug
--################################
    DEBUG_SIG( 4) <= LED_CNT(0);
    DEBUG_SIG( 5) <= LED_CNT(1);
    DEBUG_SIG( 6) <= FRAMEQ_N  ;
    DEBUG_SIG( 7) <= IRDYQ_N  ;
    DEBUG_SIG( 8) <= TRDYQ_N   ;
    DEBUG_SIG( 9) <= STOPQ_N   ;
    DEBUG_SIG(10) <= DEVSELQ_N   ;
    DEBUG_SIG(11) <= M_DATA  ;
    DEBUG_SIG(12) <= '0';
    DEBUG_SIG(13) <= '0';


-- *************************************************************************
-- PGPG  LOGIC
-- *************************************************************************

pgpg0 : pfpga_config  port map(
--    clk      => CLK,
    clk      => CLK,
    rst_n    => (not RST),
    cmd_reg  => PGPG_REG0_ff(8 downto 0),
    data_reg => PGPG_REG1_ff(31 downto 0),
    -- Connected to Chip Output Pins Directly
    CFG_D       => CFG_D_o,
    CFG_CCLK    => CFG_CCLK_o,
    CFG_PROG_B0 => CFG_PROG_B0_o,
    CFG_PROG_B1 => CFG_PROG_B1_o,
    CFG_PROG_B2 => CFG_PROG_B2_o,
    CFG_PROG_B3 => CFG_PROG_B3_o,
    CFG_CS_B0   => CFG_CS_B0_o,
    CFG_CS_B1   => CFG_CS_B1_o,
    CFG_CS_B2   => CFG_CS_B2_o,
    CFG_CS_B3   => CFG_CS_B3_o,
    CFG_RDWR_B  => CFG_RDWR_B_o);

  -- PFPGA Configuration Pins
  process(CLK, RST)  begin
    if (RST = '1') then
      CFG_D <= (others => '0');
      CFG_CCLK <= '0';
      CFG_PROG_B0 <= '1'; CFG_PROG_B1 <= '1'; CFG_PROG_B2 <= '1'; CFG_PROG_B3 <= '1';
      CFG_CS_B0 <= '1'; CFG_CS_B1 <= '1'; CFG_CS_B2 <= '1'; CFG_CS_B3 <= '1';
      CFG_RDWR_B <= '1';
      CFG_INIT_B0_iff <= '0';
      CFG_INIT_B1_iff <= '0';
      CFG_INIT_B2_iff <= '0';
      CFG_INIT_B3_iff <= '0';
    elsif (CLK'event and CLK = '1') then
      CFG_D <= CFG_D_o;
      CFG_CCLK <= CFG_CCLK_o;
      CFG_INIT_B0_iff <= CFG_INIT_B0;
      CFG_INIT_B1_iff <= CFG_INIT_B1;
      CFG_INIT_B2_iff <= CFG_INIT_B2;
      CFG_INIT_B3_iff <= CFG_INIT_B3;
      CFG_PROG_B0 <= CFG_PROG_B0_o;
      CFG_PROG_B1 <= CFG_PROG_B1_o;
      CFG_PROG_B2 <= CFG_PROG_B2_o;
      CFG_PROG_B3 <= CFG_PROG_B3_o;
      CFG_CS_B0 <= CFG_CS_B0_o;
      CFG_CS_B1 <= CFG_CS_B1_o;
      CFG_CS_B2 <= CFG_CS_B2_o;
      CFG_CS_B3 <= CFG_CS_B3_o;
      CFG_RDWR_B <= CFG_RDWR_B_o;
    end if;
  end process;

--------------------------------------------------------------------------------------------------------------
--  LOCAL Input/Output controller between IFPGA and PFPGA
--------------------------------------------------------------------------------------------------------------
pgpg1 : LOCAL_IO
  generic map (NBIT_L_ADRO => 3) -- MAX    (FDIM=8)
--  generic map (NBIT_L_ADRO => 2) -- for G5 (FDIM=4) # �W�F�l���b�N�̓`�d�����܂������Ȃ��̂Œ���local_read_cnt.vhd��I_NFI��ύX���܂��傤!!
  port map (
    CALC_STS => PFPGA_PIPE_STS(0),         -- 1: PIPE CALC DONE, 0: PIPE RUNNING
    NPIPE    => PGPG_REG3_ff(7 downto 0),  -- from REGNCT ( PGPG_REG3 )
    BUSY_LOCAL_READ => BUSY_LOCAL_READ,    -- to REGNCT (GPREG0)
    -- pcicnt input
    MEM_ADA  => FIFO_AD(19 downto 0),
    MEM_WEHA => FIFO_WE,
    MEM_WELA => FIFO_WE,
    MEM_DTIA => FIFO_DTI,

    -- CBUS/DBUS
    DMAW_ENABLE => DMAW_ENABLE,
    DMAR_ENABLE => DMAR_ENABLE,
    DBUS_Port   => DBUS_Port,
    DBUS_idata  => DBUS_idata,
    DBUS_HiZ    => DBUS_HiZ,
    -- DPRAM R/W ports
    MEM_ADB     => MEM_ADB,                  -- DPRAM Port B R/W Address
    MEM_WEHB    => MEM_WEHB,                 -- DPRAM Port B Write Enable (High Word)
    MEM_WELB    => MEM_WELB,                 -- DPRAM Port B Write Enable (Low  Word)
    MEM_DTIB    => MEM_DTIB,                 -- DPRAM Port B Write Data
    MEM_DTOB    => MEM_DTOB,                 -- DPRAM Port B Read Data
    RST => RST,
    CLK => CLK
    );

pgpg2 : WRITECOMB_CHECK
  port map (
    -- pcicnt input
    MEM_WEHA => MEM_WEHA,
    MEM_WELA => MEM_WELA,
    IS_ERR => GPREG0_ff(31 downto 6),
    RST => GPREG1_ff(0),
    CLK => CLK
    );

pgpg3 : FIFOFIFO
  port map(
    -- pcicnt input
    MEM_ADA  => MEM_ADA,
    MEM_WEHA => MEM_WEHA,
    MEM_WELA => MEM_WELA,
    MEM_DTIA => MEM_DTIA,
    -- output
    MEM_AD   => FIFO_AD,
    MEM_WE   => FIFO_WE,
    MEM_DTI  => FIFO_DTI,
    RST => RST,
    CLK => CLK);


  -- CBUS --------------------------------------------------------(2004/11/23 by T.H.)
  CBUS0(0) <= DMAW_ENABLE(0);  CBUS0(1) <= DMAR_ENABLE(0);
  CBUS1(0) <= DMAW_ENABLE(1);  CBUS1(1) <= DMAR_ENABLE(1);
  CBUS2(0) <= DMAW_ENABLE(2);  CBUS2(1) <= DMAR_ENABLE(2);
  CBUS3(0) <= DMAW_ENABLE(3);  CBUS3(1) <= DMAR_ENABLE(3);
--  PFPGA_PIPE_STS <= CBUS3(7) & CBUS2(7) & CBUS1(7) & CBUS0(7);
--  PFPGA_PIPE_STS <= "1111";
  PFPGA_PIPE_STS <= "111" & CBUS0(7);

  CBUS0(6 downto 2) <= (others=>'Z');
  CBUS1(7 downto 2) <= (others=>'Z');
  CBUS2(7 downto 2) <= (others=>'Z');
  CBUS3(7 downto 2) <= (others=>'Z');
  ----------------------------------------------------------------//

  DBUS <= (others=>'Z') when DBUS_HiZ='1' else DBUS_Port;
  DBUS_idata <= DBUS;

  PFPGA_RST <= GPREG1_ff(3 downto 0);

  -- GPREG0 -----------------------------------------------------(2004/11/23 by T.H.)
--GPREG0_ff(31 downto 6) <-- from WRITECOMB_CHECK
  GPREG0_ff(5 downto 1) <= (others=>'0');
  GPREG0_ff(0) <= BUSY_LOCAL_READ;
  ---------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------
--  CLOCK to Pipeline FPGAs   (by Tsuyoshi Hamada)
--------------------------------------------------------------------------------------------------------------
--           +-------------------------+
--           |          FPGA           |
--  (CK66) ->| -> DCM -> (IOB:FDDRRSE) -> CK66_IFPGA, CK66_PFPGA
--           | CLK-+                   |
--           +-------------------------+
  -- ADJUSTMENT OF CHIP INPUT CLOCK AND DCM CLOCK GENERATION

  dcm_ps_f0 : dcm_ps_f  generic map(PS=>0)
    port map(RST => RST, CLK_IN => CLK, CLK_FB_IN => CK66, CLK_OUT => CK66_DCM);

  xCK66_DCM   <= not CK66_DCM;

  -- OUTPUT CLOCK GENERATION
  ck66_0  : FDDRRSE port map(Q => CK66_PFPGA0,
            D0 => const_1, D1 => const_0, C0 => CK66_DCM,  C1 => xCK66_DCM,  CE => const_1, R => RST, S => const_0);
  ck66_1  : FDDRRSE port map(Q => CK66_PFPGA1,
            D0 => const_1, D1 => const_0, C0 => CK66_DCM,  C1 => xCK66_DCM,  CE => const_1, R => RST, S => const_0);
  ck66_2  : FDDRRSE port map(Q => CK66_PFPGA2,
            D0 => const_1, D1 => const_0, C0 => CK66_DCM,  C1 => xCK66_DCM,  CE => const_1, R => RST, S => const_0);
  ck66_3  : FDDRRSE port map(Q => CK66_PFPGA3,
            D0 => const_1, D1 => const_0, C0 => CK66_DCM,  C1 => xCK66_DCM,  CE => const_1, R => RST, S => const_0);
  ck66_4  : FDDRRSE port map(Q => CK66_IFPGA,
            D0 => const_1, D1 => const_0, C0 => CK66_DCM,  C1 => xCK66_DCM,  CE => const_1, R => RST, S => const_0);

  -------------------
  -- LED
  -------------------
  PLED_OUT(3 downto 0) <= LED_ff(3 downto 0);
  LLED_OUT(2 downto 0) <= LED_ff(6 downto 4);
  LLED_OUT(3) <= LED_ff(7) OR (DSW_OUT(1) AND DSW_OUT(0));

  process(CLK, RST) begin
    if(RST = '1') then
      LED_ff <= "00000000";
    elsif(CLK'event and CLK='1') then
      LED_ff <= not GPREG1_ff(7 downto 0);
    end if;
  end process;


  ----------------------------------------------------------------
  -- Trans Hit_PGPG_REG2_ff (CLK) -> Hit_PGPG_REG2_ff_CK66 (CK66)
  -- Trans Hit_PGPG_REG3_ff (CLK) -> Hit_PGPG_REG3_ff_CK66 (CK66)
  ----------------------------------------------------------------
  Hit_PGPG_REG3_ff_CK66 <= Hit_PGPG_REG3_ff_CK66;
  process(CK66) begin
    if(CK66'event and CK66='1') then
      Hit_PGPG_REG2_ff0 <= Hit_PGPG_REG2_ff;
      Hit_PGPG_REG3_ff0 <= Hit_PGPG_REG3_ff;
    end if;
  end process;

  process(CK66, RST, Hit_PGPG_REG2_ff, Hit_PGPG_REG2_ff0) begin
    if(RST = '1') then
      Hit_PGPG_REG2_ff_CK66 <= '0';
    elsif(CK66'event and CK66='1') then
      if(Hit_PGPG_REG2_ff = '0' AND Hit_PGPG_REG2_ff0 ='1') then
        Hit_PGPG_REG2_ff_CK66 <= '1';
      else
        Hit_PGPG_REG2_ff_CK66 <= '0';
      end if;
    end if;
  end process;

  process(CK66, RST, Hit_PGPG_REG3_ff, Hit_PGPG_REG3_ff0) begin
    if(RST = '1') then
      Hit_PGPG_REG3_ff_CK66 <= '0';
    elsif(CK66'event and CK66='1') then
      if(Hit_PGPG_REG3_ff = '0' AND Hit_PGPG_REG3_ff0 ='1') then
        Hit_PGPG_REG3_ff_CK66 <= '1';
      else
        Hit_PGPG_REG3_ff_CK66 <= '0';
      end if;
    end if;
  end process;


  ----------------------------
  -- CK33 for ChipScope Debug
  ----------------------------
  DEBUG_CS_CLK1 <= DEBUG_CS_CLK0;
  process(CLK, RST) begin
    if(RST = '1') then
      DEBUG_CS_CLK0<= '0';
    elsif(CLK'event and CLK='1') then
      if(DEBUG_CS_CLK1='0') then
        DEBUG_CS_CLK0<= '1';
      else
        DEBUG_CS_CLK0<= '0';
      end if;
    end if;
  end process;


  ----------------------------
  -- Not Used But Need Signals
  ----------------------------

  process(CLK, RST) begin
    if(RST = '1') then
      DSW_OUT(0) <= '1';
      DSW_OUT(1) <= '1';
    elsif(CLK'event and CLK='1') then
      DSW_OUT(0) <= CFG_INIT_B0_iff AND CFG_INIT_B1_iff AND CFG_INIT_B2_iff AND CFG_INIT_B3_iff;
      DSW_OUT(1) <= DEBUG_CS_CLK0;
    end if;
  end process;



end rtl;
