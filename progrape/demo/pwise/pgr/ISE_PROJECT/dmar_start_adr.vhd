-- Copyright 2004 Tsuyoshi Hamada
--
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity dmar_start_adr is
  port (
    CLK       : in std_logic;
    DBUS      : in std_logic_vector(63 downto 0);
    STATE     : in std_logic_vector(1 downto 0);
    START_ADR : out std_logic_vector(18 downto 0) );
end dmar_start_adr;

architecture rtl of dmar_start_adr is
component dmaw_start_adr
  port (
    CLK       : in std_logic;
    DBUS      : in std_logic_vector(63 downto 0);
    STATE     : in std_logic_vector(1 downto 0);
    START_ADR : out std_logic_vector(18 downto 0) );
end component;
begin
  u0 : dmaw_start_adr port map(CLK=>CLK, DBUS=>DBUS, STATE=>STATE, START_ADR=>START_ADR);
end rtl;
