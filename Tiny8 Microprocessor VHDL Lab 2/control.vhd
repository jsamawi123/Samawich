library ieee;

use ieee.std_logic_1164.all;
use work.t8_types.all;

-- control Entity Description
-- Adapted from Dr. Michael Crocker's Spring 2013 CSCE 385 Lab 2 at Pacific Lutheran University
entity control is
    port( CLK : in std_logic;
          RESET : in std_logic;
          START : in std_logic;
          
          WE : out std_logic;
          ALU_OP : out std_logic_vector(1 downto 0);
          B_INV : out std_logic;
          CIN : out std_logic;
          A_SEL : out std_logic_vector(1 downto 0);
          B_SEL :  out std_logic_vector(1 downto 0);
          MEM_ADDR_SEL : out std_logic;
          EN_A : out std_logic;
          EN_PC : out std_logic;
          EN_ADDR : out std_logic;
          EN_DATA : out std_logic;
          EN_OP : out std_logic;
          EN_FIELD : out std_logic;
          
          Z_FLAG : in std_logic;
          N_FLAG : in std_logic;
          INSTR_OP : in t8_opcode);
end control;

-- control Architecture Description
architecture behavorial of control is

    -- control signal values
        -- alu operations
        constant alu_nop : std_logic_vector(1 downto 0) := "00";
        constant alu_and : std_logic_vector(1 downto 0) := "00";
        constant alu_or : std_logic_vector(1 downto 0) := "01";
        constant alu_add : std_logic_vector(1 downto 0) := "10";
        
        -- a select control
        constant a_0 : std_logic_vector(1 downto 0) := "00";
        constant a_a : std_logic_vector(1 downto 0) := "10";
        constant a_pc : std_logic_vector(1 downto 0) := "11";
        
        -- b select control
        constant b_0 : std_logic_vector(1 downto 0) := "00";
        constant b_1 : std_logic_vector(1 downto 0) := "01";
        constant b_data : std_logic_vector(1 downto 0) := "10";
        constant b_field : std_logic_vector(1 downto 0) := "11";
        
        -- memory address select
        constant from_pc : std_logic := '0';
        constant from_addr : std_logic := '1';
        
        -- register load control
        constant hold : std_logic := '0';
        constant load : std_logic := '1';
        
        -- write enable control
        constant rd : std_logic := '0';
        constant wr : std_logic := '1';
        
        -- b invert control
        constant pos : std_logic := '0';
        constant inv : std_logic := '1';
        
    -- op codes
    constant op_add   : t8_opcode := "000";
    constant op_sub   : t8_opcode := "001";  
    constant op_load  : t8_opcode := "010";
    constant op_store : t8_opcode := "011";
    constant op_addi  : t8_opcode := "100";
    constant op_seti  : t8_opcode := "101";
    constant op_jump  : t8_opcode := "110";
    
    -- definitions of the states the control can be in
    type states is (
        stopped,
        fetch,
        use_field,
        load_data,
        execute,
        mem_write
        );
    signal state, next_state : states := stopped;
    
    -- internal write enable, ungated by the clock
    signal pre_we : std_logic;
    
begin
    
    -- write enable is gated when the clock is low
    we <= pre_we and (not clk);
    
    -- process to define the state register
    state_reg: process( CLK, RESET )
    begin
        if( RESET = '1' ) then
            state <= stopped;
        elsif( rising_edge(clk) ) then
            state <= next_state;
        end if;
    end process state_reg;
    
    -- ############################################ --
    
    -- process to define next state transitions and output signals
    next_state_and_output: process( state, START, INSTR_OP, Z_FLAG, N_FLAG )
    begin
        case state is
            -- Stopped is the stopped state; wait for start
            when stopped =>
                if (start /= '1') then
                    EN_A  <= hold;    EN_PC  <= hold;    EN_ADDR <= hold;
                    EN_DATA <= hold;  EN_FIELD <= hold;  EN_OP   <= hold;
                    pre_we <= rd;     MEM_ADDR_SEL <= from_pc;
                    B_INV <= pos;     CIN   <= '0';      ALU_OP <= alu_nop;
                    A_SEL <= a_0;     B_SEL <= b_0;
                    
                    next_state <= stopped;
                else
                    EN_A  <= hold;    EN_PC  <= load;    EN_ADDR <= hold;
                    EN_DATA <= hold;  EN_FIELD <= hold;  EN_OP   <= hold;
                    pre_we <= rd;     MEM_ADDR_SEL <= from_pc;
                    B_INV <= pos;     CIN   <= '0';      ALU_OP <= alu_and;
                    A_SEL <= a_0;     B_SEL <= b_0;
                    
                    next_state <= fetch; -- go to fetch state
                end if;
                
            -- In fetch state, fetch next instruction & increment PC
            -- FIELD <= memory[PC]
            -- OP <= memory[PC]
            -- PC <= PC + 1
            when fetch =>
                EN_A  <= hold;    EN_PC  <= load;    EN_ADDR <= hold;
                EN_DATA <= hold;  EN_FIELD <= load;  EN_OP   <= load;
                pre_we <= rd;     MEM_ADDR_SEL <= from_pc;
                B_INV <= pos;     CIN   <= '0';      ALU_OP <= alu_add;
                A_SEL <= a_pc;    B_SEL <= b_1;
                
                next_state <= use_field;
                
            -- In use_field, move instruction address field from FIELD to ADDR
            -- If it is an immediate instruction, just use the FIELD value
            when use_field =>
                if instr_op = op_addi then
                    EN_A  <= load;    EN_PC  <= hold;    EN_ADDR <= hold;
                    EN_DATA <= hold;  EN_FIELD <= hold;  EN_OP   <= hold;
                    pre_we <= rd;     MEM_ADDR_SEL <= from_pc;
                    B_INV <= pos;     CIN   <= '0';      ALU_OP <= alu_add;
                    A_SEL <= a_a;     B_SEL <= b_field;
                    
                    next_state <= fetch;
                    
                elsif instr_op = op_seti then
                    EN_A  <= load;    EN_PC  <= hold;    EN_ADDR <= hold;
                    EN_DATA <= hold;  EN_FIELD <= hold;  EN_OP   <= hold;
                    pre_we <= rd;     MEM_ADDR_SEL <= from_pc;
                    B_INV <= pos;     CIN   <= '0';      ALU_OP <= alu_add;
                    A_SEL <= a_0;     B_SEL <= b_field;
                    
                    next_state <= fetch;
                    
                elsif instr_op = op_jump then
                    EN_A  <= hold;    EN_PC  <= load;    EN_ADDR <= hold;
                    EN_DATA <= hold;  EN_FIELD <= hold;  EN_OP   <= hold;
                    pre_we <= rd;     MEM_ADDR_SEL <= from_pc;
                    B_INV <= pos;     CIN   <= '0';      ALU_OP <= alu_add;
                    A_SEL <= a_0;     B_SEL <= b_field;
                    
                    next_state <= fetch;
                    
                elsif instr_op = op_store then
                    EN_A  <= hold;    EN_PC  <= hold;    EN_ADDR <= load;
                    EN_DATA <= hold;  EN_FIELD <= hold;  EN_OP   <= hold;
                    pre_we <= rd;     MEM_ADDR_SEL <= from_pc;
                    B_INV <= pos;     CIN   <= '0';      ALU_OP <= alu_add;
                    A_SEL <= a_0;     B_SEL <= b_field;
                    
                    next_state <= mem_write;
                    
                else   -- add or load
                    EN_A  <= hold;    EN_PC  <= hold;    EN_ADDR <= load;
                    EN_DATA <= hold;  EN_FIELD <= hold;  EN_OP   <= hold;
                    pre_we <= rd;     MEM_ADDR_SEL <= from_pc;
                    B_INV <= pos;     CIN   <= '0';      ALU_OP <= alu_add;
                    A_SEL <= a_0;     B_SEL <= b_field;
                    
                    next_state <= load_data;
                    
                end if;
                
            -- In mem_write, the store uses the address field to tell the memory where to write
            when mem_write =>
                EN_A  <= hold;    EN_PC  <= hold;    EN_ADDR <= hold;
                EN_DATA <= hold;  EN_FIELD <= hold;  EN_OP   <= hold;
                pre_we <= wr;     MEM_ADDR_SEL <= from_addr;
                B_INV <= pos;     CIN   <= '0';      ALU_OP <= alu_and;
                A_SEL <= a_0;     B_SEL <= b_0;
                
                next_state <= fetch;
                		
            -- In load_data, we need to get another value from memory, this time putting it in the DATA register
            when load_data =>
                EN_A  <= hold;    EN_PC  <= hold;    EN_ADDR <= hold;
                EN_DATA <= load;  EN_FIELD <= hold;  EN_OP   <= hold;
                pre_we <= rd;     MEM_ADDR_SEL <= from_addr;
                B_INV <= pos;     CIN   <= '0';      ALU_OP <= alu_add;
                A_SEL <= a_0;     B_SEL <= b_0;
                
                next_state <= execute;
                
            -- In execute, use the ALU to add DATA+A or DATA+0
            when execute =>    
                -- see if an add, sub, or a load
                if instr_op = op_add then
                    -- add: A+DATA
                    EN_A  <= load;    EN_PC  <= hold;    EN_ADDR <= hold;
                    EN_DATA <= hold;  EN_FIELD <= hold;  EN_OP   <= hold;
                    pre_we <= rd;     MEM_ADDR_SEL <= from_pc;
                    B_INV <= pos;     CIN   <= '0';      ALU_OP <= alu_add;
                    A_SEL <= a_a;     B_SEL <= b_data;
                    
                    next_state <= fetch;
                    
                elsif instr_op = op_sub then
                    -- sub: A-DATA
                    EN_A  <= load;    EN_PC  <= hold;    EN_ADDR <= hold;
                    EN_DATA <= hold;  EN_FIELD <= hold;  EN_OP   <= hold;
                    pre_we <= rd;     MEM_ADDR_SEL <= from_pc;
                    B_INV <= inv;     CIN   <= '1';      ALU_OP <= alu_add;
                    A_SEL <= a_a;     B_SEL <= b_data;
                    
                    next_state <= fetch;
                    
                else  -- load
                    -- load: 0+DATA
                    EN_A  <= load;    EN_PC  <= hold;    EN_ADDR <= hold;
                    EN_DATA <= hold;  EN_FIELD <= hold;  EN_OP   <= hold;
                    pre_we <= rd;     MEM_ADDR_SEL <= from_pc;
                    B_INV <= pos;     CIN   <= '0';      ALU_OP <= alu_add;
                    A_SEL <= a_0;     B_SEL <= b_data;
                    
                    next_state <= fetch;
                    
                end if;
                
            when others =>
                -- should never get here, but if it does, set PC<=0 and stop
                EN_A  <= hold;    EN_PC  <= load;    EN_ADDR <= hold;
                EN_DATA <= hold;  EN_FIELD <= hold;  EN_OP   <= hold;
                pre_we <= rd;     MEM_ADDR_SEL <= from_pc;
                B_INV <= pos;     CIN   <= '0';      ALU_OP <= alu_and;
                A_SEL <= a_0;     B_SEL <= b_0;
                
                next_state <= stopped; -- simply stop
                
        end case;
    end process next_state_and_output;

end behavorial;
