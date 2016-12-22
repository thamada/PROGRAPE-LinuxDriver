-- Copyright 2004 Tsuyoshi Hamada
--
--
-- clk         __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __
-- [ DBUS ]           X   >< n ><d0 ><d1 ><d2 ><d3 ><d4 ><d5 ><d6 ><d7 >
-- STATE               0  >< 1 >< 2                                    >< 3 >< 0 
-- START_ADR                    < n                                    >
-- x                              0 >< 1 >< 2 >< 3 >< 4 >< 5 >< 6 >< 7 >< 8 >< 0 >
-- z                              1 >< 2 >< 3 >< 4 >< 5 >< 6 >< 7 >< 8 >< 9 >< 1 >
-- mem_adr_inc                    0 >< 1 >< 2 >< 3 >< 4 >< 5 >< 6 >< 7 >< 8 >< 0 >
-- MEM_ADR                           < n ><n+1><n+2><n+3><n+4><n+5><n+6><n+7>

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity dmaw_mem_adr is
  port (
    CLK       : in  std_logic;
    STATE     : in std_logic_vector(1 downto 0);  -- STATE of DMAW
    START_ADR : in std_logic_vector(18 downto 0);
    MEM_ADR   : out  std_logic_vector(18 downto 0)
    );
end dmaw_mem_adr;

architecture rtl of dmaw_mem_adr is

signal mem_adr_inc : std_logic_vector(18 downto 0);
signal   x,z : std_logic_vector(18 downto 0);
constant one : std_logic_vector(18 downto 0) := "0000000000000000001";

begin

  z <= x + one;

  -----------------
  -- mem_adr_inc
  -----------------
  process (CLK,STATE) begin
    if(clk'event and clk = '1') then
      if(STATE = "10") then
        mem_adr_inc <= z;
      else
        mem_adr_inc <= (others=>'0');
      end if;
    end if;
  end process;

  x <= mem_adr_inc;

  -----------------
  -- MEM_ADR
  -----------------
  process (CLK,STATE) begin
    if(clk'event and clk = '1') then
      if(STATE="10") then
        MEM_ADR <= mem_adr_inc + START_ADR;
      else
        MEM_ADR <= (others=>'0');
      end if;
    end if;
  end process;

end rtl;
