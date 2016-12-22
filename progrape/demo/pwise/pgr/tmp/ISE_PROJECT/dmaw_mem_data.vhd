-- Copyright 2004 Tsuyoshi Hamada
--
--
--clk         __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __
--[dma_we]    _______/~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\______________
--[ DBUS ]           X   >< n ><d0 ><d1 ><d2 ><d3 ><d4 ><d5 ><d6 ><d7 >
--state_dmaw          0  >< 1 >< 2                                    >< 3 >< 0 
--mem_data                          <d0 ><d1 ><d2 ><d3 ><d4 ><d5 ><d6 ><d7 >

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity dmaw_mem_data is
  port (
    CLK      : in std_logic;
    DBUS     : in std_logic_vector(63 downto 0);
    STATE    : in std_logic_vector(1 downto 0);
    MEM_DATA : out std_logic_vector(63 downto 0) );
end dmaw_mem_data;

architecture rtl of dmaw_mem_data is
constant zero : std_logic_vector(63 downto 0) := (others=>'0');
begin

  process (CLK,STATE) begin
    if(CLK'event and CLK = '1') then
      if(STATE="10") then
        MEM_DATA <= DBUS;
      else
        MEM_DATA <= zero;
      end if;
    end if;
  end process;

end rtl;
