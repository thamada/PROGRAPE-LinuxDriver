-----------------------------------------------
--  pgpg-b3 dual port RAM module (for IMEM)
--      32 bits
--   16384 entries
--  Copyright(c) 2004- by Tsuyoshi Hamada
--  2004/12/02 : 64KB version up for imem by Tsuyoshi Hamada 
--  2004/10/29 : for Jmem by Tsuyoshi Hamada
-----------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;

entity dp32b16384w is
  port (
    clka  : in std_logic;
    wea   : in std_logic;
    addra : in std_logic_vector(13 downto 0);
    dina  : in std_logic_vector(31 downto 0);
    douta : out std_logic_vector(31 downto 0);

    clkb  : in std_logic;
    web   : in std_logic;
    addrb : in std_logic_vector(13 downto 0);
    dinb  : in std_logic_vector(31 downto 0);
    doutb : out std_logic_vector(31 downto 0));

end dp32b16384w;

architecture rtl of dp32b16384w is

component RAMB16_S1_S1
  generic (
         INIT_A : bit_vector := X"0";
         INIT_B : bit_vector := X"0";
         SRVAL_A : bit_vector := X"0";
         SRVAL_B : bit_vector := X"0";
         WRITE_MODE_A : string :="WRITE_FIRST";
         WRITE_MODE_B : string :="WRITE_FIRST");
  port ( doa   : out std_logic_vector(0 downto 0);
         addra : in std_logic_vector(13 downto 0);
         clka  : in std_logic;
         dia   : in std_logic_vector(0 downto 0);
         ena   : in std_logic;
         ssra  : in std_logic;
         wea   : in std_logic;

         dob   : out std_logic_vector(0 downto 0);
         addrb : in std_logic_vector(13 downto 0);
         clkb  : in std_logic;
         dib   : in std_logic_vector(0 downto 0);
         enb   : in std_logic;
         ssrb  : in std_logic;
         web   : in std_logic);
end component;

begin

  forgen1: for i in 0 to 31 generate
    uraml: RAMB16_S1_S1 -- GENERIC MAP(WRITE_MODE=>"WRITE_FIRST");
	      PORT MAP(-- FIFO SIDE --
                       clka=>clka,
                       addra=>addra,
                       dia=>dina(i downto i),
                       doa=>douta(i downto i),
                       ena=>'1',
                       ssra=>'0',
                       wea=>wea,
                       -- LOCAL SIDE --
                       clkb=>clkb,
                       addrb=>addrb,
                       dib=>dinb(i downto i),
                       dob=>doutb(i downto i),
                       enb=>'1',
                       ssrb=>'0',
                       web=>web);
  end generate forgen1;


end rtl;

