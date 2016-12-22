-- Copyright 2004 Tsuyoshi Hamada
--
--clk         __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~
--WE         _______/~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\________
--WAD                < n ><n+1><n+2><n+3><n+4><n+5><n+6><n+7>
--WDT(from Host)     <d0 ><d1 ><d2 ><d3 ><d4 ><d5 ><d6 ><d7 >
--RE          _______/~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\_______
--RAD                < n ><n+1><n+2><n+3><n+4><n+5><n+6><n+7>
--RDT(from User)          <ud0><ud1><ud2><ud3><ud4><ud5><ud6><ud7>

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity user is
  port (
      FPGA_NO : in std_logic_vector(1 downto 0);
      RST : in std_logic;
      CLK  : in std_logic;
      PCLK : in std_logic;
      WE  : in std_logic;
      RE  : in std_logic;
      WAD : in std_logic_vector(18 downto 0);
      WDT : in std_logic_vector(63 downto 0);
      RAD : in std_logic_vector(18 downto 0);
      RDT : out std_logic_vector(63 downto 0);
      STS : out std_logic);
end user;

architecture rtl of user is

component pgpg_mem
  port (
    RST           : in  std_logic;
    SYS_CLK       : in  std_logic;
    PIPE_CLK      : in  std_logic;
    ADR           : in  std_logic_vector(18 downto 0);
    WE            : in  std_logic;
    DTI           : in  std_logic_vector(63 downto 0);
    DTO           : out std_logic_vector(63 downto 0);
    STS           : out std_logic;
    FPGA_NO       : in std_logic_vector(1 downto 0));
end component;

signal RWAD : std_logic_vector(18 downto 0);

begin

------------------------------------------ bugfixed 2004/11/23 by T.H.
--process(WE) begin
--  if(WE='1') then
--    RWAD <= WAD;
--  else
--    RWAD <= RAD;
--  end if;
--end process;

with WE select
  RWAD <= WAD when '1',
          RAD when '0',
          (others=>'0') when others;
------------------------------------------//

u0 : pgpg_mem port map(
       RST => RST,
       SYS_CLK  => CLK,
       PIPE_CLK => PCLK,
       ADR => RWAD,
       WE  => WE,
       DTI => WDT,
       DTO => RDT,
       STS => STS,
       FPGA_NO => FPGA_NO);

end rtl;
