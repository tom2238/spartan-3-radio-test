library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity lfsr_gen is
    generic(
        G_M : integer := 16 ;
        G_POLY : std_logic_vector := "1100010100010110"
    );    
    Port ( clk : in  STD_LOGIC;
           cell_data : out std_logic_vector(3 downto 0);           
           rst : in std_logic
    );
end lfsr_gen;

architecture Behavioral of lfsr_gen is
    signal r_lfsr : std_logic_vector (G_M downto 1);
    signal w_mask : std_logic_vector (G_M downto 1);
    signal w_poly : std_logic_vector (G_M downto 1);
    signal clk_div, clk_div_next : std_logic_vector (16 downto 0);
    signal cell_y_en : std_logic;
    signal cell_data_int : std_logic_vector(3 downto 0);
begin
    
    -- Generate LFSR
    w_poly  <= G_POLY;
    g_mask : for k in G_M downto 1 generate
        w_mask(k)  <= w_poly(k) and r_lfsr(1);
    end generate g_mask;

    process (rst, clk_div(16)) begin 
        if (rst = '1') then 
            r_lfsr   <= (others=>'1');
        elsif rising_edge(clk_div(16)) then  
            r_lfsr   <= '0' & r_lfsr(G_M downto 2) xor w_mask; 
        end if; 
    end process; 
    
    clk_div_next <= std_logic_vector(unsigned(clk_div) + 1);	
    
    process (clk) begin
		if(rising_edge(clk)) then	
			clk_div <= clk_div_next;
            cell_data <= cell_data_int;
		end if;
	end process;
    -- Select cell source
    cell_data_int <= r_lfsr(5 downto 2);    
   
end Behavioral;