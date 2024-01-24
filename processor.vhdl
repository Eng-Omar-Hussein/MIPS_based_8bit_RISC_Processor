library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity processor is
	port (
		Clk : in std_logic;
		Reset : in std_logic;
		Program_counter : out std_logic_vector(5 downto 0):=(others => '0');
		destnation_register : out std_logic_vector(7 downto 0):=(others => '0'));
	end entity;
	architecture Behavioral of processor is
		type memoryinst is array (0 to 15) of std_logic_vector(15 downto 0);
		constant inst : memoryinst := (
			x"7209",--0 -- r1 <- 29
			x"0000",--1 -- r3 <- 0
			x"0000",--2 -- r2 <- 0
			x"7802",--3 -- r4 <- 2
			x"2240",--4 -- r1 <- r1 to update sf_flag 
			x"F009",--5 -- if(sf==0) --> inst[9]
			x"0000",--6 -- wait for 10 ns
			x"0000",--7 -- wait for 10 ns
			x"2481",--8 -- r2 <- r2 + 1
			x"130B",--9 -- r1 <- r1 / r4
			x"B2C4",--A -- if(r1>r3) --> inst[4]
			x"0000",--B -- wait for 10 ns
			x"0000",--C -- wait for 10 ns
			x"2480",--D -- r2 <- r2 to update destnation_register
			x"0000",--E -- end
			x"0000"); 
		type registers is array (0 to 7) of std_logic_vector(7 downto 0);
		signal reg : registers := (others => (others => '0'));
		type memory is array (0 to 15) of std_logic_vector(15 downto 0);
		signal s : memory := (others => (others => '0'));
		signal current_PC,PC : std_logic_vector(5 downto 0):= (others => '0');
		signal current_instr : std_logic_vector(15 downto 0) := (others => '0');
		signal cf_flag, zf_flag, sf_flag : std_logic := '0';	
	begin
		process (Clk, Reset)
			variable A, B : std_logic_vector(7 downto 0) := (others => '0');
			variable alu_value, mux_cout : std_logic_vector(15 downto 0) := (others => '0');
			variable extended_immediate_9 : std_logic_vector(15 downto 0):= (others => '0');
			variable fs : std_logic_vector(2 downto 0):= (others => '0');
			variable regfile_rs, regfile_rt: std_logic_vector(7 downto 0) := (others => '0');
			variable fetched_immediate_6, fetched_address_6: std_logic_vector(5 downto 0) := (others => '0');
			variable fetched_opcode : std_logic_vector(3 downto 0) := (others => '0');
			variable fetched_rs, fetched_rt, fetched_rd, fetched_func : std_logic_vector(2 downto 0) := (others => '0');
			variable fetched_taddress : std_logic_vector(11 downto 0) := (others => '0');
			variable fetched_immediate_9, fetched_address_9 : std_logic_vector(8 downto 0) := (others => '0');
		begin
			if Reset = '1' then
				PC <= (others => '0');
			
			elsif rising_edge(Clk) then
				current_PC <= std_logic_vector(unsigned(PC) mod "010000");
				current_instr<=inst(to_integer(unsigned(current_PC)));
				Program_counter<=current_PC;
				fetched_opcode := current_instr(15 downto 12);
				fetched_rs := current_instr(11 downto 9);
				fetched_rt := current_instr(8 downto 6);
				fetched_rd := current_instr(5 downto 3);
				fetched_func := current_instr(2 downto 0);
				fetched_immediate_9 := current_instr(8 downto 0);
				fetched_address_9 := current_instr(8 downto 0);
				fetched_immediate_6 := current_instr(5 downto 0);
				fetched_address_6 := current_instr(5 downto 0);
				fetched_taddress := current_instr(11 downto 0);
				regfile_rs := reg(to_integer(unsigned(fetched_rs)));
				regfile_rt := reg(to_integer(unsigned(fetched_rt)));
				A := regfile_rs;
				if fetched_opcode = "0001" then
					B := regfile_rt;
					fs := fetched_func;
				else
					if fetched_opcode = "0010" then
						fs := "000";
					elsif fetched_opcode = "0011" then
						fs := "001";
					elsif fetched_opcode = "0100" then
						fs := "100";
					elsif fetched_opcode = "0101" then
						fs := "101";
					else
						fs := "110";
					end if;
					B(5 downto 0) := fetched_immediate_6;
				end if;
				alu_value := (others => '0');
				case fs is
					when "000" =>
						alu_value(7 downto 0) := std_logic_vector(unsigned(A) + unsigned(B));
					when "001" =>
						alu_value(7 downto 0) := std_logic_vector(unsigned(A) - unsigned(B));
					when "010" =>
						alu_value := std_logic_vector(unsigned(A) * unsigned(B));
					when "011" =>
						alu_value(7 downto 0) := std_logic_vector(unsigned(A) / unsigned(B));
						alu_value(15 downto 8) := std_logic_vector(unsigned(A) mod unsigned(B));
					when "100" =>
						alu_value(7 downto 0) := A and B;
					when "101" =>
						alu_value(7 downto 0) := A or B;
					when "110" =>
						alu_value(7 downto 0) := A xor B;
					when others =>
						alu_value(7 downto 0) := not A;
				end case;
				case fetched_opcode is
					when "0000" =>
						mux_cout := (others => '0');
					when "1000" =>
						mux_cout := s(to_integer(unsigned(fetched_address_6)));
					when "1001" =>
						mux_cout(7 downto 0) := regfile_rs;
					when "0111" =>
						extended_immediate_9 := (others => '0');
						extended_immediate_9(8 downto 0) := fetched_immediate_9;
						mux_cout := extended_immediate_9;
					when others =>
						mux_cout := alu_value;
				end case;
				cf_flag <= mux_cout (7) xor mux_cout (6);
				if std_logic_vector(mux_cout nor "0000000000000000") = "1111111111111111" then
					zf_flag <= '1';
				else
					zf_flag <= '0';
				end if;
				sf_flag <= mux_cout (0);
				if fetched_opcode = "0001" then
					reg(to_integer(unsigned(fetched_rd))) <= mux_cout(7 downto 0);
				elsif fetched_opcode = "0111" or fetched_opcode = "1000" then
					reg(to_integer(unsigned(fetched_rs))) <= mux_cout(7 downto 0);
				elsif fetched_opcode = "0110" or fetched_opcode = "0101" or fetched_opcode = "0100" or fetched_opcode = "0011" or fetched_opcode = "0010" then
					reg(to_integer(unsigned(fetched_rt))) <= mux_cout(7 downto 0);
				elsif fetched_opcode = "1001" then
					s(to_integer(unsigned(fetched_address_6))) <= mux_cout;
				end if;
				destnation_register <= mux_cout(7 downto 0);
				if regfile_rs = regfile_rt and fetched_opcode = "1010" then
					PC <= fetched_address_6;
				elsif regfile_rs > regfile_rt and fetched_opcode = "1011" then
					PC <= fetched_address_6;
				elsif regfile_rs < regfile_rt and fetched_opcode = "1100" then
					PC <= fetched_address_6;
				elsif cf_flag = '1' and fetched_opcode = "1101" then
					PC <= fetched_address_6;
				elsif zf_flag = '1' and fetched_opcode = "1110" then
					PC <= fetched_address_6;
				elsif sf_flag='0' and fetched_opcode = "1111" then
					PC <= fetched_taddress(5 downto 0);
				else
					PC <= std_logic_vector(unsigned(PC) + 1);
				end if;
			end if;
		end process;
end Behavioral;
