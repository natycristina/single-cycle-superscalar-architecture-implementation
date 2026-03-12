library verilog;
use verilog.vl_types.all;
entity top_dual_vlg_check_tst is
    port(
        DataAdr0        : in     vl_logic_vector(31 downto 0);
        DataAdr1        : in     vl_logic_vector(31 downto 0);
        Instr0_DBG      : in     vl_logic_vector(31 downto 0);
        Instr1_DBG      : in     vl_logic_vector(31 downto 0);
        MemWrite0       : in     vl_logic;
        MemWrite1       : in     vl_logic;
        PC_DBG          : in     vl_logic_vector(31 downto 0);
        WriteData0      : in     vl_logic_vector(31 downto 0);
        WriteData1      : in     vl_logic_vector(31 downto 0);
        sampler_rx      : in     vl_logic
    );
end top_dual_vlg_check_tst;
