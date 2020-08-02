library IEEE;
use IEEE.std_logic_1164.all;

-- bit2_reg Entity Description
-- Adapted from Dr. Michael Crocker's Spring 2013 CSCE 385 Lab 6 at Pacific Lutheran University
entity bit2_reg is
   port( CLK : in std_logic;
         RESET : in std_logic;
         EN : in std_logic;
         D : in std_logic_vector(1 downto 0);
         Q : out std_logic_vector(1 downto 0));
end bit2_reg;

-- bit2_reg Architecture Description
architecture behavioral of bit2_reg is
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
