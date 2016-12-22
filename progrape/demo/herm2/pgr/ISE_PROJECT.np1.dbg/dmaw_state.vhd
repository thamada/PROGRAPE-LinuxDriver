-- Copyright 2004 Tsuyoshi Hamada
--
--
--clk         __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __
--[dma_we]    _______/~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\______________
--state_dmaw          0  >< 1 >< 2                                    >< 3 >< 0 

-- 0->1 : if((state==0)&&(dma_we==1))
-- 1->2 : if (state==1)
-- 2->3 : if((state==2) &&(dma_we==0))
-- 3->0 : if (state==3)

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity dmaw_state is
  port (
    RST      : in std_logic;
    CLK      : in std_logic;
    ENABLE   : in std_logic;
    STATE    : out std_logic_vector(1 downto 0) );
end dmaw_state;

architecture rtl of dmaw_state is

signal state_ff : std_logic_vector(1 downto 0);
begin

  STATE <= state_ff;

  process (RST,CLK,ENABLE,state_ff) begin
    if(RST='1') then
      state_ff <= (others=>'0');
    elsif(CLK'event and CLK = '1') then
      if((state_ff="00") AND (ENABLE='1')) then
        state_ff <= "01";
      elsif(state_ff = "01") then
        state_ff <= "10";
      elsif((state_ff = "10") AND (ENABLE='0')) then
        state_ff <= "11";
      elsif((state_ff = "10") AND (ENABLE='1')) then
        state_ff <= "10";
      else -- if(state_ff = "11") then
        state_ff <= "00";
      end if;
    end if;
  end process;

end rtl;
