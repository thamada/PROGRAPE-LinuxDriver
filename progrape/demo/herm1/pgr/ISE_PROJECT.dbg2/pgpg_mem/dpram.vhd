-----------------------------------------------
--  PGR dual port RAM module (for JDIM 16)
--     64 bits
--   1024 entries
--  Copyright(c) 2006- by Tsuyoshi Hamada
--  2006/02/06 by Tsuyoshi Hamada
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

entity dpram is
  port (
    wadr: in std_logic_vector(12 downto 0);
    radr: in std_logic_vector(12 downto 0);
    wclk: in std_logic;
    rclk: in std_logic;
    din: in std_logic_vector(63 downto 0);
    dout: out std_logic_vector(63 downto 0);
    we: in std_logic);
end dpram;

architecture rtl of dpram is
component RAMB16_S18_S18
  generic (
         INIT_A : bit_vector := X"0";
         INIT_B : bit_vector := X"0";
         SRVAL_A : bit_vector := X"0";
         SRVAL_B : bit_vector := X"0";
         WRITE_MODE_A : string :="WRITE_FIRST";
         WRITE_MODE_B : string :="WRITE_FIRST");
  port ( doa   : out std_logic_vector(15 downto 0);
         addra : in std_logic_vector(9 downto 0);
         clka  : in std_logic;
         dia   : in std_logic_vector(15 downto 0);
         ena   : in std_logic;
         ssra  : in std_logic;
         wea   : in std_logic;

         dipa  : in  std_logic_vector(1 downto 0); --
         dopa  : out std_logic_vector(1 downto 0); --
         dipb  : in  std_logic_vector(1 downto 0); --
         dopb  : out std_logic_vector(1 downto 0); --

         dob   : out std_logic_vector(15 downto 0);
         addrb : in std_logic_vector(9 downto 0);
         clkb  : in std_logic;
         dib   : in std_logic_vector(15 downto 0);
         enb   : in std_logic;
         ssrb  : in std_logic;
         web   : in std_logic);
end component;

begin

  forgen1: for i in 0 to 3 generate
    uram: RAMB16_S18_S18 -- GENERIC MAP(WRITE_MODE=>"WRITE_FIRST");
	      PORT MAP(-- UNUSED
                       doa   => open,
                       dipa  => (others=>'0'),
                       dopa  => open,
                       dipb  => (others=>'0'),
                       dopb  => open,
                       -- WRITE SIDE --
                       addra=>wadr(9 downto 0), clka=>wclk,
                       dia=>din(((16*i)+15) downto 16*i),
                       ena=>'1',ssra=>'0',
                       wea=>we,
                       -- READ SIDE --
                       addrb=>radr(9 downto 0), clkb=>rclk,
                       dib=>din(((16*i)+15) downto 16*i), dob=>dout(((16*i)+15) downto 16*i),
                       enb=>'1',ssrb=>'0',
                       web=>'0');
  end generate forgen1;


end rtl;

