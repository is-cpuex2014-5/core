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
    inst : out std_logic_vector(31 downto 0);
    waitwrite : in std_logic_vector(19 downto 0)
  );
end fetch;

architecture fetch_test of fetch is
begin
  fetch_main: process(clk)
  begin
    if rising_edge(clk) then
      if load_signal = '1' then
        if waitwrite = 0 then
if pc = 0 then
--	inst <= x"C0200010";
	inst <= x"82000064";
end if;
if pc = 4 then
--	inst <= x"02220035";
	inst <= x"3F800000";
end if;
if pc = 8 then
--	inst <= x"E2200000";
	inst <= x"02400002";
end if;
if pc = 12 then
--    inst <= x"8001E000";
	inst <= x"8624005C";
end if;
if pc = 16 then
	inst <= x"06420001";
end if;
if pc = 20 then
	inst <= x"C43C0000";
end if;
if pc = 24 then
	inst <= x"00240000";
end if;
if pc = 28 then
	inst <= x"03DC000C";
end if;
if pc = 32 then
	inst <= x"037E000C";
end if;
if pc = 36 then
	inst <= x"C57DFFFC";
end if;
if pc = 40 then
	inst <= x"82000008";
end if;
if pc = 44 then
	inst <= x"07DC000C";
end if;
if pc = 48 then
	inst <= x"C03C0000";
end if;
if pc = 52 then
	inst <= x"06220002";
end if;
if pc = 56 then
	inst <= x"CC3C0008";
end if;
if pc = 60 then
	inst <= x"03DC0018";
end if;
if pc = 64 then
	inst <= x"037E000C";
end if;
if pc = 68 then
	inst <= x"C57DFFFC";
end if;
if pc = 72 then
	inst <= x"82000008";
end if;
if pc = 76 then
	inst <= x"07DC0018";
end if;
if pc = 80 then
	inst <= x"C85C0008";
end if;
if pc = 84 then
	inst <= x"40242000";
end if;
if pc = 88 then
	inst <= x"C1FDFFFC";
end if;
if pc = 92 then
	inst <= x"C8200004";
end if;
if pc = 96 then
	inst <= x"C1FDFFFC";
end if;
if pc = 100 then
	inst <= x"0220000A";
end if;
if pc = 104 then
	inst <= x"03DC0008";
end if;
if pc = 108 then
	inst <= x"037E000C";
end if;
if pc = 112 then
	inst <= x"C57DFFFC";
end if;
if pc = 116 then
	inst <= x"82000008";
end if;
if pc = 120 then
	inst <= x"07DC0008";
end if;
if pc = 124 then
	inst <= x"54220000";
end if;
if pc = 128 then
	inst <= x"E2200000";
end if;
if pc = 132 then
	inst <= x"8001E000";
end if;
if pc > 132 then
	inst <= x"FFFFFFFF";
end if;
          -- load from SRAM
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
    end if;
  end process;
end fetch_test;

