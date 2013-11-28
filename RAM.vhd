library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity RAM is
    port(
        clk     : in  std_logic;
        cs      : in  std_logic;
        read    : in  std_logic;
        write   : in  std_logic;
        address : in  std_logic_vector(9 downto 0);
        wrdata  : in  std_logic_vector(31 downto 0);
        rddata  : out std_logic_vector(31 downto 0));
end RAM;

architecture synth of RAM is

    type mem_type is array(0 to 1023) of std_logic_vector(31 downto 0);

    signal mem         : mem_type;
    signal reg_address : std_logic_vector(9 downto 0);
    signal reg_read    : std_logic;
begin

    -- address register
    process (clk)
    begin
        if (rising_edge(clk)) then
            reg_read    <= cs and read;
            -- The next statement is optional and ONLY compatible
            -- with Quartus II 8.0 or higher:
            -- Since we don't read during the next cycle, we can
            -- save power consumption by keeping the address constant.
            --if(read='1' and cs='1')then
                reg_address <= address;
            --end if;
        end if;
    end process;

    -- read in memory
    process (mem, reg_read, reg_address)
    begin
        rddata <= (others => 'Z');
        if (reg_read ='1') then
            rddata <= mem(conv_integer(reg_address));
        end if;
    end process;

    -- write in memory
    process (clk)
    begin
        if (rising_edge(clk)) then
            if (cs = '1' and write = '1') then
                mem(conv_integer(address)) <= wrdata;
            end if;
        end if;
    end process;
end synth;
