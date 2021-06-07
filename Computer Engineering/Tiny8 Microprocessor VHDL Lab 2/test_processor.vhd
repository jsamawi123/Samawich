LIBRARY ieee;

USE ieee.std_logic_1164.ALL;

-- From Dr. Michael Crocker's Spring 2013 CSCE 385 Lab 2 at Pacific Lutheran University
ENTITY test_processor IS
END test_processor;

ARCHITECTURE testbench OF test_processor IS
    
    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT processor
    PORT(
         DataIn_View : OUT  std_logic_vector(7 downto 0);
         DataOut_View : OUT  std_logic_vector(7 downto 0);
         Address_View : OUT  std_logic_vector(4 downto 0);
         Instr_View : OUT  std_logic_vector(2 downto 0);
         clk : IN  std_logic;
         reset : IN  std_logic;
         start : IN  std_logic
        );
    END COMPONENT;
    
    --Inputs
    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
    signal start : std_logic := '0';
    
 	--Outputs
    signal DataIn_View : std_logic_vector(7 downto 0);
    signal DataOut_View : std_logic_vector(7 downto 0);
    signal Address_View : std_logic_vector(4 downto 0);
    signal Instr_View : std_logic_vector(2 downto 0);
    
    -- Clock period definitions
    constant clk_period : time := 10 ns;
    
BEGIN
    
    -- Instantiate the Unit Under Test (UUT)
    uut: processor PORT MAP (
        CLK => clk,
        RESET => reset,
        START => start,
        DataIn_View => DataIn_View,
        DataOut_View => DataOut_View,
        Address_View => Address_View,
        Instr_View => Instr_View
        );
        
    -- Clock process definition
    clk_process: process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;
    
    -- Stimulus process
    stim_proc: process
    begin
        -- hold reset state for 100 ns
        reset <= '1';
        wait for 100 ns;
        
        reset <= '0';
        start <= '1';
        wait for clk_period*2;
        
        start <= '0';
        wait for clk_period*14;  -- load, add, store -> 4+4+3=11
        
        wait;
   end process;

END testbench;
