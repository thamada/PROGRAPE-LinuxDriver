-- PGR SOFTWARE LICENSE  ------------------------------------
-- 2006-05-11    <hamada@progrape.jp>
-- XXXXXXXXXXXXXXXXX. 
-------------------------------------------------------------



-- PGR Floating-Point Sub
-- by N.N tests (2004/09/16)
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity pg_float_sub_26_16_4_6 is
  port( x : in std_logic_vector(25 downto 0);
        y : in std_logic_vector(25 downto 0);
        z : out std_logic_vector(25 downto 0);
        clk : in std_logic);
end pg_float_sub_26_16_4_6;
architecture rtl of pg_float_sub_26_16_4_6 is
  component pgsub_float_add_26_16_6_uadd_3
    port( x : in std_logic_vector(25 downto 0);
          y : in std_logic_vector(25 downto 0);
          z : out std_logic_vector(25 downto 0);
        clk : in std_logic);
  end component;

  component pgsub_float_add_26_16_6_usub_3
    port( x : in std_logic_vector(25 downto 0);
          y : in std_logic_vector(25 downto 0);
          z : out std_logic_vector(25 downto 0);
        clk : in std_logic);
  end component;

signal z0  : std_logic_vector(25 downto 0);
signal signx, signy : std_logic;
signal uy1  : std_logic_vector(25 downto 0);  -- nbit_exp-1
signal uy2  : std_logic_vector(25 downto 0);  -- nbit_exp-1
signal yin  : std_logic_vector(25 downto 0);  -- nbit_exp-1
signal zadd : std_logic_vector(25 downto 0);  -- nbit_exp-1
signal zsub : std_logic_vector(25 downto 0);  -- nbit_exp-1
signal sign_flag0 : std_logic;
signal sign_flag1 : std_logic;
signal sign_flag2 : std_logic;
signal sign_flag3 : std_logic;
signal sign_flag4 : std_logic;
signal sign_flag5 : std_logic;
signal sign_flag6 : std_logic;
signal sign_flag7 : std_logic;
signal sign_flag8 : std_logic;
signal sign_flag9 : std_logic;
signal sign_flag  : std_logic;
begin
-- sign bit
  signx <= x(25);                  -- nbit_float-1
  signy <= y(25);                  -- nbit_float-1
  sign_flag0 <= signx xor signy;

-- absolute value
  uy1 <= '0' & y(24 downto 0);
  uy2 <= '1' & y(24 downto 0);

  with signx select
    yin <= uy1 when '0',    -- signx = 0;
           uy2 when others; -- signx = 1;

  u1 : pgsub_float_add_26_16_6_usub_3 port map(
    x => x,
    y => y,
    z => zsub,
    clk => clk);

  u2 : pgsub_float_add_26_16_6_uadd_3 port map(
    x => x,
    y => yin,
    z => zadd,
    clk => clk);

  process(clk) begin
    if(clk'event and clk='1') then
      sign_flag1 <= sign_flag0;
    end if;
  end process;

  process(clk) begin
    if(clk'event and clk='1') then
      sign_flag2 <= sign_flag1;
    end if;
  end process;

  process(clk) begin
    if(clk'event and clk='1') then
      sign_flag <= sign_flag2;
    end if;
  end process;

  with sign_flag select
    z0 <= zsub when '0',    -- signx =  signy
          zadd when others; -- signx != signy

  -- PIPELINE LAST ----------------------------------------------------------------
  process(clk) begin
    if(clk'event and clk='1') then
      z <= z0;
    end if;
  end process;
end rtl;
-- Floating-Point Unsigned Adder
-- For Signed Adder/Subtoractor
-- by Tsuyoshi Hamada (2004/10/02)
-- P: 1[-], 2[O], 3[-], 4[O], 5[O], 6[-], 7[-], 8[-], 9[-], 
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
entity pgsub_float_add_26_16_6_uadd_3 is
  port( x : in std_logic_vector(25 downto 0);
        y : in std_logic_vector(25 downto 0);
        z : out std_logic_vector(25 downto 0);
        clk : in std_logic);
end pgsub_float_add_26_16_6_uadd_3;
architecture rtl of pgsub_float_add_26_16_6_uadd_3 is
  component pg_fuadd_26_16_swap_1
    port ( nonzx, nonzy : in std_logic;
           expx,expy : in std_logic_vector(7 downto 0);  -- nbit_exp-1
           manx,many : in std_logic_vector(15 downto 0);  -- nbit_man-1
           expdif : out std_logic_vector(7 downto 0);    -- nbit_exp-1
           expz : out std_logic_vector(7 downto 0);      -- nbit_exp-1
           mana,manb : out std_logic_vector(15 downto 0); -- nbit_man-1
           nontobi : out std_logic;
           clk : in std_logic);
  end component;

  component pg_fuadd_26_16_shift_0
    port ( x : in std_logic_vector(16 downto 0);  -- nbit_man
           c : in std_logic_vector(7 downto 0);  -- nbit_exp-1
           z : out std_logic_vector(33 downto 0); -- 2*(nbit_man+1)-1
           clk : in std_logic );
  end component;

  component pg_fuadd_26_16_guard
    port ( x : in std_logic_vector(16 downto 0);  -- nbit_man
           c : in std_logic_vector(7 downto 0);  -- nbit_exp-1
           flag : out std_logic);
  end component;

  component pg_fuadd_26_16_adjust_0
    port ( x : in std_logic_vector(33 downto 0);  -- 2*(nbit_man+1)-1
           c : in std_logic_vector(7 downto 0);  -- nbit_exp-1
           z : out std_logic_vector(18 downto 0); -- nbit_man+2
           clk : in std_logic);
  end component;

  component pg_float_rbit_mode6
    port ( Fbit : in std_logic;
           Ulp  : in std_logic;
           Sbit : in std_logic;
           Gbit : in std_logic;
           man_inc : out std_logic);
  end component;

  component pg_float_round_26_16 is
    port ( exp  : in std_logic_vector(7 downto 0);   -- nbit_exp-1
           man  : in std_logic_vector(15 downto 0);   -- nbit_man-1
           man_inc : in std_logic;
           expr : out std_logic_vector(7 downto 0);  -- nbit_exp-1
           manr : out std_logic_vector(15 downto 0)); -- nbit_man-1
  end component;
signal nonzx,nonzy : std_logic;
signal expx,expy : std_logic_vector(7 downto 0);  -- nbit_exp-1
signal manx,many : std_logic_vector(15 downto 0);  -- nbit_man-1
signal signz0,signz1,signz2,signz3,signz4,signz5,signz6,signz7,signz8 : std_logic;
signal nonzz0,nonzz1,nonzz2,nonzz3,nonzz4,nonzz5,nonzz6,nonzz7,nonzz8 : std_logic;
signal expdif0,expdif1,expdif2 : std_logic_vector(7 downto 0);  -- nbit_exp-1
signal expz0,expz1,expz2,expz3,expz3r,expz4,expz5,expz6,expz7,expz8,expz9 : std_logic_vector(7 downto 0);  -- nbit_exp-1
signal mana0,mana1,mana2,mana3,mana4 : std_logic_vector(15 downto 0);  -- nbit_man-1
signal manb0,manb1 : std_logic_vector(15 downto 0);  -- nbit_man-1
signal nontobi0,nontobi1,nontobi2,nontobi3,nontobi4,nontobi5 : std_logic;
signal imana : std_logic_vector(16 downto 0);  -- nbit_man
signal mash,madd0,madd1 : std_logic_vector(33 downto 0);  -- 2*(nbit_man+1)-1
signal manz0,manz1 : std_logic_vector(18 downto 0);  -- nbit_man+2
signal manz2,manz3,manz4,manz5,manz6,manz7 : std_logic_vector(15 downto 0);  -- nbit_man-1
signal Gbit0,Gbit1,Gbit2,Gbit3,Gbit4 : std_logic;
signal Sbit0,Sbit1,Sbit2,Sbit3 : std_logic;
signal efsub : std_logic_vector(8 downto 0);  -- nbit_exp
signal eflag0,eflag1,eflag2 : std_logic;
signal mtr : std_logic_vector(16 downto 0);    -- nbit_man
signal ezinc : std_logic_vector(7 downto 0);  -- nbit_exp-1
signal i2b : std_logic_vector(1 downto 0);
signal is_tobi : std_logic;
signal man_inc0,man_inc1,man_inc2 : std_logic;
begin

  signz0 <= x(25);                 -- nbit_float-1
  nonzx  <= x(24);                 -- nbit_float-2
  nonzy  <= y(24);                 -- nbit_float-2
  expx <= x(23 downto 16);         -- (nbit_float-3), nbit_man
  expy <= y(23 downto 16);         -- (nbit_float-3), nbit_man
  manx <= x(15 downto 0);          -- (nbit_man-1)
  many <= y(15 downto 0);          -- (nbit_man-1)

  -- nonz evalv
  nonzz0 <= nonzx or nonzy;

  u1 : pg_fuadd_26_16_swap_1 port map(
    nonzx => nonzx,
    nonzy => nonzy,
    expx => expx,
    expy => expy,
    manx => manx,
    many => many,
    expdif => expdif0,
    expz => expz0,
    mana => mana0,
    manb => manb0,
    nontobi => nontobi0,
    clk => clk);

  -- PIPELINE 1 ----------------------------------------------------------------
--  process(clk) begin
--    if(clk'event and clk='1') then
      signz1 <= signz0;
      nonzz1 <= nonzz0;
--    end if;
--  end process;

  -- PIPELINE 2 ----------------------------------------------------------------
  process(clk) begin
    if(clk'event and clk='1') then
      signz2 <= signz1;
      nonzz2 <= nonzz1;
    end if;
  end process;

  imana <= '1' & mana0;
  u3 : pg_fuadd_26_16_shift_0 port map (
    x => imana,
    c => expdif0,
    z => mash,
    clk => clk);

  -- PIPELINE 3 ----------------------------------------------------------------
--  process(clk) begin
--    if(clk'event and clk='1') then
      signz3 <= signz2;
      nonzz3 <= nonzz2;
      nontobi1 <= nontobi0;
      expdif1 <= expdif0;
      expz1 <= expz0;
      mana1 <= mana0;
      manb1 <= manb0;
--    end if;
--  end process;

  madd0 <= mash + ("000000000000000001"&manb1);  -- 1 of nbit_man+2
  -- PIPELINE 4 ----------------------------------------------------------------
  process(clk) begin
    if(clk'event and clk='1') then
      signz4 <= signz3;
      nonzz4 <= nonzz3;
      nontobi2 <= nontobi1;
      expdif2 <= expdif1;
      madd1 <= madd0;
      expz2 <= expz1;
      mana2 <= mana1;
    end if;
  end process;

  u4 : pg_fuadd_26_16_guard port map(
    x => madd1(16 downto 0),  -- nbit_man
    c => expdif2,
    flag => Gbit0);

  u5 : pg_fuadd_26_16_adjust_0 port map (
    x => madd1,
    c => expdif2,
    z => manz0,
    clk => clk);

  efsub <= ('0' & expdif2) - "000010010";  -- 18 of nbit_exp+1
  eflag0 <= efsub(8); -- nbit_exp

  -- PIPELINE 5 ----------------------------------------------------------------
  process(clk) begin
    if(clk'event and clk='1') then
      signz5 <= signz4;
      nonzz5 <= nonzz4;
      nontobi3 <= nontobi2;
      Gbit1 <= Gbit0;
      eflag1 <= eflag0;
      manz1 <= manz0;
      expz3 <= expz2;
      mana3 <= mana2;
    end if;
  end process;

  Sbit0 <= manz1(0);
  mtr <= manz1(17 downto 1);    -- nbit_man+1
  i2b <= manz1(18 downto 17);   -- nbit_man+2, nbit_man+1
  ezinc <= expz3 + "00000001";  -- 1 of (nbit_exp) bit

  with i2b select 
    manz2 <= mtr(15 downto 0) when "01",  -- nbit_man-1
             mtr(16 downto 1) when others;  -- nbit_man

  with i2b select 
    expz4 <= expz3 when "01",
             ezinc when others;

  -- PIPELINE 6 ----------------------------------------------------------------
--  process(clk) begin
--    if(clk'event and clk='1') then
      signz6 <= signz5;
      nonzz6 <= nonzz5;
      nontobi4 <= nontobi3;
      eflag2 <= eflag1;
      Gbit2 <= Gbit1;
      Sbit1 <= Sbit0;
      manz3 <= manz2;
      expz5 <= expz4;
      expz3r <= expz3;
      mana4 <= mana3;
--    end if;
--  end process;

  is_tobi <= eflag2 nand nontobi4;
  with is_tobi select
    Gbit3 <= Gbit2 when '0',
               '1' when others;
  with is_tobi select
    Sbit2 <= Sbit1 when '0',
               '0' when others;
  with is_tobi select
    manz4 <= manz3 when '0',
             mana4 when others;
  with is_tobi select
    expz6 <= expz5 when '0',
             expz3r when others;

  -- PIPELINE 7 ----------------------------------------------------------------
--  process(clk) begin
--    if(clk'event and clk='1') then
      signz7 <= signz6;
      nonzz7 <= nonzz6;
      nontobi5 <= nontobi4;
      Gbit4 <= Gbit3;
      Sbit3 <= Sbit2;
      manz5 <= manz4;
      expz7 <= expz6;
--    end if;
--  end process;

  u6 : pg_float_rbit_mode6 port map (
    Fbit => signz7,
    Ulp  => manz5(0),
    Sbit => Sbit3,
    Gbit => Gbit4,
    man_inc => man_inc0);

  man_inc1 <= man_inc0 and nontobi5;

  -- PIPELINE 8 ----------------------------------------------------------------
--  process(clk) begin
--    if(clk'event and clk='1') then
      signz8 <= signz7;
      nonzz8 <= nonzz7;
      man_inc2 <= man_inc1;
      manz6 <= manz5;
      expz8 <= expz7;
--    end if;
--  end process;

  u7 : pg_float_round_26_16 port map (
    exp  => expz8,
    man  => manz6,
    man_inc => man_inc2,
    expr => expz9,
    manr => manz7);

  -- PIPELINE 9 ----------------------------------------------------------------
--  process(clk) begin
--    if(clk'event and clk='1') then
      z(25)           <= signz8;  -- nbit_float-1
      z(24)           <= nonzz8;  -- nbit_float-2
      z(23 downto 16) <= expz9;   -- nbit_float-3,  nbit_man
      z(15 downto 0)  <= manz7;   -- nbit_man-1
--    end if;
--  end process;
end rtl;

-- Module for Swap in Floating-Pioint Arithmetics
-- by Tsuyoshi Hamada (2004/08/30)
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
entity pg_fuadd_26_16_swap_1 is
  port ( nonzx, nonzy : in std_logic;
         expx,expy : in std_logic_vector(7 downto 0);  -- nbit_exp-1
         manx,many : in std_logic_vector(15 downto 0);  -- nbit_man-1
         expdif : out std_logic_vector(7 downto 0);    -- nbit_exp-1
         expz : out std_logic_vector(7 downto 0);      -- nbit_exp-1
         mana,manb : out std_logic_vector(15 downto 0); -- nbit_man-1
         nontobi : out std_logic;
         clk : in std_logic);
end pg_fuadd_26_16_swap_1;
architecture rtl of pg_fuadd_26_16_swap_1 is
signal expx0,expy0,expx1,expy1 : std_logic_vector(7 downto 0); -- nbit_exp-1
signal manx0,many0,manx1,many1 : std_logic_vector(15 downto 0); -- nbit_man-1
signal exp_x,exp_y : std_logic_vector(8 downto 0); -- nbit_exp
signal exy0,exy1 : std_logic_vector(8 downto 0);   -- nbit_exp
signal eyx0,eyx1 : std_logic_vector(7 downto 0);   -- nbit_exp-1
signal mx,my,mxy : std_logic_vector(16 downto 0);   -- nbit_man
signal mygex0,mygex1 : std_logic;
signal eygex : std_logic;
signal expdif0 : std_logic_vector(7 downto 0);     -- nbit_exp-1
signal xney : std_logic;  -- (expx != expy)
signal expz0 : std_logic_vector(7 downto 0);       -- nbit_exp-1
signal mana0,manb0 : std_logic_vector(15 downto 0); -- nbit_man-1
signal nzxy : std_logic_vector(1 downto 0);
signal nontobi0, nontobi1 : std_logic;
signal nygex0,nygex1 : std_logic;
signal flag0,flag1 : std_logic;
begin

  -- buffering
  expx0 <= expx;
  expy0 <= expy;
  manx0 <= manx;
  many0 <= many;

  -- biassing to unsigned
  exp_x(8) <= '0';                         -- nbit_exp
  exp_x(7) <= not expx0(7);               -- nbit_exp-1, nbit_exp-1
  exp_x(6 downto 0) <= expx0(6 downto 0); -- nbit_exp-2, nbit_exp-2
  exp_y(8) <= '0';                         -- nbit_exp
  exp_y(7) <= not expy0(7);               -- nbit_exp-1, nbit_exp-1
  exp_y(6 downto 0) <= expy0(6 downto 0); -- nbit_exp-2, nbit_exp-2

  -- sub exponent
  exy0 <= exp_x - exp_y;
  eyx0 <= exp_y(7 downto 0) - exp_x(7 downto 0); -- nbit_exp-1, nbit_exp-1

  -- compare mantissa
  mx <= '0' & manx0;
  my <= '0' & many0;
  mxy <= mx - my;
  mygex0 <= mxy(16);                     -- nbit_man

  -- nontobi, nygex
  nzxy <= nonzx & nonzy;
  with nzxy select
    nontobi0 <= '1' when "11",
                '0' when others;
  with nzxy select
    nygex0 <= '1' when "01",
              '0' when others;

  -- PIPELINE 1 ----------------------------------------------------------------
--  process(clk) begin
--    if(clk'event and clk='1') then
      expx1 <= expx0;
      expy1 <= expy0;
      manx1 <= manx0;
      many1 <= many0;
      exy1 <= exy0;
      eyx1 <= eyx0;
      mygex1 <= mygex0;
      nontobi1 <= nontobi0;
      nygex1 <= nygex0;
--    end if;
--  end process;

  eygex <= exy1(8);  -- nbit_exp

  with eygex select
    expdif0 <= eyx1 when '1',
               exy1(7 downto 0) when others;  -- nbit_exp-1

  with expdif0 select
    xney <= '0' when "00000000",              -- nbit_exp
            '1' when others;

  with xney select
    flag0 <= eygex  when '1',
             mygex1 when others;

  with nontobi1 select
    flag1 <= nygex1 when '0',
             flag0  when others;

  with flag1 select
    expz0 <= expy1 when '1',
             expx1 when others;

  with flag1 select
    mana0 <= manx1 when '0',
             many1 when others;

  with flag1 select
    manb0 <= manx1 when '1',
             many1 when others;

  -- PIPELINE 2 ----------------------------------------------------------------
  process(clk) begin
    if(clk'event and clk='1') then
      expz <= expz0;
      expdif <= expdif0;
      mana <=  mana0;
      manb <=  manb0;
      nontobi <= nontobi1;
    end if;
  end process;

end rtl;

-- Module for Shift in Floating-Pioint Arithmetics
-- by Tsuyoshi Hamada (2004/08/30)
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
entity pg_fuadd_26_16_shift_0 is
    port ( x : in std_logic_vector(16 downto 0);    -- nbit_man
           c : in std_logic_vector(7 downto 0);    -- nbit_exp-1
           z : out std_logic_vector(33 downto 0);   -- 2*(nbit_man+1)-1
           clk : in std_logic );
end pg_fuadd_26_16_shift_0;
architecture rtl of pg_fuadd_26_16_shift_0 is
signal x0 : std_logic_vector(16 downto 0);  -- nbit_man
signal c0 : std_logic_vector(7 downto 0);  -- nbit_exp-1
signal z0 : std_logic_vector(33 downto 0);  -- 2*(nbit_man+1)-1
begin

  x0 <= x;
  c0 <= c;

  with c0(4 downto 0) select   --  (int)(log(nbit_man+2)/log(2))-1
    z0 <= "00000000000000000" & x0      when "00000",  -- 0
          "0000000000000000" & x0 & '0' when "00001",  -- 1
          "000000000000000" & x0 & "00" when "00010",  -- 2
          "00000000000000" & x0 & "000" when "00011",  -- 3
          "0000000000000" & x0 & "0000" when "00100",  -- 4
          "000000000000" & x0 & "00000" when "00101",  -- 5
          "00000000000" & x0 & "000000" when "00110",  -- 6
          "0000000000" & x0 & "0000000" when "00111",  -- 7
          "000000000" & x0 & "00000000" when "01000",  -- 8
          "00000000" & x0 & "000000000" when "01001",  -- 9
          "0000000" & x0 & "0000000000" when "01010",  -- 10
          "000000" & x0 & "00000000000" when "01011",  -- 11
          "00000" & x0 & "000000000000" when "01100",  -- 12
          "0000" & x0 & "0000000000000" when "01101",  -- 13
          "000" & x0 & "00000000000000" when "01110",  -- 14
          "00" & x0 & "000000000000000" when "01111",  -- 15
          '0' & x0 & "0000000000000000" when "10000",  -- 16
               x0 & "00000000000000000" when "10001",  -- 17
          (others=>'0') when others;   -- over 18 = (nbit_man+2)

--  process(clk) begin
--    if(clk'event and clk='1') then
      z <= z0;
--    end if;
--  end process;

end rtl;

-- Module for Gbit Generator in Floating-Pioint Arithmetics
-- by Tsuyoshi Hamada (2004/08/31)
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
entity pg_fuadd_26_16_guard is
    port ( x : in std_logic_vector(16 downto 0); -- nbit_man
           c : in std_logic_vector(7 downto 0); -- nbit_exp-1
           flag : out std_logic);
end pg_fuadd_26_16_guard;
architecture rtl of pg_fuadd_26_16_guard is
signal x0 : std_logic_vector(16 downto 0); -- nbit_man
signal c0 : std_logic_vector(7 downto 0); -- nbit_exp-1
signal cc : std_logic_vector(16 downto 0); -- nbit_man
begin

  x0 <= x;
  c0 <= c;

  cc(0)  <= '0';
  cc(1)  <= x(0);
  fgen0: for i in 1 to 15 generate  -- nbit_man
    cc(i+1)  <= cc(i) or x(i);
  end generate;

  with c0(4 downto 0) select   --  ceil(log(nbit_man+2)/log(2))-1
    flag <= 
          cc(1)  when "00010",  -- 2
          cc(2)  when "00011",  -- 3
          cc(3)  when "00100",  -- 4
          cc(4)  when "00101",  -- 5
          cc(5)  when "00110",  -- 6
          cc(6)  when "00111",  -- 7
          cc(7)  when "01000",  -- 8
          cc(8)  when "01001",  -- 9
          cc(9)  when "01010",  -- 10
          cc(10)  when "01011",  -- 11
          cc(11)  when "01100",  -- 12
          cc(12)  when "01101",  -- 13
          cc(13)  when "01110",  -- 14
          cc(14)  when "01111",  -- 15
          cc(15)  when "10000",  -- 16
          cc(16)  when "10001",  -- 17
          '0' when others;      -- over 18 = (nbit_man+2)
end rtl;

-- Module for Adjust in Floating-Pioint Arithmetics
-- by Tsuyoshi Hamada (2004/08/31)
--
--  if(c>0){
--    z = x>>(c-1); /* c != 0 */
--  }else{
--    z = x<<1;     /* c == 0 */
--  }
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
entity pg_fuadd_26_16_adjust_0 is
    port ( x : in std_logic_vector(33 downto 0);  -- 2*(nbit_man+1)-1
           c : in std_logic_vector(7 downto 0);  -- nbit_exp-1
           z : out std_logic_vector(18 downto 0); -- nbit_man+2
           clk : in std_logic );
end pg_fuadd_26_16_adjust_0;
architecture rtl of pg_fuadd_26_16_adjust_0 is
signal x0 : std_logic_vector(34 downto 0); -- 2*(nbit_man+1)
signal c0 : std_logic_vector(7 downto 0); -- nbit_exp-1
signal z0 : std_logic_vector(18 downto 0); -- nbit_man+2
begin
  x0 <= '0' & x;
  c0 <= c;
  with c0(4 downto 0) select   --  ceil(log(nbit_man+2)/log(2))-1
    z0 <= x0(17 downto 0) & '0' when "00000",  -- 0
          x0(18 downto 0)       when "00001",  -- 1
          x0(19 downto 1)       when "00010",  -- 2
          x0(20 downto 2)       when "00011",  -- 3
          x0(21 downto 3)       when "00100",  -- 4
          x0(22 downto 4)       when "00101",  -- 5
          x0(23 downto 5)       when "00110",  -- 6
          x0(24 downto 6)       when "00111",  -- 7
          x0(25 downto 7)       when "01000",  -- 8
          x0(26 downto 8)       when "01001",  -- 9
          x0(27 downto 9)       when "01010",  -- 10
          x0(28 downto 10)       when "01011",  -- 11
          x0(29 downto 11)       when "01100",  -- 12
          x0(30 downto 12)       when "01101",  -- 13
          x0(31 downto 13)       when "01110",  -- 14
          x0(32 downto 14)       when "01111",  -- 15
          x0(33 downto 15)       when "10000",  -- 16
          x0(34 downto 16)       when "10001",  -- 17
          (others=>'0') when others;           -- over 18 = (nbit_man+2)

  z <= z0;
end rtl;

-- Module for Execute Rounding Operation in Floating-Pioint Arithmetics
-- by Tsuyoshi Hamada (2004/08/31)
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
entity pg_float_round_26_16 is
    port ( exp  : in std_logic_vector(7 downto 0); -- nbit_exp-1
           man  : in std_logic_vector(15 downto 0); -- nbit_man-1
           man_inc : in std_logic;
           expr : out std_logic_vector(7 downto 0); -- nbit_exp-1
           manr : out std_logic_vector(15 downto 0)); -- nbit_man-1
end pg_float_round_26_16;
architecture rtl of pg_float_round_26_16 is
  signal mx : std_logic_vector(16 downto 0);  -- nbit_man
  signal my : std_logic_vector(16 downto 0);  -- nbit_man
  signal mz : std_logic_vector(16 downto 0);  -- nbit_man
  signal flag : std_logic;
  signal epp : std_logic_vector(7 downto 0); -- nbit_exp-1
begin

  mx <= '0' & man;
  my <= "0000000000000000" & man_inc;  -- nbit_man
  mz <= mx + my;
  flag <= mz(16);  -- nbit_man
  epp <= exp + "00000001";  -- 1 of nbit_exp
  with flag select
    expr <= epp when '1',
            exp when others;

  with flag select
    manr <= mz(15 downto 0) when '0',  -- nbit_man-1
            (others=>'0') when others;
end rtl;

-- Module for Rounding Evaluation
-- by Tsuyoshi Hamada (2004/08/30)
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
entity pg_float_rbit_mode6 is
    port ( Fbit : in std_logic;
           Ulp  : in std_logic;
           Sbit : in std_logic;
           Gbit : in std_logic;
           man_inc : out std_logic);
end pg_float_rbit_mode6;
architecture rtl of pg_float_rbit_mode6 is
begin

--  man_inc <= '0';                                        -- 0: Truncation
--  man_inc <= Fbit and (not((not Sbit) and (not Gbit)));  -- 1: Truncation to Zero
--  man_inc <= Sbit;                                       -- 2: Rounding to Plus Infinity
--  man_inc <= Sbit and Gbit;                              -- 3: Rounding to Minus Infinity
--  man_inc <= Sbit and (not (Fbit and (not Gbit)));       -- 4: Rounding to Infinity
--  man_inc <= Sbit and (not ((not Fbit) and (not Gbit))); -- 5: Rounding to Zero
man_inc <= Sbit and (not ((not Ulp) and (not Gbit)));  -- 6: Rounding to Even
--  man_inc <= Sbit and (not (Ulp and (not Gbit)));        -- 7: Rounding to Odd
--  man_inc <= Sbit or Gbit;                               -- 8: Rounding Force to One

end rtl;

-- Floating-Point Unsigned Subtractor
-- For Signed Adder/Subtoractor
-- by Tsuyoshi Hamada (2004/10/02)
-- P: 1[-], 2[O], 3[-], 4[O], 5[-], 6[O], 7[-], 8[-], 9[-], 
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
entity pgsub_float_add_26_16_6_usub_3 is
  port( x : in std_logic_vector(25 downto 0);
        y : in std_logic_vector(25 downto 0);
        z : out std_logic_vector(25 downto 0);
        clk : in std_logic);
end pgsub_float_add_26_16_6_usub_3;
architecture rtl of pgsub_float_add_26_16_6_usub_3 is
  component pg_fusub_26_16_swap_1
    port ( signx, signy, nonzx, nonzy :  in std_logic;
           expx,expy : in std_logic_vector(7 downto 0);  -- nbit_exp-1
           manx,many : in std_logic_vector(15 downto 0);  -- nbit_man-1
           expdif : out std_logic_vector(7 downto 0);    -- nbit_exp-1
           expz : out std_logic_vector(7 downto 0);      -- nbit_exp-1
           mana,manb : out std_logic_vector(15 downto 0); -- nbit_man-1
           signz, nontobi, is_xeqy : out std_logic;
           clk : in std_logic);
  end component;

  component pg_fusub_26_16_shift_manb_0
    port ( x : in std_logic_vector(15 downto 0);  -- nbit_man-1
           c : in std_logic_vector(4 downto 0);  -- log_2(nbit_exp)-1
           z : out std_logic_vector(19 downto 0); -- nbit_man+3
           clk : in std_logic );
  end component;

  component penc_20_5
    port ( a : in std_logic_vector(19 downto 0);   -- nbit_man+3
           c : out std_logic_vector(4 downto 0)); -- nbit_penc-1
  end component;

  component pg_fusub_26_16_guard_0
    port ( x : in std_logic_vector(19 downto 0);  -- nbit_man+3
           c : in std_logic_vector(4 downto 0);  -- nbit_penc-1
           flag : out std_logic;
           clk  : in std_logic);
  end component;

  component pg_fusub_26_16_adjust_0
    port ( subdata  : in std_logic_vector(19 downto 0);  -- nbit_man+3
           pencdata : in std_logic_vector(4 downto 0);  -- nbit_penc-1
           mantissa : out std_logic_vector(15 downto 0); -- nbit_man-1
           Sbit     : out std_logic;
           clk : in std_logic);
  end component;

  component pg_fusub_26_16_expsub_0
    port ( expi : in std_logic_vector(7 downto 0);  -- nbit_exp-1
           penc : in std_logic_vector(4 downto 0);  -- nbit_penc-1
           expo : out std_logic_vector(7 downto 0); -- nbit_exp-1
           clk : in std_logic);
  end component;

  component pg_float_rbit_mode6
    port ( Fbit : in std_logic;
           Ulp  : in std_logic;
           Sbit : in std_logic;
           Gbit : in std_logic;
           man_inc : out std_logic);
  end component;

  component pg_float_round_26_16 is
    port ( exp  : in std_logic_vector(7 downto 0);   -- nbit_exp-1
           man  : in std_logic_vector(15 downto 0);   -- nbit_man-1
           man_inc : in std_logic;
           expr : out std_logic_vector(7 downto 0);  -- nbit_exp-1
           manr : out std_logic_vector(15 downto 0)); -- nbit_man-1
  end component;
signal nonzx,nonzy : std_logic;
signal expx,expy : std_logic_vector(7 downto 0);  -- nbit_exp-1
signal manx,many : std_logic_vector(15 downto 0);  -- nbit_man-1
signal signx,signy,signz0,signz1,signz2,signz3,signz4,signz5,signz6,signz7,signz8 : std_logic;
signal nonzz0,nonzz1,nonzz2,nonzz3,nonzz4,nonzz5,nonzz6,nonzz7,nonzz8,nonzz9 : std_logic;
signal nontobi0,nontobi1,nontobi2,nontobi3,nontobi4,nontobi5 : std_logic;
signal is_xeqy : std_logic;
signal expdif : std_logic_vector(7 downto 0);  -- nbit_exp-1
signal expz0,expz1,expz2,expz3,expz3r,expz4,expz5,expz6,expz7,expz8,expz9,expz10 : std_logic_vector(7 downto 0);  -- nbit_exp-1
signal expdif_sub : std_logic_vector(8 downto 0); -- nbit_exp
signal eflag0,eflag1,eflag2,eflag3,eflag4 : std_logic;
signal mana0,mana1,mana2,mana3,mana4 : std_logic_vector(15 downto 0);  -- nbit_man-1
signal manb0 : std_logic_vector(15 downto 0);  -- nbit_man-1
signal manb_s0,manb_s1 : std_logic_vector(19 downto 0);  -- nbit_man+3
signal msub0,msub1,msub2 : std_logic_vector(19 downto 0);  -- nbit_man+3
signal npenc0,npenc1 : std_logic_vector(4 downto 0);
signal Gbit0,Gbit1,Gbit2,Gbit3 : std_logic;
signal Sbit0,Sbit1,Sbit2,Sbit3 : std_logic;
signal mtr0,mtr1 : std_logic_vector(15 downto 0);  -- nbit_man-1
signal is_tobi : std_logic;
signal manz0,manz1,manz2,manz3 : std_logic_vector(15 downto 0);  -- nbit_man-1
signal man_inc0,man_inc1,man_inc2 : std_logic;
begin

  signx  <= x(25);                 -- nbit_float-1
  signy  <= y(25);                 -- nbit_float-1
  nonzx  <= x(24);                 -- nbit_float-2
  nonzy  <= y(24);                 -- nbit_float-2
  expx <= x(23 downto 16);         -- (nbit_float-3), nbit_man
  expy <= y(23 downto 16);         -- (nbit_float-3), nbit_man
  manx <= x(15 downto 0);          -- (nbit_man-1)
  many <= y(15 downto 0);          -- (nbit_man-1)

  -- nonz evalv
  nonzz0 <= nonzx or nonzy;

  u1 : pg_fusub_26_16_swap_1 port map(
    signx => signx,
    signy => signy,
    nonzx => nonzx,
    nonzy => nonzy,
    expx => expx,
    expy => expy,
    manx => manx,
    many => many,
    expdif => expdif,
    expz => expz0,
    mana => mana0,
    manb => manb0,
    nontobi => nontobi0,
    is_xeqy => is_xeqy,
    signz => signz2,
    clk => clk);

  -- PIPELINE 1 ----------------------------------------------------------------
--  process(clk) begin
--    if(clk'event and clk='1') then
      nonzz1 <= nonzz0;
--    end if;
--  end process;

  -- PIPELINE 2 ----------------------------------------------------------------
  process(clk) begin
    if(clk'event and clk='1') then
      nonzz2 <= nonzz1;
    end if;
  end process;

  u3 : pg_fusub_26_16_shift_manb_0 port map (
    x => manb0,
    c => expdif(4 downto 0), -- nbit_ctrl-1
    z => manb_s0,
    clk => clk);

  -- (expdif<18) ? eflag=1 : eflag=0 
  expdif_sub <= ('0'&expdif) - "000010010";  -- (expdif - 18)
  eflag0 <= expdif_sub(8);

  -- PIPELINE 3 ----------------------------------------------------------------
--  process(clk) begin
--    if(clk'event and clk='1') then
      nonzz3 <= nonzz2 AND (NOT is_xeqy);
      signz3 <= signz2;
      nontobi1 <= nontobi0;
      eflag1 <= eflag0;
      expz1 <= expz0;
      manb_s1 <= manb_s0;
      mana1 <= mana0;
--    end if;
--  end process;

  msub0 <= ('1' & mana1 & "000") - manb_s1;
  -- PIPELINE 4 ----------------------------------------------------------------
  process(clk) begin
    if(clk'event and clk='1') then
      nonzz4 <= nonzz3;
      signz4 <= signz3;
      nontobi2 <= nontobi1;
      eflag2 <= eflag1;
      expz2 <= expz1;
      msub1 <= msub0;
      mana2 <= mana1;
    end if;
  end process;

 u4 : penc_20_5 port map( a=>msub1, c=>npenc0 );
  -- PIPELINE 5 ----------------------------------------------------------------
--  process(clk) begin
--    if(clk'event and clk='1') then
      nonzz5 <= nonzz4;
      signz5 <= signz4;
      nontobi3 <= nontobi2;
      eflag3 <= eflag2;
      expz3 <= expz2;
      msub2 <= msub1;
      npenc1 <= npenc0;
      mana3 <= mana2;
--    end if;
--  end process;

  u5 : pg_fusub_26_16_guard_0 port map(
    x => msub2,
    c => npenc1,
    flag => Gbit0,
    clk => clk);

  u6 : pg_fusub_26_16_adjust_0 port map (
    subdata  => msub2,
    pencdata => npenc1,
    mantissa => mtr0,
    Sbit     => Sbit0,
    clk => clk);

  u7 : pg_fusub_26_16_expsub_0 port map (
    expi  => expz3,
    penc => npenc1,
    expo => expz4,
    clk => clk);

  -- PIPELINE 6 ----------------------------------------------------------------
  process(clk) begin
    if(clk'event and clk='1') then
      nonzz6 <= nonzz5;
      signz6 <= signz5;
      nontobi4 <= nontobi3;
      eflag4 <= eflag3;
      expz5 <= expz4;
      expz6 <= expz3;
      Gbit1 <= Gbit0;
      Sbit1 <= Sbit0;
      mtr1 <= mtr0;
      mana4 <= mana3;
    end if;
  end process;

  is_tobi <= eflag4 nand nontobi4;
  with is_tobi select
    expz7 <= expz5 when '0',
             expz6 when others;
  with is_tobi select
    Gbit2 <= Gbit1 when '0',
               '1' when others;
  with is_tobi select
    Sbit2 <= Sbit1 when '0',
               '0' when others;
  with is_tobi select
    manz0 <= mtr1  when '0',
             mana4 when others;

  -- PIPELINE 7 ----------------------------------------------------------------
--  process(clk) begin
--    if(clk'event and clk='1') then
      nonzz7 <= nonzz6;
      signz7 <= signz6;
      nontobi5 <= nontobi4;
      Gbit3 <= Gbit2;
      Sbit3 <= Sbit2;
      manz1 <= manz0;
      expz8 <= expz7;
--    end if;
--  end process;

  u8 : pg_float_rbit_mode6 port map (
    Fbit => signz7,
    Ulp  => manz1(0),
    Sbit => Sbit3,
    Gbit => Gbit3,
    man_inc => man_inc0);

  man_inc1 <= man_inc0 and nontobi5;

  -- PIPELINE 8 ----------------------------------------------------------------
--  process(clk) begin
--    if(clk'event and clk='1') then
      nonzz8 <= nonzz7;
      signz8 <= signz7;
      man_inc2 <= man_inc1;
      manz2 <= manz1;
      expz9 <= expz8;
--    end if;
--  end process;

  u9 : pg_float_round_26_16 port map (
    exp  => expz9,
    man  => manz2,
    man_inc => man_inc2,
    expr => expz10,
    manr => manz3);

  -- PIPELINE 9 ----------------------------------------------------------------
--  process(clk) begin
--    if(clk'event and clk='1') then
      z(25)           <= signz8;  -- nbit_float-1
      z(24)           <= nonzz8;  -- nbit_float-2
      z(23 downto 16) <= expz10;  -- nbit_float-3,  nbit_man
      z(15 downto 0)  <= manz3;   -- nbit_man-1
--    end if;
--  end process;
end rtl;

-- Module for Swap in Floating-Pioint Subtractor Arithmetics
-- by Tsuyoshi Hamada (2004/08/30)
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
entity pg_fusub_26_16_swap_1 is
  port ( signx, signy, nonzx, nonzy : in std_logic;
         expx,expy : in std_logic_vector(7 downto 0);  -- nbit_exp-1
         manx,many : in std_logic_vector(15 downto 0);  -- nbit_man-1
         expdif : out std_logic_vector(7 downto 0);    -- nbit_exp-1
         expz : out std_logic_vector(7 downto 0);      -- nbit_exp-1
         mana,manb : out std_logic_vector(15 downto 0); -- nbit_man-1
         signz, nontobi, is_xeqy : out std_logic;
         clk : in std_logic);
end pg_fusub_26_16_swap_1;
architecture rtl of pg_fusub_26_16_swap_1 is
signal sx0,sx1,sy0,sy1,nx0,nx1,ny0,ny1 : std_logic;
signal expx0,expy0,expx1,expy1 : std_logic_vector(7 downto 0); -- nbit_exp-1
signal manx0,many0,manx1,many1 : std_logic_vector(15 downto 0); -- nbit_man-1
signal exp_x,exp_y,exy0,eyx0 : std_logic_vector(8 downto 0); -- nbit_exp
signal exy1,eyx1 : std_logic_vector(7 downto 0);   -- nbit_exp-1
signal exgey0,exgey1,eygex0,eygex1 : std_logic;
signal mx,my,mxy,myx : std_logic_vector(16 downto 0);   -- nbit_man
signal mxgey0,mxgey1,mygex0,mygex1 : std_logic;
signal expdif0 : std_logic_vector(7 downto 0);     -- nbit_exp-1
signal exeqy,mxeqy : std_logic;
signal flag0,flag1 : std_logic;
signal is_xeqy0 : std_logic;
signal nygex : std_logic;
signal nontobi0 : std_logic;
signal expz0 : std_logic_vector(7 downto 0);       -- nbit_exp-1
signal mana0,manb0 : std_logic_vector(15 downto 0); -- nbit_man-1
signal signz0 : std_logic;
begin

  -- buffering
  sx0  <= signx;
  sy0  <= signy;
  nx0  <= nonzx;
  ny0  <= nonzy;
  expx0 <= expx;
  expy0 <= expy;
  manx0 <= manx;
  many0 <= many;

  -- biassing to unsigned
  exp_x(8) <= '0';                         -- nbit_exp
  exp_x(7) <= not expx0(7);               -- nbit_exp-1, nbit_exp-1
  exp_x(6 downto 0) <= expx0(6 downto 0); -- nbit_exp-2, nbit_exp-2
  exp_y(8) <= '0';                         -- nbit_exp
  exp_y(7) <= not expy0(7);               -- nbit_exp-1, nbit_exp-1
  exp_y(6 downto 0) <= expy0(6 downto 0); -- nbit_exp-2, nbit_exp-2

  -- sub exponent
  exy0 <= exp_x - exp_y;
  eyx0 <= exp_y - exp_x;
  eygex0 <= exy0(8);
  exgey0 <= eyx0(8);

  -- compare mantissa
  mx <= '0' & manx0;
  my <= '0' & many0;
  mxy <= mx - my;
  myx <= my - mx;
  mxgey0 <= myx(16);   -- nbit_man
  mygex0 <= mxy(16);   -- nbit_man

  -- PIPELINE 1 ----------------------------------------------------------------
--  process(clk) begin
--    if(clk'event and clk='1') then
      sx1  <= sx0;
      sy1  <= sy0;
      nx1  <= nx0;
      ny1  <= ny0;
      expx1 <= expx0;
      expy1 <= expy0;
      manx1 <= manx0;
      many1 <= many0;
      exy1 <= exy0(7 downto 0);   -- nbit_exp-1
      eyx1 <= eyx0(7 downto 0);   -- nbit_exp-1
      exgey1 <= exgey0;
      eygex1 <= eygex0;
      mxgey1 <= mxgey0;
      mygex1 <= mygex0;
--    end if;
--  end process;

  with eygex1 select
    expdif0 <= exy1 when '0',
               eyx1 when others;

  exeqy <= exgey1 nor eygex1;

  with exeqy select
    flag0 <= eygex1 when '0',
             mygex1 when others;

  mxeqy <= mxgey1 nor mygex1;

  is_xeqy0 <= nx1 AND ny1 AND exeqy AND mxeqy;

  nontobi0 <= nx1 AND ny1;

  nygex <= (NOT nx1) AND ny1;

  with nontobi0 select
    flag1 <= nygex when '0',
             flag0 when others;

  with flag1 select
    signz0 <= (NOT sy1) when '1',
              sx1 when others;
  with flag1 select
    expz0 <= expx1 when '0',
             expy1 when others;
  with flag1 select
    mana0 <= manx1 when '0',
             many1 when others;
  with flag1 select
    manb0 <= many1 when '0',
             manx1 when others;

  -- PIPELINE 2 ----------------------------------------------------------------
  process(clk) begin
    if(clk'event and clk='1') then
      signz <= signz0;
      expz <= expz0;
      expdif <= expdif0;
      mana <=  mana0;
      manb <=  manb0;
      nontobi <= nontobi0;
      is_xeqy <= is_xeqy0;
    end if;
  end process;

end rtl;

-- Module for Shift in Floating-Pioint Arithmetics
-- by Tsuyoshi Hamada (2004/09/12)
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
entity pg_fusub_26_16_shift_manb_0 is
    port ( x : in std_logic_vector(15 downto 0);    -- nbit_man-1
           c : in std_logic_vector(4 downto 0);    -- nbit_ctrl-1
           z : out std_logic_vector(19 downto 0);   -- nbit_man+3
           clk : in std_logic );
end pg_fusub_26_16_shift_manb_0;
architecture rtl of pg_fusub_26_16_shift_manb_0 is
signal x0 : std_logic_vector(33 downto 0);
signal c0 : std_logic_vector(4 downto 0);  -- nbit_ctrl-1
signal xs : std_logic_vector(33 downto 0);
signal SHbit,SLbit,Gbit : std_logic;
signal z0 : std_logic_vector(19 downto 0);  -- nbit_man+3
begin

  x0 <= '1' & x & "00000000000000000";
  c0 <= c;
  SHbit <= xs(16);
  SLbit <= xs(15);
  Gbit <= xs(14)  or xs(13)  or xs(12)  or xs(11)  or xs(10)  or xs(9)  or xs(8)  or xs(7)  or xs(6)  or xs(5)  or xs(4)  or xs(3)  or xs(2)  or xs(1)  or xs(0);
  z0 <= xs(33 downto 17) & SHbit & SLbit & Gbit;

  with c0 select
    xs <=      x0(33 downto 0) when "00000",  -- 0
          '0' & x0(33 downto 1) when "00001",  -- 1
          "00" & x0(33 downto 2) when "00010",  -- 2
          "000" & x0(33 downto 3) when "00011",  -- 3
          "0000" & x0(33 downto 4) when "00100",  -- 4
          "00000" & x0(33 downto 5) when "00101",  -- 5
          "000000" & x0(33 downto 6) when "00110",  -- 6
          "0000000" & x0(33 downto 7) when "00111",  -- 7
          "00000000" & x0(33 downto 8) when "01000",  -- 8
          "000000000" & x0(33 downto 9) when "01001",  -- 9
          "0000000000" & x0(33 downto 10) when "01010",  -- 10
          "00000000000" & x0(33 downto 11) when "01011",  -- 11
          "000000000000" & x0(33 downto 12) when "01100",  -- 12
          "0000000000000" & x0(33 downto 13) when "01101",  -- 13
          "00000000000000" & x0(33 downto 14) when "01110",  -- 14
          "000000000000000" & x0(33 downto 15) when "01111",  -- 15
          "0000000000000000" & x0(33 downto 16) when "10000",  -- 16
          "00000000000000000" & x0(33 downto 17) when "10001",  -- 17
          (others=>'0') when others;   -- over 18 = (nbit_man+2)

  z <= z0;

end rtl;
                                                                    
library ieee;                                                       
use ieee.std_logic_1164.all;                                        
                                                                    
entity penc_20_5 is                             
port( a : in std_logic_vector(19 downto 0);              
      c : out std_logic_vector(4 downto 0));           
end penc_20_5;                                  
                                                                    
architecture rtl of penc_20_5 is                
begin                                                               
                                                                    
  process(a) begin                                                  
    if(a(19)='1') then                                    
      c <= "10011";                                              
    elsif(a(18)='1') then                                      
      c <= "10010";                                             
    elsif(a(17)='1') then                                      
      c <= "10001";                                             
    elsif(a(16)='1') then                                      
      c <= "10000";                                             
    elsif(a(15)='1') then                                      
      c <= "01111";                                             
    elsif(a(14)='1') then                                      
      c <= "01110";                                             
    elsif(a(13)='1') then                                      
      c <= "01101";                                             
    elsif(a(12)='1') then                                      
      c <= "01100";                                             
    elsif(a(11)='1') then                                      
      c <= "01011";                                             
    elsif(a(10)='1') then                                      
      c <= "01010";                                             
    elsif(a(9)='1') then                                      
      c <= "01001";                                             
    elsif(a(8)='1') then                                      
      c <= "01000";                                             
    elsif(a(7)='1') then                                      
      c <= "00111";                                             
    elsif(a(6)='1') then                                      
      c <= "00110";                                             
    elsif(a(5)='1') then                                      
      c <= "00101";                                             
    elsif(a(4)='1') then                                      
      c <= "00100";                                             
    elsif(a(3)='1') then                                      
      c <= "00011";                                             
    elsif(a(2)='1') then                                      
      c <= "00010";                                             
    elsif(a(1)='1') then                                      
      c <= "00001";                                             
    else                                                            
      c <= "00000";                                               
    end if;                                                         
  end process;                                                      
                                                                    
end rtl;                                                            

-- Module for Guard in Floating-Pioint Subtractor
-- by Tsuyoshi Hamada (2004/09/13)
--
--           <- NBIT_MAN  ->
--  00000001. XXXXXXXXXXXXX S NNNNNNN.......
--                            <--   OR   -->
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
entity pg_fusub_26_16_guard_0 is
    port ( x : in std_logic_vector(19 downto 0);  -- nbit_man+3
           c : in std_logic_vector(4 downto 0);   -- nbit_penc-1
           flag : out std_logic;
           clk : in std_logic );
end pg_fusub_26_16_guard_0;
architecture rtl of pg_fusub_26_16_guard_0 is
signal x0 : std_logic_vector(19 downto 0); -- nbit_man+3
signal c0 : std_logic_vector(4 downto 0); -- nbit_penc-1
signal gg : std_logic_vector(1 downto 0);
signal f0 : std_logic;
begin

  x0 <= x;
  c0 <= c;

  gg(0) <= x0(0);
  gg(1) <= x0(0) or x(1);

  with c0 select
    f0 <= gg(0) when "10010",  -- 18 (nbit_man+2)
          gg(1) when "10011",  -- 19 (nbit_man+3)
           '0'  when others;  -- c0 < 18 , 19 < c0

  flag <= f0;

end rtl;

-- Module for Adjust in Floating-Pioint Subtractor
-- by Tsuyoshi Hamada (2004/09/13)
--
--           <- NBIT_MAN  ->
--  00000001. XXXXXXXXXXXXX S NNNNNNN
--           <--   OUTPUT  -->
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
entity pg_fusub_26_16_adjust_0 is
    port ( subdata  : in std_logic_vector(19 downto 0);  -- nbit_man+3
           pencdata : in std_logic_vector(4 downto 0);   -- nbit_penc-1
           mantissa : out std_logic_vector(15 downto 0); -- nbit_man-1
           Sbit     : out std_logic;
           clk : in std_logic );
end pg_fusub_26_16_adjust_0;
architecture rtl of pg_fusub_26_16_adjust_0 is
signal x0 : std_logic_vector(19 downto 0); -- nbit_man+3
signal c0 : std_logic_vector(4 downto 0);  -- nbit_penc-1
signal z0 : std_logic_vector(16 downto 0); -- nbit_man
signal m0 : std_logic_vector(15 downto 0); -- nbit_man - 1
signal s0 : std_logic;
begin

  x0 <= subdata;
  c0 <= pencdata;

  with c0 select
    z0 <=  x0(18 downto 2)       when "10011",  -- 19
           x0(17 downto 1)       when "10010",  -- 18
           x0(16 downto 0)       when "10001",  -- 17
           x0(15 downto 0) & '0' when "10000",  -- 16
           x0(14 downto 0) & "00" when "01111",  -- 15
           x0(13 downto 0) & "000" when "01110",  -- 14
           x0(12 downto 0) & "0000" when "01101",  -- 13
           x0(11 downto 0) & "00000" when "01100",  -- 12
           x0(10 downto 0) & "000000" when "01011",  -- 11
           x0( 9 downto 0) & "0000000" when "01010",  -- 10
           x0( 8 downto 0) & "00000000" when "01001",  -- 9
           x0( 7 downto 0) & "000000000" when "01000",  -- 8
           x0( 6 downto 0) & "0000000000" when "00111",  -- 7
           x0( 5 downto 0) & "00000000000" when "00110",  -- 6
           x0( 4 downto 0) & "000000000000" when "00101",  -- 5
           x0( 3 downto 0) & "0000000000000" when "00100",  -- 4
           x0( 2 downto 0) & "00000000000000" when "00011",  -- 3
           x0( 1 downto 0) & "000000000000000" when "00010",  -- 2
           x0(0)           & "0000000000000000"  when "00001",  -- 1
         (others=>'0') when others;
  m0 <= z0(16 downto 1);                -- nbit_man
  s0 <= z0(0);

  -- OUTPUT --
  mantissa <= m0;
  Sbit <= s0;

end rtl;

-- Module for ExpSub in Floating-Pioint Subtractor
-- by Tsuyoshi Hamada (2004/09/14)
--
--    {
--      LONG exp_inc; // 5-bit because exp_inc is always >=0.
--      LONG exp_z;
--      exp_inc =  0x1fULL& (LONG)(19 - npenc); // 5-bit because exp_inc is always >=0.
--      exp_z = (0x80ULL)^expz;
--      exp_z = exp_z - exp_inc;
--      expz = (0x80ULL)^exp_z;
--    }

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
entity pg_fusub_26_16_expsub_0 is
    port ( expi : in std_logic_vector(7 downto 0); -- nbit_exp-1
           penc : in std_logic_vector(4 downto 0); -- nbit_penc-1
           expo : out std_logic_vector(7 downto 0); -- nbit_exp-1
           clk : in std_logic );
end pg_fusub_26_16_expsub_0;
architecture rtl of pg_fusub_26_16_expsub_0 is
signal expi0 : std_logic_vector(7 downto 0); -- nbit_exp-1
signal expo0 : std_logic_vector(7 downto 0); -- nbit_exp-1
signal penc0 : std_logic_vector(4 downto 0); -- nbit_penc-1
signal inc0  : std_logic_vector(4 downto 0); -- nbit_penc-1
signal inc1  : std_logic_vector(4 downto 0); -- nbit_penc-1
signal exp0  : std_logic_vector(7 downto 0); -- nbit_exp-1
signal exp1  : std_logic_vector(7 downto 0); -- nbit_exp-1
signal exp2  : std_logic_vector(7 downto 0); -- nbit_exp-1

begin

  expi0 <= expi;
  penc0 <= penc;

  inc0 <= "10011" - penc0; -- 19 of nbit_penc
  exp0(7) <= not expi0(7); -- nbit_exp-1, nbit_exp-1
  exp0(6 downto 0) <= expi0(6 downto 0); -- nbit_exp-2, nbit_exp-2

--  process(clk) begin
--    if(clk'event and clk='1') then
      inc1 <= inc0;
      exp1 <= exp0;
--    end if;
--  end process;

  exp2 <= exp1 - ("000"&inc1); -- (nbit_exp-nbit_penc)
  expo0(7) <= not exp2(7); -- nbit_exp-1, nbit_exp-1
  expo0(6 downto 0) <= exp2(6 downto 0); -- nbit_exp-2, nbit_exp-2

--  process(clk) begin
--    if(clk'event and clk='1') then
      expo <= expo0;
--    end if;
--  end process;

end rtl;
-- PGR Floating-Point Multiplier
-- by Tsuyoshi Hamada (2004/08/24)
-- P: 1[-], 2[-], 3[O], 4[-], 5[-], 6[-], 7[O], 
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
entity pg_float_mult_26_16_2_6 is
  port( x : in std_logic_vector(25 downto 0);
        y : in std_logic_vector(25 downto 0);
        z : out std_logic_vector(25 downto 0);
        clk : in std_logic);
end pg_float_mult_26_16_2_6;
architecture rtl of pg_float_mult_26_16_2_6 is

  component pg_umult_17_17_0
   port (x: in std_logic_vector(16 downto 0);
         y: in std_logic_vector(16 downto 0);
         clk: in std_logic;
         z: out std_logic_vector(33 downto 0));
  end component;

signal signx,signy : std_logic;
signal signz0r0,signz0,signz1,signz2,signz3,signz4,signz5 : std_logic;
signal nonzx,nonzy   : std_logic;
signal nonzz0r0,nonzz0,nonzz1,nonzz2,nonzz3,nonzz4,nonzz5 : std_logic;
signal expx,expy : std_logic_vector(7 downto 0);
signal manx,many : std_logic_vector(16 downto 0);
signal manz0,manz1,manz2 : std_logic_vector(33 downto 0);  -- 2*(nbit_man+1)-1
signal expz0,expz0r0,expz1,expz2,expz3,expz4,expz5 : std_logic_vector(7 downto 0); -- nbit_exp-1
signal muloh2b : std_logic_vector(1 downto 0);
signal exp_inc0,exp_inc1,exp_inc2,exp_inc3 : std_logic;
signal exp_inc4 : std_logic_vector(1 downto 0);
signal Ulp0,Sbit0,Gbit0,GbitA,GbitB : std_logic;
signal Ulp1,Sbit1,Gbit1 : std_logic;
signal man_trunc0,man_trunc1 : std_logic_vector(15 downto 0);  -- nbit_man-1
signal minc0,minc1 : std_logic;
signal z_man0,z_man1 : std_logic_vector(16 downto 0);    -- nbit_man
signal z_man2,z_man_rs : std_logic_vector(15 downto 0);  -- nbit_man-1
signal exp_inc_pa,exp_inc_pb,exp_inc_pc : std_logic_vector(1 downto 0);
signal z_exp : std_logic_vector(7 downto 0);             -- nbit_exp-1
signal zz : std_logic_vector(25 downto 0);               -- nbit_log-1

begin

  signx  <= x(25);                       -- nbit_float-1
  signy  <= y(25);                       -- nbit_float-1
  nonzx  <= x(24);                       -- nbit_float-2
  nonzy  <= y(24);                       -- nbit_float-2
  expx <= x(23 downto 16 );              -- (nbit_float-3), nbit_man
  expy <= y(23 downto 16);               -- (nbit_float-3), nbit_man
  manx <= '1' & x(15 downto 0);          -- (nbit_man-1)
  many <= '1' & y(15 downto 0);          -- (nbit_man-1)

  signz0r0 <= signx xor signy;
  nonzz0r0 <= nonzx and nonzy;
  expz0r0 <= expx + expy;

  -- manz0 <= manx * many;
  mult0 : pg_umult_17_17_0   port map(x => manx, y=> many, z => manz0, clk=>clk);

  --- PIPELINE 1(OFF) ---
--  process(clk) begin
--    if(clk'event and clk='1') then
      signz0 <= signz0r0;
      nonzz0 <= nonzz0r0;
      expz0  <= expz0r0;
--    end if;
--  end process;
  ----------------------.

  -- PIPELINE 2 (OFF) -----------------------------------------------------------
--  process(clk) begin
--    if(clk'event and clk='1') then
      signz1 <= signz0;
      nonzz1 <= nonzz0;
      manz1  <= manz0;
      expz1  <= expz0;
--    end if;
--  end process;

  -- Top 2-bit of multiplier's outdata
  muloh2b <= manz1(33 downto 32);       -- 2*(nbit_man+1)-1, 2*(nbit_man+1)-2
  with muloh2b select 
    exp_inc0 <= '0' when "01",          -- If mult-result is "01.XXXXX" 
                '1' when others;
  with muloh2b select 
    Ulp0 <= manz1(16) when "01",         -- nbit_man
            manz1(17) when others;       -- nbit_man+1

  with muloh2b select 
    Sbit0 <= manz1(15) when "01",         -- nbit_man-1
             manz1(16) when others;       -- nbit_man

  with manz1(14 downto 0) select
    GbitA <= '0' when "000000000000000", -- nbit_man-1
             '1' when others;

  with manz1(15 downto 0) select
    GbitB <= '0' when "0000000000000000", -- nbit_man
             '1' when others;

  with muloh2b select 
    Gbit0 <= GbitA when "01",
             GbitB when others;

  -- PIPELINE 3 ----------------------------------------------------------------
  process(clk) begin
    if(clk'event and clk='1') then
      signz2 <= signz1;
      nonzz2 <= nonzz1;
      manz2  <= manz1;
      expz2  <= expz1;
      exp_inc1 <= exp_inc0;
      Ulp1  <= Ulp0;
      Sbit1 <= Sbit0;
      Gbit1 <= Gbit0;
    end if;
  end process;

-- SELECT ROUNDING MODE (minc : MANtissa INCliment)----------------------------
--  minc0 <= '0';                                            -- 0: Truncation
--  minc0 <= signz2 and (not((not Sbit1) and (not Gbit1)));  -- 1: Truncation to Zero
--  minc0 <= Sbit1;                                          -- 2: Rounding to Plus Infinity
--  minc0 <= Sbit1 and Gbit1;                                -- 3: Rounding to Minus Infinity
--  minc0 <= Sbit1 and (not (signz2 and (not Gbit1)));       -- 4: Rounding to Infinity
--  minc0 <= Sbit1 and (not ((not signz2) and (not Gbit1))); -- 5: Rounding to Zero
  minc0 <= Sbit1 and (not ((not Ulp1) and (not Gbit1)));   -- 6: Rounding to Even
--  minc0 <= Sbit1 and (not (Ulp1 and (not Gbit1)));         -- 7: Rounding to Odd
--  minc0 <= Sbit1 or Gbit1;                                 -- 8: Rounding Force to One
-------------------------------------------------------------------------------


  -- Shift & Truncate
  with  exp_inc1 select
    man_trunc0 <= manz2(31 downto 16) when '0',    -- 2*nbit_man-1, nbit_man
                  manz2(32 downto 17) when others; -- 2*nbit_man,   nbit_man+1

  -- PIPELINE 4 (OFF) -----------------------------------------------------------
--  process(clk) begin
--    if(clk'event and clk='1') then
      signz3 <= signz2;
      nonzz3 <= nonzz2;
      expz3  <= expz2;
      exp_inc2 <= exp_inc1;
      man_trunc1  <= man_trunc0;
      minc1 <= minc0;
--    end if;
--  end process;

  z_man0 <= ('0' & man_trunc1) + ("0000000000000000" & minc1);  -- nbit_man


  -- PIPELINE 5 (OFF) -----------------------------------------------------------
--  process(clk) begin
--    if(clk'event and clk='1') then
      signz4 <= signz3;
      nonzz4 <= nonzz3;
      expz4  <= expz3;
      exp_inc3 <= exp_inc2;
      z_man1  <= z_man0;
--    end if;
--  end process;

  exp_inc_pa <= ('0'&exp_inc3) + ("01");
  exp_inc_pb <= ('0'&exp_inc3);

  with  z_man1(16) select                     -- nbit_man
    exp_inc_pc <= exp_inc_pa when '1',
                  exp_inc_pb when others;

  z_man_rs <= z_man1(15 downto 0);


  -- PIPELINE 6 (OFF) -----------------------------------------------------------
--  process(clk) begin
--    if(clk'event and clk='1') then
      signz5 <= signz4;
      nonzz5 <= nonzz4;
      expz5  <= expz4;
      exp_inc4 <= exp_inc_pc;
      z_man2  <= z_man_rs;
--    end if;
--  end process;
  
  z_exp <= expz5 + ("000000"&exp_inc4);

  zz(25) <= signz5;
  zz(24) <= nonzz5;
  zz(23 downto 16) <= z_exp;
  zz(15 downto 0) <= z_man2;
  
  -- PIPELINE 7 ----------------------------------------------------------------
  process(clk) begin
    if(clk'event and clk='1') then
      z <= zz;
    end if;
  end process;

end rtl;

--+--------------------------------+
--| PGR unsigned multiplier        |
--|  2006-04-14 16:24:06           |
--|      by Tsuyoshi Hamada        |
--+--------------------------------+
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity pg_umult_17_17_0 is
  port(x : in std_logic_vector(16 downto 0);
       y : in std_logic_vector(16 downto 0);
       z : out std_logic_vector(33 downto 0);
     clk : in std_logic);
end pg_umult_17_17_0;

architecture rtl of pg_umult_17_17_0 is

  signal s : std_logic_vector(33 downto 0);
begin
  s <= x * y;
  z <= s;
end rtl;
-- PGR Floating-Point Unsigned Adder
-- by Tsuyoshi Hamada (2004/08/30)
-- P: 1[-], 2[O], 3[-], 4[O], 5[O], 6[-], 7[-], 8[-], 9[O], 
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
entity pg_float_unsigned_add_26_16_4_6 is
  port( x : in std_logic_vector(25 downto 0);
        y : in std_logic_vector(25 downto 0);
        z : out std_logic_vector(25 downto 0);
        clk : in std_logic);
end pg_float_unsigned_add_26_16_4_6;
architecture rtl of pg_float_unsigned_add_26_16_4_6 is
  component pg_fuadd_26_16_swap_1
    port ( nonzx, nonzy : in std_logic;
           expx,expy : in std_logic_vector(7 downto 0);  -- nbit_exp-1
           manx,many : in std_logic_vector(15 downto 0);  -- nbit_man-1
           expdif : out std_logic_vector(7 downto 0);    -- nbit_exp-1
           expz : out std_logic_vector(7 downto 0);      -- nbit_exp-1
           mana,manb : out std_logic_vector(15 downto 0); -- nbit_man-1
           nontobi : out std_logic;
           clk : in std_logic);
  end component;

  component pg_fuadd_26_16_shift_0
    port ( x : in std_logic_vector(16 downto 0);  -- nbit_man
           c : in std_logic_vector(7 downto 0);  -- nbit_exp-1
           z : out std_logic_vector(33 downto 0); -- 2*(nbit_man+1)-1
           clk : in std_logic );
  end component;

  component pg_fuadd_26_16_guard
    port ( x : in std_logic_vector(16 downto 0);  -- nbit_man
           c : in std_logic_vector(7 downto 0);  -- nbit_exp-1
           flag : out std_logic);
  end component;

  component pg_fuadd_26_16_adjust_0
    port ( x : in std_logic_vector(33 downto 0);  -- 2*(nbit_man+1)-1
           c : in std_logic_vector(7 downto 0);  -- nbit_exp-1
           z : out std_logic_vector(18 downto 0); -- nbit_man+2
           clk : in std_logic);
  end component;

  component pg_float_rbit_mode6
    port ( Fbit : in std_logic;
           Ulp  : in std_logic;
           Sbit : in std_logic;
           Gbit : in std_logic;
           man_inc : out std_logic);
  end component;

  component pg_float_round_26_16 is
    port ( exp  : in std_logic_vector(7 downto 0);   -- nbit_exp-1
           man  : in std_logic_vector(15 downto 0);   -- nbit_man-1
           man_inc : in std_logic;
           expr : out std_logic_vector(7 downto 0);  -- nbit_exp-1
           manr : out std_logic_vector(15 downto 0)); -- nbit_man-1
  end component;
signal nonzx,nonzy : std_logic;
signal expx,expy : std_logic_vector(7 downto 0);  -- nbit_exp-1
signal manx,many : std_logic_vector(15 downto 0);  -- nbit_man-1
signal signz0,signz1,signz2,signz3,signz4,signz5,signz6,signz7,signz8 : std_logic;
signal nonzz0,nonzz1,nonzz2,nonzz3,nonzz4,nonzz5,nonzz6,nonzz7,nonzz8 : std_logic;
signal expdif0,expdif1,expdif2 : std_logic_vector(7 downto 0);  -- nbit_exp-1
signal expz0,expz1,expz2,expz3,expz3r,expz4,expz5,expz6,expz7,expz8,expz9 : std_logic_vector(7 downto 0);  -- nbit_exp-1
signal mana0,mana1,mana2,mana3,mana4 : std_logic_vector(15 downto 0);  -- nbit_man-1
signal manb0,manb1 : std_logic_vector(15 downto 0);  -- nbit_man-1
signal nontobi0,nontobi1,nontobi2,nontobi3,nontobi4,nontobi5 : std_logic;
signal imana : std_logic_vector(16 downto 0);  -- nbit_man
signal mash,madd0,madd1 : std_logic_vector(33 downto 0);  -- 2*(nbit_man+1)-1
signal manz0,manz1 : std_logic_vector(18 downto 0);  -- nbit_man+2
signal manz2,manz3,manz4,manz5,manz6,manz7 : std_logic_vector(15 downto 0);  -- nbit_man-1
signal Gbit0,Gbit1,Gbit2,Gbit3,Gbit4 : std_logic;
signal Sbit0,Sbit1,Sbit2,Sbit3 : std_logic;
signal efsub : std_logic_vector(8 downto 0);  -- nbit_exp
signal eflag0,eflag1,eflag2 : std_logic;
signal mtr : std_logic_vector(16 downto 0);    -- nbit_man
signal ezinc : std_logic_vector(7 downto 0);  -- nbit_exp-1
signal i2b : std_logic_vector(1 downto 0);
signal is_tobi : std_logic;
signal man_inc0,man_inc1,man_inc2 : std_logic;
begin

  signz0 <= x(25);                 -- nbit_float-1
  nonzx  <= x(24);                 -- nbit_float-2
  nonzy  <= y(24);                 -- nbit_float-2
  expx <= x(23 downto 16);         -- (nbit_float-3), nbit_man
  expy <= y(23 downto 16);         -- (nbit_float-3), nbit_man
  manx <= x(15 downto 0);          -- (nbit_man-1)
  many <= y(15 downto 0);          -- (nbit_man-1)

  -- nonz evalv
  nonzz0 <= nonzx or nonzy;

  u1 : pg_fuadd_26_16_swap_1 port map(
    nonzx => nonzx,
    nonzy => nonzy,
    expx => expx,
    expy => expy,
    manx => manx,
    many => many,
    expdif => expdif0,
    expz => expz0,
    mana => mana0,
    manb => manb0,
    nontobi => nontobi0,
    clk => clk);

  -- PIPELINE 1 ----------------------------------------------------------------
--  process(clk) begin
--    if(clk'event and clk='1') then
      signz1 <= signz0;
      nonzz1 <= nonzz0;
--    end if;
--  end process;

  -- PIPELINE 2 ----------------------------------------------------------------
  process(clk) begin
    if(clk'event and clk='1') then
      signz2 <= signz1;
      nonzz2 <= nonzz1;
    end if;
  end process;

  imana <= '1' & mana0;
  u3 : pg_fuadd_26_16_shift_0 port map (
    x => imana,
    c => expdif0,
    z => mash,
    clk => clk);

  -- PIPELINE 3 ----------------------------------------------------------------
--  process(clk) begin
--    if(clk'event and clk='1') then
      signz3 <= signz2;
      nonzz3 <= nonzz2;
      nontobi1 <= nontobi0;
      expdif1 <= expdif0;
      expz1 <= expz0;
      mana1 <= mana0;
      manb1 <= manb0;
--    end if;
--  end process;

  madd0 <= mash + ("000000000000000001"&manb1);  -- 1 of nbit_man+2
  -- PIPELINE 4 ----------------------------------------------------------------
  process(clk) begin
    if(clk'event and clk='1') then
      signz4 <= signz3;
      nonzz4 <= nonzz3;
      nontobi2 <= nontobi1;
      expdif2 <= expdif1;
      madd1 <= madd0;
      expz2 <= expz1;
      mana2 <= mana1;
    end if;
  end process;

  u4 : pg_fuadd_26_16_guard port map(
    x => madd1(16 downto 0),  -- nbit_man
    c => expdif2,
    flag => Gbit0);

  u5 : pg_fuadd_26_16_adjust_0 port map (
    x => madd1,
    c => expdif2,
    z => manz0,
    clk => clk);

  efsub <= ('0' & expdif2) - "000010010";  -- 18 of nbit_exp+1
  eflag0 <= efsub(8); -- nbit_exp

  -- PIPELINE 5 ----------------------------------------------------------------
  process(clk) begin
    if(clk'event and clk='1') then
      signz5 <= signz4;
      nonzz5 <= nonzz4;
      nontobi3 <= nontobi2;
      Gbit1 <= Gbit0;
      eflag1 <= eflag0;
      manz1 <= manz0;
      expz3 <= expz2;
      mana3 <= mana2;
    end if;
  end process;

  Sbit0 <= manz1(0);
  mtr <= manz1(17 downto 1);    -- nbit_man+1
  i2b <= manz1(18 downto 17);   -- nbit_man+2, nbit_man+1
  ezinc <= expz3 + "00000001";  -- 1 of (nbit_exp) bit

  with i2b select 
    manz2 <= mtr(15 downto 0) when "01",  -- nbit_man-1
             mtr(16 downto 1) when others;  -- nbit_man

  with i2b select 
    expz4 <= expz3 when "01",
             ezinc when others;

  -- PIPELINE 6 ----------------------------------------------------------------
--  process(clk) begin
--    if(clk'event and clk='1') then
      signz6 <= signz5;
      nonzz6 <= nonzz5;
      nontobi4 <= nontobi3;
      eflag2 <= eflag1;
      Gbit2 <= Gbit1;
      Sbit1 <= Sbit0;
      manz3 <= manz2;
      expz5 <= expz4;
      expz3r <= expz3;
      mana4 <= mana3;
--    end if;
--  end process;

  is_tobi <= eflag2 nand nontobi4;
  with is_tobi select
    Gbit3 <= Gbit2 when '0',
               '1' when others;
  with is_tobi select
    Sbit2 <= Sbit1 when '0',
               '0' when others;
  with is_tobi select
    manz4 <= manz3 when '0',
             mana4 when others;
  with is_tobi select
    expz6 <= expz5 when '0',
             expz3r when others;

  -- PIPELINE 7 ----------------------------------------------------------------
--  process(clk) begin
--    if(clk'event and clk='1') then
      signz7 <= signz6;
      nonzz7 <= nonzz6;
      nontobi5 <= nontobi4;
      Gbit4 <= Gbit3;
      Sbit3 <= Sbit2;
      manz5 <= manz4;
      expz7 <= expz6;
--    end if;
--  end process;

  u6 : pg_float_rbit_mode6 port map (
    Fbit => signz7,
    Ulp  => manz5(0),
    Sbit => Sbit3,
    Gbit => Gbit4,
    man_inc => man_inc0);

  man_inc1 <= man_inc0 and nontobi5;

  -- PIPELINE 8 ----------------------------------------------------------------
--  process(clk) begin
--    if(clk'event and clk='1') then
      signz8 <= signz7;
      nonzz8 <= nonzz7;
      man_inc2 <= man_inc1;
      manz6 <= manz5;
      expz8 <= expz7;
--    end if;
--  end process;

  u7 : pg_float_round_26_16 port map (
    exp  => expz8,
    man  => manz6,
    man_inc => man_inc2,
    expr => expz9,
    manr => manz7);

  -- PIPELINE 9 ----------------------------------------------------------------
  process(clk) begin
    if(clk'event and clk='1') then
      z(25)           <= signz8;  -- nbit_float-1
      z(24)           <= nonzz8;  -- nbit_float-2
      z(23 downto 16) <= expz9;   -- nbit_float-3,  nbit_man
      z(15 downto 0)  <= manz7;   -- nbit_man-1
    end if;
  end process;
end rtl;
-- PGR Floating-Point SquareRoot
-- by Tsuyoshi Hamada (2004/09/30)
-- NFLO 26, NMAN 16, NST 3, NCUT 14
-- P: 1[-], 2[-], 3[O], 4[O], 5[-], 6[-], 7[-], 8[O], 
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
entity pg_float_sqrt_26_16_3 is
  port( x : in std_logic_vector(25 downto 0);
        z : out std_logic_vector(25 downto 0);
        clk : in std_logic);
end pg_float_sqrt_26_16_3;
architecture rtl of pg_float_sqrt_26_16_3 is

  component pg_float_sqrt_table_2itp_16_14_2
    port ( x : in std_logic_vector(17 downto 0);
           f : out std_logic_vector(19 downto 0);
           clk : in std_logic );
  end component;

signal signz0,signz1,signz2,signz3,signz3r0,signz3r,signz4,signz5,signz6 : std_logic;
signal nonzz0,nonzz1,nonzz2,nonzz3,nonzz3r0,nonzz3r,nonzz4,nonzz5,nonzz6 : std_logic;
signal emsb,elsb : std_logic;
signal expx,expxm,expxs,expxms : std_logic_vector(7 downto 0);
signal exps0,exps1,exps2,exps3,exps3r0,exps3r,exps4,exps5 : std_logic_vector(7 downto 0);
signal expp0,expp0r0,expp0r,expp1 : std_logic_vector(7 downto 0);
signal expz0,expz1 : std_logic_vector(7 downto 0);
signal is_one0,is_one1,is_one2,is_one3,is_one4,is_one4r0,is_one4r,is_one5,is_one6 : std_logic;
signal manx0 : std_logic_vector(15 downto 0);
signal manx1 : std_logic_vector(16 downto 0);
signal manx2,manx3,manx4,manx5 : std_logic_vector(17 downto 0);
signal is_two : std_logic;
signal tz0,tz1,tz2 : std_logic_vector(19 downto 0);
signal mz0,mz1,mz2 : std_logic_vector(15 downto 0);

begin

  signz0  <= x(25);
  nonzz0  <= x(24);
  expx    <= x(23 downto 16 );
  manx0   <= x(15 downto 0);

  with manx0 select
      is_one0 <= '1' when "0000000000000000",
                 '0' when others;

  manx1 <= '1' & manx0;
  manx2 <= manx1 & '1';
  manx3 <= '0' & manx1;
  with elsb select
      manx4 <= manx2 when '1',
               manx3 when others;
  with elsb select
      is_one1 <= is_one0 when '0',
                 '0' when others;

  emsb <= expx(7);
  elsb <= expx(0);
  expxm <= expx - "00000001";
  expxms <= emsb  & expxm(7 downto 1);
  expxs  <= emsb  & expx(7 downto 1);

  with elsb select
      exps0 <= expxms when '1',
               expxs  when others;

  -- PIPELINE 1 (OFF) -----------------------------------------------------------
--  process(clk) begin
--    if(clk'event and clk='1') then
      signz1 <= signz0;
      nonzz1 <= nonzz0;
      exps1  <= exps0;
      manx5  <= manx4;
      is_one2 <= is_one1;
--    end if;
--  end process;

  u0 : pg_float_sqrt_table_2itp_16_14_2 port map(x=>manx5, f=>tz0, clk=>clk); 

  -- PIPELINE 2 (OFF) -----------------------------------------------------------
--  process(clk) begin
--    if(clk'event and clk='1') then
      signz2 <= signz1;
      nonzz2 <= nonzz1;
      exps2  <= exps1;
      is_one3 <= is_one2;
--    end if;
--  end process;

  -- PIPELINE 3 ----------------------------------------------------------------
  process(clk) begin
    if(clk'event and clk='1') then
      signz3 <= signz2;
      nonzz3 <= nonzz2;
      exps3  <= exps2;
      is_one4 <= is_one3;
    end if;
  end process;

  -- PIPELINE 4 ----------------------------------------------------------------
  process(clk) begin
    if(clk'event and clk='1') then
      signz3r0 <= signz3;
      nonzz3r0 <= nonzz3;
      exps3r0  <= exps3;
      is_one4r0 <= is_one4;
    end if;
  end process;

  -- PIPELINE 5 (OFF) -----------------------------------------------------------
--  process(clk) begin
--    if(clk'event and clk='1') then
      signz3r <= signz3r0;
      nonzz3r <= nonzz3r0;
      exps3r  <= exps3r0;
      is_one4r <= is_one4r0;
--    end if;
--  end process;

  expp0 <= exps3r + "00000001";

  -- PIPELINE 6 (OFF) -----------------------------------------------------------
--  process(clk) begin
--    if(clk'event and clk='1') then
      signz4 <= signz3r;
      nonzz4 <= nonzz3r;
      exps4  <= exps3r;
      is_one5 <= is_one4r;
      expp0r  <= expp0;
--    end if;
--  end process;

  -- PIPELINE 7 (OFF) -----------------------------------------------------------
--  process(clk) begin
--    if(clk'event and clk='1') then
      signz5 <= signz4;
      nonzz5 <= nonzz4;
      exps5  <= exps4;
      expp1  <= expp0r;
      tz1    <= tz0;
      is_one6 <= is_one5;
--    end if;
--  end process;

  is_two <= tz1(19);
  with is_two select
      expz0 <= exps5 when '0',
               expp1 when others;
  with is_two select
      tz2 <= tz1 when '0',
             "00000000000000000000" when others;
  mz0 <= tz2(17 downto 2);
  with is_one6 select
      mz1 <= mz0 when '0',
             "0000000000000000" when others;

  -- PIPELINE 8 ----------------------------------------------------------------
  process(clk) begin
    if(clk'event and clk='1') then
      signz6 <= signz5;
      nonzz6 <= nonzz5;
      expz1  <= expz0;
      mz2    <= mz1;
    end if;
  end process;
  z(25) <= signz6;
  z(24) <= nonzz6;
  z(23 downto 16) <= expz1;
  z(15 downto 0)  <= mz2;

end rtl;
-- P: 1[-], 2[O], 3[-], 4[O], 5[-], 

-- ************************************************* 
-- * 2nd Order Polynominal for PG_FLOAT_SQRT       * 
-- * AUTHOR: Tsuyoshi Hamada                       * 
-- * VERSION: 1.01                                 * 
-- * LAST MODIFIED AT Tue Sep 29 13:01:00 JST 2004 * 
-- ************************************************* 
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity pg_float_sqrt_table_2itp_16_14_2 is
  port(x : in std_logic_vector(17 downto 0);
       f : out std_logic_vector(19 downto 0);
       clk : in std_logic);
end pg_float_sqrt_table_2itp_16_14_2;

architecture rtl of pg_float_sqrt_table_2itp_16_14_2 is 

  component lcell_rom_float_sqrt_c0_16_14_4_19_0
   port (indata: in std_logic_vector(3 downto 0);
         clk: in std_logic;
         outdata: out std_logic_vector(18 downto 0));
  end component;

  component lcell_rom_float_sqrt_c1_16_14_4_17_0
   port (indata: in std_logic_vector(3 downto 0);
         clk: in std_logic;
         outdata: out std_logic_vector(16 downto 0));
  end component;

  component lcell_rom_float_sqrt_c2_16_14_4_15_0
   port (indata: in std_logic_vector(3 downto 0);
         clk: in std_logic;
         outdata: out std_logic_vector(14 downto 0));
  end component;

  -- c1dx  <= itp_c1r * itp_dxr
  component pg_umult_14_17_0
   port (x: in std_logic_vector(13 downto 0);
         y: in std_logic_vector(16 downto 0);
         clk: in std_logic;
         z: out std_logic_vector(30 downto 0));
  end component;
  -- c2dx2 <= itp_c2r * itp_dx2r
  component pg_umult_12_15_0
   port (x: in std_logic_vector(11 downto 0);
         y: in std_logic_vector(14 downto 0);
         clk: in std_logic;
         z: out std_logic_vector(26 downto 0));
  end component;

  -- FOR INTERPOLATED TABLE
  signal itp_x : std_logic_vector(3 downto 0);
  signal itp_dx,itp_dxr0,itp_dxr : std_logic_vector(13 downto 0);
  signal itp_dx2 : std_logic_vector(27 downto 0);
  signal itp_dx2r : std_logic_vector(11 downto 0);
  signal c1dx : std_logic_vector(30 downto 0);
  signal c2dx2 : std_logic_vector(26 downto 0);
  signal mula,sba,sbar : std_logic_vector(14 downto 0);
  signal mulb : std_logic_vector(10 downto 0);
  signal itp_c0,itp_c0r0,itp_c0r,itp_c0r1,itp_c0r2,itp_c0r3 : std_logic_vector(18 downto 0);
  signal itp_c1,itp_c1r0,itp_c1r : std_logic_vector(16 downto 0);
  signal itp_c2,itp_c2r0,itp_c2r : std_logic_vector(14 downto 0);
  signal f0 : std_logic_vector(19 downto 0);

begin

-- TABLE FUNCTION PART (START) 
-- ********************************************************************* 
-- * PGPG CONV LOGARITHMIC TO FIXED-POINT MODULE OF                    * 
-- * INTERPORATED TABLE LOGIC : f(x+dx) ~= c0(x) + c1(x)dx+c2(x)(dx^2) * 
-- * The c0(x), c1(x) and c2(x) are chebyshev coefficients.            * 
-- ********************************************************************* 
  itp_x  <= x(17 downto 14);
  itp_dx <= x(13 downto 0);

  -- c0(x) --                                         
  itp_c0_rom: lcell_rom_float_sqrt_c0_16_14_4_19_0
  port map(indata=>itp_x,outdata=>itp_c0,clk=>clk);

  -- c1(x) --                                         
  itp_c1_rom: lcell_rom_float_sqrt_c1_16_14_4_17_0
  port map(indata=>itp_x,outdata=>itp_c1,clk=>clk);

  -- c2(x) --                                         
  itp_c2_rom: lcell_rom_float_sqrt_c2_16_14_4_15_0
  port map(indata=>itp_x,outdata=>itp_c2,clk=>clk);

  itp_dx2 <= itp_dx * itp_dx;

  --- PIPELINE 1(OFF) ---
    itp_dxr0 <= itp_dx;           
    itp_c0r0 <= itp_c0;            
    itp_c1r0 <= itp_c1;            
    itp_c2r0 <= itp_c2;            
  ----------------------.
  --- PIPELINE 2 ---
  process(clk) begin              
    if(clk'event and clk='1') then
      itp_dxr <= itp_dxr0;        
      itp_dx2r <= itp_dx2(27 downto 16);
      itp_c0r <= itp_c0r0;        
      itp_c1r <= itp_c1r0;        
      itp_c2r <= itp_c2r0;        
    end if;                       
  end process;                    
  ----------------------.


  -- c1dx  <= itp_c1r * itp_dxr
  mult1 : pg_umult_14_17_0
   port map (x => itp_dxr,
             y => itp_c1r,
             z => c1dx,
             clk=>clk);

  -- c2dx2  <= itp_c2r * itp_dx2r
  mult2 : pg_umult_12_15_0
   port map (x => itp_dx2r,
             y => itp_c2r,
             z => c2dx2,
             clk=>clk);

  --- PIPELINE 3(OFF) ---
--  process(clk) begin              
--    if(clk'event and clk='1') then
      itp_c0r1 <= itp_c0r;          
--    end if;                       
--  end process;                    
  ----------------------.


  --- PIPELINE 4 ---
  process(clk) begin              
    if(clk'event and clk='1') then
      itp_c0r2 <= itp_c0r1;        
      mula <= c1dx(30 downto 16);    
      mulb <= c2dx2(26 downto 16);   
    end if;                       
  end process;                    
  ----------------------.


sba <= mula - ("0000" & mulb);  --  always positive !!


  --- PIPELINE 5(OFF) ---
--  process(clk) begin              
--    if(clk'event and clk='1') then
      itp_c0r3 <= itp_c0r2;       
      sbar <= sba;                
--    end if;                       
--  end process;                    
  ----------------------.


  f0 <= ('0'&itp_c0r3) + ("00000" & sbar);
  f <= f0;
end rtl;



--+--------------------------------+
--| PGR unsigned multiplier        |
--|  2006-04-14 16:24:06           |
--|      by Tsuyoshi Hamada        |
--+--------------------------------+
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity pg_umult_14_17_0 is
  port(x : in std_logic_vector(13 downto 0);
       y : in std_logic_vector(16 downto 0);
       z : out std_logic_vector(30 downto 0);
     clk : in std_logic);
end pg_umult_14_17_0;

architecture rtl of pg_umult_14_17_0 is

  signal s : std_logic_vector(30 downto 0);
begin
  s <= x * y;
  z <= s;
end rtl;

--+--------------------------------+
--| PGR unsigned multiplier        |
--|  2006-04-14 16:24:06           |
--|      by Tsuyoshi Hamada        |
--+--------------------------------+
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity pg_umult_12_15_0 is
  port(x : in std_logic_vector(11 downto 0);
       y : in std_logic_vector(14 downto 0);
       z : out std_logic_vector(26 downto 0);
     clk : in std_logic);
end pg_umult_12_15_0;

architecture rtl of pg_umult_12_15_0 is

  signal s : std_logic_vector(26 downto 0);
begin
  s <= x * y;
  z <= s;
end rtl;
                                   
-- ROM using Lcell not ESB         
-- Author: Tsuyoshi Hamada         
-- Last Modified at May 29,2003    
-- In 4 Out 19 Stage 0 Type"float_sqrt_c0_16_14"
library ieee;                      
use ieee.std_logic_1164.all;       
                                   
entity lcell_rom_float_sqrt_c0_16_14_4_19_0 is
  port( indata : in std_logic_vector(3 downto 0);
        clk : in std_logic;
        outdata : out std_logic_vector(18 downto 0));
end lcell_rom_float_sqrt_c0_16_14_4_19_0;

architecture rtl of lcell_rom_float_sqrt_c0_16_14_4_19_0 is

  component pg_lcell
    generic (MASK : bit_vector  := X"ffff";
             FF   : integer :=0);
    port (x   : in  std_logic_vector(3 downto 0);
          z   : out std_logic;
          clk : in  std_logic);
  end component;

  signal adr0 : std_logic_vector(3 downto 0);

begin

  adr0 <= indata;
  LC_00 : pg_lcell  generic map(MASK=>X"C47C",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(0));
  LC_01 : pg_lcell  generic map(MASK=>X"4FF4",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(1));
  LC_02 : pg_lcell  generic map(MASK=>X"2C5B",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(2));
  LC_03 : pg_lcell  generic map(MASK=>X"E90B",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(3));
  LC_04 : pg_lcell  generic map(MASK=>X"CC0F",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(4));
  LC_05 : pg_lcell  generic map(MASK=>X"D1E6",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(5));
  LC_06 : pg_lcell  generic map(MASK=>X"802B",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(6));
  LC_07 : pg_lcell  generic map(MASK=>X"D0A8",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(7));
  LC_08 : pg_lcell  generic map(MASK=>X"5400",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(8));
  LC_09 : pg_lcell  generic map(MASK=>X"ECC8",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(9));
  LC_10 : pg_lcell  generic map(MASK=>X"B04C",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(10));
  LC_11 : pg_lcell  generic map(MASK=>X"D1A1",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(11));
  LC_12 : pg_lcell  generic map(MASK=>X"E42D",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(12));
  LC_13 : pg_lcell  generic map(MASK=>X"F968",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(13));
  LC_14 : pg_lcell  generic map(MASK=>X"54ED",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(14));
  LC_15 : pg_lcell  generic map(MASK=>X"9944",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(15));
  LC_16 : pg_lcell  generic map(MASK=>X"E188",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(16));
  LC_17 : pg_lcell  generic map(MASK=>X"FE0E",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(17));
  LC_18 : pg_lcell  generic map(MASK=>X"FFF0",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(18));
end rtl;
                                   
-- ROM using Lcell not ESB         
-- Author: Tsuyoshi Hamada         
-- Last Modified at May 29,2003    
-- In 4 Out 17 Stage 0 Type"float_sqrt_c1_16_14"
library ieee;                      
use ieee.std_logic_1164.all;       
                                   
entity lcell_rom_float_sqrt_c1_16_14_4_17_0 is
  port( indata : in std_logic_vector(3 downto 0);
        clk : in std_logic;
        outdata : out std_logic_vector(16 downto 0));
end lcell_rom_float_sqrt_c1_16_14_4_17_0;

architecture rtl of lcell_rom_float_sqrt_c1_16_14_4_17_0 is

  component pg_lcell
    generic (MASK : bit_vector  := X"ffff";
             FF   : integer :=0);
    port (x   : in  std_logic_vector(3 downto 0);
          z   : out std_logic;
          clk : in  std_logic);
  end component;

  signal adr0 : std_logic_vector(3 downto 0);

begin

  adr0 <= indata;
  LC_00 : pg_lcell  generic map(MASK=>X"EC87",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(0));
  LC_01 : pg_lcell  generic map(MASK=>X"05C2",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(1));
  LC_02 : pg_lcell  generic map(MASK=>X"6972",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(2));
  LC_03 : pg_lcell  generic map(MASK=>X"15B4",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(3));
  LC_04 : pg_lcell  generic map(MASK=>X"DE6C",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(4));
  LC_05 : pg_lcell  generic map(MASK=>X"311D",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(5));
  LC_06 : pg_lcell  generic map(MASK=>X"B067",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(6));
  LC_07 : pg_lcell  generic map(MASK=>X"6DA9",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(7));
  LC_08 : pg_lcell  generic map(MASK=>X"774C",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(8));
  LC_09 : pg_lcell  generic map(MASK=>X"349D",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(9));
  LC_10 : pg_lcell  generic map(MASK=>X"1A12",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(10));
  LC_11 : pg_lcell  generic map(MASK=>X"A13E",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(11));
  LC_12 : pg_lcell  generic map(MASK=>X"6A13",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(12));
  LC_13 : pg_lcell  generic map(MASK=>X"1950",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(13));
  LC_14 : pg_lcell  generic map(MASK=>X"073E",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(14));
  LC_15 : pg_lcell  generic map(MASK=>X"00F7",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(15));
  LC_16 : pg_lcell  generic map(MASK=>X"FFF2",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(16));
end rtl;
                                   
-- ROM using Lcell not ESB         
-- Author: Tsuyoshi Hamada         
-- Last Modified at May 29,2003    
-- In 4 Out 15 Stage 0 Type"float_sqrt_c2_16_14"
library ieee;                      
use ieee.std_logic_1164.all;       
                                   
entity lcell_rom_float_sqrt_c2_16_14_4_15_0 is
  port( indata : in std_logic_vector(3 downto 0);
        clk : in std_logic;
        outdata : out std_logic_vector(14 downto 0));
end lcell_rom_float_sqrt_c2_16_14_4_15_0;

architecture rtl of lcell_rom_float_sqrt_c2_16_14_4_15_0 is

  component pg_lcell
    generic (MASK : bit_vector  := X"ffff";
             FF   : integer :=0);
    port (x   : in  std_logic_vector(3 downto 0);
          z   : out std_logic;
          clk : in  std_logic);
  end component;

  signal adr0 : std_logic_vector(3 downto 0);

begin

  adr0 <= indata;
  LC_00 : pg_lcell  generic map(MASK=>X"101C",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(0));
  LC_01 : pg_lcell  generic map(MASK=>X"232B",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(1));
  LC_02 : pg_lcell  generic map(MASK=>X"7E16",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(2));
  LC_03 : pg_lcell  generic map(MASK=>X"D7A1",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(3));
  LC_04 : pg_lcell  generic map(MASK=>X"0712",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(4));
  LC_05 : pg_lcell  generic map(MASK=>X"32C8",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(5));
  LC_06 : pg_lcell  generic map(MASK=>X"8BC0",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(6));
  LC_07 : pg_lcell  generic map(MASK=>X"E2F6",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(7));
  LC_08 : pg_lcell  generic map(MASK=>X"11FD",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(8));
  LC_09 : pg_lcell  generic map(MASK=>X"5E31",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(9));
  LC_10 : pg_lcell  generic map(MASK=>X"346E",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(10));
  LC_11 : pg_lcell  generic map(MASK=>X"0D7B",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(11));
  LC_12 : pg_lcell  generic map(MASK=>X"FCCA",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(12));
  LC_13 : pg_lcell  generic map(MASK=>X"03D3",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(13));
  LC_14 : pg_lcell  generic map(MASK=>X"0030",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(14));
end rtl;
-- PGR Floating-Point Reciprocator
-- by Tsuyoshi Hamada (2004/09/30)
-- P: 1[-], 2[O], 3[-], 4[-], 5[-], 6[-], 7[-], 8[O], 
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
entity pg_float_recipro_26_16_2 is
  port( x : in std_logic_vector(25 downto 0);
        z : out std_logic_vector(25 downto 0);
        clk : in std_logic);
end pg_float_recipro_26_16_2;
architecture rtl of pg_float_recipro_26_16_2 is

  component pg_float_recipro_table_2itp_16_12_1
    port ( x : in std_logic_vector(15 downto 0);
           f : out std_logic_vector(17 downto 0);
           clk : in std_logic );
  end component;

signal signz0,signz0r,signz0r0,signz1,signz2,signz3,signz4,signz5,signz6 : std_logic;
signal nonzz0,nonzz0r,nonzz0r0,nonzz1,nonzz2,nonzz3,nonzz4,nonzz5,nonzz6 : std_logic;
signal expx : std_logic_vector(7 downto 0);
signal expi0,expi0r,expi0r0,expi1,expi2,expi3,expi4,expi5 : std_logic_vector(7 downto 0);
signal expm0,expm1 : std_logic_vector(7 downto 0);
signal manx : std_logic_vector(15 downto 0);
signal minv0,minv1,minv2 : std_logic_vector(17 downto 0);
signal tman : std_logic_vector(15 downto 0);
signal is_one0,is_one0r,is_one0r0,is_one1,is_one2,is_one3,is_one4,is_one5 : std_logic;
signal ez0,ez1 : std_logic_vector(7 downto 0);
signal mz0,mz1 : std_logic_vector(15 downto 0);

begin

  signz0  <= x(25);        
  nonzz0  <= x(24);        
  expx <= x(23 downto 16 );
  manx <= x(15 downto 0);  

  expi0 <= "00000000" - expx;

  with manx select
      is_one0 <= '1' when "0000000000000000",
                 '0' when others;

  u0 : pg_float_recipro_table_2itp_16_12_1 port map(x=>manx, f=>minv0, clk=>clk); 

  -- PIPELINE 1 (OFF) -----------------------------------------------------------
--  process(clk) begin
--    if(clk'event and clk='1') then
      signz0r  <= signz0;
      nonzz0r  <= nonzz0;
      is_one0r <= is_one0;
      expi0r   <= expi0;
--    end if;
--  end process;

  -- PIPELINE 2 ----------------------------------------------------------------
  process(clk) begin
    if(clk'event and clk='1') then
      signz0r0  <= signz0r;
      nonzz0r0  <= nonzz0r;
      is_one0r0 <= is_one0r;
      expi0r0   <= expi0r;
    end if;
  end process;

  -- PIPELINE 3 (OFF) -----------------------------------------------------------
--  process(clk) begin
--    if(clk'event and clk='1') then
      signz1  <= signz0r0;
      nonzz1  <= nonzz0r0;
      is_one1 <= is_one0r0;
      expi1   <= expi0r0;
--    end if;
--  end process;

  -- PIPELINE 4 (OFF) -----------------------------------------------------------
--  process(clk) begin
--    if(clk'event and clk='1') then
      signz2  <= signz1;
      nonzz2  <= nonzz1;
      is_one2 <= is_one1;
      expi2   <= expi1;
--    end if;
--  end process;

  -- PIPELINE 5 (OFF) -----------------------------------------------------------
--  process(clk) begin
--    if(clk'event and clk='1') then
      signz3  <= signz2;
      nonzz3  <= nonzz2;
      is_one3 <= is_one2;
      expi3   <= expi2;
--    end if;
--  end process;

  -- PIPELINE 6 (OFF) -----------------------------------------------------------
--  process(clk) begin
--    if(clk'event and clk='1') then
      signz4  <= signz3;
      nonzz4  <= nonzz3;
      is_one4 <= is_one3;
      expi4   <= expi3;
      minv1   <= minv0;
--    end if;
--  end process;

  expm0 <= expi4 - "00000001";

  -- PIPELINE 7 (OFF) -----------------------------------------------------------
--  process(clk) begin
--    if(clk'event and clk='1') then
      signz5  <= signz4;
      nonzz5  <= nonzz4;
      is_one5 <= is_one4;
      expi5   <= expi4;
      minv2   <= minv1;
      expm1   <= expm0;
--    end if;
--  end process;

-- buf  : minv >> (nbit_ext-1)
-- tman : ((0x1<<nbit_man)-1) & (buf | 0x1)
  tman <= minv2(16 downto 2) & '1'; -- normalize, rounding

  with is_one5 select
      mz0 <= tman when '0',
            "0000000000000000" when others;

  with is_one5 select
      ez0 <= expm1 when '0',
             expi5 when others;

  -- PIPELINE 8 ----------------------------------------------------------------
  process(clk) begin
    if(clk'event and clk='1') then
      signz6 <= signz5;
      nonzz6 <= nonzz5;
      ez1    <= ez0;
      mz1    <= mz0;
    end if;
  end process;
  z(25) <= signz6;
  z(24) <= nonzz6;
  z(23 downto 16) <= ez1;
  z(15 downto 0)  <= mz1;

end rtl;

-- ************************************************* 
-- * 2nd Order Polynominal for PG_FLOAT_RECIPRO    * 
-- * AUTHOR: Tsuyoshi Hamada                       * 
-- * VERSION: 1.01                                 * 
-- * LAST MODIFIED AT Tue Sep 29 13:01:00 JST 2004 * 
-- ************************************************* 
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity pg_float_recipro_table_2itp_16_12_1 is
  port(x : in std_logic_vector(15 downto 0);
       f : out std_logic_vector(17 downto 0);
       clk : in std_logic);
end pg_float_recipro_table_2itp_16_12_1;

architecture rtl of pg_float_recipro_table_2itp_16_12_1 is 

  component lcell_rom_float_recipro_c0_16_12_4_18_0
   port (indata: in std_logic_vector(3 downto 0);
         clk: in std_logic;
         outdata: out std_logic_vector(17 downto 0));
  end component;

  component lcell_rom_float_recipro_c1_16_12_4_18_0
   port (indata: in std_logic_vector(3 downto 0);
         clk: in std_logic;
         outdata: out std_logic_vector(17 downto 0));
  end component;

  component lcell_rom_float_recipro_c2_16_12_4_18_0
   port (indata: in std_logic_vector(3 downto 0);
         clk: in std_logic;
         outdata: out std_logic_vector(17 downto 0));
  end component;

  -- c1dx  <= itp_c1r * itp_dxr
  component pg_umult_12_18_1
   port (x: in std_logic_vector(11 downto 0);
         y: in std_logic_vector(17 downto 0);
         clk: in std_logic;
         z: out std_logic_vector(29 downto 0));
  end component;
  -- c2dx2 <= itp_c2r * itp_dx2r
  component pg_umult_8_18_1
   port (x: in std_logic_vector(7 downto 0);
         y: in std_logic_vector(17 downto 0);
         clk: in std_logic;
         z: out std_logic_vector(25 downto 0));
  end component;

  -- FOR INTERPOLATED TABLE
  signal itp_x : std_logic_vector(3 downto 0);
  signal itp_dx,itp_dxr0,itp_dxr : std_logic_vector(11 downto 0);
  signal itp_dx2 : std_logic_vector(23 downto 0);
  signal itp_dx2r : std_logic_vector(7 downto 0);
  signal c1dx : std_logic_vector(29 downto 0);
  signal c2dx2 : std_logic_vector(25 downto 0);
  signal mula,sba,sbar : std_logic_vector(13 downto 0);
  signal mulb : std_logic_vector(9 downto 0);
  signal itp_c0,itp_c0r,itp_c0r0,itp_c0r1,itp_c0r2,itp_c0r3 : std_logic_vector(17 downto 0);
  signal itp_c1,itp_c1r0,itp_c1r : std_logic_vector(17 downto 0);
  signal itp_c2,itp_c2r0,itp_c2r : std_logic_vector(17 downto 0);
  signal f0 : std_logic_vector(18 downto 0);

begin

-- TABLE FUNCTION PART (START) 
-- ********************************************************************* 
-- * PGR CONV LOGARITHMIC TO FIXED-POINT MODULE OF                     * 
-- * INTERPORATED TABLE LOGIC : f(x+dx) ~= c0(x) + c1(x)dx+c2(x)(dx^2) * 
-- * The c0(x), c1(x) and c2(x) are chebyshev coefficients.            * 
-- ********************************************************************* 
  itp_x  <= x(15 downto 12);
  itp_dx <= x(11 downto 0);

  -- c0(x) --                                         
  itp_c0_rom: lcell_rom_float_recipro_c0_16_12_4_18_0
  port map(indata=>itp_x,outdata=>itp_c0,clk=>clk);

  -- c1(x) --                                         
  itp_c1_rom: lcell_rom_float_recipro_c1_16_12_4_18_0
  port map(indata=>itp_x,outdata=>itp_c1,clk=>clk);

  -- c2(x) --                                         
  itp_c2_rom: lcell_rom_float_recipro_c2_16_12_4_18_0
  port map(indata=>itp_x,outdata=>itp_c2,clk=>clk);

  itp_dx2 <= itp_dx * itp_dx;

  --- PIPELINE 1(OFF) ---
    itp_dxr0 <= itp_dx;            
    itp_c0r <= itp_c0;            
    itp_c1r <= itp_c1;            
    itp_c2r <= itp_c2;            
  ----------------------.
  --- PIPELINE 2(OFF) ---
--  process(clk) begin              
--    if(clk'event and clk='1') then
      itp_dxr <= itp_dxr0;            
      itp_dx2r <= itp_dx2(23 downto 16);
      itp_c0r0 <= itp_c0r;          
      itp_c1r0 <= itp_c1r;          
      itp_c2r0 <= itp_c2r;          
--    end if;                       
--  end process;                    
  ----------------------.


  -- c1dx  <= itp_c1r0 * itp_dxr
  mult1 : pg_umult_12_18_1
   port map (x => itp_dxr,
             y => itp_c1r0,
             z => c1dx,
             clk=>clk);

  -- c2dx2  <= itp_c2r0 * itp_dx2r
  mult2 : pg_umult_8_18_1
   port map (x => itp_dx2r,
             y => itp_c2r0,
             z => c2dx2,
             clk=>clk);

  --- PIPELINE 3 ---
  process(clk) begin              
    if(clk'event and clk='1') then
      itp_c0r1 <= itp_c0r0;       
    end if;                       
  end process;                    
  ----------------------.


  --- PIPELINE 4(OFF) ---
--  process(clk) begin              
--    if(clk'event and clk='1') then
      itp_c0r2 <= itp_c0r1;          
      mula <= c1dx(29 downto 16);    
      mulb <= c2dx2(25 downto 16);   
--    end if;                       
--  end process;                    
  ----------------------.


sba <= mula - ("0000" & mulb);  --  always positive !!


  --- PIPELINE 5(OFF) ---
--  process(clk) begin              
--    if(clk'event and clk='1') then
      itp_c0r3 <= itp_c0r2;       
      sbar <= sba;                
--    end if;                       
--  end process;                    
  ----------------------.


  f0 <= ('0'&itp_c0r3) - ("00000" & sbar);
  f <= f0(17 downto 0); -- f0 : always positive
end rtl;



--+--------------------------------+
--| PGR unsigned multiplier        |
--|  2006-04-14 16:24:06           |
--|      by Tsuyoshi Hamada        |
--+--------------------------------+
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity pg_umult_12_18_1 is
  port(x : in std_logic_vector(11 downto 0);
       y : in std_logic_vector(17 downto 0);
       z : out std_logic_vector(29 downto 0);
     clk : in std_logic);
end pg_umult_12_18_1;

architecture rtl of pg_umult_12_18_1 is

  signal s : std_logic_vector(29 downto 0);
begin

  s <= x * y;

  process(clk) begin
    if(clk'event and clk='1') then
      z <= s;
    end if;
  end process;

end rtl;

--+--------------------------------+
--| PGR unsigned multiplier        |
--|  2006-04-14 16:24:06           |
--|      by Tsuyoshi Hamada        |
--+--------------------------------+
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity pg_umult_8_18_1 is
  port(x : in std_logic_vector(7 downto 0);
       y : in std_logic_vector(17 downto 0);
       z : out std_logic_vector(25 downto 0);
     clk : in std_logic);
end pg_umult_8_18_1;

architecture rtl of pg_umult_8_18_1 is

  signal s : std_logic_vector(25 downto 0);
begin

  s <= x * y;

  process(clk) begin
    if(clk'event and clk='1') then
      z <= s;
    end if;
  end process;

end rtl;
                                   
-- ROM using Lcell not ESB         
-- Author: Tsuyoshi Hamada         
-- Last Modified at May 29,2003    
-- In 4 Out 18 Stage 0 Type"float_recipro_c0_16_12"
library ieee;                      
use ieee.std_logic_1164.all;       
                                   
entity lcell_rom_float_recipro_c0_16_12_4_18_0 is
  port( indata : in std_logic_vector(3 downto 0);
        clk : in std_logic;
        outdata : out std_logic_vector(17 downto 0));
end lcell_rom_float_recipro_c0_16_12_4_18_0;

architecture rtl of lcell_rom_float_recipro_c0_16_12_4_18_0 is

  component pg_lcell
    generic (MASK : bit_vector  := X"ffff";
             FF   : integer :=0);
    port (x   : in  std_logic_vector(3 downto 0);
          z   : out std_logic;
          clk : in  std_logic);
  end component;

  signal adr0 : std_logic_vector(3 downto 0);

begin

  adr0 <= indata;
  LC_00 : pg_lcell  generic map(MASK=>X"2404",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(0));
  LC_01 : pg_lcell  generic map(MASK=>X"6557",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(1));
  LC_02 : pg_lcell  generic map(MASK=>X"B605",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(2));
  LC_03 : pg_lcell  generic map(MASK=>X"03C1",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(3));
  LC_04 : pg_lcell  generic map(MASK=>X"2AFD",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(4));
  LC_05 : pg_lcell  generic map(MASK=>X"7575",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(5));
  LC_06 : pg_lcell  generic map(MASK=>X"2A8B",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(6));
  LC_07 : pg_lcell  generic map(MASK=>X"A943",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(7));
  LC_08 : pg_lcell  generic map(MASK=>X"1213",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(8));
  LC_09 : pg_lcell  generic map(MASK=>X"4F1F",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(9));
  LC_10 : pg_lcell  generic map(MASK=>X"2E2D",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(10));
  LC_11 : pg_lcell  generic map(MASK=>X"1BED",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(11));
  LC_12 : pg_lcell  generic map(MASK=>X"AC19",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(12));
  LC_13 : pg_lcell  generic map(MASK=>X"6551",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(13));
  LC_14 : pg_lcell  generic map(MASK=>X"1CCB",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(14));
  LC_15 : pg_lcell  generic map(MASK=>X"03C7",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(15));
  LC_16 : pg_lcell  generic map(MASK=>X"003F",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(16));
  outdata(17) <= '1';
end rtl;
                                   
-- ROM using Lcell not ESB         
-- Author: Tsuyoshi Hamada         
-- Last Modified at May 29,2003    
-- In 4 Out 18 Stage 0 Type"float_recipro_c1_16_12"
library ieee;                      
use ieee.std_logic_1164.all;       
                                   
entity lcell_rom_float_recipro_c1_16_12_4_18_0 is
  port( indata : in std_logic_vector(3 downto 0);
        clk : in std_logic;
        outdata : out std_logic_vector(17 downto 0));
end lcell_rom_float_recipro_c1_16_12_4_18_0;

architecture rtl of lcell_rom_float_recipro_c1_16_12_4_18_0 is

  component pg_lcell
    generic (MASK : bit_vector  := X"ffff";
             FF   : integer :=0);
    port (x   : in  std_logic_vector(3 downto 0);
          z   : out std_logic;
          clk : in  std_logic);
  end component;

  signal adr0 : std_logic_vector(3 downto 0);

begin

  adr0 <= indata;
  LC_00 : pg_lcell  generic map(MASK=>X"303A",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(0));
  LC_01 : pg_lcell  generic map(MASK=>X"1679",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(1));
  LC_02 : pg_lcell  generic map(MASK=>X"08F1",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(2));
  LC_03 : pg_lcell  generic map(MASK=>X"449D",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(3));
  LC_04 : pg_lcell  generic map(MASK=>X"4F3A",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(4));
  LC_05 : pg_lcell  generic map(MASK=>X"9533",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(5));
  LC_06 : pg_lcell  generic map(MASK=>X"0C17",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(6));
  LC_07 : pg_lcell  generic map(MASK=>X"A125",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(7));
  LC_08 : pg_lcell  generic map(MASK=>X"6EEF",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(8));
  LC_09 : pg_lcell  generic map(MASK=>X"7F94",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(9));
  LC_10 : pg_lcell  generic map(MASK=>X"39DD",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(10));
  LC_11 : pg_lcell  generic map(MASK=>X"10D3",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(11));
  LC_12 : pg_lcell  generic map(MASK=>X"A069",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(12));
  LC_13 : pg_lcell  generic map(MASK=>X"6A85",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(13));
  LC_14 : pg_lcell  generic map(MASK=>X"19A9",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(14));
  LC_15 : pg_lcell  generic map(MASK=>X"079B",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(15));
  LC_16 : pg_lcell  generic map(MASK=>X"FF87",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(16));
  LC_17 : pg_lcell  generic map(MASK=>X"007F",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(17));
end rtl;
                                   
-- ROM using Lcell not ESB         
-- Author: Tsuyoshi Hamada         
-- Last Modified at May 29,2003    
-- In 4 Out 18 Stage 0 Type"float_recipro_c2_16_12"
library ieee;                      
use ieee.std_logic_1164.all;       
                                   
entity lcell_rom_float_recipro_c2_16_12_4_18_0 is
  port( indata : in std_logic_vector(3 downto 0);
        clk : in std_logic;
        outdata : out std_logic_vector(17 downto 0));
end lcell_rom_float_recipro_c2_16_12_4_18_0;

architecture rtl of lcell_rom_float_recipro_c2_16_12_4_18_0 is

  component pg_lcell
    generic (MASK : bit_vector  := X"ffff";
             FF   : integer :=0);
    port (x   : in  std_logic_vector(3 downto 0);
          z   : out std_logic;
          clk : in  std_logic);
  end component;

  signal adr0 : std_logic_vector(3 downto 0);

begin

  adr0 <= indata;
  LC_00 : pg_lcell  generic map(MASK=>X"8EDA",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(0));
  LC_01 : pg_lcell  generic map(MASK=>X"BA15",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(1));
  LC_02 : pg_lcell  generic map(MASK=>X"C3E4",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(2));
  LC_03 : pg_lcell  generic map(MASK=>X"79C7",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(3));
  LC_04 : pg_lcell  generic map(MASK=>X"DC7B",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(4));
  LC_05 : pg_lcell  generic map(MASK=>X"BC28",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(5));
  LC_06 : pg_lcell  generic map(MASK=>X"65CD",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(6));
  LC_07 : pg_lcell  generic map(MASK=>X"480C",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(7));
  LC_08 : pg_lcell  generic map(MASK=>X"7F9A",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(8));
  LC_09 : pg_lcell  generic map(MASK=>X"E0B7",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(9));
  LC_10 : pg_lcell  generic map(MASK=>X"933F",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(10));
  LC_11 : pg_lcell  generic map(MASK=>X"0B02",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(11));
  LC_12 : pg_lcell  generic map(MASK=>X"534C",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(12));
  LC_13 : pg_lcell  generic map(MASK=>X"3679",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(13));
  LC_14 : pg_lcell  generic map(MASK=>X"0ED0",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(14));
  LC_15 : pg_lcell  generic map(MASK=>X"FE35",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(15));
  LC_16 : pg_lcell  generic map(MASK=>X"01F3",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(16));
  LC_17 : pg_lcell  generic map(MASK=>X"000F",FF=>0)  port map( x=>adr0(3 downto 0),clk=>clk,z=>outdata(17));
end rtl;

library ieee;
use ieee.std_logic_1164.all;

entity pg_bits_delay_26_16 is
  port( x : in std_logic_vector(25 downto 0);
	      y : out std_logic_vector(25 downto 0);
	     clk: in std_logic);
end pg_bits_delay_26_16;

architecture rtl of pg_bits_delay_26_16 is

  signal x0 : std_logic_vector(25 downto 0);
  signal x1 : std_logic_vector(25 downto 0);
  signal x2 : std_logic_vector(25 downto 0);
  signal x3 : std_logic_vector(25 downto 0);
  signal x4 : std_logic_vector(25 downto 0);
  signal x5 : std_logic_vector(25 downto 0);
  signal x6 : std_logic_vector(25 downto 0);
  signal x7 : std_logic_vector(25 downto 0);
  signal x8 : std_logic_vector(25 downto 0);
  signal x9 : std_logic_vector(25 downto 0);
  signal x10 : std_logic_vector(25 downto 0);
  signal x11 : std_logic_vector(25 downto 0);
  signal x12 : std_logic_vector(25 downto 0);
  signal x13 : std_logic_vector(25 downto 0);
  signal x14 : std_logic_vector(25 downto 0);
  signal x15 : std_logic_vector(25 downto 0);
  signal x16 : std_logic_vector(25 downto 0);

begin

  x0 <= x;

  process(clk) begin
    if(clk'event and clk='1') then
      x16 <= x15;
      x15 <= x14;
      x14 <= x13;
      x13 <= x12;
      x12 <= x11;
      x11 <= x10;
      x10 <= x9;
      x9 <= x8;
      x8 <= x7;
      x7 <= x6;
      x6 <= x5;
      x5 <= x4;
      x4 <= x3;
      x3 <= x2;
      x2 <= x1;
      x1 <= x0;
    end if;
  end process;

  y <= x16;

end rtl;
-- PGPG Register File
-- by Tsuyoshi Hamada (2004/10/08)
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity pg_bits_regifile_26 is
  port(x : in std_logic_vector(25 downto 0);
       z: out std_logic_vector(25 downto 0);
       run : in std_logic;
       clk : in std_logic);
end pg_bits_regifile_26;

architecture rtl of pg_bits_regifile_26 is
signal x0 : std_logic_vector(25 downto 0) := (others=>'0');
signal runr0,runr1 : std_logic            := '0';
begin
  -- runr
  process(clk) begin
    if(clk'event and clk='1') then
      runr1 <= runr0;
      runr0 <= run;
    end if;
  end process;

  process(clk) begin
    if(clk'event and clk='1') then
      if(runr0='1') then
        x0 <= x;
      end if;
    end if;
  end process;
  z <= x0;

end rtl;
-- PGR Floating-Point ExpAdd
-- by Tsuyoshi Hamada (2005/03/04)
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
entity pg_float_expadd_31_26_16_1 is
  port( x : in std_logic_vector(25 downto 0);
        z : out std_logic_vector(25 downto 0);
        clk : in std_logic);
end pg_float_expadd_31_26_16_1;
architecture rtl of pg_float_expadd_31_26_16_1 is
constant expadd : std_logic_vector(7 downto 0):="00011111"; -- 31
signal signz,nonzz : std_logic;
signal expx,expz : std_logic_vector(7 downto 0);
signal manz : std_logic_vector(15 downto 0);
signal z0 : std_logic_vector(25 downto 0);

begin

  z0(25)  <= x(25);
  z0(24)  <= x(24);
  z0(15 downto 0) <= x(15 downto 0);

  expx <= x(23 downto 16 );
  expz <= expx + expadd;
  z0(23 downto 16) <= expz;
  process(clk) begin
    if(clk'event and clk='1') then
      z <= z0;
    end if;
  end process;

end rtl;
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity pg_float_fixaccum_26_16_57_64_2_0 is
  port(x : in std_logic_vector(25 downto 0);
        z: out std_logic_vector(63 downto 0);
       run : in std_logic;
       clk : in std_logic);
end pg_float_fixaccum_26_16_57_64_2_0;

architecture rtl of pg_float_fixaccum_26_16_57_64_2_0 is

component pg_conv_floattofix_26_16_57_1_0 
  port(x : in std_logic_vector(25 downto 0);
       z : out std_logic_vector(56 downto 0);
       clk : in std_logic);
end component;

component pg_fix_smaccum_57_64_1 
  port(fdata : in std_logic_vector(56 downto 0);
        sdata: out std_logic_vector(63 downto 0);
       run,clk : in std_logic);
end component;

signal run0,run1,run2,run3,run4,run5 : std_logic;
signal fdata : std_logic_vector(56 downto 0);
begin

  run0 <= run;

  process(clk) begin
    if(clk'event and clk='1') then
      run1 <= run0;
    end if;
  end process;
  run2 <= run1;
  run3 <= run2;
  run4 <= run3;
  run5 <= run4;

  u0 : pg_conv_floattofix_26_16_57_1_0 port map(
         x=>x, z=>fdata, clk=>clk);

  u1 : pg_fix_smaccum_57_64_1 port map(
         fdata=>fdata,
         sdata => z,
         run=>run5, clk=>clk);

end rtl;
-- PGPG Floating-Point to Fixed-Point Converter
-- by Tsuyoshi Hamada (2004/10/20)
-- P: 1[-], 2[-], 3[-], 4[-], 5[-], 6[O], 
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
entity pg_conv_floattofix_26_16_57_1_0 is
  port( x : in std_logic_vector(25 downto 0);
        z : out std_logic_vector(56 downto 0);
        clk : in std_logic);
end pg_conv_floattofix_26_16_57_1_0;
architecture rtl of pg_conv_floattofix_26_16_57_1_0 is

  component pg_conv_floattofix_shift_16_7_56_0
    port ( x : in std_logic_vector(15 downto 0);
           c : in std_logic_vector(6 downto 0);
           z : out std_logic_vector(55 downto 0);
           clk : in std_logic );
  end component;

signal erase,ovflow,nonzx : std_logic;
signal nshift : std_logic_vector(6 downto 0);
signal manx : std_logic_vector(15 downto 0);
signal signz0,signz1,signz2,signz3,signz4,signz5 : std_logic;
signal check_ov : std_logic_vector(7 downto 0);
signal mansf0, mansf1: std_logic_vector(55 downto 0);
signal isz0,isz1,isz2,isz3,isz4,isz5 : std_logic;
signal z0: std_logic_vector(55 downto 0);
begin

  signz0 <= x(25);
  nonzx  <= x(24);
  erase  <=  x(23);
  nshift <= x(22 downto 16);
  manx   <= x(15 downto 0);  -- economic

  --  OVERFLOW DETECTION : (nshift>=57) ? 1 : 0
  check_ov <= "00111000" - ('0'&nshift); 
  ovflow <=  check_ov(7);
  isz0 <= erase OR (NOT nonzx);

  u0: pg_conv_floattofix_shift_16_7_56_0 port map( x=>manx, c=>nshift, z=>mansf0, clk=>clk);


  -- PIPELINE 1 ----------------------------------------------------------------
--  process(clk) begin
--    if(clk'event and clk='1') then
      signz1 <= signz0;
      isz1   <= isz0;
--    end if;
--  end process;
  -- PIPELINE 2 ----------------------------------------------------------------
--  process(clk) begin
--    if(clk'event and clk='1') then
      signz2 <= signz1;
      isz2   <= isz1;
--    end if;
--  end process;
  -- PIPELINE 3 ----------------------------------------------------------------
--  process(clk) begin
--    if(clk'event and clk='1') then
      signz3 <= signz2;
      isz3   <= isz2;
--    end if;
--  end process;
  -- PIPELINE 4 ----------------------------------------------------------------
--  process(clk) begin
--    if(clk'event and clk='1') then
      signz4 <= signz3;
      isz4   <= isz3;
--    end if;
--  end process;

  -- PIPELINE 5 ----------------------------------------------------------------
--  process(clk) begin
--    if(clk'event and clk='1') then
      signz5 <= signz4;
      isz5   <= isz4;
      mansf1 <= mansf0;
--    end if;
--  end process;

  with isz5 select
    z0 <= mansf1 when '0',
           "00000000000000000000000000000000000000000000000000000000" when others;

  -- PIPELINE 6 ----------------------------------------------------------------
  process(clk) begin
    if(clk'event and clk='1') then
      z(56) <= signz5;
      z(55 downto 0) <= z0;
    end if;
  end process;

end rtl;

-- Module for Shift in Floating-Pioint to Fixed-Point Converter
-- by Tsuyoshi Hamada (2004/10/20)
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
entity pg_conv_floattofix_shift_16_7_56_0 is
    port ( x : in std_logic_vector(15 downto 0);
           c : in std_logic_vector(6 downto 0);
           z : out std_logic_vector(55 downto 0);
           clk : in std_logic );
end pg_conv_floattofix_shift_16_7_56_0;
architecture rtl of pg_conv_floattofix_shift_16_7_56_0 is
signal x0 : std_logic_vector(15 downto 0);
signal c0 : std_logic_vector(6 downto 0);
signal z0 : std_logic_vector(55 downto 0);
begin

  x0 <= x;
  c0 <= c;

  with c0(5 downto 0) select   --  (int)(log(nbit_fix)/log(2))-1
    z0 <= "00000000000000000000000000000000000000000000000000000001"      when "000000",  -- 0
          "0000000000000000000000000000000000000000000000000000001" & x0(15)  when "000001",  -- 1
          "000000000000000000000000000000000000000000000000000001" & x0(15 downto 14) when "000010",  -- 2
          "00000000000000000000000000000000000000000000000000001" & x0(15 downto 13) when "000011",  -- 3
          "0000000000000000000000000000000000000000000000000001" & x0(15 downto 12) when "000100",  -- 4
          "000000000000000000000000000000000000000000000000001" & x0(15 downto 11) when "000101",  -- 5
          "00000000000000000000000000000000000000000000000001" & x0(15 downto 10) when "000110",  -- 6
          "0000000000000000000000000000000000000000000000001" & x0(15 downto 9) when "000111",  -- 7
          "000000000000000000000000000000000000000000000001" & x0(15 downto 8) when "001000",  -- 8
          "00000000000000000000000000000000000000000000001" & x0(15 downto 7) when "001001",  -- 9
          "0000000000000000000000000000000000000000000001" & x0(15 downto 6) when "001010",  -- 10
          "000000000000000000000000000000000000000000001" & x0(15 downto 5) when "001011",  -- 11
          "00000000000000000000000000000000000000000001" & x0(15 downto 4) when "001100",  -- 12
          "0000000000000000000000000000000000000000001" & x0(15 downto 3) when "001101",  -- 13
          "000000000000000000000000000000000000000001" & x0(15 downto 2) when "001110",  -- 14
          "00000000000000000000000000000000000000001" & x0(15 downto 1) when "001111",  -- 15
          "0000000000000000000000000000000000000001" & x0(15 downto 0) when "010000",  -- 16
          "000000000000000000000000000000000000001" & x0(15 downto 0) & '0' when "010001",  -- 17
          "00000000000000000000000000000000000001" & x0(15 downto 0) & "00" when "010010",  -- 18
          "0000000000000000000000000000000000001" & x0(15 downto 0) & "000" when "010011",  -- 19
          "000000000000000000000000000000000001" & x0(15 downto 0) & "0000" when "010100",  -- 20
          "00000000000000000000000000000000001" & x0(15 downto 0) & "00000" when "010101",  -- 21
          "0000000000000000000000000000000001" & x0(15 downto 0) & "000000" when "010110",  -- 22
          "000000000000000000000000000000001" & x0(15 downto 0) & "0000000" when "010111",  -- 23
          "00000000000000000000000000000001" & x0(15 downto 0) & "00000000" when "011000",  -- 24
          "0000000000000000000000000000001" & x0(15 downto 0) & "000000000" when "011001",  -- 25
          "000000000000000000000000000001" & x0(15 downto 0) & "0000000000" when "011010",  -- 26
          "00000000000000000000000000001" & x0(15 downto 0) & "00000000000" when "011011",  -- 27
          "0000000000000000000000000001" & x0(15 downto 0) & "000000000000" when "011100",  -- 28
          "000000000000000000000000001" & x0(15 downto 0) & "0000000000000" when "011101",  -- 29
          "00000000000000000000000001" & x0(15 downto 0) & "00000000000000" when "011110",  -- 30
          "0000000000000000000000001" & x0(15 downto 0) & "000000000000000" when "011111",  -- 31
          "000000000000000000000001" & x0(15 downto 0) & "0000000000000000" when "100000",  -- 32
          "00000000000000000000001" & x0(15 downto 0) & "00000000000000000" when "100001",  -- 33
          "0000000000000000000001" & x0(15 downto 0) & "000000000000000000" when "100010",  -- 34
          "000000000000000000001" & x0(15 downto 0) & "0000000000000000000" when "100011",  -- 35
          "00000000000000000001" & x0(15 downto 0) & "00000000000000000000" when "100100",  -- 36
          "0000000000000000001" & x0(15 downto 0) & "000000000000000000000" when "100101",  -- 37
          "000000000000000001" & x0(15 downto 0) & "0000000000000000000000" when "100110",  -- 38
          "00000000000000001" & x0(15 downto 0) & "00000000000000000000000" when "100111",  -- 39
          "0000000000000001" & x0(15 downto 0) & "000000000000000000000000" when "101000",  -- 40
          "000000000000001" & x0(15 downto 0) & "0000000000000000000000000" when "101001",  -- 41
          "00000000000001" & x0(15 downto 0) & "00000000000000000000000000" when "101010",  -- 42
          "0000000000001" & x0(15 downto 0) & "000000000000000000000000000" when "101011",  -- 43
          "000000000001" & x0(15 downto 0) & "0000000000000000000000000000" when "101100",  -- 44
          "00000000001" & x0(15 downto 0) & "00000000000000000000000000000" when "101101",  -- 45
          "0000000001" & x0(15 downto 0) & "000000000000000000000000000000" when "101110",  -- 46
          "000000001" & x0(15 downto 0) & "0000000000000000000000000000000" when "101111",  -- 47
          "00000001" & x0(15 downto 0) & "00000000000000000000000000000000" when "110000",  -- 48
          "0000001" & x0(15 downto 0) & "000000000000000000000000000000000" when "110001",  -- 49
          "000001" & x0(15 downto 0) & "0000000000000000000000000000000000" when "110010",  -- 50
          "00001" & x0(15 downto 0) & "00000000000000000000000000000000000" when "110011",  -- 51
          "0001" & x0(15 downto 0) & "000000000000000000000000000000000000" when "110100",  -- 52
          "001" & x0(15 downto 0) & "0000000000000000000000000000000000000" when "110101",  -- 53
          "01" & x0(15 downto 0) & "00000000000000000000000000000000000000" when "110110",  -- 54
          '1' & x0(15 downto 0) & "000000000000000000000000000000000000000" when "110111",  -- 55
          (others=>'0') when others;   -- over 56 = (nbit_fix-1)

--  process(clk) begin
--    if(clk'event and clk='1') then
      z <= z0;
--    end if;
--  end process;

end rtl;

-- pg_fix_smaccum
-- Pipelined, Virtual Multiple Pipelined Fixed-Point SM Accumulator for Programmable GRAPE
-- Author: Tsuyoshi Hamada
-- Last Modified at May 9 13:33:33
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity pg_fix_smaccum_57_64_1 is
  port (fdata: in std_logic_vector(56 downto 0);
        sdata: out std_logic_vector(63 downto 0);
        run : in std_logic;
        clk : in std_logic);
end pg_fix_smaccum_57_64_1;

architecture rtl of pg_fix_smaccum_57_64_1 is

  component fix_accum_reg_1
    generic (WIDTH: integer);
    port (indata: in std_logic_vector(WIDTH-1 downto 0);
          cin : in std_logic;
          run : in std_logic;
          addsub : in std_logic;
          addsubd : out std_logic;
          rund : out std_logic;
          cout : out std_logic;
          reg0 : out std_logic_vector(WIDTH-1 downto 0);
          clk : in std_logic);
  end component;

  component fix_accum_reg_last_1
    generic (WIDTH: integer);
    port (indata: in std_logic_vector(WIDTH-1 downto 0);
          cin : in std_logic;
          run : in std_logic;
          addsub : in std_logic;
--        countd : out std_logic_vector(-1 downto 0);
--        addsubd : out std_logic;
--        rund : out std_logic;
--        cout : out std_logic;
          reg0 : out std_logic_vector(WIDTH-1 downto 0);
          clk : in std_logic);
  end component;

  signal fx: std_logic_vector(63 downto 0);
  signal fx_0_0: std_logic_vector(63 downto 0);
  signal rsig : std_logic_vector(1 downto 0);
  signal addsub : std_logic_vector(0 downto 0);
  signal carry : std_logic_vector(0 downto 0);

begin

  fx <= "00000000" & fdata(55 downto 0);

  fx_0_0 <= fx(63 downto 0);
  addsub(0) <= not fdata(56);
  carry(0) <= fdata(56);
  rsig(0)  <= run;


  process(clk) begin              
    if(clk'event and clk='1') then
      rsig(1) <= rsig(0);         
    end if;                       
  end process;                    

  u0: fix_accum_reg_last_1        
    generic map(WIDTH=>64)                
    port map(indata=>fx_0_0,            
             cin=>'0',                
             run=>rsig(0),               
             addsub=>addsub(0),          
--           countd=>count1,           
--           addsubd=>addsub(1),       
--           rund=>rsig(1),            
--           cout=>carry(1),           
             reg0=>sdata(63 downto 0),
             clk=>clk);                   
                                          
end rtl;                                                            
                                                                    
library ieee;                                                       
use ieee.std_logic_1164.all;                                        
use ieee.std_logic_arith.all;                                        
use ieee.std_logic_unsigned.all;                                    
                                                                    
entity fix_accum_reg_last_1 is
  generic(WIDTH: integer := 28);                                    
  port(indata : in std_logic_vector(WIDTH-1 downto 0);              
       cin : in std_logic;     
       run : in std_logic;     
       addsub : in std_logic;  
--     countd : out std_logic_vector(-1 downto 0);
--     addsubd : out std_logic;
--     rund : out std_logic;   
--     cout : out std_logic;   
       reg0 : out std_logic_vector(WIDTH-1 downto 0);
       clk : in std_logic);    
end fix_accum_reg_last_1;
                                                                    
architecture rtl of fix_accum_reg_last_1 is                                           
                                                                    
                                                                    
signal sum : std_logic_vector(WIDTH-1 downto 0);
signal zeros : std_logic_vector(WIDTH-2 downto 0);
signal sx : std_logic_vector(WIDTH-1 downto 0);                     
signal zero : std_logic_vector(WIDTH-1 downto 0);                   
signal addout : std_logic_vector(WIDTH-1 downto 0);                 
signal run1 : std_logic;                                            
--signal cout0 : std_logic;                                       
signal reg_vmp0 : std_logic_vector(WIDTH-1 downto 0);            

begin                                                               

  forgen1 : for i in 0 to WIDTH-1 generate
    zero(i) <= '0';                       
  end generate;                           

  process(clk) begin                                              
    if(clk'event and clk='1') then                                
      if(run1 = '1') then                                         
        reg_vmp0 <= addout;                                       
      else                                                        
        if(run = '1') then                                        
          reg_vmp0 <= zero;                                       
        end if;                                                   
      end if;                                                     
    end if;                                                       
  end process;                                                    
  reg0 <= reg_vmp0;                                               

    sx <= reg_vmp0;

  forgen2 : for i in 0 to WIDTH-2 generate
    zeros(i) <= '0';                      
  end generate;                           

  process(sx,cin,addsub,indata) begin
    if(addsub='1') then
      sum <= sx+indata+(zeros&cin);
    else
      sum <= sx-indata-(zeros&cin);
    end if;
  end process;
  addout <= sum;

  process(clk) begin              
    if(clk'event and clk='1') then
      run1 <= run;                
    end if;                       
  end process;                    

--process(clk) begin              
--  if(clk'event and clk='1') then
--    addsubd <= addsub;          
--    cout <= cout0;              
--    countd <= count;            
--  end if;                       
--end process;                    

--rund <= run1;

end rtl;                            
                                    
-- PGR Floating-Point ExpAdd
-- by Tsuyoshi Hamada (2005/03/04)
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
entity pg_float_expadd_1_26_16_1 is
  port( x : in std_logic_vector(25 downto 0);
        z : out std_logic_vector(25 downto 0);
        clk : in std_logic);
end pg_float_expadd_1_26_16_1;
architecture rtl of pg_float_expadd_1_26_16_1 is
constant expadd : std_logic_vector(7 downto 0):="00000001"; -- 1
signal signz,nonzz : std_logic;
signal expx,expz : std_logic_vector(7 downto 0);
signal manz : std_logic_vector(15 downto 0);
signal z0 : std_logic_vector(25 downto 0);

begin

  z0(25)  <= x(25);
  z0(24)  <= x(24);
  z0(15 downto 0) <= x(15 downto 0);

  expx <= x(23 downto 16 );
  expz <= expx + expadd;
  z0(23 downto 16) <= expz;
  process(clk) begin
    if(clk'event and clk='1') then
      z <= z0;
    end if;
  end process;

end rtl;

library ieee;
use ieee.std_logic_1164.all;

entity pg_pdelay_26_4 is
  port( x : in std_logic_vector(25 downto 0);
	   y : out std_logic_vector(25 downto 0);
	   clk : in std_logic);
end pg_pdelay_26_4;

architecture rtl of pg_pdelay_26_4 is

  signal x0 : std_logic_vector(25 downto 0);
  signal x1 : std_logic_vector(25 downto 0);
  signal x2 : std_logic_vector(25 downto 0);
  signal x3 : std_logic_vector(25 downto 0);
  signal x4 : std_logic_vector(25 downto 0);

begin

  x0 <= x;

  process(clk) begin
    if(clk'event and clk='1') then
      x4 <= x3;
      x3 <= x2;
      x2 <= x1;
      x1 <= x0;
    end if;
  end process;

  y <= x4;

end rtl;

library ieee;
use ieee.std_logic_1164.all;

entity pg_pdelay_26_3 is
  port( x : in std_logic_vector(25 downto 0);
	   y : out std_logic_vector(25 downto 0);
	   clk : in std_logic);
end pg_pdelay_26_3;

architecture rtl of pg_pdelay_26_3 is

  signal x0 : std_logic_vector(25 downto 0);
  signal x1 : std_logic_vector(25 downto 0);
  signal x2 : std_logic_vector(25 downto 0);
  signal x3 : std_logic_vector(25 downto 0);

begin

  x0 <= x;

  process(clk) begin
    if(clk'event and clk='1') then
      x3 <= x2;
      x2 <= x1;
      x1 <= x0;
    end if;
  end process;

  y <= x3;

end rtl;

library ieee;
use ieee.std_logic_1164.all;

entity pg_pdelay_26_5 is
  port( x : in std_logic_vector(25 downto 0);
	   y : out std_logic_vector(25 downto 0);
	   clk : in std_logic);
end pg_pdelay_26_5;

architecture rtl of pg_pdelay_26_5 is

  signal x0 : std_logic_vector(25 downto 0);
  signal x1 : std_logic_vector(25 downto 0);
  signal x2 : std_logic_vector(25 downto 0);
  signal x3 : std_logic_vector(25 downto 0);
  signal x4 : std_logic_vector(25 downto 0);
  signal x5 : std_logic_vector(25 downto 0);

begin

  x0 <= x;

  process(clk) begin
    if(clk'event and clk='1') then
      x5 <= x4;
      x4 <= x3;
      x3 <= x2;
      x2 <= x1;
      x1 <= x0;
    end if;
  end process;

  y <= x5;

end rtl;

library ieee;
use ieee.std_logic_1164.all;

entity pg_pdelay_26_23 is
  port( x : in std_logic_vector(25 downto 0);
	   y : out std_logic_vector(25 downto 0);
	   clk : in std_logic);
end pg_pdelay_26_23;

architecture rtl of pg_pdelay_26_23 is

  signal x0 : std_logic_vector(25 downto 0);
  signal x1 : std_logic_vector(25 downto 0);
  signal x2 : std_logic_vector(25 downto 0);
  signal x3 : std_logic_vector(25 downto 0);
  signal x4 : std_logic_vector(25 downto 0);
  signal x5 : std_logic_vector(25 downto 0);
  signal x6 : std_logic_vector(25 downto 0);
  signal x7 : std_logic_vector(25 downto 0);
  signal x8 : std_logic_vector(25 downto 0);
  signal x9 : std_logic_vector(25 downto 0);
  signal x10 : std_logic_vector(25 downto 0);
  signal x11 : std_logic_vector(25 downto 0);
  signal x12 : std_logic_vector(25 downto 0);
  signal x13 : std_logic_vector(25 downto 0);
  signal x14 : std_logic_vector(25 downto 0);
  signal x15 : std_logic_vector(25 downto 0);
  signal x16 : std_logic_vector(25 downto 0);
  signal x17 : std_logic_vector(25 downto 0);
  signal x18 : std_logic_vector(25 downto 0);
  signal x19 : std_logic_vector(25 downto 0);
  signal x20 : std_logic_vector(25 downto 0);
  signal x21 : std_logic_vector(25 downto 0);
  signal x22 : std_logic_vector(25 downto 0);
  signal x23 : std_logic_vector(25 downto 0);

begin

  x0 <= x;

  process(clk) begin
    if(clk'event and clk='1') then
      x23 <= x22;
      x22 <= x21;
      x21 <= x20;
      x20 <= x19;
      x19 <= x18;
      x18 <= x17;
      x17 <= x16;
      x16 <= x15;
      x15 <= x14;
      x14 <= x13;
      x13 <= x12;
      x12 <= x11;
      x11 <= x10;
      x10 <= x9;
      x9 <= x8;
      x8 <= x7;
      x7 <= x6;
      x6 <= x5;
      x5 <= x4;
      x4 <= x3;
      x3 <= x2;
      x2 <= x1;
      x1 <= x0;
    end if;
  end process;

  y <= x23;

end rtl;

library ieee;
use ieee.std_logic_1164.all;

entity pg_pdelay_26_11 is
  port( x : in std_logic_vector(25 downto 0);
	   y : out std_logic_vector(25 downto 0);
	   clk : in std_logic);
end pg_pdelay_26_11;

architecture rtl of pg_pdelay_26_11 is

  signal x0 : std_logic_vector(25 downto 0);
  signal x1 : std_logic_vector(25 downto 0);
  signal x2 : std_logic_vector(25 downto 0);
  signal x3 : std_logic_vector(25 downto 0);
  signal x4 : std_logic_vector(25 downto 0);
  signal x5 : std_logic_vector(25 downto 0);
  signal x6 : std_logic_vector(25 downto 0);
  signal x7 : std_logic_vector(25 downto 0);
  signal x8 : std_logic_vector(25 downto 0);
  signal x9 : std_logic_vector(25 downto 0);
  signal x10 : std_logic_vector(25 downto 0);
  signal x11 : std_logic_vector(25 downto 0);

begin

  x0 <= x;

  process(clk) begin
    if(clk'event and clk='1') then
      x11 <= x10;
      x10 <= x9;
      x9 <= x8;
      x8 <= x7;
      x7 <= x6;
      x6 <= x5;
      x5 <= x4;
      x4 <= x3;
      x3 <= x2;
      x2 <= x1;
      x1 <= x0;
    end if;
  end process;

  y <= x11;

end rtl;

library ieee;
use ieee.std_logic_1164.all;

entity pg_pdelay_26_24 is
  port( x : in std_logic_vector(25 downto 0);
	   y : out std_logic_vector(25 downto 0);
	   clk : in std_logic);
end pg_pdelay_26_24;

architecture rtl of pg_pdelay_26_24 is

  signal x0 : std_logic_vector(25 downto 0);
  signal x1 : std_logic_vector(25 downto 0);
  signal x2 : std_logic_vector(25 downto 0);
  signal x3 : std_logic_vector(25 downto 0);
  signal x4 : std_logic_vector(25 downto 0);
  signal x5 : std_logic_vector(25 downto 0);
  signal x6 : std_logic_vector(25 downto 0);
  signal x7 : std_logic_vector(25 downto 0);
  signal x8 : std_logic_vector(25 downto 0);
  signal x9 : std_logic_vector(25 downto 0);
  signal x10 : std_logic_vector(25 downto 0);
  signal x11 : std_logic_vector(25 downto 0);
  signal x12 : std_logic_vector(25 downto 0);
  signal x13 : std_logic_vector(25 downto 0);
  signal x14 : std_logic_vector(25 downto 0);
  signal x15 : std_logic_vector(25 downto 0);
  signal x16 : std_logic_vector(25 downto 0);
  signal x17 : std_logic_vector(25 downto 0);
  signal x18 : std_logic_vector(25 downto 0);
  signal x19 : std_logic_vector(25 downto 0);
  signal x20 : std_logic_vector(25 downto 0);
  signal x21 : std_logic_vector(25 downto 0);
  signal x22 : std_logic_vector(25 downto 0);
  signal x23 : std_logic_vector(25 downto 0);
  signal x24 : std_logic_vector(25 downto 0);

begin

  x0 <= x;

  process(clk) begin
    if(clk'event and clk='1') then
      x24 <= x23;
      x23 <= x22;
      x22 <= x21;
      x21 <= x20;
      x20 <= x19;
      x19 <= x18;
      x18 <= x17;
      x17 <= x16;
      x16 <= x15;
      x15 <= x14;
      x14 <= x13;
      x13 <= x12;
      x12 <= x11;
      x11 <= x10;
      x10 <= x9;
      x9 <= x8;
      x8 <= x7;
      x7 <= x6;
      x6 <= x5;
      x5 <= x4;
      x4 <= x3;
      x3 <= x2;
      x2 <= x1;
      x1 <= x0;
    end if;
  end process;

  y <= x24;

end rtl;

library ieee;
use ieee.std_logic_1164.all;

entity pg_pdelay_26_1 is
  port( x : in std_logic_vector(25 downto 0);
	   y : out std_logic_vector(25 downto 0);
	   clk : in std_logic);
end pg_pdelay_26_1;

architecture rtl of pg_pdelay_26_1 is

  signal x0 : std_logic_vector(25 downto 0);
  signal x1 : std_logic_vector(25 downto 0);

begin

  x0 <= x;

  process(clk) begin
    if(clk'event and clk='1') then
      x1 <= x0;
    end if;
  end process;

  y <= x1;

end rtl;

library ieee;
use ieee.std_logic_1164.all;

entity pg_pdelay_26_6 is
  port( x : in std_logic_vector(25 downto 0);
	   y : out std_logic_vector(25 downto 0);
	   clk : in std_logic);
end pg_pdelay_26_6;

architecture rtl of pg_pdelay_26_6 is

  signal x0 : std_logic_vector(25 downto 0);
  signal x1 : std_logic_vector(25 downto 0);
  signal x2 : std_logic_vector(25 downto 0);
  signal x3 : std_logic_vector(25 downto 0);
  signal x4 : std_logic_vector(25 downto 0);
  signal x5 : std_logic_vector(25 downto 0);
  signal x6 : std_logic_vector(25 downto 0);

begin

  x0 <= x;

  process(clk) begin
    if(clk'event and clk='1') then
      x6 <= x5;
      x5 <= x4;
      x4 <= x3;
      x3 <= x2;
      x2 <= x1;
      x1 <= x0;
    end if;
  end process;

  y <= x6;

end rtl;

--+-------------------------------+
--| PG_LCELL/PG_LCELL_ARI         |
--| For Xilinx Devices            |
--| Multidevice Logic Cell Module |.GKey:hYj8zgUkjgdkfhB3ozXM
--| 2004/02/06                    |
--|            by Tsuyoshi Hamada |
--+-------------------------------+
--+-------------+----------+
--| x3,x2,x1,x0 |    z     |
--+-------------+----------+
--|  0, 0, 0, 0 | MASK(0)  |
--|  0, 0, 0, 1 | MASK(1)  |
--|  0, 0, 1, 0 | MASK(2)  |
--|  0, 0, 1, 1 | MASK(3)  |
--|  0, 1, 0, 0 | MASK(4)  |
--|  0, 1, 0, 1 | MASK(5)  |
--|  .......... | .......  |
--|  1, 1, 1, 1 | MASK(16) |
--+-------------+----------+
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
LIBRARY UNISIM;
USE UNISIM.Vcomponents.ALL;
entity pg_lcell is
  generic(MASK: bit_vector  := X"ffff";
            FF: integer := 0);
    port(x : in std_logic_vector(3 downto 0);
         z : out std_logic;
         clk : in std_logic);
end pg_lcell;

architecture schematic of pg_lcell is
   ATTRIBUTE BOX_TYPE : STRING;
   ATTRIBUTE INIT : STRING ;
   COMPONENT LUT4
   GENERIC( INIT : BIT_VECTOR := X"0000");
      PORT ( I0	:	IN	STD_LOGIC;
             I1	:	IN	STD_LOGIC;
             I2	:	IN	STD_LOGIC;
             I3	:	IN	STD_LOGIC;
             O	:	OUT	STD_LOGIC);
   END COMPONENT;
   ATTRIBUTE BOX_TYPE OF LUT4 : COMPONENT IS "BLACK_BOX";

   signal z0 : std_logic;

BEGIN

   xlcell : LUT4 GENERIC MAP (INIT => MASK)
      PORT MAP (I0=>x(0), I1=>x(1), I2=>x(2), I3=>x(3), O=>z0);

-- unreged output
ifgen0: if (FF=0) generate
  z <= z0;
end generate;

-- reged output
ifgen1: if (FF>0) generate
  process(clk) begin
    if(clk'event and clk='1') then
      z <= z0;
    end if;
  end process;
end generate;

end schematic;

