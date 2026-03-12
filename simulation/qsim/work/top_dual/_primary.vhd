library verilog;
use verilog.vl_types.all;
entity top_dual is
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        PC_DBG          : out    vl_logic_vector(31 downto 0);
        Instr0_DBG      : out    vl_logic_vector(31 downto 0);
        Instr1_DBG      : out    vl_logic_vector(31 downto 0);
        WriteData0      : out    vl_logic_vector(31 downto 0);
        DataAdr0        : out    vl_logic_vector(31 downto 0);
        WriteData1      : out    vl_logic_vector(31 downto 0);
        DataAdr1        : out    vl_logic_vector(31 downto 0);
        MemWrite0       : out    vl_logic;
        MemWrite1       : out    vl_logic
    );
end top_dual;
