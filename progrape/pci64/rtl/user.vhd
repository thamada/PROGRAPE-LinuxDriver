library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity USER is
  port (
    RST         : in  std_logic;                     -- PCI Bus Reset
    CLK         : in  std_logic;                     -- PCI bus Clock
    PSW_IN      : in  std_logic_vector( 1 downto 0); -- Push SW Input
    DIPSW       : out  std_logic_vector( 3 downto 0);-- DIPSW Signal
    PSW_ON0     : out  std_logic;                    -- User Interrupt 0 On Request
    PSW_ON1     : out  std_logic;                    -- User Interrupt 1 On Request
    USERINT2_ON : out  std_logic                     -- User Interrupt 2 On Request
    );
end USER;


architecture USER_rtl of USER is

--------------------------------------------------
-- signals
--------------------------------------------------

  signal DIPSWi      : std_logic_vector( 3 downto 0);          ------ Internal DIPSW Data
  signal SWCHK_CUNT  : std_logic_vector( 7 downto 0);          ------ Push SW Check Counter
  signal PSWCHK_CNT0 : std_logic_vector( 2 downto 0);          ------ Push SW 0 Check
  signal PSWCHK_CNT1 : std_logic_vector( 2 downto 0);          ------ Push SW 1 Check
  signal PSW_ON0i    : std_logic;                      ------ User Interrupt 0 On Request
  signal PSW_ON1i    : std_logic;                      ------ User Interrupt 1 On Request

begin


--------------------------------------------------------------------------------
-- DIPSW Input Signal Output Control Process
--------------------------------------------------------------------------------
    DIPSWi <= (others=>'0');  -- 2004/11/11 by T.Hamada
    DIPSW <= DIPSWi;

--------------------------------------------------------------------------------
-- Push SW Check Counter Control Process
--------------------------------------------------------------------------------

  process (RST,CLK) begin
    if (RST='1') then
       SWCHK_CUNT <= (others=>'0');
    elsif (CLK'event and CLK='1') then
       SWCHK_CUNT <= SWCHK_CUNT+1;                  ------ Counter Increment
    end if;
  end process;

--------------------------------------------------------------------------------
-- Push SW 0 Check Control Process
--------------------------------------------------------------------------------

  process (RST,CLK) begin
    if (RST='1') then
       PSWCHK_CNT0 <= (others=>'1');
    elsif (CLK'event and CLK='1') then
      if (SWCHK_CUNT="11111111") then
         PSWCHK_CNT0 <= PSWCHK_CNT0(1 downto 0) & PSW_IN(0);    ------ PSW_IN(0) Sampling
      end if;
    end if;
  end process;

--------------------------------------------------------------------------------
-- Push SW 0 On Signal Output Control Process
--------------------------------------------------------------------------------

  process (RST,CLK) begin
    if (RST='1') then
       PSW_ON0i <= '0';
    elsif (CLK'event and CLK='1') then
      if (SWCHK_CUNT="11111111") then
        PSW_ON0i <= PSWCHK_CNT0(2) and (not PSWCHK_CNT0(1));    ------ SW Check Signal Set
      else
        PSW_ON0i <= '0';
      end if;
    end if;
  end process;

    PSW_ON0 <= PSW_ON0i;

--------------------------------------------------------------------------------
-- Push SW 1 Check Control Process
--------------------------------------------------------------------------------

  process (RST,CLK) begin
    if (RST='1') then
       PSWCHK_CNT1 <= (others=>'1');
    elsif (CLK'event and CLK='1') then
      if (SWCHK_CUNT="11111111") then
         PSWCHK_CNT1 <= PSWCHK_CNT1(1 downto 0) & PSW_IN(1);    ------ PSW_IN(1) Sampling
      end if;
    end if;
  end process;

--------------------------------------------------------------------------------
-- Push SW 1 On Signal Output Control Process
--------------------------------------------------------------------------------

  process (RST,CLK) begin
    if (RST='1') then
       PSW_ON1i <= '0';
    elsif (CLK'event and CLK='1') then
      if (SWCHK_CUNT="11111111") then
        PSW_ON1i <= PSWCHK_CNT1(2) and (not PSWCHK_CNT1(1));    ------ SW Check Signal Set
      else
        PSW_ON1i <= '0';
      end if;
    end if;
  end process;

    PSW_ON1 <= PSW_ON1i;

--------------------------------------------------------------------------------
-- User Interrupt 2 Signal Output Control Process
--------------------------------------------------------------------------------

  process (RST,CLK) begin
    if (RST='1') then
      USERINT2_ON <= '0';
    elsif (CLK'event and CLK='1') then
      USERINT2_ON <=  RST and DIPSWi(0) and (not PSWCHK_CNT1(2))
                            and PSWCHK_CNT1(1);
    end if;
  end process;

end USER_rtl;
