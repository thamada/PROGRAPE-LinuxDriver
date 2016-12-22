-- C:\CYGWIN\HOME\ADMINISTRATOR\FKIT\PCI64\PROJ
-- VHDL Test Bench created by
-- HDL Bencher 6.1i
-- Sun Jan 02 23:14:58 2005
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

ENTITY sim_local_write IS
END sim_local_write;

ARCHITECTURE testbench_arch OF sim_local_write IS
-- If you get a compiler error on the following line,
-- from the menu do Options->Configuration select VHDL 87
FILE RESULTS: TEXT OPEN WRITE_MODE IS "results.txt";
	COMPONENT local_write
		PORT (
			MEM_AD : In  std_logic_vector (16 DOWNTO 0);
			MEM_WE : In  std_logic;
			MEM_DTI : In  std_logic_vector (63 DOWNTO 0);
			DMAW_ENABLE : Out  std_logic_vector (3 DOWNTO 0);
			DBUS_Port : Out  std_logic_vector (63 DOWNTO 0);
			RST : In  std_logic;
			CLK : In  std_logic
		);
	END COMPONENT;

	SIGNAL MEM_AD : std_logic_vector (16 DOWNTO 0);
	SIGNAL MEM_WE : std_logic;
	SIGNAL MEM_DTI : std_logic_vector (63 DOWNTO 0);
	SIGNAL DMAW_ENABLE : std_logic_vector (3 DOWNTO 0);
	SIGNAL DBUS_Port : std_logic_vector (63 DOWNTO 0);
	SIGNAL RST : std_logic;
	SIGNAL CLK : std_logic;

BEGIN
	UUT : local_write
	PORT MAP (
		MEM_AD => MEM_AD,
		MEM_WE => MEM_WE,
		MEM_DTI => MEM_DTI,
		DMAW_ENABLE => DMAW_ENABLE,
		DBUS_Port => DBUS_Port,
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

		BEGIN
		-- --------------------
		MEM_AD <= transport std_logic_vector'("00000000000000000"); --0
		MEM_WE <= transport '0';
		MEM_DTI <= transport std_logic_vector'("0000000000000000000000000000000000000000000000000000000000000000"); --0
		RST <= transport '0';
		-- --------------------
		WAIT FOR 500 ns; -- Time=500 ns
		MEM_AD <= transport std_logic_vector'("01100000000000000"); --C000
		MEM_WE <= transport '1';
		MEM_DTI <= transport std_logic_vector'("0000000000000000000000000000000000000000000000000001000100010001"); --1111
		-- --------------------
		WAIT FOR 100 ns; -- Time=600 ns
		MEM_DTI <= transport std_logic_vector'("0000000000000000000000000000000000000000000000000010001000100010"); --2222
		-- --------------------
		WAIT FOR 100 ns; -- Time=700 ns
		MEM_DTI <= transport std_logic_vector'("0000000000000000000000000000000000000000000000000011001100110011"); --3333
		-- --------------------
		WAIT FOR 100 ns; -- Time=800 ns
		MEM_DTI <= transport std_logic_vector'("0000000000000000000000000000000000000000000000000100010001000100"); --4444
		-- --------------------
		WAIT FOR 100 ns; -- Time=900 ns
		MEM_WE <= transport '0';
		-- --------------------
		WAIT FOR 800 ns; -- Time=1700 ns
		MEM_AD <= transport std_logic_vector'("01000000000000000"); --8000
		MEM_WE <= transport '1';
		MEM_DTI <= transport std_logic_vector'("0000000000000000000000000000000000000000101010111100110111101111"); --ABCDEF
		-- --------------------
		WAIT FOR 100 ns; -- Time=1800 ns
		MEM_AD <= transport std_logic_vector'("00000000000000000"); --0
		MEM_WE <= transport '0';
		MEM_DTI <= transport std_logic_vector'("0000000000000000000000000000000000000000000000000000000000000000"); --0
		-- --------------------
		WAIT FOR 1205 ns; -- Time=3005 ns
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

CONFIGURATION local_write_cfg OF sim_local_write IS
	FOR testbench_arch
	END FOR;
END local_write_cfg;
