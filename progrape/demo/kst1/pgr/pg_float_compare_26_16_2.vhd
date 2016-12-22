-- PGPG Floating-Point Compare
-- by Tsuyoshi Hamada (2004/10/01)
-- P: 1[O], 2[O], 
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
entity pg_float_compare_26_16_2 is
  port( x : in std_logic_vector(25 downto 0);
        y : in std_logic_vector(25 downto 0);
        flag : out std_logic;           -- (x > y) ? 1 : 0
        clk : in std_logic);
end pg_float_compare_26_16_2;
architecture rtl of pg_float_compare_26_16_2 is

-- ----------------------------------------------------------------------------
signal signx, signy, nonzx, nonzy :  std_logic;
signal expx,expy : std_logic_vector(7 downto 0);      -- nbit_exp-1
signal manx,many : std_logic_vector(15 downto 0);     -- nbit_man-1
-- ----------------------------------------------------------------------------
signal sx0,sx1,sy0,sy1 : std_logic;
signal nx0,nx1,ny0,ny1 : std_logic;
signal expx0,expy0 : std_logic_vector(7 downto 0); -- nbit_exp-1
signal manx0,many0 : std_logic_vector(15 downto 0); -- nbit_man-1
signal exp_x,exp_y,exy0,eyx0 : std_logic_vector(8 downto 0); -- nbit_exp
signal exgey0,exgey1,eygex0,eygex1 : std_logic;
signal mx,my,mxy,myx : std_logic_vector(16 downto 0);   -- nbit_man
signal mxgey0,mygex0,mygex1 : std_logic;
signal exeqy : std_logic;
signal flag0,flag1 : std_logic;
signal nygex : std_logic;
signal nontobi0 : std_logic;
signal is_xeqy0,mxeqy,mxgey1 : std_logic;
signal b : std_logic_vector(9 downto 0);
begin
                             --2.0,  4.0, 0.5, 0.0, 1024.0
  signx <= x(25);            -- 0 ,  0  ,  0 , *,   0,
  nonzx <= x(24);            -- 1 ,  1  ,  1 , 0,   1,
  expx <= x(23 downto 16);   -- 1 ,  2  , -1 , *   10,
  manx <= x(15 downto 0);    -- 0 ,  0  ,  0 , *,   0,

  signy <= y(25);
  nonzy <= y(24);
  expy <= y(23 downto 16);
  many <= y(15 downto 0);

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
  process(clk) begin
    if(clk'event and clk='1') then
      sx1  <= sx0;
      sy1  <= sy0;
      nx1  <= nx0;
      ny1  <= ny0;
      exgey1 <= exgey0;
      eygex1 <= eygex0;
      mygex1 <= mygex0;
      mxgey1 <= mxgey0;
    end if;
  end process;

  exeqy <= exgey1 nor eygex1;
  mxeqy <= not (mygex1 or mxgey1);  

  -- bawai wake vector
  b <= nx1 & ny1 & sx1 & sy1 & exeqy & exgey1 & eygex1 & mxeqy & mxgey1 & mygex1;

  flag0 <= 
    ((not b(9)) and b(8) and b(6)         ) or                                                       -- "01X1XXXXXX", -- x = 0, y < 0
    (b(9) and (not b(8)) and (not b(7))   ) or                                                       -- "100XXXXXXX", -- x > 0, y = 0
    (b(9) and b(8) and (not b(7)) and b(6)) or                                                       -- "1101XXXXXX", -- x > 0, y < 0
    (b(9) and b(8) and (not b(7)) and (not b(6)) and (not b(5)) and b(4) and (not b(3))) or          -- "1100010XXX", -- x > y > 0
    (b(9) and b(8) and (not b(7)) and (not b(6)) and b(5) and (not b(2)) and b(1) and (not b(0))) or -- "11001XX010", -- x > y > 0
    (b(9) and b(8) and b(7) and b(6) and (not b(5)) and (not b(4)) and b(3)) or                      -- "1111001XXX", -- 0 > x > y
    (b(9) and b(8) and b(7) and b(6) and b(5) and (not b(2)) and (not b(1)) and b(0));               -- "11111XX001", -- 0 > x > y

  -- PIPELINE 2 ----------------------------------------------------------------
  process(clk) begin
    if(clk'event and clk='1') then
      flag <= flag0;
    end if;
  end process;

end rtl;
