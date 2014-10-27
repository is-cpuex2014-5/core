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
         RS_RX : STD_LOGIC
        );
end top;

architecture cpu_top of top is
  signal clk,iclk : std_logic;
  --testbench signal
  component core Port (
    clk: in std_logic;
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
  signal hogge : std_logic_vector(7 downto 0);
  signal debug_otpt : std_logic_vector(31 downto 0);
  signal debug_otpt_code : std_logic_vector(2 downto 0);
  signal debug_otpt_signal : std_logic;
  signal u232c_data_reg : std_logic_vector(31 downto 0);
  signal u232c_showtype : std_logic_vector(2 downto 0);
  signal u232c_go : std_logic;
  signal u232c_busy : std_logic;
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
  core_send: core Port map (
    clk => clk,
    ostate => hogge,
    sram_go => core_sram_go,
    sram_inst_type => core_sram_inst_type,
    sram_read => core_sram_read,
    sram_write => core_sram_write,
    sram_addr => core_sram_addr,
    debug_otpt => debug_otpt,
    debug_otpt_code => debug_otpt_code,
    debug_otpt_signal => debug_otpt_signal
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
  end process;
end cpu_top;

