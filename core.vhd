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
  signal hp : std_logic_vector(31 downto 0) := x"00055555";
  signal sp : std_logic_vector(31 downto 0) := x"000AAAAA";
  signal pc : std_logic_vector(31 downto 0) := x"00000000";
  signal fpzero : std_logic_vector(31 downto 0) := x"00000000";
  signal fp1 : std_logic_vector(31 downto 0) := x"00000001";
  signal fp2 : std_logic_vector(31 downto 0) := x"00000002";
  signal fp3 : std_logic_vector(31 downto 0) := x"00000008";
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
  signal state : std_logic_vector(7 downto 0) := x"C0";
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
      if state = x"00" then
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
            end if;
          end if;
          --FPU
          if ftdcode(31 downto 30) = "01" then
            --set source A
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
          end if;
          --Branch
          if ftdcode(31 downto 30) = "10" then
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
            opccode_compr <= ftdcode(31 downto 25);
            reg_in_a_compr <= loaded_srca;
            reg_in_b_compr <= loaded_srcb;
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
            --register B
            reg_in_b <= x"000" & "000" & ftdcode(16 downto 0);
            opccode_alu <= "0000000";
          end if;
          if ftdcode(31 downto 25) = "1100001" then
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
            --register B
            reg_in_b <= x"000" & "000" & ftdcode(16 downto 0);
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
          end if;
          --FPU
          if ftdcode(31 downto 30) = "01" then
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
          end if;
          if ftdcode(31 downto 25) = "1100000" then
            --load
            if ftdcode(24 downto 21) = x"1" then
              rg1 <= sram_read;
            end if;
          end if;
          if ftdcode(31 downto 25) = "1110000" then
            --read
            if ftdcode(24 downto 21) = x"1" then
              rg1 <= sram_read;
            end if;
          end if;
          --Update PC (Branch case)
          if ftdcode(31 downto 30) = "10" then
            pc <= cond_new_pc;
          else
            if ftdcode(31 downto 0) = x"FFFFFFFF" then
              -- added nop
            else
              pc <= pc + 1;
            end if;
          end if;
        end if;
      else
        -- the case state != 0
        debug_otpt_signal <= '0';
      end if;
      if state = x"01" then
        sram_go <= '0';
        inputc_fetched <= '0';
        shift_go <= '0';
      end if;
      -- state action two
      if state = x"80" then
        if phase = "000" then
          --Phase Fetch
          if inputc_sram_request_get = '1' then
            inputc_sram_getvalue <= sram_read;
            inputc_sram_request_finished <= '1';
          end if;
        end if;
        if phase = "011" then
          --Phase EXEC
          if ftdcode(31 downto 25) = "1100000" then
            --load
            sram_go <= '1';
            sram_addr <= reg_out(19 downto 0);
            sram_inst_type <= '0';
          end if;
          if ftdcode(31 downto 25) = "1100001" then
            --store
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
      if state = x"81" then
        --reflesh
        sram_go <= '0';
        inputc_sram_request_finished <= '0';
      end if;
      if state = x"C0" then
        -- pickup groups
        -- Update cond_new_pc
        if phase = "011" then
          --phase EXEC
          if cond_out_compr = '1' then
            cond_new_pc <= reg_out;
          else
            cond_new_pc <= pc + 1;
          end if;
        end if;
      end if;
      --if state = x"BB" then
      --  debug_otpt <= reg_out;
      --end if;
      if state = x"FF" then
        -- move to next phase
        phase <= phase + 1;
      end if;
      state <= state + 1;
      ostate <= state + 1;
    end if;
  end process;
end cocore;

