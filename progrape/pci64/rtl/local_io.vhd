-- Copyright 2004,2005,2006 by Tsuyoshi Hamada
-- 2006/06/22 : add some comments (T.H)
-- 2006/02/08 : Fixed (T.H)
-- LOCAL IO (READ & WRITE)
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity LOCAL_IO is
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
end LOCAL_IO;
architecture rtl of LOCAL_IO is

component LOCAL_WRITE
  port (
    -- pcicnt input
    MEM_AD  : in std_logic_vector(19 downto 0);
    MEM_WE  : in std_logic;
    MEM_DTI : in std_logic_vector(63 downto 0);

    -- CBUS/DBUS
    DMAW_ENABLE : out std_logic_vector(3 downto 0); -- for 4 pfpga chip
    DBUS_Port : out std_logic_vector(63 downto 0);  -- outside of this module, 1 delay is inserted.
    RST : in  std_logic;
    CLK : in  std_logic
    );
end component;

component LOCAL_READ
  generic ( NBIT_L_ADRO : integer := 3);
  port (
    NPIPE : in std_logic_vector(7 downto 0); -- from PGPG_REG3
    CALC_STS : in std_logic;    -- from PFPGA
    BUSY : out std_logic :='0'; -- to GPREG0

    -- CBUS/DBUS
    DMAR_ENABLE : out std_logic_vector(3 downto 0); -- for 4 pfpga chip
    DBUS_Port : out std_logic_vector(63 downto 0);
    DBUS_idata: in std_logic_vector(63 downto 0);
    DBUS_HiZ  : out std_logic;

    -- DPRAM R/W ports
    MEM_ADB     : out std_logic_vector(12 downto 0);     -- DPRAM Port B R/W Address
    MEM_WEHB    : out std_logic;                         -- DPRAM Port B Write Enable (High Word)
    MEM_WELB    : out std_logic;                         -- DPRAM Port B Write Enable (Low  Word)
    MEM_DTIB    : out std_logic_vector(63 downto 0);     -- DPRAM Port B Write Data

    RST : in  std_logic;
    CLK : in  std_logic
    );
end component;
  signal dbus_port0   : std_logic_vector(63 downto 0) := (others=>'0'); 
-- DMAW
  signal dmaw_dbus_o  : std_logic_vector(63 downto 0) := (others=>'0');
-- DMAR
  signal dmar_dbus_o  : std_logic_vector(63 downto 0) := (others=>'0');
  signal busy_dmar    : std_logic;

begin

  -- DMA BUSY or IDLE
  process (CLK,busy_dmar,CALC_STS) begin
    if(CLK'event and CLK='1') then
      if   (CALC_STS='1' AND busy_dmar='0') then
        BUSY_LOCAL_READ <= '0';
      elsif(CALC_STS='1' AND busy_dmar='1') then
        BUSY_LOCAL_READ <= '1';
      elsif(CALC_STS='1' AND busy_dmar='0') then
        BUSY_LOCAL_READ <= '1';
      elsif(CALC_STS='0') then
        BUSY_LOCAL_READ <= '1';
      end if;
    end if;
  end process;



  ------------------------------
  --- DBUS_Port              ---
  ------------------------------
  process (CLK) begin
    if(CLK'event and CLK='1') then
      DBUS_Port <= dbus_port0;
    end if;
  end process;

  with busy_dmar select
    dbus_port0 <= dmar_dbus_o when '1',
                  dmaw_dbus_o when others;

-------------------------------------------------------------------------------
-- Write : IFPGA --> PFPGAs
-------------------------------------------------------------------------------
u0 : LOCAL_WRITE
  port map (MEM_AD      => MEM_ADA,
            MEM_WE      => MEM_WELA,
            MEM_DTI     => MEM_DTIA,
            DMAW_ENABLE => DMAW_ENABLE,
            DBUS_Port   => dmaw_dbus_o,
            RST         => RST,
            CLK         => CLK);

-------------------------------------------------------------------------------
-- Read : IFPGA <-- PFPGAs
-------------------------------------------------------------------------------
u1 : LOCAL_READ
  generic map (NBIT_L_ADRO => NBIT_L_ADRO)
  port map (NPIPE       => NPIPE,
            CALC_STS    => CALC_STS,
            BUSY        => busy_dmar,
            DMAR_ENABLE => DMAR_ENABLE,
            DBUS_Port   => dmar_dbus_o,
            DBUS_idata  => DBUS_idata,
            DBUS_HiZ    => DBUS_HiZ,
            MEM_ADB     => MEM_ADB,
            MEM_WEHB    => MEM_WEHB,
            MEM_WELB    => MEM_WELB,
            MEM_DTIB    => MEM_DTIB,
            RST         => RST,
            CLK         => CLK);

end rtl;
