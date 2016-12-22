-- Copyright 2004 Tsuyoshi Hamada
--
--
--clk         __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __
--[ENABLE]    _______/~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\______________
--[ DBUS ]          >< n ><d0 ><d1 ><d2 ><d3 ><d4 ><d5 ><d6 ><d7 >

--  ena0      _______/~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\______________
--  ena1           _______/~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\______________
--[ DBUS ]          >< n ><d0 ><d1 ><d2 ><d3 ><d4 ><d5 ><d6 ><d7 >
-- acnt                0 >< n ><n+1><n+2><n+3><n+4><n+5><n+6><n+7>< 0
--MEM_ADR                   0 >< n ><n+1><n+2><n+3><n+4><n+5><n+6><n+7>< 0
--MEM_DATA                     <d0 ><d1 ><d2 ><d3 ><d4 ><d5 ><d6 ><d7 >
--MEM_WE                   ____/~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\______

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity dmaw is
  port (
    RST       : in std_logic;
    CLK       : in std_logic;
    ENABLE    : in std_logic;
    DBUS      : in std_logic_vector(63 downto 0);
    MEM_WE    : out std_logic;
    MEM_ADR   : out std_logic_vector(18 downto 0);
    MEM_DATA  : out std_logic_vector(63 downto 0)   );
end dmaw;

architecture rtl of dmaw is

signal ena0,ena1,ena2,ena3,ena4 : std_logic :='0';
signal acnt,acntr : std_logic_vector(18 downto 0) :=(others=>'0');
signal we : std_logic :='0';

begin

  -- MEM_DATA --
  process (CLK) begin
    if(CLK'event and CLK = '1') then
      MEM_DATA <= DBUS;
    end if;
  end process;

  -- MEM_WE --
  process (CLK) begin
    if(CLK'event and CLK = '1') then
      MEM_WE <= ena1;
    end if;
  end process;

  -- MEM_ADR --
  process (CLK) begin
    if(CLK'event and CLK = '1') then
      MEM_ADR <= acnt;
    end if;
  end process;

  -- acnt
  acntr <= acnt;
  process (RST,CLK,ena0,ena1) begin
    if(RST = '1') then
      acnt  <= (others=>'0');
    elsif(CLK'event and CLK = '1') then
      if((ena0='1') AND (ena1='0')) then
        acnt <= DBUS(18 downto 0);
      elsif((ena0='1') AND (ena1='1')) then
        acnt <= acntr + "0000000000000000001";
      else
        acnt <= (others=>'0');
      end if;
    end if;
  end process;



  -- ENABLE delays
  ena0 <= ENABLE;
  process (CLK) begin
    if(CLK'event and CLK = '1') then
      ena4 <= ena3;
      ena3 <= ena2;
      ena2 <= ena1;
      ena1 <= ena0;
    end if;
  end process;


end rtl;
