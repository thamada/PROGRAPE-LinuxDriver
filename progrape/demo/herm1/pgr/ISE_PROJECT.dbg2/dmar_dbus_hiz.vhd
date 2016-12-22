-- Copyright 2004 Tsuyoshi Hamada
--
--
--clk         __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __
--[DMAR_ENABLE] _____/~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\______________
--en0                _____/~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\______________
--en1                     _____/~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\______________
--en2                          _____/~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\______________
--en3                               _____/~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\______________
--DBUS_HiZ            ~~~~~~~~~~~~~~\_________________________________________________/~~~~

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity dmar_dbus_hiz is
  port (
    RST       : in std_logic;
    CLK       : in std_logic;
    ENABLE    : in std_logic;
    DBUS_HiZ  : out std_logic :='1');
end dmar_dbus_hiz;

architecture rtl of dmar_dbus_hiz is
signal en0,en1,en2,en3 : std_logic :='0';
begin

  process(CLK) begin
    if(CLK'event and CLK = '1') then
      en3 <= en2;
      en2 <= en1;
      en1 <= en0;
      en0 <= ENABLE;
    end if;
  end process;


  process(RST,CLK,en2,en3) begin
    if(RST='1') then
      DBUS_HiZ <= '1';
    elsif(CLK'event and CLK = '1') then
     if( (en1='1') AND (en2='0') ) then
       DBUS_HiZ <= '0';
     elsif( (en2='0') AND (en3='1') ) then
       DBUS_HiZ <= '1';
     end if;
    end if;
  end process;

end rtl;
