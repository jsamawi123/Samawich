library IEEE;
use IEEE.std_logic_1164.all;
use work.sm16_types.all;

-- data_reg Entity Description
-- Adapted from Dr. Michael Crocker's Spring 2013 CSCE 385 Lab 4 at Pacific Lutheran University
entity data_reg is
   port( CLK : in std_logic;
         RESET : in std_logic;
         EN : in std_logic;
         D : in sm16_data;
         Q : out sm16_data);
end data_reg;

-- data_reg Architecture Description
architecture behavioral of data_reg is
begin

    RegisterProcess: process( CLK, RESET )
    begin
        if( RESET = '1' ) then
            Q <= (others => '0');
        elsif( rising_edge(CLK) ) then
            if( EN = '1' ) then
                Q <= D;
                if (D(15 downto 12)= "0110") then -- this is the opcode for jump
                    Q <= "0000000000000000"; -- ignore 
                    end if;
            end if;
        end if;
    end process RegisterProcess;

end behavioral;
