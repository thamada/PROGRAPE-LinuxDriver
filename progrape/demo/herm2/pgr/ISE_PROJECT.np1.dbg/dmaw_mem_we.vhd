-- Copyright 2004 Tsuyoshi Hamada
--
--
--clk         __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __
--state_dmaw          0  >< 1 >< 2                                    >< 3 >< 0 
--mem_we                        ____/~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\______

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity dmaw_mem_we is
  port (
    CLK       : in std_logic;
    STATE     : in std_logic_vector(1 downto 0);
    MEM_WE    : out std_logic );
end dmaw_mem_we;

architecture rtl of dmaw_mem_we is

begin

  process (CLK,STATE) begin
    if(CLK'event and CLK = '1') then
      if(STATE="10") then
        MEM_WE <= '1';
      else
        MEM_WE <= '0';
      end if;
    end if;
  end process;

end rtl;
