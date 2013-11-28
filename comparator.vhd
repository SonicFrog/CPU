library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity comparator is
    port (
        a_31    : in  std_logic;
        b_31    : in  std_logic;
        diff_31 : in  std_logic;
        carry   : in  std_logic;
        zero    : in  std_logic;
        op      : in  std_logic_vector( 2 downto 0);
        r       : out std_logic
    );
end comparator;

architecture synth of comparator is
begin

process (op, zero, carry, a_31, b_31, diff_31)
begin
    -- all bits to 0
    r <= zero;
    -- here we modify only the least significant bit.
    case op is
        -- >=
        when "001" =>
            -- take care to surround all logical operation with parenthesis:
            -- there's no priority between them.
            r <= (not a_31 and b_31) or ((not a_31 xor b_31) and not diff_31);
        -- <
        when "010"  =>
            r <= (a_31 and not b_31) or ((not a_31 xor b_31) and diff_31);
        -- !=
        when "011" => r <= not zero;
        -- >= unsigned
        when "101" => r <= carry;
        -- < unsigned
        when "110" => r <= not carry;
        --  0, 4, 7: =
        when others => r <= zero;
    end case;
end process;

end synth;
