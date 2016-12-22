library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;


entity WRITECOMB_CHECK is
  port (
    MEM_WEHA : in std_logic;
    MEM_WELA : in std_logic;
    IS_ERR : out std_logic_vector(25 downto 0);
    RST : in  std_logic;
    CLK : in  std_logic
    );
end WRITECOMB_CHECK;

architecture rtl of WRITECOMB_CHECK is

signal cnt,cntr : std_logic_vector(25 downto 0) := (others=>'0');

begin

  IS_ERR <= cnt;

  cntr <= cnt;

  process(CLK, RST, MEM_WEHA, MEM_WELA) begin
    if(RST = '1') then
      cnt <= (others=>'0');
    elsif(CLK'event and CLK='1') then
      if(MEM_WEHA='1' AND MEM_WELA='0') then
        cnt <= cntr + "00000000000000000000000001";
      elsif(MEM_WEHA='0' AND MEM_WELA='1') then
        cnt <= cntr + "00000000000000000000000001";
      end if;
    end if;
  end process;

end rtl;
