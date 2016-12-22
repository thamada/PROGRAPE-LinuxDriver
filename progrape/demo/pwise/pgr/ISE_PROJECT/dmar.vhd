-- Copyright 2004 Tsuyoshi Hamada
--
--
--clk         __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __
--[ENABLE]    _______/~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\______________
--DBUS               X   >< n ><HHH>----------<d0 ><d1 ><d2 ><d3 ><d4 ><d5 ><d6 ><d7 >
--DBUS_Port                              <d0 ><d1 ><d2 ><d3 ><d4 ><d5 ><d6 ><d7 >
--DBUS_HiZ           ~~~~~~~~~~~~~~~\_________________________________________________/~~~~
--MEM_RE                        ____/~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\______
--MEM_ADR                        0 >< n ><n+1><n+2><n+3><n+4><n+5><n+6><n+7>< 0
--MEM_DATA                               <d0 ><d1 ><d2 ><d3 ><d4 ><d5 ><d6 ><d7 >

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity dmar is
  port (
    RST       : in std_logic;
    CLK       : in std_logic;
    ENABLE    : in std_logic;
    DBUS      : in std_logic_vector(63 downto 0);
    DBUS_Port : out std_logic_vector(63 downto 0);
    DBUS_HiZ  : out std_logic;
    MEM_RE    : out std_logic;
    MEM_ADR   : out std_logic_vector(18 downto 0);
    MEM_DATA  : in std_logic_vector(63 downto 0)  ); 
end dmar;

architecture rtl of dmar is

component dmar_dbus_hiz
  port (
    RST       : in std_logic;
    CLK       : in std_logic;
    ENABLE    : in std_logic;
    DBUS_HiZ  : out std_logic);
end component;

component dmar_state
  port (
    RST      : in std_logic;
    CLK      : in std_logic;
    ENABLE   : in std_logic;
    STATE    : out std_logic_vector(1 downto 0) );
end component;

component dmar_start_adr
  port (
    CLK       : in std_logic;
    DBUS      : in std_logic_vector(63 downto 0);
    STATE     : in std_logic_vector(1 downto 0);
    START_ADR : out std_logic_vector(18 downto 0) );
end component;

component dmar_mem_adr
  port (
    CLK       : in  std_logic;
    STATE     : in std_logic_vector(1 downto 0);  -- STATE of DMAW
    START_ADR : in std_logic_vector(18 downto 0);
    MEM_ADR   : out  std_logic_vector(18 downto 0)
    );
end component;


component dmar_mem_re
  port (
    CLK       : in std_logic;
    STATE     : in std_logic_vector(1 downto 0);
    MEM_RE    : out std_logic );
end component;

signal state : std_logic_vector(1 downto 0);
signal start_adr : std_logic_vector(18 downto 0);

begin

-- DBUS�̃g���C�X�e�[�g�����͏�ʂōs��
-- DBUS <= (others=>'Z') when DBUS_HiZ = '1' else DBUS_Port;

 u0 : dmar_state     port map(RST=>RST, CLK=>CLK,     ENABLE=>ENABLE,       STATE=>state);
 u1 : dmar_start_adr port map(CLK=>CLK, STATE=>state, DBUS=>DBUS,           START_ADR=>start_adr);
 u2 : dmar_mem_adr   port map(CLK=>CLK, STATE=>state, START_ADR=>start_adr, MEM_ADR  => MEM_ADR);
 u3 : dmar_mem_re    port map(CLK=>CLK, STATE=>state,                       MEM_RE   => MEM_RE);

 u4 : dmar_dbus_hiz  port map(RST=>RST, CLK=>CLK,     ENABLE=>ENABLE,       DBUS_HiZ=>DBUS_HiZ);
 DBUS_Port <= MEM_DATA;


end rtl;
