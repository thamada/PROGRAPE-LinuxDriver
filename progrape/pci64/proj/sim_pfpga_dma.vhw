-- C:\CYGWIN\HOME\ADMINISTRATOR\FKIT\PCI64\PROJ
-- VHDL Test Bench created by
-- HDL Bencher 6.1i
-- Thu Dec 16 15:39:41 2004
-- 
-- Notes:
-- 1) This testbench has been automatically generated from
--   your Test Bench Waveform
-- 2) To use this as a user modifiable testbench do the following:
--   - Save it as a file with a .vhd extension (i.e. File->Save As...)
--   - Add it to your project as a testbench source (i.e. Project->Add Source...)
-- 

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
USE STD.TEXTIO.ALL;

ENTITY sim_pfpga_dma IS
END sim_pfpga_dma;

ARCHITECTURE testbench_arch OF sim_pfpga_dma IS
-- If you get a compiler error on the following line,
-- from the menu do Options->Configuration select VHDL 87
FILE RESULTS: TEXT OPEN WRITE_MODE IS "results.txt";
	COMPONENT pfpga_dma
		PORT (
			PGPG_REG3 : In  std_logic_vector (31 DOWNTO 0);
			GPREG0 : Out  std_logic_vector (31 DOWNTO 0);
			Hit_PGPG_REG3 : In  std_logic;
			MEM_ADA : In  std_logic_vector (12 DOWNTO 0);
			MEM_WEHA : In  std_logic;
			MEM_WELA : In  std_logic;
			MEM_DTIA : In  std_logic_vector (63 DOWNTO 0);
			DMAW_ENABLE : Out  std_logic_vector (3 DOWNTO 0);
			DMAR_ENABLE : Out  std_logic_vector (3 DOWNTO 0);
			DBUS_Port : Out  std_logic_vector (63 DOWNTO 0);
			DBUS_idata : In  std_logic_vector (63 DOWNTO 0);
			DBUS_HiZ : Out  std_logic;
			MEM_ADB : Out  std_logic_vector (12 DOWNTO 0);
			MEM_WEHB : Out  std_logic;
			MEM_WELB : Out  std_logic;
			MEM_DTIB : Out  std_logic_vector (63 DOWNTO 0);
			MEM_DTOB : In  std_logic_vector (63 DOWNTO 0);
			RST : In  std_logic;
			CLK : In  std_logic
		);
	END COMPONENT;

	SIGNAL PGPG_REG3 : std_logic_vector (31 DOWNTO 0);
	SIGNAL GPREG0 : std_logic_vector (31 DOWNTO 0);
	SIGNAL Hit_PGPG_REG3 : std_logic;
	SIGNAL MEM_ADA : std_logic_vector (12 DOWNTO 0);
	SIGNAL MEM_WEHA : std_logic;
	SIGNAL MEM_WELA : std_logic;
	SIGNAL MEM_DTIA : std_logic_vector (63 DOWNTO 0);
	SIGNAL DMAW_ENABLE : std_logic_vector (3 DOWNTO 0);
	SIGNAL DMAR_ENABLE : std_logic_vector (3 DOWNTO 0);
	SIGNAL DBUS_Port : std_logic_vector (63 DOWNTO 0);
	SIGNAL DBUS_idata : std_logic_vector (63 DOWNTO 0);
	SIGNAL DBUS_HiZ : std_logic;
	SIGNAL MEM_ADB : std_logic_vector (12 DOWNTO 0);
	SIGNAL MEM_WEHB : std_logic;
	SIGNAL MEM_WELB : std_logic;
	SIGNAL MEM_DTIB : std_logic_vector (63 DOWNTO 0);
	SIGNAL MEM_DTOB : std_logic_vector (63 DOWNTO 0);
	SIGNAL RST : std_logic;
	SIGNAL CLK : std_logic;

BEGIN
	UUT : pfpga_dma
	PORT MAP (
		PGPG_REG3 => PGPG_REG3,
		GPREG0 => GPREG0,
		Hit_PGPG_REG3 => Hit_PGPG_REG3,
		MEM_ADA => MEM_ADA,
		MEM_WEHA => MEM_WEHA,
		MEM_WELA => MEM_WELA,
		MEM_DTIA => MEM_DTIA,
		DMAW_ENABLE => DMAW_ENABLE,
		DMAR_ENABLE => DMAR_ENABLE,
		DBUS_Port => DBUS_Port,
		DBUS_idata => DBUS_idata,
		DBUS_HiZ => DBUS_HiZ,
		MEM_ADB => MEM_ADB,
		MEM_WEHB => MEM_WEHB,
		MEM_WELB => MEM_WELB,
		MEM_DTIB => MEM_DTIB,
		MEM_DTOB => MEM_DTOB,
		RST => RST,
		CLK => CLK
	);

	PROCESS -- clock process for CLK,
	BEGIN
		CLOCK_LOOP : LOOP
		CLK <= transport '0';
		WAIT FOR 5 ns;
		CLK <= transport '1';
		WAIT FOR 50 ns;
		CLK <= transport '0';
		WAIT FOR 35 ns;
		WAIT FOR 10 ns;
		END LOOP CLOCK_LOOP;
	END PROCESS;

	PROCESS   -- Process for CLK
		VARIABLE TX_OUT : LINE;
		VARIABLE TX_ERROR : INTEGER := 0;

		PROCEDURE CHECK_GPREG0(
			next_GPREG0 : std_logic_vector (31 DOWNTO 0);
			TX_TIME : INTEGER
		) IS
			VARIABLE TX_STR : String(1 to 4096);
			VARIABLE TX_LOC : LINE;
		BEGIN
			-- If compiler error ("/=" is ambiguous) occurs in the next line of code
			-- change compiler settings to use explicit declarations only
			IF (GPREG0 /= next_GPREG0) THEN 
				STD.TEXTIO.write(TX_LOC,string'("Error at time="));
				STD.TEXTIO.write(TX_LOC, TX_TIME);
				STD.TEXTIO.write(TX_LOC,string'("ns GPREG0="));
				IEEE.STD_LOGIC_TEXTIO.write(TX_LOC, GPREG0);
				STD.TEXTIO.write(TX_LOC, string'(", Expected = "));
				IEEE.STD_LOGIC_TEXTIO.write(TX_LOC, next_GPREG0);
				STD.TEXTIO.write(TX_LOC, string'(" "));
				TX_STR(TX_LOC.all'range) := TX_LOC.all;
				STD.TEXTIO.writeline(results, TX_LOC);
				STD.TEXTIO.Deallocate(TX_LOC);
				ASSERT (FALSE) REPORT TX_STR SEVERITY ERROR;
				TX_ERROR := TX_ERROR + 1;
			END IF;
		END;

		PROCEDURE CHECK_DMAW_ENABLE(
			next_DMAW_ENABLE : std_logic_vector (3 DOWNTO 0);
			TX_TIME : INTEGER
		) IS
			VARIABLE TX_STR : String(1 to 4096);
			VARIABLE TX_LOC : LINE;
		BEGIN
			-- If compiler error ("/=" is ambiguous) occurs in the next line of code
			-- change compiler settings to use explicit declarations only
			IF (DMAW_ENABLE /= next_DMAW_ENABLE) THEN 
				STD.TEXTIO.write(TX_LOC,string'("Error at time="));
				STD.TEXTIO.write(TX_LOC, TX_TIME);
				STD.TEXTIO.write(TX_LOC,string'("ns DMAW_ENABLE="));
				IEEE.STD_LOGIC_TEXTIO.write(TX_LOC, DMAW_ENABLE);
				STD.TEXTIO.write(TX_LOC, string'(", Expected = "));
				IEEE.STD_LOGIC_TEXTIO.write(TX_LOC, next_DMAW_ENABLE);
				STD.TEXTIO.write(TX_LOC, string'(" "));
				TX_STR(TX_LOC.all'range) := TX_LOC.all;
				STD.TEXTIO.writeline(results, TX_LOC);
				STD.TEXTIO.Deallocate(TX_LOC);
				ASSERT (FALSE) REPORT TX_STR SEVERITY ERROR;
				TX_ERROR := TX_ERROR + 1;
			END IF;
		END;

		PROCEDURE CHECK_DMAR_ENABLE(
			next_DMAR_ENABLE : std_logic_vector (3 DOWNTO 0);
			TX_TIME : INTEGER
		) IS
			VARIABLE TX_STR : String(1 to 4096);
			VARIABLE TX_LOC : LINE;
		BEGIN
			-- If compiler error ("/=" is ambiguous) occurs in the next line of code
			-- change compiler settings to use explicit declarations only
			IF (DMAR_ENABLE /= next_DMAR_ENABLE) THEN 
				STD.TEXTIO.write(TX_LOC,string'("Error at time="));
				STD.TEXTIO.write(TX_LOC, TX_TIME);
				STD.TEXTIO.write(TX_LOC,string'("ns DMAR_ENABLE="));
				IEEE.STD_LOGIC_TEXTIO.write(TX_LOC, DMAR_ENABLE);
				STD.TEXTIO.write(TX_LOC, string'(", Expected = "));
				IEEE.STD_LOGIC_TEXTIO.write(TX_LOC, next_DMAR_ENABLE);
				STD.TEXTIO.write(TX_LOC, string'(" "));
				TX_STR(TX_LOC.all'range) := TX_LOC.all;
				STD.TEXTIO.writeline(results, TX_LOC);
				STD.TEXTIO.Deallocate(TX_LOC);
				ASSERT (FALSE) REPORT TX_STR SEVERITY ERROR;
				TX_ERROR := TX_ERROR + 1;
			END IF;
		END;

		PROCEDURE CHECK_DBUS_Port(
			next_DBUS_Port : std_logic_vector (63 DOWNTO 0);
			TX_TIME : INTEGER
		) IS
			VARIABLE TX_STR : String(1 to 4096);
			VARIABLE TX_LOC : LINE;
		BEGIN
			-- If compiler error ("/=" is ambiguous) occurs in the next line of code
			-- change compiler settings to use explicit declarations only
			IF (DBUS_Port /= next_DBUS_Port) THEN 
				STD.TEXTIO.write(TX_LOC,string'("Error at time="));
				STD.TEXTIO.write(TX_LOC, TX_TIME);
				STD.TEXTIO.write(TX_LOC,string'("ns DBUS_Port="));
				IEEE.STD_LOGIC_TEXTIO.write(TX_LOC, DBUS_Port);
				STD.TEXTIO.write(TX_LOC, string'(", Expected = "));
				IEEE.STD_LOGIC_TEXTIO.write(TX_LOC, next_DBUS_Port);
				STD.TEXTIO.write(TX_LOC, string'(" "));
				TX_STR(TX_LOC.all'range) := TX_LOC.all;
				STD.TEXTIO.writeline(results, TX_LOC);
				STD.TEXTIO.Deallocate(TX_LOC);
				ASSERT (FALSE) REPORT TX_STR SEVERITY ERROR;
				TX_ERROR := TX_ERROR + 1;
			END IF;
		END;

		PROCEDURE CHECK_DBUS_HiZ(
			next_DBUS_HiZ : std_logic;
			TX_TIME : INTEGER
		) IS
			VARIABLE TX_STR : String(1 to 4096);
			VARIABLE TX_LOC : LINE;
		BEGIN
			-- If compiler error ("/=" is ambiguous) occurs in the next line of code
			-- change compiler settings to use explicit declarations only
			IF (DBUS_HiZ /= next_DBUS_HiZ) THEN 
				STD.TEXTIO.write(TX_LOC,string'("Error at time="));
				STD.TEXTIO.write(TX_LOC, TX_TIME);
				STD.TEXTIO.write(TX_LOC,string'("ns DBUS_HiZ="));
				IEEE.STD_LOGIC_TEXTIO.write(TX_LOC, DBUS_HiZ);
				STD.TEXTIO.write(TX_LOC, string'(", Expected = "));
				IEEE.STD_LOGIC_TEXTIO.write(TX_LOC, next_DBUS_HiZ);
				STD.TEXTIO.write(TX_LOC, string'(" "));
				TX_STR(TX_LOC.all'range) := TX_LOC.all;
				STD.TEXTIO.writeline(results, TX_LOC);
				STD.TEXTIO.Deallocate(TX_LOC);
				ASSERT (FALSE) REPORT TX_STR SEVERITY ERROR;
				TX_ERROR := TX_ERROR + 1;
			END IF;
		END;

		PROCEDURE CHECK_MEM_ADB(
			next_MEM_ADB : std_logic_vector (12 DOWNTO 0);
			TX_TIME : INTEGER
		) IS
			VARIABLE TX_STR : String(1 to 4096);
			VARIABLE TX_LOC : LINE;
		BEGIN
			-- If compiler error ("/=" is ambiguous) occurs in the next line of code
			-- change compiler settings to use explicit declarations only
			IF (MEM_ADB /= next_MEM_ADB) THEN 
				STD.TEXTIO.write(TX_LOC,string'("Error at time="));
				STD.TEXTIO.write(TX_LOC, TX_TIME);
				STD.TEXTIO.write(TX_LOC,string'("ns MEM_ADB="));
				IEEE.STD_LOGIC_TEXTIO.write(TX_LOC, MEM_ADB);
				STD.TEXTIO.write(TX_LOC, string'(", Expected = "));
				IEEE.STD_LOGIC_TEXTIO.write(TX_LOC, next_MEM_ADB);
				STD.TEXTIO.write(TX_LOC, string'(" "));
				TX_STR(TX_LOC.all'range) := TX_LOC.all;
				STD.TEXTIO.writeline(results, TX_LOC);
				STD.TEXTIO.Deallocate(TX_LOC);
				ASSERT (FALSE) REPORT TX_STR SEVERITY ERROR;
				TX_ERROR := TX_ERROR + 1;
			END IF;
		END;

		PROCEDURE CHECK_MEM_WEHB(
			next_MEM_WEHB : std_logic;
			TX_TIME : INTEGER
		) IS
			VARIABLE TX_STR : String(1 to 4096);
			VARIABLE TX_LOC : LINE;
		BEGIN
			-- If compiler error ("/=" is ambiguous) occurs in the next line of code
			-- change compiler settings to use explicit declarations only
			IF (MEM_WEHB /= next_MEM_WEHB) THEN 
				STD.TEXTIO.write(TX_LOC,string'("Error at time="));
				STD.TEXTIO.write(TX_LOC, TX_TIME);
				STD.TEXTIO.write(TX_LOC,string'("ns MEM_WEHB="));
				IEEE.STD_LOGIC_TEXTIO.write(TX_LOC, MEM_WEHB);
				STD.TEXTIO.write(TX_LOC, string'(", Expected = "));
				IEEE.STD_LOGIC_TEXTIO.write(TX_LOC, next_MEM_WEHB);
				STD.TEXTIO.write(TX_LOC, string'(" "));
				TX_STR(TX_LOC.all'range) := TX_LOC.all;
				STD.TEXTIO.writeline(results, TX_LOC);
				STD.TEXTIO.Deallocate(TX_LOC);
				ASSERT (FALSE) REPORT TX_STR SEVERITY ERROR;
				TX_ERROR := TX_ERROR + 1;
			END IF;
		END;

		PROCEDURE CHECK_MEM_WELB(
			next_MEM_WELB : std_logic;
			TX_TIME : INTEGER
		) IS
			VARIABLE TX_STR : String(1 to 4096);
			VARIABLE TX_LOC : LINE;
		BEGIN
			-- If compiler error ("/=" is ambiguous) occurs in the next line of code
			-- change compiler settings to use explicit declarations only
			IF (MEM_WELB /= next_MEM_WELB) THEN 
				STD.TEXTIO.write(TX_LOC,string'("Error at time="));
				STD.TEXTIO.write(TX_LOC, TX_TIME);
				STD.TEXTIO.write(TX_LOC,string'("ns MEM_WELB="));
				IEEE.STD_LOGIC_TEXTIO.write(TX_LOC, MEM_WELB);
				STD.TEXTIO.write(TX_LOC, string'(", Expected = "));
				IEEE.STD_LOGIC_TEXTIO.write(TX_LOC, next_MEM_WELB);
				STD.TEXTIO.write(TX_LOC, string'(" "));
				TX_STR(TX_LOC.all'range) := TX_LOC.all;
				STD.TEXTIO.writeline(results, TX_LOC);
				STD.TEXTIO.Deallocate(TX_LOC);
				ASSERT (FALSE) REPORT TX_STR SEVERITY ERROR;
				TX_ERROR := TX_ERROR + 1;
			END IF;
		END;

		PROCEDURE CHECK_MEM_DTIB(
			next_MEM_DTIB : std_logic_vector (63 DOWNTO 0);
			TX_TIME : INTEGER
		) IS
			VARIABLE TX_STR : String(1 to 4096);
			VARIABLE TX_LOC : LINE;
		BEGIN
			-- If compiler error ("/=" is ambiguous) occurs in the next line of code
			-- change compiler settings to use explicit declarations only
			IF (MEM_DTIB /= next_MEM_DTIB) THEN 
				STD.TEXTIO.write(TX_LOC,string'("Error at time="));
				STD.TEXTIO.write(TX_LOC, TX_TIME);
				STD.TEXTIO.write(TX_LOC,string'("ns MEM_DTIB="));
				IEEE.STD_LOGIC_TEXTIO.write(TX_LOC, MEM_DTIB);
				STD.TEXTIO.write(TX_LOC, string'(", Expected = "));
				IEEE.STD_LOGIC_TEXTIO.write(TX_LOC, next_MEM_DTIB);
				STD.TEXTIO.write(TX_LOC, string'(" "));
				TX_STR(TX_LOC.all'range) := TX_LOC.all;
				STD.TEXTIO.writeline(results, TX_LOC);
				STD.TEXTIO.Deallocate(TX_LOC);
				ASSERT (FALSE) REPORT TX_STR SEVERITY ERROR;
				TX_ERROR := TX_ERROR + 1;
			END IF;
		END;

		BEGIN
		-- --------------------
		RST <= transport '0';
		PGPG_REG3 <= transport std_logic_vector'("00000000000000000000000000000000"); --0
		Hit_PGPG_REG3 <= transport '0';
		MEM_ADA <= transport std_logic_vector'("0000000000000"); --0
		MEM_WEHA <= transport '0';
		MEM_WELA <= transport '0';
		MEM_DTIA <= transport std_logic_vector'("0000000000000000000000000000000000000000000000000000000000000000"); --0
		DBUS_idata <= transport std_logic_vector'("0000000000000000000000000000000000000000000000000000000000000000"); --0
		MEM_DTOB <= transport std_logic_vector'("0000000000000000000000000000000000000000000000000000000000000000"); --0
		-- --------------------
		WAIT FOR 500 ns; -- Time=500 ns
		RST <= transport '1';
		-- --------------------
		WAIT FOR 100 ns; -- Time=600 ns
		RST <= transport '0';
		-- --------------------
		WAIT FOR 600 ns; -- Time=1200 ns
		MEM_ADA <= transport std_logic_vector'("0111111110000"); --FF0
		MEM_WEHA <= transport '1';
		MEM_WELA <= transport '1';
		MEM_DTIA <= transport std_logic_vector'("0000000000000000000000000000000000000000000000000000000000001010"); --A
		-- --------------------
		WAIT FOR 100 ns; -- Time=1300 ns
		MEM_ADA <= transport std_logic_vector'("0111111110010"); --FF2
		MEM_DTIA <= transport std_logic_vector'("0000000000000000000000000000000000000000000000000000000000001011"); --B
		-- --------------------
		WAIT FOR 100 ns; -- Time=1400 ns
		MEM_ADA <= transport std_logic_vector'("0111111110100"); --FF4
		MEM_DTIA <= transport std_logic_vector'("0000000000000000000000000000000000000000000000000000000000001100"); --C
		-- --------------------
		WAIT FOR 100 ns; -- Time=1500 ns
		MEM_ADA <= transport std_logic_vector'("0111111110110"); --FF6
		MEM_DTIA <= transport std_logic_vector'("0000000000000000000000000000000000000000000000000000000000001101"); --D
		-- --------------------
		WAIT FOR 100 ns; -- Time=1600 ns
		MEM_WEHA <= transport '0';
		MEM_WELA <= transport '0';
		-- --------------------
		WAIT FOR 300 ns; -- Time=1900 ns
		MEM_ADA <= transport std_logic_vector'("0011101110000"); --770
		MEM_WEHA <= transport '1';
		MEM_WELA <= transport '1';
		MEM_DTIA <= transport std_logic_vector'("0000000000000000000000000000000000001111111111110000000000000001"); --FFF0001
		-- --------------------
		WAIT FOR 100 ns; -- Time=2000 ns
		MEM_ADA <= transport std_logic_vector'("0011101110010"); --772
		MEM_DTIA <= transport std_logic_vector'("0000000000000000000000000000000000001111111111110000000000000010"); --FFF0002
		-- --------------------
		WAIT FOR 100 ns; -- Time=2100 ns
		MEM_ADA <= transport std_logic_vector'("0011101110100"); --774
		MEM_DTIA <= transport std_logic_vector'("0000000000000000000000000000000000001111111111110000000000000011"); --FFF0003
		-- --------------------
		WAIT FOR 100 ns; -- Time=2200 ns
		MEM_ADA <= transport std_logic_vector'("0011101110110"); --776
		MEM_DTIA <= transport std_logic_vector'("0000000000000000000000000000000000001111111111110000000000000100"); --FFF0004
		-- --------------------
		WAIT FOR 100 ns; -- Time=2300 ns
		MEM_ADA <= transport std_logic_vector'("0011101111000"); --778
		MEM_DTIA <= transport std_logic_vector'("0000000000000000000000000000000000001111111111110000000000000101"); --FFF0005
		-- --------------------
		WAIT FOR 100 ns; -- Time=2400 ns
		MEM_ADA <= transport std_logic_vector'("0011101111010"); --77A
		MEM_DTIA <= transport std_logic_vector'("0000000000000000000000000000000000001111111111110000000000000110"); --FFF0006
		-- --------------------
		WAIT FOR 100 ns; -- Time=2500 ns
		MEM_ADA <= transport std_logic_vector'("0011101111100"); --77C
		MEM_DTIA <= transport std_logic_vector'("0000000000000000000000000000000000001111111111110000000000000111"); --FFF0007
		-- --------------------
		WAIT FOR 100 ns; -- Time=2600 ns
		MEM_WEHA <= transport '0';
		MEM_WELA <= transport '0';
		-- --------------------
		WAIT FOR 100 ns; -- Time=2700 ns
		MEM_ADA <= transport std_logic_vector'("0000000000100"); --4
		MEM_WEHA <= transport '1';
		MEM_WELA <= transport '1';
		MEM_DTIA <= transport std_logic_vector'("0000000000000000000000000000011101110111011101110000000000000100"); --777770004
		-- --------------------
		WAIT FOR 100 ns; -- Time=2800 ns
		MEM_WEHA <= transport '0';
		MEM_WELA <= transport '0';
		-- --------------------
		WAIT FOR 100 ns; -- Time=2900 ns
		MEM_ADA <= transport std_logic_vector'("0000000000110"); --6
		MEM_WEHA <= transport '1';
		MEM_WELA <= transport '1';
		MEM_DTIA <= transport std_logic_vector'("0000000000000000000000000000011101110111011101110000000000000110"); --777770006
		-- --------------------
		WAIT FOR 100 ns; -- Time=3000 ns
		MEM_WEHA <= transport '0';
		MEM_WELA <= transport '0';
		-- --------------------
		WAIT FOR 500 ns; -- Time=3500 ns
		MEM_ADA <= transport std_logic_vector'("0011101111000"); --778
		MEM_WEHA <= transport '1';
		MEM_WELA <= transport '1';
		MEM_DTIA <= transport std_logic_vector'("1001100110011001100110011001100110001000100010001000100010001000"); --9999999988888888
		-- --------------------
		WAIT FOR 100 ns; -- Time=3600 ns
		MEM_ADA <= transport std_logic_vector'("0011101111010"); --77A
		MEM_DTIA <= transport std_logic_vector'("1011101110111011101110111011101110101010101010101010101010101010"); --BBBBBBBBAAAAAAAA
		-- --------------------
		WAIT FOR 100 ns; -- Time=3700 ns
		MEM_WEHA <= transport '0';
		MEM_WELA <= transport '0';
		-- --------------------
		WAIT FOR 1255 ns; -- Time=4955 ns
		-- --------------------

		IF (TX_ERROR = 0) THEN 
			STD.TEXTIO.write(TX_OUT,string'("No errors or warnings"));
			STD.TEXTIO.writeline(results, TX_OUT);
			ASSERT (FALSE) REPORT
				"Simulation successful (not a failure).  No problems detected. "
				SEVERITY FAILURE;
		ELSE
			STD.TEXTIO.write(TX_OUT, TX_ERROR);
			STD.TEXTIO.write(TX_OUT, string'(
				" errors found in simulation"));
			STD.TEXTIO.writeline(results, TX_OUT);
			ASSERT (FALSE) REPORT
				"Errors found during simulation"
				SEVERITY FAILURE;
		END IF;
	END PROCESS;
END testbench_arch;

CONFIGURATION pfpga_dma_cfg OF sim_pfpga_dma IS
	FOR testbench_arch
	END FOR;
END pfpga_dma_cfg;
