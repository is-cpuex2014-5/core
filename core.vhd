library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity core is
  Port (
    clk : in std_logic;
    ostate : out std_logic_vector(7 downto 0);
    debug_otpt : out std_logic_vector(31 downto 0)
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
  signal ldsig : std_logic := '1';
  signal inst_from_fetch : std_logic_vector(31 downto 0);
  signal ftdcode : std_logic_vector(31 downto 0);
  signal opccode_alu : std_logic_vector(6 downto 0);
  signal reg_in_a : std_logic_vector(31 downto 0);
  signal reg_in_b : std_logic_vector(31 downto 0);
  signal reg_out : std_logic_vector(31 downto 0);
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
  core_pro: process(clk)
  begin
    if rising_edge(clk) then
      if state = x"00" then
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
          opccode_alu <= ftdcode(31 downto 25);
          if ftdcode(31 downto 30) = "00" then
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
            --set register B
            if ftdcode(31 downto 25) = "0000001" then
              -- add immediate
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
            end if;
          end if;
        end if;
        if phase = "100" then
          --Phase Store
          if ftdcode(31 downto 25) = "0000000" then
            if ftdcode(24 downto 21) = x"1" then
              rg1 <= reg_out;
            end if;
            if ftdcode(24 downto 21) = x"2" then
              rg2 <= reg_out;
            end if;
            if ftdcode(24 downto 21) = x"3" then
              rg3 <= reg_out;
            end if;
          end if;
          if ftdcode(31 downto 25) = "0000001" then
            if ftdcode(24 downto 21) = x"1" then
              rg1 <= reg_out;
            end if;
            if ftdcode(24 downto 21) = x"2" then
              rg2 <= reg_out;
            end if;
            if ftdcode(24 downto 21) = x"3" then
              rg3 <= reg_out;
            end if;
          end if;
          --Add PC
          pc <= pc + 1;
        end if;
        phase <= phase + 1;
      end if;
      if state = x"BB" then
        debug_otpt <= reg_out;
      end if;
      state <= state + 1;
      ostate <= state + 1;
    end if;
  end process;
end cocore;

