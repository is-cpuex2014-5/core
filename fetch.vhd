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
        if pc > 9 then
          inst <= x"FFFFFFFF"; -- nop
        end if;
        if pc = 0 then
          --addi s1,s0,0
          inst <= x"02200000";
          --addi s2,s0,2
          --inst <= x"02400002";
        end if;
        if pc = 1 then
          --addi s2,s0,1
          inst <= x"02400001";
          --addi s3,s0,3
          --inst <= x"02600003";
        end if;
        if pc = 2 then
          --addi s3,s0,n
          inst <= x"0260000A";
          --add s2,s2,s3
          --inst <= x"00446000";
        end if;
        if pc = 3 then
          --addi s4,s0,7
          inst <= x"02800007";
          --subi s1,s0,2
          --inst <= x"06200002";
        end if;
        if pc = 4 then
          --beq s3,s0,s4
          inst <= x"80608000";
          --beq s0,s0,s1 (=b)
          --inst <= x"80002000";
        end if;
        if pc = 5 then
          --add s5,s1,s3
          inst <= x"00A24000";
        end if;
        if pc = 6 then
          --add s1,s0,s2
          inst <= x"00204000";
        end if;
        if pc = 7 then
          --add s2,s0,s5
          inst <= x"0040A000";
        end if;
        if pc = 8 then
          --subi s5,s0,6
          inst <= x"06A00006";
        end if;
        if pc = 9 then
          --subi s3,s3,1
          inst <= x"06660001";
        end if;
        if pc = 10 then
          --beq s0,s0,s5
          inst <= x"8000A000";
        end if;
      end if;
    end if;
  end process;
end fetch_test;

