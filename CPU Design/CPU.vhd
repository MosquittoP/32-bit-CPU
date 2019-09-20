library ieee;
use ieee.std_logic_1164.all;
library work;

entity CPU is  --CPU 포트 및 구성 정의
		port (Data_in: in std_logic_vector (31 downto 0); 
              Clock: in std_logic;  --클럭
              Data_out: out std_logic_vector (31 downto 0);  --데이터 출력
              MemRead_out: out std_logic;  --지정된 공간의 데이터가 read됨
              MemWrite_out: out std_logic;  --지정된 공간에 데이터를 write함
              Zero: out std_logic;
              ALUAData :buffer std_logic_vector (31 downto 0);  --작업을 수행할 데이터A	
			  ALUBData :buffer std_logic_vector (31 downto 0);  --작업을 수행할 데이터B
              State:buffer std_logic_vector(3 downto 0) ;	
              ID2Ctrl: buffer  std_logic_vector (5 downto 0);
              OUTToPC :buffer std_logic_vector (31 downto 0);  --다음 프로그램 수행 주소를 저장
              IRWrite:buffer std_logic:='1';  --데이터에서 op코드,rs,rt값을 받아서 씀
              ALUCTRLTOALU32 :buffer std_logic_vector (2 downto 0);  --ALU의 동작 제어(ALU에 제어신호 제공)
              LASTOUT :buffer std_logic_vector (31 downto 0);  --연산의 결과를 최종 저장
			  RESULT :buffer std_logic_vector (31 downto 0);
			  ShiftToALU :buffer std_logic_vector (31 downto 0);	
              PCWrite,PCWriteCond,IorD,MemWrite,MemRead,Mem2Reg,PCSrc,RegWrite,RegDst,ALUSrcA :buffer std_logic;
              ALUOP,ALUSrcB :buffer std_logic_vector(1 downto 0);
              ProgramCount :buffer std_logic_vector (31 downto 0);
              Address_out: out std_logic_vector (31 downto 0));
end CPU;

architecture structural of CPU is 

	component ALU32  --ALU 구성 포트
		port  (a,b:in std_logic_vector(31 downto 0);
              operation :in std_logic_vector(2 downto 0);
              zero, overflow :out std_logic;
              result : out std_logic_vector(31 downto 0));
	end component;
	
   component MulticycleControl  --MulticycleControl 구성 포트  
         port(Opcodefield:in std_logic_vector(5 downto 0);
              clk : in std_logic ;
              NextStateReg :buffer std_logic_vector(3 downto 0);
              ALUOP,ALUSrcB :out std_logic_vector(1 downto 0);
              PCWrite,PCWriteCond,IorD,MemWrite,MemRead,IRWrite,Mem2Reg,PCSrc,RegWrite,RegDst,ALUSrcA:out std_logic);
   end component;

	
	component REGISTER_MODULE  --레지스터 모듈 구성 포트
	    port (Clock: in std_logic;
              Register1: in std_logic_vector (4 downto 0);
              Register2: in std_logic_vector (4 downto 0);
              RegisterW: in std_logic_vector (4 downto 0);
              Data_Reg: in std_logic_vector (31 downto 0);
              RegWrite: in std_logic;
              Data1: out std_logic_vector (31 downto 0);
              Data2: out std_logic_vector (31 downto 0));
	end component;
	
	component IR_MODULE  --명령어 레지스터 구성 포트
		port (Clock: in std_logic;
              Data_in: in std_logic_vector (31 downto 0);
              IRWrite: in std_logic;
              Ctrl_out: out std_logic_vector (5 downto 0);
              Register1: out std_logic_vector (4 downto 0);
              Register2: out std_logic_vector (4 downto 0);
              Register3: out std_logic_vector (4 downto 0);
              RegisterW: out std_logic_vector (15 downto 0));
	end component;

component PC_MODULE  --프로그램 카운터 구성 포트
		port (Clock: in std_logic;
              WriteSig :in std_logic;
              Data_in: in std_logic_vector (31 downto 0);
              Data_out: out std_logic_vector (31 downto 0));
end component;

	component MDR_MODULE  --메모리 데이터 레지스터 구성
		port (Clock: in std_logic;
              Data_in: in std_logic_vector (31 downto 0);
              Data_out: out std_logic_vector (31 downto 0));
	end component;
	
	component Sign_extend  --부호확장
		port (
              Clock: in std_logic;
              Data_in: in std_logic_vector (15 downto 0);
              Data_out: out std_logic_vector (31 downto 0));
	end component;

	component Shift_left2  --4배수 증가
		port (
              Clock: in std_logic;
              Data_in: in std_logic_vector (31 downto 0);
              Data_out: out std_logic_vector (31 downto 0));
	end component;

	component ALU_CTRL  --ALU컨트롤(ALU의 동작을 결정)
		port (Clock: in std_logic;
              ALUOP    : in std_logic_vector( 1 downto 0);
              Data_in  : in std_logic_vector (15 downto 0);
              Data_out : out std_logic_vector (2 downto 0));
	end component;




signal MD2REG:  std_logic_vector (31 downto 0);
signal REG1,REG2,REG3,REGW:  std_logic_vector (4 downto 0);
signal IRToSignORALU:  std_logic_vector (15 downto 0);
signal AData: std_logic_vector (31 downto 0);
signal BData: std_logic_vector (31 downto 0);
signal OUTorMDRtoREG: std_logic_vector (31 downto 0);
signal SignToALU : std_logic_vector (31 downto 0);	
signal SignToShift : std_logic_vector (31 downto 0);	

signal reresult : std_logic_vector (31 downto 0);	
	
signal zeroBit, overflowBit,WritePC :std_logic;



	begin
		
		
		CTRL: MulticycleControl port map (ID2Ctrl,clock, State,ALUOP,ALUSrcB,PCWrite,PCWriteCond,IorD,MemWrite,MemRead,IRWrite,Mem2Reg,PCSrc,RegWrite,RegDst,ALUSrcA);
		IR : IR_MODULE port map(Clock,Data_in,IRWrite,ID2Ctrl,REG1,REG2,REG3,IRToSignORALU);
	   	MDR : MDR_MODULE port map(Clock,Data_in,MD2REG);
        REG : REGISTER_MODULE port map(Clock,REG1,REG2,REGW,OUTorMDRtoREG,RegWrite,AData,BData);
        ALUCTL : ALU_CTRL port map (Clock,ALUOP,IRToSignORALU,ALUCTRLTOALU32);
		Sign_ex : Sign_extend port map(Clock,IRToSignORALU,SignToALU);
		Shift_le : Shift_left2  port map(Clock,SignToALU,ShiftToALU);
		ALU : ALU32 port map(ALUAData,ALUBData,ALUCTRLTOALU32,zeroBit, overflowBit,RESULT);
		PC :PC_MODULE port map(Clock,WritePC,OUTToPC,ProgramCount);
		
		MemRead_out<=MemRead;
        Zero<=zeroBit;
        
       
        
        
		process(Clock,RESULT)
		variable temp : std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
		begin
		
		if (Clock'event and (Clock ='1')  and not(temp = RESULT) )then 
		LASTOUT<=RESULT;
		temp := RESULT;
		end if;
		
		
		
		
	   		
		case ALUSrcA is
		when '0'=> ALUAData<=ProgramCount;
		when '1'=> ALUAData<=AData;
		end case;
		
		
		case ALUSrcB is
		when "00"=> ALUBData<=BData;
		when "01"=> ALUBData<="00000000000000000000000000000100";
		when "10"=> ALUBData<=SignToALU;
		when "11"=> ALUBData<=ShiftToALU;
		end case;
		
		case PCSrc is
		when '0'=> OUTToPC<=RESULT;  --nextPC=현재PC+4
		when '1'=> OUTToPC<=LASTOUT;  --nextPC=계산된 branch대상
		end case;
		
	
		
		case IorD is
		when '0'=> Address_out<=ProgramCount;
		when '1'=> Address_out<=LASTOUT;
		end case;
		
		case MemWrite is  --주소에 의해 지정된 메모리공간에 데이터를 씀
		when '1'=> Data_out<=BData;
		MemWrite_out<=MemWrite;
		when others => 
		MemWrite_out<=MemWrite;
		
		end case;
	

        if(PCWrite ='1'or (PCWriteCond ='1' and zeroBit='1')) then
		   WritePC<='1';
		   
		else 
		WritePC<='0';
		end if;
		
		case Mem2Reg is
		when '1'=> OUTorMDRtoREG<=MD2REG;
		when others => 
		OUTorMDRtoREG<=LASTOUT;
		end case;
		
		
			case RegDst is
		when '1'=> REGW<=REG3;
		when others => 
		REGW<=REG2;
		end case;
		
	
		end process;


		
	
end structural;

