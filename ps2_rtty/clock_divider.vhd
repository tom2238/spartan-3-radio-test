library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

entity clock_divider is
    generic (
        COUNT_TO : integer := 1;
        WIDTH : integer := 24
    );
    Port ( clk_in : in  STD_LOGIC;
           clk_out : out  STD_LOGIC
    );
end clock_divider;

architecture Behavioral of clock_divider is
    signal clock_sig, clock_sig_next : std_logic := '0';
    signal cnt, cnt_next : std_logic_vector(WIDTH-1 downto 0) := (others => '0');
    signal cnt_clear : std_logic := '0';

begin
 
    process(clk_in) begin
        if(rising_edge(clk_in)) then
            cnt <= cnt_next;
            clock_sig <= clock_sig_next;
        end if;
    end process;
    
    process(cnt_clear,clock_sig) begin
        if(cnt_clear = '1') then
            clock_sig_next <= not clock_sig;
        else   
            clock_sig_next <= clock_sig;
        end if;
    end process;
    
    clk_out <= clock_sig;
    cnt_clear <= '1' when unsigned(cnt) = COUNT_TO else '0';
    cnt_next <= std_logic_vector(unsigned(cnt) + 1) when cnt_clear = '0' else std_logic_vector(to_unsigned(1,WIDTH));
      
end Behavioral;