
-- **************************************
--               INREVIUM                
-- **************************************

--------------------------------------------------------------------------------
-- Copyright(C) 2004 - TOKYO ELECTRON DEVICE LIMITED. All rigths reserved.
--------------------------------------------------------------------------------
-- PCI_DMACNT MODEL
--------------------------------------------------------------------------------
-- Internal Register Control Module
--------------------------------------------------------------------------------
-- File                      : pci_dmacnt.vhd
-- Entity                    : PCI_DMACNT
-- Architecture              : PCI_DMACNT_rtl
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


entity PCI_DMACNT is
	port (
		RST 			: in	std_logic;							-- PCI Bus Reset
		CLK 			: in	std_logic;							-- PCI bus Clock

		FRAMEQ_N		: in	std_logic;							-- Latched FRAME# Signal
		REQ64Q_N		: in	std_logic;							-- Latched REQ64# Signal
		TRDYQ_N 		: in	std_logic;							-- Latched TRDY# Signal
		IRDYQ_N 		: in	std_logic;							-- Latched IRDY# Signal
		STOPQ_N 		: in	std_logic;							-- Latched STOP# Signal
		DEVSELQ_N		: in	std_logic;							-- Latched DEVSEL# Signal
		ACK64Q_N		: in	std_logic;							-- Latched ACK64# Signal

		ADIO			: inout std_logic_vector( 63 downto 0);		-- Internal Address/Data Bus

		REQUEST 		: out	std_logic;							-- REQ# Signal Assert Request
		REQUEST64		: out	std_logic;							-- REQ64# Signal Assert Request
		REQUESTHOLD 	: out	std_logic;							-- Extended REQ# Signal Assert Request (Not Use)
		COMPLETE		: out	std_logic;							-- Initiator Transaction End Signal

		M_WRDN			: out	std_logic;							-- Initiator Transaction Data Direction (0:Write, 1:Read)
		M_READY 		: out	std_logic;							-- Initiator Transaction Data Transfer Ready Siganl
		M_SRC_EN		: in	std_logic;							-- Initiator Transaction Data Source Enable
		M_DATA_VLD		: in	std_logic;							-- Initiator Transaction Data Phase Valid Signal
		M_CBE			: out	std_logic_vector(  7 downto 0);		-- Initiator Command & Byte Enable Signal

		TIME_OUT		: in	std_logic;							-- Latency Timer Timeout Signal
		M_FAIL64		: in	std_logic;							-- 64 bit Transaction Fail Signal
		CFG_SELF		: out	std_logic;							-- Self Configuration Start Signal

		M_DATA			: in	std_logic;							-- Data Transfer State
		DR_BUS			: in	std_logic;							-- Bus Park State
		I_IDLE			: in	std_logic;							-- Initiator Idle State
		M_ADDR_N		: in	std_logic;							-- Initiator Address State

		PERRQ_N 		: in	std_logic;							-- latched PERR# Signal
		SERRQ_N 		: in	std_logic;							-- Latched SERR# Signal

		CSR 			: in	std_logic_vector( 39 downto 0);		-- Command/Status Register State
		CFG 			: in	std_logic_vector(255 downto 0);		-- Confiuration Data

	-- DMA Register R/W ports
		DMAREG_AD		: in	std_logic_vector( 7 downto 0);		-- PCI_DMACNT R/W Address
		DMAREG_WE		: in	std_logic;							-- PCI_DMACNT Write Enable
		DMAREG_RE		: in	std_logic;							-- PCI_DMACNT Read Enable
		DMAREG_DTI		: in	std_logic_vector(31 downto 0);		-- PCI_DMACNT Write Data
		DMAREG_DTO		: out	std_logic_vector(31 downto 0);		-- PCI_DMACNT Read Data
		DMAREG_DTOEN	: out	std_logic;							-- PCI_DMACNT Read Data Enable

	-- Internal DMA Access Control Signal
		DMA_ADRS		: out	std_logic_vector(31 downto 0);		-- Internal Memory DMA Access Address

		DMA_WRDT		: out	std_logic_vector(63 downto 0);		-- Internal Memory DMA Access Write Data
		DMA_WRT			: out	std_logic_vector( 7 downto 0);		-- Internal Memory DMA Access Write Signal
		DMA_READ		: out	std_logic;							-- Internal Memory DMA Access Read  Signal

		FIFO_RDDT		: in	std_logic_vector(63 downto 0);		-- FIFO Read Data
		FIFO_RDTEN		: in	std_logic;							-- FIFO Read Data Enable Signel

		DMATRNS_ENB		: out	std_logic;							-- PCI DMA Transfer Enable

		DMAEND_INT		: out	std_logic;					  		-- DMA End Interrupt On Request



--################################
--##    for Debug
--################################


		DEBUG_OUT		: out	std_logic_vector( 7 downto 0)



		);
end PCI_DMACNT;


architecture PCI_DMACNT_rtl of PCI_DMACNT is


--------------------------------------------------------------------------------
-- constant
--------------------------------------------------------------------------------

-- PCI Bus Control
	constant c_MEMRD		: std_logic_vector(3 downto 0) := "0110";	-- Memory Read
	constant c_MEMRD_L		: std_logic_vector(3 downto 0) := "1110";	-- Memory Read Line
	constant c_MEMRD_M		: std_logic_vector(3 downto 0) := "1100";	-- Memory Read Multipul
	constant c_MEMWRT		: std_logic_vector(3 downto 0) := "0111";	-- Memory Write
	constant c_MEMWRT_IV	: std_logic_vector(3 downto 0) := "1111";	-- Memory Write Invalidate
	constant c_IORD			: std_logic_vector(3 downto 0) := "0010";	-- I/O Read
	constant c_IOWRT		: std_logic_vector(3 downto 0) := "0011";	-- I/O Write
	constant c_CFGRD		: std_logic_vector(3 downto 0) := "1010";	-- Configuration Read
	constant c_CFGWRT		: std_logic_vector(3 downto 0) := "1011";	-- Configuration Write
	constant c_IACK			: std_logic_vector(3 downto 0) := "0000";	-- Interrupt Acknowledge Cycle
	constant c_SPECIAL		: std_logic_vector(3 downto 0) := "0001";	-- Special Cycle
	constant c_DUAL_ADRS	: std_logic_vector(3 downto 0) := "1101";	-- Dual Address Cycle


--------------------------------------------------
-- signals
--------------------------------------------------

-- Register Access Control Signal

	signal REG_SEL		: std_logic_vector(10 downto  0);			-- Register Select Signal
--	signal REG_SEL		: std_logic_vector( 5 downto  0);			-- Register Select Signal

	signal PCIADRS_SEL	: std_logic;								-- DMA PCI Address Register Select
	signal LOCALAD_SEL	: std_logic;								-- DMA Local Address Register Select
	signal DMACUNT_SEL	: std_logic;								-- DMA Counter Register Select
	signal DMACTRL_SEL	: std_logic;								-- DMA Control Register Select
	signal DMAINTV_SEL	: std_logic;								-- DMA Interval Register Select
	signal DMASTAT_SEL	: std_logic;								-- DMA Status Register Select

	signal REGRD_CNT	: std_logic;								-- Register Read Timing Control Signal

-- DMA PCI Address Register

	signal PCIADRS_DT	: std_logic_vector(31 downto  2);			-- DMA PCI Address Register Data
	signal PCIADRS_RDDT	: std_logic_vector(31 downto  0);			-- DMA PCI Address Register Read Data

-- DMA Local Address Register

	signal LOCALAD_DT	: std_logic_vector(23 downto  2);			-- General Register Data
	signal LOCALAD_RDDT	: std_logic_vector(31 downto  0);			-- General Register Read Data

-- DMA Counter Register

	signal DMACUNT_DT	: std_logic_vector(23 downto  2);			-- DMA Counter Register Data
	signal DMACUNT_RDDT	: std_logic_vector(31 downto  0);			-- DMA Counter Register Read Data

-- DMA Control Register

	signal DMASTAT_BIT	: std_logic;								-- DMA Start/Stop Control Bit
	signal DMA64_BIT	: std_logic;								-- DMA Data Width Bit (0:32 bit. 1:64 bit)
	signal DMAMODE_BIT	: std_logic_vector( 1 downto  0);			-- DMA Mode Bit
	signal DMADIR_BIT	: std_logic;								-- DMA Direction Bit (0:MEM->PCI, 1:PCI->MEM)

	signal DMACTRL_RDDT	: std_logic_vector(31 downto  0);			-- DMA Control Register Read Data

-- DMA Interval Register

	signal DMALNGTH_DT	: std_logic_vector(31 downto 16);			-- DMA Length Data
	signal DMAINTV_DT	: std_logic_vector(15 downto  0);			-- DMA Interval Data

	signal DMAINTV_RDDT	: std_logic_vector(31 downto  0);			-- DMA Interval Register Read Data

-- DMA Status Register

	signal DISCNCT_CUNT	: std_logic_vector(31 downto 16);			-- Disconnect Counter Data
	signal RETRY_CUNT	: std_logic_vector(15 downto  0);			-- Retry Counter Data

	signal DMASTAT_RDDT	: std_logic_vector(31 downto  0);			-- Interrupt Mask Register Read Data


-- DMA Transfer Control State Machine Signal

	type DMA_STATE is  (
			DMA_IDLE,												-- DMA Idle State
			DMA_START,												-- DMA Transfer State State
			DMA_REQON,												-- REQ#/REQ64# Signal Assert Request State
			DMA_PRERD,												-- Memory Pre-Read Start Wait State for PCI WriteTtransaction
			DMA_DTTRNS,												-- PCI Transaction End Wait State
			DMA_RETRY,												-- PCI Retry Response Detect State
			DMA_DISCONNECT,											-- PCI Disconnect Detect State
			DMA_BRSTEND,											-- PCI One Transaction End State
			DMA_END,												-- DMA Transaction End State
			DMA_SDONE												-- PCI Initiator Transaction Error End State
			);

	signal DMA_current	: DMA_STATE;								-- DMA Transfer Current State
	signal DMA_next		: DMA_STATE;								-- DMA Transfer Next State


-- DMA Transfer Control Signal

	signal PCICMD_DT	: std_logic_vector( 3 downto  0);			-- PCI Command for Initiator Access

	signal DMA_PCIADRS	: std_logic_vector(31 downto  2);			-- DMA PCI Address Counter
	signal DMA_MEMADRS	: std_logic_vector(23 downto  2);			-- DMA Memory Address Counter
	signal DMA_PRDADRS	: std_logic_vector(23 downto  2);			-- DMA Memory Pre Read Address Counter

	signal DMA_PRDCNT	: std_logic_vector( 2 downto  0);			-- DMA Memory Pre Read Signal Control Counter
	signal DMA_PREREAD	: std_logic;								-- DMA Memory Pre Read Signal

	signal DMA_DTCUNT	: std_logic_vector(23 downto  2);			-- DMA Data Counter
	signal DMA_BSTCUNT	: std_logic_vector(15 downto  0);			-- DMA Transaction Burst Length Counter
	signal DMA_INTVCUNT	: std_logic_vector(15 downto  0);			-- DMA Transaction Interval Timer Counter

	signal LASTBLK_FLG	: std_logic;								-- DMA Last Transaction Flag
	signal DMACUNT_END	: std_logic;								-- DMA Counter End Flag
	signal CUNTCMP_FLG	: std_logic;								-- DMA/Burst Data Counter Compere Flag

	signal INTVEND_FLG	: std_logic;								-- PCI Transaction Interval End Flag

	signal PCI_REQ	 	: std_logic;								-- Internal REQ# Signal
	signal PCI_REQ64	: std_logic;								-- Internal REQ64# Signal

	signal NEAREND_FLG	: std_logic;								-- PCI Transaction Near End Flag

	signal DMAEND_CNT1	: std_logic;								-- PCI Last 1 Transaction Flag
	signal DMAEND_CNT2	: std_logic;								-- PCI Last 2 Transaction Flag
	signal DMAEND_CNT3	: std_logic;								-- PCI Last 3 Transaction Flag

	signal DMA_READY	: std_logic;								-- PCI Transaction Start Control Signal

	signal DMA_RWAITCNT	: std_logic_vector( 2 downto  0);			-- PCI Read Transaction Start Check Control Signal
	signal DMA_RWAIT	: std_logic;								-- PCI Read Transaction Start Delay Control Signal

	signal DMA_WWAITCNT	: std_logic_vector( 2 downto  0);			-- PCI Write Transaction Start Check Control Signal
	signal DMA_WWAIT0	: std_logic;								-- PCI Write Transaction Start Delay Control Signal
	signal DMA_WWAIT1	: std_logic;								-- PCI Write Transaction Start Delay Control Signal

	signal ASERT_CMPLTE	: std_logic;								-- COMPLETE Signal Assert Signal
	signal HOLD_CMPLTE	: std_logic;								-- COMPLETE Signal Hold Signal

	signal DMA_END1		: std_logic;								-- PCI Last 1 Transaction Signal
	signal DMA_END2		: std_logic;								-- PCI Last 2 Transaction Signal
	signal DMA_END3		: std_logic;								-- PCI Last 3 Transaction Signal

	signal M_DATA_CHK	: std_logic;								-- M_DATA Signal Samplig Signal
	signal M_DATA_FELL	: std_logic;								-- M_DATA Down Edge Detect Signal

	signal PCI_RETRY	: std_logic;								-- PCI Retry Response Flag
	signal PCI_DISCNCT	: std_logic;								-- PCI Disconnect Response Flag
	signal PCI_TGABORT	: std_logic;								-- PCI Target Abort Response Flag

	signal PCI_ENDST	: std_logic_vector( 2 downto 0);			-- PCI End Status									-- V00.01-1

	signal DISCNCT_FLAG	: std_logic;								-- PCI Disconnect Check Flag						-- V00.01-2

-- Internal Memory DMA Access Control Signal

	signal DMA_WRENB	: std_logic;								-- Internal Memory DMA Write Access Enable
	signal DMA_RDENB	: std_logic;								-- Internal Memory DMA Read  Access Enable






--################################
--##    for Debug
--################################


	signal DEBUG_OUTDT	: std_logic_vector( 7 downto 0);

	signal DMASTAT_ON	: std_logic;								-- DMA Start/Stop Control Bit
	signal DMASTAT_CHK	: std_logic;								-- DMA Start/Stop Control Bit

	signal DMASTAT_CNT	: std_logic_vector(31 downto  0);			-- Interrupt Mask Register Read Data

	signal DMAON_TIME	: std_logic_vector(31 downto  0);			-- Interrupt Mask Register Read Data
	signal DMAPCI_TIME	: std_logic_vector(31 downto  0);			-- Interrupt Mask Register Read Data


	signal FRAMEN_CHK	: std_logic_vector( 2 downto  0);			-- Interrupt Mask Register Read Data
	signal FRAME_CUNT	: std_logic_vector(31 downto  0);			-- Interrupt Mask Register Read Data


	signal TIMER_CUNT	: std_logic_vector(31 downto  0);			-- Free Run Counter





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
			case DMAREG_AD(7 downto 2) is
				when "001000" => REG_SEL <= "00000000001";					------ DMA PCI Address Register Select
				when "001001" => REG_SEL <= "00000000010";					------ DMA Local Address Register Select
				when "001010" => REG_SEL <= "00000000100";					------ DMA Counter Register Select
				when "001011" => REG_SEL <= "00000001000";					------ DMA Control Register Select
				when "001100" => REG_SEL <= "00000010000";					------ DMA Interval Register Select
				when "001101" => REG_SEL <= "00000100000";					------ DMA Status Register Select
				when "001110" => REG_SEL <= "00001000000";					------ DMA On Couter Control Register Select
				when "001111" => REG_SEL <= "00010000000";					------ DMA On Counter Register Select
				when "010000" => REG_SEL <= "00100000000";					------ DMA PCI On Counter Register Select
				when "010001" => REG_SEL <= "01000000000";					------ DMA PCI Frame Counter Register Select
				when "010100" => REG_SEL <= "10000000000";					------ Free Run Counter Register Select
				when others   => REG_SEL <= "00000000000";					------ Register No Select
			end case;
		end if;
	end process;



--	process (RST,CLK) begin
--		if (RST='1') then
--			REG_SEL <= (others=>'0');
--		elsif (CLK'event and CLK='1') then
--			case DMAREG_AD(7 downto 2) is
--				when "001000" => REG_SEL <= "000001";						------ DMA PCI Address Register Select
--				when "001001" => REG_SEL <= "000010";						------ DMA Local Address Register Select
--				when "001010" => REG_SEL <= "000100";						------ DMA Counter Register Select
--				when "001011" => REG_SEL <= "001000";						------ DMA Control Register Select
--				when "001100" => REG_SEL <= "010000";						------ DMA Interval Register Select
--				when "001101" => REG_SEL <= "100000";						------ DMA Status Register Select
--				when others   => REG_SEL <= "000000";						------ Register No Select
--			end case;
--		end if;
--	end process;

		 PCIADRS_SEL <= REG_SEL(0);											------ DMA PCI Address Register Select
		 LOCALAD_SEL <= REG_SEL(1);											------ DMA Local Address Register Select
		 DMACUNT_SEL <= REG_SEL(2);											------ DMA Counter Register Select
		 DMACTRL_SEL <= REG_SEL(3);											------ DMA Control Register Select
		 DMAINTV_SEL <= REG_SEL(4);											------ DMA Interval Register Select
		 DMASTAT_SEL <= REG_SEL(5);											------ DMA Status Register Select

--------------------------------------------------------------------------------
-- Register Read Data Select Control Process
--------------------------------------------------------------------------------

	process (RST,CLK) begin
		if (RST='1') then
			DMAREG_DTO <= (others=>'0');
		elsif (CLK'event and CLK='1') then
			case REG_SEL is
				when "00000000001" => DMAREG_DTO <= PCIADRS_RDDT;			------ DMA PCI Address Register Read Data
				when "00000000010" => DMAREG_DTO <= LOCALAD_RDDT;			------ General Register Read Data
				when "00000000100" => DMAREG_DTO <= DMACUNT_RDDT;			------ DMA Counter Register Read Data
				when "00000001000" => DMAREG_DTO <= DMACTRL_RDDT;			------ DMA Control Register Read Data
				when "00000010000" => DMAREG_DTO <= DMAINTV_RDDT;			------ DMA Interval Register Read Data
				when "00000100000" => DMAREG_DTO <= DMASTAT_RDDT;			------ Interrupt Mask Register Read Data
				when "00001000000" => DMAREG_DTO <= DMASTAT_CNT;			------ DMA On Couter Control Register Read Data
				when "00010000000" => DMAREG_DTO <= DMAON_TIME;				------ DMA On Counter Register Read Data
				when "00100000000" => DMAREG_DTO <= DMAPCI_TIME;			------ DMA PCI On Counter Register Read Data
				when "01000000000" => DMAREG_DTO <= FRAME_CUNT;				------ DMA PCI Frame Counter Register Read Data
				when "10000000000" => DMAREG_DTO <= TIMER_CUNT;				------ Free Run Counter
				when others        => DMAREG_DTO <= (others=>'0');			------ No Read Data
			end case;
		end if;
	end process;



--	process (RST,CLK) begin
--		if (RST='1') then
--			DMAREG_DTO <= (others=>'0');
--		elsif (CLK'event and CLK='1') then
--			case REG_SEL is
--				when "000001" => DMAREG_DTO <= PCIADRS_RDDT;				------ DMA PCI Address Register Read Data
--				when "000010" => DMAREG_DTO <= LOCALAD_RDDT;				------ General Register Read Data
--				when "000100" => DMAREG_DTO <= DMACUNT_RDDT;				------ DMA Counter Register Read Data
--				when "001000" => DMAREG_DTO <= DMACTRL_RDDT;				------ DMA Control Register Read Data
--				when "010000" => DMAREG_DTO <= DMAINTV_RDDT;				------ DMA Interval Register Read Data
--				when "100000" => DMAREG_DTO <= DMASTAT_RDDT;				------ Interrupt Mask Register Read Data
--				when others   => DMAREG_DTO <= (others=>'0');				------ No Read Data
--			end case;
--		end if;
--	end process;

--------------------------------------------------------------------------------
-- Register Read Data Signal Timing Control Process
--------------------------------------------------------------------------------

	process (RST,CLK) begin
		if (RST='1') then
			REGRD_CNT <= '0';
		elsif (CLK'event and CLK='1') then
			REGRD_CNT <= DMAREG_RE;											------ Register Read Signal Shift
		end if;
	end process;

--------------------------------------------------------------------------------
-- Register Read Data Enable Signal Control Process
--------------------------------------------------------------------------------

	process (RST,CLK) begin
		if (RST='1') then
			DMAREG_DTOEN <= '0';
		elsif (CLK'event and CLK='1') then
			if (REGRD_CNT='1' and REG_SEL/="00000000") then					------ Register Read ?
				DMAREG_DTOEN <= REGRD_CNT;									------ Register Read Data Available Signal Output
			else
				DMAREG_DTOEN <= '0';
			end if;
		end if;
	end process;



--	process (RST,CLK) begin
--		if (RST='1') then
--			DMAREG_DTOEN <= '0';
--		elsif (CLK'event and CLK='1') then
--			if (REGRD_CNT='1' and REG_SEL/="000000") then					------ Register Read ?
--				DMAREG_DTOEN <= REGRD_CNT;									------ Register Read Data Available Signal Output
--			else
--				DMAREG_DTOEN <= '0';
--			end if;
--		end if;
--	end process;


--***************************************************************
--*
--*  Register Data Control Block
--*
--***************************************************************

--------------------------------------------------------------------------------
-- DMA PCI Address Register Data Control Process
--------------------------------------------------------------------------------

	process (RST,CLK) begin
		if (RST='1') then
			PCIADRS_DT <= (others=>'0');
		elsif (CLK'event and CLK='1') then
			if (PCIADRS_SEL='1' and DMAREG_WE='1') then						------ Register Write Enable ?
				PCIADRS_DT <= DMAREG_DTI(31 downto 2);						------ Register Write Data Set
			end if;
		end if;
	end process;

		PCIADRS_RDDT <= PCIADRS_DT & "00";									------ DMA PCI Address Register Read Data Set

--------------------------------------------------------------------------------
-- DMA Local Address Register Data Control Process
--------------------------------------------------------------------------------

	process (RST,CLK) begin
		if (RST='1') then
			LOCALAD_DT <= (others=>'0');
		elsif (CLK'event and CLK='1') then
			if (LOCALAD_SEL='1' and DMAREG_WE='1') then						------ Register Write Enable ?
				LOCALAD_DT <= DMAREG_DTI(23 downto 2);						------ Register Write Data Set
			end if;
		end if;
	end process;

		LOCALAD_RDDT <= "00000000" & LOCALAD_DT & "00";						------ DMA Local Address Register Read Data Set

--------------------------------------------------------------------------------
-- DMA Counter Register Data Control Process
--------------------------------------------------------------------------------

	process (RST,CLK) begin
		if (RST='1') then
			DMACUNT_DT <= (others=>'0');
		elsif (CLK'event and CLK='1') then
			if (DMACUNT_SEL='1' and DMAREG_WE='1') then						------ Register Write Enable ?
				DMACUNT_DT <= DMAREG_DTI(23 downto 2);						------ Register Write Data Set
			end if;
		end if;
	end process;

		DMACUNT_RDDT <= "00000000" & DMACUNT_DT & "00";						------ DMA Counter Register Read Data Set

--------------------------------------------------------------------------------
--  DMA Control Register Control Process
--------------------------------------------------------------------------------

--------------------------------------------------
-- DMA Start/Stop Control Bit
--------------------------------------------------

	process (RST,CLK) begin
		if (RST='1') then
			DMASTAT_BIT <= '0';
		elsif (CLK'event and CLK='1') then
			if (DMACTRL_SEL='1' and DMAREG_WE='1') then						------ Register Write Enable ?
				DMASTAT_BIT <= DMAREG_DTI(0);								------ DMA Start/Stop Control Bit Set
			elsif (DMA_current=DMA_END) then								------ DMA Transfer End ?
				DMASTAT_BIT <= '0';											------ DMA Start/Stop Control Bit Clear
			end if;
		end if;
	end process;

--------------------------------------------------
-- DMA Data Width Control Bit
--------------------------------------------------

	process (RST,CLK) begin
		if (RST='1') then
			DMA64_BIT <= '0';
		elsif (CLK'event and CLK='1') then
			if (DMACTRL_SEL='1' and DMAREG_WE='1') then						------ Register Write Enable ?
				DMA64_BIT <= DMAREG_DTI(1);									------ DMA Data Width Bit Set
			end if;
		end if;
	end process;

--------------------------------------------------
-- DMA Mode Control Bit
--------------------------------------------------

	process (RST,CLK) begin
		if (RST='1') then
			DMAMODE_BIT <= (others=>'0');
		elsif (CLK'event and CLK='1') then
			if (DMACTRL_SEL='1' and DMAREG_WE='1') then						------ Register Write Enable ?
				DMAMODE_BIT <= DMAREG_DTI(3 downto 2);						------ DMA Mode Bit Set
			end if;
		end if;
	end process;

--------------------------------------------------
-- DMA Direction Control Bit
--------------------------------------------------

	process (RST,CLK) begin
		if (RST='1') then
			DMADIR_BIT <= '0';
		elsif (CLK'event and CLK='1') then
			if (DMACTRL_SEL='1' and DMAREG_WE='1') then						------ Register Write Enable ?
				DMADIR_BIT <= DMAREG_DTI(4);								------ DMA Direction Bit Set
			end if;
		end if;
	end process;

--------------------------------------------------
-- DMA Control Register Read Data Set
--------------------------------------------------

		DMACTRL_RDDT(31 downto  5) <= (others=>'0');						------ DMA Control Register Read Data
		DMACTRL_RDDT( 4 downto  0) <= DMADIR_BIT & DMAMODE_BIT
									& DMA64_BIT  & DMASTAT_BIT;				------ DMA Control Register Read Data Set

--------------------------------------------------------------------------------
-- DMA Interval Register Data Control Process
--------------------------------------------------------------------------------

--------------------------------------------------
-- DMA Length Data Control
--------------------------------------------------

	process (RST,CLK) begin
		if (RST='1') then
			DMALNGTH_DT <= (others=>'0');
		elsif (CLK'event and CLK='1') then
			if (DMAINTV_SEL='1' and DMAREG_WE='1') then						------ Register Write Enable ?
				DMALNGTH_DT <= DMAREG_DTI(31 downto 16);					------ Register Write Data Set
			end if;
		end if;
	end process;

--------------------------------------------------
-- DMA Interval Data Control
--------------------------------------------------

	process (RST,CLK) begin
		if (RST='1') then
			DMAINTV_DT <= (others=>'0');
		elsif (CLK'event and CLK='1') then
			if (DMAINTV_SEL='1' and DMAREG_WE='1') then						------ Register Write Enable ?
				DMAINTV_DT <= DMAREG_DTI(15 downto 0);						------ Register Write Data Set
			end if;
		end if;
	end process;

		DMAINTV_RDDT <= DMALNGTH_DT & DMAINTV_DT;							------ DMA Interval Register Read Data Set

--------------------------------------------------------------------------------
--  DMA Status Register Control Process
--------------------------------------------------------------------------------

--------------------------------------------------
-- PCI Disconnect Counter Control
--------------------------------------------------

	process (RST,CLK) begin
		if (RST='1') then
			DISCNCT_CUNT <= (others =>'0');
		elsif (CLK'event and CLK='1') then
			if (DMA_current=DMA_IDLE and DMASTAT_BIT='1') then				------ DMA Transfer Start ?
				DISCNCT_CUNT <= (others =>'0');								------ Counter Initialize
			elsif (DMA_current=DMA_DISCONNECT) then							------ PCI Disconnect Response ?
				if (DISCNCT_CUNT/="1111111111111111") then					------ Counter Not Over Flow ?
					DISCNCT_CUNT <= DISCNCT_CUNT+1;							------ Counter Increment
				end if;
			end if;
		end if;
	end process;

--------------------------------------------------
-- PCI Retry Counter Control
--------------------------------------------------

	process (RST,CLK) begin
		if (RST='1') then
			RETRY_CUNT <= (others =>'0');
		elsif (CLK'event and CLK='1') then
			if (DMA_current=DMA_IDLE and DMASTAT_BIT='1') then				------ DMA Transfer Start ?
				RETRY_CUNT <= (others =>'0');								------ Counter Initialize
			elsif (DMA_current=DMA_RETRY) then								------ PCI Retry Response ?
				if (RETRY_CUNT/="1111111111111111") then					------ Counter Not Over Flow ?
					RETRY_CUNT <= RETRY_CUNT+1;								------ Counter Increment
				end if;
			end if;
		end if;
	end process;

		DMASTAT_RDDT <= DISCNCT_CUNT & RETRY_CUNT;							------ DMA Status Register Read Data Set


--***************************************************************
--*
--*  DMA Access Control Block
--*
--***************************************************************

--------------------------------------------------------------------------------
-- DMA Access State change
--------------------------------------------------------------------------------

	process (RST,CLK) begin
		if (RST='1') then
			DMA_current <= DMA_IDLE;
		elsif (CLK'event and CLK='1') then
			DMA_current <= DMA_next;										------ DMA Access Next State Set
		end if;
	end process;

--------------------------------------------------------------------------------
-- DMA Access Next State Calculate Process
--------------------------------------------------------------------------------

	process (DMA_current,DMASTAT_BIT,DMADIR_BIT,M_ADDR_N,M_DATA_FELL,
				PCI_RETRY,PCI_DISCNCT,PCI_TGABORT,DMACUNT_END,INTVEND_FLG) begin

		case DMA_current is
			when DMA_IDLE =>												------ DMA_IDLE State
				if (DMASTAT_BIT='1') then									------ DMA Start Set ?
					DMA_next <= DMA_START;									------ Goto DMA_START State
				else
					DMA_next <= DMA_IDLE;									------ Stay DMA_IDLE State
				end if;

			when DMA_START =>												------ DMA_START State
				if (DMASTAT_BIT='0') then									------ DMA Disabel ?
					DMA_next <= DMA_END;									------ Goto DMA_END State
				else
					DMA_next <= DMA_REQON;									------ Goto DMA_REQON State
				end if;

			when DMA_REQON =>												------ DMA_REQON State
				if (DMASTAT_BIT='0') then									------ DMA Disabel ?
					DMA_next <= DMA_END;									------ Goto DMA_END State
				elsif (DMADIR_BIT='0') then									------ DMA Write ?
					DMA_next <= DMA_PRERD;									------ Goto DMA_PRERD State
				else
					DMA_next <= DMA_DTTRNS;									------ Goto DMA_DTTRNS State
				end if;

			when DMA_PRERD =>												------ DMA_PRERD State
				if (DMASTAT_BIT='0') then									------ DMA Disabel ?
					DMA_next <= DMA_END;									------ Goto DMA_END State
				elsif (M_ADDR_N='0') then									------ PCI Transaction Start ?
					DMA_next <= DMA_DTTRNS;									------ Goto DMA_DTTRNS State
				else
					DMA_next <= DMA_PRERD;									------ Stay DMA_PRERD State
				end if;

			when DMA_DTTRNS =>												------ DMA_DTTRNS State
				if (DMASTAT_BIT='0') then									------ DMA Disabel ?
					DMA_next <= DMA_END;									------ Goto DMA_END State
				elsif (M_DATA_FELL='1') then								------ PCI Transaction End ?
					if (PCI_RETRY='1' and DISCNCT_FLAG='0') then			------ PCI Retry Response On ?
						DMA_next <= DMA_RETRY;								------ Goto DMA_RETRY State
					elsif (PCI_RETRY='1' and DISCNCT_FLAG='1') then			------ PCI Disconnect without Data Response On ?
						DMA_next <= DMA_DISCONNECT;							------ Goto DMA_DISCONNECT State
					elsif (PCI_DISCNCT='1') then							------ PCI Disconnect with Data Response On ?
						DMA_next <= DMA_DISCONNECT;							------ Goto DMA_DISCONNECT State
					elsif (PCI_TGABORT='1') then							------ PCI Target Abort Response On ?
						DMA_next <= DMA_SDONE;								------ Goto DMA_SDONE State
					else													------ Normal Transaction End
						DMA_next <= DMA_BRSTEND;							------ Goto DMA_BRSTEND State
					end if;
				else
					DMA_next <= DMA_DTTRNS;									------ Stay DMA_DTTRNS State
				end if;

			when DMA_RETRY =>												------ DMA_RETRY State
				if (DMASTAT_BIT='0') then									------ DMA Disabel ?
					DMA_next <= DMA_END;									------ Goto DMA_END State
				else
					DMA_next <= DMA_REQON;									------ Goto DMA_REQON State
				end if;

			when DMA_DISCONNECT =>											------ DMA_DISCONNECT State
				if (DMASTAT_BIT='0') then									------ DMA Disabel ?
					DMA_next <= DMA_END;									------ Goto DMA_END State
				else
					DMA_next <= DMA_BRSTEND;								------ Goto DMA_BRSTEND State
				end if;

			when DMA_BRSTEND =>												------ DMA_BRSTEND State
				if (DMASTAT_BIT='0') then									------ DMA Disabel ?
					DMA_next <= DMA_END;									------ Goto DMA_END State
				elsif (DMACUNT_END='1') then								------ DMA Transfer End ?
					DMA_next <= DMA_END;									------ Goto DMA_END State
				elsif (INTVEND_FLG='1') then								------ Transaction Interval Time End ?
					DMA_next <= DMA_START;									------ Goto DMA_START State
				else
					DMA_next <= DMA_BRSTEND;								------ Stay DMA_BRSTEND State
				end if;

			when DMA_END =>													------ DMA_END State
					DMA_next <= DMA_IDLE;									------ Goto GMCLR_IDLE State

			when DMA_SDONE =>												------ DMA_SDONE State
					DMA_next <= DMA_SDONE;									------ Goto DMA_SDONE State (Loop)

			when others =>
					DMA_next <= DMA_IDLE;									------ Goto GMCLR_IDLE State

		end case;
	end process;


--------------------------------------------------------------------------------
--  DMA Transfer PCI Address Counter Control Process
--------------------------------------------------------------------------------

	process (RST,CLK) begin
		if (RST='1') then
			DMA_PCIADRS <= (others=>'0');
		elsif (CLK'event and CLK='1') then
			if (DMA_current=DMA_IDLE and DMASTAT_BIT='1') then				------ DMA Transfer Start ?
				DMA_PCIADRS <= PCIADRS_DT;									------ PCI Address Register Data Set
			elsif (M_DATA_VLD='1') then										------ PCI Data Transfer ?
				if (DMA64_BIT='1' and M_FAIL64='0') then					------ 64 bit Data Transfer ?
					DMA_PCIADRS <= DMA_PCIADRS+2;							------ PCI Address Increment +2
				else
					DMA_PCIADRS <= DMA_PCIADRS+1;							------ PCI Address Increment +1
				end if;
			end if;
		end if;
	end process;

--------------------------------------------------------------------------------
--  DMA Transfer Memory Address Counter Control Process
--------------------------------------------------------------------------------

	process (RST,CLK) begin
		if (RST='1') then
			DMA_MEMADRS <= (others=>'0');
		elsif (CLK'event and CLK='1') then
			if (DMA_current=DMA_IDLE and DMASTAT_BIT='1') then				------ DMA Transfer Start ?
				DMA_MEMADRS <= LOCALAD_DT;									------ Memory Address Register Data Set
			elsif (M_DATA_VLD='1') then										------ PCI Data Transfer ?
				if (DMA64_BIT='1' and M_FAIL64='0') then					------ 64 bit Data Transfer ?
					DMA_MEMADRS <= DMA_MEMADRS+2;							------ Memory Address Increment +2
				else
					DMA_MEMADRS <= DMA_MEMADRS+1;							------ Memory Address Increment +1
				end if;
			end if;
		end if;
	end process;

--------------------------------------------------------------------------------
--  DMA Transfer Data Pre-Read Memory Address Counter Control Process
--------------------------------------------------------------------------------

	process (RST,CLK) begin
		if (RST='1') then
			DMA_PRDADRS <= (others=>'0');
		elsif (CLK'event and CLK='1') then
			if (DMA_current=DMA_IDLE and DMASTAT_BIT='1') then				------ DMA Transfer Start ?
				DMA_PRDADRS <= LOCALAD_DT;									------ Memory Address Register Data Set
			elsif (DMA_current=DMA_START) then								------ PCI Transaction Start ?
				DMA_PRDADRS <= DMA_MEMADRS;									------ Memory Address Register Data Set
			elsif (M_SRC_EN='1' or DMA_PREREAD='1') then					------ PCI Data Transfer or Memory Pre-Read ?
				if (DMA64_BIT='1' and M_FAIL64='0') then					------ 64 bit Data Transfer ?
					DMA_PRDADRS <= DMA_PRDADRS+2;							------ Memory Address Increment +2
				else
					DMA_PRDADRS <= DMA_PRDADRS+1;							------ Memory Address Increment +1
				end if;
			end if;
		end if;
	end process;

--------------------------------------------------------------------------------
--  DMA Transfer Data Pre-Read Signal Control Process
--------------------------------------------------------------------------------

	process (RST,CLK) begin
		if (RST='1') then
			DMA_PRDCNT <= "100";
		elsif (CLK'event and CLK='1') then
			if (DMA_current=DMA_PRERD and M_ADDR_N='0') then				------ PCI Write Transaction Start ?
				DMA_PRDCNT <= "000";										------ Pre Read Counter Start
			elsif (DMA_PRDCNT(2)='0') then									------ Before Counter Count up ?
				DMA_PRDCNT <= DMA_PRDCNT+1;									------ Counter Increment
			end if;
		end if;
	end process;

		DMA_PREREAD <= (not DMA_PRDCNT(2)) or DMA_PRDCNT(1) or DMA_PRDCNT(0);	-- Memory Pre-Read Signal Set

--------------------------------------------------------------------------------
--  DMA Transfer Data Counter Control Process
--------------------------------------------------------------------------------

	process (RST,CLK) begin
		if (RST='1') then
			DMA_DTCUNT <= (others=>'0');
		elsif (CLK'event and CLK='1') then
			if (DMA_current=DMA_IDLE and DMASTAT_BIT='1') then				------ DMA Transfer Start ?
				DMA_DTCUNT <= DMACUNT_DT;									------ DMA Transfer Data Counter Register Data Set
			elsif (M_DATA_VLD='1') then										------ PCI Data Transaction Valid ?
				if (DMA64_BIT='1' and M_FAIL64='0') then					------ 64 bit Data Transfer ?
					DMA_DTCUNT <= DMA_DTCUNT-2;								------ Counter Decrement -2
				else
					DMA_DTCUNT <= DMA_DTCUNT-1;								------ Counter Decrement -1
				end if;
			end if;
		end if;
	end process;

--------------------------------------------------------------------------------
--  DMA Transfer Last Data Block Flag Control Process
--------------------------------------------------------------------------------

	process (RST,CLK) begin
		if (RST='1') then
			LASTBLK_FLG <= '0';
		elsif (CLK'event and CLK='1') then
			if (DMA_DTCUNT(23 downto 18)="000000") then						------ Counter High Block = 0 ?
				LASTBLK_FLG <= '1';											------ Last Data Block Flag Set
			else
				LASTBLK_FLG <= '0';											------ Last Data Block Flag Clear
			end if;
		end if;
	end process;

--------------------------------------------------------------------------------
--  DMA Transfer End Flag Control Process
--------------------------------------------------------------------------------

	process (RST,CLK) begin
		if (RST='1') then
			DMACUNT_END <= '0';
		elsif (CLK'event and CLK='1') then
			if (LASTBLK_FLG='1'
					and DMA_DTCUNT(17 downto 2)="0000000000000000") then	------ Counter High Block = 0 & Counter = 0 ?
				DMACUNT_END <= '1';											------ Last Data Block Flag Set
			else
				DMACUNT_END <= '0';											------ Last Data Block Flag Clear
			end if;
		end if;
	end process;

--------------------------------------------------------------------------------
--  DMA Data Counter/Burst Data Counter Compere Flag Control Process
--------------------------------------------------------------------------------

	process (RST,CLK) begin
		if (RST='1') then
			CUNTCMP_FLG <= '0';
		elsif (CLK'event and CLK='1') then
			if ((DMA64_BIT='1' and (DMALNGTH_DT > DMA_DTCUNT(18 downto 3)))
				or (DMA64_BIT='0' and (DMALNGTH_DT > DMA_DTCUNT(17 downto 2)))
							or DMALNGTH_DT="0000000000000000") then			------ DMA Length > DMA Counter Low Block ?
				CUNTCMP_FLG <= '1';											------ Counter Compere Flag Set
			else
				CUNTCMP_FLG <= '0';											------ Counter Compere Flag Clear
			end if;
		end if;
	end process;

--------------------------------------------------------------------------------
--  DMA Transfer PCI Transaction Data Counter Control Process
--------------------------------------------------------------------------------

	process (RST,CLK) begin
		if (RST='1') then
			DMA_BSTCUNT <= (others=>'0');
		elsif (CLK'event and CLK='1') then
			if (DMA_current=DMA_REQON) then									------ PCI Transfer Start ?
				if (LASTBLK_FLG='1' and CUNTCMP_FLG='1') then				------ Last Block Tranfer ?
					if (DMA64_BIT='1') then									------ 64 bit Transfer ?
						DMA_BSTCUNT <= DMA_DTCUNT(18 downto 3);				------ 64 bit Data Transfer Count Set
					else
						DMA_BSTCUNT <= DMA_DTCUNT(17 downto 2);				------ 32 bit Data Transfer Count Set
					end if;
				else
						DMA_BSTCUNT <= DMALNGTH_DT;							------ DMA Length Register Data Set
				end if;
			elsif (DMA_current=DMA_PRERD and M_ADDR_N='0') then				------ PCI Write Transaction Start ?
				if (DMA_BSTCUNT/="0000000000000000") then					------ Counter Not Zero ?
					DMA_BSTCUNT <= DMA_BSTCUNT-1;							------ Counter Decrement -1
				end if;
			elsif (M_DATA_VLD='1') then										------ PCI Data Transaction Valid ?
				if (DMA_BSTCUNT/="0000000000000000") then					------ Counter Not Zero ?
					DMA_BSTCUNT <= DMA_BSTCUNT-1;							------ Counter Decrement -1
				end if;
			end if;
		end if;
	end process;

--------------------------------------------------------------------------------
--  DMA Transfer PCI Transaction Interval Counter Control Process
--------------------------------------------------------------------------------

	process (RST,CLK) begin
		if (RST='1') then
			DMA_INTVCUNT <= (others=>'0');
		elsif (CLK'event and CLK='1') then
			if (DMA_current=DMA_REQON) then									------ PCI Transfer Start ?
				DMA_INTVCUNT <= DMAINTV_DT(15 downto 0);					------ PCI Interval Counter Register Data Set
			elsif (DMA_current=DMA_BRSTEND) then							------ PCI Transaction End ?
				if (DMA_INTVCUNT/="0000000000000000") then					------ Counter Not Zero ?
					DMA_INTVCUNT <= DMA_INTVCUNT-1;							------ Counter Decrement -1
				end if;
			end if;
		end if;
	end process;

--------------------------------------------------------------------------------
--  DMA Transfer PCI Transaction Interval End Flag Control Process
--------------------------------------------------------------------------------

	process (RST,CLK) begin
		if (RST='1') then
			INTVEND_FLG <= '0';
		elsif (CLK'event and CLK='1') then
			if (DMA_INTVCUNT="0000000000000000") then						------ Counter = 0 ?
				INTVEND_FLG <= '1';											------ Interval End Flag Set
			else
				INTVEND_FLG <= '0';											------ Interval End Flag Clear
			end if;
		end if;
	end process;

--------------------------------------------------------------------------------
--  DMA Transfer End Interrupt Signal Output Control Process
--------------------------------------------------------------------------------

	process (RST,CLK) begin
		if (RST='1') then
			DMAEND_INT <= '0';
		elsif (CLK'event and CLK='1') then
			if (DMACUNT_END='1' and DMA_current=DMA_END) then				------ All Data DMA Transfer End ?
				DMAEND_INT <= '1';									  		------ DMA End Interrupt On Assert
			else
				DMAEND_INT <= '0';									  		------ DMA End Interrupt On Negate
			end if;
		end if;
	end process;


--***************************************************************
--*
--*  PCI Core Interface Control Block
--*
--***************************************************************

--------------------------------------------------------------------------------
--  PCI Bus Request Start Signal Control Process
--------------------------------------------------------------------------------

	process (RST,CLK) begin
		if (RST='1') then
			PCI_REQ   <= '0';
			PCI_REQ64 <= '0';
		elsif (CLK'event and CLK='1') then
			if (DMA_current=DMA_REQON) then									------ PCI Transaction Start ?
				if (DMA64_BIT='1') then										------ 64 bit Transfer ?
					PCI_REQ   <= '0';										------ PCI 32 bit Transfer Start Clear
					PCI_REQ64 <= '1';										------ PCI 64 bit Transfer Start Set
				else
					PCI_REQ   <= '1';										------ PCI 32 bit Transfer Start Set
					PCI_REQ64 <= '0';										------ PCI 64 bit Transfer Start Clear
				end if;
			else
				PCI_REQ   <= '0';
				PCI_REQ64 <= '0';
			end if;
		end if;
	end process;

		REQUEST   <= PCI_REQ;
		REQUEST64 <= PCI_REQ64;

--------------------------------------------------------------------------------
--  PCI Command for Initiator Aceess Control Process
--------------------------------------------------------------------------------

	process (RST,CLK) begin
		if (RST='1') then
			PCICMD_DT <= (others=>'0');
		elsif (CLK'event and CLK='1') then
			if (DMADIR_BIT='1') then										------ Initiator Data Read ?
				case DMAMODE_BIT is
					when "01"   => PCICMD_DT <= c_MEMRD;					------ Memory Read
					when "10"   => PCICMD_DT <= c_MEMRD_L;					------ Memory Read Line
					when "11"   => PCICMD_DT <= c_MEMRD_M;					------ Memory Read Multipul
					when others =>
				end case;
			else															------ Initiator Data Write ?
				case DMAMODE_BIT is
					when "01"   => PCICMD_DT <= c_MEMWRT;					------ Memory Write
					when "11"   => PCICMD_DT <= c_MEMWRT_IV;				------ Memory Write Invalidate
					when others =>
				end case;
			end if;
		end if;
	end process;

--------------------------------------------------------------------------------
--  DMA PCI Address/Data Control Process
--------------------------------------------------------------------------------

	process (M_ADDR_N,M_DATA,DMADIR_BIT,DMA_PCIADRS,
							DMA64_BIT,M_FAIL64,FIFO_RDDT) begin
		if (M_ADDR_N='0') then												------ PCI Address State ?
			ADIO(63 downto 32) <= (others=>'1');							------ PCI Access High Address Disable
			ADIO(31 downto  0) <= DMA_PCIADRS & "00";						------ PCI Access Low Address Set
		elsif (M_DATA='1' and DMADIR_BIT='0') then							------ PCI Data State & Data Write ?
			if (DMA64_BIT='1' and M_FAIL64='0') then						------ 64 bit Data Transfer ?
				ADIO <= FIFO_RDDT;											------ PCI 64 bit Write Data Set
			else
				ADIO(63 downto 32) <= (others=>'1');						------ PCI Access High Word Data Disable
				ADIO(31 downto  0) <= FIFO_RDDT(31 downto 0);				------ PCI Access Low Write Data Set
			end if;
		else
			ADIO  <= (others=>'Z');
		end if;
	end process;

--------------------------------------------------------------------------------
--  DMA PCI CBE Signa Control Process
--------------------------------------------------------------------------------

	process (M_ADDR_N,M_DATA,PCICMD_DT) begin
		if (M_ADDR_N='0') then												------ PCI Address State ?
			M_CBE <= "1111" & PCICMD_DT;									------ PCI Command Set
		elsif (M_DATA='1') then												------ PCI Data State ?
			M_CBE <= (others=>'0');											------ PCI Byte Enable Set
		else
			M_CBE <= (others=>'1');
		end if;
	end process;

--------------------------------------------------------------------------------
--  PCI DMA Transfer Direction Signal Control Process
--------------------------------------------------------------------------------

	process (RST,CLK) begin
		if (RST='1') then
			M_WRDN <= '0';
		elsif (CLK'event and CLK='1') then
			M_WRDN <= (not DMADIR_BIT);										------ DMA Direction Bit Set
		end if;
	end process;

--------------------------------------------------------------------------------
--  PCI Core M_READY Signal Control Process
--------------------------------------------------------------------------------

	process (RST,CLK) begin
		if (RST='1') then
			DMA_READY <= '0';
		elsif (CLK'event and CLK='1') then
			if (DMASTAT_BIT='1' and DMADIR_BIT='1') then					------ PCI Read Transaction ?
				DMA_READY <= '1';											------ DMA_READY Signal Set
			else
				DMA_READY <= '0';											------ DMA_READY Signal Clear
			end if;
		end if;
	end process;

--------------------------------------------------------------------------------
--  PCI Core M_READY Signal Output Control Process
--------------------------------------------------------------------------------

		M_READY <= (DMA_READY or FIFO_RDTEN) and DMASTAT_BIT;				------ M_READY Signal Output

--------------------------------------------------------------------------------
--  PCI Read Transaction Start Check Wait Signal Control Process
--------------------------------------------------------------------------------

	process (RST,CLK) begin
		if (RST='1') then
			DMA_RWAITCNT <= (others=>'0');
		elsif (CLK'event and CLK='1') then
			if (M_ADDR_N='0') then											------ PCI Transaction Start ?
				DMA_RWAITCNT <= (others=>'0');
			elsif (DMADIR_BIT='1') then										------ PCI Read Transaction ?
				DMA_RWAITCNT <= DMA_RWAITCNT(1 downto 0) & '1';				------ DMA_RWAITCNT Signal Shift
			end if;
		end if;
	end process;

		DMA_RWAIT <= DMA_RWAITCNT(1);

--------------------------------------------------------------------------------
--  PCI Write Transaction Start Check Wait Signal Control Process
--------------------------------------------------------------------------------

	process (RST,CLK) begin
		if (RST='1') then
			DMA_WWAITCNT <= (others=>'0');
		elsif (CLK'event and CLK='1') then
			if (M_ADDR_N='0') then											------ PCI Transaction Start ?
				DMA_WWAITCNT <= (others=>'0');
			elsif (DMADIR_BIT='0') then										------ PCI Write Transaction ?
				DMA_WWAITCNT <= DMA_WWAITCNT(1 downto 0) & FIFO_RDTEN;		------ FIFO_RDTEN Signal Shift
			end if;
		end if;
	end process;

		DMA_WWAIT0 <= DMA_WWAITCNT(0);
		DMA_WWAIT1 <= DMA_WWAITCNT(1);

--------------------------------------------------------------------------------
--  PCI Bus Data Transaction End Check Signal Control Process
--------------------------------------------------------------------------------

	process (RST,CLK) begin
		if (RST='1') then
			M_DATA_CHK <= '0';
		elsif (CLK'event and CLK='1') then
			M_DATA_CHK <= M_DATA;											------ MDATA Signal Sampling
		end if;
	end process;

		M_DATA_FELL <= (not M_DATA) and M_DATA_CHK;							------ PCI Data Transaction End Signal

--------------------------------------------------------------------------------
--  PCI Transaction Near End Flag Control Process
--------------------------------------------------------------------------------

	process (RST,CLK) begin
		if (RST='1') then
			NEAREND_FLG <= '0';
		elsif (CLK'event and CLK='1') then
			if (DMA_BSTCUNT(15 downto 3)="0000000000000") then				------ Counter High Block = 0 ?
				NEAREND_FLG <= '1';											------ Transaction Near End Set
			else
				NEAREND_FLG <= '0';											------ Transaction Near End Clear
			end if;
		end if;
	end process;

--------------------------------------------------------------------------------
--  PCI Bus Data Transaction Last 1 Word Signal Control Process
--------------------------------------------------------------------------------

	process (DMASTAT_BIT,NEAREND_FLG,DMA_BSTCUNT) begin
		if (DMASTAT_BIT='1' and NEAREND_FLG='1'
								and DMA_BSTCUNT(2 downto 0)="001") then		------ PCI Last 1 Transaction ?
				DMAEND_CNT1 <= '1';											------ Last 1 Word Signal Set
		else
				DMAEND_CNT1 <= '0';											------ Last 1 Word Signal Clear
		end if;
	end process;

--------------------------------------------------------------------------------
--  PCI Bus Data Transaction Last 2 Word Signal Control Process
--------------------------------------------------------------------------------

	process (DMASTAT_BIT,NEAREND_FLG,DMA_BSTCUNT) begin
		if (DMASTAT_BIT='1' and NEAREND_FLG='1'
								and DMA_BSTCUNT(2 downto 0)="010") then		------ PCI Last 2 Transaction ?
				DMAEND_CNT2 <= '1';											------ Last 2 Word Signal Set
		else
				DMAEND_CNT2 <= '0';											------ Last 2 Word Signal Clear
		end if;
	end process;

--------------------------------------------------------------------------------
--  PCI Bus Data Transaction Last 3 Word Signal Control Process
--------------------------------------------------------------------------------

	process (DMASTAT_BIT,NEAREND_FLG,DMA_BSTCUNT) begin
		if (DMASTAT_BIT='1' and NEAREND_FLG='1'
								and DMA_BSTCUNT(2 downto 0)="011") then		------ PCI Last 3 Transaction ?
				DMAEND_CNT3 <= '1';											------ Last 3 Word Signal Set
		else
				DMAEND_CNT3 <= '0';											------ Last 3 Word Signal Clear
		end if;
	end process;

--------------------------------------------------------------------------------
--  PCI Bus Data Transaction End Signal Control Process
--------------------------------------------------------------------------------

		DMA_END1 <= DMAEND_CNT1 and (PCI_REQ or PCI_REQ64 or DMA_WWAIT0);		-- DMA Last 1 Transaction Signal
		DMA_END2 <= DMAEND_CNT2 and M_DATA and (DMA_RWAIT or DMA_WWAIT1);		-- DMA Last 2 Transaction Signal
		DMA_END3 <= DMAEND_CNT3	and M_DATA_VLD and (DMADIR_BIT or CFG(117));	-- DMA Last 3 Transaction Signal

--------------------------------------------------------------------------------
--  PCI Core COMPLETE Signal Control Process
--------------------------------------------------------------------------------

		ASERT_CMPLTE <= DMA_END1 or DMA_END2 or DMA_END3;					------ COMPLETE Signal Assert Signal

	process (RST,CLK) begin
		if (RST='1') then
			HOLD_CMPLTE <= '0';
		elsif (CLK'event and CLK='1') then
			if (M_DATA_FELL='1') then										------ PCI Data Phase End ?
				HOLD_CMPLTE <= '0';											------ COMPLETE Signal Hold Clear
			elsif (ASERT_CMPLTE='1') then									------ COMPLETE Signal Assert ?
				HOLD_CMPLTE <= '1';											------ COMPLETE Signal Hold Set
			end if;
		end if;
	end process;

--------------------------------------------------------------------------------
--  PCI Core COMPLETE Signal Output Control Process
--------------------------------------------------------------------------------

		COMPLETE <= ASERT_CMPLTE or HOLD_CMPLTE or (not DMASTAT_BIT);		------ COMPLETE Signal Output

--------------------------------------------------------------------------------
--  PCI Transaction End Status Signal Control Process
--
--	V00.01: 1. End Status Signal Generatre PCI_ENDST Condition Added
--------------------------------------------------------------------------------

	process (RST,CLK) begin
		if (RST='1') then
			PCI_RETRY   <= '0';
			PCI_DISCNCT <= '0';
			PCI_TGABORT <= '0';
		elsif (CLK'event and CLK='1') then
			if (DMASTAT_BIT='1') then										------ DMA Start ?
				if (M_ADDR_N='0') then										------ PCI Transaction Start ?
					PCI_RETRY   <= '0';										------ Status Clear
					PCI_DISCNCT <= '0';
					PCI_TGABORT <= '0';
				elsif (M_DATA='1' and PCI_ENDST="000") then					------ PCI Data Phase						-- V00.01-1
--				elsif (M_DATA='1') then										------ PCI Data Phase
					PCI_RETRY   <= CSR(36);									------ Status Latch
					PCI_DISCNCT <= CSR(37);
					PCI_TGABORT <= CSR(38) or CSR(39);
				end if;
			else
					PCI_RETRY   <= '0';										------ Status Clear
					PCI_DISCNCT <= '0';
					PCI_TGABORT <= '0';
			end if;
		end if;
	end process;

		PCI_ENDST <= PCI_RETRY & PCI_DISCNCT & PCI_TGABORT;																-- V00.01-1


--------------------------------------------------------------------------------
--  PCI Disconnect/Retry Transaction Check Flag Control Process
--
--	V00.01: 2. This Process Added
--------------------------------------------------------------------------------

	process (RST,CLK) begin																								-- V00.01-2
		if (RST='1') then
			DISCNCT_FLAG   <= '0';
		elsif (CLK'event and CLK='1') then
			if (M_DATA='1') then											------ PCI Data Phase
				if (TRDYQ_N='0') then										------ Data Transaction Start ?
					DISCNCT_FLAG <= '1';									------ Flag Set
				end if;
			else
					DISCNCT_FLAG <= '0';									------ Flag Clear
			end if;
		end if;
	end process;


--***************************************************************
--*
--*  Internal Memory DMA Access Control Signal Generate Block
--*
--***************************************************************

--------------------------------------------------------------------------------
-- BAR1(Internal Memory) R/W Select Signal Control Process
--------------------------------------------------------------------------------

	process (RST,CLK) begin
		if (RST='1') then
			DMA_WRENB <= '0';
			DMA_RDENB <= '0';
		elsif (CLK'event and CLK='1') then
			if (M_ADDR_N='0') then											------ Initiator PCI Access Start ?
				DMA_WRENB <= DMADIR_BIT;									------ R/W Status Set
				DMA_RDENB <= (not DMADIR_BIT);
			elsif (M_DATA_FELL='1') then									------ Transaction End ?
				DMA_WRENB <= '0';											------ Select Signal Clear
				DMA_RDENB <= '0';
			end if;
		end if;
	end process;

		DMATRNS_ENB <= DMA_WRENB or DMA_RDENB;								------ DMA Access Enable Signal Output

--------------------------------------------------------------------------------
-- Internal Memory DMA Access Address Output Control Process
--------------------------------------------------------------------------------

	process (DMA_WRENB,DMA_MEMADRS,DMA_PRDADRS) begin
		if (DMA_WRENB='1') then												------ Memory Write ?
			DMA_ADRS <= "00000000" & DMA_MEMADRS & "00";					------ Write Address Output
		else
			DMA_ADRS <= "00000000" & DMA_PRDADRS & "00";					------ Read  Address Output
		end if;
	end process;

--------------------------------------------------------------------------------
-- Internal Memory DMA Write Signal Control Process
--------------------------------------------------------------------------------

	process (DMA_WRENB,M_DATA_VLD,DMA64_BIT,M_FAIL64,DMA_MEMADRS) begin
		if (DMA_WRENB='1' and M_DATA_VLD='1') then							------ BAR1 Target Data Write Available ?
			if (DMA64_BIT='1' and M_FAIL64='0') then						------ 64 bit Data Transfer ?
				DMA_WRT <= "11111111";										------ 64 bit Write Signal Set
			else
				if (DMA_MEMADRS(2)='1') then								------ 32 bit Odd Address Write ?
					DMA_WRT <= "11110000";									------ High Word Write Signal Set
				else
					DMA_WRT <= "00001111";									------ Low  Word Write Signal Set
				end if;
			end if;
		else
				DMA_WRT <= (others => '0');									------ DMA_WR Signal Negate
		end if;
	end process;

--------------------------------------------------------------------------------
-- Internal Memory DMA Write Data Control Process
--------------------------------------------------------------------------------

	process (DMA_WRENB,M_DATA_VLD,DMA64_BIT,M_FAIL64,DMA_MEMADRS,ADIO) begin
		if (DMA_WRENB='1' and M_DATA_VLD='1') then							------ BAR1 Target Data Write Available ?
			if (DMA64_BIT='1' and M_FAIL64='0') then						------ 64 bit Data Transfer ?
				DMA_WRDT <= ADIO;											------ 64 bit Write Data Output
			else
				if (DMA_MEMADRS(2)='1') then								------ 32 bit Odd Address Write ?
					DMA_WRDT(31 downto  0) <= (others => '0');				------ Low  Word Write Data Clear
					DMA_WRDT(63 downto 32) <= ADIO(31 downto 0);			------ High Word Write Data Set
				else
					DMA_WRDT(31 downto  0) <= ADIO(31 downto 0);			------ Low  Word Write Data Set
					DMA_WRDT(63 downto 32) <= (others => '0');				------ High Word Write Data Clear
				end if;
			end if;
		else
				DMA_WRDT <= (others => '0');								------ Write Data Clear
		end if;
	end process;

--------------------------------------------------------------------------------
-- Internal Memory DMA Read Signal Control Process
--------------------------------------------------------------------------------

		DMA_READ <= (DMA_PREREAD or M_SRC_EN) and DMA_RDENB;				------ Data Read Signal Set



--***************************************************************
--*
--*  Unused PCI Core Signal Control Block
--*
--***************************************************************

		REQUESTHOLD 	<= '0'; --: out   std_logic;

		CFG_SELF		<= '0'; --: out   std_logic;




--***************************************************************
--*
--*  Debug Signal Output Control Block
--*
--***************************************************************


--	process (DMA_current) begin
--		case DMA_current is
--			when DMA_IDLE		 => DEBUG_OUTDT(7 downto 4) <= "0001";
--			when DMA_START		 => DEBUG_OUTDT(7 downto 4) <= "0010";
--			when DMA_REQON		 => DEBUG_OUTDT(7 downto 4) <= "0011";
--			when DMA_PRERD		 => DEBUG_OUTDT(7 downto 4) <= "0100";
--			when DMA_DTTRNS		 => DEBUG_OUTDT(7 downto 4) <= "0101";
--			when DMA_RETRY		 => DEBUG_OUTDT(7 downto 4) <= "0110";
--			when DMA_DISCONNECT	 => DEBUG_OUTDT(7 downto 4) <= "0111";
--			when DMA_BRSTEND	 => DEBUG_OUTDT(7 downto 4) <= "1000";
--			when DMA_END		 => DEBUG_OUTDT(7 downto 4) <= "1001";
--			when DMA_SDONE		 => DEBUG_OUTDT(7 downto 4) <= "1010";
--			when others          => DEBUG_OUTDT(7 downto 4) <= "0000";
--		end case;
--	end process;


		DEBUG_OUT(0) <= '0';
		DEBUG_OUT(1) <= '0';
		DEBUG_OUT(2) <= '0';
		DEBUG_OUT(3) <= '0';
		DEBUG_OUT(4) <= PCI_RETRY;
		DEBUG_OUT(5) <= PCI_DISCNCT;
		DEBUG_OUT(6) <= PCI_TGABORT;
		DEBUG_OUT(7) <= CLK;


--					PCI_RETRY   <= '0';										------ Status Clear
--					PCI_DISCNCT <= '0';
--					PCI_TGABORT <= '0';



--	process (RST,CLK) begin
--		if (RST='1') then
--			DEBUG_OUT(0) <= '0';
--		elsif (CLK'event and CLK='1') then
--			if (PCI_REQ='1' or PCI_REQ64='1') then
--				DEBUG_OUT(0) <= DR_BUS;
--			end if;
--		end if;
--	end process;

	process (RST,CLK) begin
		if (RST='1') then
			DEBUG_OUTDT(7) <= '0';
		elsif (CLK'event and CLK='1') then
			if (DMASTAT_CHK='1') then						------ Register Write Enable ?
				DEBUG_OUTDT(7) <= '0';
			elsif (M_FAIL64='1') then
				DEBUG_OUTDT(7) <= '1';
			end if;
		end if;
	end process;



--***************************************************************


	process (RST,CLK) begin
		if (RST='1') then
			DMASTAT_ON <= '0';
		elsif (CLK'event and CLK='1') then
			if (DMACTRL_SEL='1' and DMAREG_WE='1') then						------ Register Write Enable ?
				DMASTAT_ON <= DMAREG_DTI(0);								------ DMA Start/Stop Control Bit Set
			else
				DMASTAT_ON <= '0';											------ DMA Start/Stop Control Bit Clear
			end if;
		end if;
	end process;

	process (RST,CLK) begin
		if (RST='1') then
			DMASTAT_CHK <= '0';
		elsif (CLK'event and CLK='1') then
			DMASTAT_CHK <= DMASTAT_ON;								------ DMA Start/Stop Control Bit Set
		end if;
	end process;


	process (RST,CLK) begin
		if (RST='1') then
			DMASTAT_CNT <= (others=>'0');
		elsif (CLK'event and CLK='1') then
			if (REG_SEL(6)='1' and DMAREG_WE='1') then						------ Register Write Enable ?
				DMASTAT_CNT(15 downto  0) <= (others=>'0');						------ Register Write Data Set
				DMASTAT_CNT(31 downto 16) <= DMAREG_DTI(31 downto 16);						------ Register Write Data Set
			elsif (DMASTAT_ON='1') then
				DMASTAT_CNT(15 downto  0) <= DMASTAT_CNT(15 downto  0)+1;						------ Register Write Data Set
				DMASTAT_CNT(31 downto 16) <= DMASTAT_CNT(31 downto 16);						------ Register Write Data Set
			end if;
		end if;
	end process;


	process (RST,CLK) begin
		if (RST='1') then
			DMAON_TIME <= (others=>'0');
		elsif (CLK'event and CLK='1') then
			if (DMASTAT_CNT(31 downto 16)=DMASTAT_CNT(15 downto 0)) then						------ Register Write Enable ?
				if (DMASTAT_CHK='1') then						------ Register Write Enable ?
					DMAON_TIME <= (others=>'0');
				elsif (DMASTAT_BIT='1') then
					DMAON_TIME <= DMAON_TIME+1;
				end if;
			end if;
		end if;
	end process;

	process (RST,CLK) begin
		if (RST='1') then
			DMAPCI_TIME <= (others=>'0');
		elsif (CLK'event and CLK='1') then
			if (DMASTAT_CNT(31 downto 16)=DMASTAT_CNT(15 downto 0)) then						------ Register Write Enable ?
				if (DMASTAT_CHK='1') then											------ Register Write Enable ?
					DMAPCI_TIME <= (others=>'0');
				elsif (DMASTAT_BIT='1' and M_DATA_VLD='1') then
					DMAPCI_TIME <= DMAPCI_TIME+1;
				end if;
			end if;
		end if;
	end process;




	process (RST,CLK) begin
		if (RST='1') then
			FRAMEN_CHK <= (others=>'0');
		elsif (CLK'event and CLK='1') then
			FRAMEN_CHK <= FRAMEN_CHK(1 downto 0) & M_DATA;
		end if;
	end process;

	process (RST,CLK) begin
		if (RST='1') then
			FRAME_CUNT <= (others=>'0');
		elsif (CLK'event and CLK='1') then
			if (DMASTAT_CNT(31 downto 16)=DMASTAT_CNT(15 downto 0)) then						------ Register Write Enable ?
				if (DMASTAT_CHK='1') then											------ Register Write Enable ?
					FRAME_CUNT <= (others=>'0');
				elsif (DMASTAT_BIT='1' and FRAMEN_CHK(2 downto 1)="01") then
					FRAME_CUNT <= FRAME_CUNT+1;
				end if;
			end if;
		end if;
	end process;













--	signal FRAMEN_CHK	: std_logic_vector( 2 downto  0);			-- Interrupt Mask Register Read Data
--	signal FRAME_CUNT	: std_logic_vector(31 downto  0);			-- Interrupt Mask Register Read Data


--	signal DMAPCI_TIME	: std_logic_vector(31 downto  0);			-- Interrupt Mask Register Read Data


--	signal DMASTAT_ON	: std_logic;								-- DMA Start/Stop Control Bit
--
--	signal DMASTAT_CNT	: std_logic_vector( 7 downto  0);			-- Interrupt Mask Register Read Data
--
--	signal DMAON_TIME	: std_logic_vector(31 downto  0);			-- Interrupt Mask Register Read Data






--------------------------------------------------------------------------------
-- Free Run Counter
--------------------------------------------------------------------------------

	process (RST,CLK) begin
		if (RST='1') then
			TIMER_CUNT <= (others=>'0');
		elsif (CLK'event and CLK='1') then
			if (REG_SEL(10)='1' and DMAREG_WE='1') then						------ Register Write Enable ?
				TIMER_CUNT <= (others=>'0');								------ Register Write Data Set
			else
				TIMER_CUNT <= TIMER_CUNT+1;
			end if;
		end if;
	end process;







end PCI_DMACNT_rtl;
