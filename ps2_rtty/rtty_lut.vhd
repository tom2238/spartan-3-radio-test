library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

entity rtty_lut is
    Port ( ps2_scan_code : in  STD_LOGIC_VECTOR (7 downto 0);
           rtty_baudot : out  STD_LOGIC_VECTOR (4 downto 0)
           );
end rtty_lut;

architecture Behavioral of rtty_lut is

begin
    with ps2_scan_code select -- Murray code
    rtty_baudot <= "00011" when X"1C",   -- A
                   "00001" when X"24",   -- E
                   "10101" when X"35",   -- Y
                   "00111" when X"3C",   -- U
                   "00110" when X"43",   -- I
                   "11000" when X"44",   -- O
                   "01011" when X"3B",   -- J
                   "11010" when X"34",   -- G
                   "10100" when X"33",   -- H
                   "11001" when X"32",   -- B
                   "01110" when X"21",   -- C
                   "01101" when X"2B",   -- F
                   "01001" when X"23",   -- D
                   "00100" when X"29",   -- space
                   "11101" when X"22",   -- X
                   "10001" when X"1A",   -- Z
                   "00101" when X"1B",   -- S
                   "10000" when X"2C",   -- T
                   "10011" when X"1D",   -- W
                   "11110" when X"2A",   -- V
                   "01111" when X"42",   -- K
                   "11100" when X"3A",   -- M
                   "10010" when X"4B",   -- L
                   "01010" when X"2D",   -- R
                   "10111" when X"15",   -- Q
                   "01100" when X"31",   -- N
                   "10110" when X"4D",   -- P
                   "01000" when X"5A",   -- Enter
                   "11111" when others;   -- NULL


end Behavioral;

