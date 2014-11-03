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
    inst : out std_logic_vector(31 downto 0)
  );
  end component;
  component alu Port (
    clk : in std_logic;
    opc_alu : in std_logic_vector(6 downto 0);
    reg_in_a : in std_logic_vector(31 downto 0);
    reg_in_b : in std_logic_vector(31 downto 0);
    reg_out : out std_logic_vector(31 downto 0)
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
-- registers
  signal rgzero : std_logic_vector(31 downto 0) := x"00000000";
  signal rg1 : std_logic_vector(31 downto 0) := x"00000007";
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
  signal rgD : std_logic_vector(31 downto 0) := x"00000000";
  signal rgE : std_logic_vector(31 downto 0) := x"00000000";
  signal rgF : std_logic_vector(31 downto 0) := x"00000000";
-- signals
  signal state : std_logic_vector(7 downto 0) := x"C0";
  signal phase : std_logic_vector(2 downto 0) := "000";
    --phase: active phase (without pipelines)
  signal pc : std_logic_vector(31 downto 0) := x"00000000";
  signal cond_new_pc : std_logic_vector(31 downto 0) := x"00000000";
  signal ldsig : std_logic := '1';
  signal inst_from_fetch : std_logic_vector(31 downto 0);
  signal ftdcode : std_logic_vector(31 downto 0);
  signal opccode_alu : std_logic_vector(6 downto 0);
  signal reg_in_a : std_logic_vector(31 downto 0);
  signal reg_in_b : std_logic_vector(31 downto 0);
  signal reg_out : std_logic_vector(31 downto 0);
  signal opccode_compr : std_logic_vector(6 downto 0);
  signal reg_in_a_compr : std_logic_vector(31 downto 0);
  signal reg_in_b_compr : std_logic_vector(31 downto 0);
  signal cond_out_compr : std_logic;
begin
  with_fetch: fetch Port map (
      clk => clk,
      pc => pc,
      load_signal => ldsig,
      inst => inst_from_fetch
    );
  with_alu: alu Port map (
      clk => clk,
      opc_alu => opccode_alu,
      reg_in_a => reg_in_a,
      reg_in_b => reg_in_b,
      reg_out => reg_out
    );
  with_compr: compr Port map (
      clk => clk,
      opc_compr => opccode_compr,
      reg_in_a => reg_in_a_compr,
      reg_in_b => reg_in_b_compr,
      cond_out => cond_out_compr
    );
  core_pro: process(clk)
  begin
    if (rising_edge(clk)) and (execute_ok = '1') then
      -- state action one
      if state = x"00" then
        -- initialize groups
        if phase = "000" then
          --Phase Fetch
        end if;
        if phase = "001" then
          --Phase Decode
          ftdcode <= inst_from_fetch;
        end if;
        if phase = "010" then
          --Phase Load
        end if;
        if phase = "011" then
          --Phase EXEC
          --ALU
          if ftdcode(31 downto 30) = "00" then
            opccode_alu <= ftdcode(31 downto 25);
            --set register A
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
            --set register B
            if (ftdcode(31 downto 25) = "0000001") or (ftdcode(31 downto 25) = "0000011") then
              -- set immediate
              if ftdcode(16) = '1' then
                -- high
                reg_in_b <= ftdcode(15 downto 0)&"0000000000000000";
              else
                -- low
                reg_in_b <= "0000000000000000"&ftdcode(15 downto 0);
              end if;
            else
              if ftdcode(16 downto 13) = x"0" then
                reg_in_b <= rgzero;
              end if;
              if ftdcode(16 downto 13) = x"1" then
                reg_in_b <= rg1;
              end if;
              if ftdcode(16 downto 13) = x"2" then
                reg_in_b <= rg2;
              end if;
              if ftdcode(16 downto 13) = x"3" then
                reg_in_b <= rg3;
              end if;
              if ftdcode(16 downto 13) = x"4" then
                reg_in_b <= rg4;
              end if;
              if ftdcode(16 downto 13) = x"5" then
                reg_in_b <= rg5;
              end if;
            end if;
          end if;
          --Branch
          if ftdcode(31 downto 30) = "10" then
            opccode_compr <= ftdcode(31 downto 25);
            --set register A
            if ftdcode(24 downto 21) = x"0" then
              reg_in_a_compr <= rgzero;
            end if;
            if ftdcode(24 downto 21) = x"1" then
              reg_in_a_compr <= rg1;
            end if;
            if ftdcode(24 downto 21) = x"2" then
              reg_in_a_compr <= rg2;
            end if;
            if ftdcode(24 downto 21) = x"3" then
              reg_in_a_compr <= rg3;
            end if;
            if ftdcode(24 downto 21) = x"4" then
              reg_in_a_compr <= rg4;
            end if;
            if ftdcode(24 downto 21) = x"5" then
              reg_in_a_compr <= rg5;
            end if;
            --set register B
            if ftdcode(20 downto 17) = x"0" then
              reg_in_b_compr <= rgzero;
            end if;
            if ftdcode(20 downto 17) = x"1" then
              reg_in_b_compr <= rg1;
            end if;
            if ftdcode(20 downto 17) = x"2" then
              reg_in_b_compr <= rg2;
            end if;
            if ftdcode(20 downto 17) = x"3" then
              reg_in_b_compr <= rg3;
            end if;
            if ftdcode(20 downto 17) = x"4" then
              reg_in_b_compr <= rg4;
            end if;
            if ftdcode(20 downto 17) = x"5" then
              reg_in_b_compr <= rg5;
            end if;
            --Calculate next PC if branch condition is true
            opccode_alu <= "0000000";
            reg_in_a <= pc;
            if ftdcode(31 downto 25) = "1000000" then
              if ftdcode(16 downto 13) = x"0" then
                reg_in_b <= rgzero;
              end if;
              if ftdcode(16 downto 13) = x"1" then
                reg_in_b <= rg1;
              end if;
              if ftdcode(16 downto 13) = x"2" then
                reg_in_b <= rg2;
              end if;
              if ftdcode(16 downto 13) = x"3" then
                reg_in_b <= rg3;
              end if;
              if ftdcode(16 downto 13) = x"4" then
                reg_in_b <= rg4;
              end if;
              if ftdcode(16 downto 13) = x"5" then
                reg_in_b <= rg5;
              end if;
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
          -- Debug NOP(all FFFFFFF case doesn't update PC)
        else
          -- the case state = 0 ^ phase != 100
          debug_otpt_signal <= '0';
        end if;
        if phase = "100" then
          --MEMORY
          --Phase Store
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
          if ftdcode(31 downto 25) = "1100000" then
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
      -- state action two
      if state = x"80" then
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
        else
          sram_go <= '0';
        end if;
      else
        sram_go <= '0';
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

