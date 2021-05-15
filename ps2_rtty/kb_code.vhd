library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

entity kb_code is
    Port ( clk : in  STD_LOGIC;
           ps2_data : in  STD_LOGIC_VECTOR (7 downto 0);
           ps2_data_en : in  STD_LOGIC;
           scan_code : out  STD_LOGIC_VECTOR (7 downto 0);
           scan_code_en : out STD_LOGIC
           );
end kb_code;

architecture Behavioral of kb_code is
    signal sc_code, sc_code_next : std_logic_vector(7 downto 0) := (others => '0');
    type state_type is (wait_on,get_code);
    signal st, st_next : state_type := wait_on;

begin
    scan_code <= sc_code;

    process(clk) begin
        if(rising_edge(clk)) then
            st <= st_next;
            sc_code <= sc_code_next;
        end if;
    end process;
    
    process(st, ps2_data, ps2_data_en, sc_code) begin
        sc_code_next <= sc_code;
        scan_code_en <= '0';
        case (st) is
            when wait_on =>
                if(ps2_data_en = '1') and (ps2_data = x"F0") then
                    st_next <= get_code;
                else
                    st_next <= wait_on;
                end if;            
            when others => -- get_code
                if(ps2_data_en = '1') then
                    sc_code_next <= ps2_data;
                    st_next <= wait_on;
                    scan_code_en <= '1';
                else 
                    st_next <= get_code;
                    sc_code_next <= sc_code;
                    scan_code_en <= '0';
                end if;  
        end case;  
    end process;
    
end Behavioral;