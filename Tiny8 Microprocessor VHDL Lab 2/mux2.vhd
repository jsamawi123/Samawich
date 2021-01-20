library IEEE;

use IEEE.std_logic_1164.all;
use work.t8_types.all;

-- mux2 Entity Description
-- Adapted from Dr. Michael Crocker's Spring 2013 CSCE 385 Lab 2 at Pacific Lutheran University
entity mux2 is
    port( IN0 : in t8_address;
          IN1 : in t8_address;
          SEL : in std_logic;
          DOUT : out t8_address);
end mux2;

-- mux2 Architecture Description
architecture behavioral of mux2 is
begin

    with SEL select
    DOUT <= IN0 when '0',
            IN1 when '1',
            (others => 'X') when others;

end behavioral;
