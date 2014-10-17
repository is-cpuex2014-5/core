-- alu.vhd
-- Read Oper,in1,in2
-- Send out to core as soon as possible

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity alu is
  Port (
    clk : in std_logic;
    opc_alu : in std_logic_vector(6 downto 0);
    reg_in_a : in std_logic_vector(31 downto 0);
    reg_in_b : in std_logic_vector(31 downto 0);
    reg_out : out std_logic_vector(31 downto 0)
  );
end alu;

architecture alu_main of alu is
begin
  alu_mainprocess: process(clk)
  begin
    if rising_edge(clk) then
      -- Operation add
      if opc_alu = "0000000" then
        reg_out <= reg_in_a + reg_in_b;
      end if;
      if opc_alu = "0000001" then
        reg_out <= reg_in_a + reg_in_b;
      end if;
    end if;
  end process;
end alu_main;

