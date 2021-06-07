library IEEE;

use IEEE.std_logic_1164.all;
use work.t8_types.all;

-- processor Entity Description
-- Adapted from Dr. Michael Crocker's Spring 2013 CSCE 385 Lab 2 at Pacific Lutheran University
entity processor is
    port( CLK : in std_logic;
          RESET : in std_logic;
          START : in std_logic;
          
          DataIn_View  : out t8_data;  -- I/O to and from memory, so we can debug processor
          DataOut_View : out t8_data;
          Address_View : out t8_address;
          Instr_View   : out t8_opcode	 -- Current Instruction OpCode
          );
end processor;

-- processor Architecture Description
architecture structural of processor is

    -- declare all components and their ports 
    component datapath is
        port( CLK : in std_logic;
              RESET : in std_logic;
              
              -- I/O with Memory
              DATA_IN : out t8_data;
              DATA_OUT : in t8_data;
              ADDRESS : out t8_address;
              
              -- Control Signals to the ALU
              ALU_OP : in std_logic_vector(1 downto 0);
              B_INV : in std_logic;
              CIN : in std_logic;
              
              -- Control Signals from the ALU
              ZERO_FLAG : out std_logic;
              NEG_FLAG : out std_logic;
              
              -- ALU Multiplexer Select Signals
              A_SEL : in std_logic_vector(1 downto 0);
              B_SEL : in std_logic_vector(1 downto 0);
              MEM_SEL : in std_logic;  
              
              -- Enable Signals for all registers
              EN_A : in std_logic;
              EN_PC : in std_logic;
              EN_OP : in std_logic;
              EN_FIELD : in std_logic;
              EN_DATA : in std_logic;
              EN_ADDR : in std_logic;
              
              -- OpCode sent to the Control
              INSTR_OP : out t8_opcode);
    end component;
    
    component memory
        port( DIN : in t8_data;
              ADDR : in t8_address;
              DOUT : out t8_data;
              WE : in std_logic);
    end component;
    
    component control
        port( CLK : in std_logic;
              RESET : in std_logic;
              START : in std_logic;
              WE : out std_logic;
              ALU_OP : out std_logic_vector(1 downto 0);
              B_INV : out std_logic;
              CIN : out std_logic;
              A_SEL : out std_logic_vector(1 downto 0);
              B_SEL : out std_logic_vector(1 downto 0);
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
    end component;
    
    signal Address_Connect   : t8_address;
    signal DataIn_Connect    : t8_data;
    signal DataOut_Connect   : t8_data;
    signal ReadWrite_Connect : std_logic;
    
    signal InstrOpCode_Connect : t8_opcode;
    signal ALUOp_Connect       : std_logic_vector(1 downto 0);
    signal Binv_Connect        : std_logic;
    signal Cin_Connect         : std_logic;
    signal Zflag_Connect       : std_logic;
    signal Nflag_Connect       : std_logic;
    
    signal ASel_Connect       : std_logic_vector(1 downto 0);
    signal BSel_Connect       : std_logic_vector(1 downto 0);
    signal MemAddrSel_Connect : std_logic;
    
    signal EnA_Connect     : std_logic;
    signal EnPC_Connect    : std_logic;
    signal EnADDR_Connect  : std_logic;
    signal EnDATA_Connect  : std_logic;
    signal EnOP_Connect    : std_logic;
    signal EnFIELD_Connect : std_logic;
    
begin
    
    the_memory: memory port map(
        DIN => DataIn_Connect,
        ADDR => Address_Connect,
        DOUT => DataOut_Connect,
        WE => ReadWrite_Connect
        );
        
    the_datapath: datapath port map (
        CLK => clk,
        RESET => reset,
        DATA_IN => DataIn_Connect,
        DATA_OUT => DataOut_Connect,
        ADDRESS => Address_Connect,
        ALU_OP => ALUOp_Connect,
        B_INV => Binv_Connect,
        CIN => Cin_Connect,
        ZERO_FLAG => Zflag_Connect,
        NEG_FLAG => Nflag_Connect,
        A_SEL => ASel_Connect,
        B_SEL => BSel_Connect,
        MEM_SEL => MemAddrSel_Connect,
        EN_A => EnA_Connect,
        EN_PC => EnPC_Connect,
        EN_OP => EnOP_Connect,
        EN_FIELD => EnFIELD_Connect,
        EN_DATA => EnDATA_Connect,
        EN_ADDR => EnADDR_Connect,
        INSTR_OP => InstrOpCode_Connect
        );
        
    the_control: control port map (
        CLK => clk,
        RESET => reset,
        START => start,
        WE => ReadWrite_Connect,
        ALU_OP => ALUOp_Connect,
        B_INV => Binv_Connect,
        CIN => Cin_Connect,
        A_SEL => ASel_Connect,
        B_SEL => BSel_Connect,
	    MEM_ADDR_SEL => MemAddrSel_Connect,
        EN_A => EnA_Connect,
        EN_PC => EnPC_Connect,
        EN_ADDR => EnADDR_Connect,
        EN_DATA => EnDATA_Connect,
        EN_OP => EnOP_Connect,
        EN_FIELD => EnFIELD_Connect,
        Z_FLAG => Zflag_Connect,
        N_FLAG => Nflag_Connect,
        INSTR_OP => InstrOpCode_Connect
        );
        
    DataIn_View <= DataIn_Connect;
    DataOut_View <= DataOut_Connect;
    Address_View <= Address_Connect;
    Instr_View <= InstrOpCode_Connect;
    
end structural;
