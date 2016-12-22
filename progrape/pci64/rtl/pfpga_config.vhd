-- 1: cfg_en0 set(clock start): 0x0f1
-- 2: cfg_prog_b0 down        : 0x0e1
-- 3: cfg_prog_b0 up          : 0x0f1
-- 4: set data
-- 5: config start (is_dsend) : 0x1f1
-- 6: end config(cfg_en0 down): 0x0f0
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity pfpga_config is
  port( clk   : in std_logic;
        rst_n : in std_logic;
        cmd_reg  : in std_logic_vector(8 downto 0);
        data_reg : in std_logic_vector(31 downto 0);
	-- Pipeline FPGA side
        CFG_D         : out  std_logic_vector(7 downto 0);  -- DATA
        CFG_CCLK      : out  std_logic;           -- CCLK
        CFG_PROG_B0   : out  std_logic;           -- DDR-FPGA0����PROG_B
        CFG_PROG_B1   : out  std_logic;           -- DDR-FPGA1����PROG_B
        CFG_PROG_B2   : out  std_logic;           -- DDR-FPGA2����PROG_B
        CFG_PROG_B3   : out  std_logic;           -- DDR-FPGA3����PROG_B
        CFG_CS_B0     : out  std_logic;           -- DDR-FPGA0����CS_B
        CFG_CS_B1     : out  std_logic;           -- DDR-FPGA1����CS_B
        CFG_CS_B2     : out  std_logic;           -- DDR-FPGA2����CS_B
        CFG_CS_B3     : out  std_logic;           -- DDR-FPGA3����CS_B
        CFG_RDWR_B    : out  std_logic);          -- RD/WR_B
end pfpga_config;

architecture rtl of pfpga_config is
signal cclk_cnt   : std_logic_vector(1 downto 0);
signal cfg_cnt    : std_logic_vector(3 downto 0) := "1111";
signal cfg_en     : std_logic_vector(3 downto 0);
signal cfg_prog_b : std_logic_vector(3 downto 0);
signal dbuf0,dbuf1,dbuf2,dbuf3 : std_logic_vector(7 downto 0);
signal is_cclk : std_logic;
signal cs : std_logic;
signal stop_cnt : std_logic := '1';
signal rund : std_logic_vector(10 downto 0);
signal cfg_d_port  : std_logic_vector(7 downto 0);
signal is_dsend : std_logic;
signal cfg_start0,cfg_start1 : std_logic;
begin

  CFG_RDWR_B <= '0';
  cfg_en     <= cmd_reg(3 downto 0);
  cfg_prog_b <= cmd_reg(7 downto 4);
  cfg_start0 <= cmd_reg(8);

  process(clk) begin
    if(clk'event and clk='1') then
      cfg_start1 <= cfg_start0;
    end if;
  end process;

  process(clk,rst_n) begin
    if(rst_n = '0') then
      is_dsend <= '0';
    elsif(clk'event and clk='1') then
      if((cfg_start0 = '1') and (cfg_start1 = '0')) then
        is_dsend <='1';
      else
        is_dsend <='0';
      end if;
    end if;
  end process;


-- stop_cnt ,cs -------------------------------------
  process(clk) begin
    if(clk'event and clk='1') then
      rund(10) <= rund(9);
      rund(9) <= rund(8);
      rund(8) <= rund(7);
      rund(7) <= rund(6);
      rund(6) <= rund(5);
      rund(5) <= rund(4);
      rund(4) <= rund(3);
      rund(3) <= rund(2);
      rund(2) <= rund(1);
      rund(1) <= rund(0);
      rund(0) <= is_dsend;
    end if;
  end process;

  process(clk) begin
    if(clk'event and clk='1') then
      if((rund(7) = '0') AND (rund(6) = '1')) then
        stop_cnt <='1';
      elsif((is_dsend='1') AND (rund(0) = '0')) then
        stop_cnt <='0';
      end if;
    end if;
  end process;

  process(clk,rst_n) begin
    if(rst_n = '0') then
      cs <= '0';
    elsif(clk'event and clk='1') then
      if((rund(0)='1') AND (rund(1) = '0')) then
        cs <= '1';
      elsif((rund(9) = '0') AND (rund(8) = '1')) then
        cs <= '0';
      end if; 
    end if;
  end process;
-------------------------------------

-- CFG_D, CFG_CS_B<n> output ----------
  process(clk,cclk_cnt(0)) begin
    if(cclk_cnt(0)='1') then
      CFG_D <= cfg_d_port;
      CFG_CS_B0 <= NOT (cs AND cfg_en(0));
      CFG_CS_B1 <= NOT (cs AND cfg_en(1));
      CFG_CS_B2 <= NOT (cs AND cfg_en(2));
      CFG_CS_B3 <= NOT (cs AND cfg_en(3));
    elsif(clk'event and clk='1') then
      CFG_D <= cfg_d_port;
      CFG_CS_B0 <= NOT (cs AND cfg_en(0));
      CFG_CS_B1 <= NOT (cs AND cfg_en(1));
      CFG_CS_B2 <= NOT (cs AND cfg_en(2));
      CFG_CS_B3 <= NOT (cs AND cfg_en(3));
    end if;
  end process;
-------------------------------------


-- SEND_CFG_DATA --------------------

  dbuf3(7 downto 0) <= data_reg(0)&data_reg(1)&data_reg(2)&data_reg(3)&data_reg(4)&data_reg(5)&data_reg(6)&data_reg(7);
  dbuf2(7 downto 0) <= data_reg(8)&data_reg(9)&data_reg(10)&data_reg(11)&data_reg(12)&data_reg(13)&data_reg(14)&data_reg(15);
  dbuf1(7 downto 0) <= data_reg(16)&data_reg(17)&data_reg(18)&data_reg(19)&data_reg(20)&data_reg(21)&data_reg(22)&data_reg(23);
  dbuf0(7 downto 0) <= data_reg(24)&data_reg(25)&data_reg(26)&data_reg(27)&data_reg(28)&data_reg(29)&data_reg(30)&data_reg(31);


  process(clk) begin
    if((is_dsend = '1')AND(rund(0)='0')) then
      cfg_d_port <= "00000000";
    elsif(clk'event and clk='1') then
      case cfg_cnt is
      when "0000" =>
        cfg_d_port <= dbuf0;
      when "0001" =>
        cfg_d_port <= dbuf0;
      when "0010" =>
        cfg_d_port <= dbuf1;
      when "0011" =>
        cfg_d_port <= dbuf1;
      when "0100" =>
        cfg_d_port <= dbuf2;
      when "0101" =>
        cfg_d_port <= dbuf2;
      when "0110" =>
        cfg_d_port <= dbuf3;
      when "0111" =>
        cfg_d_port <= dbuf3;
      when others =>
        cfg_d_port <= "00000000";
      end case;
    end if;
  end process;

  process(clk,stop_cnt) begin
    if(clk'event and clk='1') then
      if(stop_cnt='1')then
        cfg_cnt <= "0000";
      else
        cfg_cnt <= cfg_cnt + "0001";
      end if;
    end if;
  end process;


-------------------------------------


-- CFG_PROG_B<n> -------------------- 
  process(clk) begin
    if(clk'event and clk='1') then
      if(rst_n = '0') then
        CFG_PROG_B0 <=  '1';
        CFG_PROG_B1 <=  '1';
        CFG_PROG_B2 <=  '1';
        CFG_PROG_B3 <=  '1';
      else
        CFG_PROG_B0 <=  cfg_prog_b(0);
        CFG_PROG_B1 <=  cfg_prog_b(1);
        CFG_PROG_B2 <=  cfg_prog_b(2);
        CFG_PROG_B3 <=  cfg_prog_b(3);
      end if;
    end if;
  end process;
-------------------------------------

-- Generate CFG_CCLK ----------------
  CFG_CCLK <= not cclk_cnt(0);
  is_cclk <= cfg_en(0) OR cfg_en(1) OR cfg_en(2) OR cfg_en(3);

  process(clk) 
  begin
    if(clk'event and clk='1') then
      if(is_cclk='0') then
        cclk_cnt <= "00";
      else
        cclk_cnt <= cclk_cnt + "01";
      end if;
    end if;
  end process;
-------------------------------------


end rtl;