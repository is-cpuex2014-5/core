library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM;
use UNISIM.VComponents.all;

-- CPUEV2(HW09) より
entity top is
  Port ( MCLK1 : in  STD_LOGIC;
         RS_TX : out  STD_LOGIC;
         XGA : out STD_LOGIC;
         XE1 : out STD_LOGIC;
         E2A : out STD_LOGIC;
         XE3 : out STD_LOGIC;
         XZCKE : out STD_LOGIC;
         ADVA : out STD_LOGIC;
         XLBO : out STD_LOGIC;
         ZZA : out STD_LOGIC;
         XFT : out STD_LOGIC;
         ZCLKMA : out STD_LOGIC_VECTOR (1 downto 0);
         ZD : inout STD_LOGIC_VECTOR (31 downto 0);
         ZDP : inout STD_LOGIC_VECTOR (3 downto 0);
         ZA : inout STD_LOGIC_VECTOR (19 downto 0);
         IOA : STD_LOGIC_VECTOR (126 downto 0);
         XZBE : inout STD_LOGIC_VECTOR (3 downto 0);
         XWA : out STD_LOGIC;
         XRST : in STD_LOGIC;
         RS_RX : in STD_LOGIC
        );
end top;

architecture cpu_top of top is
  signal clk,iclk : std_logic;
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
    debug_otpt_signal: out std_logic;
    waitwrite_from_parent : in std_logic_vector(19 downto 0)
  );
  end component;
  component sram Port (
    clk: in std_logic;
    SRXGA : out STD_LOGIC;
    SRXE1 : out STD_LOGIC;
    SRE2A : out STD_LOGIC;
    SRXE3 : out STD_LOGIC;
    SRXZCKE : out STD_LOGIC;
    SRADVA : out STD_LOGIC;
    SRXLBO : out STD_LOGIC;
    SRZZA : out STD_LOGIC;
    SRXFT : out STD_LOGIC;
    SRZCLKMA : out STD_LOGIC_VECTOR (1 downto 0);
    SRZD : inout STD_LOGIC_VECTOR (31 downto 0);
    SRZDP : inout STD_LOGIC_VECTOR (3 downto 0);
    SRZA : inout STD_LOGIC_VECTOR (19 downto 0);
    SRIOA : STD_LOGIC_VECTOR (126 downto 0);
    SRXZBE : inout STD_LOGIC_VECTOR (3 downto 0);
    SRXWA : out STD_LOGIC;
    SRXRST : in STD_LOGIC;
    sram_go : in std_logic;
    sram_busy : out std_logic;
    sram_inst_type : in std_logic;
    sram_read : out std_logic_vector(31 downto 0);
    sram_write : in std_logic_vector(31 downto 0);
    sram_addr : in std_logic_vector(19 downto 0)
  );
  end component;
  component u232c
    generic (wtime: std_logic_vector(15 downto 0) := x"1ADB");
    Port (
      clk : in std_logic;
      data_reg : in std_logic_vector(31 downto 0);
      showtype : in std_logic_vector(2 downto 0);
      go : in std_logic;
      busy : out std_logic;
      tx : out std_logic
    );
  end component;
  component inputc
    Port (
      clk : in std_logic;
      execute_ok : out std_logic;
      debug_read : out std_logic_vector(7 downto 0);
      write_value : out std_logic_vector(31 downto 0);
      write_addr : out std_logic_vector(19 downto 0);
      write_ok : out std_logic;
      rx : in std_logic
    );
  end component;
  signal exok : std_logic := '0';
  signal exok_from_read : std_logic;
  signal top_state : std_logic_vector(2 downto 0) := "000";
  signal hogge : std_logic_vector(7 downto 0);
  signal debug_otpt : std_logic_vector(31 downto 0);
  signal debug_otpt_code : std_logic_vector(2 downto 0);
  signal debug_otpt_signal : std_logic;
  signal debug_otpt_inputc : std_logic_vector(7 downto 0);
  signal u232c_data_reg : std_logic_vector(31 downto 0);
  signal u232c_showtype : std_logic_vector(2 downto 0);
  signal u232c_go : std_logic;
  signal u232c_busy : std_logic;
  signal inputc_write_value : std_logic_vector(31 downto 0);
  signal inputc_write_addr : std_logic_vector(19 downto 0);
  signal inputc_write_ok : std_logic;
  signal core_sram_go : std_logic;
  signal core_sram_inst_type : std_logic; --0: read 1: write
  signal core_sram_read : std_logic_vector(31 downto 0);
  signal core_sram_write : std_logic_vector(31 downto 0);
  signal core_sram_addr : std_logic_vector(19 downto 0);
  signal sram_go : std_logic;
  signal sram_busy : std_logic;
  signal sram_inst_type : std_logic; --0: read 1: write
  signal sram_read : std_logic_vector(31 downto 0);
  signal sram_write : std_logic_vector(31 downto 0);
  signal sram_addr : std_logic_vector(19 downto 0);
  signal sigcount : std_logic_vector(3 downto 0) := x"0";
  signal debug_saved_value : std_logic_vector(31 downto 0);
  signal first_state_sram_input_id : std_logic_vector(19 downto 0) := x"00000";
  signal first_state_write_wait : std_logic_vector(7 downto 0) := x"00";
  signal waitwrite_to_core : std_logic_vector(19 downto 0) := x"00000";
  -- wait one clock to wait u232c's busy
  signal debug_waitoneclock : std_logic := '0';
begin
  -- HW 実験当時の top より
  ib: IBUFG port map (
    i => MCLK1,
    o => iclk
    );
  bg: BUFG port map (
    i => iclk,
    o => clk
    );
  rs232c : u232c generic map (wtime => x"1ADB")
  Port map (
    clk => clk,
    data_reg => u232c_data_reg,
    showtype => u232c_showtype,
    go => u232c_go,
    busy => u232c_busy,
    tx => rs_tx
    );
  with_inputc : inputc Port map (
    clk => clk,
    execute_ok => exok_from_read,
    debug_read => debug_otpt_inputc,
    write_value => inputc_write_value,
    write_addr => inputc_write_addr,
    write_ok => inputc_write_ok,
    rx => rs_rx
    );
  core_send: core Port map (
    clk => clk,
    execute_ok => exok,
    ostate => hogge,
    sram_go => core_sram_go,
    sram_inst_type => core_sram_inst_type,
    sram_read => core_sram_read,
    sram_write => core_sram_write,
    sram_addr => core_sram_addr,
    debug_otpt => debug_otpt,
    debug_otpt_code => debug_otpt_code,
    debug_otpt_signal => debug_otpt_signal,
    waitwrite_from_parent => waitwrite_to_core
    );
  withsram: sram Port map (
    clk => clk,
    SRXGA => XGA,
    SRXE1 => XE1,
    SRE2A => E2A,
    SRXE3 => XE3,
    SRXZCKE => XZCKE,
    SRADVA => ADVA,
    SRXLBO => XLBO,
    SRZZA => ZZA,
    SRXFT => XFT,
    SRZCLKMA => ZCLKMA,
    SRZD => ZD,
    SRZDP => ZDP,
    SRZA => ZA,
    SRIOA => IOA,
    SRXZBE => XZBE,
    SRXWA => XWA,
    SRXRST => XRST,
    sram_go => sram_go,
    sram_busy => sram_busy,
    sram_inst_type => sram_inst_type,
    sram_read => sram_read,
    sram_write => sram_write,
    sram_addr => sram_addr
    );
  cpu_top_main : process
  begin
    if rising_edge(clk) then
      if u232c_busy = '0' then
        waitwrite_to_core <= x"00000";
      else
        waitwrite_to_core <= x"C0C0A";
      end if;
      if top_state = "000" then
        -- write inst phase
        if (first_state_write_wait = 0) then
        -- write in addr
          if (first_state_sram_input_id<326) then
            if sram_busy = '0' then
              sram_go <= '1';
              sram_inst_type <= '1';
              first_state_write_wait <= x"FF";
              sram_addr <= first_state_sram_input_id;
if first_state_sram_input_id = 0 then
	sram_write <= x"8200019C";
end if;
if first_state_sram_input_id = 1 then
	sram_write <= x"00000000";
end if;
if first_state_sram_input_id = 2 then
	sram_write <= x"3F800000";
end if;
if first_state_sram_input_id = 3 then
	sram_write <= x"3FC00000";
end if;
if first_state_sram_input_id = 4 then
	sram_write <= x"43000000";
end if;
if first_state_sram_input_id = 5 then
	sram_write <= x"40800000";
end if;
if first_state_sram_input_id = 6 then
	sram_write <= x"40222000";
end if;
if first_state_sram_input_id = 7 then
	sram_write <= x"C1FDFFFC";
end if;
if first_state_sram_input_id = 8 then
	sram_write <= x"C1FC0000";
end if;
if first_state_sram_input_id = 9 then
	sram_write <= x"E2200000";
end if;
if first_state_sram_input_id = 10 then
	sram_write <= x"07DC0004";
end if;
if first_state_sram_input_id = 11 then
	sram_write <= x"C1FC0000";
end if;
if first_state_sram_input_id = 12 then
	sram_write <= x"E0200000";
end if;
if first_state_sram_input_id = 13 then
	sram_write <= x"E0400000";
end if;
if first_state_sram_input_id = 14 then
	sram_write <= x"E0600000";
end if;
if first_state_sram_input_id = 15 then
	sram_write <= x"E0800000";
end if;
if first_state_sram_input_id = 16 then
	sram_write <= x"22221820";
end if;
if first_state_sram_input_id = 17 then
	sram_write <= x"22441020";
end if;
if first_state_sram_input_id = 18 then
	sram_write <= x"22660820";
end if;
if first_state_sram_input_id = 19 then
	sram_write <= x"00224000";
end if;
if first_state_sram_input_id = 20 then
	sram_write <= x"00226000";
end if;
if first_state_sram_input_id = 21 then
	sram_write <= x"00228000";
end if;
if first_state_sram_input_id = 22 then
	sram_write <= x"07DC0004";
end if;
if first_state_sram_input_id = 23 then
	sram_write <= x"C1FC0000";
end if;
if first_state_sram_input_id = 24 then
	sram_write <= x"E0200000";
end if;
if first_state_sram_input_id = 25 then
	sram_write <= x"E0400000";
end if;
if first_state_sram_input_id = 26 then
	sram_write <= x"E0600000";
end if;
if first_state_sram_input_id = 27 then
	sram_write <= x"E0800000";
end if;
if first_state_sram_input_id = 28 then
	sram_write <= x"22221820";
end if;
if first_state_sram_input_id = 29 then
	sram_write <= x"22441020";
end if;
if first_state_sram_input_id = 30 then
	sram_write <= x"22660820";
end if;
if first_state_sram_input_id = 31 then
	sram_write <= x"00224000";
end if;
if first_state_sram_input_id = 32 then
	sram_write <= x"00226000";
end if;
if first_state_sram_input_id = 33 then
	sram_write <= x"00228000";
end if;
if first_state_sram_input_id = 34 then
	sram_write <= x"C43C0004";
end if;
if first_state_sram_input_id = 35 then
	sram_write <= x"C83C0004";
end if;
if first_state_sram_input_id = 36 then
	sram_write <= x"07DC0004";
end if;
if first_state_sram_input_id = 37 then
	sram_write <= x"C1FC0000";
end if;
if first_state_sram_input_id = 38 then
	sram_write <= x"CC3C0004";
end if;
if first_state_sram_input_id = 39 then
	sram_write <= x"C03C0004";
end if;
if first_state_sram_input_id = 40 then
	sram_write <= x"228218A0";
end if;
if first_state_sram_input_id = 41 then
	sram_write <= x"226210A0";
end if;
if first_state_sram_input_id = 42 then
	sram_write <= x"224208A0";
end if;
if first_state_sram_input_id = 43 then
	sram_write <= x"E2800000";
end if;
if first_state_sram_input_id = 44 then
	sram_write <= x"E2600000";
end if;
if first_state_sram_input_id = 45 then
	sram_write <= x"E2400000";
end if;
if first_state_sram_input_id = 46 then
	sram_write <= x"E2200000";
end if;
if first_state_sram_input_id = 47 then
	sram_write <= x"07DC0004";
end if;
if first_state_sram_input_id = 48 then
	sram_write <= x"C1FC0000";
end if;
if first_state_sram_input_id = 49 then
	sram_write <= x"007A0000";
end if;
if first_state_sram_input_id = 50 then
	sram_write <= x"822000DC";
end if;
if first_state_sram_input_id = 51 then
	sram_write <= x"C45A0000";
end if;
if first_state_sram_input_id = 52 then
	sram_write <= x"06220001";
end if;
if first_state_sram_input_id = 53 then
	sram_write <= x"03BA0004";
end if;
if first_state_sram_input_id = 54 then
	sram_write <= x"820000C8";
end if;
if first_state_sram_input_id = 55 then
	sram_write <= x"00260000";
end if;
if first_state_sram_input_id = 56 then
	sram_write <= x"07DC0004";
end if;
if first_state_sram_input_id = 57 then
	sram_write <= x"C1FC0000";
end if;
if first_state_sram_input_id = 58 then
	sram_write <= x"5F375A86";
end if;
if first_state_sram_input_id = 59 then
	sram_write <= x"3F000000";
end if;
if first_state_sram_input_id = 60 then
	sram_write <= x"3FC00000";
end if;
if first_state_sram_input_id = 61 then
	sram_write <= x"C86000E8";
end if;
if first_state_sram_input_id = 62 then
	sram_write <= x"C88000EC";
end if;
if first_state_sram_input_id = 63 then
	sram_write <= x"C8A000F0";
end if;
if first_state_sram_input_id = 64 then
	sram_write <= x"CC3C0004";
end if;
if first_state_sram_input_id = 65 then
	sram_write <= x"C05C0004";
end if;
if first_state_sram_input_id = 66 then
	sram_write <= x"C06000E8";
end if;
if first_state_sram_input_id = 67 then
	sram_write <= x"224401A0";
end if;
if first_state_sram_input_id = 68 then
	sram_write <= x"04464000";
end if;
if first_state_sram_input_id = 69 then
	sram_write <= x"C45C0004";
end if;
if first_state_sram_input_id = 70 then
	sram_write <= x"C85C0004";
end if;
if first_state_sram_input_id = 71 then
	sram_write <= x"48828000";
end if;
if first_state_sram_input_id = 72 then
	sram_write <= x"48648000";
end if;
if first_state_sram_input_id = 73 then
	sram_write <= x"48646000";
end if;
if first_state_sram_input_id = 74 then
	sram_write <= x"446A6000";
end if;
if first_state_sram_input_id = 75 then
	sram_write <= x"48446000";
end if;
if first_state_sram_input_id = 76 then
	sram_write <= x"48648000";
end if;
if first_state_sram_input_id = 77 then
	sram_write <= x"48646000";
end if;
if first_state_sram_input_id = 78 then
	sram_write <= x"446A6000";
end if;
if first_state_sram_input_id = 79 then
	sram_write <= x"48446000";
end if;
if first_state_sram_input_id = 80 then
	sram_write <= x"48648000";
end if;
if first_state_sram_input_id = 81 then
	sram_write <= x"48646000";
end if;
if first_state_sram_input_id = 82 then
	sram_write <= x"446A6000";
end if;
if first_state_sram_input_id = 83 then
	sram_write <= x"48446000";
end if;
if first_state_sram_input_id = 84 then
	sram_write <= x"48224000";
end if;
if first_state_sram_input_id = 85 then
	sram_write <= x"07DC0004";
end if;
if first_state_sram_input_id = 86 then
	sram_write <= x"C1FC0000";
end if;
if first_state_sram_input_id = 87 then
	sram_write <= x"3F000000";
end if;
if first_state_sram_input_id = 88 then
	sram_write <= x"40000000";
end if;
if first_state_sram_input_id = 89 then
	sram_write <= x"BFF0F0F1";
end if;
if first_state_sram_input_id = 90 then
	sram_write <= x"4034B4B5";
end if;
if first_state_sram_input_id = 91 then
	sram_write <= x"CC3C0004";
end if;
if first_state_sram_input_id = 92 then
	sram_write <= x"C03C0004";
end if;
if first_state_sram_input_id = 93 then
	sram_write <= x"224217A0";
end if;
if first_state_sram_input_id = 94 then
	sram_write <= x"04404000";
end if;
if first_state_sram_input_id = 95 then
	sram_write <= x"024400FD";
end if;
if first_state_sram_input_id = 96 then
	sram_write <= x"22441720";
end if;
if first_state_sram_input_id = 97 then
	sram_write <= x"C45C0008";
end if;
if first_state_sram_input_id = 98 then
	sram_write <= x"C85C0008";
end if;
if first_state_sram_input_id = 99 then
	sram_write <= x"C060015C";
end if;
if first_state_sram_input_id = 100 then
	sram_write <= x"22220920";
end if;
if first_state_sram_input_id = 101 then
	sram_write <= x"222209A0";
end if;
if first_state_sram_input_id = 102 then
	sram_write <= x"00226000";
end if;
if first_state_sram_input_id = 103 then
	sram_write <= x"C43C0004";
end if;
if first_state_sram_input_id = 104 then
	sram_write <= x"C83C0004";
end if;
if first_state_sram_input_id = 105 then
	sram_write <= x"C8600164";
end if;
if first_state_sram_input_id = 106 then
	sram_write <= x"C8800168";
end if;
if first_state_sram_input_id = 107 then
	sram_write <= x"48626000";
end if;
if first_state_sram_input_id = 108 then
	sram_write <= x"40668000";
end if;
if first_state_sram_input_id = 109 then
	sram_write <= x"C8A00160";
end if;
if first_state_sram_input_id = 110 then
	sram_write <= x"48826000";
end if;
if first_state_sram_input_id = 111 then
	sram_write <= x"448A8000";
end if;
if first_state_sram_input_id = 112 then
	sram_write <= x"48668000";
end if;
if first_state_sram_input_id = 113 then
	sram_write <= x"48826000";
end if;
if first_state_sram_input_id = 114 then
	sram_write <= x"448A8000";
end if;
if first_state_sram_input_id = 115 then
	sram_write <= x"48668000";
end if;
if first_state_sram_input_id = 116 then
	sram_write <= x"48826000";
end if;
if first_state_sram_input_id = 117 then
	sram_write <= x"448A8000";
end if;
if first_state_sram_input_id = 118 then
	sram_write <= x"48668000";
end if;
if first_state_sram_input_id = 119 then
	sram_write <= x"48246000";
end if;
if first_state_sram_input_id = 120 then
	sram_write <= x"07DC0004";
end if;
if first_state_sram_input_id = 121 then
	sram_write <= x"C1FC0000";
end if;
if first_state_sram_input_id = 122 then
	sram_write <= x"BF800000";
end if;
if first_state_sram_input_id = 123 then
	sram_write <= x"CC3C0000";
end if;
if first_state_sram_input_id = 124 then
	sram_write <= x"C03C0000";
end if;
if first_state_sram_input_id = 125 then
	sram_write <= x"22420120";
end if;
if first_state_sram_input_id = 126 then
	sram_write <= x"224418A0";
end if;
if first_state_sram_input_id = 127 then
	sram_write <= x"02600096";
end if;
if first_state_sram_input_id = 128 then
	sram_write <= x"8664027C";
end if;
if first_state_sram_input_id = 129 then
	sram_write <= x"8264027C";
end if;
if first_state_sram_input_id = 130 then
	sram_write <= x"0260007E";
end if;
if first_state_sram_input_id = 131 then
	sram_write <= x"86460230";
end if;
if first_state_sram_input_id = 132 then
	sram_write <= x"82460230";
end if;
if first_state_sram_input_id = 133 then
	sram_write <= x"02800096";
end if;
if first_state_sram_input_id = 134 then
	sram_write <= x"04884000";
end if;
if first_state_sram_input_id = 135 then
	sram_write <= x"206280A0";
end if;
if first_state_sram_input_id = 136 then
	sram_write <= x"04404000";
end if;
if first_state_sram_input_id = 137 then
	sram_write <= x"02840096";
end if;
if first_state_sram_input_id = 138 then
	sram_write <= x"20668020";
end if;
if first_state_sram_input_id = 139 then
	sram_write <= x"82000234";
end if;
if first_state_sram_input_id = 140 then
	sram_write <= x"02600000";
end if;
if first_state_sram_input_id = 141 then
	sram_write <= x"C45C0004";
end if;
if first_state_sram_input_id = 142 then
	sram_write <= x"C47C0008";
end if;
if first_state_sram_input_id = 143 then
	sram_write <= x"C85C0004";
end if;
if first_state_sram_input_id = 144 then
	sram_write <= x"C87C0008";
end if;
if first_state_sram_input_id = 145 then
	sram_write <= x"44404000";
end if;
if first_state_sram_input_id = 146 then
	sram_write <= x"CC5C0004";
end if;
if first_state_sram_input_id = 147 then
	sram_write <= x"C05C0000";
end if;
if first_state_sram_input_id = 148 then
	sram_write <= x"86460278";
end if;
if first_state_sram_input_id = 149 then
	sram_write <= x"82460278";
end if;
if first_state_sram_input_id = 150 then
	sram_write <= x"8E600268";
end if;
if first_state_sram_input_id = 151 then
	sram_write <= x"40206000";
end if;
if first_state_sram_input_id = 152 then
	sram_write <= x"07DC0004";
end if;
if first_state_sram_input_id = 153 then
	sram_write <= x"C1FC0000";
end if;
if first_state_sram_input_id = 154 then
	sram_write <= x"C84001E8";
end if;
if first_state_sram_input_id = 155 then
	sram_write <= x"40264000";
end if;
if first_state_sram_input_id = 156 then
	sram_write <= x"07DC0004";
end if;
if first_state_sram_input_id = 157 then
	sram_write <= x"C1FC0000";
end if;
if first_state_sram_input_id = 158 then
	sram_write <= x"40206000";
end if;
if first_state_sram_input_id = 159 then
	sram_write <= x"07DC0004";
end if;
if first_state_sram_input_id = 160 then
	sram_write <= x"C1FC0000";
end if;
if first_state_sram_input_id = 161 then
	sram_write <= x"40222000";
end if;
if first_state_sram_input_id = 162 then
	sram_write <= x"07DC0004";
end if;
if first_state_sram_input_id = 163 then
	sram_write <= x"C1FC0000";
end if;
if first_state_sram_input_id = 164 then
	sram_write <= x"03600000";
end if;
if first_state_sram_input_id = 165 then
	sram_write <= x"82360320";
end if;
if first_state_sram_input_id = 166 then
	sram_write <= x"44668000";
end if;
if first_state_sram_input_id = 167 then
	sram_write <= x"4066A000";
end if;
if first_state_sram_input_id = 168 then
	sram_write <= x"CCBC0000";
end if;
if first_state_sram_input_id = 169 then
	sram_write <= x"C43C0008";
end if;
if first_state_sram_input_id = 170 then
	sram_write <= x"CC7C0010";
end if;
if first_state_sram_input_id = 171 then
	sram_write <= x"CCDC0018";
end if;
if first_state_sram_input_id = 172 then
	sram_write <= x"CC5C0020";
end if;
if first_state_sram_input_id = 173 then
	sram_write <= x"C17DFFFC";
end if;
if first_state_sram_input_id = 174 then
	sram_write <= x"C57C002C";
end if;
if first_state_sram_input_id = 175 then
	sram_write <= x"03DC0030";
end if;
if first_state_sram_input_id = 176 then
	sram_write <= x"037E0010";
end if;
if first_state_sram_input_id = 177 then
	sram_write <= x"C57C0000";
end if;
if first_state_sram_input_id = 178 then
	sram_write <= x"03DC0004";
end if;
if first_state_sram_input_id = 179 then
	sram_write <= x"82000284";
end if;
if first_state_sram_input_id = 180 then
	sram_write <= x"07DC0030";
end if;
if first_state_sram_input_id = 181 then
	sram_write <= x"C17C002C";
end if;
if first_state_sram_input_id = 182 then
	sram_write <= x"C57DFFFC";
end if;
if first_state_sram_input_id = 183 then
	sram_write <= x"C85C0020";
end if;
if first_state_sram_input_id = 184 then
	sram_write <= x"48224000";
end if;
if first_state_sram_input_id = 185 then
	sram_write <= x"C8DC0018";
end if;
if first_state_sram_input_id = 186 then
	sram_write <= x"4042C000";
end if;
if first_state_sram_input_id = 187 then
	sram_write <= x"C83C0010";
end if;
if first_state_sram_input_id = 188 then
	sram_write <= x"48622000";
end if;
if first_state_sram_input_id = 189 then
	sram_write <= x"48844000";
end if;
if first_state_sram_input_id = 190 then
	sram_write <= x"03600014";
end if;
if first_state_sram_input_id = 191 then
	sram_write <= x"C8B60000";
end if;
if first_state_sram_input_id = 192 then
	sram_write <= x"40E68000";
end if;
if first_state_sram_input_id = 193 then
	sram_write <= x"8EAE0318";
end if;
if first_state_sram_input_id = 194 then
	sram_write <= x"C03C0008";
end if;
if first_state_sram_input_id = 195 then
	sram_write <= x"06220001";
end if;
if first_state_sram_input_id = 196 then
	sram_write <= x"C8BC0000";
end if;
if first_state_sram_input_id = 197 then
	sram_write <= x"82000290";
end if;
if first_state_sram_input_id = 198 then
	sram_write <= x"02200031";
end if;
if first_state_sram_input_id = 199 then
	sram_write <= x"82000024";
end if;
if first_state_sram_input_id = 200 then
	sram_write <= x"02200030";
end if;
if first_state_sram_input_id = 201 then
	sram_write <= x"82000024";
end if;
if first_state_sram_input_id = 202 then
	sram_write <= x"02600190";
end if;
if first_state_sram_input_id = 203 then
	sram_write <= x"86260338";
end if;
if first_state_sram_input_id = 204 then
	sram_write <= x"07DC0004";
end if;
if first_state_sram_input_id = 205 then
	sram_write <= x"C1FC0000";
end if;
if first_state_sram_input_id = 206 then
	sram_write <= x"58220000";
end if;
if first_state_sram_input_id = 207 then
	sram_write <= x"C43C0000";
end if;
if first_state_sram_input_id = 208 then
	sram_write <= x"C45C0004";
end if;
if first_state_sram_input_id = 209 then
	sram_write <= x"C17DFFFC";
end if;
if first_state_sram_input_id = 210 then
	sram_write <= x"C57C000C";
end if;
if first_state_sram_input_id = 211 then
	sram_write <= x"03DC0010";
end if;
if first_state_sram_input_id = 212 then
	sram_write <= x"037E0010";
end if;
if first_state_sram_input_id = 213 then
	sram_write <= x"C57C0000";
end if;
if first_state_sram_input_id = 214 then
	sram_write <= x"03DC0004";
end if;
if first_state_sram_input_id = 215 then
	sram_write <= x"82000284";
end if;
if first_state_sram_input_id = 216 then
	sram_write <= x"07DC0010";
end if;
if first_state_sram_input_id = 217 then
	sram_write <= x"C17C000C";
end if;
if first_state_sram_input_id = 218 then
	sram_write <= x"C57DFFFC";
end if;
if first_state_sram_input_id = 219 then
	sram_write <= x"03600010";
end if;
if first_state_sram_input_id = 220 then
	sram_write <= x"C8560000";
end if;
if first_state_sram_input_id = 221 then
	sram_write <= x"CC5C0008";
end if;
if first_state_sram_input_id = 222 then
	sram_write <= x"CC3C0010";
end if;
if first_state_sram_input_id = 223 then
	sram_write <= x"C17DFFFC";
end if;
if first_state_sram_input_id = 224 then
	sram_write <= x"40204000";
end if;
if first_state_sram_input_id = 225 then
	sram_write <= x"C57C001C";
end if;
if first_state_sram_input_id = 226 then
	sram_write <= x"03DC0020";
end if;
if first_state_sram_input_id = 227 then
	sram_write <= x"037E0010";
end if;
if first_state_sram_input_id = 228 then
	sram_write <= x"C57C0000";
end if;
if first_state_sram_input_id = 229 then
	sram_write <= x"03DC0004";
end if;
if first_state_sram_input_id = 230 then
	sram_write <= x"8200016C";
end if;
if first_state_sram_input_id = 231 then
	sram_write <= x"07DC0020";
end if;
if first_state_sram_input_id = 232 then
	sram_write <= x"C17C001C";
end if;
if first_state_sram_input_id = 233 then
	sram_write <= x"C57DFFFC";
end if;
if first_state_sram_input_id = 234 then
	sram_write <= x"C85C0010";
end if;
if first_state_sram_input_id = 235 then
	sram_write <= x"48242000";
end if;
if first_state_sram_input_id = 236 then
	sram_write <= x"0360000C";
end if;
if first_state_sram_input_id = 237 then
	sram_write <= x"C8560000";
end if;
if first_state_sram_input_id = 238 then
	sram_write <= x"44224000";
end if;
if first_state_sram_input_id = 239 then
	sram_write <= x"C03C0004";
end if;
if first_state_sram_input_id = 240 then
	sram_write <= x"58420000";
end if;
if first_state_sram_input_id = 241 then
	sram_write <= x"CC3C0018";
end if;
if first_state_sram_input_id = 242 then
	sram_write <= x"C17DFFFC";
end if;
if first_state_sram_input_id = 243 then
	sram_write <= x"40204000";
end if;
if first_state_sram_input_id = 244 then
	sram_write <= x"C57C0024";
end if;
if first_state_sram_input_id = 245 then
	sram_write <= x"03DC0028";
end if;
if first_state_sram_input_id = 246 then
	sram_write <= x"037E0010";
end if;
if first_state_sram_input_id = 247 then
	sram_write <= x"C57C0000";
end if;
if first_state_sram_input_id = 248 then
	sram_write <= x"03DC0004";
end if;
if first_state_sram_input_id = 249 then
	sram_write <= x"82000284";
end if;
if first_state_sram_input_id = 250 then
	sram_write <= x"07DC0028";
end if;
if first_state_sram_input_id = 251 then
	sram_write <= x"C17C0024";
end if;
if first_state_sram_input_id = 252 then
	sram_write <= x"C57DFFFC";
end if;
if first_state_sram_input_id = 253 then
	sram_write <= x"C85C0008";
end if;
if first_state_sram_input_id = 254 then
	sram_write <= x"CC3C0020";
end if;
if first_state_sram_input_id = 255 then
	sram_write <= x"C17DFFFC";
end if;
if first_state_sram_input_id = 256 then
	sram_write <= x"40204000";
end if;
if first_state_sram_input_id = 257 then
	sram_write <= x"C57C002C";
end if;
if first_state_sram_input_id = 258 then
	sram_write <= x"03DC0030";
end if;
if first_state_sram_input_id = 259 then
	sram_write <= x"037E0010";
end if;
if first_state_sram_input_id = 260 then
	sram_write <= x"C57C0000";
end if;
if first_state_sram_input_id = 261 then
	sram_write <= x"03DC0004";
end if;
if first_state_sram_input_id = 262 then
	sram_write <= x"8200016C";
end if;
if first_state_sram_input_id = 263 then
	sram_write <= x"07DC0030";
end if;
if first_state_sram_input_id = 264 then
	sram_write <= x"C17C002C";
end if;
if first_state_sram_input_id = 265 then
	sram_write <= x"C57DFFFC";
end if;
if first_state_sram_input_id = 266 then
	sram_write <= x"C85C0020";
end if;
if first_state_sram_input_id = 267 then
	sram_write <= x"48242000";
end if;
if first_state_sram_input_id = 268 then
	sram_write <= x"03600008";
end if;
if first_state_sram_input_id = 269 then
	sram_write <= x"C8560000";
end if;
if first_state_sram_input_id = 270 then
	sram_write <= x"44C24000";
end if;
if first_state_sram_input_id = 271 then
	sram_write <= x"022003E8";
end if;
if first_state_sram_input_id = 272 then
	sram_write <= x"03600004";
end if;
if first_state_sram_input_id = 273 then
	sram_write <= x"C8360000";
end if;
if first_state_sram_input_id = 274 then
	sram_write <= x"C8BC0018";
end if;
if first_state_sram_input_id = 275 then
	sram_write <= x"C17DFFFC";
end if;
if first_state_sram_input_id = 276 then
	sram_write <= x"40802000";
end if;
if first_state_sram_input_id = 277 then
	sram_write <= x"40602000";
end if;
if first_state_sram_input_id = 278 then
	sram_write <= x"40402000";
end if;
if first_state_sram_input_id = 279 then
	sram_write <= x"C57C002C";
end if;
if first_state_sram_input_id = 280 then
	sram_write <= x"03DC0030";
end if;
if first_state_sram_input_id = 281 then
	sram_write <= x"037E0010";
end if;
if first_state_sram_input_id = 282 then
	sram_write <= x"C57C0000";
end if;
if first_state_sram_input_id = 283 then
	sram_write <= x"03DC0004";
end if;
if first_state_sram_input_id = 284 then
	sram_write <= x"82000290";
end if;
if first_state_sram_input_id = 285 then
	sram_write <= x"07DC0030";
end if;
if first_state_sram_input_id = 286 then
	sram_write <= x"C17C002C";
end if;
if first_state_sram_input_id = 287 then
	sram_write <= x"C57DFFFC";
end if;
if first_state_sram_input_id = 288 then
	sram_write <= x"C03C0000";
end if;
if first_state_sram_input_id = 289 then
	sram_write <= x"02220001";
end if;
if first_state_sram_input_id = 290 then
	sram_write <= x"C05C0004";
end if;
if first_state_sram_input_id = 291 then
	sram_write <= x"82000328";
end if;
if first_state_sram_input_id = 292 then
	sram_write <= x"02400190";
end if;
if first_state_sram_input_id = 293 then
	sram_write <= x"862404A0";
end if;
if first_state_sram_input_id = 294 then
	sram_write <= x"07DC0004";
end if;
if first_state_sram_input_id = 295 then
	sram_write <= x"C1FC0000";
end if;
if first_state_sram_input_id = 296 then
	sram_write <= x"02400000";
end if;
if first_state_sram_input_id = 297 then
	sram_write <= x"C43C0000";
end if;
if first_state_sram_input_id = 298 then
	sram_write <= x"C17DFFFC";
end if;
if first_state_sram_input_id = 299 then
	sram_write <= x"01240000";
end if;
if first_state_sram_input_id = 300 then
	sram_write <= x"00420000";
end if;
if first_state_sram_input_id = 301 then
	sram_write <= x"00320000";
end if;
if first_state_sram_input_id = 302 then
	sram_write <= x"C57C0004";
end if;
if first_state_sram_input_id = 303 then
	sram_write <= x"03DC0008";
end if;
if first_state_sram_input_id = 304 then
	sram_write <= x"037E0010";
end if;
if first_state_sram_input_id = 305 then
	sram_write <= x"C57C0000";
end if;
if first_state_sram_input_id = 306 then
	sram_write <= x"03DC0004";
end if;
if first_state_sram_input_id = 307 then
	sram_write <= x"82000328";
end if;
if first_state_sram_input_id = 308 then
	sram_write <= x"07DC0008";
end if;
if first_state_sram_input_id = 309 then
	sram_write <= x"C17C0004";
end if;
if first_state_sram_input_id = 310 then
	sram_write <= x"C57DFFFC";
end if;
if first_state_sram_input_id = 311 then
	sram_write <= x"C03C0000";
end if;
if first_state_sram_input_id = 312 then
	sram_write <= x"02220001";
end if;
if first_state_sram_input_id = 313 then
	sram_write <= x"82000490";
end if;
if first_state_sram_input_id = 314 then
	sram_write <= x"02200000";
end if;
if first_state_sram_input_id = 315 then
	sram_write <= x"C17DFFFC";
end if;
if first_state_sram_input_id = 316 then
	sram_write <= x"C57C0004";
end if;
if first_state_sram_input_id = 317 then
	sram_write <= x"03DC0008";
end if;
if first_state_sram_input_id = 318 then
	sram_write <= x"037E0010";
end if;
if first_state_sram_input_id = 319 then
	sram_write <= x"C57C0000";
end if;
if first_state_sram_input_id = 320 then
	sram_write <= x"03DC0004";
end if;
if first_state_sram_input_id = 321 then
	sram_write <= x"82000490";
end if;
if first_state_sram_input_id = 322 then
	sram_write <= x"07DC0008";
end if;
if first_state_sram_input_id = 323 then
	sram_write <= x"C17C0004";
end if;
if first_state_sram_input_id = 324 then
	sram_write <= x"C57DFFFC";
end if;
if first_state_sram_input_id = 325 then
	sram_write <= x"8001E000";
end if;
            else
              sram_go <= '0';
            end if;
          else
            sram_go <= '0';
            top_state <= "001";
          end if;
        else
          if (first_state_write_wait = 5) then
            first_state_sram_input_id <= first_state_sram_input_id + 1;
          end if;
          if (first_state_write_wait > 0) then
            first_state_write_wait <= first_state_write_wait - 1;
          end if;
          sram_go <= '0';
        end if;
      end if;
      if top_state = "001" then
        --Input Wait
        if exok_from_read = '1' then
          exok <= '1';
          top_state <= "010";
          --if u232c_busy = '0' then
          --  u232c_data_reg <= x"000000" & debug_otpt_inputc;
          --  u232c_showtype <= "000";
          --  u232c_go <= '1';
          --else
          --  u232c_go <= '0';
          --end if;
        end if;
        if sram_busy = '0' then
          if inputc_write_ok = '1' then
            sram_go <= '1';
            --write
            sram_inst_type <= '1';
            sram_addr <= inputc_write_addr;
            sram_write <= inputc_write_value;
            debug_saved_value <= inputc_write_value;
            sigcount <= x"8";
            if u232c_busy = '0' then
              u232c_data_reg <= inputc_write_value;
              u232c_showtype <= "000";
              u232c_go <= '1';
            else
              u232c_go <= '0';
            end if;
          else
            u232c_go <= '0';
            sram_go <= '0';
          end if;
        else
          u232c_go <= '0';
          sram_go <= '0';
        end if;
      end if;
      if top_state = "010" then
        --Execution
        if u232c_busy = '0' then
          u232c_data_reg <= debug_otpt;
          u232c_showtype <= debug_otpt_code;
          u232c_go <= debug_otpt_signal;
        else
          u232c_go <= '0';
        end if;
        -- 垂れ流し
        core_sram_read <= sram_read;
        if sram_busy = '0' then
          if core_sram_go = '1' then
            sram_go <= '1';
            if core_sram_inst_type = '0' then
              --read
              sram_inst_type <= '0';
              sram_addr <= core_sram_addr;
            else
              --write
              sram_inst_type <= '1';
              sram_addr <= core_sram_addr;
              sram_write <= core_sram_write;
            end if;
          else
            sram_go <= '0';
          end if;
        else
          sram_go <= '0';
        end if;
      end if;
    end if;
  end process;
end cpu_top;

