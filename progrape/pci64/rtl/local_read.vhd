-- Copyright 2004,2005,2006 by Tsuyoshi Hamada
-- 2006/06/22 : add some comments (T.H)
-- 2006/02/08 : Fixed (T.H)

-- LOCAL READ ( ifpga <- pfpga )
-- by Tsuyoshi Hamada
-- (��) l_adro�̃r�b�g��(NBIT_L_ADRO)��ς����ꍇ��prom���Ă��Ȃ����K�v�����邱�Ƃɒ���.(�����̂͏�̃��W���[��)
-- (��) ���������̑O��FLOCAL_READ��PFPGA0�����PIPE_STS�M��(CBUS0(7))���g�����U�N�V�����J�n�M���Ƃ��Ă��܂��B

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity LOCAL_READ is
  generic ( NBIT_L_ADRO : integer := 3);
  port (
    NPIPE : in std_logic_vector(7 downto 0); -- from PGPG_REG3
    CALC_STS : in std_logic;    -- from PFPGA
    BUSY : out std_logic :='1'; -- to GPREG0 (default '1'!! => Waiting until pipe calc end)

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
end LOCAL_READ;

architecture rtl of LOCAL_READ is

component LOCAL_READ_CNT
  generic (CNT_WIDTH     : integer := 16;      -- program counter bit-width
           FO_BASE       : integer := 24576;   -- = 0x6000
           NBIT_L_ADRO   : integer := 3;       -- Bit-Length of l_ado(pgpg_mem.vhd)
           INTF_LAT      : integer := 8);      -- LOCAL_READ_IF latency (clock)
  port (
    NPIPE : in std_logic_vector(7 downto 0);   -- number of pipelines per chip
    CALC_DONE  : in std_logic;                 -- pulse
    FETCH_DONE : out std_logic;
    EXEC     : out std_logic;                     -- pulse
    START_AD : out std_logic_vector(18 downto 0); -- 19 bit
    NQWORD   : out std_logic_vector( 8 downto 0); --  9 bit
    CHIPSEL  : out std_logic_vector( 3 downto 0); --  4 bit
    MEM_AD_BASE : out std_logic_vector(12 downto 0);
    RST : in  std_logic;
    CLK : in  std_logic
    );
end component;

component LOCAL_READ_IF
  port (
    EXEC : in std_logic;
    START_AD : in std_logic_vector(18 downto 0);
    NQWORD   : in std_logic_vector( 8 downto 0);
    CHIPSEL  : in std_logic_vector( 3 downto 0);
    MEM_AD_BASE : in std_logic_vector(12 downto 0);
    BUSY : out std_logic;  -- to GPREG0
    DMAR_ENABLE : out std_logic_vector(3 downto 0);
    DBUS_Port : out std_logic_vector(63 downto 0);
    DBUS_idata: in std_logic_vector(63 downto 0);
    DBUS_HiZ  : out std_logic;
    MEM_ADB     : out std_logic_vector(12 downto 0);
    MEM_WEHB    : out std_logic;
    MEM_WELB    : out std_logic;
    MEM_DTIB    : out std_logic_vector(63 downto 0);
    RST : in  std_logic;
    CLK : in  std_logic
    );
end component;

signal calc_done : std_logic :='0';   -- to cnt
signal csts0,csts1 : std_logic :='0'; -- from pfpga

-- CNT
signal fetch_done : std_logic :='0';
signal exec : std_logic;                          -- cnt -> if
signal start_ad : std_logic_vector(18 downto 0);  -- cnt -> if
signal nqword   : std_logic_vector( 8 downto 0);  -- cnt -> if
signal chipsel  : std_logic_vector( 3 downto 0);  -- cnt -> if
signal mem_base : std_logic_vector(12 downto 0);  -- cnt -> if
-- IF
signal ignore_busy : std_logic; 

begin

  -- CALC STATUS
  csts0 <= CALC_STS;
  process (CLK) begin
    if (CLK'event and CLK='1') then
      csts1 <= csts0;
    end if;
  end process;

  -- CALC DONE
  process (RST,CLK,csts0,csts1) begin
    if(RST='1') then
      calc_done <= '0';
    elsif (CLK'event and CLK='1') then
      if((csts0='1') AND (csts1='0')) then
        calc_done <= '1';
      else
        calc_done <= '0';
      end if;
    end if;
  end process;

  -- BUSY
  process (RST,CLK,csts0,csts1,fetch_done) begin
    if (RST='1') then
      BUSY <='1';
    elsif (CLK'event and CLK='1') then
      if((csts0='1') AND (csts1='0')) then
        BUSY <= '1';
      elsif(fetch_done='1') then
        BUSY <= '0';
      end if;
    end if;
  end process;

  -- =================================================== SUBMODULE INSTANCES
  u0: LOCAL_READ_CNT 
    generic map(NBIT_L_ADRO => NBIT_L_ADRO)
    port map(NPIPE => NPIPE,
             CALC_DONE => calc_done,
             FETCH_DONE => fetch_done,
             EXEC       => exec,
             START_AD   => start_ad,
             NQWORD     => nqword,
             CHIPSEL    => chipsel,
             MEM_AD_BASE => mem_base,
             RST => RST, CLK=>CLK);


  u1: LOCAL_READ_IF
    port map(EXEC        => exec,     -- from cnt
             START_AD    => start_ad, -- from cnt
             NQWORD      => nqword,   -- from cnt
             CHIPSEL     => chipsel,  -- from cnt
             MEM_AD_BASE => mem_base, -- from cnt
             BUSY => ignore_busy,
             DMAR_ENABLE => DMAR_ENABLE, -- output directly
             DBUS_Port   => DBUS_Port,   -- output directly
             DBUS_idata  => DBUS_idata,  -- output directly
             DBUS_HiZ    => DBUS_HiZ,    -- output directly
             MEM_ADB  => MEM_ADB,        -- output directly
             MEM_WEHB => MEM_WEHB,       -- output directly
             MEM_WELB => MEM_WELB,       -- output directly
             MEM_DTIB => MEM_DTIB,       -- output directly
             RST=>RST,CLK=>CLK);


end rtl;
