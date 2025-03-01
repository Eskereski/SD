library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity datapath is
	Port(
		CLK : in  STD_LOGIC;
		RESET : in  STD_LOGIC;
		
		incPC : in  STD_LOGIC;
		cargaPC : in  STD_LOGIC;
		cargaREM : in  STD_LOGIC;
		cargaAC : in  STD_LOGIC;
		cargaRI : in  STD_LOGIC;
		cargaRDM : in  STD_LOGIC;
		cargaN : in  STD_LOGIC;
      	cargaZ : in  STD_LOGIC;
      	cargaV : in  STD_LOGIC;
      	cargaC : in  STD_LOGIC;
      	cargaB : in  STD_LOGIC;
		
		selULA : in  STD_LOGIC_VECTOR(3 downto 0);
		selMUXREM : in  STD_LOGIC;
		selMUXRDM : in  STD_LOGIC;
		WR : in  STD_LOGIC_VECTOR(0 downto 0);
		
		regN : out  STD_LOGIC := '0';
		regZ : out  STD_LOGIC := '0';
		regV : out  STD_LOGIC := '0';
		regC : out  STD_LOGIC := '0';
		regB : out  STD_LOGIC := '0';

		regriDECOD : out STD_LOGIC_VECTOR(23 downto 0);
		memOUT : out STD_LOGIC_VECTOR(7 downto 0)
	);		
end datapath;

architecture Behavioral of datapath is

	COMPONENT memoria
	PORT (
		clka : IN STD_LOGIC;
		wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
		addra : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END COMPONENT;
	--Registradores
	signal regPC : STD_LOGIC_VECTOR(7 downto 0);
	signal regAC : STD_LOGIC_VECTOR(7 downto 0);
	signal regRI : STD_LOGIC_VECTOR(7 downto 0);
	signal regMEM : STD_LOGIC_VECTOR(7 downto 0);
	signal regREM : STD_LOGIC_VECTOR(7 downto 0);
	signal regRDM : STD_LOGIC_VECTOR(7 downto 0);
	signal regMUXREM: STD_LOGIC_VECTOR(7 downto 0);
	signal regMUXRDM : STD_LOGIC_VECTOR(7 downto 0);
	--ULA
	signal XULA : STD_LOGIC_VECTOR(7 downto 0);
	signal YULA : STD_LOGIC_VECTOR(7 downto 0);
	signal regULA : STD_LOGIC_VECTOR(7 downto 0);
	signal opULA : STD_LOGIC_VECTOR(8 downto 0);
	-- Flags
	signal flagN : STD_LOGIC;
	signal flagZ : STD_LOGIC;
	signal flagV : STD_LOGIC;
	signal flagC : STD_LOGIC;
	signal flagB : STD_LOGIC;

begin
	mem : memoria
	PORT MAP (
		clka => CLK,
		wea => WR,
		addra => regREM,
		dina => regRDM,
		douta => REGmem
	);	

	process(CLK, RESET)								--PC
		begin
			if(RESET = '1') then
				regPC <= "00000000";
			else
				if(rising_edge(CLK)) then
					if(cargaPC = '1') then
						regPC <= regRDM;
					elsif(incPC = '1') then
						regPC <= std_logic_vector(unsigned((regPC) + 1));
					end if;
				end if;
			end if;
	end process;

	process(CLK, RESET, regAC)								--AC
		begin
			XULA <= regAC;
			if(RESET = '1') then
				regAC <= "00000000";
			elsif(rising_edge(clk)) then
				if(cargaAC = '1') then
					regAC <= regULA;
				end if;
			end if;
	end process;
	
	process(CLK, RESET, regRDM)								--RDM
		begin
			YULA <= regRDM;
			if(RESET = '1') then
				regRDM <= "00000000";
			elsif(rising_edge(CLK)) then
				if(cargaRDM = '1') then
					regRDM <= regMUXRDM;
				end if;
			end if;
	end process;

	process(selMUXRDM, regMEM, regAC)				--MUX RDM
		begin
			memOUT <= regMEM;											
			if(selMUXRDM = '1') then
				regMUXRDM <= regAC;
			else
				regMUXRDM <= regMEM;
			end if;
	end process;

	process(CLK, RESET)								--REM
		begin
			if(RESET = '1') then
				regREM <= "00000000";
			elsif(rising_edge(CLK)) then
				if(cargaREM = '1') then
					regREM <= regMUXREM;
				end if;
			end if;
	end process;

	process(selMUXREM, regRDM, regPC)				--MUX REM
		begin
			if(selMUXREM = '1') then
				regMUXREM <= regRDM;
			else
				regMUXREM <= regPC;
			end if;
	end process;

	process(RESET,CLK, cargaN)						--regN
		begin	
			if(RESET = '1') then
				regN <= '0';
			elsif(rising_edge(CLK)) then
				if(cargaN = '1') then
					regN <= flagN;
				end if;
			end if;
	end process;

	process(RESET,CLK, cargaZ)						--regZ
		begin	
			if(RESET = '1') then
				regZ <= '0';
			elsif(rising_edge(CLK)) then
				if(cargaZ = '1') then
					regZ <= flagZ;
				end if;
			end if;
	end process;

	process(RESET,CLK, cargaV)						--regV
		begin	
			if(RESET = '1') then
				regV <= '0';
			elsif(rising_edge(CLK)) then
				if(cargaV = '1') then
					regV <= flagV;
				end if;
			end if;
	end process;

	process(RESET,CLK, cargaC)						--regC
		begin
			if(RESET = '1') then
				regC <= '0';
			elsif(rising_edge(CLK)) then
				if(cargaC = '1') then
					regC <= flagC;
				end if;
			end if;
	end process;

	process(RESET,CLK, cargaB)						--regB
		begin	
			if(RESET = '1') then
				regB <= '0';
			elsif(rising_edge(CLK)) then
				if(cargaB = '1') then
					regB <= flagB;
				end if;
			end if;

	end process;

	process(RESET,regRI)							--riDECOD
		begin
			regriDECOD <= "000000000000000000000000";
			if(RESET = '1') then
				regriDECOD <= "000000000000000000000000";
			else
				case regRI is 
					when "00000000" => regriDECOD <= "000000000000000000000001";	--NOP(0)
					when "00010000" => regriDECOD <= "000000000000000000000010";	--STA(1)
					when "00100000" => regriDECOD <= "000000000000000000000100";	--LDA(2)
					when "00110000" => regriDECOD <= "000000000000000000001000";	--ADD(3)
					when "01000000" => regriDECOD <= "000000000000000000010000";	--OR(4)
					when "01010000" => regriDECOD <= "000000000000000000100000";	--AND(5)
					when "01100000" => regriDECOD <= "000000000000000001000000";	--NOT(6)
					when "01110000" => regriDECOD <= "000000000000000010000000";	--SUB(7)
					when "10000000" => regriDECOD <= "000000000000000100000000";	--JMP(8)
					when "10010000" => regriDECOD <= "000000000000001000000000";	--JN(9)
					when "10010100" => regriDECOD <= "000000000000010000000000";	--JP(10)
					when "10011000" => regriDECOD <= "000000000000100000000000";	--JV(11)
					when "10011100" => regriDECOD <= "000000000001000000000000";	--JNV(12)
					when "10100000" => regriDECOD <= "000000000010000000000000";	--JZ(13)
					when "10100100" => regriDECOD <= "000000000100000000000000";	--JNZ(14)
					when "10110000" => regriDECOD <= "000000001000000000000000";	--JC(15)
					when "10110100" => regriDECOD <= "000000010000000000000000";	--JNC(16)
					when "10111000" => regriDECOD <= "000000100000000000000000";	--JB(17)
					when "10111100" => regriDECOD <= "000001000000000000000000";	--JNB(18)
					when "11100000" => regriDECOD <= "000010000000000000000000";	--SHR(19)
					when "11100001" => regriDECOD <= "000100000000000000000000";	--SHL(20)
					when "11100010" => regriDECOD <= "001000000000000000000000";	--ROR(21)
					when "11100011" => regriDECOD <= "010000000000000000000000";	--ROL(22)
                    when "11110000" => regriDECOD <= "100000000000000000000000";	--HLT(23)
                    when others => regriDECOD <= "100000000000000000000000";  -- HLT
				end case;
			end if;
	end process;
			
	process(selULA, XULA, YULA, opULA, flagC)		--ULA
		begin
			regULA <= std_logic_vector(unsigned(opULA(7 downto 0)));
			flagC <= '0';
			flagV <= '0';
			flagB <= '0';
			flagN <= opULA(7);						-- Atualiza os signals das flags
			if(opULA(7 downto 0) = "00000000") then
				flagZ <= '1';
			else
				flagZ <= '0';
			end if;

			case selULA is
				when "0000" => 														--LDA
					opULA <= ('0' & (STD_LOGIC_VECTOR(YULA)));

				when "0001" =>														--ADD
					opULA <= std_logic_vector(unsigned('0' & XULA) + unsigned('0' & YULA));
					if(XULA(7) = YULA(7) and opULA(7) /= XULA(7)) then	--atualiza a flag V
						flagV <= '1';
					else
						flagV <= '0';
					end if;
					flagC <= opULA(8);
					
				when "0010" => 														--OR
					opULA <= ('0' & (STD_LOGIC_VECTOR(XULA OR YULA)));
					
				when "0011" =>														--AND
					opULA <= ('0' & (STD_LOGIC_VECTOR((XULA AND YULA))));
					
				when "0100" =>														--NOT
					opULA <= ('0' & (STD_LOGIC_VECTOR((NOT XULA))));
					
				when "0101" => 														--SUB
					opULA <= std_logic_vector(unsigned('0' & XULA) + unsigned('1' & (NOT(YULA) + 1)));
					if(XULA(7) /= YULA(7) and opULA(7) /= XULA(7)) then	--Atualiza flagV
						flagV <= '1';
					else
						flagV <= '0';
					end if;
					flagb <= opULA(8);

				when "0110" => 														--SHR
					opULA(0) <= XULA(1);
					opULA(1) <= XULA(2);
					opULA(2) <= XULA(3);
					opULA(3) <= XULA(4);
					opULA(4) <= XULA(5);
					opULA(5) <= XULA(6);
					opULA(6) <= XULA(7);
					opULA(7) <= '0';
					opULA(8) <= XULA(0);
					flagC <= opULA(8);

				when "0111" => 														--SHL
					opULA(7) <= XULA (6);
					opULA(6) <= XULA (5);
					opULA(5) <= XULA (4);
					opULA(4) <= XULA (3);
					opULA(3) <= XULA (2);
					opULA(2) <= XULA (1);
					opULA(1) <= XULA (0);
					opULA(0) <= '0';		
					opULA(8) <= XULA(7);
					flagC <= opULA(8);

				when "1000" => 														--ROR
					opULA(0) <= XULA(1);
					opULA(1) <= XULA(2);
					opULA(2) <= XULA(3);
					opULA(3) <= XULA(4);
					opULA(4) <= XULA(5);
					opULA(5) <= XULA(6);
					opULA(6) <= XULA(7);
					opULA(7) <= flagC;
					opULA(8) <= XULA(0);
					flagC <= opULA(8);

				when "1001" => 														--ROL
					opULA(7) <= XULA (6);
					opULA(6) <= XULA (5);
					opULA(5) <= XULA (4);
					opULA(4) <= XULA (3);
					opULA(3) <= XULA (2);
					opULA(2) <= XULA (1);
					opULA(1) <= XULA (0);
					opULA(0) <= flagC;		
					opULA(8) <= XULA(7);
					flagC <= opULA(8);

				when others =>
					opULA <= "XXXXXXXXX";

			end case;
	end process;
			
	process(clk, RESET)								--RI
		begin
			if(RESET = '1') then
				regRI <= "00000000";
			elsif(rising_edge(CLK)) then
				if (cargaRI = '1') then
					regRI <= regRDM;
				end if;
			end if;

	end process;
end Behavioral;

