library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;
use work.t8_types.all;

-- alu Entity Description
-- From Dr. Michael Crocker's Spring 2013 CSCE 385 Lab 2 at Pacific Lutheran University
entity alu is
   port(
      A: in t8_data;
      B: in t8_data;
      OP: in std_logic_vector(1 downto 0);
      D: out t8_data;
      Z: out std_logic;
      CIN,B_INV: in std_logic
   );
end alu;

-- alu Architecture Description
architecture rtl of alu is
   signal pre_D : t8_data;
begin
 
   ArithProcess: process(A,B,CIN,B_INV,OP)
      variable operand1, operand2 : t8_data;
      variable carry_ext : std_logic_vector(1 downto 0);
      constant zero : t8_data := "00000000";

   begin
      carry_ext := '0' & CIN;  -- needed to make CIN positive
      operand1 := A;
      if B_INV = '0' then 
	 operand2 := B;
      else
	 operand2 := not B;    -- needed for subtract
      end if;

      case OP is
         when "00" =>
            pre_D <= operand1 and operand2;  -- bitwise AND
         when "01" =>
            pre_D <= operand1 or operand2;  -- bitwise OR
         when "10" =>
            pre_D <= operand1 + operand2 + carry_ext;  -- add or subtract
         when others =>
	   pre_D <= zero;
	   assert false
	     report "Illegal ALU operation" severity error;
      end case;

   end process ArithProcess;   

   D <= pre_D;
   Z <= not (pre_D(0) or pre_D(1) or pre_D(2) or pre_D(3) or
   		    pre_D(4) or pre_D(5) or pre_D(6) or pre_D(7));
    
end rtl;

