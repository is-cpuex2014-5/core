-- comp.vhd
-- Used in Branch operation
-- Read Oper,in1,in2
-- Send out to core as soon as possible

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity compr is
  Port (
    clk : in std_logic;
    opc_compr : in std_logic_vector(6 downto 0);
    reg_in_a : in std_logic_vector(31 downto 0);
    reg_in_b : in std_logic_vector(31 downto 0);
    cond_out : out std_logic
  );
end compr;

architecture compr_main of compr is
begin
  compr_mainprocess: process(clk)
  begin
    if rising_edge(clk) then
      -- Compare eql
      if (opc_compr = "1000000") or (opc_compr = "1000001") then
        if reg_in_a = reg_in_b then
          cond_out <= '1';
        else
          cond_out <= '0';
        end if;
      end if;
      if (opc_compr = "1000010") or (opc_compr = "1000011") then
        if reg_in_a < reg_in_b then
          cond_out <= '1';
        else
          cond_out <= '0';
        end if;
      end if;
    end if;
  end process;
end compr_main;

