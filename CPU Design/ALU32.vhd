library ieee;
use ieee.std_logic_1164.all;

entity ALU is  --ALU port 정의
         port(a,b,Binvert,carryin,less:in std_logic;
              operation :in std_logic_vector(1 downto 0);
              result, carryout :out std_logic );
end ALU;
 architecture sample of ALU is  --작동신호 및 operation값에 따른 동작분류
signal temp :std_logic;
  begin 
      
      process(Binvert,operation)
        begin
       case Binvert is  --case를 사용하여 작동신호 분류
          when'0'=> temp<= b;
          when'1'=> temp<=not(b);
       end case;
        case operation is  --case를 사용하여 operation동작분류
				when "00" => 
                  result <= a and temp;
                when "01" =>
				  result <= a or temp;
                when "10" =>
                  result <= a xor temp xor carryin;
				when "11" =>
				  result <= less; 
			end case;  --carryout 입력
			carryout <= (a and temp) or ( a and carryin ) or ( temp and carryin);
	
				
        
     end process;
end sample;



library ieee;
use ieee.std_logic_1164.all;

entity ALU_MSB is  --ALU_MSB port 정의
         port(a,b,Binvert,carryin,less:in std_logic;
              operation :in std_logic_vector(1 downto 0);
              result, overflow, set :out std_logic );
end ALU_MSB;
 architecture sample of ALU_MSB is
signal temp :std_logic;
signal re :std_logic;
  begin  --Binvert과 operation 따른 연산 수행
      
      process(Binvert,operation)
        begin
       case Binvert is  --Binvert 따른 상태 선택
          when'0'=> temp<= b;
          when'1'=> temp<=not(b);
       end case;
       re <= a xor temp xor carryin;
        case operation is  --operation 따른 and, or, 출력, 종료 수행
				when "00" => 
                  result <= a and temp;
                when "01" =>
				  result <= a or temp;
                when "10" =>
                  result <= re;
				when "11" =>
				  result <= less; 
			end case;
			
			set <= a xor temp xor carryin;
			
			overflow <= (Binvert and a and not(b) and not(re)) or
			            (not(Binvert) and not(a) and not(b) and re) or
			            (Binvert and not(a) and b and re) or
			            (not(Binvert) and a and b and not(re)) ; 

	       
				
        
     end process;
end sample;


library ieee;
use ieee.std_logic_1164.all;

package mypkg is  --mypkg package 및 component 작업

    component ALU  --ALU port
         port(a,b,Binvert,carryin,less:in std_logic;
              operation :in std_logic_vector(1 downto 0);
              result, carryout :out std_logic );
    end component;

    component ALU_MSB  --ALU_MSB port
         port(a,b,Binvert,carryin,less:in std_logic;
              operation :in std_logic_vector(1 downto 0);
              result, overflow, set :out std_logic );
    end component;
end mypkg;

library ieee;
use ieee.std_logic_1164.all;
library work;
use work.mypkg.all;

entity ALU32 is  --32비트 ALU port정의
         port(
              a,b:in std_logic_vector(31 downto 0);
              operation :in std_logic_vector(2 downto 0);
              zero, overflow :out std_logic;
              result : out std_logic_vector(31 downto 0));
end ALU32;

architecture sample of ALU32 is
signal set1 : std_logic:='0';
signal zer : std_logic:='0';
signal overflow1 : std_logic:='0';
signal carry_out : std_logic_vector(31 downto 0);
signal RESULT_BUFF : std_logic_vector(31 downto 0);

begin  --버퍼 관리 모듈

    ALU_MSB1 :  ALU_MSB port map(a(31),b(31),operation(2),carry_out(30),'0',operation(1 downto 0),RESULT_BUFF(31),overflow1,set1);
    result(31)<=RESULT_BUFF(31);
 
    CASCASE :
     for I in 30 downto 1 generate 
       ALU2 : ALU port map(a(I),b(I),operation(2),carry_out(I-1),'0',operation(1 downto 0),RESULT_BUFF(I),carry_out(I));
      result(I)<=RESULT_BUFF(I);
 
    end generate CASCASE;
        
    ALU1 : ALU port map(a(0),b(0),operation(2),operation(2),set1,operation(1 downto 0),RESULT_BUFF(0),carry_out(0));
    result(0)<=RESULT_BUFF(0);  --버퍼 및 오버플로우 세팅
    
	zero<=NOT(RESULT_BUFF(0)or RESULT_BUFF(1)or RESULT_BUFF(2)or RESULT_BUFF(3)or RESULT_BUFF(4)or RESULT_BUFF(5)or 
    RESULT_BUFF(6)or RESULT_BUFF(7)or RESULT_BUFF(8)or RESULT_BUFF(9)or RESULT_BUFF(10)or RESULT_BUFF(11)or RESULT_BUFF(12)or 
    RESULT_BUFF(13)or RESULT_BUFF(14)or RESULT_BUFF(15)or RESULT_BUFF(16)or RESULT_BUFF(17)or RESULT_BUFF(18)or RESULT_BUFF(19)or 
    RESULT_BUFF(20)or RESULT_BUFF(21)or RESULT_BUFF(22)or RESULT_BUFF(23)or RESULT_BUFF(24)or RESULT_BUFF(25)or RESULT_BUFF(26)or 
    RESULT_BUFF(27)or RESULT_BUFF(28)or RESULT_BUFF(29)or RESULT_BUFF(30)or RESULT_BUFF(31) );
    overflow <= overflow1;  --버퍼 및 오버플로우 입력
   
end sample;