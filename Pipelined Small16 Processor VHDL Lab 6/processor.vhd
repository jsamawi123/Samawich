library IEEE;
use IEEE.std_logic_1164.all;
use work.sm16_types.all;

-- processor Entity Description
-- Adapted from Dr. Michael Crocker's Spring 2013 CSCE 385 Lab 4 at Pacific Lutheran University
entity processor is
    port( CLK : in std_logic;
          RESET : in std_logic;
          START : in std_logic  -- signals to run the processor
          );
end processor;

-- processor Architecture Description
architecture structural of processor is
    
    -- declare all components and their ports 
    component datapath is
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
    end component;
    
    component instr_memory is
        port( DIN : in sm16_data;
              ADDR: in sm16_address;
              DOUT: out sm16_data;
              WE: in std_logic);
    end component;
    
    component data_memory is
        port( DIN : in sm16_data;
              ADDR : in sm16_address;
              DOUT : out sm16_data;
              WE : in std_logic);
    end component;
    
    component control_stage2 is
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
    end component;
    
    component control_stage3 is
    port( CLK   : in std_logic;
          RESET : in std_logic;
          START : in std_logic;
          
          EN_ABCD : out std_logic;
          ALU_OP : out std_logic_vector(1 downto 0);
          B_INV  : out std_logic;
          CIN    : out std_logic;
          A_SEL  : out std_logic;
          B_SEL  : out std_logic;
          PC_SEL : out std_logic;

          INSTR_OP3 : in sm16_opcode); -- STAGE Three
    end component;
    
    signal DataAddress_Connect, PCAddress_Connect : sm16_address;
    signal Data_IntoMem_Connect : sm16_data;
    signal DataOut_OutofMem_Connect, Instruction_Connect : sm16_data;
    signal ReadWrite_Connect : std_logic;
    
    signal INSTR_OP2_Connect, INSTR_OP3_Connect : sm16_opcode;
    signal ALUOp_Connect : std_logic_vector(1 downto 0);
    signal Binv_Connect  : std_logic;
    signal Cin_Connect   : std_logic;
    
    signal ASel_Connect  : std_logic;
    signal BSel_Connect  : std_logic;
    signal PCSel_Connect : std_logic;
    
    signal EnPC_Connect : std_logic;
    signal EnINSTR_Connect : std_logic;
    signal EnOP_Connect : std_logic;
    signal EnIMMED_Connect : std_logic;
    signal EnDATA_Connect : std_logic;
    signal EnREGV_Connect : std_logic;
    signal EnB2_Connect : std_logic;
    signal EN_ABCD_Connect  : std_logic;
    
begin
    
    the_instr_memory: instr_memory port map (
        DIN => "0000000000000000",
        ADDR => PCAddress_Connect,
        DOUT => Instruction_Connect,
        WE => '0'  -- always read
        );
        
    the_data_memory: data_memory port map (
        DIN => Data_IntoMem_Connect,
        ADDR => DataAddress_Connect,
        DOUT => DataOut_OutofMem_Connect,
        WE => ReadWrite_Connect
        );
        
    the_datapath: datapath port map (
        CLK   => CLK,
        RESET => RESET,
        DATA_IN   => Data_IntoMem_Connect,
        DATA_OUT  => DataOut_OutofMem_Connect,
        DATA_ADDR => DataAddress_Connect,
        INSTR_OUT  => Instruction_Connect,
        INSTR_ADDR => PCAddress_Connect,
        INSTR_OP2   => INSTR_OP2_Connect,
        INSTR_OP3   => INSTR_OP3_Connect,
        ALU_OP => ALUOp_Connect,
        B_INV  => Binv_Connect,
        CIN    => Cin_Connect,
        A_SEL  => ASel_Connect,
        B_SEL  => BSel_Connect,
        PC_SEL => PCSel_Connect,
        EN_PC => EnPC_Connect,
        EN_INSTR => EnINSTR_Connect,
        EN_OP => EnOP_Connect, 
        EN_IMMED => EnIMMED_Connect, 
        EN_DATA => EnDATA_Connect, 
        EN_REGV => EnREGV_Connect, 
        EN_B2 => EnB2_Connect,
        EN_ABCD => EN_ABCD_Connect
        );
        
    S2_control: control_stage2 port map ( -- change
        CLK   => CLK,
        RESET => RESET,
        START => START,
        WE     => ReadWrite_Connect,
        EN_PC => EnPC_Connect,
        EN_INSTR => EnINSTR_Connect,
        EN_OP => EnOP_Connect, 
        EN_IMMED => EnIMMED_Connect, 
        EN_DATA => EnDATA_Connect, 
        EN_REGV => EnREGV_Connect, 
        EN_B2 => EnB2_Connect,
        INSTR_OP2 => INSTR_OP2_Connect
        );
    
    S3_control: control_stage3 port map ( 
        CLK     => CLK,
        RESET   => RESET,
        START   => START,
        EN_ABCD => EN_ABCD_Connect,
        ALU_OP  => ALUOp_Connect,
        B_INV   => Binv_Connect,
        CIN     => Cin_Connect,
        A_SEL   => ASel_Connect,
        B_SEL   => BSel_Connect,
        PC_SEL  => PCSel_Connect,
        INSTR_OP3 => INSTR_OP3_Connect
        );
        
end structural;
