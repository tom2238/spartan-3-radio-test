library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

entity key2seg7 is
    Port ( scan_code : in  STD_LOGIC_VECTOR (7 downto 0);
           segment_data : out  STD_LOGIC_VECTOR (6 downto 0);
           segment_pozice : out  STD_LOGIC_VECTOR (3 downto 0);
           clk : in  STD_LOGIC);
end key2seg7;

architecture Behavioral of key2seg7 is
    signal segment_reg : std_logic_vector(3 downto 0) := "1110";
    signal segment0, segment2, segment3 : std_logic_vector(4 downto 0);
    signal segment_active : std_logic_vector(4 downto 0);

begin

    process(clk) begin
        if(rising_edge(clk)) then
            segment_reg <= segment_reg(0) & segment_reg(3 downto 1);
        end if;
    end process;
    
    segment_pozice <= segment_reg;
    
    segment2 <= "10001" when scan_code = x"00" else
                '0' & scan_code(3 downto 0);
    
    segment3 <= "10001" when scan_code = x"00" else
                '0' & scan_code(7 downto 4);
    
    segment0 <= "00000" when scan_code = x"45" else
                "00001" when scan_code = x"16" else
                "00010" when scan_code = x"1e" else
                "00011" when scan_code = x"26" else
                "00100" when scan_code = x"25" else
                "00101" when scan_code = x"2e" else
                "00110" when scan_code = x"36" else
                "00111" when scan_code = x"3d" else
                "01000" when scan_code = x"3e" else
                "01001" when scan_code = x"46" else
                "01010" when scan_code = x"1c" else
                "01011" when scan_code = x"32" else
                "01100" when scan_code = x"21" else
                "01101" when scan_code = x"23" else
                "01110" when scan_code = x"24" else
                "01111" when scan_code = x"2b" else
                "10001"; --pomlcka
    
    segment_active <= segment0 when segment_reg = "1110" else
                      segment2 when segment_reg = "1011" else
                      segment3 when segment_reg = "0111" else
                      "10000"; --zhasni
    
     --              abcdefg , aktivni v 0
    segment_data <= "0000001" when segment_active = "00000" else    -- 0
              "1001111" when segment_active = "00001" else    -- 1
              "0010010" when segment_active = "00010" else    -- 2
              "0000110" when segment_active = "00011" else    -- 3
              "1001100" when segment_active = "00100" else    -- 4
              "0100100" when segment_active = "00101" else    -- 5
              "0100000" when segment_active = "00110" else    -- 6
              "0001111" when segment_active = "00111" else    -- 7
              "0000000" when segment_active = "01000" else    -- 8
              "0000100" when segment_active = "01001" else    -- 9
              "0001000" when segment_active = "01010" else    -- A
              "1100000" when segment_active = "01011" else    -- B
              "1110010" when segment_active = "01100" else    -- C
              "1000010" when segment_active = "01101" else    -- D
              "0110000" when segment_active = "01110" else    -- E
              "0111000" when segment_active = "01111" else    -- F
              "1111111" when segment_active = "10000" else    -- zhasni
              "1111110"; --when segment_active = "10001"; pomlcka

end Behavioral;