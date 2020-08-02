library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.sm16_types.all;

-- data_memory Entity Description
-- Adapted from Dr. Michael Crocker's Spring 2013 CSCE 385 Lab 4 at Pacific Lutheran University
entity data_memory is
    port( DIN : in sm16_data;
          ADDR : in sm16_address;
          DOUT : out sm16_data;
          WE : in std_logic);
end data_memory;

-- data_memory Architecture Description
architecture behavioral of data_memory is
    subtype ramword is bit_vector(15 downto 0);
    type rammemory is array (0 to 1023) of ramword;
    ----------------------------------------------
    ----------------------------------------------
    -----  This is where you put your data -------
    ----------------------------------------------
    ----------------------------------------------
    signal ram : rammemory := ("0000000000000000",  --  0: array[0]=A=1
                               "0000000000000000",  --  1: array[1]=B=2
                               "0000000000000000",  --  2: array[2]=C=3
                               "0000000000000000",  --  3: array[3]=D=4
                               "0000000000000011",
                               "0000000000000000",
                               "0000000000000000",
                               "0000000000000000",

                               others => "0000000000000000");

begin

    DOUT <= to_stdlogicvector(ram(to_integer(unsigned(ADDR))));
    
    ram(to_integer(unsigned(ADDR))) <= to_bitvector(DIN) when WE = '1';

end behavioral;
