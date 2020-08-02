library IEEE;
use IEEE.std_logic_1164.all;
use work.sm16_types.all;

-- datapath Entity Description
-- Adapted from Dr. Michael Crocker's Spring 2013 CSCE 385 Lab 4 at Pacific Lutheran University
entity datapath is
    port( CLK   : in std_logic;
          RESET : in std_logic;
          
          -- I/O with Data Memory
          DATA_IN   : out sm16_data;
          DATA_OUT  : in  sm16_data;
          DATA_ADDR : out sm16_address;
          
          -- I/O with Instruction Memory
          INSTR_OUT  : in  sm16_data;
          INSTR_ADDR : out sm16_address;
          
          -- OpCode sent to the Control stage 2
          INSTR_OP2   : out sm16_opcode; 
          
          -- OpCode sent to the Control stage 3
          INSTR_OP3   : out sm16_opcode; 
          
          -- Control Signals to the ALU
          ALU_OP : in std_logic_vector(1 downto 0);
          B_INV  : in std_logic;
          CIN    : in std_logic;
  
          -- ALU Multiplexer Select Signals
          A_SEL  : in std_logic;
          B_SEL  : in std_logic;
          PC_SEL : in std_logic;
          
          -- Enable Signals for all registers
          EN_PC : in std_logic;
          EN_INSTR : in std_logic;
          EN_OP : in std_logic;
          EN_IMMED : in std_logic;
          EN_DATA : in std_logic;
          EN_REGV : in std_logic;
          EN_B2 : in std_logic;
          EN_ABCD : in std_logic
          );
end datapath;

-- datapath Architecture Description
architecture structural of datapath is
    -- declare all components and their ports 
    
   component bit2_reg is
   port( CLK : in std_logic;
         RESET : in std_logic;
         EN : in std_logic;
         D : in std_logic_vector(1 downto 0);
         Q : out std_logic_vector(1 downto 0));
    end component;
    
    component opcode_reg is
    port( CLK : in std_logic;
         RESET : in std_logic;
         EN : in std_logic;
         D : in sm16_opcode;
         Q : out sm16_opcode);
    end component;
    
    component ABCDRegFile is
    port( CLK : in std_logic;
          RESET : in std_logic;
          RD_REG : in std_logic_vector(1 downto 0);  
          REG_OUT : out sm16_data;
          ABCD_WE : in std_logic; 
          WR_REG : in std_logic_vector(1 downto 0);  
          REG_IN : in sm16_data);
    end component;
    
    component address_reg is
        port( CLK : in std_logic;
              RESET : in std_logic;
              EN : in std_logic;
              D : in sm16_address;
              Q : out sm16_address);
    end component;
    
    component data_reg is 
        port( CLK : in std_logic;
              RESET : in std_logic;
              EN : in std_logic;
              D : in sm16_data;
              Q : out sm16_data);
    end component;
    
    component alu is
        port( A : in sm16_data;
              B : in sm16_data;
              OP : in std_logic_vector(1 downto 0);
              D : out sm16_data;
              CIN : in std_logic;
              B_INV : in std_logic);
    end component;
    
    component adder is
        port( A : in sm16_address;
              B : in sm16_address;
              D : out sm16_address);
    end component;
    
    component mux2_addr is
        port( IN0 : in sm16_address;
              IN1 : in sm16_address;
              SEL : in std_logic;
              DOUT : out sm16_address);
    end component;
    
    component mux2_data is
        port( IN0 : in sm16_data;
              IN1 : in sm16_data;
              SEL : in std_logic;
              DOUT : out sm16_data);
    end component;
    
    component zero_extend is
        port( A : in sm16_address;
              Z : out sm16_data);
    end component;
    
    component zero_checker is
        port( A : in sm16_data;
              Z : out std_logic);
    end component;
    
    -- 16-bit sm16_data:
    signal zero_16 : sm16_data := "0000000000000000";           
    signal alu_a, alu_b, alu_out : sm16_data;                   
    signal a_out, immediate_zero_extend_out : sm16_data;        
    signal ABCDout, INSTR_Split : sm16_data;                    
    signal immediate_to_B, data_to_B, regValue_to_A : sm16_data;
    -- 10-bit sm16_address:
    signal pc_out, pc_in, ADDERtoPC : sm16_address;  
    -- Other:
    signal bit2Reg_out: std_logic_vector(1 downto 0);           
    
begin
    
    ProgramCounter: address_reg port map ( -- done
        CLK   => CLK,
        RESET => RESET,
        EN    => EN_PC,
        D     => ADDERtoPC,
        Q     => pc_out
        );
        
    PCadder: adder port map ( -- done
        A => "0000000001",
        B => pc_out, -- 10 bits
        D => ADDERtoPC
        );
        
    InstrReg: data_reg port map ( -- done
        CLK   => CLK,
        RESET => RESET,
        EN    => EN_INSTR,
        D     => INSTR_OUT,
        Q     => INSTR_Split
        );
    
    ImmediateZeroExt: zero_extend port map ( -- done
        A => INSTR_Split(9 downto 0),
        Z => immediate_zero_extend_out
        );
    
    opcodeReg: opcode_reg port map ( -- done
        CLK => CLK,
        RESET => RESET,
        EN => EN_OP,
        D => INSTR_Split(15 downto 12),
        Q => INSTR_OP3
        );
    
    ImmediateReg: data_reg port map ( -- done
        CLK => CLK,
        RESET => RESET,
        EN => EN_IMMED,
        D => immediate_zero_extend_out,
        Q => immediate_to_B
        );
    
    DataReg: data_reg port map ( -- done
        CLK => CLK,
        RESET => RESET,
        EN => EN_DATA,
        D => DATA_OUT,
        Q => data_to_B
        );
    
    TheABCD: ABCDRegFile port map ( -- done
        CLK => CLK,
        RESET => RESET,
        RD_REG => INSTR_Split(11 downto 10),
        REG_OUT => ABCDout,
        ABCD_WE => EN_ABCD,
        WR_REG => bit2Reg_out,
        REG_IN => alu_out
    );
    
    RegValue: data_reg port map ( -- done
        CLK => CLK,
        RESET => RESET,
        EN => EN_REGV,
        D => ABCDout,
        Q => regValue_to_A
        );
    
    bit2Reg: bit2_reg port map ( -- done
        CLK => CLK,
         RESET => RESET,
         EN => EN_B2,
         D => INSTR_Split(11 downto 10),
         Q => bit2Reg_out
        );    
    
    Bmux: mux2_data port map ( -- done
        IN0  => data_to_B,  -- from dataReg
        IN1  => immediate_to_B,  -- from immediateReg
        SEL  => B_SEL,
        DOUT => alu_b
        );
    
    Amux: mux2_data port map ( -- done
        IN0  => zero_16,  -- All zero
        IN1  => regValue_to_A,  -- from regValue
        SEL  => A_SEL,
        DOUT => alu_a
        );
        
    TheAlu: alu port map ( -- done
        A     => alu_a,
        B     => alu_b,
        OP    => ALU_OP,
        D     => alu_out,
        CIN   => CIN,
        B_INV => B_INV
        );
        
    -- Instruction Memory
    INSTR_ADDR <= pc_out;
    INSTR_OP2  <= INSTR_Split(15 downto 12);
    -- INSTR_OP3  => OpcodeReg 
    
    -- Data Memory
    DATA_ADDR <= INSTR_Split(9 downto 0); 
    DATA_IN   <= ABCDout;
    -- DATA_OUT => DataReg
    
end structural;
