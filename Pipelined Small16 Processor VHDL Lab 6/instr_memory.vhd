library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.sm16_types.all;

-- instr_memory Entity Description
-- Adapted from Dr. Michael Crocker's Spring 2013 CSCE 385 Lab 6 at Pacific Lutheran University
entity instr_memory is
    port( DIN : in sm16_data;
          ADDR : in sm16_address;
          DOUT : out sm16_data;
          WE : in std_logic);
end instr_memory;

-- instr_memory Architecture Description
architecture behavioral of instr_memory is
    subtype ramword is bit_vector(15 downto 0);
    type rammemory is array (0 to 1023) of ramword;
    ----------------------------------------------
    ----------------------------------------------
    ----  This is where you put your program -----
    ----------------------------------------------
    ----------------------------------------------
    -- add   0000           addi 0100
    -- sub   0001           seti 0101 
    -- load  0010           jump 0110
    -- store 0011    
         
    signal ram : rammemory := ("0101000000000001",  -- 0:  seti A 1
                               "0101010000000010",  -- 1:  seti B 2
                               "0101100000000011",  -- 2:  seti C 3
                               "0101110000000100",  -- 3:  seti D 4
                               "0011000000000000",  -- 4:  store A 0  
                               "0011010000000001",  -- 5:  store B 1
                               "0011100000000010",  -- 6:  store C 2
                               "0011110000000011",  -- 7:  store D 3
                               
                               -------- Jump Test ---------
                               "0101110000000111",  -- 3:  seti D 7
                               "0110110000001000",  -- 3:  jump to store
                               "0100010000000000",  -- stall
                               "0000110000000100",  -- add 3 to 7  *skipped*
                               "0011110000001000",  -- 7:  store D (7)
                               
                               -------- Data Hazards -------
                               -- Testing add for A
                               "0010000000000100", -- load 3
                               "0000000000000100", -- add 3 to 3
                               "0100010000000000", -- stall
                               "0011000000000101", -- store 3+3 in..
                               -- Testing multiple setti for B
                               "0101010000000011", -- B = 3
                               "0101010000000100", -- B = 4
                               "0101010000000101", -- B = 5
                               "0100010000000000", -- stall
                               "0011010000000110", -- store 5
                               -- Testing multiple addi for C
                               "0100100000000011", -- C = 6
                               "0100100000000100", -- C = 10
                               "0100100000000101", -- C = 15 (f)
                               "0100010000000000", -- stall
                               "0011100000000111", -- store 15 (f)
                               
                               others => "0000000000000000");

begin

    DOUT <= to_stdlogicvector(ram(to_integer(unsigned(ADDR))));
    
    ram(to_integer(unsigned(ADDR))) <= to_bitvector(DIN) when WE = '1';

end behavioral;
