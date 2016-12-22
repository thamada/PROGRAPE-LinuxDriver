library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;


entity PFPGA_DMA is
  port (
    -- pcicnt input
    MEM_AD  : in std_logic_vector(16 downto 0);     -- DPRAM Port B R/W Address
    MEM_WE  : in std_logic;
    MEM_WE  : in std_logic;
    MEM_DTI : in std_logic_vector(63 downto 0);

    -- CBUS/DBUS
    DMAW_ENABLE : out std_logic_vector(3 downto 0); -- for 4 pfpga chip
    DBUS_Port : out std_logic_vector(63 downto 0);

    RST : in  std_logic;
    CLK : in  std_logic
    );
end PFPGA_DMA;

architecture rtl of PFPGA_DMA is

-----------------------------------------------------------------
-- DMAW
  signal mem_wea   : std_logic := '0';
  signal dmaw_we0  : std_logic := '0';
  signal dmaw_we1  : std_logic := '0';
  signal dmaw_adr          : std_logic_vector(63 downto 0) := (others=>'0');
  signal dmaw_dt0,dmaw_dt1 : std_logic_vector(63 downto 0) := (others=>'0');
  signal dmaw_dbus_o       : std_logic_vector(63 downto 0) := (others=>'0');

begin

-- WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
-- DMA WRITE ( ifpga -> pfpga )
-- WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
  ------------------------------
  --- mem_wea                ---
  ------------------------------
  mem_wea <= MEM_WE;

  ------------------------------
  --- dmaw_we0,1             ---
  ------------------------------
  process (RST,CLK) begin
    if(RST='1') then
      dmaw_we0 <= '0';
    elsif(CLK'event and CLK='1') then
      dmaw_we0 <= mem_wea;
    end if;
  end process;

  process (CLK) begin
    if(CLK'event and CLK='1') then
      dmaw_we1 <= dmaw_we0;
    end if;
  end process;
  
  ------------------------------
  --- dmaw_adr               ---
  ------------------------------
  process (RST,CLK,mem_wea,dmaw_we0) begin
    if(RST='1') then
      dmaw_adr <= (others=>'0');
    elsif(CLK'event and CLK='1') then
      if((mem_wea = '1') and (dmaw_we0 = '0')) then
        dmaw_adr(15 downto 0) <= MEM_AD(16 downto 1);
      end if;
      dmaw_adr(63 downto 16) <= (others=>'0');
    end if;
  end process;

  ------------------------------
  --- dmaw_dt delay          ---
  ------------------------------
  process (RST,CLK) begin
    if(RST='1') then
      dmaw_dt1 <= (others=>'0');
      dmaw_dt0 <= (others=>'0');
    elsif(CLK'event and CLK='1') then
      dmaw_dt1 <= dmaw_dt0;
      dmaw_dt0 <= MEM_DTI;
    end if;
  end process;

  ------------------------------
  --- dmaw_dbus_o            ---
  ------------------------------
  process (RST,CLK,dmaw_we0,dmaw_we1) begin
    if(RST='1') then
      dmaw_dbus_o <= (others=>'0');
    elsif(CLK'event and CLK='1') then
      if(dmaw_we0 = '1' and dmaw_we1 = '0') then
        dmaw_dbus_o <= dmaw_adr;
      else
        dmaw_dbus_o <= dmaw_dt1;
      end if;
    end if;
  end process;

  --- DMAW_ENABLE
  process (RST,CLK) begin
    if(RST='1') then
      DMAW_ENABLE    <= (others=>'0');
    elsif(CLK'event and CLK='1') then
      DMAW_ENABLE(0) <= dmaw_we1;
      DMAW_ENABLE(1) <= dmaw_we1;
      DMAW_ENABLE(2) <= dmaw_we1;
      DMAW_ENABLE(3) <= dmaw_we1;
    end if;
  end process;


end rtl;
