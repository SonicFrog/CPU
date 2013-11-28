library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity multiplexer is
    port(
        i0  : in  std_logic_vector(31 downto 0);
        i1  : in  std_logic_vector(31 downto 0);
        i2  : in  std_logic_vector(31 downto 0);
        i3  : in  std_logic_vector(31 downto 0);
        sel : in  std_logic_vector( 1 downto 0);
        o   : out std_logic_vector(31 downto 0)
    );
end multiplexer;

architecture synth of multiplexer is
begin

process(i0, i1, i2, i3, sel)
begin
    case sel is
        when "00" => o <= i0;
        when "01" => o <= i1;
        when "10" => o <= i2;
        when "11" => o <= i3;
        when others =>
    end case;
end process;

end synth;
