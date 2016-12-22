--###############################
--# by T.Hamada for B3 Board    #
--###############################

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity DPRAM is
  port (
    RST         : in  std_logic;                        -- PCI Bus Reset
    CLK         : in  std_logic;                        -- PCI bus Clock
    CLKB        : in   std_logic;                       -- Port B Clock
    -- PCI R/W ports
    MEM_ADA     : in  std_logic_vector(13 downto 0);    -- DPRAM Port A R/W Address
    MEM_WEHA    : in  std_logic;                        -- DPRAM Port A Write Enable (High Word)
    MEM_WELA    : in  std_logic;                        -- DPRAM Port A Write Enable (Low  Word)
    MEM_REA     : in  std_logic;                        -- DPRAM Port A Read Enable
    MEM_DTIA    : in  std_logic_vector(63 downto 0);    -- DPRAM Port A Write Data
    MEM_DTOA    : out std_logic_vector(63 downto 0);    -- DPRAM Port A Read Data
    MEM_DTOEN   : out std_logic;                        -- DPRAM Port A Read Data Enable
    -- USER Application R/W ports
    MEM_ADB     : in  std_logic_vector(12 downto 0);    -- DPRAM Port B R/W Address
    MEM_WEHB    : in  std_logic;                        -- DPRAM Port B Write Enable (High Word)
    MEM_WELB    : in  std_logic;                        -- DPRAM Port B Write Enable (Low  Word)
    MEM_DTIB    : in  std_logic_vector(63 downto 0);    -- DPRAM Port B Write Data
    MEM_DTOB    : out  std_logic_vector(63 downto 0)    -- DPRAM Port B Read Data
    );
end DPRAM;


architecture DPRAM_rtl of DPRAM is

--------------------------------------------------
-- Components
--------------------------------------------------
--component dp32b512w
--  port (
--    addra      : in  std_logic_vector( 8 downto 0);    -- Port A Address
--    addrb      : in  std_logic_vector( 8 downto 0);    -- Port B Address
--    clka       : in  std_logic;                        -- Port A Clock
--    clkb       : in  std_logic;                        -- Port A Clock
--    dina       : in  std_logic_vector(31 downto 0);    -- Port A Write Data
--    dinb       : in  std_logic_vector(31 downto 0);    -- Port B Write Data
--    douta      : out  std_logic_vector(31 downto 0);   -- Port A Read Data
--    doutb      : out  std_logic_vector(31 downto 0);   -- Port B Read  Data
--    wea        : in  std_logic;                        -- Port A Write Enable
--    web        : in  std_logic                         -- Port A Write Enable
--    );
--end component;

component dp32b8192w
  port (
    clka  : in std_logic;
    wea   : in std_logic;
    addra : in std_logic_vector(12 downto 0);
    dina  : in std_logic_vector(31 downto 0);
    douta : out std_logic_vector(31 downto 0);

    clkb  : in std_logic;
    web   : in std_logic;
    addrb : in std_logic_vector(12 downto 0);
    dinb  : in std_logic_vector(31 downto 0);
    doutb : out std_logic_vector(31 downto 0)
  );
end component;

  signal MEM_RDTFLG  : std_logic;                       -- Port A Read Data Select Flag
  signal MEM_RDDT    : std_logic_vector( 63 downto 0);  -- Port A Memory Read Data
begin


--***************************************************************
--* instantiate sub-blocks
--***************************************************************

-- Low Word (32 bit)

  dp0 : dp32b8192w port map (
    addra      => MEM_ADA(13 downto  1),          -- Port A Address
    addrb      => MEM_ADB(12 downto  0),          -- Port B Address
    clka       => CLK,                            -- Port A Clock
    clkb       => CLKB,                           -- Port B Clock
    dina       => MEM_DTIA(31 downto  0),         -- Port A Write Data
    dinb       => MEM_DTIB(31 downto  0),         -- Port B Write Data
    douta      => MEM_RDDT(31 downto  0),         -- Port A Read Data
    doutb      => MEM_DTOB(31 downto  0),         -- Port B Read  Data
    wea        => MEM_WELA,                       -- Port A Write Enable
    web        => MEM_WELB                        -- Port A Write Enable
  );

-- High Word (32 bit)

  dp1 : dp32b8192w port map (
    addra      => MEM_ADA(13 downto  1),          -- Port A Address
    addrb      => MEM_ADB(12 downto  0),          -- Port B Address
    clka       => CLK,                            -- Port A Clock
    clkb       => CLKB,                           -- Port A Clock
    dina       => MEM_DTIA(63 downto 32),         -- Port A Write Data
    dinb       => MEM_DTIB(63 downto 32),         -- Port B Write Data
    douta      => MEM_RDDT(63 downto 32),         -- Port A Read Data
    doutb      => MEM_DTOB(63 downto 32),         -- Port B Read  Data
    wea        => MEM_WEHA,                       -- Port A Write Enable
    web        => MEM_WEHB                        -- Port A Write Enable
  );


--***************************************************************
--*
--*  PORT A Control Block
--*
--***************************************************************

--------------------------------------------------------------------------------
-- Port A Read Data Select Flag Control Process
--------------------------------------------------------------------------------

  process (RST,CLK) begin
    if (RST='1') then
      MEM_RDTFLG <= '0';
    elsif (CLK'event and CLK='1') then
      MEM_RDTFLG <= MEM_ADA(0);                  ------ Port A Read Address LSB Set
    end if;
  end process;

--------------------------------------------------------------------------------
-- Port A Read Data Output Control Process
--------------------------------------------------------------------------------

  process (MEM_RDTFLG,MEM_RDDT) begin
    if (MEM_RDTFLG='1') then                     ------ 32 bit Odd Address Access ?
      MEM_DTOA <= MEM_RDDT(63 downto 32) & MEM_RDDT(63 downto 32);  ------ 32 bit High Data Set to Low Word
    else
      MEM_DTOA <= MEM_RDDT;                      ------ Set to 64 bit Data
    end if;
  end process;

--------------------------------------------------------------------------------
-- Port A Read Data Enable Signal Control Process
--------------------------------------------------------------------------------

  process (RST,CLK) begin
    if (RST='1') then
      MEM_DTOEN <= '0';
    elsif (CLK'event and CLK='1') then
      MEM_DTOEN <= MEM_REA;                      ------ Read Enable Signal Shift
    end if;
  end process;

end DPRAM_rtl;
