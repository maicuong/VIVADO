library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity MEMORY_VHDL is
    Port ( CLK : in std_logic;
           DIN : in std_logic_vector(7 downto 0) := "00000000";
           DOUT : out std_logic_vector(7 downto 0);
           WR : in std_logic;
           ADDR_IN : in std_logic_vector(8 downto 0));
end MEMORY_VHDL;

architecture RTL of MEMORY_VHDL is
  type ram_type is array (511 downto 0) of std_logic_vector (7 downto 0); 
    signal RAM : ram_type; 
    signal ADDR_REG : std_logic_vector(8 downto 0); 
begin
  process(CLK) begin
    if (CLK'event and CLK = '1') then
      if (WR = '1') then 
        RAM(CONV_INTEGER(ADDR_IN)) <= DIN; 
      end if; 
      ADDR_REG <= ADDR_IN; 
    end if; 
  end process;
  DOUT <= RAM(CONV_INTEGER(ADDR_REG));
end RTL;
