library IEEE;
use IEEE.std_logic_1164.all;
use work.t8_types.all;

-- zero_extend Entity Description
-- From Dr. Michael Crocker's Spring 2013 CSCE 385 Lab 2 at Pacific Lutheran University
entity zero_extend is
   port(
      A: in t8_address;
      Z: out t8_data
   );
end zero_extend;


-- zero_extend Architecture Description
architecture dataflow of zero_extend is

signal zero_3 : t8_opcode := "000";

begin

	Z(7 downto 5) <= zero_3;
	Z(4 downto 0) <= A;

end dataflow;
