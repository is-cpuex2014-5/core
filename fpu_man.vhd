-- fpu_man.vhd
-- fpu manager

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity fpu_man is
  Port (
    clk : in std_logic;
    opc_fpu : in std_logic_vector(6 downto 0);
    reg_in_a : in std_logic_vector(31 downto 0);
    reg_in_b : in std_logic_vector(31 downto 0);
    reg_out : out std_logic_vector(31 downto 0)
  );
end fpu_man;

architecture fpu_man_main of fpu_man is
begin
  fpu_man_mainprocess: process(clk)
  begin
    if rising_edge(clk) then
      -- Operation add
      reg_out <= reg_in_a + reg_in_b;
    end if;
  end process;
end fpu_man_main;

