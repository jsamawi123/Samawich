library IEEE;

use IEEE.std_logic_1164.all;
use work.t8_types.all;

-- data_reg Entity Description
-- Adapted from Dr. Michael Crocker's Spring 2013 CSCE 385 Lab 2 at Pacific Lutheran University
entity data_reg is
    port( CLK : in std_logic;
          RESET : in std_logic;
          EN : in std_logic;
          
          D : in t8_data;
          Q : out t8_data);
end data_reg;

-- data_reg Architecture Description
architecture behavioral of data_reg is
begin
    
    RegisterProcess: process( CLK, RESET )
    begin
        if( RESET = '1' ) then
            Q <= (others => '0');
        elsif( CLK'event and CLK = '1' ) then
            if( EN = '1' ) then
                Q <= D;
            end if;
        end if;
    end process RegisterProcess;
   
end behavioral;
