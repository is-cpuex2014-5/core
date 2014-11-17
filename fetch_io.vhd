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
          inst_sram_addr <= pc(19 downto 0);
          if inst_sram_request_finished = '1' then
            inst <= inst_sram_getvalue;
          end if;
          if (inst_fetched = '1') and (inst_sram_getvalue(31 downto 20) = x"FFD") then
            waitwrite <= x"20000";
            inst_sram_request <= '0';
          else
            inst_sram_request <= '1';
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

