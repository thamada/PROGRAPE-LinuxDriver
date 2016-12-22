
-- **************************************
--               INREVIUM                
-- **************************************

--------------------------------------------------------------------------------
-- Copyright(C) 2004 - TOKYO ELECTRON DEVICE LIMITED. All rigths reserved.
--------------------------------------------------------------------------------
-- PCI_TARGETCNT MODEL
--------------------------------------------------------------------------------
-- PCI64_CORE Target Access Control Module
--------------------------------------------------------------------------------
-- File                      : PCI_TARGETCNT.vhd
-- Entity                    : PCI_TARGETCNT
-- Architecture              : PCI_TARGETCNT_rtl
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


entity PCI_TARGETCNT is
	port (
	-- Interface to PCI Logicore.
		FRAMEQ_N		: in	std_logic;							-- Latched FRAME# Signal
		REQ64Q_N		: in	std_logic;							-- Latched REQ64# Signal
		TRDYQ_N 		: in	std_logic;							-- Latched TRDY# Signal
		IRDYQ_N 		: in	std_logic;							-- Latched IRDY# Signal
		STOPQ_N 		: in	std_logic;							-- Latched STOP# Signal
		DEVSELQ_N		: in	std_logic;							-- Latched DEVSEL# Signal
		ACK64Q_N		: in	std_logic;							-- Latched ACK64# Signal

		ADDR			: in	std_logic_vector( 31 downto 0);		-- Latched Target Address Bus
		ADIO			: inout std_logic_vector( 63 downto 0);		-- Internal Address/Data Bus

		CFG_VLD 		: in	std_logic;							-- Configulation Cycle Valid
		CFG_HIT 		: in	std_logic;							-- Configuration Cycle Start
		C_TERM			: out	std_logic;							-- Configuraton Cycle Terminate Signal
		C_READY 		: out	std_logic;							-- Configuration Data Transfer Ready Signal

		ADDR_VLD		: in	std_logic;							-- Internal Address Valid
		BASE_HIT		: in	std_logic_vector(  7 downto 0);		-- Base Address Hit

		S_CYCLE64		: in	std_logic;							-- 64 bit Transaction Go On
		S_TERM			: out	std_logic;							-- Target Transaction Terminate Signal
		S_READY 		: out	std_logic;							-- Target Transaction Data Transfer Ready Siganl
		S_ABORT 		: out	std_logic;							-- Target Abort Request Signal
		S_WRDN			: in	std_logic;							-- Target Transaction Data Direction (0:Write, 1:Read)
		S_SRC_EN		: in	std_logic;							-- Target Transaction Data Source Enable
		S_DATA_VLD		: in	std_logic;							-- Target Transaction Data Phase Valid Signal
		S_CBE			: in	std_logic_vector(  7 downto 0);		-- Target Command & Byte Enable Signal
		PCI_CMD 		: in	std_logic_vector( 15 downto 0);		-- Latched Bus Command

		IDLE			: in	std_logic;							-- Target Idle State
		B_BUSY			: in	std_logic;							-- PCI Bus Busy State
		S_DATA			: in	std_logic;							-- Target Data Transfer State
		BACKOFF 		: in	std_logic;							-- Target State Machine Transaction End State

		SLOT64			: out	std_logic;							-- 64 bit Extended Signal Eable
		PERRQ_N 		: in	std_logic;							-- latched PERR# Signal
		SERRQ_N 		: in	std_logic;							-- Latched SERR# Signal
		KEEPOUT 		: out	std_logic;							-- ADIO Bus Disable Request Signal

		CSR 			: in	std_logic_vector( 39 downto 0);		-- Command/Status Register State
		SUB_DATA		: out	std_logic_vector( 31 downto 0);		-- Sub-Identification
		CFG 			: in	std_logic_vector(255 downto 0);		-- Confiuration Data

		RST 			: in	std_logic;							-- PCI Bus Reset
		CLK 			: in	std_logic;							-- PCI bus Clock

	-- Internal Block Target Access Control Signal
		TARGET_AD		: out	std_logic_vector(31 downto 0);		-- Target Access Address

		FIFO_RDDT		: in	std_logic_vector(63 downto 0);		-- FIFO Read Data
		FIFO_RDTEN		: in	std_logic;							-- FIFO Read Data Enable Signel

	-- Base Address 0 Area (Internal Register) Target Access Control Signal
		BAR0_WRDT		: out	std_logic_vector(31 downto 0);		-- BAR0 Area Target Access Write Data
		BAR0_WR			: out	std_logic_vector( 3 downto 0);		-- BAR0 Area Target Access Write Signal
		BAR0_RD			: out	std_logic;							-- BAR0 Area Target Access Read  Signal

	-- Base Address 1 Area (Internal Memoery) Target Access Control Signal
		BAR1_WRDT		: out	std_logic_vector(63 downto 0);		-- BAR1 Area Target Access Write Data
		BAR1_WR			: out	std_logic_vector( 7 downto 0);		-- BAR1 Area Target Access Write Signal
		BAR1_RD			: out	std_logic							-- BAR1 Area Target Access Read  Signal
		);
end PCI_TARGETCNT;


architecture PCI_TARGETCNT_rtl of PCI_TARGETCNT is

--------------------------------------------------
-- Components
--------------------------------------------------


--------------------------------------------------
-- signals
--------------------------------------------------

-- Internal Block R/W Select Signal
--
--	BAR0 : Internal Register
--	BAR1 : Internal Memory Block

	signal	BAR0_WRENB		: std_logic;							-- BAR0 Block Write Select Signal
	signal	BAR0_RDENB		: std_logic;							-- BAR0 Block Read  Select Signal

	signal	BAR1_WRENB		: std_logic;							-- BAR1 Block Write Select Signal
	signal	BAR1_RDENB		: std_logic;							-- BAR1 Block Read  Select Signal

-- Internal Block Access Control Signal
	signal	TARGET_ADRS		: std_logic_vector(31 downto 2);		-- Target Access Address

	signal	PRERD_CNT		: std_logic_vector(3 downto 0);			-- Pre READ Signal Assert Control

	signal	BAR0_PRERD		: std_logic;							-- BAR0 Block Pre-Read Signal
	signal	BAR1_PRERD		: std_logic;							-- BAR1 Block Pre-Read Signal

	signal	BAR0_READ		: std_logic;							-- Internal BAR0 Block Read Signal
	signal	BAR1_READ		: std_logic;							-- Internal BAR1 Block Read Signal

	signal	DTRD_FLG		: std_logic;							-- Data Read Flag



begin



--***************************************************************
--*
--*  Base Address 0 Area Access Control Signal Generate Block
--*
--***************************************************************

--------------------------------------------------------------------------------
-- BAR0(Internal Register) R/W Select Signal Control Process
--------------------------------------------------------------------------------

	process (RST,CLK) begin
		if (RST='1') then
			BAR0_WRENB <= '0';
			BAR0_RDENB <= '0';
		elsif (CLK'event and CLK='1') then
			if (BASE_HIT(0)='1') then										------ Base Address 0 Area Access ?
				BAR0_WRENB <= S_WRDN;										------ R/W Status Set
				BAR0_RDENB <= (not S_WRDN);
			elsif (S_DATA='0') then											------ Transaction End ?
				BAR0_WRENB <= '0';											------ Select Signal Clear
				BAR0_RDENB <= '0';
			end if;
		end if;
	end process;

--------------------------------------------------------------------------------
-- BAR0(Internal Register) Area Write Signal Control Process
--------------------------------------------------------------------------------

	process (BAR0_WRENB,S_DATA_VLD,S_CBE) begin
		if (BAR0_WRENB='1' and S_DATA_VLD='1') then							------ BAR0 Target Data Write Available ?
			BAR0_WR <= (not S_CBE(3 downto 0));								------ High Word Write Signal Set
		else
			BAR0_WR <= (others => '0');										------ BAR0_WR Signal Negate
		end if;
	end process;

--------------------------------------------------------------------------------
-- BAR0(Internal Register) Area Write Data Control Process
--------------------------------------------------------------------------------

	process (BAR0_WRENB,S_DATA_VLD,ADIO) begin
		if (BAR0_WRENB='1' and S_DATA_VLD='1') then							------ BAR0 Target Data Write Available ?
			BAR0_WRDT(31 downto  0) <= ADIO(31 downto 0);					------ Low  Word Write Data Set
		else
			BAR0_WRDT <= (others => '0');									------ Write Data Clear
		end if;
	end process;

--------------------------------------------------------------------------------
-- BAR0(Internal Register) Area Pre-Read Signal Control Process
--------------------------------------------------------------------------------

	process (RST,CLK) begin
		if (RST='1') then
			BAR0_PRERD <= '0';
		elsif (CLK'event and CLK='1') then
			if (BASE_HIT(0)='1' and S_WRDN='0') then						------ Base Address 0 Area Read Access ?
				BAR0_PRERD <= '1';											------ Base Address 0 Area Pre-Read Start
			elsif (PRERD_CNT(3)='1') then									------ Pre Read Data Transfer End ?
				BAR0_PRERD <= '0';											------ Base Address 0 Area Pre-Read End
			end if;
		end if;
	end process;

--------------------------------------------------------------------------------
-- BAR0(Internal Register) Area Read Signal Control Process
--------------------------------------------------------------------------------

		BAR0_READ <= (BAR0_PRERD or S_SRC_EN) and BAR0_RDENB;			------ Data Read Signal Set

		BAR0_RD   <= BAR0_READ;												------ Data Read Signal Output


--***************************************************************
--*
--*  Base Address 1 Area Access Control Signal Generate Block
--*
--***************************************************************

--------------------------------------------------------------------------------
-- BAR1(Internal Memory) R/W Select Signal Control Process
--------------------------------------------------------------------------------

	process (RST,CLK) begin
		if (RST='1') then
			BAR1_WRENB <= '0';
			BAR1_RDENB <= '0';
		elsif (CLK'event and CLK='1') then
			if (BASE_HIT(1)='1') then										------ Base Address 1 Area Access ?
				BAR1_WRENB <= S_WRDN;										------ R/W Status Set
				BAR1_RDENB <= (not S_WRDN);
			elsif (S_DATA='0') then											------ Transaction End ?
				BAR1_WRENB <= '0';											------ Select Signal Clear
				BAR1_RDENB <= '0';
			end if;
		end if;
	end process;

--------------------------------------------------------------------------------
-- BAR1(Internal Memory) Area Write Signal Control Process
--------------------------------------------------------------------------------

	process (BAR1_WRENB,S_DATA_VLD,S_CYCLE64,TARGET_ADRS,S_CBE) begin
		if (BAR1_WRENB='1' and S_DATA_VLD='1') then							------ BAR1 Target Data Write Available ?
			if (S_CYCLE64='1') then											------ 64 bit Access ?
				BAR1_WR <= (not S_CBE);										------ S_CBE Signal Set
			else
				if (TARGET_ADRS(2)='1') then								------ 32 bit Odd Address Write ?
					BAR1_WR <= (not S_CBE(3 downto 0)) & "0000";			------ High Word Write Signal Set
				else
					BAR1_WR <=  "0000" & (not S_CBE(3 downto 0));			------ High Word Write Signal Set
				end if;
			end if;
		else
				BAR1_WR <= (others => '0');									------ BAR1_WR Signal Negate
		end if;
	end process;

--------------------------------------------------------------------------------
-- BAR1(Internal Memory) Area Write Data Control Process
--------------------------------------------------------------------------------

	process (BAR1_WRENB,S_DATA_VLD,S_CYCLE64,TARGET_ADRS,ADIO) begin
		if (BAR1_WRENB='1' and S_DATA_VLD='1') then							------ BAR1 Target Data Write Available ?
			if (S_CYCLE64='1') then											------ 64 bit Access ?
				BAR1_WRDT <= ADIO;											------ 64 bit Write Data Output
			else
				if (TARGET_ADRS(2)='1') then								------ 32 bit Odd Address Write ?
					BAR1_WRDT(31 downto  0) <= (others => '0');				------ Low  Word Write Data Clear
					BAR1_WRDT(63 downto 32) <= ADIO(31 downto 0);			------ High Word Write Data Set
				else
					BAR1_WRDT(31 downto  0) <= ADIO(31 downto 0);			------ Low  Word Write Data Set
					BAR1_WRDT(63 downto 32) <= (others => '0');				------ High Word Write Data Clear
				end if;
			end if;
		else
				BAR1_WRDT <= (others => '0');								------ Write Data Clear
		end if;
	end process;

--------------------------------------------------------------------------------
-- BAR1(Internal Memory) Area Pre-Read Signal Control Process
--------------------------------------------------------------------------------

	process (RST,CLK) begin
		if (RST='1') then
			BAR1_PRERD <= '0';
		elsif (CLK'event and CLK='1') then
			if (BASE_HIT(1)='1' and S_WRDN='0') then						------ Base Address 1 Area Read Access ?
				BAR1_PRERD <= '1';											------ Base Address 1 Area Pre-Read Start
			elsif (PRERD_CNT(3)='1') then									------ Pre Read Data Transfer End ?
				BAR1_PRERD <= '0';											------ Base Address 1 Area Pre-Read End
			end if;
		end if;
	end process;

--------------------------------------------------------------------------------
-- BAR1(Internal Memory) Area Read Signal Control Process
--------------------------------------------------------------------------------

		BAR1_READ <= (BAR1_PRERD or S_SRC_EN) and BAR1_RDENB;			------ Data Read Signal Set

		BAR1_RD   <= BAR1_READ;												------ Data Read Signal Output

--------------------------------------------------------------------------------
-- S_READY Signal Output Control Process
--------------------------------------------------------------------------------

		S_READY <= BAR0_WRENB or BAR1_WRENB or FIFO_RDTEN;					------ Target Write Access Start or Read Data Available

--------------------------------------------------------------------------------
-- Internal Block Pre-Read Signal Control Process
--------------------------------------------------------------------------------

	process (RST,CLK) begin
		if (RST='1') then
			PRERD_CNT <= (others=>'0');
		elsif (CLK'event and CLK='1') then
			PRERD_CNT <= PRERD_CNT(2 downto 0) & (BAR0_PRERD or BAR1_PRERD);		------ FRAMEQ_N Signal Sampling
		end if;
	end process;

--------------------------------------------------------------------------------
-- Target Access Address Output Control Process
--------------------------------------------------------------------------------

	process (RST,CLK) begin
		if (RST='1') then
			TARGET_ADRS <= (others=>'0');
		elsif (CLK'event and CLK='1') then
			if (ADDR_VLD='1') then											------- Target Access Start ?
				TARGET_ADRS <= ADIO(31 downto 2);							------- Start Address Set
			elsif (S_WRDN='1' and S_DATA_VLD='1') then						------- Target Write Access ?
				if (S_CYCLE64='1') then										------- 64 bit Access ?
					TARGET_ADRS <= TARGET_ADRS+2;							------- Access Address Increment +2
				else
					TARGET_ADRS <= TARGET_ADRS+1;							------- Access Address Increment +1
				end if;
			elsif (BAR0_READ='1' or BAR1_READ='1') then						------- Target Read Access ?
				if (S_CYCLE64='1') then										------- 64 bit Access ?
					TARGET_ADRS <= TARGET_ADRS+2;							------- Access Address Increment +2
				else
					TARGET_ADRS <= TARGET_ADRS+1;							------- Access Address Increment +1
				end if;
			end if;
		end if;
	end process;

		TARGET_AD <= TARGET_ADRS & "00";									------- Target Access Address Output

--------------------------------------------------------------------------------
-- ADIO Signal Output Control Process
--------------------------------------------------------------------------------

	process (S_DATA,FIFO_RDTEN,FIFO_RDDT) begin
		if (S_DATA='1' and FIFO_RDTEN='1') then								------ PCI Target Read Transaction & Data Valid ?
			ADIO <= FIFO_RDDT;												------ Read Data Output
		else
			ADIO <= (others=>'Z');									--: inout std_logic_vector( 63 downto 0);
		end if;
	end process;


--***************************************************************
--*
--*  Unused or Fixed PCI Core Signal Control Block
--*
--***************************************************************


		C_TERM			<= '0'; --: out   std_logic;
		C_READY 		<= '1'; --: out   std_logic;

		S_TERM			<= '0'; --: out   std_logic;
		S_ABORT 		<= '0'; --: out   std_logic;

		SLOT64			<= '1'; --: out   std_logic;
		KEEPOUT 		<= '0'; --: out   std_logic;

		SUB_DATA		<= (others=>'0'); 								--: out	 std_logic_vector( 31 downto 0);





end PCI_TARGETCNT_rtl;
