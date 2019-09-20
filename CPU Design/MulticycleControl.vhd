library ieee;
use ieee.std_logic_1164.all;

entity MulticycleControl is
         port(Opcodefield:in std_logic_vector(5 downto 0);
              clk : in std_logic ;
              
              NextStateReg :buffer std_logic_vector(3 downto 0);  --다음 상태 Reg
              ALUOP,ALUSrcB :out std_logic_vector(1 downto 0);  --ALUOP, 두 번째 피연산자
              PCWrite,PCWriteCond,IorD,MemWrite,MemRead,IRWrite,Mem2Reg,PCSrc,RegWrite,RegDst,ALUSrcA:out std_logic);
end MulticycleControl;

architecture sample of MulticycleControl is
 

begin
  process (clk)
  begin
   if(clk'event and clk='1') then  --상승 에지에서 동작
		
          
			
            case NextStateReg is
            when "0000" =>  --명령어 인출
            	   ALUSrcA<='1';  --ALU의 첫번째 피연산자는 A 레지스터
				   ALUSrcB<="00";
				   ALUOP<="00";
				   PCSrc<='0';
				   PCWriteCond<='0'; 
				  
				   --나머지 부분 초기화--
				   PCWrite<='0';
				   IorD<='0';
				   MemWrite<='0';
				   MemRead<='0';
				   IRWrite<='1';
				   Mem2Reg<='0';
				   RegWrite<='0';
				   RegDst<='0';
				     
				   NextStateReg<="1111";
				 
			      
               
               when"0001" =>  --명령어 해석 / 레지스터 읽기
                  ALUSrcA<='0';  --ALU의 첫번째 피연산자가 PC
				  ALUSrcB<="11";
				  ALUOP<="00";  --ALU가 덧셈을 수행
				  
				  --나머지 부분 초기화--				  
				  PCWrite<='0';
				  PCWriteCond<='0';
				  IorD<='0';
				  MemWrite<='0';
				  MemRead<='0';
				  IRWrite<='0';
				  Mem2Reg<='0';
				  PCSrc<='0';
				  RegWrite<='0';
				  RegDst<='0';


				   
				    case Opcodefield is
					     when "101011" =>  --store word(sw)
					     NextStateReg <="0010";
					     when "100011" =>  --load word(lw)
					     NextStateReg <="0010";
					     when "000000" =>  --R-format
                         NextStateReg <="0110";
					     when "000100" =>  --branch
					     NextStateReg <="1000";
					     when others =>
					     
					end case;
                when"0010" =>  --메모리 주소 계산
                  ALUSrcA<='1';  --ALU의 첫번째 피연산자는 A 레지스터
				  ALUSrcB<="10";  --ALU의 두번째 피연산자는 부호확장된 IR의 하위 16비트
				  ALUOP<="00";  --ALU 덧셈
				  --나머지 초기화--
				  PCWrite<='0';
				  PCWriteCond<='0';
				  IorD<='0';
				  MemWrite<='0';
				  MemRead<='0';
				  IRWrite<='0';
				  Mem2Reg<='0';
				  PCSrc<='0';
				  RegWrite<='0';
				  RegDst<='0';
				  
			
				  				  
                  case Opcodefield is
			        when "101011"=>  --store
                      NextStateReg <="0101";
				    when "100011"=>  --load
                      NextStateReg <="0011";
				    when others => 
				  end case;

				 when"0011" =>  --Memory 접근
				   MemRead<='1';  --메모리 address 입력에 메모리의 내용이 데이터 출력에 놓여짐
				   IorD<='1';  --ALUOut이 메모리 주소 지정
				   --나머지 초기화--
			       ALUSrcA<='0';
				   ALUSrcB<="00";
				   ALUOP<="00";
				   PCWrite<='0';
				   PCWriteCond<='0';
				   MemWrite<='0';
				   IRWrite<='0';
				   Mem2Reg<='0';
				   PCSrc<='0';
				   RegWrite<='0';
				   RegDst<='0';
				   
				   NextStateReg<="0100";
				
				 when"0100" =>  --쓰기 단계
                   RegWrite<='1';  --reg 파일에 쓰기 실행
                   Mem2Reg<='1';
                   RegDst<='0';
                   --나머지 초기화--
                   MemRead<='0';
				   IorD<='0';
				   ALUSrcA<='0';
				   ALUSrcB<="00";
				   ALUOP<="00";
				   PCWrite<='0';
				   PCWriteCond<='0';
				   MemWrite<='0';
				   IRWrite<='0';
				   PCSrc<='0';
                   
		 
                   
                   NextStateReg<="1111";
                 
                   
				 when "0101" =>  --메모리 접근
				   MemWrite<='1';
				   IorD<='1';  --ALUOut이 메모리주소 지정
				   --나머지 초기화--
				   ALUSrcA<='0';
				   ALUSrcB<="00";
				   ALUOP<="00";
				   PCWrite<='0';
				   PCWriteCond<='0';
				   
				   IRWrite<='0';
				   Mem2Reg<='0';
				   PCSrc<='0';
				   RegWrite<='0';
				   RegDst<='0';
				   MemRead<='0';
				
				   NextStateReg<="1111";
				
				 when "0110" =>  --실행
				   ALUSrcA<='1';  --ALU의 첫 번째 피연산자 -> A reg
				   ALUSrcB<="00"; --ALU의 두 번째 피연산자 -> B reg
				   ALUOP<="10";  --명령어 funct 필드가 ALU 연산 결정
				   --나머지 초기화--
				   PCWrite<='0';
				   PCWriteCond<='0';
				   IorD<='0';
				   MemWrite<='0';
				   MemRead<='0';
				   IRWrite<='0';
				   Mem2Reg<='0';
				   PCSrc<='0';
				   RegWrite<='0';
				   RegDst<='0';
				  
                   NextStateReg<="0111";
                  
				when "0111" =>  --R-format 완료
			       RegWrite<='1';  --reg 파이에 쓰기가 행해짐
                   Mem2Reg<='0';  --reg 쓰기 데이터값이 MDR로부터 옴
                   RegDst<='1';  --목적지 reg번호가 rd 필드에서 옴
                   --나머지 초기화--
                   MemRead<='0';
				   IorD<='0';
				   ALUSrcA<='0';
				   ALUSrcB<="00";
				   ALUOP<="00";
				   PCWrite<='0';
				   PCWriteCond<='0';
				   MemWrite<='0';
				   IRWrite<='0';
				   PCSrc<='0';
				   
                   NextStateReg<="1111";
				 
				 when "1000" =>  --branch 완료
				   ALUSrcA<='1';  --ALU의 첫 번째 피연산자 -> A reg
				   ALUSrcB<="00";  --ALU의 두 번째 피연산자 -> B reg
				   ALUOP<="01";  --ALU가 뺄셈 실행
				   PCSrc<='1';  --ALUOut의 내용이 PC로 전달
				   PCWriteCond<='1';  --ALU의 Zero 출력이 1이면 PC에 씀
				   --나머지 초기화--
				   PCWrite<='0';
				   IorD<='0';
				   MemWrite<='0';
				   MemRead<='0';
				   IRWrite<='0';
				   Mem2Reg<='0';
				   RegWrite<='0';
				   RegDst<='0';
				    
				   NextStateReg<="1111";
				 
			    when others =>  --초기화

			    MemRead<='1';
                  ALUSrcA<='0';
                  IorD<='0';
                  IRWrite<='1';
                  ALUSrcB<="01";
                  ALUOP<="00";
                  PCWrite<='1';
                  PCSrc<='0';
                  NextStateReg<="0001";
                 
                  PCWriteCond<='0';
                  MemWrite<='0';
                  Mem2Reg<='0';
                  RegWrite<='0';
                  RegDst<='0';
                 
			end case;
			
        
   end if;
  end process;
 
end sample;