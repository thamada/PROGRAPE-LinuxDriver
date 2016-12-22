-- C:\CYGWIN\HOME\ADMINISTRATOR\FKIT\PCI64\PROJ
-- VHDL Test Bench created by
-- HDL Bencher 6.1i
-- Wed Dec 29 19:47:04 2004
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

ENTITY sim_writecomb_check IS
END sim_writecomb_check;

ARCHITECTURE testbench_arch OF sim_writecomb_check IS
-- If you get a compiler error on the following line,
-- from the menu do Options->Configuration select VHDL 87
FILE RESULTS: TEXT OPEN WRITE_MODE IS "results.txt";
	COMPONENT writecomb_check
		PORT (
			MEM_WEHA : In  std_logic;
			MEM_WELA : In  std_logic;
			IS_ERR : Out  std_logic_vector (1 DOWNTO 0);
			RST : In  std_logic;
			CLK : In  std_logic
		);
	END COMPONENT;

	SIGNAL MEM_WEHA : std_logic;
	SIGNAL MEM_WELA : std_logic;
	SIGNAL IS_ERR : std_logic_vector (1 DOWNTO 0);
	SIGNAL RST : std_logic;
	SIGNAL CLK : std_logic;

BEGIN
	UUT : writecomb_check
	PORT MAP (
		MEM_WEHA => MEM_WEHA,
		MEM_WELA => MEM_WELA,
		IS_ERR => IS_ERR,
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

		PROCEDURE CHECK_IS_ERR(
			next_IS_ERR : std_logic_vector (1 DOWNTO 0);
			TX_TIME : INTEGER
		) IS
			VARIABLE TX_STR : String(1 to 4096);
			VARIABLE TX_LOC : LINE;
		BEGIN
			-- If compiler error ("/=" is ambiguous) occurs in the next line of code
			-- change compiler settings to use explicit declarations only
			IF (IS_ERR /= next_IS_ERR) THEN 
				STD.TEXTIO.write(TX_LOC,string'("Error at time="));
				STD.TEXTIO.write(TX_LOC, TX_TIME);
				STD.TEXTIO.write(TX_LOC,string'("ns IS_ERR="));
				IEEE.STD_LOGIC_TEXTIO.write(TX_LOC, IS_ERR);
				STD.TEXTIO.write(TX_LOC, string'(", Expected = "));
				IEEE.STD_LOGIC_TEXTIO.write(TX_LOC, next_IS_ERR);
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
		MEM_WEHA <= transport '0';
		MEM_WELA <= transport '0';
		-- --------------------
		WAIT FOR 200 ns; -- Time=200 ns
		RST <= transport '0';
		-- --------------------
		WAIT FOR 500 ns; -- Time=700 ns
		MEM_WEHA <= transport '0';
		MEM_WELA <= transport '0';
		-- --------------------
		WAIT FOR 200 ns; -- Time=900 ns
		RST <= transport '1';
		-- --------------------
		WAIT FOR 100 ns; -- Time=1000 ns
		RST <= transport '0';
		-- --------------------
		WAIT FOR 1900 ns; -- Time=2900 ns
		MEM_WEHA <= transport '1';
		MEM_WELA <= transport '1';
		-- --------------------
		WAIT FOR 500 ns; -- Time=3400 ns
		MEM_WEHA <= transport '0';
		MEM_WELA <= transport '0';
		-- --------------------
		WAIT FOR 1100 ns; -- Time=4500 ns
		MEM_WEHA <= transport '1';
		MEM_WELA <= transport '1';
		-- --------------------
		WAIT FOR 200 ns; -- Time=4700 ns
		MEM_WEHA <= transport '0';
		MEM_WELA <= transport '0';
		-- --------------------
		WAIT FOR 1300 ns; -- Time=6000 ns
		MEM_WELA <= transport '1';
		-- --------------------
		WAIT FOR 100 ns; -- Time=6100 ns
		MEM_WELA <= transport '0';
		-- --------------------
		WAIT FOR 100 ns; -- Time=6200 ns
		MEM_WEHA <= transport '0';
		-- --------------------
		WAIT FOR 300 ns; -- Time=6500 ns
		MEM_WEHA <= transport '1';
		-- --------------------
		WAIT FOR 100 ns; -- Time=6600 ns
		MEM_WEHA <= transport '0';
		-- --------------------
		WAIT FOR 1300 ns; -- Time=7900 ns
		MEM_WELA <= transport '1';
		-- --------------------
		WAIT FOR 100 ns; -- Time=8000 ns
		MEM_WEHA <= transport '1';
		MEM_WELA <= transport '0';
		-- --------------------
		WAIT FOR 100 ns; -- Time=8100 ns
		MEM_WEHA <= transport '0';
		MEM_WELA <= transport '1';
		-- --------------------
		WAIT FOR 100 ns; -- Time=8200 ns
		MEM_WEHA <= transport '1';
		MEM_WELA <= transport '0';
		-- --------------------
		WAIT FOR 100 ns; -- Time=8300 ns
		MEM_WEHA <= transport '0';
		-- --------------------
		WAIT FOR 2005 ns; -- Time=10305 ns
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

CONFIGURATION writecomb_check_cfg OF sim_writecomb_check IS
	FOR testbench_arch
	END FOR;
END writecomb_check_cfg;
