-- Copyright 2004 Tsuyoshi Hamada
--
--
--clk         __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __
--[ DBUS ]           X   >< n ><d0 ><d1 ><d2 ><d3 ><d4 ><d5 ><d6 ><d7 >
--dmaw_state          0  >< 1 >< 2                                    >< 3 >< 0 
--dmaw_start_adr               < n                                         >< 0

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity dmaw_start_adr is
  port (
    CLK       : in std_logic;
    DBUS      : in std_logic_vector(63 downto 0);
    STATE     : in std_logic_vector(1 downto 0);
    START_ADR : out std_logic_vector(18 downto 0) );
end dmaw_start_adr;

architecture rtl of dmaw_start_adr is
constant zero : std_logic_vector(18 downto 0) := (others=>'0');
begin

  process (CLK,STATE) begin
    if(CLK'event and CLK = '1') then
      if(STATE="01") then
        START_ADR <= DBUS(18 downto 0);
      elsif((STATE="00") OR (STATE="11")) then
        START_ADR <= zero;
      end if;
    end if;
  end process;

end rtl;
