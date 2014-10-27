library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library UNISIM;
use UNISIM.VComponents.all;

-- CPUEV2(HW09) より
entity sram is
  Port ( clk : in  STD_LOGIC;
         SRXGA : out STD_LOGIC := '0';
         SRXE1 : out STD_LOGIC := '0';
         SRE2A : out STD_LOGIC := '1';
         SRXE3 : out STD_LOGIC := '0';
         SRXZCKE : out STD_LOGIC := '0';
         SRADVA : out STD_LOGIC := '0';
         SRXLBO : out STD_LOGIC := '1';
         SRZZA : out STD_LOGIC := '0';
         SRXFT : out STD_LOGIC := '1';
         SRZCLKMA : out STD_LOGIC_VECTOR (1 downto 0);
         SRZD : inout STD_LOGIC_VECTOR (31 downto 0) := "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
         SRZDP : inout STD_LOGIC_VECTOR (3 downto 0);
         SRZA : inout STD_LOGIC_VECTOR (19 downto 0);
         SRIOA : STD_LOGIC_VECTOR (126 downto 0);
         SRXZBE : inout STD_LOGIC_VECTOR (3 downto 0) := "0000";
         SRXWA : out STD_LOGIC := '1';
         SRXRST : in STD_LOGIC;
         sram_go : in std_logic;
         sram_busy : out std_logic;
         sram_inst_type : in std_logic;
         sram_read : out std_logic_vector(31 downto 0);
         sram_write : in std_logic_vector(31 downto 0);
         sram_addr : in std_logic_vector(19 downto 0)
        );
end sram;

architecture sram_pyon of sram is
  signal state : std_logic_vector(1 downto 0) := "00";
  signal waittm : std_logic_vector(7 downto 0) := x"00";
begin
  SRZCLKMA(0) <= clk;
  SRZCLKMA(1) <= clk;
  sram_pyon_pyon : process
  begin
    if rising_edge(clk) then
      if state = 0 then
        --waiting
        if sram_go = '1' then
          sram_busy <= '1';
          waittm <= x"AF";
          if sram_inst_type = '1' then
            --write set
            SRZA <= sram_addr;
            SRZD <= sram_write;
            SRXWA <= '0';
            state <= "01";
          else
            --read set
            SRZA <= sram_addr;
            SRZD <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
            SRXWA <= '1';
            state <= "10";
          end if;
        end if;
      end if;
      if state = 1 then
        --waiting (write)
        if waittm = 1 then
          state <= "00";
          sram_busy <= '0';
          SRXWA <= '1';
        end if;
        waittm <= waittm - 1;
      end if;
      if state = 2 then
        --waiting (read)
        if waittm = 1 then
          state <= "00";
          sram_busy <= '0';
          SRXWA <= '1';
          sram_read <= SRZD;
        end if;
        waittm <= waittm - 1;
      end if;
    end if;
  end process;
end sram_pyon;

