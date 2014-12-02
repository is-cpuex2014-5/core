-- CORE
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity core is
  Port (
    clk : in std_logic;
    execute_ok : in std_logic;
    ostate : out std_logic_vector(7 downto 0);
    sram_go : out std_logic := '0';
    sram_inst_type : out std_logic;
    sram_addr : out std_logic_vector(19 downto 0);
    sram_read : in std_logic_vector(31 downto 0);
    sram_write : out std_logic_vector(31 downto 0);
    debug_otpt : out std_logic_vector(31 downto 0);
    debug_otpt_code : out std_logic_vector(2 downto 0);
    debug_otpt_signal : out std_logic := '0'
  );
end core;

architecture cocore of core is
--components
  component fetch Port (
    clk : in std_logic;
    pc : in std_logic_vector(31 downto 0);
    load_signal : in std_logic;
    inst_sram_request : out std_logic;
    inst_sram_addr : out std_logic_vector(19 downto 0);
    inst_sram_getvalue : in std_logic_vector(31 downto 0);
    inst_sram_request_finished : in std_logic;
    inst_fetched : in std_logic;
    inst : out std_logic_vector(31 downto 0)
  );
  end component;
  component alu Port (
    clk : in std_logic;
    opc_alu : in std_logic_vector(6 downto 0);
    reg_in_a : in std_logic_vector(31 downto 0);
    reg_in_b : in std_logic_vector(31 downto 0);
    reg_out : out std_logic_vector(31 downto 0);
    shift_dir : in std_logic;
    shift_type : in std_logic_vector(1 downto 0);
    shift_go : in std_logic
  );
  end component;
  component compr Port (
    clk : in std_logic;
    opc_compr : in std_logic_vector(6 downto 0);
    reg_in_a : in std_logic_vector(31 downto 0);
    reg_in_b : in std_logic_vector(31 downto 0);
    cond_out : out std_logic
  );
  end component;
  component fpu_man Port (
    clk : in std_logic;
    opc_fpu : in std_logic_vector(6 downto 0);
    reg_in_a : in std_logic_vector(31 downto 0);
    reg_in_b : in std_logic_vector(31 downto 0);
    reg_out : out std_logic_vector(31 downto 0)
  );
  end component;
  -- registers
  signal rgzero : std_logic_vector(31 downto 0) := x"00000000";
  signal rg1 : std_logic_vector(31 downto 0) := x"00000000";
  signal rg2 : std_logic_vector(31 downto 0) := x"00000000";
  signal rg3 : std_logic_vector(31 downto 0) := x"00000000";
  signal rg4 : std_logic_vector(31 downto 0) := x"00000000";
  signal rg5 : std_logic_vector(31 downto 0) := x"00000000";
  signal rg6 : std_logic_vector(31 downto 0) := x"00000000";
  signal rg7 : std_logic_vector(31 downto 0) := x"00000000";
  signal rg8 : std_logic_vector(31 downto 0) := x"00000000";
  signal rg9 : std_logic_vector(31 downto 0) := x"00000000";
  signal rgA : std_logic_vector(31 downto 0) := x"00000000";
  signal rgB : std_logic_vector(31 downto 0) := x"00000000";
  signal rgC : std_logic_vector(31 downto 0) := x"00000000";
  signal hp : std_logic_vector(31 downto 0) := x"00055550";
  signal sp : std_logic_vector(31 downto 0) := x"000AAAA0";
  signal pc : std_logic_vector(31 downto 0) := x"00000000";
  signal fpzero : std_logic_vector(31 downto 0) := x"00000000";
  signal fp1 : std_logic_vector(31 downto 0) := x"0F000000";
  signal fp2 : std_logic_vector(31 downto 0) := x"0F000000";
  signal fp3 : std_logic_vector(31 downto 0) := x"00000000";
  signal fp4 : std_logic_vector(31 downto 0) := x"00000000";
  signal fp5 : std_logic_vector(31 downto 0) := x"00000000";
  signal fp6 : std_logic_vector(31 downto 0) := x"00000000";
  signal fp7 : std_logic_vector(31 downto 0) := x"00000000";
  signal fp8 : std_logic_vector(31 downto 0) := x"00000000";
  signal fp9 : std_logic_vector(31 downto 0) := x"00000000";
  signal fpA : std_logic_vector(31 downto 0) := x"00000000";
  signal fpB : std_logic_vector(31 downto 0) := x"00000000";
  signal fpC : std_logic_vector(31 downto 0) := x"00000000";
  signal fpD : std_logic_vector(31 downto 0) := x"00000000";
  signal fpE : std_logic_vector(31 downto 0) := x"00000000";
  signal fpret : std_logic_vector(31 downto 0) := x"00000000";
-- signals
  signal state : std_logic_vector(3 downto 0) := x"0";
  signal phase : std_logic_vector(2 downto 0) := "111";
    --phase: active phase (without pipelines)
  signal cond_new_pc : std_logic_vector(31 downto 0) := x"00000000";
  signal ldsig : std_logic := '0';
  signal inst_from_fetch : std_logic_vector(31 downto 0);
  signal inputc_sram_request : std_logic;
  signal inputc_sram_request_get : std_logic;
  signal inputc_sram_addr : std_logic_vector(19 downto 0);
  signal inputc_sram_getvalue : std_logic_vector(31 downto 0);
  signal inputc_sram_request_finished : std_logic;
  signal inputc_fetched : std_logic;
  signal ftdcode : std_logic_vector(31 downto 0);
  signal opccode_alu : std_logic_vector(6 downto 0);
  signal reg_in_a : std_logic_vector(31 downto 0);
  signal reg_in_b : std_logic_vector(31 downto 0);
  signal reg_out : std_logic_vector(31 downto 0);
  signal shift_dir : std_logic;
  signal shift_type : std_logic_vector(1 downto 0);
  signal shift_go : std_logic := '0';
  signal opccode_fpu : std_logic_vector(6 downto 0);
  signal reg_in_a_fpu : std_logic_vector(31 downto 0);
  signal reg_in_b_fpu : std_logic_vector(31 downto 0);
  signal reg_out_fpu : std_logic_vector(31 downto 0);
  signal opccode_compr : std_logic_vector(6 downto 0);
  signal reg_in_a_compr : std_logic_vector(31 downto 0);
  signal reg_in_b_compr : std_logic_vector(31 downto 0);
  signal cond_out_compr : std_logic;
  signal dest_reg : std_logic_vector(3 downto 0);
  signal loaded_srca : std_logic_vector(31 downto 0);
  signal loaded_srcb : std_logic_vector(31 downto 0);
  signal loaded_newpc : std_logic_vector(31 downto 0);
  signal read_index : std_logic_vector(19 downto 0) := x"00000";
begin
  with_fetch: fetch Port map (
      clk => clk,
      pc => pc,
      load_signal => ldsig,
      inst => inst_from_fetch,
      inst_sram_request => inputc_sram_request,
      inst_sram_getvalue => inputc_sram_getvalue,
      inst_sram_addr => inputc_sram_addr,
      inst_fetched => inputc_fetched,
      inst_sram_request_finished => inputc_sram_request_finished
    );
  with_alu: alu Port map (
      clk => clk,
      opc_alu => opccode_alu,
      reg_in_a => reg_in_a,
      reg_in_b => reg_in_b,
      reg_out => reg_out,
      shift_dir => shift_dir,
      shift_type => shift_type,
      shift_go => shift_go
    );
  with_compr: compr Port map (
      clk => clk,
      opc_compr => opccode_compr,
      reg_in_a => reg_in_a_compr,
      reg_in_b => reg_in_b_compr,
      cond_out => cond_out_compr
    );
  with_fpu: fpu_man Port map (
      clk => clk,
      opc_fpu => opccode_fpu,
      reg_in_a => reg_in_a_fpu,
      reg_in_b => reg_in_b_fpu,
      reg_out => reg_out_fpu
    );
  core_pro: process(clk)
  begin
    if (rising_edge(clk)) and (execute_ok = '1') then
      -- state action one
      ldsig <= '1';
      if state = x"0" then
        -- initialize groups
        if phase = "000" then
          --Phase Fetch
          if inputc_sram_request = '1' then
            sram_go <= '1';
            sram_addr <= inputc_sram_addr;
            sram_inst_type <= '0';
            inputc_sram_request_get <= '1';
          else
            inputc_sram_request_get <= '0';
          end if;
        end if;
        if phase = "001" then
          --Phase Decode
          ftdcode <= inst_from_fetch;
          inputc_fetched <= '1';
        end if;
        if phase = "010" then
          --Phase Load
          -- ALU
          if ftdcode(31 downto 30) = "00" then
            --set source A
            if ftdcode(20 downto 17) = x"0" then
              loaded_srca <= rgzero;
            end if;
            if ftdcode(20 downto 17) = x"1" then
              loaded_srca <= rg1;
            end if;
            if ftdcode(20 downto 17) = x"2" then
              loaded_srca <= rg2;
            end if;
            if ftdcode(20 downto 17) = x"3" then
              loaded_srca <= rg3;
            end if;
            if ftdcode(20 downto 17) = x"4" then
              loaded_srca <= rg4;
            end if;
            if ftdcode(20 downto 17) = x"5" then
              loaded_srca <= rg5;
            end if;
            if ftdcode(20 downto 17) = x"6" then
              loaded_srca <= rg6;
            end if;
            if ftdcode(20 downto 17) = x"7" then
              loaded_srca <= rg7;
            end if;
            if ftdcode(20 downto 17) = x"8" then
              loaded_srca <= rg8;
            end if;
            if ftdcode(20 downto 17) = x"9" then
              loaded_srca <= rg9;
            end if;
            if ftdcode(20 downto 17) = x"A" then
              loaded_srca <= rgA;
            end if;
            if ftdcode(20 downto 17) = x"B" then
              loaded_srca <= rgB;
            end if;
            if ftdcode(20 downto 17) = x"C" then
              loaded_srca <= rgC;
            end if;
            if ftdcode(20 downto 17) = x"D" then
              loaded_srca <= hp;
            end if;
            if ftdcode(20 downto 17) = x"E" then
              loaded_srca <= sp;
            end if;
            if ftdcode(20 downto 17) = x"F" then
              loaded_srca <= pc;
            end if;
            --set source B
            if (ftdcode(31 downto 25) = "0000001") or (ftdcode(31 downto 25) = "0000011") or (ftdcode(31 downto 25) = "0010001") then
              --immediate
              if ftdcode(31 downto 25) = "0010001" then
                loaded_srcb <= x"000000" & "000" & ftdcode(12 downto 8);
              else
                if ftdcode(16) = '1' then
                  -- high
                  loaded_srcb <= ftdcode(15 downto 0)&"0000000000000000";
                else
                  -- low
                  loaded_srcb <= "0000000000000000"&ftdcode(15 downto 0);
                end if;
              end if;
            else
              if ftdcode(16 downto 13) = x"0" then
                loaded_srcb <= rgzero;
              end if;
              if ftdcode(16 downto 13) = x"1" then
                loaded_srcb <= rg1;
              end if;
              if ftdcode(16 downto 13) = x"2" then
                loaded_srcb <= rg2;
              end if;
              if ftdcode(16 downto 13) = x"3" then
                loaded_srcb <= rg3;
              end if;
              if ftdcode(16 downto 13) = x"4" then
                loaded_srcb <= rg4;
              end if;
              if ftdcode(16 downto 13) = x"5" then
                loaded_srcb <= rg5;
              end if;
              if ftdcode(16 downto 13) = x"6" then
                loaded_srcb <= rg6;
              end if;
              if ftdcode(16 downto 13) = x"7" then
                loaded_srcb <= rg7;
              end if;
              if ftdcode(16 downto 13) = x"8" then
                loaded_srcb <= rg8;
              end if;
              if ftdcode(16 downto 13) = x"9" then
                loaded_srcb <= rg9;
              end if;
              if ftdcode(16 downto 13) = x"A" then
                loaded_srcb <= rgA;
              end if;
              if ftdcode(16 downto 13) = x"B" then
                loaded_srcb <= rgB;
              end if;
              if ftdcode(16 downto 13) = x"C" then
                loaded_srcb <= rgC;
              end if;
              if ftdcode(20 downto 17) = x"D" then
                loaded_srcb <= hp;
              end if;
              if ftdcode(20 downto 17) = x"E" then
                loaded_srcb <= sp;
              end if;
              if ftdcode(20 downto 17) = x"F" then
                loaded_srcb <= pc;
              end if;
            end if;
          end if;
          --FPU
          if ftdcode(31 downto 30) = "01" then
            --set source A
            if ftdcode(31 downto 25) = "0101100" then
              -- itof
              if ftdcode(20 downto 17) = x"0" then
                loaded_srca <= rgzero;
              end if;
              if ftdcode(20 downto 17) = x"1" then
                loaded_srca <= rg1;
              end if;
            if ftdcode(20 downto 17) = x"2" then
              loaded_srca <= rg2;
            end if;
            if ftdcode(20 downto 17) = x"3" then
              loaded_srca <= rg3;
            end if;
            if ftdcode(20 downto 17) = x"4" then
              loaded_srca <= rg4;
            end if;
            if ftdcode(20 downto 17) = x"5" then
              loaded_srca <= rg5;
            end if;
            if ftdcode(20 downto 17) = x"6" then
              loaded_srca <= rg6;
            end if;
            if ftdcode(20 downto 17) = x"7" then
              loaded_srca <= rg7;
            end if;
            if ftdcode(20 downto 17) = x"8" then
              loaded_srca <= rg8;
            end if;
            if ftdcode(20 downto 17) = x"9" then
              loaded_srca <= rg9;
            end if;
            if ftdcode(20 downto 17) = x"A" then
              loaded_srca <= rgA;
            end if;
            if ftdcode(20 downto 17) = x"B" then
              loaded_srca <= rgB;
            end if;
            if ftdcode(20 downto 17) = x"C" then
              loaded_srca <= rgC;
            end if;
            if ftdcode(20 downto 17) = x"D" then
              loaded_srca <= hp;
            end if;
              if ftdcode(20 downto 17) = x"E" then
                loaded_srca <= sp;
              end if;
              if ftdcode(20 downto 17) = x"F" then
                loaded_srca <= pc;
              end if;
            else
              -- otherwise
              if ftdcode(20 downto 17) = x"0" then
                loaded_srca <= fpzero;
              end if;
              if ftdcode(20 downto 17) = x"1" then
                loaded_srca <= fp1;
              end if;
              if ftdcode(20 downto 17) = x"2" then
                loaded_srca <= fp2;
            end if;
            if ftdcode(20 downto 17) = x"3" then
              loaded_srca <= fp3;
            end if;
            if ftdcode(20 downto 17) = x"4" then
              loaded_srca <= fp4;
            end if;
            if ftdcode(20 downto 17) = x"5" then
              loaded_srca <= fp5;
            end if;
            if ftdcode(20 downto 17) = x"6" then
              loaded_srca <= fp6;
            end if;
            if ftdcode(20 downto 17) = x"7" then
              loaded_srca <= fp7;
            end if;
            if ftdcode(20 downto 17) = x"8" then
              loaded_srca <= fp8;
            end if;
            if ftdcode(20 downto 17) = x"9" then
              loaded_srca <= fp9;
            end if;
            if ftdcode(20 downto 17) = x"A" then
              loaded_srca <= fpA;
            end if;
            if ftdcode(20 downto 17) = x"B" then
              loaded_srca <= fpB;
            end if;
            if ftdcode(20 downto 17) = x"C" then
              loaded_srca <= fpC;
            end if;
            if ftdcode(20 downto 17) = x"D" then
              loaded_srca <= fpD;
            end if;
            if ftdcode(20 downto 17) = x"E" then
              loaded_srca <= fpE;
            end if;
              if ftdcode(20 downto 17) = x"F" then
                loaded_srca <= fpret;
              end if;
            end if;
            --set source B
            if ftdcode(16 downto 13) = x"0" then
              loaded_srcb <= fpzero;
            end if;
            if ftdcode(16 downto 13) = x"1" then
              loaded_srcb <= fp1;
            end if;
            if ftdcode(16 downto 13) = x"2" then
              loaded_srcb <= fp2;
            end if;
            if ftdcode(16 downto 13) = x"3" then
              loaded_srcb <= fp3;
            end if;
            if ftdcode(16 downto 13) = x"4" then
              loaded_srcb <= fp4;
            end if;
            if ftdcode(16 downto 13) = x"5" then
              loaded_srcb <= fp5;
            end if;
            if ftdcode(16 downto 13) = x"6" then
              loaded_srcb <= fp6;
            end if;
            if ftdcode(16 downto 13) = x"7" then
              loaded_srcb <= fp7;
            end if;
            if ftdcode(16 downto 13) = x"8" then
              loaded_srcb <= fp8;
            end if;
            if ftdcode(16 downto 13) = x"9" then
              loaded_srcb <= fp9;
            end if;
            if ftdcode(16 downto 13) = x"A" then
              loaded_srcb <= fpA;
            end if;
            if ftdcode(16 downto 13) = x"B" then
              loaded_srcb <= fpB;
            end if;
            if ftdcode(16 downto 13) = x"C" then
              loaded_srcb <= fpC;
            end if;
            if ftdcode(16 downto 13) = x"D" then
              loaded_srcb <= fpD;
            end if;
            if ftdcode(16 downto 13) = x"E" then
              loaded_srcb <= fpE;
            end if;
            if ftdcode(16 downto 13) = x"F" then
              loaded_srcb <= fpret;
            end if;
          end if;
          --Branch
          if ftdcode(31 downto 30) = "10" then
            if ftdcode(31 downto 27) = "10001" then
              --float
              --set source A
              if ftdcode(24 downto 21) = x"0" then
                loaded_srca <= fpzero;
              end if;
              if ftdcode(24 downto 21) = x"1" then
                loaded_srca <= fp1;
              end if;
            if ftdcode(24 downto 21) = x"2" then
              loaded_srca <= fp2;
            end if;
            if ftdcode(24 downto 21) = x"3" then
              loaded_srca <= fp3;
            end if;
            if ftdcode(24 downto 21) = x"4" then
              loaded_srca <= fp4;
            end if;
            if ftdcode(24 downto 21) = x"5" then
              loaded_srca <= fp5;
            end if;
            if ftdcode(24 downto 21) = x"6" then
              loaded_srca <= fp6;
            end if;
            if ftdcode(24 downto 21) = x"7" then
              loaded_srca <= fp7;
            end if;
            if ftdcode(24 downto 21) = x"8" then
              loaded_srca <= fp8;
            end if;
            if ftdcode(24 downto 21) = x"9" then
              loaded_srca <= fp9;
            end if;
            if ftdcode(24 downto 21) = x"A" then
              loaded_srca <= fpA;
            end if;
            if ftdcode(24 downto 21) = x"B" then
              loaded_srca <= fpB;
            end if;
            if ftdcode(24 downto 21) = x"C" then
              loaded_srca <= fpC;
            end if;
            if ftdcode(24 downto 21) = x"D" then
              loaded_srca <= fpD;
            end if;
            if ftdcode(24 downto 21) = x"E" then
              loaded_srca <= fpE;
            end if;
            if ftdcode(24 downto 21) = x"F" then
              loaded_srca <= fpret;
            end if;
            --set source B
            if ftdcode(20 downto 17) = x"0" then
              loaded_srcb <= fpzero;
            end if;
            if ftdcode(20 downto 17) = x"1" then
              loaded_srcb <= fp1;
            end if;
            if ftdcode(20 downto 17) = x"2" then
              loaded_srcb <= fp2;
            end if;
            if ftdcode(20 downto 17) = x"3" then
              loaded_srcb <= fp3;
            end if;
            if ftdcode(20 downto 17) = x"4" then
              loaded_srcb <= fp4;
            end if;
            if ftdcode(20 downto 17) = x"5" then
              loaded_srcb <= fp5;
            end if;
            if ftdcode(20 downto 17) = x"6" then
              loaded_srcb <= fp6;
            end if;
            if ftdcode(20 downto 17) = x"7" then
              loaded_srcb <= fp7;
            end if;
            if ftdcode(20 downto 17) = x"8" then
              loaded_srcb <= fp8;
            end if;
            if ftdcode(20 downto 17) = x"9" then
              loaded_srcb <= fp9;
            end if;
            if ftdcode(20 downto 17) = x"A" then
              loaded_srcb <= fpA;
            end if;
            if ftdcode(20 downto 17) = x"B" then
              loaded_srcb <= fpB;
            end if;
            if ftdcode(20 downto 17) = x"C" then
              loaded_srcb <= fpC;
            end if;
            if ftdcode(20 downto 17) = x"D" then
              loaded_srcb <= fpD;
            end if;
            if ftdcode(20 downto 17) = x"E" then
              loaded_srcb <= fpE;
            end if;
              if ftdcode(20 downto 17) = x"F" then
                loaded_srcb <= fpret;
              end if;
            else
              --integer
              --set source A
              if ftdcode(24 downto 21) = x"0" then
                loaded_srca <= rgzero;
              end if;
              if ftdcode(24 downto 21) = x"1" then
                loaded_srca <= rg1;
              end if;
            if ftdcode(24 downto 21) = x"2" then
              loaded_srca <= rg2;
            end if;
            if ftdcode(24 downto 21) = x"3" then
              loaded_srca <= rg3;
            end if;
            if ftdcode(24 downto 21) = x"4" then
              loaded_srca <= rg4;
            end if;
            if ftdcode(24 downto 21) = x"5" then
              loaded_srca <= rg5;
            end if;
            if ftdcode(24 downto 21) = x"6" then
              loaded_srca <= rg6;
            end if;
            if ftdcode(24 downto 21) = x"7" then
              loaded_srca <= rg7;
            end if;
            if ftdcode(24 downto 21) = x"8" then
              loaded_srca <= rg8;
            end if;
            if ftdcode(24 downto 21) = x"9" then
              loaded_srca <= rg9;
            end if;
            if ftdcode(24 downto 21) = x"A" then
              loaded_srca <= rgA;
            end if;
            if ftdcode(24 downto 21) = x"B" then
              loaded_srca <= rgB;
            end if;
            if ftdcode(24 downto 21) = x"C" then
              loaded_srca <= rgC;
            end if;
            if ftdcode(24 downto 21) = x"D" then
              loaded_srca <= hp;
            end if;
            if ftdcode(24 downto 21) = x"E" then
              loaded_srca <= sp;
            end if;
            if ftdcode(24 downto 21) = x"F" then
              loaded_srca <= pc;
            end if;
            --set source B
            if ftdcode(20 downto 17) = x"0" then
              loaded_srcb <= rgzero;
            end if;
            if ftdcode(20 downto 17) = x"1" then
              loaded_srcb <= rg1;
            end if;
            if ftdcode(20 downto 17) = x"2" then
              loaded_srcb <= rg2;
            end if;
            if ftdcode(20 downto 17) = x"3" then
              loaded_srcb <= rg3;
            end if;
            if ftdcode(20 downto 17) = x"4" then
              loaded_srcb <= rg4;
            end if;
            if ftdcode(20 downto 17) = x"5" then
              loaded_srcb <= rg5;
            end if;
            if ftdcode(20 downto 17) = x"6" then
              loaded_srcb <= rg6;
            end if;
            if ftdcode(20 downto 17) = x"7" then
              loaded_srcb <= rg7;
            end if;
            if ftdcode(20 downto 17) = x"8" then
              loaded_srcb <= rg8;
            end if;
            if ftdcode(20 downto 17) = x"9" then
              loaded_srcb <= rg9;
            end if;
            if ftdcode(20 downto 17) = x"A" then
              loaded_srcb <= rgA;
            end if;
            if ftdcode(20 downto 17) = x"B" then
              loaded_srcb <= rgB;
            end if;
            if ftdcode(20 downto 17) = x"C" then
              loaded_srcb <= rgC;
            end if;
            if ftdcode(20 downto 17) = x"D" then
              loaded_srcb <= hp;
            end if;
            if ftdcode(20 downto 17) = x"E" then
              loaded_srcb <= sp;
            end if;
              if ftdcode(20 downto 17) = x"F" then
                loaded_srcb <= pc;
              end if;
            end if;
            --set newpc
            if ftdcode(16 downto 13) = x"0" then
              loaded_newpc <= rgzero;
            end if;
            if ftdcode(16 downto 13) = x"1" then
              loaded_newpc <= rg1;
            end if;
            if ftdcode(16 downto 13) = x"2" then
              loaded_newpc <= rg2;
            end if;
            if ftdcode(16 downto 13) = x"3" then
              loaded_newpc <= rg3;
            end if;
            if ftdcode(16 downto 13) = x"4" then
              loaded_newpc <= rg4;
            end if;
            if ftdcode(16 downto 13) = x"5" then
              loaded_newpc <= rg5;
            end if;
            if ftdcode(16 downto 13) = x"6" then
              loaded_newpc <= rg6;
            end if;
            if ftdcode(16 downto 13) = x"7" then
              loaded_newpc <= rg7;
            end if;
            if ftdcode(16 downto 13) = x"8" then
              loaded_newpc <= rg8;
            end if;
            if ftdcode(16 downto 13) = x"9" then
              loaded_newpc <= rg9;
            end if;
            if ftdcode(16 downto 13) = x"A" then
              loaded_newpc <= rgA;
            end if;
            if ftdcode(16 downto 13) = x"B" then
              loaded_newpc <= rgB;
            end if;
            if ftdcode(16 downto 13) = x"C" then
              loaded_newpc <= rgC;
            end if;
            if ftdcode(16 downto 13) = x"D" then
              loaded_newpc <= hp;
            end if;
            if ftdcode(16 downto 13) = x"E" then
              loaded_newpc <= sp;
            end if;
            if ftdcode(16 downto 13) = x"F" then
              loaded_newpc <= pc;
            end if;
          end if;
        end if;
        if phase = "011" then
          --Phase EXEC
          --ALU
          if ftdcode(31 downto 30) = "00" then
            opccode_alu <= ftdcode(31 downto 25);
            reg_in_a <= loaded_srca;
            reg_in_b <= loaded_srcb;
            if ftdcode(31 downto 29) = "001" then
              shift_dir <= ftdcode(7);
              shift_type <= ftdcode(6 downto 5);
              shift_go <= '1';
            end if;
          end if;
          --FPU
          if ftdcode(31 downto 30) = "01" then
            opccode_fpu <= ftdcode(31 downto 25);
            reg_in_a_fpu <= loaded_srca;
            reg_in_b_fpu <= loaded_srcb;
          end if;
          --Branch
          if ftdcode(31 downto 30) = "10" then
            if ftdcode(31 downto 27) = "10001" then
              opccode_fpu <= ftdcode(31 downto 25);
              reg_in_a_fpu <= loaded_srca;
              reg_in_b_fpu <= loaded_srcb;
            else
              opccode_compr <= ftdcode(31 downto 25);
              reg_in_a_compr <= loaded_srca;
              reg_in_b_compr <= loaded_srcb;
            end if;
            --Calculate next PC if branch condition is true
            opccode_alu <= "0000000";
            if ftdcode(25 downto 25) = "1" then
              -- branch imm type
              reg_in_a <= rgzero;
              reg_in_b <= x"000" & "000" & ftdcode(16 downto 0);
            else
              -- branch reg+imm type
              reg_in_a <= loaded_newpc;
              reg_in_b <= x"0000" & "000" & ftdcode(12 downto 0);
            end if;
          end if;
          --MEMORY
          if ftdcode(31 downto 25) = "1100000" then
            --load
            --calculate address
            --register A
            if ftdcode(20 downto 17) = x"0" then
              reg_in_a <= rgzero;
            end if;
            if ftdcode(20 downto 17) = x"1" then
              reg_in_a <= rg1;
            end if;
            if ftdcode(20 downto 17) = x"2" then
              reg_in_a <= rg2;
            end if;
            if ftdcode(20 downto 17) = x"3" then
              reg_in_a <= rg3;
            end if;
            if ftdcode(20 downto 17) = x"4" then
              reg_in_a <= rg4;
            end if;
            if ftdcode(20 downto 17) = x"5" then
              reg_in_a <= rg5;
            end if;
            if ftdcode(20 downto 17) = x"6" then
              reg_in_a <= rg6;
            end if;
            if ftdcode(20 downto 17) = x"7" then
              reg_in_a <= rg7;
            end if;
            if ftdcode(20 downto 17) = x"8" then
              reg_in_a <= rg8;
            end if;
            if ftdcode(20 downto 17) = x"9" then
              reg_in_a <= rg9;
            end if;
            if ftdcode(20 downto 17) = x"A" then
              reg_in_a <= rgA;
            end if;
            if ftdcode(20 downto 17) = x"B" then
              reg_in_a <= rgB;
            end if;
            if ftdcode(20 downto 17) = x"C" then
              reg_in_a <= rgC;
            end if;
            if ftdcode(20 downto 17) = x"D" then
              reg_in_a <= hp;
            end if;
            if ftdcode(20 downto 17) = x"E" then
              reg_in_a <= sp;
            end if;
            if ftdcode(20 downto 17) = x"F" then
              reg_in_a <= pc;
            end if;
            --register B
            if ftdcode(16) = '1' then
              reg_in_b <= x"FFF" & "111" & ftdcode(16 downto 0);
            else
              reg_in_b <= x"000" & "000" & ftdcode(16 downto 0);
            end if;
            opccode_alu <= "0000000";
          end if;
          if ftdcode(31 downto 25) = "1100010" then
            --store
            if ftdcode(20 downto 17) = x"0" then
              reg_in_a <= rgzero;
            end if;
            if ftdcode(20 downto 17) = x"1" then
              reg_in_a <= rg1;
            end if;
            if ftdcode(20 downto 17) = x"2" then
              reg_in_a <= rg2;
            end if;
            if ftdcode(20 downto 17) = x"3" then
              reg_in_a <= rg3;
            end if;
            if ftdcode(20 downto 17) = x"4" then
              reg_in_a <= rg4;
            end if;
            if ftdcode(20 downto 17) = x"5" then
              reg_in_a <= rg5;
            end if;
            if ftdcode(20 downto 17) = x"6" then
              reg_in_a <= rg6;
            end if;
            if ftdcode(20 downto 17) = x"7" then
              reg_in_a <= rg7;
            end if;
            if ftdcode(20 downto 17) = x"8" then
              reg_in_a <= rg8;
            end if;
            if ftdcode(20 downto 17) = x"9" then
              reg_in_a <= rg9;
            end if;
            if ftdcode(20 downto 17) = x"A" then
              reg_in_a <= rgA;
            end if;
            if ftdcode(20 downto 17) = x"B" then
              reg_in_a <= rgB;
            end if;
            if ftdcode(20 downto 17) = x"C" then
              reg_in_a <= rgC;
            end if;
            if ftdcode(20 downto 17) = x"D" then
              reg_in_a <= hp;
            end if;
            if ftdcode(20 downto 17) = x"E" then
              reg_in_a <= sp;
            end if;
            if ftdcode(20 downto 17) = x"F" then
              reg_in_a <= pc;
            end if;
            --register B
            if ftdcode(16) = '1' then
              reg_in_b <= x"FFF" & "111" & ftdcode(16 downto 0);
            else
              reg_in_b <= x"000" & "000" & ftdcode(16 downto 0);
            end if;
            opccode_alu <= "0000000";
          end if;
          if ftdcode(31 downto 25) = "1110001" then
            -- write
            if ftdcode(24 downto 21) = x"1" then
              debug_otpt <= rg1;
            end if;
            if ftdcode(24 downto 21) = x"2" then
              debug_otpt <= rg2;
            end if;
            if ftdcode(24 downto 21) = x"3" then
              debug_otpt <= rg3;
            end if;
            debug_otpt_code <= "000";
            debug_otpt_signal <= '1';
          else
            if ftdcode(31 downto 20) = x"FFD" then
            -- Debug Output
              if ftdcode(3 downto 0) = x"1" then
                debug_otpt <= rg1;
              end if;
              if ftdcode(3 downto 0) = x"2" then
                debug_otpt <= rg2;
              end if;
              if ftdcode(3 downto 0) = x"3" then
                debug_otpt <= rg3;
              end if;
              debug_otpt_code <= ftdcode(6 downto 4);
              debug_otpt_signal <= '1';
            else
              debug_otpt_signal <= '0';
            end if;
          end if;
          -- Debug NOP(all FFFFFFF case doesn't update PC)
        else
          -- the case state = 0 ^ phase != 100
          debug_otpt_signal <= '0';
        end if;
        if phase = "100" then
          --MEMORY
          --Phase Store
          --ALU
          if ftdcode(31 downto 30) = "00" then
            if ftdcode(24 downto 21) = x"1" then
              rg1 <= reg_out;
            end if;
            if ftdcode(24 downto 21) = x"2" then
              rg2 <= reg_out;
            end if;
            if ftdcode(24 downto 21) = x"3" then
              rg3 <= reg_out;
            end if;
            if ftdcode(24 downto 21) = x"4" then
              rg4 <= reg_out;
            end if;
            if ftdcode(24 downto 21) = x"5" then
              rg5 <= reg_out;
            end if;
            if ftdcode(24 downto 21) = x"6" then
              rg6 <= reg_out;
            end if;
            if ftdcode(24 downto 21) = x"7" then
              rg7 <= reg_out;
            end if;
            if ftdcode(24 downto 21) = x"8" then
              rg8 <= reg_out;
            end if;
            if ftdcode(24 downto 21) = x"9" then
              rg9 <= reg_out;
            end if;
            if ftdcode(24 downto 21) = x"A" then
              rgA <= reg_out;
            end if;
            if ftdcode(24 downto 21) = x"B" then
              rgB <= reg_out;
            end if;
            if ftdcode(24 downto 21) = x"C" then
              rgC <= reg_out;
            end if;
            if ftdcode(24 downto 21) = x"D" then
              hp <= reg_out;
            end if;
            if ftdcode(24 downto 21) = x"E" then
              sp <= reg_out;
            end if;
            if ftdcode(24 downto 21) = x"F" then
              pc <= reg_out;
            end if;
          end if;
          --FPU
          if ftdcode(31 downto 30) = "01" then
            if ftdcode(31 downto 25) = "0101010" then
              --ftoi
              if ftdcode(24 downto 21) = x"1" then
                rg1 <= reg_out;
              end if;
              if ftdcode(24 downto 21) = x"2" then
                rg2 <= reg_out;
              end if;
            if ftdcode(24 downto 21) = x"3" then
              rg3 <= reg_out;
            end if;
            if ftdcode(24 downto 21) = x"4" then
              rg4 <= reg_out;
            end if;
            if ftdcode(24 downto 21) = x"5" then
              rg5 <= reg_out;
            end if;
            if ftdcode(24 downto 21) = x"6" then
              rg6 <= reg_out;
            end if;
            if ftdcode(24 downto 21) = x"7" then
              rg7 <= reg_out;
            end if;
            if ftdcode(24 downto 21) = x"8" then
              rg8 <= reg_out;
            end if;
            if ftdcode(24 downto 21) = x"9" then
              rg9 <= reg_out;
            end if;
            if ftdcode(24 downto 21) = x"A" then
              rgA <= reg_out;
            end if;
            if ftdcode(24 downto 21) = x"B" then
              rgB <= reg_out;
            end if;
            if ftdcode(24 downto 21) = x"C" then
              rgC <= reg_out;
            end if;
            if ftdcode(24 downto 21) = x"D" then
              hp <= reg_out;
            end if;
              if ftdcode(24 downto 21) = x"E" then
                sp <= reg_out;
              end if;
              if ftdcode(24 downto 21) = x"F" then
                pc <= reg_out;
              end if;
            else
              if ftdcode(24 downto 21) = x"1" then
                fp1 <= reg_out_fpu;
              end if;
              if ftdcode(24 downto 21) = x"2" then
                fp2 <= reg_out_fpu;
              end if;
            if ftdcode(24 downto 21) = x"3" then
              fp3 <= reg_out_fpu;
            end if;
            if ftdcode(24 downto 21) = x"4" then
              fp4 <= reg_out_fpu;
            end if;
            if ftdcode(24 downto 21) = x"5" then
              fp5 <= reg_out_fpu;
            end if;
            if ftdcode(24 downto 21) = x"6" then
              fp6 <= reg_out_fpu;
            end if;
            if ftdcode(24 downto 21) = x"7" then
              fp7 <= reg_out_fpu;
            end if;
            if ftdcode(24 downto 21) = x"8" then
              fp8 <= reg_out_fpu;
            end if;
            if ftdcode(24 downto 21) = x"9" then
              fp9 <= reg_out_fpu;
            end if;
            if ftdcode(24 downto 21) = x"A" then
              fpA <= reg_out_fpu;
            end if;
            if ftdcode(24 downto 21) = x"B" then
              fpB <= reg_out_fpu;
            end if;
            if ftdcode(24 downto 21) = x"C" then
              fpC <= reg_out_fpu;
            end if;
            if ftdcode(24 downto 21) = x"D" then
              fpD <= reg_out_fpu;
            end if;
              if ftdcode(24 downto 21) = x"E" then
                fpE <= reg_out_fpu;
              end if;
              if ftdcode(24 downto 21) = x"F" then
                fpret <= reg_out_fpu;
              end if;
            end if;
          end if;
          if ftdcode(31 downto 25) = "1100000" then
            --load(integer)
            if ftdcode(24 downto 21) = x"1" then
              rg1 <= sram_read;
            end if;
            if ftdcode(24 downto 21) = x"2" then
              rg2 <= sram_read;
            end if;
            if ftdcode(24 downto 21) = x"3" then
              rg3 <= sram_read;
            end if;
            if ftdcode(24 downto 21) = x"4" then
              rg4 <= sram_read;
            end if;
            if ftdcode(24 downto 21) = x"5" then
              rg5 <= sram_read;
            end if;
            if ftdcode(24 downto 21) = x"6" then
              rg6 <= sram_read;
            end if;
            if ftdcode(24 downto 21) = x"7" then
              rg7 <= sram_read;
            end if;
            if ftdcode(24 downto 21) = x"8" then
              rg8 <= sram_read;
            end if;
            if ftdcode(24 downto 21) = x"9" then
              rg9 <= sram_read;
            end if;
            if ftdcode(24 downto 21) = x"A" then
              rgA <= sram_read;
            end if;
            if ftdcode(24 downto 21) = x"B" then
              rgB <= sram_read;
            end if;
            if ftdcode(24 downto 21) = x"C" then
              rgC <= sram_read;
            end if;
            if ftdcode(24 downto 21) = x"D" then
              hp <= sram_read;
            end if;
            if ftdcode(24 downto 21) = x"E" then
              sp <= sram_read;
            end if;
            if ftdcode(24 downto 21) = x"F" then
              pc <= sram_read;
            end if;
          end if;
          if ftdcode(31 downto 25) = "1100100" then
            --fload(float)
            if ftdcode(24 downto 21) = x"1" then
              fp1 <= sram_read;
            end if;
            if ftdcode(24 downto 21) = x"2" then
              fp2 <= sram_read;
            end if;
            if ftdcode(24 downto 21) = x"3" then
              fp3 <= sram_read;
            end if;
            if ftdcode(24 downto 21) = x"4" then
              fp4 <= sram_read;
            end if;
            if ftdcode(24 downto 21) = x"5" then
              fp5 <= sram_read;
            end if;
            if ftdcode(24 downto 21) = x"6" then
              fp6 <= sram_read;
            end if;
            if ftdcode(24 downto 21) = x"7" then
              fp7 <= sram_read;
            end if;
            if ftdcode(24 downto 21) = x"8" then
              fp8 <= sram_read;
            end if;
            if ftdcode(24 downto 21) = x"9" then
              fp9 <= sram_read;
            end if;
            if ftdcode(24 downto 21) = x"A" then
              fpA <= sram_read;
            end if;
            if ftdcode(24 downto 21) = x"B" then
              fpB <= sram_read;
            end if;
            if ftdcode(24 downto 21) = x"C" then
              fpC <= sram_read;
            end if;
            if ftdcode(24 downto 21) = x"D" then
              fpD <= sram_read;
            end if;
            if ftdcode(24 downto 21) = x"E" then
              fpE <= sram_read;
            end if;
            if ftdcode(24 downto 21) = x"F" then
              fpret <= sram_read;
            end if;
          end if;
          if ftdcode(31 downto 25) = "1110000" then
            --read
            if ftdcode(24 downto 21) = x"1" then
              rg1 <= sram_read;
            end if;
            if ftdcode(24 downto 21) = x"2" then
              rg2 <= sram_read;
            end if;
            if ftdcode(24 downto 21) = x"3" then
              rg3 <= sram_read;
            end if;
            if ftdcode(24 downto 21) = x"4" then
              rg4 <= sram_read;
            end if;
            if ftdcode(24 downto 21) = x"5" then
              rg5 <= sram_read;
            end if;
            if ftdcode(24 downto 21) = x"6" then
              rg6 <= sram_read;
            end if;
            if ftdcode(24 downto 21) = x"7" then
              rg7 <= sram_read;
            end if;
            if ftdcode(24 downto 21) = x"8" then
              rg8 <= sram_read;
            end if;
            if ftdcode(24 downto 21) = x"9" then
              rg9 <= sram_read;
            end if;
            if ftdcode(24 downto 21) = x"A" then
              rgA <= sram_read;
            end if;
            if ftdcode(24 downto 21) = x"B" then
              rgB <= sram_read;
            end if;
            if ftdcode(24 downto 21) = x"C" then
              rgC <= sram_read;
            end if;
            if ftdcode(24 downto 21) = x"D" then
              hp <= sram_read;
            end if;
            if ftdcode(24 downto 21) = x"E" then
              sp <= sram_read;
            end if;
            if ftdcode(24 downto 21) = x"F" then
              pc <= sram_read;
            end if;
          end if;
          --Update PC (Branch case)
          if ftdcode(31 downto 30) = "10" then
            pc <= cond_new_pc;
          else
            if ftdcode(31 downto 0) = x"FFFFFFFF" then
              -- added nop
            else
              -- The Case when update pc by ALU,load
              if (ftdcode(31 downto 30) = "00") and (ftdcode(24 downto 21) = x"F") then
              else
                if (ftdcode(31 downto 25) = "1100000") and (ftdcode(24 downto 21) = x"F") then
                else
                  pc <= pc + 4;
                end if;
              end if;
            end if;
          end if;
        end if;
      else
        -- the case state != 0
        debug_otpt_signal <= '0';
      end if;
      if state = x"1" then
        sram_go <= '0';
        inputc_fetched <= '0';
        shift_go <= '0';
      end if;
      -- state action two
      if state = x"8" then
        if phase = "000" then
          --Phase Fetch
          if inputc_sram_request_get = '1' then
            inputc_sram_getvalue <= sram_read;
            inputc_sram_request_finished <= '1';
          end if;
        end if;
        if phase = "011" then
          --Phase EXEC
          if (ftdcode(31 downto 25) = "1100000") or (ftdcode(31 downto 25) = "1100100") then
            --load,fload
            sram_go <= '1';
            sram_addr <= reg_out(19 downto 0);
            sram_inst_type <= '0';
          end if;
          if ftdcode(31 downto 25) = "1100010" then
            --store(integer)
            sram_go <= '1';
            sram_inst_type <= '1';
            sram_addr <= reg_out(19 downto 0);
            if ftdcode(24 downto 21) = x"0" then
              sram_write <= rgzero;
            end if;
            if ftdcode(24 downto 21) = x"1" then
              sram_write <= rg1;
            end if;
            if ftdcode(24 downto 21) = x"2" then
              sram_write <= rg2;
            end if;
            if ftdcode(24 downto 21) = x"3" then
              sram_write <= rg3;
            end if;
            if ftdcode(24 downto 21) = x"4" then
              sram_write <= rg4;
            end if;
            if ftdcode(24 downto 21) = x"5" then
              sram_write <= rg5;
            end if;
            if ftdcode(24 downto 21) = x"6" then
              sram_write <= rg6;
            end if;
            if ftdcode(24 downto 21) = x"7" then
              sram_write <= rg7;
            end if;
            if ftdcode(24 downto 21) = x"8" then
              sram_write <= rg8;
            end if;
            if ftdcode(24 downto 21) = x"9" then
              sram_write <= rg9;
            end if;
            if ftdcode(24 downto 21) = x"A" then
              sram_write <= rgA;
            end if;
            if ftdcode(24 downto 21) = x"B" then
              sram_write <= rgB;
            end if;
            if ftdcode(24 downto 21) = x"C" then
              sram_write <= rgC;
            end if;
            if ftdcode(24 downto 21) = x"D" then
              sram_write <= hp;
            end if;
            if ftdcode(24 downto 21) = x"E" then
              sram_write <= sp;
            end if;
            if ftdcode(24 downto 21) = x"F" then
              sram_write <= pc;
            end if;
          end if;
          if ftdcode(31 downto 25) = "1100110" then
            --fstore(float)
            sram_go <= '1';
            sram_inst_type <= '1';
            sram_addr <= reg_out(19 downto 0);
            if ftdcode(24 downto 21) = x"0" then
              sram_write <= fpzero;
            end if;
            if ftdcode(24 downto 21) = x"1" then
              sram_write <= fp1;
            end if;
            if ftdcode(24 downto 21) = x"2" then
              sram_write <= fp2;
            end if;
            if ftdcode(24 downto 21) = x"3" then
              sram_write <= fp3;
            end if;
            if ftdcode(24 downto 21) = x"4" then
              sram_write <= fp4;
            end if;
            if ftdcode(24 downto 21) = x"5" then
              sram_write <= fp5;
            end if;
            if ftdcode(24 downto 21) = x"6" then
              sram_write <= fp6;
            end if;
            if ftdcode(24 downto 21) = x"7" then
              sram_write <= fp7;
            end if;
            if ftdcode(24 downto 21) = x"8" then
              sram_write <= fp8;
            end if;
            if ftdcode(24 downto 21) = x"9" then
              sram_write <= fp9;
            end if;
            if ftdcode(24 downto 21) = x"A" then
              sram_write <= fpA;
            end if;
            if ftdcode(24 downto 21) = x"B" then
              sram_write <= fpB;
            end if;
            if ftdcode(24 downto 21) = x"C" then
              sram_write <= fpC;
            end if;
            if ftdcode(24 downto 21) = x"D" then
              sram_write <= fpD;
            end if;
            if ftdcode(24 downto 21) = x"E" then
              sram_write <= fpE;
            end if;
            if ftdcode(24 downto 21) = x"F" then
              sram_write <= fpret;
            end if;
          end if;
          if ftdcode(31 downto 25) = "1110000" then
            --read
            sram_go <= '1';
            sram_addr <= read_index;
            read_index <= read_index + 1;
            sram_inst_type <= '0';
          end if;
        else
          sram_go <= '0';
        end if;
      end if;
      if state = x"9" then
        --reflesh
        sram_go <= '0';
        inputc_sram_request_finished <= '0';
      end if;
      if state = x"E" then
        -- pickup groups
        -- Update cond_new_pc
        if phase = "011" then
          --phase EXEC
          if ftdcode(31 downto 27) = "10001" then
            if reg_out_fpu(0) = '1' then
              cond_new_pc <= reg_out;
            else
              cond_new_pc <= pc + 4;
            end if;            
          else
            if cond_out_compr = '1' then
              cond_new_pc <= reg_out;
            else
              cond_new_pc <= pc + 4;
            end if;
          end if;
        end if;
      end if;
      --if state = x"BB" then
      --  debug_otpt <= reg_out;
      --end if;
      if state = x"F" then
        -- move to next phase
        phase <= phase + 1;
      end if;
      state <= state + 1;
      ostate <= "00000000" + state + 1;
    end if;
  end process;
end cocore;

