library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity rttymem is
    Port ( clk : in STD_LOGIC;
           addr : in STD_LOGIC_VECTOR(7 downto 0);
           output_data : out STD_LOGIC
         );
end rttymem;

architecture Behavioral of rttymem is
    type ROMmemory is array(0 to 255) of std_logic;
    constant rom : ROMmemory := ( 
      -- ST  LSB   _    _    _   MSB  STOP 
        '0', '1', '1', '1', '1', '1', '1', -- LTRS
        '0', '0', '0', '1', '0', '0', '1', -- SPACE
        '0', '1', '1', '0', '0', '0', '1', -- A
        '0', '0', '0', '1', '0', '1', '1', -- H
        '0', '0', '0', '0', '1', '1', '1', -- O
        '0', '1', '1', '0', '1', '0', '1', -- J
        '0', '0', '0', '1', '0', '0', '1', -- SPACE
        '0', '0', '0', '0', '0', '1', '1', -- T
        '0', '0', '0', '0', '1', '1', '1', -- O
        '0', '0', '0', '1', '1', '1', '1', -- M
        '0', '1', '1', '0', '0', '0', '1', -- A
        '0', '1', '0', '1', '0', '0', '1', -- S
        '0', '0', '0', '1', '0', '0', '1', -- SPACE
        '0', '1', '1', '0', '1', '1', '1', -- FIGS
        '0', '1', '1', '0', '0', '1', '1', -- 2
        '0', '0', '0', '0', '0', '1', '1', -- 5
        '0', '0', '0', '1', '1', '1', '1', -- .
        '0', '1', '1', '1', '0', '1', '1', -- 1
        '0', '0', '1', '1', '0', '1', '1', -- 0
        '0', '0', '0', '1', '1', '1', '1', -- .
        '0', '0', '0', '0', '1', '0', '1', -- CR
        '0', '0', '1', '0', '0', '0', '1', -- LF
        
        others => '0'
    );
    
begin
    process(clk) begin
        if(rising_edge(clk)) then
            output_data <= rom(to_integer(unsigned(addr)));
        end if;
    end process; 
end Behavioral;