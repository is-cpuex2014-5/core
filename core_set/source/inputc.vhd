-- 0E03:  6+     +28*256=7174
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
  signal next_write_addr : std_logic_vector(19 downto 0) := x"00000";
  signal readbufcount : std_logic_vector(2 downto 0) := "000";
  signal readbufvalue : std_logic_vector(31 downto 0) := x"00000000";
  signal input_type : std_logic := '0';
  signal data_write_space : std_logic_vector(1 downto 0) := "00";
  signal write_log : std_logic_vector(31 downto 0) := x"00000000";
  signal startbit_log : std_logic_vector(19 downto 0) := x"FFFFF";
  signal one_chan : std_logic_vector(7 downto 0) := x"14"; -- 20
  signal noisecheck_counter : std_logic_vector(7 downto 0) := x"00";
  signal noisecheck_sum : std_logic_vector(3 downto 0) := x"0";
begin
  sttmachine: process(clk)
  begin
    if rising_edge(clk) then
      if state = 10 then
        if noisecheck_counter = 30 then
          if rx = '0' then
            if startbit_log(19) = '1' then
              if one_chan < 4 then
                state <= x"0";
                countdown <= x"0E03" - 270;
                readbuf <= x"00";
                one_chan <= x"14"; -- 20
                startbit_log <= x"FFFFF";
              else
                one_chan <= one_chan - 1;
                startbit_log <= startbit_log(18 downto 0) & "0";
              end if;
            end if;
          else
            if startbit_log(19) = '0' then
              one_chan <= one_chan + 1;
            end if;
            startbit_log <= startbit_log(18 downto 0) & "1";
          end if;
          noisecheck_counter <= x"00";
        else
          noisecheck_counter <= noisecheck_counter + 1;
        end if;
      end if;
      if (state > 0) and (state < 9) then
        if readcount = 600 then
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
          countdown <= x"0E03";
          readcount <= x"0000";
          readzero <= "000";
          readone <= "000";
          write_ok <= '0';
        else
          if (state = 9) and (countdown = 750) then
            --skip and end of read char
            countdown <= x"0000";
            state <= state + 1;
            --execute_ok <= '1';
            if readbuf = x"58" then
              if input_type = '1' then
                execute_ok <= '1';
              else
                input_type <= '1';
                next_write_addr <= x"55554";
                readbufcount <= "000";
              end if;
            --  write_ok <= '0';
            else
              if input_type = '1' then
                if readbufcount = 0 then
                  if readbuf < 58 then
                    readbufvalue <= ((x"000000" & readbuf) - 48);
                  else
                    readbufvalue <= ((x"000000" & readbuf) - 55);
                  end if;
                  readbufcount <= "001";
                end if;
                if readbufcount = 1 then
                  if data_write_space = 0 then
                    if readbuf < 58 then
                      write_value <= write_log + ((readbufvalue(27 downto 0) & x"0") + ((x"000000" & readbuf) - 48));
                      write_log <= write_log + ((readbufvalue(27 downto 0) & x"0") + ((x"000000" & readbuf) - 48));
                    else
                      write_value <= write_log + ((readbufvalue(27 downto 0) & x"0") + ((x"000000" & readbuf) - 55));
                      write_log <= write_log + ((readbufvalue(27 downto 0) & x"0") + ((x"000000" & readbuf) - 55));
                    end if;
                  end if;
                  if data_write_space = 1 then
                    if readbuf < 58 then
                      write_value <= write_log + (((readbufvalue(19 downto 0) & x"0") + ((x"0000" & readbuf) - 48)) & x"00");
                      write_log <= write_log + (((readbufvalue(19 downto 0) & x"0") + ((x"0000" & readbuf) - 48)) & x"00");
                    else
                      write_value <= write_log + (((readbufvalue(19 downto 0) & x"0") + ((x"0000" & readbuf) - 55)) & x"00");
                      write_log <= write_log + (((readbufvalue(19 downto 0) & x"0") + ((x"0000" & readbuf) - 55)) & x"00");
                    end if;
                  end if;
                  if data_write_space = 2 then
                    if readbuf < 58 then
                      write_value <= write_log + (((readbufvalue(11 downto 0) & x"0") + ((x"00" & readbuf) - 48)) & x"0000");
                      write_log <= write_log + (((readbufvalue(11 downto 0) & x"0") + ((x"00" & readbuf) - 48)) & x"0000");
                    else
                      write_value <= write_log + (((readbufvalue(11 downto 0) & x"0") + ((x"00" & readbuf) - 55)) & x"0000");
                      write_log <= write_log + (((readbufvalue(11 downto 0) & x"0") + ((x"00" & readbuf) - 55)) & x"0000");
                    end if;
                  end if;
                  if data_write_space = 3 then
                    if readbuf < 58 then
                      write_value <= write_log + (((readbufvalue(3 downto 0) & x"0") + (readbuf - 48)) & x"000000");
                      write_log <= x"00000000";
                    else
                      write_value <= write_log + (((readbufvalue(3 downto 0) & x"0") + (readbuf - 55)) & x"000000");
                      write_log <= x"00000000";
                    end if;
                  end if;
                  readbufcount <= "000";
                  write_addr <= next_write_addr;
                  write_ok <= '1';
                  if data_write_space = 3 then
                    next_write_addr <= next_write_addr - 1;
                  end if;
                  data_write_space <= data_write_space + 1;
                end if;
              else
                if readbufcount = 0 then
                  if readbuf < 58 then
                    readbufvalue <= ((x"000000" & readbuf) - 48);
                  else
                    readbufvalue <= ((x"000000" & readbuf) - 55);
                  end if;
                  readbufcount <= "001";
                end if;
                if (readbufcount > 0) and (readbufcount< 7) then
                  if readbuf < 58 then
                    readbufvalue <= (readbufvalue(27 downto 0) & x"0") + ((x"000000" & readbuf) - 48);
                  else
                    readbufvalue <= (readbufvalue(27 downto 0) & x"0") + ((x"000000" & readbuf) - 55);
                  end if;
                  readbufcount <= readbufcount + 1;
                end if;
                if readbufcount = 7 then
                  if readbuf < 58 then
                    write_value <= (readbufvalue(27 downto 0) & x"0") + ((x"000000" & readbuf) - 48);
                  else
                    write_value <= (readbufvalue(27 downto 0) & x"0") + ((x"000000" & readbuf) - 55);
                  end if;
                  readbufcount <= "000";
                  write_addr <= next_write_addr;
                  write_ok <= '1';
                  next_write_addr <= next_write_addr + 1;
                end if;
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
 
