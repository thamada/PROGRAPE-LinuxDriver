-- Copyright 2004 Tsuyoshi Hamada
--
--
--
-- DMAR_STATE is used only 
--                dmar_mem_adr.vhd  
--                dmar_mem_re.vhd
--                dmar_start_adr.vhd
-- dmar_dbus_hiz and dma_mem_data do not used DMAR_STATE.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity dmar_state is
  port (
    RST      : in std_logic;
    CLK      : in std_logic;
    ENABLE   : in std_logic;
    STATE    : out std_logic_vector(1 downto 0) );
end dmar_state;

architecture rtl of dmar_state is

component dmaw_state
  port (
    RST      : in std_logic;
    CLK      : in std_logic;
    ENABLE   : in std_logic;
    STATE    : out std_logic_vector(1 downto 0) );
end component;

begin
  u0 : dmaw_state port map(RST=>RST, CLK=>CLK, ENABLE=>ENABLE, STATE=>STATE);
end rtl;
