-- Copyright 2004 Tsuyoshi Hamada
--
--
--[WRITE]
--clk         __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __
-- CBUS(0)    _______/~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\______________
--[ DBUS ]           X   >< n ><d0 ><d1 ><d2 ><d3 ><d4 ><d5 ><d6 ><d7 >
--MEM_ADR                        0 >< n ><n+1><n+2><n+3><n+4><n+5><n+6><n+7>< 0
--MEM_DATA                          <d0 ><d1 ><d2 ><d3 ><d4 ><d5 ><d6 ><d7 >
--MEM_WE                        ____/~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\______

--[READ] 
--clk         __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __
-- CBUS(1)    _______/~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\______________
--DBUS               X   >< n ><HHH>----------<d0 ><d1 ><d2 ><d3 ><d4 ><d5 ><d6 ><d7 >
--DBUS_Port_ff                                <d0 ><d1 ><d2 ><d3 ><d4 ><d5 ><d6 ><d7 >
--DBUS_Port                              <d0 ><d1 ><d2 ><d3 ><d4 ><d5 ><d6 ><d7 >
--DBUS_HiZ           ~~~~~~~~~~~~~~~\_________________________________________________/~~~~
--MEM_RE                        ____/~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\______
--MEM_ADR                        0 >< n ><n+1><n+2><n+3><n+4><n+5><n+6><n+7>< 0
--MEM_DATA                               <d0 ><d1 ><d2 ><d3 ><d4 ><d5 ><d6 ><d7 >

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity top is
  port (
    RST       : in std_logic;
    CK66      : in std_logic;
    CK133     : in std_logic; -- not used
    CBUS      : inout std_logic_vector(7 downto 0);
    DBUS      : inout std_logic_vector(63 downto 0);
    LED       : out std_logic_vector(7 downto 0);
    TPIN      : out std_logic_vector(15 downto 0); -- TEST PIN
    DSW       : in std_logic_vector(7 downto 0);   -- DIP SWITCH
    FPGA_NO   : in std_logic_vector(1 downto 0)
  );
end top;

architecture rtl of top is

component dmaw
  port (
    RST       : in std_logic;
    CLK       : in std_logic;
    ENABLE    : in std_logic;
    DBUS      : in std_logic_vector(63 downto 0);
    MEM_WE    : out std_logic;
    MEM_ADR   : out std_logic_vector(18 downto 0);
    MEM_DATA  : out std_logic_vector(63 downto 0)   );
end component;

component dmar
  port (
    RST       : in std_logic;
    CLK       : in std_logic;
    ENABLE    : in std_logic;
    DBUS      : in std_logic_vector(63 downto 0);
    DBUS_Port : out std_logic_vector(63 downto 0);
    DBUS_HiZ  : out std_logic;
    MEM_RE    : out std_logic;
    MEM_ADR   : out std_logic_vector(18 downto 0);
    MEM_DATA  : in std_logic_vector(63 downto 0)  ); 
end component;

component user
  port (
    FPGA_NO : in std_logic_vector(1 downto 0);
    RST : in std_logic;
    CLK  : in std_logic;
    PCLK : in std_logic;
    WE  : in std_logic;
    RE  : in std_logic;
    WAD : in std_logic_vector(18 downto 0);
    WDT : in std_logic_vector(63 downto 0);
    RAD : in std_logic_vector(18 downto 0);
    RDT : out std_logic_vector(63 downto 0);
    STS : out std_logic);
end component;

component CLK_MULDIV
  generic (CLKFX_MULTIPLY : integer :=3;
           CLKFX_DIVIDE : integer := 2);
  port (ICLK : in std_logic;
        OCLK : out std_logic;
        OCLK_FX : out std_logic;
        LOCKED : out std_logic);
end component;

--COMPONENT CLK_MULDIV_BY_XCORE
--PORT(
--	CLKIN_IN : IN std_logic;
--	RST_IN : IN std_logic;          
--	CLKFX_OUT : OUT std_logic;
--	CLK0_OUT : OUT std_logic;
--	LOCKED_OUT : OUT std_logic
--	);
--END COMPONENT;


signal DBUS_HiZ    : std_logic;
signal DBUS_idata  : std_logic_vector(63 downto 0);
signal DBUS_Port   : std_logic_vector(63 downto 0);
signal DBUS_Port_ff: std_logic_vector(63 downto 0);
signal dmaw_enable : std_logic;
signal dmar_enable : std_logic;
signal dmaw_mem_adr : std_logic_vector(18 downto 0);
signal dmar_mem_adr : std_logic_vector(18 downto 0);
signal dmaw_mem_we  : std_logic;
signal dmar_mem_re  : std_logic;
signal dmaw_mem_data : std_logic_vector(63 downto 0);
signal dmar_mem_data : std_logic_vector(63 downto 0);
---
signal LED_ff : std_logic_vector(7 downto 0) := (others=>'1');

signal user_status : std_logic :='0';
signal CLK0,CLK1 : std_logic;
signal DCM_LOCKED : std_logic;
signal FPGA_NO_ff : std_logic_vector(1 downto 0);
signal tmp0 : std_logic_vector(5 downto 0);
begin

dcm0: CLK_MULDIV
  generic map (CLKFX_MULTIPLY => 2,
               CLKFX_DIVIDE   => 2)
  port map (ICLK => CK66,
            OCLK => CLK0,
            OCLK_FX => CLK1,
            LOCKED => DCM_LOCKED);

-- CLK0 <= CK66;
-- CLK1 <= CK66;
-- DCM_LOCKED <= '0';



  CBUS(7) <= user_status;

  DBUS <= (others=>'Z') when DBUS_HiZ = '1' else DBUS_Port_ff;
  DBUS_idata <= DBUS;
  dmaw_enable <= CBUS(0);
  dmar_enable <= CBUS(1);
  process (CLK0) begin
    if(CLK0'event and CLK0='1') then
      DBUS_Port_ff <= DBUS_Port;
    end if;
  end process;

  u0 : dmaw port map(
    RST       => RST,
    CLK       => CLK0,
    ENABLE    => dmaw_enable,
    DBUS      => DBUS_idata,
    MEM_WE    => dmaw_mem_we,
    MEM_ADR   => dmaw_mem_adr,
    MEM_DATA  => dmaw_mem_data);

  u1: dmar port map(
    RST       => RST,
    CLK       => CLK0,
    ENABLE    => dmar_enable,
    DBUS      => DBUS_idata,
    DBUS_Port => DBUS_Port,
    DBUS_HiZ  => DBUS_HiZ,
    MEM_RE    => dmar_mem_re,
    MEM_ADR   => dmar_mem_adr,
    MEM_DATA  => dmar_mem_data);

  u2: user port map(
      FPGA_NO => FPGA_NO_ff,
      RST => RST,
      CLK  => CLK0,
      PCLK => CLK1,
      WE  => dmaw_mem_we,
      RE  => dmar_mem_re,
      WAD => dmaw_mem_adr,
      WDT => dmaw_mem_data,
      RAD => dmar_mem_adr,
      RDT => dmar_mem_data,
      STS => user_status);

-----------------------------
  process (CLK0) begin
    if(CLK0'event and CLK0='1') then
      FPGA_NO_ff <= FPGA_NO;
    end if;
  end process;

-------------------------------------------------------------------------------
  -- LED --
  LED <= LED_ff;

  process (RST,CLK0) begin
    if(RST='1') then
      LED_ff <= (others=>'0');
    elsif(CLK0'event and CLK0='1') then
--      if(dmaw_enable = '1' AND dmar_enable = '0') then
--        LED_ff(7 downto 4) <= (others=>'0');
--        LED_ff(3 downto 0) <= (others=>'1');
--      elsif(dmaw_enable = '0' AND dmar_enable = '1') then
--        LED_ff(7 downto 4) <= (others=>'1');
--        LED_ff(3 downto 0) <= (others=>'0');
--      else
--        LED_ff <= "1111111" & DCM_LOCKED;
--      end if;
      LED_ff <= "1110011" & DCM_LOCKED;
    end if;
  end process;

  -- TEST PIN --
  process (CLK0) begin
    if(CLK0'event and CLK0='1') then
      tmp0(5 downto 0) <= CK133 & CBUS(6 downto 2);
    end if;
  end process;

  process (CLK0) begin
    if(CLK0'event and CLK0='1') then
      TPIN(15 downto 10) <= tmp0(5 downto 0);
      TPIN(9) <= 'Z';
      TPIN(8) <= 'Z';
      TPIN(7 downto 0) <= DSW;
    end if;
  end process;
  TPIN(14 downto 11) <= (others=>'Z');

end rtl;
