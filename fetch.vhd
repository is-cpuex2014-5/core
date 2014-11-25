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
if pc = 0 then
	inst <= "82000094";
end if;
if pc = 1 then
	inst <= "02400002";
end if;
if pc = 2 then
	inst <= "86240088";
end if;
if pc = 3 then
	inst <= "06420001";
end if;
if pc = 4 then
	inst <= "C43C0000";
end if;
if pc = 5 then
	inst <= "C17DFFFC";
end if;
if pc = 6 then
	inst <= "00240000";
end if;
if pc = 7 then
	inst <= "C57C0004";
end if;
if pc = 8 then
	inst <= "03DC0008";
end if;
if pc = 9 then
	inst <= "037E0010";
end if;
if pc = 10 then
	inst <= "C57C0000";
end if;
if pc = 11 then
	inst <= "03DC0004";
end if;
if pc = 12 then
	inst <= "82000004";
end if;
if pc = 13 then
	inst <= "07DC0008";
end if;
if pc = 14 then
	inst <= "C17C0004";
end if;
if pc = 15 then
	inst <= "C57DFFFC";
end if;
if pc = 16 then
	inst <= "C05C0000";
end if;
if pc = 17 then
	inst <= "06440002";
end if;
if pc = 18 then
	inst <= "C43C0004";
end if;
if pc = 19 then
	inst <= "C17DFFFC";
end if;
if pc = 20 then
	inst <= "00240000";
end if;
if pc = 21 then
	inst <= "C57C000C";
end if;
if pc = 22 then
	inst <= "03DC0010";
end if;
if pc = 23 then
	inst <= "037E0010";
end if;
if pc = 24 then
	inst <= "C57C0000";
end if;
if pc = 25 then
	inst <= "03DC0004";
end if;
if pc = 26 then
	inst <= "82000004";
end if;
if pc = 27 then
	inst <= "07DC0010";
end if;
if pc = 28 then
	inst <= "C17C000C";
end if;
if pc = 29 then
	inst <= "C57DFFFC";
end if;
if pc = 30 then
	inst <= "C05C0004";
end if;
if pc = 31 then
	inst <= "00242000";
end if;
if pc = 32 then
	inst <= "07DC0004";
end if;
if pc = 33 then
	inst <= "C1FC0000";
end if;
if pc = 34 then
	inst <= "02200001";
end if;
if pc = 35 then
	inst <= "07DC0004";
end if;
if pc = 36 then
	inst <= "C1FC0000";
end if;
if pc = 37 then
	inst <= "0220000A";
end if;
if pc = 38 then
	inst <= "C17DFFFC";
end if;
if pc = 39 then
	inst <= "C57C0004";
end if;
if pc = 40 then
	inst <= "03DC0008";
end if;
if pc = 41 then
	inst <= "037E0010";
end if;
if pc = 42 then
	inst <= "C57C0000";
end if;
if pc = 43 then
	inst <= "03DC0004";
end if;
if pc = 44 then
	inst <= "82000004";
end if;
if pc = 45 then
	inst <= "07DC0008";
end if;
if pc = 46 then
	inst <= "C17C0004";
end if;
if pc = 47 then
	inst <= "C57DFFFC";
end if;
if pc = 48 then
	inst <= "8001E000";
end if;
if pc > 48 then
	inst <= "FFFFFFFF";
end if;          -- load from SRAM
          -- send to core
--          if pc > 1 then
--            --debug write 0 s1
--            inst <= x"FFFFFFFF";
--          end if;
--          if pc = 0 then
--            --read s1
--            inst <= x"E0200000";
--          end if;
--          if pc = 1 then
--            --write s1
--            inst <= x"E2200000";
--            waitwrite <= x"20000";
--          end if;
          --inst_sram_addr <= pc(19 downto 0);
          --if inst_sram_request_finished = '1' then
          --  inst <= inst_sram_getvalue;
          --end if;
          --if (inst_fetched = '1') and (inst_sram_getvalue(31 downto 20) = x"FFD") then
          --  waitwrite <= x"20000";
          --  inst_sram_request <= '0';
          --else
          --  inst_sram_request <= '1';
          --end if;
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

