library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity u232c is
  generic (wtime : std_logic_vector(15 downto 0) := x"1ADB");
  Port (
    clk : in std_logic;
    data_reg : in std_logic_vector(31 downto 0);
    showtype : in std_logic_vector(2 downto 0);
    go : in std_logic;
    busy : out std_logic;
    tx : out std_logic);
end u232c;

architecture blkbx of u232c is
  signal send_buf : std_logic_vector(8 downto 0) := "111111111";
  signal state : std_logic_vector(3 downto 0) := x"B";
  signal countdown : std_logic_vector(15 downto 0) := x"0000";
  signal base_ln : std_logic_vector(7 downto 0) := x"30";
begin
  sttmachine: process(clk)
  begin
    if rising_edge(clk) then
      if state < 14 then
        if countdown = 1 then
          state <= state + 1;
          countdown <= wtime;
          send_buf <= "1" & send_buf(8 downto 1);
        else
          countdown <= countdown - 1;
        end if;
        busy <= '1';
      end if;
      if state = x"E" then
        if countdown = 1 then
          state <= state + 1;
          countdown <= wtime;
          send_buf <= "1" & send_buf(8 downto 1);
          busy <= '0';
        else
          countdown <= countdown - 1;
          busy <= '1';
        end if;
      end if;
      if state = x"F" then
        if go = '1' then
          if showtype = "000" then
            send_buf <=  (base_ln + data_reg(3 downto 0)) & "0";
          end if;
          if showtype = "001" then
            send_buf <=  (base_ln + data_reg(7 downto 4)) & "0";
          end if;
          if showtype = "010" then
            send_buf <=  (data_reg(11 downto 8)+30) & "0";
          end if;
          if showtype = "011" then
            send_buf <=  (data_reg(15 downto 12)+30) & "0";
          end if;
          state <= x"0";
          countdown <= wtime;
          busy <= '1';
        else
          busy <= '0';
        end if;
      end if;
    end if;
  end process;
  tx <= send_buf(0);
end blkbx;
 
