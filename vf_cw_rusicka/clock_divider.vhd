----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:22:56 10/09/2020 
-- Design Name: 
-- Module Name:    clock_divider - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity clock_divider is
    generic (
        COUNT_TO : integer := 5        
    );
    Port ( clk_in : in  STD_LOGIC;
           clk_out : out  STD_LOGIC
    );
end clock_divider;

architecture Behavioral of clock_divider is
    signal clock_sig : std_logic := '0';
    signal count: integer:=1;
begin
 
    process(clk_in) begin
        if(rising_edge(clk_in)) then  
            count <= count + 1;
            if(count = COUNT_TO) then
                clock_sig <= not clock_sig;
                count <= 1;
            end if;    
        end if;
    end process;    
    
    clk_out <= clock_sig;
    
end Behavioral;