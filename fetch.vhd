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
	inst <= x"8200019C";
end if;
if pc = 4 then
	inst <= x"00000000";
end if;
if pc = 8 then
	inst <= x"3F800000";
end if;
if pc = 12 then
	inst <= x"3FC00000";
end if;
if pc = 16 then
	inst <= x"43000000";
end if;
if pc = 20 then
	inst <= x"40800000";
end if;
if pc = 24 then
	inst <= x"40222000";
end if;
if pc = 28 then
	inst <= x"C1FDFFFC";
end if;
if pc = 32 then
	inst <= x"82200098";
end if;
if pc = 36 then
	inst <= x"44668000";
end if;
if pc = 40 then
	inst <= x"4066A000";
end if;
if pc = 44 then
	inst <= x"CCBC0000";
end if;
if pc = 48 then
	inst <= x"C43C0008";
end if;
if pc = 52 then
	inst <= x"CC7C0010";
end if;
if pc = 56 then
	inst <= x"CCDC0018";
end if;
if pc = 60 then
	inst <= x"CC5C0020";
end if;
if pc = 64 then
	inst <= x"03DC0030";
end if;
if pc = 68 then
	inst <= x"037E000C";
end if;
if pc = 72 then
	inst <= x"C57DFFFC";
end if;
if pc = 76 then
	inst <= x"82000018";
end if;
if pc = 80 then
	inst <= x"07DC0030";
end if;
if pc = 84 then
	inst <= x"C85C0020";
end if;
if pc = 88 then
	inst <= x"48224000";
end if;
if pc = 92 then
	inst <= x"C8DC0018";
end if;
if pc = 96 then
	inst <= x"4042C000";
end if;
if pc = 100 then
	inst <= x"C83C0010";
end if;
if pc = 104 then
	inst <= x"48622000";
end if;
if pc = 108 then
	inst <= x"48844000";
end if;
if pc = 112 then
	inst <= x"C8A00014";
end if;
if pc = 116 then
	inst <= x"40E68000";
end if;
if pc = 120 then
	inst <= x"8EAE008C";
end if;
if pc = 124 then
	inst <= x"C03C0008";
end if;
if pc = 128 then
	inst <= x"06220001";
end if;
if pc = 132 then
	inst <= x"C8BC0000";
end if;
if pc = 136 then
	inst <= x"82000020";
end if;
if pc = 140 then
	inst <= x"02200031";
end if;
if pc = 144 then
	inst <= x"E2200000";
end if;
if pc = 148 then
	inst <= x"C1FDFFFC";
end if;
if pc = 152 then
	inst <= x"02200030";
end if;
if pc = 156 then
	inst <= x"E2200000";
end if;
if pc = 160 then
	inst <= x"C1FDFFFC";
end if;
if pc = 164 then
	inst <= x"02600080";
end if;
if pc = 168 then
	inst <= x"862600B0";
end if;
if pc = 172 then
	inst <= x"C1FDFFFC";
end if;
if pc = 176 then
	inst <= x"58220000";
end if;
if pc = 180 then
	inst <= x"C43C0000";
end if;
if pc = 184 then
	inst <= x"C45C0004";
end if;
if pc = 188 then
	inst <= x"03DC0010";
end if;
if pc = 192 then
	inst <= x"037E000C";
end if;
if pc = 196 then
	inst <= x"C57DFFFC";
end if;
if pc = 200 then
	inst <= x"82000018";
end if;
if pc = 204 then
	inst <= x"07DC0010";
end if;
if pc = 208 then
	inst <= x"C8400010";
end if;
if pc = 212 then
	inst <= x"60640000";
end if;
if pc = 216 then
	inst <= x"48226000";
end if;
if pc = 220 then
	inst <= x"C860000C";
end if;
if pc = 224 then
	inst <= x"44226000";
end if;
if pc = 228 then
	inst <= x"C03C0004";
end if;
if pc = 232 then
	inst <= x"58620000";
end if;
if pc = 236 then
	inst <= x"CC3C0008";
end if;
if pc = 240 then
	inst <= x"CC5C0010";
end if;
if pc = 244 then
	inst <= x"40206000";
end if;
if pc = 248 then
	inst <= x"03DC0020";
end if;
if pc = 252 then
	inst <= x"037E000C";
end if;
if pc = 256 then
	inst <= x"C57DFFFC";
end if;
if pc = 260 then
	inst <= x"82000018";
end if;
if pc = 264 then
	inst <= x"07DC0020";
end if;
if pc = 268 then
	inst <= x"C85C0010";
end if;
if pc = 272 then
	inst <= x"60440000";
end if;
if pc = 276 then
	inst <= x"48224000";
end if;
if pc = 280 then
	inst <= x"C8400008";
end if;
if pc = 284 then
	inst <= x"44C24000";
end if;
if pc = 288 then
	inst <= x"022003E8";
end if;
if pc = 292 then
	inst <= x"40200000";
end if;
if pc = 296 then
	inst <= x"C8BC0008";
end if;
if pc = 300 then
	inst <= x"40802000";
end if;
if pc = 304 then
	inst <= x"40602000";
end if;
if pc = 308 then
	inst <= x"40402000";
end if;
if pc = 312 then
	inst <= x"03DC0020";
end if;
if pc = 316 then
	inst <= x"037E000C";
end if;
if pc = 320 then
	inst <= x"C57DFFFC";
end if;
if pc = 324 then
	inst <= x"82000020";
end if;
if pc = 328 then
	inst <= x"07DC0020";
end if;
if pc = 332 then
	inst <= x"C03C0000";
end if;
if pc = 336 then
	inst <= x"02220001";
end if;
if pc = 340 then
	inst <= x"C05C0004";
end if;
if pc = 344 then
	inst <= x"820000A4";
end if;
if pc = 348 then
	inst <= x"02400080";
end if;
if pc = 352 then
	inst <= x"86240168";
end if;
if pc = 356 then
	inst <= x"C1FDFFFC";
end if;
if pc = 360 then
	inst <= x"02400000";
end if;
if pc = 364 then
	inst <= x"C43C0000";
end if;
if pc = 368 then
	inst <= x"01240000";
end if;
if pc = 372 then
	inst <= x"00420000";
end if;
if pc = 376 then
	inst <= x"00320000";
end if;
if pc = 380 then
	inst <= x"03DC000C";
end if;
if pc = 384 then
	inst <= x"037E000C";
end if;
if pc = 388 then
	inst <= x"C57DFFFC";
end if;
if pc = 392 then
	inst <= x"820000A4";
end if;
if pc = 396 then
	inst <= x"07DC000C";
end if;
if pc = 400 then
	inst <= x"C03C0000";
end if;
if pc = 404 then
	inst <= x"02220001";
end if;
if pc = 408 then
	inst <= x"8200015C";
end if;
if pc = 412 then
	inst <= x"02200000";
end if;
if pc = 416 then
	inst <= x"03DC0008";
end if;
if pc = 420 then
	inst <= x"037E000C";
end if;
if pc = 424 then
	inst <= x"C57DFFFC";
end if;
if pc = 428 then
	inst <= x"8200015C";
end if;
if pc = 432 then
	inst <= x"07DC0008";
end if;
if pc = 436 then
	inst <= x"8001E000";
end if;
if pc > 436 then
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

