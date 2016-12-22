-- multiple clock generator
-- by Tsuyoshi Hamada
-- Last Modified at 2004/01/11
-- ===== COMPONENT SAMPLE =======================================
--component CLK_MULDIV
--  generic (CLKFX_MULTIPLY : integer :=3;
--           CLKFX_DIVIDE : integer := 2);
--  port (ICLK : in std_logic;
--        OCLK : out std_logic;
--        OCLK_FX : out std_logic;
--        LOCKED : out std_logic);
--end component;
--
-- ===== INSTANCIATION SAMPLE ====================================
--dcm0 : CLK_MULDIV
----  generic map (CLKFX_MULTIPLY =>11,CLKFX_DIVIDE=>2) -- 183MHz
----  generic map (CLKFX_MULTIPLY =>16,CLKFX_DIVIDE=>3) -- 178MHz
----  generic map (CLKFX_MULTIPLY =>5,CLKFX_DIVIDE=>1)  -- 167MHz
----  generic map (CLKFX_MULTIPLY =>9,CLKFX_DIVIDE=>2)  -- 150MHz
----  generic map (CLKFX_MULTIPLY =>4,CLKFX_DIVIDE=>1)  -- 133MHz
----  generic map (CLKFX_MULTIPLY =>7,CLKFX_DIVIDE=>2)  -- 117MHz
----  generic map (CLKFX_MULTIPLY =>3,CLKFX_DIVIDE=>1)  -- 100MHz
----  generic map (CLKFX_MULTIPLY =>2,CLKFX_DIVIDE=>1)  -- 67MHz
--  generic map (CLKFX_MULTIPLY =>1,CLKFX_DIVIDE=>1)    -- 33MHz if SYS_CLK is 33MHz
--  port map (
--	ICLK=>SYS_CLK,
--	OCLK=>clk,
--	OCLK_FX=>pclk,
--	LOCKED=>dcm_locked);


library ieee;
LIBRARY UNISIM;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;                                        
use ieee.std_logic_unsigned.all;                                    
USE UNISIM.Vcomponents.ALL;

entity CLK_MULDIV is
  generic (CLKFX_MULTIPLY : integer :=3;
           CLKFX_DIVIDE : integer := 2);
  port (ICLK : in std_logic;
        OCLK : out std_logic;
        OCLK_FX : out std_logic;
        LOCKED : out std_logic);
end CLK_MULDIV;

architecture rtl of CLK_MULDIV is
component BUFG port (I: in  std_logic;  O: out  std_logic); 
end component;
component IBUFG port(I: in std_logic; O: out std_logic);
end component;
component DCM
  generic ( 
       CLKFX_MULTIPLY : integer := 3;
       CLKFX_DIVIDE : integer := 2;
       CLKIN_PERIOD : real := 15.000000;
       DLL_FREQUENCY_MODE : string := "LOW";
       DUTY_CYCLE_CORRECTION : boolean := TRUE;
       CLKOUT_PHASE_SHIFT : string := "FIXED";
       PHASE_SHIFT  : integer := 0;
       STARTUP_WAIT : boolean := FALSE
      );  
  port ( CLKIN   : in  std_logic;
       CLKFB   : in  std_logic;
       DSSEN   : in  std_logic;
       PSINCDEC   : in  std_logic;
       PSEN     : in  std_logic;
       PSCLK   : in  std_logic;
       RST     : in  std_logic;
       CLK0     : out std_logic;
       CLK90   : out std_logic;
       CLK180   : out std_logic;
       CLK270   : out std_logic;
       CLK2X   : out std_logic;
       CLK2X180   : out std_logic;
       CLKDV   : out std_logic;
       CLKFX   : out std_logic;
       CLKFX180   : out std_logic;
       LOCKED   : out std_logic;
       PSDONE   : out std_logic;
       STATUS   : out std_logic_vector(7 downto 0)
      );
end component;

signal dcm_in,dcm_out,dcm_fx,dcm_fb : std_logic;

begin

dcm0 : DCM
  generic map (CLKFX_MULTIPLY=>CLKFX_MULTIPLY,
	CLKFX_DIVIDE=>CLKFX_DIVIDE,
        CLKIN_PERIOD => 15.000000,
	DUTY_CYCLE_CORRECTION=>TRUE)
  port map(
    RST          => '0',         -- ���Z�b�g
    CLKIN        => dcm_in,      -- PHASE SHIFT���̓N���b�N
    CLKFB        => dcm_fb,         -- FB����
    DSSEN        => '0',
    PSINCDEC     => '0',
    PSEN         => '0',         -- �ʑ��V�t�g�C�l�[�u��
    PSCLK        => '0',         -- �ʑ��V�t�g�N���b�N
    LOCKED       => LOCKED,
    CLKFX        => dcm_fx,      -- ICLK x N
    CLK0         => dcm_out      -- PHASE SHIFT�o�̓N���b�N
  );

U_BUFG0 : IBUFG port map(I=>ICLK, O=>dcm_in);
U_BUFG1 : BUFG port map(I=>dcm_out,   O=>dcm_fb);
U_BUFG2 : BUFG port map(I=>dcm_fx, O=>OCLK_FX);  -- 66,100,133MHz
OCLK <= dcm_fb;
end rtl;

