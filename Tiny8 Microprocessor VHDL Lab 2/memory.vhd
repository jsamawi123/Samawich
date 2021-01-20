library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.t8_types.all;

-- memory Entity Description
-- Adapted from Dr. Michael Crocker's Spring 2013 CSCE 385 Lab 2 at Pacific Lutheran University
entity memory is
    port( DIN : in t8_data;
          ADDR : in t8_address;
          DOUT : out t8_data;
          WE : in std_logic);
end memory;

-- memory Architecture Description
architecture behavioral of memory is
    subtype ramword is bit_vector(7 downto 0);
    type rammemory is array (0 to 31) of ramword;
    ----------------------------------------------
    ----------------------------------------------
    ----  This is where you put your program. ----
    ----------------------------------------------
    ----------------------------------------------
    -- add   000           addi 100
    -- sub   001           seti 101
    -- load  010           jump 110
    -- store 011
    signal ram : rammemory := ( "10100001",  -- seti 1
                                "01110000",  -- store 16
                                "01110001",  -- store 17
                                "01010000",  -- load 16
                                "00010001",  -- add 17
                                "01110010",  -- store 18
                                "01000011",  -- load 3
                                "10000001",  -- addi 1
                                "01100011",  -- store 3
                                "01000100",  -- load 4
                                "10000001",  -- addi 1
                                "01100100",  -- store 4
                                "01000101",  -- load 5
                                "10000001",  -- addi 1
                                "01100101",  -- store 5
                                "11000011",  -- jump 3
                                others => "00000000");
                                
begin
    
    DOUT <= to_stdlogicvector(ram(to_integer(unsigned(ADDR))));
    
    ram(to_integer(unsigned(ADDR))) <= to_bitvector(DIN) when WE = '1';
    
end behavioral;
