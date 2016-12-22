-- for SPH SecondStage ( JDATA_WIDTH=512)
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity jmem is
  port (
    rst        : in  std_logic; -- not used
    we         : in  std_logic;
    wclk        : in  std_logic;
    wadr        : in  std_logic_vector(15 downto 0);
    rclk        : in  std_logic;
    radr        : in  std_logic_vector(15 downto 0);
    idata      : in  std_logic_vector(63 downto 0);
--    odata      : out  std_logic_vector(127 downto 0)  -- for G5
--    odata      : out  std_logic_vector(223 downto 0)  -- for SPH FirstStage
    odata      : out  std_logic_vector(511 downto 0)  -- for SPH SecondStage
  );
end jmem;

architecture rtl of jmem is
component dpram
	port (
	wadr: IN std_logic_VECTOR(12 downto 0);
	radr: IN std_logic_VECTOR(12 downto 0);
	wclk: IN std_logic;
	rclk: IN std_logic;
	din: IN std_logic_VECTOR(63 downto 0);
	dout: OUT std_logic_VECTOR(63 downto 0);
	we: IN std_logic);
end component;
signal we0,we1,we2,we3 : std_logic;
signal we4,we5,we6,we7 : std_logic;
signal we8,we9,we10,we11 : std_logic;
signal we12,we13,we14,we15 : std_logic;

signal adr0,adr1,nadr0,nadr1 : std_logic;
signal adr2,nadr2,adr3,nadr3 : std_logic;

begin

adr0  <= wadr(0);
nadr0 <= NOT wadr(0);
adr1  <= wadr(1);
nadr1 <= NOT wadr(1);
adr2  <= wadr(2);
nadr2 <= NOT wadr(2);

we0  <= we and nadr2 and nadr1 and nadr0;  -- we & wadr(2,0)="000"
we1  <= we and nadr2 and nadr1 and  adr0;  -- we & wadr(2,0)="001"
we2  <= we and nadr2 and  adr1 and nadr0;  -- we & wadr(2,0)="010"
we3  <= we and nadr2 and  adr1 and  adr0;  -- we & wadr(2,0)="011"

we4  <= we and  adr2 and nadr1 and nadr0;  -- we & wadr(2,0)="100"
we5  <= we and  adr2 and nadr1 and  adr0;  -- we & wadr(2,0)="101"
we6  <= we and  adr2 and  adr1 and nadr0;  -- we & wadr(2,0)="110"
we7  <= we and  adr2 and  adr1 and  adr0;  -- we & wadr(2,0)="111"

u0 : dpram port map(
      wadr=> wadr(15 downto 3),
      wclk=> wclk,
      radr=> radr(15 downto 3),
      rclk=> rclk,
      din => idata,
      dout=> odata(63 downto 0),
      we  => we0);

u1 : dpram port map(
      wadr=> wadr(15 downto 3),
      wclk=> wclk,
      radr=> radr(15 downto 3),
      rclk=> rclk,
      din => idata, 
      dout=> odata(127 downto 64),
      we  => we1);

u2 : dpram port map(
      wadr=> wadr(15 downto 3),
      wclk=> wclk,
      radr=> radr(15 downto 3),
      rclk=> rclk,
      din => idata, 
      dout=> odata(191 downto 128),
      we  => we2);

u3 : dpram port map(
      wadr=> wadr(15 downto 3),
      wclk=> wclk,
      radr=> radr(15 downto 3),
      rclk=> rclk,
      din => idata, 
      dout=> odata(255 downto 192),
      we  => we3);

u4 : dpram port map(
      wadr=> wadr(15 downto 3),
      wclk=> wclk,
      radr=> radr(15 downto 3),
      rclk=> rclk,
      din => idata, 
      dout=> odata(319 downto 256),
      we  => we4);

u5 : dpram port map(
      wadr=> wadr(15 downto 3),
      wclk=> wclk,
      radr=> radr(15 downto 3),
      rclk=> rclk,
      din => idata, 
      dout=> odata(383 downto 320),
      we  => we5);

u6 : dpram port map(
      wadr=> wadr(15 downto 3),
      wclk=> wclk,
      radr=> radr(15 downto 3),
      rclk=> rclk,
      din => idata, 
      dout=> odata(447 downto 384),
      we  => we6);

u7 : dpram port map(
      wadr=> wadr(15 downto 3),
      wclk=> wclk,
      radr=> radr(15 downto 3),
      rclk=> rclk,
      din => idata, 
      dout=> odata(511 downto 448),
      we  => we7);

end rtl;
