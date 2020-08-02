library ieee;
use ieee.std_logic_1164.all;
use work.sm16_types.all;

-- control Entity Description
-- Adapted from Dr. Michael Crocker's Spring 2013 CSCE 385 Lab 4 at Pacific Lutheran University
entity control_stage2 is
    port( CLK   : in std_logic;
          RESET : in std_logic;
          START : in std_logic;
          
          WE     : out std_logic;
          EN_PC  : out std_logic;
          EN_INSTR : out std_logic;
          EN_OP    : out std_logic;
          EN_IMMED : out std_logic;
          EN_DATA : out std_logic;
          EN_REGV : out std_logic;
          EN_B2 : out std_logic;
          
          INSTR_OP2 : in sm16_opcode); -- STAGE TWO
end control_stage2;

-- control Architecture Description
architecture behavorial of control_stage2 is

    -- control signal values:
    -- register load control
    constant hold : std_logic := '0';
    constant load : std_logic := '1';
    
    -- data memory write enable control
    constant rd : std_logic := '0';
    constant wr : std_logic := '1';
        
        
    -- op codes
    constant op_add   : sm16_opcode := "0000";
    constant op_sub   : sm16_opcode := "0001";  
    constant op_load  : sm16_opcode := "0010";
    constant op_store : sm16_opcode := "0011";
    constant op_addi  : sm16_opcode := "0100";
    constant op_seti  : sm16_opcode := "0101";
    constant op_jump  : sm16_opcode := "0110";
    
    -- definitions of the states the control can be in
    type states is (stopped, running);  -- single cycle now, so only one running state
    signal state, next_state : states := stopped;
    
    -- internal write enable, ungated by the clock
    signal pre_we : std_logic;
    
begin
    
    -- write enable is gated when the clock is low
    WE <= pre_we and (not CLK);
    
    -- process to state register
    state_reg: process( CLK, RESET )
    begin
        if( RESET = '1' ) then
            state <= stopped;
        elsif( rising_edge(CLK) ) then
            state <= next_state;
        end if;
    end process state_reg;
    
    -- ############################################ --
    
    -- process to define next state transitions and output signals
    next_state_and_output: process( state, START, INSTR_OP2) --INSTR_OP3 later
    begin
        case state is
            -- Stopped is the stopped state; wait for start
            when stopped =>
                
                if( START /= '1' ) then
                    -- issue nop
                    EN_PC <= hold; EN_INSTR <= hold; EN_OP <= hold; EN_IMMED <= hold; 
                    EN_DATA <= hold; EN_REGV <= hold; EN_B2 <= hold;
                    pre_we <= rd;     
                    
                    next_state <= stopped;
                else
                    EN_PC <= hold; EN_INSTR <= hold; EN_OP <= hold; EN_IMMED <= hold; 
                    EN_DATA <= hold; EN_REGV <= hold; EN_B2 <= hold;
                    pre_we <= rd;     
                    
                    next_state <= running; -- go to fetch state
                end if;
                
            -- In running state, each instruciton has its own control signals
            when running =>
                
                if instr_op2 = op_jump then
                    -- PC <- 0 + Immediate
                    EN_PC <= load; EN_INSTR <= load; EN_OP <= load; EN_IMMED <= load; 
                    EN_DATA <= load; EN_REGV <= load; EN_B2 <= load;
                    
                    pre_we <= rd;
                    
                    next_state <= running;
                
                elsif instr_op2 = op_add then
                    -- A <- A + Mem
                    EN_PC <= load; EN_INSTR <= load; EN_OP <= load; EN_IMMED <= load; 
                    EN_DATA <= load; EN_REGV <= load; EN_B2 <= load;
                    
                    pre_we <= rd;     
                    
                    next_state <= running;
                    
                elsif instr_op2 = op_sub then
                    -- A <- A - Mem
                    EN_PC <= load; EN_INSTR <= load; EN_OP <= load; EN_IMMED <= load; 
                    EN_DATA <= load; EN_REGV <= load; EN_B2 <= load;
                    
                    pre_we <= rd;     
                    
                    next_state <= running;

                    
                elsif instr_op2 = op_load then
                    -- PC <- 0 + Immediate
                    EN_PC <= load; EN_INSTR <= load; EN_OP <= load; EN_IMMED <= load; 
                    EN_DATA <= load; EN_REGV <= load; EN_B2 <= load;
                    
                    pre_we <= rd;     
                    
                    next_state <= running;
                    
               elsif instr_op2 = op_store then -- en_A hold
                    -- PC <- 0 + Immediate
                    EN_PC <= load; EN_INSTR <= load; EN_OP <= load; EN_IMMED <= load; 
                    EN_DATA <= load; EN_REGV <= load; EN_B2 <= load;
                    
                    pre_we <= wr;     
                    
                    next_state <= running; 
                      
               elsif instr_op2 = op_addi then
                    -- PC <- 0 + Immediate
                    EN_PC <= load; EN_INSTR <= load; EN_OP <= load; EN_IMMED <= load; 
                    EN_DATA <= load; EN_REGV <= load; EN_B2 <= load;
                    
                    pre_we <= rd;     
                    
                    next_state <= running;
                    
               elsif instr_op2 = op_seti then   -- DONE
                    -- A <- 0 + Immediate
                    EN_PC <= load; EN_INSTR <= load; EN_OP <= load; EN_IMMED <= load; 
                    EN_DATA <= hold; EN_REGV <= hold; EN_B2 <= load;
                    
                    pre_we <= rd;     
                    
                    next_state <= running;

                else -- unknown opcode
                    -- should never get here, but if it does, set PC<=0 and stop
                    EN_PC <= hold; EN_INSTR <= hold; EN_OP <= hold; EN_IMMED <= hold; 
                    EN_DATA <= hold; EN_REGV <= hold; EN_B2 <= hold;
                    
                    pre_we <= rd;     
                    
                    next_state <= stopped;
                    
                end if;
                
            when others => -- unknown state 
                    -- should never get here, but if it does, set PC<=0 and stop
                    EN_PC <= hold; EN_INSTR <= hold; EN_OP <= hold; EN_IMMED <= hold; 
                    EN_DATA <= hold; EN_REGV <= hold; EN_B2 <= hold;
                    
                    pre_we <= rd;     
                    
                    next_state <= stopped;
        end case;
    end process next_state_and_output;
    
end behavorial;
