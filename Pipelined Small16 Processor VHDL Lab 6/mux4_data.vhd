library IEEE;

use IEEE.std_logic_1164.all;
use work.sm16_types.all;

-- mux4_data Entity Description
-- Adapted from Dr. Michael Crocker's Spring 2013 CSCE 385 Lab 6 at Pacific Lutheran University
entity mux4_data is
    port( IN0: in sm16_data;
          IN1: in sm16_data;
          IN2: in sm16_data;
          IN3: in sm16_data;
          SEL: in std_logic_vector(1 downto 0);
          DOUT: out sm16_data);
end mux4_data;

-- mux4_data Architecture Description
architecture behavioral of mux4_data is
begin

    with SEL select
    DOUT <= IN0 when "00",
            IN1 when "01",
            IN2 when "10",
            IN3 when "11",
            (others => 'X') when others;

end behavioral;
