library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;                                        
use ieee.std_logic_unsigned.all;                                    

entity pipe_sts is
  port (
    rst        : in  std_logic;
    clk        : in  std_logic;
    run        : in  std_logic;
    runret     : in  std_logic;
    status     : out std_logic_vector(31 downto 0)
  );
end pipe_sts;

architecture rtl of pipe_sts is
signal sts_reg  : std_logic_vector(7 downto 0) :=X"77";
signal rund,sts : std_logic;
signal cntr : std_logic_vector(7 downto 0);
signal irun : std_logic := '0';

begin

-- clk    ____~~~~____~~~~____~~~~____~~~~__
-- runret _____~~~~~~~~_____________________
-- rund   _____________~~~~~~~~_____________
-- status                      <finish     >

-- status
status(31 downto 8) <= (others=>'0');
process(clk,rst) begin
  if(rst='1') then
    status(7 downto 0) <= (others=>'1');
  elsif(clk'event and clk='1') then
    if((runret='0') AND (rund='1')) then  -- �v�Z�I��
      status(7 downto 0) <= (others=>'1');
    elsif((run='1') AND (irun='0')) then -- �v�Z�J�n
      status(7 downto 0) <= (others=>'0');
    end if;
  end if;
end process;

process(clk) begin
  if(clk'event and clk='1') then
    rund  <= runret;
  end if;
end process;

process(clk) begin
  if(clk'event and clk='1') then
    irun  <= run;
  end if;
end process;


end rtl;
