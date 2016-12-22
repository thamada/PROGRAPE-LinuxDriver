library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;                                        
use ieee.std_logic_unsigned.all;                                    

entity setn is
  port (
    clk       : in std_logic;
    we        : in std_logic;
    idata     : in std_logic_vector(31 downto 0);
    odata     : out std_logic_vector(31 downto 0));
end setn;

architecture rtl of setn is
signal nreg :  std_logic_vector(31 downto 0) := "00000000000000000000000000000011"; -- default 3
begin

odata <= nreg;
--odata <= "00000000000000000000000000000011";

process (clk) begin
  if(clk'event and clk='1') then
    if(we = '1') then
      nreg <= idata;
    end if;
  end if;
end process;

end rtl;
