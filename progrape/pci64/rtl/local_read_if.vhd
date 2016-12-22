-- LOCAL READ INTERFACE ( ifpga <- pfpga )
-- by Tsuyoshi Hamada
--
-- CLK            __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ __~~ 
-- EXEC           __/~~~~~\_____
-- BUSY           ________/~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\_______
-- DMAR_ENABLE                   __/~~~~~~~~~~~~~~~\___ { (Ndata+1) clock }
-- DBUS_Port                       < adr ><XXXX
-- DBUS_idata                                          < d0 >< d1 >
-- DBUS                                  <adr><XXXXXXX>< d0 >< d1 >
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity LOCAL_READ_IF is
  port (
    -- PGPG REG input
    EXEC : in std_logic;                         -- Execution Pulse
    START_AD : in std_logic_vector(18 downto 0); -- 19 bit  -- constant in transaction
    NQWORD   : in std_logic_vector( 8 downto 0); --  9 bit  -- constant in transaction : (NQWORD + 1) words transfer
    CHIPSEL  : in std_logic_vector( 3 downto 0); --  4 bit  -- constant in transaction
    MEM_AD_BASE : in std_logic_vector(12 downto 0);         -- constant in transaction
    BUSY : out std_logic;  -- to GPREG0

    -- CBUS/DBUS
    DMAR_ENABLE : out std_logic_vector(3 downto 0); -- for 4 pfpga chip
    DBUS_Port : out std_logic_vector(63 downto 0);
    DBUS_idata: in std_logic_vector(63 downto 0);
    DBUS_HiZ  : out std_logic;

    -- DPRAM R/W ports
    MEM_ADB     : out std_logic_vector(12 downto 0);     -- DPRAM Port B R/W Address
    MEM_WEHB    : out std_logic;                         -- DPRAM Port B Write Enable (High Word)
    MEM_WELB    : out std_logic;                         -- DPRAM Port B Write Enable (Low  Word)
    MEM_DTIB    : out std_logic_vector(63 downto 0);     -- DPRAM Port B Write Data

    RST : in  std_logic;
    CLK : in  std_logic
    );
end LOCAL_READ_IF;

architecture rtl of LOCAL_READ_IF is

-----------------------------------------------------------------
-- DMAW/R
  signal hit,hitr : std_logic;
  signal csel    : std_logic_vector(3 downto 0);
  signal s_adr : std_logic_vector(18 downto 0);

-- DMAR
  signal en_cnt0   : std_logic_vector(12 downto 0) :=(others=>'0');
  signal en_cnt0_r : std_logic_vector(12 downto 0) :=(others=>'0');
  signal en0,en1,en2,en3,en4,en5,en6,en7 : std_logic :='0';
  signal lo_mem_wad, lo_mem_wad_z : std_logic_vector(12 downto 0) :=(others=>'0');
  signal mem_ad_offset : std_logic_vector(12 downto 0) :=(others=>'0');
begin

  -- DMA BUSY or IDLE
  BUSY  <= hit or hitr or en0 or en1 or en2 or en3 or en4 or en5 or en6 or en7;
  hit <= EXEC;
  process (CLK) begin
    if (CLK'event and CLK='1') then
      hitr <= hit;
    end if;
  end process;

  ----------------------------
  --- DMAR START ADR       ---
  ----------------------------
  process (CLK,hit,hitr) begin
    if(RST='1') then
      s_adr <= (others=>'0');
    elsif(CLK'event and CLK='1') then
      if((hit = '0') AND (hitr = '1')) then
        s_adr <= START_AD(18 downto 0);
      end if;
    end if;
  end process;

  ----------------------------
  --- DMAR START ADR       ---
  ----------------------------
  process (CLK,hit,hitr) begin
    if(RST='1') then
      mem_ad_offset <= (others=>'0');
    elsif(CLK'event and CLK='1') then
      if((hit = '0') AND (hitr = '1')) then
        mem_ad_offset <= MEM_AD_BASE;
      end if;
    end if;
  end process;


  ----------------------------
  --- CHIP SEL             ---
  ----------------------------
  process (CLK,hit,hitr) begin
    if(RST='1') then
      csel <= (others=>'0');
    elsif(CLK'event and CLK='1') then
      if((hit = '0') AND (hitr = '1')) then
        if    (CHIPSEL(0) = '1') then
          csel <= "0001";
        elsif (CHIPSEL(1) = '1') then
          csel <= "0010";
        elsif (CHIPSEL(2) = '1') then
          csel <= "0100";
        else
          csel <= "1000";
        end if;
      end if;
    end if;
  end process;

  ------------------------------
  --- MEM_ADB                ---
  ------------------------------
  process (CLK) begin
    if(CLK'event and CLK='1') then
      MEM_ADB <= lo_mem_wad + mem_ad_offset;
    end if;
  end process;

  ----------------------------
  -- DMAR EN COUNT     ---
  ----------------------------
  en_cnt0_r <= en_cnt0;
  process (RST,CLK,hit,hitr,en_cnt0_r) begin
    if(RST='1') then
      en_cnt0 <= (others=>'0');
    elsif(CLK'event and CLK='1') then
      if((hit = '0') AND (hitr = '1'))then
        en_cnt0 <= "0000" & NQWORD(8 downto 0);   -- SET NQWORD
      elsif(en_cnt0_r /= "000000000000") then
        en_cnt0 <= en_cnt0_r - "000000000001";
      end if;
    end if;
  end process;

  ----------------------------
  -- DMAR EN 0         ---
  ----------------------------
  process (RST,CLK,hit,hitr,en_cnt0) begin
    if(RST='1') then
      en0 <= '0';
    elsif(CLK'event and CLK='1') then
      if((hit = '0') AND (hitr = '1'))then
        en0 <= '1';
      elsif(en_cnt0 = "000000000000") then
        en0 <= '0';
      end if;
    end if;
  end process;

  process (CLK) begin
    if(CLK'event and CLK='1') then
      en7 <= en6;
      en6 <= en5;
      en5 <= en4;
      en4 <= en3;
      en3 <= en2;
      en2 <= en1;
      en1 <= en0;
    end if;
  end process;


  ------------------------------
  --- DMAR ENABLE            ---
  ------------------------------
  process (CLK,en1,en2)  begin
    if(CLK'event and CLK='1') then
      if((en0 = '1') OR (en1 = '1')) then
        DMAR_ENABLE(0) <= '1' AND csel(0);
        DMAR_ENABLE(1) <= '1' AND csel(1);
        DMAR_ENABLE(2) <= '1' AND csel(2);
        DMAR_ENABLE(3) <= '1' AND csel(3);
      else
        DMAR_ENABLE <= (others=>'0');
      end if;
    end if;
  end process;

  ------------------------------
  --- DBUS_PORT            ---
  ------------------------------
  process (RST,CLK,en0,en1,en2,en3)  begin
    if(RST='1') then
      DBUS_Port <= (others=>'0');
    elsif(CLK'event and CLK='1') then
      if(    (en0 = '1') AND (en1 = '0') ) then
        DBUS_Port <= ("000000000000000000000000000000000000000000000" & s_adr);
      elsif( (en1 = '1') AND (en2 = '0') ) then
--        DBUS_Port <= X"FFFFFFFFFFFFFFFF";
        NULL;
      elsif( (en2 = '1') AND (en3 = '0') ) then
        DBUS_Port <= (others=>'0');
      end if;
    end if;
  end process;

  ------------------------------
  --- DBUS_HiZ               ---
  ------------------------------
  process (RST,CLK,en2,en3,en4,en5)  begin
    if(RST='1') then
      DBUS_HiZ <= '0';
    elsif(CLK'event and CLK='1') then
      if((en2 = '1') OR (en3 = '1') OR (en4 = '1') OR (en5 = '1') ) then
        DBUS_HiZ <= '1';
      else
        DBUS_HiZ <= '0';
      end if;
    end if;
  end process;

  ------------------------------
  --- MEM_DTIB               ---
  ------------------------------
  process (CLK)  begin
    if(CLK'event and CLK='1') then
      MEM_DTIB <= DBUS_idata;
    end if;
  end process;

  ------------------------------
  --- MEM_WEHB, MEM_WELB     ---
  ------------------------------
  process (CLK)  begin
    if(CLK'event and CLK='1') then
      MEM_WEHB <= en6;
      MEM_WELB <= en6;
    end if;
  end process;

  ------------------------------
  --- lo_mem_wad             ---
  ------------------------------
  lo_mem_wad_z <= lo_mem_wad;
  process (RST,CLK,en5,en6)  begin
    if(RST='1') then
      lo_mem_wad <= "0000000000000";
    elsif(CLK'event and CLK='1') then
      if((en5 = '1') AND (en6 = '0')) then
        lo_mem_wad <= "0000000000000";
      elsif((en5 = '1') AND (en6 = '1')) then
        lo_mem_wad <= lo_mem_wad_z + "0000000000001";
      elsif((en5 = '0') AND (en6 = '1')) then
        lo_mem_wad <= "0000000000000";
      end if;
    end if;
  end process;

end rtl;
