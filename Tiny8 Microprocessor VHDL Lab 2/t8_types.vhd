library IEEE;
use IEEE.std_logic_1164.all;

-- From Dr. Michael Crocker's Spring 2013 CSCE 385 Lab 2 at Pacific Lutheran University
package t8_types is

  subtype t8_data is std_logic_vector(7 downto 0);     -- 8 bits
  subtype t8_address is std_logic_vector(4 downto 0);  -- 5 bits
  subtype t8_opcode is std_logic_vector (2 downto 0);    -- 3 bits

end t8_types;
