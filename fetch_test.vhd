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
          if pc > 9 then
            --halt (beq s0,s0,s0)
            inst <= x"80000000";
            --inst <= x"FFFFFFFF"; -- nop
          end if;
          if pc = 0 then
            --addi s1,s0,5
            inst <= x"02200005";
          end if;
          if pc = 1 then
            --debug write 0 s1
            inst <= x"FFDFFF01";
            --waitwrite <= x"20000";
          end if;
          if pc = 2 then
            --store s1,s0,0
            inst <= x"C2200000";
          end if;
          if pc = 3 then
            --addi s1,s0,1
            inst <= x"02200001";
          end if;
          if pc = 4 then
            --debug write 0 s1
            inst <= x"FFDFFF01";
            --waitwrite <= x"20000";
          end if;
          if pc = 5 then
            --store s1,s0,0
            inst <= x"C2200001";
          end if;
          if pc = 6 then
            --load s1,s0,0
            inst <= x"C0200000";
          end if;
          if pc = 7 then
            --debug write 0 s1
            inst <= x"FFDFFF01";
            --waitwrite <= x"20000";
          end if;
          if pc = 8 then
            --load s1,s0,1
            inst <= x"C0200001";
          end if;
          if pc = 9 then
            --debug write 0 s1
            inst <= x"FFDFFF01";
            --waitwrite <= x"20000";
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

