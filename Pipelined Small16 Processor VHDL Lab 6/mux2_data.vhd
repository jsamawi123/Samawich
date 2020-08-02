library IEEE;
use IEEE.std_logic_1164.all;
use work.sm16_types.all;

-- mux2_data Entity Description
-- Adapted from Dr. Michael Crocker's Spring 2013 CSCE 385 Lab 4 at Pacific Lutheran University
entity mux2_data is
   port( IN0 : in sm16_data;
         IN1 : in sm16_data;
         SEL : in std_logic;
         DOUT : out sm16_data);
end mux2_data;

-- mux2_data Architecture Description
architecture behavioral of mux2_data is
begin

    with SEL select
    DOUT <= IN0 when '0',
            IN1 when '1',
            (others => 'X') when others;

end behavioral;
