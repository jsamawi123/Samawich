library IEEE;
use IEEE.std_logic_1164.all;
use work.sm16_types.all;

-- address_reg Entity Description
-- Adapted from Dr. Michael Crocker's Spring 2013 CSCE 385 Lab 4 at Pacific Lutheran University
entity address_reg is
   port( CLK : in std_logic;
         RESET : in std_logic;
         EN : in std_logic;
         D : in sm16_address;
         Q : out sm16_address);
end address_reg;

-- address_reg Architecture Description
architecture behavioral of address_reg is
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
