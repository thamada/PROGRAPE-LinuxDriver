-- C:\CYGWIN\HOME\ADMINISTRATOR\FKIT\PCI64\TMP2
-- VHDL Test Bench created by
-- HDL Bencher 6.1i
-- Wed Nov 10 11:38:24 2004
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
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
USE STD.TEXTIO.ALL;

ENTITY sim IS
END sim;

ARCHITECTURE testbench_arch OF sim IS
-- If you get a compiler error on the following line,
-- from the menu do Options->Configuration select VHDL 87
FILE RESULTS: TEXT OPEN WRITE_MODE IS "results.txt";
	COMPONENT pfpga_config
		PORT (
			clk : In  std_logic;
			rst_n : In  std_logic;
			cmd_reg : In  std_logic_vector (8 DOWNTO 0);
			data_reg : In  std_logic_vector (31 DOWNTO 0);
			CFG_D : Out  std_logic_vector (7 DOWNTO 0);
			CFG_CCLK : Out  std_logic;
			CFG_PROG_B0 : Out  std_logic;
			CFG_PROG_B1 : Out  std_logic;
			CFG_PROG_B2 : Out  std_logic;
			CFG_PROG_B3 : Out  std_logic;
			CFG_CS_B0 : Out  std_logic;
			CFG_CS_B1 : Out  std_logic;
			CFG_CS_B2 : Out  std_logic;
			CFG_CS_B3 : Out  std_logic;
			CFG_RDWR_B : Out  std_logic
		);
	END COMPONENT;

	SIGNAL clk : std_logic;
	SIGNAL rst_n : std_logic;
	SIGNAL cmd_reg : std_logic_vector (8 DOWNTO 0);
	SIGNAL data_reg : std_logic_vector (31 DOWNTO 0);
	SIGNAL CFG_D : std_logic_vector (7 DOWNTO 0);
	SIGNAL CFG_CCLK : std_logic;
	SIGNAL CFG_PROG_B0 : std_logic;
	SIGNAL CFG_PROG_B1 : std_logic;
	SIGNAL CFG_PROG_B2 : std_logic;
	SIGNAL CFG_PROG_B3 : std_logic;
	SIGNAL CFG_CS_B0 : std_logic;
	SIGNAL CFG_CS_B1 : std_logic;
	SIGNAL CFG_CS_B2 : std_logic;
	SIGNAL CFG_CS_B3 : std_logic;
	SIGNAL CFG_RDWR_B : std_logic;

BEGIN
	UUT : pfpga_config
	PORT MAP (
		clk => clk,
		rst_n => rst_n,
		cmd_reg => cmd_reg,
		data_reg => data_reg,
		CFG_D => CFG_D,
		CFG_CCLK => CFG_CCLK,
		CFG_PROG_B0 => CFG_PROG_B0,
		CFG_PROG_B1 => CFG_PROG_B1,
		CFG_PROG_B2 => CFG_PROG_B2,
		CFG_PROG_B3 => CFG_PROG_B3,
		CFG_CS_B0 => CFG_CS_B0,
		CFG_CS_B1 => CFG_CS_B1,
		CFG_CS_B2 => CFG_CS_B2,
		CFG_CS_B3 => CFG_CS_B3,
		CFG_RDWR_B => CFG_RDWR_B
	);

	PROCESS -- clock process for clk,
	BEGIN
		CLOCK_LOOP : LOOP
		clk <= transport '0';
		WAIT FOR 5 us;
		clk <= transport '1';
		WAIT FOR 5 us;
		WAIT FOR 45 us;
		clk <= transport '0';
		WAIT FOR 45 us;
		END LOOP CLOCK_LOOP;
	END PROCESS;

	PROCESS   -- Process for clk
		VARIABLE TX_OUT : LINE;
		VARIABLE TX_ERROR : INTEGER := 0;

		PROCEDURE CHECK_CFG_D(
			next_CFG_D : std_logic_vector (7 DOWNTO 0);
			TX_TIME : INTEGER
		) IS
			VARIABLE TX_STR : String(1 to 4096);
			VARIABLE TX_LOC : LINE;
		BEGIN
			-- If compiler error ("/=" is ambiguous) occurs in the next line of code
			-- change compiler settings to use explicit declarations only
			IF (CFG_D /= next_CFG_D) THEN 
				STD.TEXTIO.write(TX_LOC,string'("Error at time="));
				STD.TEXTIO.write(TX_LOC, TX_TIME);
				STD.TEXTIO.write(TX_LOC,string'("us CFG_D="));
				IEEE.STD_LOGIC_TEXTIO.write(TX_LOC, CFG_D);
				STD.TEXTIO.write(TX_LOC, string'(", Expected = "));
				IEEE.STD_LOGIC_TEXTIO.write(TX_LOC, next_CFG_D);
				STD.TEXTIO.write(TX_LOC, string'(" "));
				TX_STR(TX_LOC.all'range) := TX_LOC.all;
				STD.TEXTIO.writeline(results, TX_LOC);
				STD.TEXTIO.Deallocate(TX_LOC);
				ASSERT (FALSE) REPORT TX_STR SEVERITY ERROR;
				TX_ERROR := TX_ERROR + 1;
			END IF;
		END;

		PROCEDURE CHECK_CFG_CCLK(
			next_CFG_CCLK : std_logic;
			TX_TIME : INTEGER
		) IS
			VARIABLE TX_STR : String(1 to 4096);
			VARIABLE TX_LOC : LINE;
		BEGIN
			-- If compiler error ("/=" is ambiguous) occurs in the next line of code
			-- change compiler settings to use explicit declarations only
			IF (CFG_CCLK /= next_CFG_CCLK) THEN 
				STD.TEXTIO.write(TX_LOC,string'("Error at time="));
				STD.TEXTIO.write(TX_LOC, TX_TIME);
				STD.TEXTIO.write(TX_LOC,string'("us CFG_CCLK="));
				IEEE.STD_LOGIC_TEXTIO.write(TX_LOC, CFG_CCLK);
				STD.TEXTIO.write(TX_LOC, string'(", Expected = "));
				IEEE.STD_LOGIC_TEXTIO.write(TX_LOC, next_CFG_CCLK);
				STD.TEXTIO.write(TX_LOC, string'(" "));
				TX_STR(TX_LOC.all'range) := TX_LOC.all;
				STD.TEXTIO.writeline(results, TX_LOC);
				STD.TEXTIO.Deallocate(TX_LOC);
				ASSERT (FALSE) REPORT TX_STR SEVERITY ERROR;
				TX_ERROR := TX_ERROR + 1;
			END IF;
		END;

		PROCEDURE CHECK_CFG_PROG_B0(
			next_CFG_PROG_B0 : std_logic;
			TX_TIME : INTEGER
		) IS
			VARIABLE TX_STR : String(1 to 4096);
			VARIABLE TX_LOC : LINE;
		BEGIN
			-- If compiler error ("/=" is ambiguous) occurs in the next line of code
			-- change compiler settings to use explicit declarations only
			IF (CFG_PROG_B0 /= next_CFG_PROG_B0) THEN 
				STD.TEXTIO.write(TX_LOC,string'("Error at time="));
				STD.TEXTIO.write(TX_LOC, TX_TIME);
				STD.TEXTIO.write(TX_LOC,string'("us CFG_PROG_B0="));
				IEEE.STD_LOGIC_TEXTIO.write(TX_LOC, CFG_PROG_B0);
				STD.TEXTIO.write(TX_LOC, string'(", Expected = "));
				IEEE.STD_LOGIC_TEXTIO.write(TX_LOC, next_CFG_PROG_B0);
				STD.TEXTIO.write(TX_LOC, string'(" "));
				TX_STR(TX_LOC.all'range) := TX_LOC.all;
				STD.TEXTIO.writeline(results, TX_LOC);
				STD.TEXTIO.Deallocate(TX_LOC);
				ASSERT (FALSE) REPORT TX_STR SEVERITY ERROR;
				TX_ERROR := TX_ERROR + 1;
			END IF;
		END;

		PROCEDURE CHECK_CFG_PROG_B1(
			next_CFG_PROG_B1 : std_logic;
			TX_TIME : INTEGER
		) IS
			VARIABLE TX_STR : String(1 to 4096);
			VARIABLE TX_LOC : LINE;
		BEGIN
			-- If compiler error ("/=" is ambiguous) occurs in the next line of code
			-- change compiler settings to use explicit declarations only
			IF (CFG_PROG_B1 /= next_CFG_PROG_B1) THEN 
				STD.TEXTIO.write(TX_LOC,string'("Error at time="));
				STD.TEXTIO.write(TX_LOC, TX_TIME);
				STD.TEXTIO.write(TX_LOC,string'("us CFG_PROG_B1="));
				IEEE.STD_LOGIC_TEXTIO.write(TX_LOC, CFG_PROG_B1);
				STD.TEXTIO.write(TX_LOC, string'(", Expected = "));
				IEEE.STD_LOGIC_TEXTIO.write(TX_LOC, next_CFG_PROG_B1);
				STD.TEXTIO.write(TX_LOC, string'(" "));
				TX_STR(TX_LOC.all'range) := TX_LOC.all;
				STD.TEXTIO.writeline(results, TX_LOC);
				STD.TEXTIO.Deallocate(TX_LOC);
				ASSERT (FALSE) REPORT TX_STR SEVERITY ERROR;
				TX_ERROR := TX_ERROR + 1;
			END IF;
		END;

		PROCEDURE CHECK_CFG_PROG_B2(
			next_CFG_PROG_B2 : std_logic;
			TX_TIME : INTEGER
		) IS
			VARIABLE TX_STR : String(1 to 4096);
			VARIABLE TX_LOC : LINE;
		BEGIN
			-- If compiler error ("/=" is ambiguous) occurs in the next line of code
			-- change compiler settings to use explicit declarations only
			IF (CFG_PROG_B2 /= next_CFG_PROG_B2) THEN 
				STD.TEXTIO.write(TX_LOC,string'("Error at time="));
				STD.TEXTIO.write(TX_LOC, TX_TIME);
				STD.TEXTIO.write(TX_LOC,string'("us CFG_PROG_B2="));
				IEEE.STD_LOGIC_TEXTIO.write(TX_LOC, CFG_PROG_B2);
				STD.TEXTIO.write(TX_LOC, string'(", Expected = "));
				IEEE.STD_LOGIC_TEXTIO.write(TX_LOC, next_CFG_PROG_B2);
				STD.TEXTIO.write(TX_LOC, string'(" "));
				TX_STR(TX_LOC.all'range) := TX_LOC.all;
				STD.TEXTIO.writeline(results, TX_LOC);
				STD.TEXTIO.Deallocate(TX_LOC);
				ASSERT (FALSE) REPORT TX_STR SEVERITY ERROR;
				TX_ERROR := TX_ERROR + 1;
			END IF;
		END;

		PROCEDURE CHECK_CFG_PROG_B3(
			next_CFG_PROG_B3 : std_logic;
			TX_TIME : INTEGER
		) IS
			VARIABLE TX_STR : String(1 to 4096);
			VARIABLE TX_LOC : LINE;
		BEGIN
			-- If compiler error ("/=" is ambiguous) occurs in the next line of code
			-- change compiler settings to use explicit declarations only
			IF (CFG_PROG_B3 /= next_CFG_PROG_B3) THEN 
				STD.TEXTIO.write(TX_LOC,string'("Error at time="));
				STD.TEXTIO.write(TX_LOC, TX_TIME);
				STD.TEXTIO.write(TX_LOC,string'("us CFG_PROG_B3="));
				IEEE.STD_LOGIC_TEXTIO.write(TX_LOC, CFG_PROG_B3);
				STD.TEXTIO.write(TX_LOC, string'(", Expected = "));
				IEEE.STD_LOGIC_TEXTIO.write(TX_LOC, next_CFG_PROG_B3);
				STD.TEXTIO.write(TX_LOC, string'(" "));
				TX_STR(TX_LOC.all'range) := TX_LOC.all;
				STD.TEXTIO.writeline(results, TX_LOC);
				STD.TEXTIO.Deallocate(TX_LOC);
				ASSERT (FALSE) REPORT TX_STR SEVERITY ERROR;
				TX_ERROR := TX_ERROR + 1;
			END IF;
		END;

		PROCEDURE CHECK_CFG_CS_B0(
			next_CFG_CS_B0 : std_logic;
			TX_TIME : INTEGER
		) IS
			VARIABLE TX_STR : String(1 to 4096);
			VARIABLE TX_LOC : LINE;
		BEGIN
			-- If compiler error ("/=" is ambiguous) occurs in the next line of code
			-- change compiler settings to use explicit declarations only
			IF (CFG_CS_B0 /= next_CFG_CS_B0) THEN 
				STD.TEXTIO.write(TX_LOC,string'("Error at time="));
				STD.TEXTIO.write(TX_LOC, TX_TIME);
				STD.TEXTIO.write(TX_LOC,string'("us CFG_CS_B0="));
				IEEE.STD_LOGIC_TEXTIO.write(TX_LOC, CFG_CS_B0);
				STD.TEXTIO.write(TX_LOC, string'(", Expected = "));
				IEEE.STD_LOGIC_TEXTIO.write(TX_LOC, next_CFG_CS_B0);
				STD.TEXTIO.write(TX_LOC, string'(" "));
				TX_STR(TX_LOC.all'range) := TX_LOC.all;
				STD.TEXTIO.writeline(results, TX_LOC);
				STD.TEXTIO.Deallocate(TX_LOC);
				ASSERT (FALSE) REPORT TX_STR SEVERITY ERROR;
				TX_ERROR := TX_ERROR + 1;
			END IF;
		END;

		PROCEDURE CHECK_CFG_CS_B1(
			next_CFG_CS_B1 : std_logic;
			TX_TIME : INTEGER
		) IS
			VARIABLE TX_STR : String(1 to 4096);
			VARIABLE TX_LOC : LINE;
		BEGIN
			-- If compiler error ("/=" is ambiguous) occurs in the next line of code
			-- change compiler settings to use explicit declarations only
			IF (CFG_CS_B1 /= next_CFG_CS_B1) THEN 
				STD.TEXTIO.write(TX_LOC,string'("Error at time="));
				STD.TEXTIO.write(TX_LOC, TX_TIME);
				STD.TEXTIO.write(TX_LOC,string'("us CFG_CS_B1="));
				IEEE.STD_LOGIC_TEXTIO.write(TX_LOC, CFG_CS_B1);
				STD.TEXTIO.write(TX_LOC, string'(", Expected = "));
				IEEE.STD_LOGIC_TEXTIO.write(TX_LOC, next_CFG_CS_B1);
				STD.TEXTIO.write(TX_LOC, string'(" "));
				TX_STR(TX_LOC.all'range) := TX_LOC.all;
				STD.TEXTIO.writeline(results, TX_LOC);
				STD.TEXTIO.Deallocate(TX_LOC);
				ASSERT (FALSE) REPORT TX_STR SEVERITY ERROR;
				TX_ERROR := TX_ERROR + 1;
			END IF;
		END;

		PROCEDURE CHECK_CFG_CS_B2(
			next_CFG_CS_B2 : std_logic;
			TX_TIME : INTEGER
		) IS
			VARIABLE TX_STR : String(1 to 4096);
			VARIABLE TX_LOC : LINE;
		BEGIN
			-- If compiler error ("/=" is ambiguous) occurs in the next line of code
			-- change compiler settings to use explicit declarations only
			IF (CFG_CS_B2 /= next_CFG_CS_B2) THEN 
				STD.TEXTIO.write(TX_LOC,string'("Error at time="));
				STD.TEXTIO.write(TX_LOC, TX_TIME);
				STD.TEXTIO.write(TX_LOC,string'("us CFG_CS_B2="));
				IEEE.STD_LOGIC_TEXTIO.write(TX_LOC, CFG_CS_B2);
				STD.TEXTIO.write(TX_LOC, string'(", Expected = "));
				IEEE.STD_LOGIC_TEXTIO.write(TX_LOC, next_CFG_CS_B2);
				STD.TEXTIO.write(TX_LOC, string'(" "));
				TX_STR(TX_LOC.all'range) := TX_LOC.all;
				STD.TEXTIO.writeline(results, TX_LOC);
				STD.TEXTIO.Deallocate(TX_LOC);
				ASSERT (FALSE) REPORT TX_STR SEVERITY ERROR;
				TX_ERROR := TX_ERROR + 1;
			END IF;
		END;

		PROCEDURE CHECK_CFG_CS_B3(
			next_CFG_CS_B3 : std_logic;
			TX_TIME : INTEGER
		) IS
			VARIABLE TX_STR : String(1 to 4096);
			VARIABLE TX_LOC : LINE;
		BEGIN
			-- If compiler error ("/=" is ambiguous) occurs in the next line of code
			-- change compiler settings to use explicit declarations only
			IF (CFG_CS_B3 /= next_CFG_CS_B3) THEN 
				STD.TEXTIO.write(TX_LOC,string'("Error at time="));
				STD.TEXTIO.write(TX_LOC, TX_TIME);
				STD.TEXTIO.write(TX_LOC,string'("us CFG_CS_B3="));
				IEEE.STD_LOGIC_TEXTIO.write(TX_LOC, CFG_CS_B3);
				STD.TEXTIO.write(TX_LOC, string'(", Expected = "));
				IEEE.STD_LOGIC_TEXTIO.write(TX_LOC, next_CFG_CS_B3);
				STD.TEXTIO.write(TX_LOC, string'(" "));
				TX_STR(TX_LOC.all'range) := TX_LOC.all;
				STD.TEXTIO.writeline(results, TX_LOC);
				STD.TEXTIO.Deallocate(TX_LOC);
				ASSERT (FALSE) REPORT TX_STR SEVERITY ERROR;
				TX_ERROR := TX_ERROR + 1;
			END IF;
		END;

		PROCEDURE CHECK_CFG_RDWR_B(
			next_CFG_RDWR_B : std_logic;
			TX_TIME : INTEGER
		) IS
			VARIABLE TX_STR : String(1 to 4096);
			VARIABLE TX_LOC : LINE;
		BEGIN
			-- If compiler error ("/=" is ambiguous) occurs in the next line of code
			-- change compiler settings to use explicit declarations only
			IF (CFG_RDWR_B /= next_CFG_RDWR_B) THEN 
				STD.TEXTIO.write(TX_LOC,string'("Error at time="));
				STD.TEXTIO.write(TX_LOC, TX_TIME);
				STD.TEXTIO.write(TX_LOC,string'("us CFG_RDWR_B="));
				IEEE.STD_LOGIC_TEXTIO.write(TX_LOC, CFG_RDWR_B);
				STD.TEXTIO.write(TX_LOC, string'(", Expected = "));
				IEEE.STD_LOGIC_TEXTIO.write(TX_LOC, next_CFG_RDWR_B);
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
		rst_n <= transport '0';
		cmd_reg <= transport std_logic_vector'("000000000"); --0
		data_reg <= transport std_logic_vector'("00000000000000000000000000000000"); --0
		-- --------------------
		WAIT FOR 300 us; -- Time=300 us
		rst_n <= transport '1';
		-- --------------------
		WAIT FOR 500 us; -- Time=800 us
		cmd_reg <= transport std_logic_vector'("011110001"); --F1
		-- --------------------
		WAIT FOR 400 us; -- Time=1200 us
		cmd_reg <= transport std_logic_vector'("011100001"); --E1
		-- --------------------
		WAIT FOR 400 us; -- Time=1600 us
		cmd_reg <= transport std_logic_vector'("011110001"); --F1
		-- --------------------
		WAIT FOR 800 us; -- Time=2400 us
		data_reg <= transport std_logic_vector'("10000000100000001000000011111111"); --808080FF
		-- --------------------
		WAIT FOR 700 us; -- Time=3100 us
		cmd_reg <= transport std_logic_vector'("111110001"); --1F1
		-- --------------------
		WAIT FOR 3355 us; -- Time=6455 us
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

CONFIGURATION pfpga_config_cfg OF sim IS
	FOR testbench_arch
	END FOR;
END pfpga_config_cfg;
