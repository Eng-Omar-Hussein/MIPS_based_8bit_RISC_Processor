library ieee;
use ieee.std_logic_1164.all;

entity processor_tb is
end entity processor_tb;

architecture tb_arch of processor_tb is
    signal Clk: std_logic := '0';
    signal Reset: std_logic := '0';
    signal Program_counter: std_logic_vector(5 downto 0):=(others => '0');
    signal destnation_register: std_logic_vector( 7 downto 0) := (others => '0');

    component processor
        port (
            Clk: in std_logic;
            Reset: in std_logic;
            Program_counter : out std_logic_vector(5 downto 0):=(others => '0');
            destnation_register : out std_logic_vector( 7 downto 0)
        );
    end component;

begin
    DUT: processor port map (
        Clk => Clk,
        Reset => Reset,
        Program_counter => Program_counter,
        destnation_register=>destnation_register
    );

    -- Clock process
    Clk_Process: process
    begin
        while now < 800 ns loop
            clk <= '0';
            wait for 5 ns;
            clk <= '1';
            wait for 5 ns;
        end loop;
        wait;
    end process;

    -- Reset process
    process
	begin
		reset <= '1';
		wait for 10 ns; 
		reset <= '0';
		wait;
	end process;

    Stimulus: process
    begin
    
        wait;
    end process;

end architecture tb_arch;

