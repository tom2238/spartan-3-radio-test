----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:45:29 10/17/2020 
-- Design Name: 
-- Module Name:    vf_cw_rusicka - Behavioral 
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity vf_cw_rusicka is
    Port ( clk : in  STD_LOGIC;
           cw : in  STD_LOGIC;
           ant : out  STD_LOGIC);
end vf_cw_rusicka;

architecture Behavioral of vf_cw_rusicka is
    signal clk2 : std_logic;
begin

     -- delicka z 50 MHz na 25 MHz
	 CLK_DIVIDER_VGA: entity work.clock_divider
     generic map (
        COUNT_TO => 1 -- 1 = 2 divison 2      
     )
	 port map (
	    clk_in => clk,
        clk_out => clk2
	 );

ant <= clk2 and cw;

end Behavioral;

