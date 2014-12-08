-- Fetch.vhd
-- Read code from SRAM (Not yet)
-- send back to core.vhd

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity fetch is
  Port (
    clk : in std_logic;
    load_signal : in std_logic := '0';
    pc : in std_logic_vector(31 downto 0);
    inst_sram_request : out std_logic;
    inst_sram_addr : out std_logic_vector(19 downto 0);
    inst_sram_getvalue : in std_logic_vector(31 downto 0);
    inst_sram_request_finished : in std_logic;
    inst_fetched : in std_logic;
    inst : out std_logic_vector(31 downto 0)
  );
end fetch;

architecture fetch_test of fetch is
  signal waitwrite : std_logic_vector(19 downto 0) := x"00000";
begin
  fetch_main: process(clk)
  begin
    if rising_edge(clk) then
      if load_signal = '1' then
        if waitwrite = 0 then
          -- load from SRAM
          -- send to core
          if pc > 4 then
            --halt (beq s0,s0,s0,3)
            inst <= x"80000003";
            --inst <= x"FFFFFFFF"; -- nop
          end if;
          if pc = 0 then
            --addi s1,s0,11
            inst <= x"0220000B";
          end if;
          if pc = 1 then
            --addi s2,s0,13
            inst <= x"0240000D";
          end if;
          if pc = 2 then
            --nor s3,s1,s2
            inst <= x"1C624000"; -- 0001 1100 0110 0010 010
          end if;
          if pc = 3 then
            --addi s4,s0,31
            inst <= x"0280001F";
          end if;
          if pc = 4 then
            --shift s1,s3,s4,1,rotate
            inst <= x"202680C0"; -- 0010 0000 0010 0110 1000 0000 100 
          end if;
        else
          inst <= x"FFFFFFFF";
        end if;
      end if;
      if waitwrite > 0 then
        waitwrite <= waitwrite - 1;
      end if;
    end if;
  end process;
end fetch_test;
