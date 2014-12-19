-- fpu_man.vhd
-- fpu manager

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity fpu_man is
  Port (
    clk : in std_logic;
    opc_fpu : in std_logic_vector(6 downto 0);
    reg_in_a : in std_logic_vector(31 downto 0);
    reg_in_b : in std_logic_vector(31 downto 0);
    reg_out : out std_logic_vector(31 downto 0)
  );
end fpu_man;

architecture fpu_man_main of fpu_man is
  component fadd Port (
    A : in std_logic_vector(31 downto 0);
    B : in std_logic_vector(31 downto 0);
    CLK : in std_logic;
    C : out std_logic_vector(31 downto 0)
  );
  end component;
  component fsub Port (
    A : in std_logic_vector(31 downto 0);
    B : in std_logic_vector(31 downto 0);
    CLK : in std_logic;
    C : out std_logic_vector(31 downto 0)
  );
  end component;
  component fmul Port (
    A : in std_logic_vector(31 downto 0);
    B : in std_logic_vector(31 downto 0);
    CLK : in std_logic;
    C : out std_logic_vector(31 downto 0)
  );
  end component;
  component fsqrt Port (
    A : in std_logic_vector(31 downto 0);
    CLK : in std_logic;
    Q : out std_logic_vector(31 downto 0)
  );
  end component;
  component floor Port (
    A : in std_logic_vector(31 downto 0);
    CLK : in std_logic;
    Q : out std_logic_vector(31 downto 0)
  );
  end component;
  component i2f Port (
    A : in std_logic_vector(31 downto 0);
    CLK : in std_logic;
    Q : out std_logic_vector(31 downto 0)
  );
  end component;
  component fneg is
    port (
      A   : in  std_logic_vector (31 downto 0);
      CLK : in  std_logic;
      Q   : out std_logic_vector (31 downto 0));
  end component fneg;
  component finv Port (
    A : in std_logic_vector(31 downto 0);
    CLK : in std_logic;
    Q : out std_logic_vector(31 downto 0)
  );
  end component;
  component fabs is
    port (
      A   : in  std_logic_vector (31 downto 0);
      CLK : in  std_logic;
      Q   : out std_logic_vector (31 downto 0));
  end component fabs;
  component feq Port (
    A : in std_logic_vector(31 downto 0);
    B : in std_logic_vector(31 downto 0);
    CLK : in std_logic;
    C : out std_logic
  );
  end component;
  component flt Port (
    A : in std_logic_vector(31 downto 0);
    B : in std_logic_vector(31 downto 0);
    CLK : in std_logic;
    C : out std_logic
  );
  end component;
  signal a_fadd : std_logic_vector(31 downto 0);
  signal b_fadd : std_logic_vector(31 downto 0);
  signal ret_fadd : std_logic_vector(31 downto 0);
  signal a_fsub : std_logic_vector(31 downto 0);
  signal b_fsub : std_logic_vector(31 downto 0);
  signal ret_fsub : std_logic_vector(31 downto 0);
  signal a_fmul : std_logic_vector(31 downto 0);
  signal b_fmul : std_logic_vector(31 downto 0);
  signal ret_fmul : std_logic_vector(31 downto 0);
  signal temp_fdiv : std_logic_vector(31 downto 0);
  signal ret_fdiv : std_logic_vector(31 downto 0);
  signal a_fsqrt : std_logic_vector(31 downto 0);
  signal ret_fsqrt : std_logic_vector(31 downto 0);
  signal a_floor : std_logic_vector(31 downto 0);
  signal ret_floor : std_logic_vector(31 downto 0);
  signal a_itof : std_logic_vector(31 downto 0);
  signal ret_itof : std_logic_vector(31 downto 0);
  signal a_fneg : std_logic_vector (31 downto 0);
  signal ret_fneg : std_logic_vector (31 downto 0);
  signal a_finv : std_logic_vector(31 downto 0);
  signal ret_finv : std_logic_vector(31 downto 0);
  signal a_fabs : std_logic_vector (31 downto 0);
  signal ret_fabs : std_logic_vector (31 downto 0);
  signal a_bfeq : std_logic_vector(31 downto 0);
  signal b_bfeq : std_logic_vector(31 downto 0);
  signal ret_bfeq : std_logic;
  signal a_bflt : std_logic_vector(31 downto 0);
  signal b_bflt : std_logic_vector(31 downto 0);
  signal ret_bflt : std_logic;
begin
  with_fadd : fadd Port map(
    A => a_fadd,
    B => b_fadd,
    CLK => clk,
    C => ret_fadd
  );
  with_fsub : fsub Port map(
    A => a_fsub,
    B => b_fsub,
    CLK => clk,
    C => ret_fsub
  );
  with_fmul : fmul Port map(
    A => a_fmul,
    B => b_fmul,
    CLK => clk,
    C => ret_fmul
  );
  with_fsqrt : fsqrt Port map(
    A => a_fsqrt,
    CLK => clk,
    Q => ret_fsqrt
  );
  with_floor : floor Port map(
    A => a_floor,
    CLK => clk,
    Q => ret_floor
  );
  with_i2f : i2f Port map(
    A => a_itof,
    CLK => clk,
    Q => ret_itof
  );
  with_fneg: fneg Port map (
    A   => a_fneg,
    CLK => clk,
    Q   => ret_fneg);
  with_finv : finv Port map(
    A => a_finv,
    CLK => clk,
    Q => ret_finv
  );
  with_fabs : fabs Port map (
    A   => a_fabs,
    CLK => clk,
    Q   => ret_fabs);
  with_bfeq : feq Port map(
    A => a_bfeq,
    B => b_bfeq,
    CLK => clk,
    C => ret_bfeq
  );
  with_bflt : flt Port map(
    A => a_bflt,
    B => b_bflt,
    CLK => clk,
    C => ret_bflt
  );
  fpu_man_mainprocess: process(clk)
  begin
    if rising_edge(clk) then
      -- Operation fadd
      if opc_fpu = "0100000" then
        a_fadd <= reg_in_a;
        b_fadd <= reg_in_b;
        reg_out <= ret_fadd;
      end if;
      -- Operation fsub
      if opc_fpu = "0100010" then
        a_fsub <= reg_in_a;
        b_fsub <= reg_in_b;
        reg_out <= ret_fsub;
      end if;
      -- Operation fmul
      if opc_fpu = "0100100" then
        a_fmul <= reg_in_a;
        b_fmul <= reg_in_b;
        reg_out <= ret_fmul;
      end if;
      -- Operation fdiv
      if opc_fpu = "0100110" then
        a_finv <= reg_in_b;
        temp_fdiv <= ret_finv;
        a_fmul <= temp_fdiv;
        b_fmul <= reg_in_a;
        reg_out <= ret_fmul;
      end if;
      -- Operation fsqrt
      if opc_fpu = "0101000" then
        a_fsqrt <= reg_in_a;
        reg_out <= ret_fsqrt;
      end if;
      -- Operation ftoi
      if opc_fpu = "0101010" then
        a_floor <= reg_in_a;
        reg_out <= ret_floor;
      end if;
      -- Operation itof
      if opc_fpu = "0101100" then
        a_itof <= reg_in_a;
        reg_out <= ret_itof;
      end if;
      -- Operation fneg
      if opc_fpu = "0101110" then
        a_fneg <= reg_in_a;
        reg_out <= ret_fneg;
      end if;
      -- Operation finv
      if opc_fpu = "0110000" then
        a_finv <= reg_in_a;
        reg_out <= ret_finv;
      -- Operation fabs
      elsif opc_fpu = "0111000" then
        a_fabs <= reg_in_a;
        reg_out <= ret_fabs;
      end if;
      -- Operation bfeq,bfeqi
      if opc_fpu(6 downto 1) = "100010" then
        a_bfeq <= reg_in_a;
        b_bfeq <= reg_in_b;
        if ret_bfeq = '1' then
          reg_out <= x"00000001";
        else
          reg_out <= x"00000000";
        end if;
      end if;
      -- Operation bflt,bflti
      if opc_fpu(6 downto 1) = "100011" then
        a_bflt <= reg_in_a;
        b_bflt <= reg_in_b;
        if ret_bflt = '1' then
          reg_out <= x"00000001";
        else
          reg_out <= x"00000000";
        end if;
      end if;
    end if;
  end process;
end fpu_man_main;

