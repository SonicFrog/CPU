library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity register_file is
    port(
        clk    : in std_logic;
        aa     : in  std_logic_vector( 4 downto 0);
        ab     : in  std_logic_vector( 4 downto 0);
        aw     : in  std_logic_vector( 4 downto 0);
        wren   : in  std_logic;
        wrdata : in  std_logic_vector(31 downto 0);
        a      : out std_logic_vector(31 downto 0);
        b      : out std_logic_vector(31 downto 0)
    );
end register_file;

architecture synth of register_file is
    type reg_type is array (0 to 31) of std_logic_vector(31 downto 0);
    signal reg_array : reg_type := (others=>(others=>'0'));
    signal decoder : std_logic_vector(31 downto 0);
begin
    -- asynchronous read (1396 LUT)
    --a <= reg_array(conv_integer(aa)) when aa/=0 else (others=>'0');
    --b <= reg_array(conv_integer(ab)) when ab/=0 else (others=>'0');

    -- asynchronous read (1396 LUT)
    a <= reg_array(conv_integer(aa));
    b <= reg_array(conv_integer(ab));

    -- synchronous write (1403 LUT)
--  process(clk)
--  begin
--      if(rising_edge(clk))then
--          if(wren='1')then
--              reg_array(conv_integer(aw)) <= wrdata;
--          end if;
--          -- fix register 0 to 0
--          reg_array(0) <= (others => '0');
--      end if;
--  end process;

    -- synchronous write (1393 LUT)
    process(clk)
    begin
        if(rising_edge(clk))then
            if(wren='1' and aw /= 0)then
                reg_array(conv_integer(aw)) <= wrdata;
            end if;
            -- fix register 0 to 0
            --reg_array(0) <= (others => '0');
        end if;
    end process;

--  -- synchronous write (1392 LU)
--  process(clk)
--  begin
--      if(rising_edge(clk))then
--          if(wren='1')then
--              reg_array(conv_integer(aw)) <= wrdata;
--          end if;
--      end if;
--  end process;

end synth;
