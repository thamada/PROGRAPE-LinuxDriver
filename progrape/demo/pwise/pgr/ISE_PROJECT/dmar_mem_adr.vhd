-- Copyright 2004 Tsuyoshi Hamada
--
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity dmar_mem_adr is
  port (
    CLK       : in  std_logic;
    STATE     : in std_logic_vector(1 downto 0);
    START_ADR : in std_logic_vector(18 downto 0);
    MEM_ADR   : out  std_logic_vector(18 downto 0)
    );
end dmar_mem_adr;

architecture rtl of dmar_mem_adr is
component dmaw_mem_adr
  port (
    CLK       : in  std_logic;
    STATE     : in std_logic_vector(1 downto 0);  -- STATE of DMAW
    START_ADR : in std_logic_vector(18 downto 0);
    MEM_ADR   : out  std_logic_vector(18 downto 0)
    );
end component;
begin
  u0 : dmaw_mem_adr port map(CLK=>CLK, STATE=>STATE, START_ADR=>START_ADR, MEM_ADR=>MEM_ADR);
end rtl;
