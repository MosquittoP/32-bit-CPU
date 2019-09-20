library ieee;
use ieee.std_logic_1164.all;

entity MulticycleControl is
         port(Opcodefield:in std_logic_vector(5 downto 0);
              clk : in std_logic ;
              
              NextStateReg :buffer std_logic_vector(3 downto 0);  --���� ���� Reg
              ALUOP,ALUSrcB :out std_logic_vector(1 downto 0);  --ALUOP, �� ��° �ǿ�����
              PCWrite,PCWriteCond,IorD,MemWrite,MemRead,IRWrite,Mem2Reg,PCSrc,RegWrite,RegDst,ALUSrcA:out std_logic);
end MulticycleControl;

architecture sample of MulticycleControl is
 

begin
  process (clk)
  begin
   if(clk'event and clk='1') then  --��� �������� ����
		
          
			
            case NextStateReg is
            when "0000" =>  --��ɾ� ����
            	   ALUSrcA<='1';  --ALU�� ù��° �ǿ����ڴ� A ��������
				   ALUSrcB<="00";
				   ALUOP<="00";
				   PCSrc<='0';
				   PCWriteCond<='0'; 
				  
				   --������ �κ� �ʱ�ȭ--
				   PCWrite<='0';
				   IorD<='0';
				   MemWrite<='0';
				   MemRead<='0';
				   IRWrite<='1';
				   Mem2Reg<='0';
				   RegWrite<='0';
				   RegDst<='0';
				     
				   NextStateReg<="1111";
				 
			      
               
               when"0001" =>  --��ɾ� �ؼ� / �������� �б�
                  ALUSrcA<='0';  --ALU�� ù��° �ǿ����ڰ� PC
				  ALUSrcB<="11";
				  ALUOP<="00";  --ALU�� ������ ����
				  
				  --������ �κ� �ʱ�ȭ--				  
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
                when"0010" =>  --�޸� �ּ� ���
                  ALUSrcA<='1';  --ALU�� ù��° �ǿ����ڴ� A ��������
				  ALUSrcB<="10";  --ALU�� �ι�° �ǿ����ڴ� ��ȣȮ��� IR�� ���� 16��Ʈ
				  ALUOP<="00";  --ALU ����
				  --������ �ʱ�ȭ--
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

				 when"0011" =>  --Memory ����
				   MemRead<='1';  --�޸� address �Է¿� �޸��� ������ ������ ��¿� ������
				   IorD<='1';  --ALUOut�� �޸� �ּ� ����
				   --������ �ʱ�ȭ--
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
				
				 when"0100" =>  --���� �ܰ�
                   RegWrite<='1';  --reg ���Ͽ� ���� ����
                   Mem2Reg<='1';
                   RegDst<='0';
                   --������ �ʱ�ȭ--
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
                 
                   
				 when "0101" =>  --�޸� ����
				   MemWrite<='1';
				   IorD<='1';  --ALUOut�� �޸��ּ� ����
				   --������ �ʱ�ȭ--
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
				
				 when "0110" =>  --����
				   ALUSrcA<='1';  --ALU�� ù ��° �ǿ����� -> A reg
				   ALUSrcB<="00"; --ALU�� �� ��° �ǿ����� -> B reg
				   ALUOP<="10";  --��ɾ� funct �ʵ尡 ALU ���� ����
				   --������ �ʱ�ȭ--
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
                  
				when "0111" =>  --R-format �Ϸ�
			       RegWrite<='1';  --reg ���̿� ���Ⱑ ������
                   Mem2Reg<='0';  --reg ���� �����Ͱ��� MDR�κ��� ��
                   RegDst<='1';  --������ reg��ȣ�� rd �ʵ忡�� ��
                   --������ �ʱ�ȭ--
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
				 
				 when "1000" =>  --branch �Ϸ�
				   ALUSrcA<='1';  --ALU�� ù ��° �ǿ����� -> A reg
				   ALUSrcB<="00";  --ALU�� �� ��° �ǿ����� -> B reg
				   ALUOP<="01";  --ALU�� ���� ����
				   PCSrc<='1';  --ALUOut�� ������ PC�� ����
				   PCWriteCond<='1';  --ALU�� Zero ����� 1�̸� PC�� ��
				   --������ �ʱ�ȭ--
				   PCWrite<='0';
				   IorD<='0';
				   MemWrite<='0';
				   MemRead<='0';
				   IRWrite<='0';
				   Mem2Reg<='0';
				   RegWrite<='0';
				   RegDst<='0';
				    
				   NextStateReg<="1111";
				 
			    when others =>  --�ʱ�ȭ

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