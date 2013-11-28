library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity IR is
    port(
        clk     : in std_logic;
        enable  : in std_logic;
        D       : in  std_logic_vector(31 downto 0);
        Q       : out std_logic_vector(31 downto 0)
    );
end IR;

architecture synth of IR is

signal instruction : std_logic_vector(31 downto 0);
	
begin

	process(clk, enable, D)
	begin 
		if(rising_edge(clk)) then
			if(enable = '1') then
				instruction <= D;
			end if;
		end if;
	end process;
	
	Q <= instruction;
	
end synth;
