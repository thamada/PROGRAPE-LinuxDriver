-- Copyright 2004 Tsuyoshi Hamada
--
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity dmar_mem_re is
  port (
    CLK       : in std_logic;
    STATE     : in std_logic_vector(1 downto 0);
    MEM_RE    : out std_logic );
end dmar_mem_re;

architecture rtl of dmar_mem_re is
component dmaw_mem_we 
  port (
    CLK       : in std_logic;
    STATE     : in std_logic_vector(1 downto 0);
    MEM_WE    : out std_logic );
end component;
begin
 u0 : dmaw_mem_we port map(CLK=>CLK, STATE=>STATE, MEM_WE=>MEM_RE);
end rtl;
