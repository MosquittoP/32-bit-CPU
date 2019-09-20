32-bit CPU Design

사용 언어 : VHDL(Quartus 2)

총 32개의 register를 가지고 있는 CPU 시뮬레이터입니다. 이론 상으로는 최대 64개 명령어를 사용할 수 있습니다.
입력 변수와 명령어에 따라 연산하는 과정을 볼 수 있습니다.
사용가능한 명령어는 R-type(Add, Sub)과 I-type(Lw, Sw, Beq, Addi)입니다. 각 명령어의 Opcode는 다음과 같습니다.
------------------------------------
Add 000000 (Function 100000)
Sub 000000 (Function 100010)
Lw 100011
Sw 101011
Beq 000100
Addi 001000
------------------------------------
연산에 따른 Control의 구조입니다. RegDst는 data를 저장할 reg를 구별하기 위한 신호입니다.
ALUSrc는 alu를 통하여 계산할 데이터를 구별하기 위한 신호이고, MemtoReg는 reg에 저장할 data를 구별하기 위한 신호입니다.
Regwrite는 reg에 data를 저장할지 구별하기 위한 신호이며, MemRead는 Memory에서 데이터를 읽어올지 구별하기 위한 신호입니다.
MemWrite는 Memory에서 데이터를 저장할지 구별하기 위한 신호이며, ALUOp는 일반적 산술연산의 alu를 사용하는지 구별하기 위한 신호입니다.