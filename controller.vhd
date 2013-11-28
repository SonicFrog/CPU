library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity controller is
    port(
        clk        : in  std_logic;
        reset_n    : in  std_logic;
        -- instruction opcode
        op         : in  std_logic_vector(5 downto 0);
        opx        : in  std_logic_vector(5 downto 0);
        -- activates branch condition
        branch_op  : out std_logic;
        -- immediate value sign extention
        imm_signed : out std_logic;
        -- instruction register enable
        ir_en      : out std_logic;
        -- PC control signals
        pc_add_imm : out std_logic;
        pc_en      : out std_logic;
        pc_sel_a   : out std_logic;
        pc_sel_imm : out std_logic;
        -- register file enable
        rf_wren    : out std_logic;
        -- multiplexers selections
        sel_addr   : out std_logic;
        sel_b      : out std_logic;
        sel_mem    : out std_logic;
        sel_pc     : out std_logic;
        sel_ra     : out std_logic;
        sel_rC     : out std_logic;
        -- write memory output
        read       : out std_logic;
        write      : out std_logic;
        -- alu op
        op_alu     : out std_logic_vector(5 downto 0)
    );
end controller;

architecture synth of controller is

	type state is (fetch1, fetch2, decode, r_op, store, break, load1, load2, i_op, branch, call, jmp, ur_op, ui_op);
	signal current_state, future_state : state;
	
begin

	process(clk)
	begin
		if(reset_n = '0') then
			current_state <= fetch1;
		elsif(rising_edge(clk)) then
			current_state <= future_state;
		end if;
	end process;

	process(current_state, op, opx)
	begin
		
		future_state <= current_state;
		
		read <= '0';
		write <= '0';
	
		branch_op <= '0';
		imm_signed <= '0';
		pc_sel_a <= '0';
		pc_sel_imm <= '0';
		pc_add_imm <= '0';
		sel_pc <= '0';
		sel_ra <= '0';
		ir_en <= '0';
		pc_en <= '0';
		imm_signed <= '0';
		sel_b <= '0';
		sel_addr <= '0';
		sel_rC <= '0';
		sel_mem <= '0';
		op_alu <= (others => '0');
		rf_wren <= '0';
		
		case current_state is
			when fetch1 =>
				read <= '1';
				future_state <= fetch2;
				
			when fetch2 =>
				pc_en <= '1';
				ir_en <= '1';
				future_state <= decode;
				
			when decode =>
				case "00" & op is
					when X"3A" => -- R_OP			
						case "00" & opx is 
							when X"34" => 
								future_state <= break;
							when X"0D" | X"05" => 
								future_state <= jmp;
							
							when others =>
								case "00" & opx is
									when X"12" | X"1A" | X"3A" => 
										-- R_OP avec opérande non signée
										future_state <= ur_op;
									when others =>
										future_state <= r_op;
								end case;
								
						end case;
						
					when X"17" => -- Load word
						future_state <= load1;
						
					when X"15" => -- Store word
						future_state <= store;
						
					when X"04" => -- Operande imm avec signe
						future_state <= i_op;
						
					when X"0C" |
						 X"14" |
						 X"1C" => --Operande imm sans signe
						 future_state <= ui_op;

					when X"06" | 
						 X"0E" | 
						 X"16" | 
						 X"1E" | 
						 X"26" | 
						 X"2E" | 
						 X"36" => -- Opération de branching
						future_state <= branch; 
						
					when X"00" => -- Instruction call
						future_state <= call ;
						
					when others =>
						future_state <= fetch1;
						
				end case;
				
			when r_op =>
				rf_wren <= '1';
				sel_mem <= '0';
				sel_pc <= '0';
				sel_b <= '1';
				sel_rC <= '1';

				case "00" & opx is
					when X"1B" => 
						-- srl
						op_alu <= "110011";
				
					when X"0E" => 
						-- and
						op_alu <= "100001";
						
					when X"31" =>
						--add
						op_alu <= (others => '0');
						
					when X"39" => 
						--sub
						op_alu <= "001000";

					when X"08" => 
						--cmpge
						op_alu <= "011001";
						
					when X"10" => 
						--cmplt
						op_alu <= "011010";
						
					when X"06" =>
						--nor
						op_alu <= "100000";
						
					when X"16" => 
						--or
						op_alu <= "100010";
						
					when X"1E" =>
						--xor
						op_alu <= "100011";
						
					when X"13" =>
						--sll
						op_alu <= "110010";
					
					when X"3B" =>
						--sra
						op_alu <= "110111";
						
					when others => 
				end case;

				-- Skip fetch1
				read <= '1';
				future_state <= fetch2;

			
			when store =>
				sel_b <= '0';
				sel_addr <= '1';
				write <= '1';	
				imm_signed <= '1';
				future_state <= fetch1;
			
			when break =>
				future_state <= break;
				
			when load1 =>
				imm_signed <= '1';
				sel_b <= '0';
				op_alu <= (others => '0');
				read <= '1';
				sel_addr <= '1';		
				future_state <= load2;
			
			when load2 =>
				sel_rC <= '0';
				sel_mem <= '1';
				rf_wren <= '1';

				-- Skip fetch1
				read <= '1';
				future_state <= fetch2;

			
			when i_op =>
				rf_wren <= '1';
				future_state <= fetch1;
				
				case "00" & op is
					when X"04" => -- addi
						op_alu <= (others => '0');
						imm_signed <= '1';
					
					when X"0C" | X"14" | X"1C" => --Opération non signée
						future_state <= ur_op;
						

					when others => 
						rf_wren <= '0';
				end case;

				-- Skip fetch1
				read <= '1';
				future_state <= fetch2;

				

			when ur_op => 
				-- Execution des instructions r-type avec
				-- opérande non signées
				rf_wren <= '1';
				sel_rC <= '1';
				imm_signed <= '0';

				case "00" & opx is 
					when X"12" => -- slli
						op_alu <= "110010";

					when X"1A" => -- srli
						op_alu <= "110011";

					when X"3A" => -- srai
						op_alu <= "111111";

					when others =>

				end case;

				-- Skip fetch1
				read <= '1';
				future_state <= fetch2;

			when ui_op =>
				--Execution des instructions i_type avec
				-- opérande non signée
				rf_wren <= '1';
				sel_rc <= '0';
				imm_signed <= '0';
				future_state <= fetch1;

				case "00" & op is
					when X"0C" => -- andi
						op_alu <= "100001";

					when X"14" => -- ori
						op_alu <= "100010";

					when X"1C" => -- xori
						op_alu <= "100011";

					when others => 

				end case;

				-- Skip fetch1
				read <= '1';
				future_state <= fetch2;


				
			when branch =>
				future_state <= fetch1;
				branch_op <= '1'; 
				sel_b <= '1';
				
				-- pc_en <= '1'  ; 
				-- N'est pas activé sur le pdf 
				
				pc_add_imm <= '1';
				-- L'instruction content IMM16, donc on 
				-- ajoute tout de suite l'adresse dans le pc
				
				-- Géré dans un process à part
				case "00" & op is
					when X"06" =>
						-- br 
						op_alu <= "011100";
						
					when X"0E" =>
						-- bge
						-- A >= B
						op_alu <= "011001" ;
						
					when X"16" =>
						-- blt
						-- A < B
						op_alu <= "011010" ;

					when X"1E" => 
						-- bne
						-- A != B
						op_alu <= "011011" ; 
						
					when X"26" =>
						-- beq
						-- A == B
						op_alu <= "011100" ; 
						
					when X"2E" =>
						-- bgeu
						-- unsigned A >= unsigned B
						op_alu <= "011101" ; 
						
					when X"36" =>
						-- bltu
						-- unsigned A < unsigned B
						op_alu <= "011110" ; 
					
					when others =>
						branch_op <= '0' ; 
						sel_b <= '0' ;
						
				end case;
					
			when call => --Store the current pc address in the ra register
				pc_en <= '1';
				sel_ra <= '1';
				sel_rC <= '0';
				rf_wren <= '1';
				sel_mem <= '0';
				sel_pc <= '1';
				pc_sel_imm <= '1';
				future_state <= fetch1;
				
			when jmp => --Jumps at the address contained in the given register
				pc_sel_a <= '1';
				pc_en <= '1';
				future_state <= fetch1;
				
			when others =>
				future_state <= fetch1;
				
		end case;
		
	end process;
	
end synth;
