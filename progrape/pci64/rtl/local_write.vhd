-- LOCAL WRITE ( ifpga -> pfpga )
-- by Tsuyoshi Hamada
--
-- CLK     __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ 
-- MEM_WE            __/~~~~~~~~~~\_____ 
-- MEM_AD              < a0 >< a1 >
-- MEM_DTI             < d0 >< d1 >
-- DMAW_ENABLE                      __/~~~~~~~~~~\___  
-- DBUS_Port                     < a0 >< d0 >< d1 >

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity LOCAL_WRITE is
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
end LOCAL_WRITE;

architecture rtl of LOCAL_WRITE is

  signal we0  : std_logic := '0';
  signal we1  : std_logic := '0';
  signal adr          : std_logic_vector(63 downto 0) := (others=>'0');
  signal data0,data1 : std_logic_vector(63 downto 0) := (others=>'0');
  signal dbus_o       : std_logic_vector(63 downto 0) := (others=>'0');

begin
  ------------------------------
  --- we0,1                  ---
  ------------------------------
  process (RST,CLK) begin
    if(RST='1') then
      we0 <= '0';
    elsif(CLK'event and CLK='1') then
      we0 <= MEM_WE;
    end if;
  end process;

  process (CLK) begin
    if(CLK'event and CLK='1') then
      we1 <= we0;
    end if;
  end process;
  
  ------------------------------
  --- adr                    ---
  ------------------------------
  process (RST,CLK,MEM_WE,we0) begin
    if(RST='1') then
      adr <= (others=>'0');
    elsif(CLK'event and CLK='1') then
      if((MEM_WE = '1') and (we0 = '0')) then
        adr(18 downto 0) <= MEM_AD(19 downto 1);
      end if;
      adr(63 downto 19) <= (others=>'0');
    end if;
  end process;

  ------------------------------
  --- data delay             ---
  ------------------------------
  process (RST,CLK) begin
    if(RST='1') then
      data1 <= (others=>'0');
      data0 <= (others=>'0');
    elsif(CLK'event and CLK='1') then
      data1 <= data0;
      data0 <= MEM_DTI;
    end if;
  end process;

  ------------------------------
  --- DBUS_Port              ---
  ------------------------------
  process (RST,CLK,we0,we1) begin
    if(RST='1') then
      DBUS_Port <= (others=>'0');
    elsif(CLK'event and CLK='1') then
      if(we0 = '1' and we1 = '0') then
        DBUS_Port <= adr;
      else
        DBUS_Port <= data1;
      end if;
    end if;
  end process;

  --- DMAW_ENABLE
  process (RST,CLK) begin
    if(RST='1') then
      DMAW_ENABLE    <= (others=>'0');
    elsif(CLK'event and CLK='1') then
      DMAW_ENABLE(0) <= we1;
      DMAW_ENABLE(1) <= we1;
      DMAW_ENABLE(2) <= we1;
      DMAW_ENABLE(3) <= we1;
    end if;
  end process;


end rtl;
