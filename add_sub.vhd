library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity add_sub is
    port(
        a        : in  std_logic_vector(31 downto 0);
        b        : in  std_logic_vector(31 downto 0);
        sub_mode : in  std_logic;
        carry    : out std_logic;
        zero     : out std_logic;
        r        : out std_logic_vector(31 downto 0)
    );
end add_sub;

architecture synth of add_sub is
    signal b_s    : std_logic_vector(31 downto 0);
    signal result : std_logic_vector(32 downto 0);
begin

    -- b_s is the output of the xor between b and sub_mode.
    -- here a vector of 32 bits of sub_mode has been created
    b_s <= b xor (31 downto 0 => sub_mode);

    -- result of the adder will be on 33 bits to keep the carry.
    -- Using the unsigned library, at least the left operand should have the same bitwidht
    -- than the result. This is done for a and b by concatenating a 0 on the most significant bit.
    -- sub_mode will be converted by the unsigned library to match
    -- the others operand sizes.
    result <= ('0' & a) + ('0' & b_s) + sub_mode;

    -- The carry is extracted from the most significant bit of the result
    carry <= result(32);

    -- the r output is the 32 least significant bits of result
    r <= result(31 downto 0);

    -- zero is 1 when r=0. r is an output, it can't be read.
    -- We have to compare the 32 least significant bits of result
    zero  <= '1' when result(31 downto 0)=0 else '0';

end synth;
