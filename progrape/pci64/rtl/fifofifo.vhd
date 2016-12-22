-- Copyright 2004-2005 Tsuyoshi Hamada
--clk         __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __
--MEM_WEHA         _______/~~~~\__________
--MEM_WELA    _______/~~~~\__________
--MEM_DTIA[L]        < L  >              
--MEM_DTIA[H]             < H  >              
--wait             _______/~~~~~~~~~\__________
--dtl

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;


entity FIFOFIFO is
  port (
    -- pcicnt input
    MEM_ADA  : in std_logic_vector(19 downto 0);     -- DPRAM Port B R/W Address
    MEM_WEHA : in std_logic;
    MEM_WELA : in std_logic;
    MEM_DTIA : in std_logic_vector(63 downto 0);
    -- output
    MEM_AD     : out std_logic_vector(31 downto 0);
    MEM_WE     : out std_logic;
    MEM_DTI    : out std_logic_vector(63 downto 0);

    RST : in  std_logic;
    CLK : in  std_logic
    );
end FIFOFIFO;

architecture rtl of FIFOFIFO is
  signal we   : std_logic :='0'; 
  signal adr  : std_logic_vector(19 downto 0) := (others=>'0'); 
  signal data : std_logic_vector(63 downto 0) := (others=>'0'); 
begin

  MEM_AD(31 downto 20) <= (others=>'0');
  MEM_AD(19 downto 0) <= adr;

  MEM_WE <= we;
  MEM_DTI <= data;


  process (RST,CLK,MEM_WEHA,MEM_WELA) begin
    if(RST='1') then
      adr <= (others=>'0');
    elsif (CLK'event and CLK='1') then
      if(MEM_WEHA='1' AND MEM_WELA='1') then
        adr <= MEM_ADA(19 downto 0);
      elsif(MEM_WEHA='0' AND MEM_WELA='1') then
        adr <= MEM_ADA(19 downto 0);
      elsif(MEM_WEHA='1' AND MEM_WELA='0') then
        adr <= MEM_ADA(19 downto 0);
      end if;
    end if;
  end process;

  process (RST,CLK,MEM_WEHA,MEM_WELA) begin
    if(RST='1') then
      we <= '0';
    elsif (CLK'event and CLK='1') then
      if(MEM_WEHA='1' AND MEM_WELA='1') then
        we <= '1';
      elsif(MEM_WEHA='0' AND MEM_WELA='1') then
        we <= '0';
      elsif(MEM_WEHA='1' AND MEM_WELA='0') then
        we <= '1';
      else
        we <= '0';
      end if;
    end if;
  end process;

  process (RST,CLK,MEM_WEHA,MEM_WELA) begin
    if(RST='1') then
      data <= (others=>'0');
    elsif (CLK'event and CLK='1') then
      if(MEM_WEHA='1' AND MEM_WELA='1') then
        data <= MEM_DTIA;
      elsif(MEM_WEHA='0' AND MEM_WELA='1') then
        data(31 downto 0) <= MEM_DTIA(31 downto 0);
      elsif(MEM_WEHA='1' AND MEM_WELA='0') then
        data(63 downto 32) <= MEM_DTIA(63 downto 32);
      end if;
    end if;
  end process;

end rtl;
