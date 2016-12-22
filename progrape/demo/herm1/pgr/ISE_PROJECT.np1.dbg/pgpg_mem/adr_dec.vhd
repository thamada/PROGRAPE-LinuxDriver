-- Last Modifiled at 2004/12/27

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity adr_dec is
  port (
    clk        : in std_logic;
    adr        : in std_logic_vector(18 downto 0);
    is_jpw     : out std_logic;
    is_ipw     : out std_logic;
    is_fo      : out std_logic;
    is_setn    : out std_logic;
    is_run     : out std_logic;
    FPGA_NO    : in std_logic_vector(1 downto 0));
end adr_dec;

architecture rtl of adr_dec is
signal cmd_h : std_logic_vector(6 downto 0);
signal cmd_l : std_logic_vector(11 downto 0);

begin

cmd_h <= adr(18 downto 12);
cmd_l <= adr(11 downto 0);

-- is_jpw ----------------------
process(cmd_h,cmd_l) begin -- BroadCast Only
--if (cmd_h(3) = '1') then -- 4096w * 512bit = 256KByte
--if (cmd_h(4) = '1') then -- 8192w * 512bit = 512KByte
--if (cmd_h(5) = '1') then --16384w * 512bit =   1MByte
  if (cmd_h(6) = '1') then --32768w * 512bit =   2MByte
     is_jpw <= '1';
  else
     is_jpw <= '0';
  end if;
end process;

-- is_ipw ----------------------
process(cmd_h,cmd_l) begin
  if((cmd_h = "0000101") AND (cmd_l(11 downto 10)=FPGA_NO)) then
     is_ipw <= '1';
  else
     is_ipw <= '0';
  end if;
end process;

-- is_fo -----------------------
process(cmd_h,cmd_l) begin
--  if((cmd_h = "0000110") AND (cmd_l(9 downto 8) = FPGA_NO)) then
  if((cmd_h = "0000110") AND (cmd_l(10 downto 9) = FPGA_NO)) then
     is_fo <= '1';
  else
     is_fo <= '0';
  end if;
end process;

-- is_setn ---------------------
process(cmd_h,cmd_l) begin
  if((cmd_h = "0111") AND (cmd_l(11 downto 0) = "000000000000")) then
     is_setn <= '1';
  else
     is_setn <= '0';
  end if;
end process;

-- is_run ----------------------
process(cmd_h,cmd_l) begin
  if((cmd_h = "0000111") AND (cmd_l(11 downto 0) = "000000000011")) then
     is_run <= '1';
  else
     is_run <= '0';
  end if;
end process;


end rtl;
