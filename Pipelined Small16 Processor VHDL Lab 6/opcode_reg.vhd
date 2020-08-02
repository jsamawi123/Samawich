library IEEE;
use IEEE.std_logic_1164.all;
use work.sm16_types.all;

-- opcode_reg Entity Description
-- Adapted from Dr. Michael Crocker's Spring 2013 CSCE 385 Lab 6 at Pacific Lutheran University
entity opcode_reg is
   port( CLK : in std_logic;
         RESET : in std_logic;
         EN : in std_logic;
         D : in sm16_opcode;
         Q : out sm16_opcode);
end opcode_reg;

-- opcode_reg Architecture Description
architecture behavioral of opcode_reg is
begin 

    RegisterProcess: process( CLK, RESET )
    begin
        if( RESET = '1' ) then
            Q <= (others => '0');
        elsif( rising_edge(CLK) ) then
            if( EN = '1' ) then
                Q <= D;
            end if;
        end if;
    end process RegisterProcess;

end behavioral;
