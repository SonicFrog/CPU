-- Copyright (C) 1991-2007 Altera Corporation
-- Your use of Altera Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Altera Program License 
-- Subscription Agreement, Altera MegaCore Function License 
-- Agreement, or other applicable license agreement, including, 
-- without limitation, that your use is for the sole purpose of 
-- programming logic devices manufactured by Altera and sold by 
-- Altera or its authorized distributors.  Please refer to the 
-- applicable agreement for further details.

-- PROGRAM "Quartus II"
-- VERSION "Version 7.2 Build 207 03/18/2008 Service Pack 3 SJ Full Version"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY CPU IS 
	port
	(
		reset_n :  IN  STD_LOGIC;
		clk :  IN  STD_LOGIC;
		rddata :  IN  STD_LOGIC_VECTOR(31 downto 0);
		write :  OUT  STD_LOGIC;
		read :  OUT  STD_LOGIC;
		address :  OUT  STD_LOGIC_VECTOR(15 downto 0);
		wrdata :  OUT  STD_LOGIC_VECTOR(31 downto 0)
	);
END CPU;

ARCHITECTURE bdf_type OF CPU IS 

component alu
	PORT(a : IN STD_LOGIC_VECTOR(31 downto 0);
		 b : IN STD_LOGIC_VECTOR(31 downto 0);
		 op : IN STD_LOGIC_VECTOR(5 downto 0);
		 s : OUT STD_LOGIC_VECTOR(31 downto 0)
	);
end component;

component controller
	PORT(clk : IN STD_LOGIC;
		 reset_n : IN STD_LOGIC;
		 op : IN STD_LOGIC_VECTOR(5 downto 0);
		 opx : IN STD_LOGIC_VECTOR(5 downto 0);
		 branch_op : OUT STD_LOGIC;
		 imm_signed : OUT STD_LOGIC;
		 ir_en : OUT STD_LOGIC;
		 pc_add_imm : OUT STD_LOGIC;
		 pc_en : OUT STD_LOGIC;
		 pc_sel_a : OUT STD_LOGIC;
		 pc_sel_imm : OUT STD_LOGIC;
		 rf_wren : OUT STD_LOGIC;
		 sel_addr : OUT STD_LOGIC;
		 sel_b : OUT STD_LOGIC;
		 sel_mem : OUT STD_LOGIC;
		 sel_pc : OUT STD_LOGIC;
		 sel_ra : OUT STD_LOGIC;
		 sel_rC : OUT STD_LOGIC;
		 write : OUT STD_LOGIC;
		 read : OUT STD_LOGIC;
		 op_alu : OUT STD_LOGIC_VECTOR(5 downto 0)
	);
end component;

component extend
	PORT(signed : IN STD_LOGIC;
		 imm16 : IN STD_LOGIC_VECTOR(15 downto 0);
		 imm32 : OUT STD_LOGIC_VECTOR(31 downto 0)
	);
end component;

component ir
	PORT(clk : IN STD_LOGIC;
		 enable : IN STD_LOGIC;
		 D : IN STD_LOGIC_VECTOR(31 downto 0);
		 Q : OUT STD_LOGIC_VECTOR(31 downto 0)
	);
end component;

component mux2x16
	PORT(sel : IN STD_LOGIC;
		 i0 : IN STD_LOGIC_VECTOR(15 downto 0);
		 i1 : IN STD_LOGIC_VECTOR(15 downto 0);
		 o : OUT STD_LOGIC_VECTOR(15 downto 0)
	);
end component;

component mux2x5
	PORT(sel : IN STD_LOGIC;
		 i0 : IN STD_LOGIC_VECTOR(4 downto 0);
		 i1 : IN STD_LOGIC_VECTOR(4 downto 0);
		 o : OUT STD_LOGIC_VECTOR(4 downto 0)
	);
end component;

component mux2x32
	PORT(sel : IN STD_LOGIC;
		 i0 : IN STD_LOGIC_VECTOR(31 downto 0);
		 i1 : IN STD_LOGIC_VECTOR(31 downto 0);
		 o : OUT STD_LOGIC_VECTOR(31 downto 0)
	);
end component;

component pc
	PORT(clk : IN STD_LOGIC;
		 reset_n : IN STD_LOGIC;
		 en : IN STD_LOGIC;
		 sel_a : IN STD_LOGIC;
		 sel_imm : IN STD_LOGIC;
		 add_imm : IN STD_LOGIC;
		 a : IN STD_LOGIC_VECTOR(15 downto 0);
		 imm : IN STD_LOGIC_VECTOR(15 downto 0);
		 addr : OUT STD_LOGIC_VECTOR(31 downto 0)
	);
end component;

component register_file
	PORT(clk : IN STD_LOGIC;
		 wren : IN STD_LOGIC;
		 aa : IN STD_LOGIC_VECTOR(4 downto 0);
		 ab : IN STD_LOGIC_VECTOR(4 downto 0);
		 aw : IN STD_LOGIC_VECTOR(4 downto 0);
		 wrdata : IN STD_LOGIC_VECTOR(31 downto 0);
		 a : OUT STD_LOGIC_VECTOR(31 downto 0);
		 b : OUT STD_LOGIC_VECTOR(31 downto 0)
	);
end component;

signal	a :  STD_LOGIC_VECTOR(31 downto 0);
signal	alu_res :  STD_LOGIC_VECTOR(31 downto 0);
signal	aw :  STD_LOGIC_VECTOR(4 downto 0);
signal	b :  STD_LOGIC_VECTOR(31 downto 0);
signal	branch_op :  STD_LOGIC;
signal	branch_taken :  STD_LOGIC;
signal	imm :  STD_LOGIC_VECTOR(31 downto 0);
signal	imm_signed :  STD_LOGIC;
signal	instr :  STD_LOGIC_VECTOR(31 downto 0);
signal	ir_en :  STD_LOGIC;
signal	op_alu :  STD_LOGIC_VECTOR(5 downto 0);
signal	op_b :  STD_LOGIC_VECTOR(31 downto 0);
signal	pc_add_imm :  STD_LOGIC;
signal	pc_addr :  STD_LOGIC_VECTOR(31 downto 0);
signal	pc_en :  STD_LOGIC;
signal	pc_sel_a :  STD_LOGIC;
signal	pc_sel_imm :  STD_LOGIC;
signal	pc_wren :  STD_LOGIC;
signal	ra :  STD_LOGIC_VECTOR(4 downto 0);
signal	rf_wren :  STD_LOGIC;
signal	sel_addr :  STD_LOGIC;
signal	sel_b :  STD_LOGIC;
signal	sel_mem :  STD_LOGIC;
signal	sel_pc :  STD_LOGIC;
signal	sel_ra :  STD_LOGIC;
signal	sel_rC :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_0 :  STD_LOGIC_VECTOR(4 downto 0);
signal	SYNTHESIZED_WIRE_1 :  STD_LOGIC;
signal	SYNTHESIZED_WIRE_2 :  STD_LOGIC_VECTOR(31 downto 0);
signal	SYNTHESIZED_WIRE_3 :  STD_LOGIC_VECTOR(31 downto 0);


BEGIN 



b2v_alu_0 : alu
PORT MAP(a => a,
		 b => op_b,
		 op => op_alu,
		 s => alu_res);

branch_taken <= branch_op AND alu_res(0);

b2v_controller_0 : controller
PORT MAP(clk => clk,
		 reset_n => reset_n,
		 op => instr(5 downto 0),
		 opx => instr(16 downto 11),
		 branch_op => branch_op,
		 imm_signed => imm_signed,
		 ir_en => ir_en,
		 pc_add_imm => pc_add_imm,
		 pc_en => pc_wren,
		 pc_sel_a => pc_sel_a,
		 pc_sel_imm => pc_sel_imm,
		 rf_wren => rf_wren,
		 sel_addr => sel_addr,
		 sel_b => sel_b,
		 sel_mem => sel_mem,
		 sel_pc => sel_pc,
		 sel_ra => sel_ra,
		 sel_rC => sel_rC,
		 write => write,
		 read => read,
		 op_alu => op_alu);

b2v_extend_0 : extend
PORT MAP(signed => imm_signed,
		 imm16 => instr(21 downto 6),
		 imm32 => imm);

b2v_IR_0 : ir
PORT MAP(clk => clk,
		 enable => ir_en,
		 D => rddata,
		 Q => instr);

b2v_mux_addr : mux2x16
PORT MAP(sel => sel_addr,
		 i0 => pc_addr(15 downto 0),
		 i1 => alu_res(15 downto 0),
		 o => address);

b2v_mux_aw : mux2x5
PORT MAP(sel => sel_rC,
		 i0 => SYNTHESIZED_WIRE_0,
		 i1 => instr(21 downto 17),
		 o => aw);

b2v_mux_b : mux2x32
PORT MAP(sel => sel_b,
		 i0 => imm,
		 i1 => b,
		 o => op_b);

b2v_mux_data : mux2x32
PORT MAP(sel => SYNTHESIZED_WIRE_1,
		 i0 => alu_res,
		 i1 => SYNTHESIZED_WIRE_2,
		 o => SYNTHESIZED_WIRE_3);

b2v_mux_mem : mux2x32
PORT MAP(sel => sel_mem,
		 i0 => pc_addr,
		 i1 => rddata,
		 o => SYNTHESIZED_WIRE_2);

b2v_mux_ra : mux2x5
PORT MAP(sel => sel_ra,
		 i0 => instr(26 downto 22),
		 i1 => ra,
		 o => SYNTHESIZED_WIRE_0);

pc_en <= pc_wren OR branch_taken;

b2v_PC_0 : pc
PORT MAP(clk => clk,
		 reset_n => reset_n,
		 en => pc_en,
		 sel_a => pc_sel_a,
		 sel_imm => pc_sel_imm,
		 add_imm => pc_add_imm,
		 a => a(15 downto 0),
		 imm => instr(21 downto 6),
		 addr => pc_addr);

SYNTHESIZED_WIRE_1 <= sel_pc OR sel_mem;

b2v_register_file_0 : register_file
PORT MAP(clk => clk,
		 wren => rf_wren,
		 aa => instr(31 downto 27),
		 ab => instr(26 downto 22),
		 aw => aw,
		 wrdata => SYNTHESIZED_WIRE_3,
		 a => a,
		 b => b);
wrdata <= b;

ra <= "11111";
END; 