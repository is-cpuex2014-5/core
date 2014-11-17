-- 1C06:  6+     +28*256=7174
-- 1ADB: 11+13*16+26*256=6875
-- read data
-- execute command "X"

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity inputc is
  Port (
    clk : in std_logic;
    execute_ok : out std_logic := '0';
    debug_read : out std_logic_vector(7 downto 0);
    write_value : out std_logic_vector(31 downto 0);
    write_addr : out std_logic_vector(19 downto 0);
    write_ok : out std_logic := '0';
    rx : in std_logic);
end inputc;

architecture blkbx of inputc is
  signal send_buf : std_logic_vector(8 downto 0) := "111111111";
  signal state : std_logic_vector(3 downto 0) := x"A";
  signal countdown : std_logic_vector(15 downto 0) := x"0000";
  signal readbuf : std_logic_vector(7 downto 0) := x"00";
  signal readcount : std_logic_vector(15 downto 0) := x"0000";
  signal readzero : std_logic_vector(2 downto 0) := "000";
  signal readone : std_logic_vector(2 downto 0) := "000";
  signal base_ln : std_logic_vector(7 downto 0) := x"30";
  signal readbufforreg : std_logic_vector(31 downto 0) := x"00000000";
  signal readsum : std_logic_vector(2 downto 0) := "000";
  signal next_write_addr : std_logic_vector(19 downto 0) := x"00000";
begin
  sttmachine: process(clk)
  begin
    if rising_edge(clk) then
      if state = 10 then
        if rx = '0' then
          countdown <= x"1C05";
          state <= x"0";
          readbuf <= x"00";
        end if;
      end if;
      if (state > 0) and (state < 9) then
        if readcount = 1200 then
          readcount <= x"0000";
          if rx = '0' then
            readzero <= readzero + 1;
          else
            readone <= readone + 1;
          end if;
        else
          if countdown > 0 then
            readcount <= readcount + 1;
          end if;
        end if;
        if countdown = 1 then
          -- decide which bit has read
          if readzero > readone then
            readbuf <= "0" & readbuf(7 downto 1);
          else
            readbuf <= "1" & readbuf(7 downto 1);
          end if;
        end if;
      end if;
      if state < 10 then
        if countdown = 0 then
          -- move to next state
          state <= state + 1;
          countdown <= x"1C06";
          readcount <= x"0000";
          readzero <= "000";
          readone <= "000";
          write_ok <= '0';
        else
          if (state = 9) and (countdown = 150) then
            --skip and end of read char
            countdown <= x"0000";
            state <= state + 1;
            --execute_ok <= '1';
            if readbuf = x"58" then
              execute_ok <= '1';
              write_ok <= '0';
            else
              if readsum < 7 then
                if readbuf>64 then
                  readbufforreg <= (readbufforreg(27 downto 0) & "0000") + (readbuf-55);
                else
                  readbufforreg <= (readbufforreg(27 downto 0) & "0000") + (readbuf-48);
                end if;
                readsum <= readsum + 1;
                write_ok <= '0';
              else
                if readbuf>64 then
                  write_value <= (readbufforreg(27 downto 0) & "0000") + (readbuf-55);
                else
                  write_value <= (readbufforreg(27 downto 0) & "0000") + (readbuf-48);
                end if;
                write_addr <= next_write_addr;
                write_ok <= '1';
                next_write_addr <= next_write_addr + 1;
                readsum <= "000";
                readbufforreg <= x"00000000";
              end if;
            end if;
            debug_read <= readbuf;
          else
            write_ok <= '0';
            countdown <= countdown - 1;
          end if;
        end if;
      else
        write_ok <= '0';
      end if;
    end if;
  end process;
end blkbx;
 
