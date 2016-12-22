-- C:\CYGWIN\HOME\ADMINISTRATOR\FKIT\PCI64\PROJ
-- VHDL Test Bench created by
-- HDL Bencher 6.1i
-- Mon Jan 03 23:23:10 2005
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

ENTITY sim_local_read_if IS
END sim_local_read_if;

ARCHITECTURE testbench_arch OF sim_local_read_if IS
-- If you get a compiler error on the following line,
-- from the menu do Options->Configuration select VHDL 87
FILE RESULTS: TEXT OPEN WRITE_MODE IS "results.txt";
	COMPONENT local_read_if
		PORT (
			EXEC : In  std_logic;
			START_AD : In  std_logic_vector (18 DOWNTO 0);
			NQWORD : In  std_logic_vector (8 DOWNTO 0);
			CHIPSEL : In  std_logic_vector (3 DOWNTO 0);
			MEM_AD_BASE : In  std_logic_vector (12 DOWNTO 0);
			BUSY : Out  std_logic;
			DMAR_ENABLE : Out  std_logic_vector (3 DOWNTO 0);
			DBUS_Port : Out  std_logic_vector (63 DOWNTO 0);
			DBUS_idata : In  std_logic_vector (63 DOWNTO 0);
			DBUS_HiZ : Out  std_logic;
			MEM_ADB : Out  std_logic_vector (12 DOWNTO 0);
			MEM_WEHB : Out  std_logic;
			MEM_WELB : Out  std_logic;
			MEM_DTIB : Out  std_logic_vector (63 DOWNTO 0);
			RST : In  std_logic;
			CLK : In  std_logic
		);
	END COMPONENT;

	SIGNAL EXEC : std_logic;
	SIGNAL START_AD : std_logic_vector (18 DOWNTO 0);
	SIGNAL NQWORD : std_logic_vector (8 DOWNTO 0);
	SIGNAL CHIPSEL : std_logic_vector (3 DOWNTO 0);
	SIGNAL MEM_AD_BASE : std_logic_vector (12 DOWNTO 0);
	SIGNAL BUSY : std_logic;
	SIGNAL DMAR_ENABLE : std_logic_vector (3 DOWNTO 0);
	SIGNAL DBUS_Port : std_logic_vector (63 DOWNTO 0);
	SIGNAL DBUS_idata : std_logic_vector (63 DOWNTO 0);
	SIGNAL DBUS_HiZ : std_logic;
	SIGNAL MEM_ADB : std_logic_vector (12 DOWNTO 0);
	SIGNAL MEM_WEHB : std_logic;
	SIGNAL MEM_WELB : std_logic;
	SIGNAL MEM_DTIB : std_logic_vector (63 DOWNTO 0);
	SIGNAL RST : std_logic;
	SIGNAL CLK : std_logic;

BEGIN
	UUT : local_read_if
	PORT MAP (
		EXEC => EXEC,
		START_AD => START_AD,
		NQWORD => NQWORD,
		CHIPSEL => CHIPSEL,
		MEM_AD_BASE => MEM_AD_BASE,
		BUSY => BUSY,
		DMAR_ENABLE => DMAR_ENABLE,
		DBUS_Port => DBUS_Port,
		DBUS_idata => DBUS_idata,
		DBUS_HiZ => DBUS_HiZ,
		MEM_ADB => MEM_ADB,
		MEM_WEHB => MEM_WEHB,
		MEM_WELB => MEM_WELB,
		MEM_DTIB => MEM_DTIB,
		RST => RST,
		CLK => CLK
	);

	PROCESS -- clock process for CLK,
	BEGIN
		CLOCK_LOOP : LOOP
		CLK <= transport '0';
		WAIT FOR 25 ns;
		CLK <= transport '1';
		WAIT FOR 25 ns;
		WAIT FOR 25 ns;
		CLK <= transport '0';
		WAIT FOR 25 ns;
		END LOOP CLOCK_LOOP;
	END PROCESS;

	PROCESS   -- Process for CLK
		VARIABLE TX_OUT : LINE;
		VARIABLE TX_ERROR : INTEGER := 0;

		PROCEDURE CHECK_BUSY(
			next_BUSY : std_logic;
			TX_TIME : INTEGER
		) IS
			VARIABLE TX_STR : String(1 to 4096);
			VARIABLE TX_LOC : LINE;
		BEGIN
			-- If compiler error ("/=" is ambiguous) occurs in the next line of code
			-- change compiler settings to use explicit declarations only
			IF (BUSY /= next_BUSY) THEN 
				STD.TEXTIO.write(TX_LOC,string'("Error at time="));
				STD.TEXTIO.write(TX_LOC, TX_TIME);
				STD.TEXTIO.write(TX_LOC,string'("ns BUSY="));
				IEEE.STD_LOGIC_TEXTIO.write(TX_LOC, BUSY);
				STD.TEXTIO.write(TX_LOC, string'(", Expected = "));
				IEEE.STD_LOGIC_TEXTIO.write(TX_LOC, next_BUSY);
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
		EXEC <= transport '0';
		START_AD <= transport std_logic_vector'("0000000000000000000"); --0
		NQWORD <= transport std_logic_vector'("000000000"); --0
		CHIPSEL <= transport std_logic_vector'("0000"); --0
		MEM_AD_BASE <= transport std_logic_vector'("0000000000000"); --0
		DBUS_idata <= transport std_logic_vector'("0000000000000000000000000000000000000000000000000000000000000000"); --0
		RST <= transport '0';
		-- --------------------
		WAIT FOR 400 ns; -- Time=400 ns
		START_AD <= transport std_logic_vector'("0001000000000000000"); --8000
		NQWORD <= transport std_logic_vector'("000000111"); --7
		CHIPSEL <= transport std_logic_vector'("0000"); --0
		MEM_AD_BASE <= transport std_logic_vector'("0000100000000"); --100
		-- --------------------
		WAIT FOR 700 ns; -- Time=1100 ns
		EXEC <= transport '1';
		-- --------------------
		WAIT FOR 100 ns; -- Time=1200 ns
		EXEC <= transport '0';
		-- --------------------
		WAIT FOR 1600 ns; -- Time=2800 ns
		EXEC <= transport '1';
		-- --------------------
		WAIT FOR 100 ns; -- Time=2900 ns
		EXEC <= transport '0';
		-- --------------------
		WAIT FOR 3300 ns; -- Time=6200 ns
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

CONFIGURATION local_read_if_cfg OF sim_local_read_if IS
	FOR testbench_arch
	END FOR;
END local_read_if_cfg;
