library IEEE;
use IEEE.std_logic_1164.all;

entity write_buff is

  generic (buff_size : integer range 0 to 65535 := 255);
  port (
    clk      : in  std_logic;
    data_in  : in  std_logic_vector (7 downto 0);
    go_in    : in  std_logic;
    busy_in  : in  std_logic;
    data_out : out std_logic_vector (7 downto 0);
    go_out   : out std_logic;
    busy_out : out std_logic);

end entity write_buff;

architecture rtl of write_buff is
  type buff_t is array (0 to buff_size) of std_logic_vector (7 downto 0);
  signal buff : buff_t := (others => (others => '0'));

  -- purpose: incr count
  function incr (
    a : integer range 0 to 65535)
    return integer is
  begin  -- function incr
    if a /= buff_size then
      return a + 1;
    else
      return 0;
    end if;
  end function incr;
begin  -- architecture rtl

  write_loop: process (clk) is
    variable write_stop : std_logic := '1';
    variable read_stop : std_logic := '0';
    variable buff_read_side : integer range 0 to 65535 := 0;
    variable buff_write_side  : integer range 0 to 65535 := 0;
    variable just_wrote : std_logic := '0';
  begin  -- process write_loop
    if rising_edge (clk) then
      -- pop queue
      if busy_in = '0' and write_stop = '0' and just_wrote = '0' then
        data_out <= buff (buff_write_side);
        go_out <= '1';
        buff_write_side := incr(buff_write_side);
        read_stop := '0';
        if buff_read_side = buff_write_side then
          write_stop := '1';
        else
          write_stop := '0';
        end if;
        just_wrote := '1';
      else
        just_wrote := '0';
        go_out <= '0';
      end if;
      -- push queue
      if go_in = '1' and read_stop = '0' then
        buff (buff_read_side) <= data_in;
        buff_read_side := incr(buff_read_side);
        write_stop := '0';
        if buff_read_side = buff_write_side then
          read_stop := '1';
        else
          read_stop := '0';
        end if;
      end if;

      busy_out <= read_stop;
    end if;
  end process write_loop;

end architecture rtl;
