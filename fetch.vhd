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
begin
  fetch_main: process(clk)
  begin
    if rising_edge(clk) then
      if load_signal = '1' then
        -- load from SRAM
        -- send to core
        if pc > 2 then
          inst <= x"FFFFFFFF"; -- nop
        end if;
        if pc = 0 then
          inst <= x"02400002";
        end if;
        if pc = 1 then
          inst <= x"02600003";
        end if;
        if pc = 2 then
          inst <= x"00446000";
        end if;
      end if;
    end if;
  end process;
end fetch_test;

