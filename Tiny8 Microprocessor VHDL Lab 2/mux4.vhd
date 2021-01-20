library IEEE;

use IEEE.std_logic_1164.all;
use work.t8_types.all;

-- mux4 Entity Description
-- Adapted from Dr. Michael Crocker's Spring 2013 CSCE 385 Lab 2 at Pacific Lutheran University
entity mux4 is
    port( IN0: in t8_data;
          IN1: in t8_data;
          IN2: in t8_data;
          IN3: in t8_data;
          SEL: in std_logic_vector(1 downto 0);
          DOUT: out t8_data);
end mux4;

-- mux4 Architecture Description
architecture behavioral of mux4 is
begin

    with SEL select
    DOUT <= IN0 when "00",
            IN1 when "01",
            IN2 when "10",
            IN3 when "11",
            (others => 'X') when others;

end behavioral;
