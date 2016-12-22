
-- **************************************
--               INREVIUM                
-- **************************************

--------------------------------------------------------------------------------
-- Copyright(C) 2004 - TOKYO ELECTRON DEVICE LIMITED. All rigths reserved.
--------------------------------------------------------------------------------
-- PCI_RDTFIFO MODEL
--------------------------------------------------------------------------------
-- PCI_RDTFIFO (64 bit X 4 word) Module
--------------------------------------------------------------------------------
-- File                      : PCI_RDTFIFO.vhd
-- Entity                    : PCI_RDTFIFO
-- Architecture              : PCI_RDTFIFO_rtl
--------------------------------------------------------------------------------
-- Project Navigator version : ISE6.2.03i
-- Design Flow               : XST
--------------------------------------------------------------------------------
-- Ver.     Data        Coded by        Contents
-- 01.00    2004/08/10  TED)DDC         �V�K
--------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;


entity PCI_RDTFIFO is
	port (
		RST 			: in	std_logic;							-- PCI Bus Reset
		CLK 			: in	std_logic;							-- PCI bus Clock

		FIFO_ENB		: in	std_logic;							-- FIFO Enable Signal

		-- FIFO Data Write ports
		FIFO_WRDT		: in	std_logic_vector(63 downto 0);		-- FIFO Write Data
		FIFO_WE			: in	std_logic;					  		-- FIFO Write Enable

		-- FIFO Data Read ports
		FIFO_RE			: in	std_logic;							-- FIFO Read Enable
		FIFO_RDDT		: out	std_logic_vector(63 downto 0);		-- FIFO Read Data
		FIFO_RDTEN		: out	std_logic							-- FIFO Read Data Enable
		);
end PCI_RDTFIFO;


architecture PCI_RDTFIFO_rtl of PCI_RDTFIFO is


--------------------------------------------------
-- signals
--------------------------------------------------

--	type FIFO_TYPE is array (0 to 3) of std_logic_vector(64 downto 0);		------ Define Data Buffer Type (65bit X 4)

	signal FIFO_DATA0	: std_logic_vector(64 downto 0);					------ FIFO Data Buffer 0
	signal FIFO_DATA1	: std_logic_vector(64 downto 0);					------ FIFO Data Buffer 1
	signal FIFO_DATA2	: std_logic_vector(64 downto 0);					------ FIFO Data Buffer 2
	signal FIFO_DATA3	: std_logic_vector(64 downto 0);					------ FIFO Data Buffer 3

	signal FIFO_WRADRS	: std_logic_vector( 1 downto 0);					------ FIFO Write Address
	signal FIFO_RDADRS	: std_logic_vector( 1 downto 0);					------ FIFO Read Address


begin


--***************************************************************
--*
--*  FIFO Data Write Control Block
--*
--***************************************************************

--------------------------------------------------------------------------------
-- FIFO_DATA0 Data Write Control Process
--------------------------------------------------------------------------------

	process (RST,CLK) begin
		if (RST='1') then
			FIFO_DATA0 <= (others=>'0');
		elsif (CLK'event and CLK='1') then
			if (FIFO_ENB='0') then											------ FIFO Disable ?
				FIFO_DATA0 <= (others=>'0');								------ FIFO Data Clear
			elsif (FIFO_WRADRS="00" and FIFO_WE='1') then					------ FIFO Data Write ?
				FIFO_DATA0 <= FIFO_WE & FIFO_WRDT;							------ FIFO Write Data Set
			end if;
		end if;
	end process;

--------------------------------------------------------------------------------
-- FIFO_DATA1 Data Write Control Process
--------------------------------------------------------------------------------

	process (RST,CLK) begin
		if (RST='1') then
			FIFO_DATA1 <= (others=>'0');
		elsif (CLK'event and CLK='1') then
			if (FIFO_ENB='0') then											------ FIFO Disable ?
				FIFO_DATA1 <= (others=>'0');								------ FIFO Data Clear
			elsif (FIFO_WRADRS="01" and FIFO_WE='1') then					------ FIFO Data Write ?
				FIFO_DATA1 <= FIFO_WE & FIFO_WRDT;							------ FIFO Write Data Set
			end if;
		end if;
	end process;

--------------------------------------------------------------------------------
-- FIFO_DATA2 Data Write Control Process
--------------------------------------------------------------------------------

	process (RST,CLK) begin
		if (RST='1') then
			FIFO_DATA2 <= (others=>'0');
		elsif (CLK'event and CLK='1') then
			if (FIFO_ENB='0') then											------ FIFO Disable ?
				FIFO_DATA2 <= (others=>'0');								------ FIFO Data Clear
			elsif (FIFO_WRADRS="10" and FIFO_WE='1') then					------ FIFO Data Write ?
				FIFO_DATA2 <= FIFO_WE & FIFO_WRDT;							------ FIFO Write Data Set
			end if;
		end if;
	end process;

--------------------------------------------------------------------------------
-- FIFO_DATA3 Data Write Control Process
--------------------------------------------------------------------------------

	process (RST,CLK) begin
		if (RST='1') then
			FIFO_DATA3 <= (others=>'0');
		elsif (CLK'event and CLK='1') then
			if (FIFO_ENB='0') then											------ FIFO Disable ?
				FIFO_DATA3 <= (others=>'0');								------ FIFO Data Clear
			elsif (FIFO_WRADRS="11" and FIFO_WE='1') then					------ FIFO Data Write ?
				FIFO_DATA3 <= FIFO_WE & FIFO_WRDT;							------ FIFO Write Data Set
			end if;
		end if;
	end process;

--------------------------------------------------------------------------------
-- FIFO Write Address Control Process
--------------------------------------------------------------------------------

	process (RST,CLK) begin
		if (RST='1') then
			FIFO_WRADRS <= (others=>'0');
		elsif (CLK'event and CLK='1') then
			if (FIFO_ENB='0') then											------ FIFO Disable ?
				FIFO_WRADRS <= (others=>'0');								------ FIFO Write Address Clear
			elsif (FIFO_WE='1') then										------ FIFO Data Write ?
				FIFO_WRADRS <= FIFO_WRADRS+1;								------ FIFO Write Address Increment
			end if;
		end if;
	end process;


--***************************************************************
--*
--*  FIFO Data Read Control Block
--*
--***************************************************************

--------------------------------------------------------------------------------
-- FIFO Read Data Select Control Process
--------------------------------------------------------------------------------

	process (FIFO_RDADRS,FIFO_DATA0,FIFO_DATA1,FIFO_DATA2,FIFO_DATA3) begin
		case FIFO_RDADRS is
			when "00"	=> FIFO_RDDT <= FIFO_DATA0(63 downto 0);			------ Buffer0 Read
			when "01"	=> FIFO_RDDT <= FIFO_DATA1(63 downto 0);			------ Buffer1 Read
			when "10"	=> FIFO_RDDT <= FIFO_DATA2(63 downto 0);			------ Buffer2 Read
			when "11"	=> FIFO_RDDT <= FIFO_DATA3(63 downto 0);			------ Buffer3 Read
			when others => FIFO_RDDT <= (others=>'0');
		end case;
	end process;

--------------------------------------------------------------------------------
-- FIFO Read Data Enable Signal Select Control Process
--------------------------------------------------------------------------------

	process (FIFO_RDADRS,FIFO_DATA0,FIFO_DATA1,FIFO_DATA2,FIFO_DATA3) begin
		case FIFO_RDADRS is
			when "00"	=> FIFO_RDTEN <= FIFO_DATA0(64);					------ Buffer0 Read Enable Signal
			when "01"	=> FIFO_RDTEN <= FIFO_DATA1(64);					------ Buffer1 Read Enable Signal
			when "10"	=> FIFO_RDTEN <= FIFO_DATA2(64);					------ Buffer2 Read Enable Signal
			when "11"	=> FIFO_RDTEN <= FIFO_DATA3(64);					------ Buffer3 Read Enable Signal
			when others => FIFO_RDTEN <= '0';
		end case;
	end process;

--------------------------------------------------------------------------------
-- FIFO Read Address Control Process
--------------------------------------------------------------------------------

	process (RST,CLK) begin
		if (RST='1') then
			FIFO_RDADRS <= (others=>'0');
		elsif (CLK'event and CLK='1') then
			if (FIFO_ENB='0') then											------ FIFO Disable ?
				FIFO_RDADRS <= (others=>'0');								------ FIFO Read Address Clear
			elsif (FIFO_RE='1') then										------ FIFO Data Read ?
				FIFO_RDADRS <= FIFO_RDADRS+1;								------ FIFO Read Address Increment
			end if;
		end if;
	end process;



end PCI_RDTFIFO_rtl;
