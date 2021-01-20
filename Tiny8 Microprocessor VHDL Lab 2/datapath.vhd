library IEEE;

use IEEE.std_logic_1164.all;
use work.t8_types.all;

-- datapath Entity Description
-- Adapted from Dr. Michael Crocker's Spring 2013 CSCE 385 Lab 2 at Pacific Lutheran University

entity datapath is
    port( CLK : in std_logic;
          RESET : in std_logic;
          
          -- I/O with Memory ****
          DATA_IN : out t8_data;
          DATA_OUT : in t8_data;
          ADDRESS : out t8_address;
          
          -- Control Signals to the ALU*******
          ALU_OP : in std_logic_vector(1 downto 0);
          B_INV : in std_logic;
          CIN : in std_logic;
          
          -- Control Signals from the ALU *****
          ZERO_FLAG : out std_logic;
          NEG_FLAG : out std_logic; -- last bit in alu_out 
          
          -- ALU Multiplexer Select Signals *****
          A_SEL : in std_logic_vector(1 downto 0);
          B_SEL : in std_logic_vector(1 downto 0);
	      MEM_SEL : in std_logic;  
          
          -- Enable Signals for all registers *****
          EN_A : in std_logic;
          EN_PC : in std_logic;
          EN_OP : in std_logic;
          EN_FIELD : in std_logic;
          EN_DATA : in std_logic;
          EN_ADDR : in std_logic;
          
          -- OpCode sent to the Control ****
          INSTR_OP : out t8_opcode);  
end datapath;

-- datapath Architecture Description
architecture structural of datapath is

  -- declare all components and their ports 
    component address_reg 
        port( CLK : in std_logic;
              RESET : in std_logic;
              EN : in std_logic;
              D : in t8_address;
              Q : out t8_address);
    end component;
    
    component data_reg
        port( CLK : in std_logic;
              RESET : in std_logic;
              EN : in std_logic;
              D : in t8_data;
              Q: out t8_data);
    end component;
    
    component op_reg 
        port( CLK : in std_logic;
              RESET : in std_logic;
              EN : in std_logic;
              D : in t8_opcode;
              Q : out t8_opcode);
    end component;
    
    component alu 
        port( A : in t8_data;
              B : in t8_data;
              OP : in std_logic_vector(1 downto 0);
              D : out t8_data;
              Z : out std_logic;
              CIN : in std_logic;
              B_INV : in std_logic);
    end component;
    
    component mux4 
        port( IN0 : in t8_data;
              IN1 : in t8_data;
              IN2 : in t8_data;
              IN3 : in t8_data;
              SEL : in std_logic_vector(1 downto 0);
              DOUT : out t8_data);
    end component;
    
    component mux2 
        port( IN0 : in t8_address;
              IN1 : in t8_address;
              SEL : in std_logic;
              DOUT : out t8_address);
    end component;
    
    component zero_extend is
        port( A : in t8_address;
              Z : out t8_data);
    end component;
    
    
    signal zero_8 : t8_data := "00000000";
    signal alu_out : t8_data;
    signal a_out : t8_data;
    
    signal one_8 : t8_data := "00000001";
    signal BtoALU : std_logic_vector (7 downto 0);
    signal AtoALU : std_logic_vector (7 downto 0);
    signal DatatoIN2: std_logic_vector (7 downto 0);
    signal PCtoZERO: std_logic_vector (4 downto 0);
    signal PZEROtoIN3: std_logic_vector (7 downto 0);
    signal FIELDtoZERO: std_logic_vector (4 downto 0);
    signal FZEROtoIN3: std_logic_vector (7 downto 0);
    signal ADDRtoMEM: std_logic_vector (4 downto 0);
    
    
    
begin
    
    the_alu: alu port map (
        A     => AtoALU,
        B     => BtoALU,
        OP    => alu_op,
        D     => alu_out, --output
        Z     => zero_flag,
        CIN   => cin,
        B_INV => b_inv
        );
        
    Amux: mux4 port map (
        IN0  => zero_8,   -- 00
        IN1  => zero_8,   -- 01 nothing
        IN2  => a_out,   -- 10 A
        IN3  => PZEROtoIN3,   -- 11 PC
        SEL  => a_sel, --a select 
        DOUT => AtoALU 
        );
        
    Bmux: mux4 port map (
        IN0  => zero_8,   -- 00
        IN1  => one_8,   -- 01
        IN2  => datatoIN2,   -- 10 data
        IN3  => FZEROtoIN3,   -- 11 field
        SEL  => b_sel, --b select
        DOUT => BtoALU 
        );
        
    MEMmux: mux2 port map (
        IN0  => PCtoZERO,   -- 00
        IN1  => ADDRtoMEM,   -- 01
        SEL  => mem_sel,
        DOUT => address
        );
        
    op: op_reg port map (
        CLK   => clk,
        RESET => reset,
        EN    => en_op,
        D     => data_out(7 downto 5),
        Q     => INSTR_OP
        );
        
    addr: address_reg port map (
        CLK   => clk,
        RESET => reset,
        EN    => en_addr,
        D     => alu_out(4 downto 0),
        Q     => ADDRtoMEM
        );
        
    field: address_reg port map (
        CLK   => clk,
        RESET => reset,
        EN    => en_field,
        D     => data_out(4 downto 0),
        Q     => FIELDtoZERO
        );
        
    pc: address_reg port map (
        CLK   => clk,
        RESET => reset,
        EN    => en_pc,
        D     => alu_out(4 downto 0),
        Q     => PCtoZERO
        );
        
    a: data_reg port map (
        CLK   => clk,
        RESET => reset,
        EN    => en_a,
        D     => alu_out(7 downto 0),
        Q     => a_out 
        );
        
    data: data_reg port map (
        CLK   => clk,
        RESET => reset,
        EN    => en_data,
        D     => data_out(7 downto 0),
        Q     => datatoIN2
        );
        
    field_zero_ext: zero_extend port map ( --concatinates 4 zero bits
        A   => FIELDtoZERO,
        Z   => FZEROtoIN3
        );
        
    pc_zero_ext: zero_extend port map ( --concatinates 4 zero bits
        A   => PCtoZERO,
        Z   => PZEROtoIN3
        );
        
    DATA_IN <= a_out;
    
    NEG_FLAG <= alu_out(7);
    
end structural;
