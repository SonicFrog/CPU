library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity PC is
    port(
        clk     : in  std_logic;
        reset_n : in  std_logic;
        en      : in  std_logic;
        sel_a   : in  std_logic;
        sel_imm : in  std_logic;
        add_imm : in  std_logic;
        imm     : in  std_logic_vector(15 downto 0);
        a       : in  std_logic_vector(15 downto 0);
        addr    : out std_logic_vector(31 downto 0)
    );
end PC;

architecture synth of PC is

signal inst_addr : std_logic_vector(15 downto 0);

begin

	process(clk) 
	begin
		if(rising_edge(clk)) then
			if(reset_n = '0') then
				inst_addr <= (others => '0');
			elsif(en = '1') then
				if(add_imm = '1') then
					inst_addr <= inst_addr + imm; 
				elsif(sel_imm = '1') then
					inst_addr <= imm(13 downto 0) & "00";
				elsif(sel_a = '1') then
					inst_addr <= a(15 downto 2) & "00";
				else
					inst_addr <= inst_addr + 4;
				end if;
			end if;
		end if;
	end process;
	
	addr <= X"0000" & inst_addr;
	
end synth;
