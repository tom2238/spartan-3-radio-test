library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity debouncer_2 is
    Port ( clk : in  STD_LOGIC;
           pulse : in  STD_LOGIC;
           debounced : out  STD_LOGIC);
end debouncer_2;

architecture Behavioral of debouncer_2 is
    signal debounce_register : std_logic_vector(63 downto 0) := (others => '0');
    signal debounce_int : std_logic := '0';
begin

    -- debouncer negativni clock
    process(clk) begin
        if rising_edge(clk) then
            debounce_register <= pulse & debounce_register(63 downto 1);
        end if;    
    end process;
    -- 1 is normal, input is active in 0
    debounce_int <= '1' when unsigned(debounce_register) = 0 else '0';
    debounced <= debounce_int;
    
    -- Konec
end Behavioral;

