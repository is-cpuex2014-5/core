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
    execute_ok: in std_logic;
    ostate: out std_logic_vector(7 downto 0);
    sram_go : out std_logic;
    sram_inst_type : out std_logic;
    sram_addr : out std_logic_vector(19 downto 0);
    sram_read : in std_logic_vector(31 downto 0);
    sram_write : out std_logic_vector(31 downto 0);
    debug_otpt: out std_logic_vector(31 downto 0);
    debug_otpt_code: out std_logic_vector(2 downto 0);
    debug_otpt_signal: out std_logic
  );
  end component;
  component sramt Port ( clk : in  STD_LOGIC;
         sram_go : in std_logic;
         sram_inst_type : in std_logic;
         sram_read : out std_logic_vector(31 downto 0);
         sram_write : in std_logic_vector(31 downto 0);
         sram_addr : in std_logic_vector(19 downto 0)
        );
  end component;
  signal simclk : std_logic := '0';
  signal exok : std_logic := '1';
  signal hogge : std_logic_vector(7 downto 0);
  signal sram_inst_type_c : std_logic;
  signal sram_go_c : std_logic;
  signal sram_addr_c : std_logic_vector(19 downto 0);
  signal sram_read_c : std_logic_vector(31 downto 0);
  signal sram_write_c : std_logic_vector(31 downto 0);
  signal sram_inst_type_x : std_logic;
  signal sram_go_x : std_logic;
  signal sram_wait : std_logic_vector(1 downto 0);
  signal sram_addr_x : std_logic_vector(19 downto 0);
  signal sram_read_x : std_logic_vector(31 downto 0);
  signal sram_write_x : std_logic_vector(31 downto 0);
  signal debug_otpt : std_logic_vector(31 downto 0);
  signal debug_otpt_code : std_logic_vector(2 downto 0);
  signal debug_otpt_signal : std_logic;
begin
  core_send: core Port map (
      clk => simclk,
      execute_ok => exok,
      ostate => hogge,
      sram_inst_type => sram_inst_type_c,
      sram_go => sram_go_c,
      sram_addr => sram_addr_c,
      sram_read => sram_read_c,
      sram_write => sram_write_c,
      debug_otpt => debug_otpt,
      debug_otpt_code => debug_otpt_code,
      debug_otpt_signal => debug_otpt_signal
    );
  with_sramt: sramt Port map (
      clk => simclk,
      sram_go => sram_go_x,
      sram_inst_type => sram_inst_type_x,
      sram_addr => sram_addr_x,
      sram_read => sram_read_x,
      sram_write => sram_write_x
    );
  clockgen : process
  begin
    simclk <= '0';
    if sram_go_c = '1' then
      sram_go_x <= '1';
      sram_inst_type_x <= sram_inst_type_c;
      sram_addr_x <= sram_addr_c;
      sram_write_x <= sram_write_c;
      sram_wait <= "11";
    else
      if sram_wait > 0 then
        sram_wait <= sram_wait - 1;
        sram_go_x <= '1';
      else
        sram_read_c <= sram_read_x;
        sram_go_x <= '0';
      end if;
    end if;
    wait for 50 ns;
    simclk <= '1';
    wait for 50 ns;
  end process;
end testbench;

