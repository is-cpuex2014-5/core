library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity test is
end test;

architecture testbench of test is
  --testbench signal
  component core Port (
    clk: in std_logic;
    execute_ok: in std_logic;
    ostate: out std_logic_vector(7 downto 0);
    sram_go : out std_logic;
    sram_inst_type : out std_logic;
    sram_addr : out std_logic_vector(19 downto 0);
    sram_read : in std_logic_vector(31 downto 0);
    sram_write : out std_logic_vector(31 downto 0);
    debug_otpt: out std_logic_vector(31 downto 0);
    debug_otpt_code: out std_logic_vector(2 downto 0);
    debug_otpt_signal: out std_logic
  );
  end component;
  signal simclk : std_logic := '0';
  signal exok : std_logic := '1';
  signal hogge : std_logic_vector(7 downto 0);
  signal sram_inst_type : std_logic;
  signal sram_go : std_logic;
  signal sram_addr : std_logic_vector(19 downto 0);
  signal sram_read : std_logic_vector(31 downto 0) := x"01234567";
  signal sram_write : std_logic_vector(31 downto 0);
  signal debug_otpt : std_logic_vector(31 downto 0);
  signal debug_otpt_code : std_logic_vector(2 downto 0);
  signal debug_otpt_signal : std_logic;
begin
  core_send: core Port map (
      clk => simclk,
      execute_ok => exok,
      ostate => hogge,
      sram_inst_type => sram_inst_type,
      sram_go => sram_go,
      sram_read => sram_read,
      sram_write => sram_write,
      debug_otpt => debug_otpt,
      debug_otpt_code => debug_otpt_code,
      debug_otpt_signal => debug_otpt_signal
    );
  clockgen : process
  begin
    simclk <= '0';
    wait for 50 ns;
    hogge(0) <= sram_go;
    simclk <= '1';
    wait for 50 ns;
    hogge(1) <= sram_go;
  end process;
end testbench;

