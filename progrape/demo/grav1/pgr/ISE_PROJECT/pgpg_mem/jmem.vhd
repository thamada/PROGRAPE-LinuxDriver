-- Copyright (c) by PGR project
-- All rights reserved.
-- Auther Tsuyoshi Hamada
-- for JDIM=4 (JDATA_WIDTH =< 128)
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity jmem is
  port (
    rst        : in  std_logic; -- not used
    we         : in  std_logic;
    wclk       : in  std_logic;
    wadr       : in  std_logic_vector(15 downto 0);
    rclk       : in  std_logic;
    radr       : in  std_logic_vector(15 downto 0);
    idata      : in  std_logic_vector(63 downto 0);
    odata      : out  std_logic_vector(127 downto 0)  -- for G5
--  odata      : out  std_logic_vector(255 downto 0)  -- for SPH FirstStage
--  odata      : out  std_logic_vector(511 downto 0)  -- for SPH SecondStage
  );
end jmem;

architecture rtl of jmem is

component dpram
	port (
	wadr: IN std_logic_VECTOR(14 downto 0);
	radr: IN std_logic_VECTOR(14 downto 0);
	wclk: IN std_logic;
	rclk: IN std_logic;
	din: IN std_logic_VECTOR(63 downto 0);
	dout: OUT std_logic_VECTOR(63 downto 0);
	we: IN std_logic);
end component;

signal we0,we1,we2,we3 : std_logic;
signal adr0,adr1,nadr0,nadr1 : std_logic;

begin

adr0  <= wadr(0);
nadr0 <= NOT wadr(0);

we0  <= we and nadr0;  -- we & wadr(0)="0"
we1  <= we and  adr0;  -- we & wadr(0)="1"

u0 : dpram port map(
      wadr=> wadr(15 downto 1),
      wclk=> wclk,
      radr=> radr(15 downto 1),
      rclk=> rclk,
      din => idata,
      dout=> odata(63 downto 0),
      we  => we0);

u1 : dpram port map(
      wadr=> wadr(15 downto 1),
      wclk=> wclk,
      radr=> radr(15 downto 1),
      rclk=> rclk,
      din => idata, 
      dout=> odata(127 downto 64),
      we  => we1);

end rtl;
