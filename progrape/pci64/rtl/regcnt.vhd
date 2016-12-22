
-- **************************************
--               INREVIUM                
-- **************************************

--------------------------------------------------------------------------------
-- Copyright(C) 2004 - TOKYO ELECTRON DEVICE LIMITED. All rigths reserved.
--------------------------------------------------------------------------------
-- REGCNT MODEL
--------------------------------------------------------------------------------
-- Internal Register Control Module
--------------------------------------------------------------------------------
-- File                      : regcnt.vhd
-- Entity                    : REGCNT
-- Architecture              : REGCNT_rtl
--------------------------------------------------------------------------------
-- Project Navigator version : ISE6.2.03i
-- Design Flow               : XST
--------------------------------------------------------------------------------
-- Ver.     Data        Coded by        Contents
-- 01.00    2004/08/10  TED)DDC         �V�K
--------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity REGCNT is
  port (
    RST          : in  std_logic;              -- PCI Bus Reset
    CLK          : in  std_logic;              -- PCI bus Clock

    -- PCI R/W ports
    REG_AD       : in  std_logic_vector( 7 downto 0);    -- REGCNT R/W Address
    REG_WE       : in  std_logic;              -- REGCNT Write Enable
    REG_RE       : in  std_logic;              -- REGCNT Read Enable
    REG_DTI      : in  std_logic_vector(31 downto 0);    -- REGCNT Write Data
    REG_DTO      : out  std_logic_vector(31 downto 0);    -- REGCNT Read Data
    REG_DTOEN    : out  std_logic;              -- REGCNT Read Data Enable

    -- USER Application Interface ports
    LED_CNT      : out  std_logic_vector( 7 downto 0);    -- LED Control Signal
    DIPSW        : in  std_logic_vector( 3 downto 0);    -- DIPSW Signal

    DMAEND_INT   : in  std_logic;                -- DMA End Interrupt On Request
    PSW_ON0      : in  std_logic;                -- User Interrupt 0 On Request
    PSW_ON1      : in  std_logic;                -- User Interrupt 1 On Request
    USERINT2_ON  : in  std_logic;                -- User Interrupt 2 On Request

    PGPG_REG0 : out std_logic_vector(31 downto 0);
    PGPG_REG1 : out std_logic_vector(31 downto 0);
    PGPG_REG2 : out std_logic_vector(31 downto 0);
    PGPG_REG3 : out std_logic_vector(31 downto 0);
    GPREG0    : in std_logic_vector(31 downto 0);  -- READ ONLY REGISTER
    GPREG1    : out std_logic_vector(31 downto 0);
    Hit_PGPG_REG2 : out std_logic; -- Active High
    Hit_PGPG_REG3 : out std_logic; -- Active High


    INT_REQ      : out  std_logic              -- Interrupt Request
    );
end REGCNT;


architecture REGCNT_rtl of REGCNT is

--------------------------------------------------
-- signals
--------------------------------------------------

-- Register Access Control Signal

  signal REG_SEL    : std_logic_vector( 9 downto 0);  -- Register Select Signal
  signal GPREG0_SEL  : std_logic;                -- General Register 0 Select (ReadOnly)
  signal GPREG1_SEL  : std_logic;                -- General Register 1 Select
  signal LEDCONT_SEL  : std_logic;               -- LED Control Register Select
  signal DIPSW_SEL  : std_logic;                 -- DIPSW Register Select
  signal INTSTAT_SEL  : std_logic;               -- Interrupt Status Register Select
  signal INTMASK_SEL  : std_logic;               -- Interrupt Mask Register Select
  signal PGPG_REG0_SEL : std_logic;              -- PGPG REG0
  signal PGPG_REG1_SEL : std_logic;              -- PGPG REG1
  signal PGPG_REG2_SEL : std_logic;              -- PGPG REG2
  signal PGPG_REG3_SEL : std_logic;              -- PGPG REG3

  signal REGRD_CNT  : std_logic;                -- Register Read Timing Control Signal

-- General Register 0

  signal GPREG0_DT  : std_logic_vector(31 downto 0);      -- General Register 0 Data

-- General Register 1

  signal GPREG1_DT  : std_logic_vector(31 downto 0) := (others=>'0');      -- General Register 1 Data

-- LED Control Register

  signal LEDCONT_DT  : std_logic_vector( 7 downto 0);      -- LED Control Register Data
  signal LEDCONT_RDDT  : std_logic_vector(31 downto 0);      -- LED Control Register Read Data

-- DIPSW Register

  signal DIPSW_RDDT  : std_logic_vector(31 downto 0);      -- DIPSW Register Read Data

-- Interrupt Status Register

  signal DMAEND_BIT  : std_logic;                -- DMA End Interrupt Status Bit
  signal USERINT0_BIT  : std_logic;                -- User Interrupt 0 Status Bit (Push Button1)
  signal USERINT1_BIT  : std_logic;                -- User Interrupt 1 Status Bit (Push Button2)
  signal USERINT2_BIT  : std_logic;                -- User Interrupt 2 Status Bit (YOBI)

  signal INTSTAT_RDDT  : std_logic_vector(31 downto 0);      -- Interrupt Status Register Read Data

-- Interrupt Mask Register

  signal INTMASK_DT  : std_logic_vector( 3 downto 0);      -- Interrupt Mask Register Data
  signal INTMASK_RDDT  : std_logic_vector(31 downto 0);      -- Interrupt Mask Register Read Data

-- PGPG Register
  signal PGPG_REG0_ff : std_logic_vector(31 downto 0);
  signal PGPG_REG1_ff : std_logic_vector(31 downto 0);
  signal PGPG_REG2_ff : std_logic_vector(31 downto 0);
  signal PGPG_REG3_ff : std_logic_vector(31 downto 0);
  signal Hit_PGPG_REG2_ff : std_logic;
  signal Hit_PGPG_REG3_ff : std_logic;

begin


--***************************************************************
--*
--*  Register Access Control Block
--*
--***************************************************************

--------------------------------------------------------------------------------
-- Register Select Signal Control Process
--------------------------------------------------------------------------------

  process (RST,CLK) begin
    if (RST='1') then
      REG_SEL <= (others=>'0');
    elsif (CLK'event and CLK='1') then
      case REG_AD(7 downto 2) is
        when "000000" => REG_SEL <= "0000000001";            ------ General Register 0 Select
        when "000001" => REG_SEL <= "0000000010";            ------ General Register 1 Select
        when "000010" => REG_SEL <= "0000000100";            ------ LED Control Register Select
        when "000011" => REG_SEL <= "0000001000";            ------ DIPSW Register Select
        when "000100" => REG_SEL <= "0000010000";            ------ Interrupt Status Register Select
        when "000101" => REG_SEL <= "0000100000";            ------ Interrupt Mask Register Select
        when "100000" => REG_SEL <= "0001000000";            ------ PGPG REG0 (0x80)
        when "100001" => REG_SEL <= "0010000000";            ------ PGPG REG1 (0x84)
        when "100010" => REG_SEL <= "0100000000";            ------ PGPG REG2 (0x88)
        when "100011" => REG_SEL <= "1000000000";            ------ PGPG REG3 (0x88)
        when others   => REG_SEL <= "0000000000";            ------ Register No Select
      end case;
    end if;
  end process;

     GPREG0_SEL  <= REG_SEL(0);                      ------ General Register 0 Select
     GPREG1_SEL  <= REG_SEL(1);                      ------ General Register 1 Select
     LEDCONT_SEL <= REG_SEL(2);                      ------ LED Control Register Select
     DIPSW_SEL   <= REG_SEL(3);                      ------ DIPSW Register Select
     INTSTAT_SEL <= REG_SEL(4);                      ------ Interrupt Status Register Select
     INTMASK_SEL <= REG_SEL(5);                      ------ Interrupt Mask Register Select
     PGPG_REG0_SEL <= REG_SEL(6);  --- PGPG REG0 Select
     PGPG_REG1_SEL <= REG_SEL(7);  --- PGPG REG1 Select
     PGPG_REG2_SEL <= REG_SEL(8);  --- PGPG REG2 Select
     PGPG_REG3_SEL <= REG_SEL(9);  --- PGPG REG3 Select


--------------------------------------------------------------------------------
-- Register Read Data Select Control Process
--------------------------------------------------------------------------------

  process (RST,CLK) begin
    if (RST='1') then
      REG_DTO <= (others=>'0');
    elsif (CLK'event and CLK='1') then
      case REG_SEL is
        when "0000000001" => REG_DTO <= GPREG0_DT;             ------ General Register 0 Data Select
        when "0000000010" => REG_DTO <= GPREG1_DT;             ------ General Register 1 Data Select
        when "0000000100" => REG_DTO <= LEDCONT_RDDT;          ------ LED Control Register Read Data Select
        when "0000001000" => REG_DTO <= DIPSW_RDDT;            ------ DIPSW Register Read Data Select
        when "0000010000" => REG_DTO <= INTSTAT_RDDT;          ------ Interrupt Status Register Read Data Select
        when "0000100000" => REG_DTO <= INTMASK_RDDT;          ------ Interrupt Mask Register Read Data Select
        when "0001000000" => REG_DTO <= PGPG_REG0_ff;
        when "0010000000" => REG_DTO <= PGPG_REG1_ff;
        when "0100000000" => REG_DTO <= PGPG_REG2_ff;
        when "1000000000" => REG_DTO <= PGPG_REG3_ff;
        when others      => REG_DTO <= (others=>'0');         ------ No Read Data
      end case;
    end if;
  end process;

--------------------------------------------------------------------------------
-- Register Read Data Signal Timing Control Process
--------------------------------------------------------------------------------

  process (RST,CLK) begin
    if (RST='1') then
      REGRD_CNT <= '0';
    elsif (CLK'event and CLK='1') then
      REGRD_CNT <= REG_RE;                      ------ Register Read Signal Shift
    end if;
  end process;

--------------------------------------------------------------------------------
-- Register Read Data Enable Signal Control Process
--------------------------------------------------------------------------------

  process (RST,CLK) begin
    if (RST='1') then
      REG_DTOEN <= '0';
    elsif (CLK'event and CLK='1') then
      REG_DTOEN <= REGRD_CNT;                      ------ Register Read Signal Shift
    end if;
  end process;


--***************************************************************
--*
--*  Register Data Control Block
--*
--***************************************************************

--------------------------------------------------------------------------------
-- PGPG Register 0 (0x80) (now this is for config fpga command)
--------------------------------------------------------------------------------
  process (RST,CLK) begin
    if (RST='1') then
      PGPG_REG0_ff(31 downto 8) <= (others=>'0');
      PGPG_REG0_ff(7 downto 0) <= "11110000";
    elsif (CLK'event and CLK='1') then
      if (PGPG_REG0_SEL='1' and REG_WE='1') then        ------ Register Write Enable ?
        PGPG_REG0_ff <= REG_DTI;                        ------ Register Write Data Set
      end if;
    end if;
  end process;
  PGPG_REG0 <= PGPG_REG0_ff;
--------------------------------------------------------------------------------
-- PGPG Register 1 (0x84) (now this is for config fpga data)
--------------------------------------------------------------------------------
  process (RST,CLK) begin
    if (RST='1') then
      PGPG_REG1_ff <= (others=>'0');
    elsif (CLK'event and CLK='1') then
      if (PGPG_REG1_SEL='1' and REG_WE='1') then        ------ Register Write Enable ?
        PGPG_REG1_ff <= REG_DTI;                        ------ Register Write Data Set
      end if;
    end if;
  end process;
  PGPG_REG1 <= PGPG_REG1_ff;
--------------------------------------------------------------------------------
-- PGPG Register 2 (0x88)
--------------------------------------------------------------------------------
  process (RST,CLK) begin
    if (RST='1') then
      PGPG_REG2_ff <= (others=>'0');
    elsif (CLK'event and CLK='1') then
      if (PGPG_REG2_SEL='1' and REG_WE='1') then        ------ Register Write Enable ?
        PGPG_REG2_ff <= REG_DTI;                        ------ Register Write Data Set
      end if;
    end if;
  end process;
  process (RST,CLK) begin
    if (RST='1') then
      Hit_PGPG_REG2_ff <= '0';
    elsif (CLK'event and CLK='1') then
      if (PGPG_REG2_SEL='1' and REG_WE='1') then
        Hit_PGPG_REG2_ff <= '1';
      else
        Hit_PGPG_REG2_ff <= '0';
      end if;
    end if;
  end process;
  PGPG_REG2     <= PGPG_REG2_ff;
  Hit_PGPG_REG2 <= Hit_PGPG_REG2_ff;
--------------------------------------------------------------------------------
-- PGPG Register 3 (0x8C)
--------------------------------------------------------------------------------
  process (RST,CLK) begin
    if (RST='1') then
      PGPG_REG3_ff <= (others=>'0');
    elsif (CLK'event and CLK='1') then
      if (PGPG_REG3_SEL='1' and REG_WE='1') then        ------ Register Write Enable ?
        PGPG_REG3_ff <= REG_DTI;                        ------ Register Write Data Set
      end if;
    end if;
  end process;
  process (RST,CLK) begin
    if (RST='1') then
      Hit_PGPG_REG3_ff <= '0';
    elsif (CLK'event and CLK='1') then
      if (PGPG_REG3_SEL='1' and REG_WE='1') then
        Hit_PGPG_REG3_ff <= '1';
      else
        Hit_PGPG_REG3_ff <= '0';
      end if;
    end if;
  end process;
  PGPG_REG3 <= PGPG_REG3_ff;
  Hit_PGPG_REG3 <= Hit_PGPG_REG3_ff;
--------------------------------------------------------------------------------
-- General Register 0 Data Control Process
--------------------------------------------------------------------------------

--  process (RST,CLK) begin
--    if (RST='1') then
--      GPREG0_DT <= (others=>'0');
--    elsif (CLK'event and CLK='1') then
--      if (GPREG0_SEL='1' and REG_WE='1') then              ------ Register Write Enable ?
--        GPREG0_DT <= REG_DTI;                    ------ Register Write Data Set
--      end if;
--    end if;
--  end process;

GPREG0_DT <= GPREG0;

--------------------------------------------------------------------------------
-- General Register 1 Data Control Process
--------------------------------------------------------------------------------

  process (RST,CLK) begin
    if (RST='1') then
      GPREG1_DT <= (others=>'0');
    elsif (CLK'event and CLK='1') then
      if (GPREG1_SEL='1' and REG_WE='1') then              ------ Register Write Enable ?
        GPREG1_DT <= REG_DTI;                    ------ Register Write Data Set
      end if;
    end if;
  end process;

GPREG1 <= GPREG1_DT;

--------------------------------------------------------------------------------
-- LED Control Register Data Control Process
--------------------------------------------------------------------------------

  process (RST,CLK) begin
    if (RST='1') then
      LEDCONT_DT <= (others=>'0');
    elsif (CLK'event and CLK='1') then
      if (LEDCONT_SEL='1' and REG_WE='1') then            ------ Register Write Enable ?
        LEDCONT_DT <= REG_DTI(7 downto 0);              ------ Register Write Data Set
      end if;
    end if;
  end process;

    LEDCONT_RDDT(31 downto  8) <= (others=>'0');            ------ LED Control Register Read Data
    LEDCONT_RDDT( 7 downto  0) <= LEDCONT_DT;              ------ LED Control Register Read Data

    LED_CNT <= LEDCONT_DT;                        ------ LED Control Signal Output

--------------------------------------------------------------------------------
-- DIPSW Control Register Data Control Process
--------------------------------------------------------------------------------

    DIPSW_RDDT(31 downto  4) <= (others=>'0');              ------ DIPSW Register Read Data
    DIPSW_RDDT( 3 downto  0) <= (not DIPSW);              ------ DIPSW Read Data Set

--------------------------------------------------------------------------------
-- Interrupt Status Register Control Process
--------------------------------------------------------------------------------

--------------------------------------------------
-- DMA End Interrupt Status Bit
--------------------------------------------------

  process (RST,CLK) begin
    if (RST='1') then
      DMAEND_BIT <= '0';
    elsif (CLK'event and CLK='1') then
      if (DMAEND_INT='1') then                    ------ DMA End Interrupt On ?
        DMAEND_BIT <= '1';                      ------ DMA End Interrupt Status On
      elsif (INTSTAT_SEL='1' and REG_WE='1' and REG_DTI(0)='0' ) then  ------ DMA End Interrupt Status Clear ?
        DMAEND_BIT <= '0';                      ------ DMA End Interrupt Status Clear
      end if;
    end if;
  end process;

--------------------------------------------------
-- User Interrupt 0 Status Bit
--------------------------------------------------

  process (RST,CLK) begin
    if (RST='1') then
      USERINT0_BIT <= '0';
    elsif (CLK'event and CLK='1') then
      if (PSW_ON0='1') then                      ------ Push_Button 0 On ?
        USERINT0_BIT <= '1';                    ------ Push_Button 0 Interrupt Status On
      elsif (INTSTAT_SEL='1' and REG_WE='1' and REG_DTI(1)='0' ) then  ------ Push_Button 0 Interrupt Status Clear ?
        USERINT0_BIT <= '0';                    ------ Push_Button 0 Interrupt Status Clear
      end if;
    end if;
  end process;

--------------------------------------------------
-- User Interrupt 1 Status Bit
--------------------------------------------------

  process (RST,CLK) begin
    if (RST='1') then
      USERINT1_BIT <= '0';
    elsif (CLK'event and CLK='1') then
      if (PSW_ON1='1') then                      ------ Push_Button 1 On ?
        USERINT1_BIT <= '1';                    ------ Push_Button 1 Interrupt Status On
      elsif (INTSTAT_SEL='1' and REG_WE='1' and REG_DTI(2)='0' ) then  ------ Push_Button 1 Interrupt Status Clear ?
        USERINT1_BIT <= '0';                    ------ Push_Button 1 Interrupt Status Clear
      end if;
    end if;
  end process;

--------------------------------------------------
-- User Interrupt 2 Status Bit
--------------------------------------------------

  process (RST,CLK) begin
    if (RST='1') then
      USERINT2_BIT <= '0';
    elsif (CLK'event and CLK='1') then
      if (USERINT2_ON='1') then                    ------ User Interrupt 2 On ?
        USERINT2_BIT <= '1';                    ------ User Interrupt 2 Interrupt Status On
      elsif (INTSTAT_SEL='1' and REG_WE='1' and REG_DTI(3)='0' ) then  ------ User Interrupt 2 Interrupt Status Clear ?
        USERINT2_BIT <= '0';                    ------ User Interrupt 2 Interrupt Status Clear
      end if;
    end if;
  end process;

    INTSTAT_RDDT(31 downto  4) <= (others=>'0');            ------ Interrupt Status Register Read Data
    INTSTAT_RDDT( 3 downto  0) <= USERINT2_BIT & USERINT1_BIT
                  & USERINT0_BIT & DMAEND_BIT;      ------ Interrupt Status Register Read Data Set

--------------------------------------------------------------------------------
-- Interrupt Mask Register Data Control Process
--------------------------------------------------------------------------------

  process (RST,CLK) begin
    if (RST='1') then
      INTMASK_DT <= (others=>'0');
    elsif (CLK'event and CLK='1') then
      if (INTMASK_SEL='1' and REG_WE='1') then            ------ Register Write Enable ?
        INTMASK_DT <= REG_DTI(3 downto 0);              ------ Register Write Data Set
      end if;
    end if;
  end process;

    INTMASK_RDDT(31 downto  4) <= (others=>'0');            ------ Interrupt Mask Register Read Data
    INTMASK_RDDT( 3 downto  0) <= INTMASK_DT;              ------ Interrupt Mask Register Read Data Set

--------------------------------------------------------------------------------
-- Interrupt Rrequest Signal Output Control Process
--------------------------------------------------------------------------------

    INT_REQ <= (DMAEND_BIT   and INTMASK_DT(0))
        or (USERINT0_BIT and INTMASK_DT(1))
        or (USERINT1_BIT and INTMASK_DT(2))
        or (USERINT2_BIT and INTMASK_DT(3));            ------ Interrupt Request Output





end REGCNT_rtl;
