library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

entity enabler is
    Port ( vstup_in : in  STD_LOGIC;
           vystup_out : out  STD_LOGIC;
           clk : in  STD_LOGIC);
end enabler;

architecture Behavioral of enabler is
  signal vystupD1_Q : std_logic;
  signal vystupXOR  : std_logic;
  signal vystupAND  : std_logic;
begin

  -- Vstupni a Vystupni D 
  d_ff_1: process (clk)
    begin
    if(rising_edge(clk)) then
      vystupD1_Q <= vstup_in;
      vystup_out <= vystupAND;
    end if;
  end process;
    
  vystupAND <= vstup_in and vystupXOR;
  vystupXOR <= vstup_in xor vystupD1_Q;  

end Behavioral;

