library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- #!/bin/sh
-- sox -t pulseaudio default  -t wav - lowpass 5500 | sox -t wav - -r 11520 -b 8 -c 1 -t wav - | cat > /dev/ttyS0

entity top is
    Port ( clk : in  STD_LOGIC;
           uart_rx : in  STD_LOGIC;
           leds : out  STD_LOGIC_VECTOR (7 downto 0);
           sound : out  STD_LOGIC_VECTOR (7 downto 0)
           );
end top;

architecture Behavioral of top is
    signal rx_out, rx_out_int : std_logic_vector(7 downto 0);
    signal fs_clock : std_logic;
    signal rx_finish_en : std_logic;
begin
    
    process(clk) begin
        if(rising_edge(clk)) then
            if(rx_finish_en = '1') then
                rx_out <= rx_out_int;
            end if;
        end if;
    end process;        
    
    c_RX : entity work.UART_RX 
    port map (clk => clk,
			 rst => '0',
			 RX_data_in => uart_rx,		
			 RX_data_out => rx_out_int,
             RX_finish => rx_finish_en
    );
    
    
    -- clock divider
	CLK_DIVIDER: entity work.clock_divider
    generic map (
       COUNT_TO => 542, -- 
       WIDTH => 10 -- 
    )
	port map (
	   clk_in => clk,
       clk_out => fs_clock
	);
    
    leds <= rx_out;
    sound <= rx_out;


end Behavioral;