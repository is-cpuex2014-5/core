library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- CPUEV2(HW09) より
entity sramt is
  Port ( clk : in  STD_LOGIC;
         sram_go : in std_logic := '0';
         sram_inst_type : in std_logic;
         sram_read : out std_logic_vector(31 downto 0);
         sram_write : in std_logic_vector(31 downto 0);
         sram_addr : in std_logic_vector(19 downto 0)
        );
end sramt;

architecture sram_pyon of sramt is
  type sram_array is array(31 downto 0) of std_logic_vector(31 downto 0);
  signal sram_value : sram_array := (others => x"00000000");
begin
  sram_pyon_pyon : process(clk)
  begin
    if rising_edge(clk) then
      if sram_go = '1' then
        if sram_inst_type = '1' then
          sram_value(conv_integer(sram_addr(4 downto 0))) <= sram_write;
        else
if sram_addr = 0 then
	sram_read <= x"820004E8";
end if;
if sram_addr = 1 then
	sram_read <= x"3F800000";
end if;
if sram_addr = 2 then
	sram_read <= x"3FC00000";
end if;
if sram_addr = 3 then
	sram_read <= x"43C80000";
end if;
if sram_addr = 4 then
	sram_read <= x"40800000";
end if;
if sram_addr = 5 then
	sram_read <= x"E0200000";
end if;
if sram_addr = 6 then
	sram_read <= x"07DC0004";
end if;
if sram_addr = 7 then
	sram_read <= x"C1FC0000";
end if;
if sram_addr = 8 then
	sram_read <= x"E2200000";
end if;
if sram_addr > 8 then
          sram_read <= sram_value(conv_integer(sram_addr(4 downto 0)));
end if;
        end if;
      end if;
    end if;
  end process;
end sram_pyon;

