library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;                                        
use ieee.std_logic_unsigned.all;                                    

entity calc is
  port (
    start      : in  std_logic;
    clk        : in  std_logic;
    pclk       : in  std_logic;
    n          : in  std_logic_vector(31 downto 0);
    run        : out  std_logic;
    mem_adr    : out  std_logic_vector(31 downto 0));
end calc;

architecture rtl of calc is

signal rst :  std_logic;
signal rstn : std_logic_vector(31 downto 0);
signal start_r : std_logic;
signal mema_dc : std_logic_vector(17 downto 0) := (others=>'0');
begin

-- GENERATE rst PULS ------------------
process(pclk) begin
  if(pclk'event and pclk='1') then
    rst <= rstn(0);
  end if;
end process;

process (clk) begin
  if(clk'event and clk='1') then
    rstn(0) <= start_r AND (NOT start);
    start_r <= start;
  end if;
end process;
---------------------------------------

-- GENERATE run --------------------------
process(pclk,rst) begin
  if(rst = '1') then
    run <= '0';
  elsif(pclk'event and pclk='1') then
    if(mema_dc /= "000000000000000000") then
      run <= '1';
    else
      run <= '0';
    end if;
  end if;
end process;

-- GENERATE mem_adr  ---------------------
process(pclk,rst) begin
  if(rst = '1') then
    mema_dc <=  n(17 downto 0) ;
  elsif(pclk'event and pclk='1') then
    if(mema_dc /= "000000000000000000") then
      mema_dc <= mema_dc - "000000000000000001";
    end if;
  end if;
end process;
--hoge
--mem_adr <= "000000000000000" & mema_dc(15 downto 0) & "0";  -- G5
--mem_adr <= "00000000000000" & mema_dc(15 downto 0) & "00";  -- SPH FirstStage
  mem_adr <= "0000000000000" & mema_dc(15 downto 0) & "000";  -- SPH SecondStage

end rtl;
