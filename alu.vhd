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
    reg_out : out std_logic_vector(31 downto 0);
    shift_dir : in std_logic;
    shift_type : in std_logic_vector(1 downto 0);
    shift_go : in std_logic
  );
end alu;

architecture alu_main of alu is
  signal state : std_logic_vector(1 downto 0) := "00";
  signal shift_calc_field : std_logic_vector(95 downto 0);
  signal shift_ret : std_logic_vector(31 downto 0);
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
      -- Operation sub
      if opc_alu = "0000010" then
        reg_out <= reg_in_a - reg_in_b;
      end if;
      if opc_alu = "0000011" then
        reg_out <= reg_in_a - reg_in_b;
      end if;
      -- Operation not
      if opc_alu = "0000100" then
        reg_out <= x"FFFFFFFF" - reg_in_a;
      end if;
      -- Operation and
      if opc_alu = "0000110" then
        reg_out <= (reg_in_a and reg_in_b);
      end if;
      -- Operation or
      if opc_alu = "0001000" then
        reg_out <= (reg_in_a or reg_in_b);
      end if;
      -- Operation xor
      if opc_alu = "0001010" then
        reg_out <= (reg_in_a xor reg_in_b);
      end if;
      -- Operation nand
      if opc_alu = "0001100" then
        reg_out <= x"FFFFFFFF" - (reg_in_a and reg_in_b);
      end if;
      -- Operation nor
      if opc_alu = "0001110" then
        reg_out <= x"FFFFFFFF" - (reg_in_a or reg_in_b);
      end if;
      -- Operation shift
      if (opc_alu = "0010000") or (opc_alu = "0010001") then
        if shift_go = '1' then
          shift_ret <= reg_in_a;
          if shift_type = "00" then
            --Alice
            if reg_in_a(31) = '1' then
              shift_calc_field <= x"FFFFFFFF" & reg_in_a & x"00000000";
            else
              shift_calc_field <= x"00000000" & reg_in_a & x"00000000";
            end if;
          end if;
          if shift_type = "01" then
            --logic
            shift_calc_field <= x"00000000" & reg_in_a & x"00000000";
          end if;
          if shift_type = "11" then
            --rotate
            shift_calc_field <= reg_in_a & reg_in_a & reg_in_a;
          end if;
          state <= "11";
        else
          if state = "11" then
            if reg_in_b(1 downto 0) = "11" then
              if shift_dir = '0' then
                shift_calc_field <= shift_calc_field(92 downto 0) & "000";
              else
                shift_calc_field <= "000" & shift_calc_field(95 downto 3);
              end if;
            end if;
            if reg_in_b(1 downto 0) = "10" then
              if shift_dir = '0' then
                shift_calc_field <= shift_calc_field(93 downto 0) & "00";
              else
                shift_calc_field <= "00" & shift_calc_field(95 downto 2);
              end if;
            end if;
            if reg_in_b(1 downto 0) = "01" then
              if shift_dir = '0' then
                shift_calc_field <= shift_calc_field(94 downto 0) & "0";
              else
                shift_calc_field <= "0" & shift_calc_field(95 downto 1);
              end if;
            end if;
            state <= "10";
          end if;
          if state = "10" then
            if reg_in_b(3 downto 2) = "11" then
              if shift_dir = '0' then
                shift_calc_field <= shift_calc_field(83 downto 0) & x"000";
              else
                shift_calc_field <= x"000" & shift_calc_field(95 downto 12);
              end if;
            end if;
            if reg_in_b(3 downto 2) = "10" then
              if shift_dir = '0' then
                shift_calc_field <= shift_calc_field(87 downto 0) & x"00";
              else
                shift_calc_field <= x"00" & shift_calc_field(95 downto 8);
              end if;
            end if;
            if reg_in_b(3 downto 2) = "01" then
              if shift_dir = '0' then
                shift_calc_field <= shift_calc_field(91 downto 0) & x"0";
              else
                shift_calc_field <= x"0" & shift_calc_field(95 downto 4);
              end if;
            end if;
            state <= "01";
          end if;
          if state = "01" then
            if reg_in_b(4) = '1' then
              if shift_dir = '0' then
                shift_calc_field <= shift_calc_field(79 downto 0) & x"0000";
              else
                shift_calc_field <= x"0000" & shift_calc_field(95 downto 16);
              end if;
            end if;
            state <= "00";
          end if;
          if state = "00" then
            reg_out <= shift_calc_field(63 downto 32);
          end if;
        end if;
      end if;
    end if;
  end process;
end alu_main;

