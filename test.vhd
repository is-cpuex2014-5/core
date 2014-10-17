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
    ostate: out std_logic_vector(7 downto 0);
    debug_otpt: out std_logic_vector(31 downto 0)
  );
  end component;
  signal simclk : std_logic := '0';
  signal hogge : std_logic_vector(7 downto 0);
  signal debug_otpt : std_logic_vector(31 downto 0);
begin
  core_send: core Port map (
      clk => simclk,
      ostate => hogge,
      debug_otpt => debug_otpt
    );
  clockgen : process
  begin
    simclk <= '0';
    wait for 50 ns;
    simclk <= '1';
    wait for 50 ns;
  end process;
end testbench;

