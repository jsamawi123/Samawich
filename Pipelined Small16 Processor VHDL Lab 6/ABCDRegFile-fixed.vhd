library IEEE;
use IEEE.std_logic_1164.all;
use work.sm16_types.all;

-- ABCDRegFile Entity Description
-- Adapted from Dr. Michael Crocker's Spring 2013 CSCE 385 Lab 6 at Pacific Lutheran University
entity ABCDRegFile is
    port( CLK : in std_logic;
          RESET : in std_logic;
          
          RD_REG : in std_logic_vector(1 downto 0);  -- Which register to read and output
          REG_OUT : out sm16_data;
          
          ABCD_WE : in std_logic; -- Write enable signal
          WR_REG : in std_logic_vector(1 downto 0);  -- Which register to write to
          REG_IN : in sm16_data);
end ABCDRegFile;

-- ABCDRegFile Architecture Description
architecture structural of ABCDRegFile is

    -- declare all components and their ports 
    component data_reg is
       port( CLK : in std_logic;
             RESET : in std_logic;
             EN : in std_logic;
             D : in sm16_data;
             Q : out sm16_data);
    end component;
    
    component mux4_data is
       port( IN0  : in sm16_data;
             IN1  : in sm16_data;
             IN2  : in sm16_data;
             IN3  : in sm16_data;
             SEL  : in std_logic_vector(1 downto 0);
             DOUT : out sm16_data);
    end component;
    
    signal a_out, b_out, c_out, d_out : sm16_data;
    signal we_a, we_b, we_c, we_d : std_logic;
    
begin
    
    we_a <= ABCD_WE when WR_REG = "00" else '0';
    we_b <= ABCD_WE when WR_REG = "01" else '0';
    we_c <= ABCD_WE when WR_REG = "10" else '0';
    we_d <= ABCD_WE when WR_REG = "11" else '0';

    A: data_reg port map (
        CLK => CLK,
        RESET => RESET,
        EN => we_a,
        D   => REG_IN,
        Q   => a_out
        );
    
    B: data_reg port map (
        CLK => CLK,
        RESET => RESET,
        EN => we_b,
        D   => REG_IN,
        Q   => b_out
        );
    
    C: data_reg port map (
        CLK => CLK,
        RESET => RESET,
        EN => we_c,
        D   => REG_IN,
        Q   => c_out
        );
    
    D: data_reg port map (
        CLK => CLK,
        RESET => RESET,
        EN => we_d,
        D   => REG_IN,
        Q   => d_out
        );
    
    RegMux: mux4_data port map (
        IN0  => a_out,     -- 00
        IN1  => b_out,     -- 01
        IN2  => c_out,     -- 10
        IN3  => d_out,     -- 11
        SEL  => RD_REG,
        DOUT => REG_OUT
        );
    
end structural;
