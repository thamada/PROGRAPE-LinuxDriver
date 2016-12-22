-- PGR SOFTWARE LICENSE  ------------------------------------
-- 2006-05-11    <hamada@progrape.jp>
-- XXXXXXXXXXXXXXXXX. 
-------------------------------------------------------------



--
-- PGR: Pipeline-processors Generator for Reconfigurable Systems
-- Copyright(c) 2004 by Tsuyoshi Hamada & Naohito Nakasato.
-- All rights reserved.
-- Generated from 'list.pgpp'
-- NPIPE : 1
-- NVMP  : 1
-- Target Platform : TD-BD-BIOLER3
--                    - 64/66 PCI DMA : Enable
--                    - 100MHz Pipe   : Enable
library ieee;
use ieee.std_logic_1164.all;

entity pg_pipe is
  generic(JDATA_WIDTH : integer := 312;
          IDATA_WIDTH : integer := 64);
  port(
    p_jdata : in std_logic_vector(JDATA_WIDTH-1 downto 0);
    p_run : in std_logic;
    p_we :  in std_logic;
    p_adri : in std_logic_vector(11 downto 0);
    p_datai : in std_logic_vector(IDATA_WIDTH-1 downto 0);
    p_adro : in std_logic_vector(11 downto 0);
    p_datao : out std_logic_vector(IDATA_WIDTH-1 downto 0);
    p_runret : out std_logic;
    clk  : in std_logic;
    pclk : in std_logic;
    rst  : in std_logic
  );
end pg_pipe;

architecture std of pg_pipe is

  component pipe
    generic(JDATA_WIDTH : integer;
            IDATA_WIDTH : integer);
    port(
      p_jdata: in std_logic_vector(JDATA_WIDTH-1 downto 0);
      p_run : in std_logic;
      p_we : in std_logic;
      p_adri : in std_logic_vector(3 downto 0);
      p_adrivp : in std_logic_vector(3 downto 0);
      p_datai : in std_logic_vector(IDATA_WIDTH-1 downto 0);
      p_adro : in std_logic_vector(3 downto 0);
      p_adrovp : in std_logic_vector(3 downto 0);
      p_datao : out std_logic_vector(IDATA_WIDTH-1 downto 0);
      p_runret : out std_logic;
      rst,pclk,clk : in std_logic );
  end component;

  signal u_adri,u_adro: std_logic_vector(7 downto 0);
  signal adrivp,adrovp: std_logic_vector(3 downto 0);
  signal we,runret: std_logic_vector(1 downto 0);
  signal datao: std_logic_vector(63 downto 0);
  signal l_adro: std_logic_vector(3 downto 0);

begin

  u_adri <= p_adri(11 downto 4);

  u_adro <= p_adro(11 downto 4);
  l_adro <= p_adro(3 downto 0);

  process(u_adri,p_we) begin
    if(p_we = '1') then
     if(u_adri = "00000000" ) then
        we(0) <= '1';
      else
        we(0) <= '0';
      end if;
    else
      we(0) <= '0';
    end if;
  end process;

  with u_adri select
    adrivp <= "0000" when "00000000", 
              "0000" when others;

  with u_adro select
    adrovp <= "0000" when "00000000", 
              "0000" when others;

  forgen1: for i in 0 to 0 generate
    upipe: pipe GENERIC MAP(JDATA_WIDTH=>JDATA_WIDTH,
                            IDATA_WIDTH=>IDATA_WIDTH)
	      PORT MAP(p_jdata=>p_jdata, p_run=>p_run,
                 p_we=>we(i),p_adri=>p_adri(3 downto 0),p_adrivp=>adrivp,
	               p_datai=>p_datai,p_adro=>l_adro,p_adrovp=>adrovp, 
	               p_datao=>datao(IDATA_WIDTH*(i+1)-1 downto IDATA_WIDTH*i), p_runret=>runret(i), 
		       rst=>rst,pclk=>pclk,clk=>clk);
  end generate forgen1;

  p_runret <= runret(0);

  with u_adro select
    p_datao <= datao(IDATA_WIDTH-1 downto 0) when "00000000", 
               datao(IDATA_WIDTH-1 downto 0) when others;

end std;

library ieee;
use ieee.std_logic_1164.all;

entity pipe is
  generic(JDATA_WIDTH : integer := 312;
          IDATA_WIDTH : integer := 64);
port(p_jdata : in std_logic_vector(JDATA_WIDTH-1 downto 0);
     p_run : in std_logic;
     p_we :  in std_logic;
     p_adri : in std_logic_vector(3 downto 0);
     p_adrivp : in std_logic_vector(3 downto 0);
     p_datai : in std_logic_vector(IDATA_WIDTH-1 downto 0);
     p_adro : in std_logic_vector(3 downto 0);
     p_adrovp : in std_logic_vector(3 downto 0);
     p_datao : out std_logic_vector(IDATA_WIDTH-1 downto 0);
     p_runret : out std_logic;
     rst,pclk,clk : in std_logic);
end pipe;

architecture std of pipe is

  component pg_float_sub_26_16_4_6
    port( clk : in std_logic;
          x : in std_logic_vector(25 downto 0);
          y : in std_logic_vector(25 downto 0);
          z : out std_logic_vector(25 downto 0));
  end component;

  component pg_float_mult_26_16_2_6
    port( clk : in std_logic;
          x : in std_logic_vector(25 downto 0);
          y : in std_logic_vector(25 downto 0);
          z : out std_logic_vector(25 downto 0));
  end component;

  component pg_float_unsigned_add_26_16_4_6
    port( clk : in std_logic;
          x : in std_logic_vector(25 downto 0);
          y : in std_logic_vector(25 downto 0);
          z : out std_logic_vector(25 downto 0));
  end component;

  component pg_float_sqrt_26_16_3
    port( clk : in std_logic;
          x : in std_logic_vector(25 downto 0);
          z : out std_logic_vector(25 downto 0));
  end component;

  component pg_float_recipro_26_16_2
    port( clk : in std_logic;
          x : in std_logic_vector(25 downto 0);
          z : out std_logic_vector(25 downto 0));
  end component;

  component pg_bits_delay_26_16
    port( x : in std_logic_vector(25 downto 0);
	        y : out std_logic_vector(25 downto 0);
	       clk: in std_logic);
  end component;

  component pg_bits_regifile_26
    port( clk,run : in std_logic;
          x : in std_logic_vector(25 downto 0);
          z : out std_logic_vector(25 downto 0));
  end component;

  component pg_float_expadd_31_26_16_1
    port( clk : in std_logic;
          x : in std_logic_vector(25 downto 0);
          z : out std_logic_vector(25 downto 0));
  end component;

  component pg_float_fixaccum_26_16_57_64_2_0
    port (x: in std_logic_vector(25 downto 0);
          z: out std_logic_vector(63 downto 0);
          run: in std_logic;
          clk: in std_logic);
  end component;

  component pg_float_expadd_1_26_16_1
    port( clk : in std_logic;
          x : in std_logic_vector(25 downto 0);
          z : out std_logic_vector(25 downto 0));
  end component;

  component pg_pdelay_26_4
    port( x : in std_logic_vector(25 downto 0);
	        y : out std_logic_vector(25 downto 0);
	       clk: in std_logic);
  end component;

  component pg_pdelay_26_3
    port( x : in std_logic_vector(25 downto 0);
	        y : out std_logic_vector(25 downto 0);
	       clk: in std_logic);
  end component;

  component pg_pdelay_26_5
    port( x : in std_logic_vector(25 downto 0);
	        y : out std_logic_vector(25 downto 0);
	       clk: in std_logic);
  end component;

  component pg_pdelay_26_23
    port( x : in std_logic_vector(25 downto 0);
	        y : out std_logic_vector(25 downto 0);
	       clk: in std_logic);
  end component;

  component pg_pdelay_26_11
    port( x : in std_logic_vector(25 downto 0);
	        y : out std_logic_vector(25 downto 0);
	       clk: in std_logic);
  end component;

  component pg_pdelay_26_24
    port( x : in std_logic_vector(25 downto 0);
	        y : out std_logic_vector(25 downto 0);
	       clk: in std_logic);
  end component;

  component pg_pdelay_26_1
    port( x : in std_logic_vector(25 downto 0);
	        y : out std_logic_vector(25 downto 0);
	       clk: in std_logic);
  end component;

  component pg_pdelay_26_6
    port( x : in std_logic_vector(25 downto 0);
	        y : out std_logic_vector(25 downto 0);
	       clk: in std_logic);
  end component;

  signal xj_0: std_logic_vector(25 downto 0);
  signal xi_0: std_logic_vector(25 downto 0);
  signal xj_1: std_logic_vector(25 downto 0);
  signal xi_1: std_logic_vector(25 downto 0);
  signal xj_2: std_logic_vector(25 downto 0);
  signal xi_2: std_logic_vector(25 downto 0);
  signal dx_0: std_logic_vector(25 downto 0);
  signal dx_1: std_logic_vector(25 downto 0);
  signal dx_2: std_logic_vector(25 downto 0);
  signal dx2_0: std_logic_vector(25 downto 0);
  signal dx2_1: std_logic_vector(25 downto 0);
  signal dx2_2r: std_logic_vector(25 downto 0);
  signal x2y2: std_logic_vector(25 downto 0);
  signal r2: std_logic_vector(25 downto 0);
  signal r2r: std_logic_vector(25 downto 0);
  signal r1: std_logic_vector(25 downto 0);
  signal r3: std_logic_vector(25 downto 0);
  signal r2r1: std_logic_vector(25 downto 0);
  signal r5: std_logic_vector(25 downto 0);
  signal r5i: std_logic_vector(25 downto 0);
  signal mjr: std_logic_vector(25 downto 0);
  signal mr5i: std_logic_vector(25 downto 0);
  signal r2r2: std_logic_vector(25 downto 0);
  signal mj: std_logic_vector(25 downto 0);
  signal mjd: std_logic_vector(25 downto 0);
  signal rx: std_logic_vector(25 downto 0);
  signal mf: std_logic_vector(25 downto 0);
  signal fs: std_logic_vector(25 downto 0);
  signal dx_0r: std_logic_vector(25 downto 0);
  signal dx_1r: std_logic_vector(25 downto 0);
  signal dx_2r: std_logic_vector(25 downto 0);
  signal fx_0: std_logic_vector(25 downto 0);
  signal sx_0: std_logic_vector(63 downto 0);
  signal fx_1: std_logic_vector(25 downto 0);
  signal sx_1: std_logic_vector(63 downto 0);
  signal fx_2: std_logic_vector(25 downto 0);
  signal sx_2: std_logic_vector(63 downto 0);
  signal vj_0: std_logic_vector(25 downto 0);
  signal vi_0: std_logic_vector(25 downto 0);
  signal vj_1: std_logic_vector(25 downto 0);
  signal vi_1: std_logic_vector(25 downto 0);
  signal vj_2: std_logic_vector(25 downto 0);
  signal vi_2: std_logic_vector(25 downto 0);
  signal dv_0r: std_logic_vector(25 downto 0);
  signal dv_1r: std_logic_vector(25 downto 0);
  signal dv_2r: std_logic_vector(25 downto 0);
  signal dv_0: std_logic_vector(25 downto 0);
  signal dv_1: std_logic_vector(25 downto 0);
  signal dv_2: std_logic_vector(25 downto 0);
  signal xv_0: std_logic_vector(25 downto 0);
  signal xv_1: std_logic_vector(25 downto 0);
  signal xv_2r: std_logic_vector(25 downto 0);
  signal xv1: std_logic_vector(25 downto 0);
  signal xv2: std_logic_vector(25 downto 0);
  signal xv2x2: std_logic_vector(25 downto 0);
  signal xv2r: std_logic_vector(25 downto 0);
  signal xv2x3r: std_logic_vector(25 downto 0);
  signal jk2a: std_logic_vector(25 downto 0);
  signal jk2s: std_logic_vector(25 downto 0);
  signal dx_0r1: std_logic_vector(25 downto 0);
  signal dx_1r1: std_logic_vector(25 downto 0);
  signal dx_2r1: std_logic_vector(25 downto 0);
  signal jk1_0: std_logic_vector(25 downto 0);
  signal jk2_0: std_logic_vector(25 downto 0);
  signal jk1_1: std_logic_vector(25 downto 0);
  signal jk2_1: std_logic_vector(25 downto 0);
  signal jk1_2: std_logic_vector(25 downto 0);
  signal jk2_2: std_logic_vector(25 downto 0);
  signal jk0_0: std_logic_vector(25 downto 0);
  signal tx_0: std_logic_vector(63 downto 0);
  signal jk0_1: std_logic_vector(25 downto 0);
  signal tx_1: std_logic_vector(63 downto 0);
  signal jk0_2: std_logic_vector(25 downto 0);
  signal tx_2: std_logic_vector(63 downto 0);
  signal dx2_2: std_logic_vector(25 downto 0);
  signal xv_2: std_logic_vector(25 downto 0);
  signal xv2x3: std_logic_vector(25 downto 0);
-- pg_rundelay(36)
  signal run: std_logic_vector(40 downto 0);
  signal ireg_xi_0: std_logic_vector(25 downto 0);
  signal ireg_xi_1: std_logic_vector(25 downto 0);
  signal ireg_xi_2: std_logic_vector(25 downto 0);
  signal ireg_vi_0: std_logic_vector(25 downto 0);
  signal ireg_vi_1: std_logic_vector(25 downto 0);
  signal ireg_vi_2: std_logic_vector(25 downto 0);

  constant zero : std_logic_vector(63 downto 0):=(others=>'0');

begin

  xj_0(25 downto 0) <= p_jdata(25 downto 0);
  xj_1(25 downto 0) <= p_jdata(51 downto 26);
  xj_2(25 downto 0) <= p_jdata(77 downto 52);
  vj_0(25 downto 0) <= p_jdata(103 downto 78);
  vj_1(25 downto 0) <= p_jdata(129 downto 104);
  vj_2(25 downto 0) <= p_jdata(155 downto 130);
  mj(25 downto 0) <= p_jdata(181 downto 156);

  process(clk) begin
    if(clk'event and clk='1') then
      if(p_we ='1') then
        if(p_adri = "0000") then
          ireg_xi_0 <= p_datai(25 downto 0);
          ireg_xi_1 <= p_datai(57 downto 32);
        elsif(p_adri = "0001") then
          ireg_xi_2 <= p_datai(25 downto 0);
          ireg_vi_0 <= p_datai(57 downto 32);
        elsif(p_adri = "0010") then
          ireg_vi_1 <= p_datai(25 downto 0);
          ireg_vi_2 <= p_datai(57 downto 32);
        end if;
      end if;
    end if;
  end process;

  process(pclk) begin
    if(pclk'event and pclk='1') then
      xi_0 <= ireg_xi_0;
      xi_1 <= ireg_xi_1;
      xi_2 <= ireg_xi_2;
      vi_0 <= ireg_vi_0;
      vi_1 <= ireg_vi_1;
      vi_2 <= ireg_vi_2;
    end if;
  end process;

  u0: pg_float_sub_26_16_4_6 port map(x=>xj_0,y=>xi_0,z=>dx_0,clk=>pclk);

  u1: pg_float_sub_26_16_4_6 port map(x=>xj_1,y=>xi_1,z=>dx_1,clk=>pclk);

  u2: pg_float_sub_26_16_4_6 port map(x=>xj_2,y=>xi_2,z=>dx_2,clk=>pclk);

  u3: pg_float_mult_26_16_2_6 port map(x=>dx_0,y=>dx_0,z=>dx2_0,clk=>pclk);

  u4: pg_float_mult_26_16_2_6 port map(x=>dx_1,y=>dx_1,z=>dx2_1,clk=>pclk);

  u5: pg_float_mult_26_16_2_6 port map(x=>dx_2,y=>dx_2,z=>dx2_2,clk=>pclk);

  u6: pg_float_unsigned_add_26_16_4_6 port map(x=>dx2_0,y=>dx2_1,z=>x2y2,clk=>pclk);

  u7: pg_float_unsigned_add_26_16_4_6 port map(x=>dx2_2r,y=>x2y2,z=>r2,clk=>pclk);

  u8: pg_float_sqrt_26_16_3 port map(x=>r2,z=>r1,clk=>pclk);

  u9: pg_float_mult_26_16_2_6 port map(x=>r2r,y=>r1,z=>r3,clk=>pclk);

  u10: pg_float_mult_26_16_2_6 port map(x=>r3,y=>r2r1,z=>r5,clk=>pclk);

  u11: pg_float_recipro_26_16_2 port map(x=>r5,z=>r5i,clk=>pclk);

  u12: pg_float_mult_26_16_2_6 port map(x=>r5i,y=>mjr,z=>mr5i,clk=>pclk);

  u13: pg_float_mult_26_16_2_6 port map(x=>mr5i,y=>r2r2,z=>mf,clk=>pclk);

  u14: pg_bits_delay_26_16 port map(x=>mj,y=>mjd,clk=>pclk);

  u15: pg_bits_regifile_26 port map(x=>mjd, z=>rx, clk=>pclk, run=>run(15));

  u16: pg_float_expadd_31_26_16_1 port map(x=>mf,z=>fs,clk=>pclk);

  u17: pg_float_mult_26_16_2_6 port map(x=>fs,y=>dx_0r,z=>fx_0,clk=>pclk);

  u18: pg_float_mult_26_16_2_6 port map(x=>fs,y=>dx_1r,z=>fx_1,clk=>pclk);

  u19: pg_float_mult_26_16_2_6 port map(x=>fs,y=>dx_2r,z=>fx_2,clk=>pclk);

  u20: pg_float_fixaccum_26_16_57_64_2_0 port map(x=>fx_0, z=>sx_0, clk=>pclk,run=>run(29));

  u21: pg_float_fixaccum_26_16_57_64_2_0 port map(x=>fx_1, z=>sx_1, clk=>pclk,run=>run(29));

  u22: pg_float_fixaccum_26_16_57_64_2_0 port map(x=>fx_2, z=>sx_2, clk=>pclk,run=>run(29));

  u23: pg_float_sub_26_16_4_6 port map(x=>vj_0,y=>vi_0,z=>dv_0,clk=>pclk);

  u24: pg_float_sub_26_16_4_6 port map(x=>vj_1,y=>vi_1,z=>dv_1,clk=>pclk);

  u25: pg_float_sub_26_16_4_6 port map(x=>vj_2,y=>vi_2,z=>dv_2,clk=>pclk);

  u26: pg_float_mult_26_16_2_6 port map(x=>fs,y=>dv_0r,z=>jk1_0,clk=>pclk);

  u27: pg_float_mult_26_16_2_6 port map(x=>fs,y=>dv_1r,z=>jk1_1,clk=>pclk);

  u28: pg_float_mult_26_16_2_6 port map(x=>fs,y=>dv_2r,z=>jk1_2,clk=>pclk);

  u29: pg_float_mult_26_16_2_6 port map(x=>dx_0,y=>dv_0,z=>xv_0,clk=>pclk);

  u30: pg_float_mult_26_16_2_6 port map(x=>dx_1,y=>dv_1,z=>xv_1,clk=>pclk);

  u31: pg_float_mult_26_16_2_6 port map(x=>dx_2,y=>dv_2,z=>xv_2,clk=>pclk);

  u32: pg_float_unsigned_add_26_16_4_6 port map(x=>xv_0,y=>xv_1,z=>xv1,clk=>pclk);

  u33: pg_float_unsigned_add_26_16_4_6 port map(x=>xv_2r,y=>xv1,z=>xv2,clk=>pclk);

  u34: pg_float_expadd_1_26_16_1 port map(x=>xv2,z=>xv2x2,clk=>pclk);

  u35: pg_float_unsigned_add_26_16_4_6 port map(x=>xv2x2,y=>xv2r,z=>xv2x3,clk=>pclk);

  u36: pg_float_mult_26_16_2_6 port map(x=>mr5i,y=>xv2x3r,z=>jk2a,clk=>pclk);

  u37: pg_float_expadd_31_26_16_1 port map(x=>jk2a,z=>jk2s,clk=>pclk);

  u38: pg_float_mult_26_16_2_6 port map(x=>jk2s,y=>dx_0r1,z=>jk2_0,clk=>pclk);

  u39: pg_float_mult_26_16_2_6 port map(x=>jk2s,y=>dx_1r1,z=>jk2_1,clk=>pclk);

  u40: pg_float_mult_26_16_2_6 port map(x=>jk2s,y=>dx_2r1,z=>jk2_2,clk=>pclk);

  u41: pg_float_sub_26_16_4_6 port map(x=>jk1_0,y=>jk2_0,z=>jk0_0,clk=>pclk);

  u42: pg_float_sub_26_16_4_6 port map(x=>jk1_1,y=>jk2_1,z=>jk0_1,clk=>pclk);

  u43: pg_float_sub_26_16_4_6 port map(x=>jk1_2,y=>jk2_2,z=>jk0_2,clk=>pclk);

  u44: pg_float_fixaccum_26_16_57_64_2_0 port map(x=>jk0_0, z=>tx_0, clk=>pclk,run=>run(33));

  u45: pg_float_fixaccum_26_16_57_64_2_0 port map(x=>jk0_1, z=>tx_1, clk=>pclk,run=>run(33));

  u46: pg_float_fixaccum_26_16_57_64_2_0 port map(x=>jk0_2, z=>tx_2, clk=>pclk,run=>run(33));

  u47: pg_pdelay_26_4 port map(x=>dx2_2,y=>dx2_2r,clk=>pclk);

  u48: pg_pdelay_26_3 port map(x=>r2,y=>r2r,clk=>pclk);

  u49: pg_pdelay_26_5 port map(x=>r2,y=>r2r1,clk=>pclk);

  u50: pg_pdelay_26_23 port map(x=>mj,y=>mjr,clk=>pclk);

  u51: pg_pdelay_26_11 port map(x=>r2,y=>r2r2,clk=>pclk);

  u52: pg_pdelay_26_24 port map(x=>dv_1,y=>dv_1r,clk=>pclk);

  u53: pg_pdelay_26_24 port map(x=>dv_0,y=>dv_0r,clk=>pclk);

  u54: pg_pdelay_26_4 port map(x=>xv_2,y=>xv_2r,clk=>pclk);

  u55: pg_pdelay_26_24 port map(x=>dv_2,y=>dv_2r,clk=>pclk);

  u56: pg_pdelay_26_24 port map(x=>dx_0,y=>dx_0r,clk=>pclk);

  u57: pg_pdelay_26_24 port map(x=>dx_1,y=>dx_1r,clk=>pclk);

  u58: pg_pdelay_26_24 port map(x=>dx_2,y=>dx_2r,clk=>pclk);

  u59: pg_pdelay_26_1 port map(x=>xv2,y=>xv2r,clk=>pclk);

  u60: pg_pdelay_26_6 port map(x=>xv2x3,y=>xv2x3r,clk=>pclk);

  u61: pg_pdelay_26_24 port map(x=>dx_1,y=>dx_1r1,clk=>pclk);

  u62: pg_pdelay_26_24 port map(x=>dx_2,y=>dx_2r1,clk=>pclk);

  u63: pg_pdelay_26_24 port map(x=>dx_0,y=>dx_0r1,clk=>pclk);

  process(pclk) begin
    if(pclk'event and pclk='1') then
      run(0) <= p_run;
      for i in 0 to 39 loop
        run(i+1) <= run(i);
      end loop;
    end if;
  end process;

  process(pclk) begin
    if(pclk'event and pclk='1') then
      p_runret <= run(40) or run(39) or run(38) or run(37);
    end if;
  end process;

  process(clk) begin
    if(clk'event and clk='1') then
      case (p_adro) is
      when "0000" => 
        p_datao <=  zero(63 downto 26) & rx;
      when "0001" => 
        p_datao <=  sx_0;
      when "0010" => 
        p_datao <=  sx_1;
      when "0011" => 
        p_datao <=  sx_2;
      when "0100" => 
        p_datao <=  tx_0;
      when "0101" => 
        p_datao <=  tx_1;
      when others => 
        p_datao <=  tx_2;
      end case;
    end if;
  end process;

end std;

