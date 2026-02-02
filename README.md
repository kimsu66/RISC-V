# Design of Single-Cycle RISC-V Processor

본 파일은 다음과 같이 구성되어 있으며, 그림 1과 같은 구조를 가진다.

| 모듈명              | 역할             | 비고            |
| ---------------- | -------------- | ------------- |
| `riscv_top.v`    | Top Module     | 전체 회로 연결 및 제어 |
| `mem_instr.v`    | Program Memory | 읽기 전용         |
| `regfile.v`      | Register File  | 읽기 / 쓰기 가능    |
| `mem_data.v`     | Data Memory    | 읽기 / 쓰기 가능    |
| `tb_riscv_top.v` | Test Bench     | 회로 동작 검증용     |


<img width="1215" height="645" alt="Image" src="https://github.com/user-attachments/assets/5c061587-8c88-4e09-959f-b835f6aa14ef" />

그림 1. RISC-V Block Diagram



<img width="1190" height="279" alt="Image" src="https://github.com/user-attachments/assets/34f4b4e4-0285-4f22-a7ba-27c49b9b74a0" />

그림 2. 각 모듈의 Input, Output



## 파일 설명

### 1. mem_instr.v
0x00~0x3FC의 주소를 가지는 1Kbyte (32bit×256) 읽기 전용 메모리이다.  
10bit address(addr)를 입력으로 받아, 해당하는 주소의 32bit 명령어(instr)를 즉시 출력한다.


### 2. mem_data.v
0x00~0x3FC의 주소를 가지는 1Kbyte (32bit×256) 읽기/쓰기 메모리이다.  
cen에 low를 입력하여 메모리를 enable하게 한 뒤 사용한다.  
10bit address(addr)를 입력으로 받아, 해당 주소에 저장되어 있던 데이터(rdata)를 즉시 출력한다.  
wen에 low를 입력하고 addr를 입력하면 32bit wdata를 해당하는 주소에 다음 clock rising edge에 저장한다.


### 3. regfile.v
32개의 32bit 길이 레지스터로 이루어져 있다.  
5bit rs1, rs2를 입력받아 32bit 데이터 rs1_data, rs2_data를 즉시 출력한다.  
reg_wen에 low를 입력하고 5bit rd를 입력하면 32bit rd_data를 해당하는 주소에 다음 clock rising edge에 저장한다.


### 4. memfile.dat
RISC-V 명령어가 Little Endian 형식의 HEX Code로 들어있는 파일이며, 메모장을 통해 확인할 수 있다.  
ModelSim 시뮬레이션 시 프로젝트를 생성한 폴더 내에 넣어 놓으면 mem_instr 모듈에서 읽어서 시뮬레이션 할 수 있다.


### 5. riscv_cpu_.v
ALU 및 Control Logic을 포함하며, add 및 addi 명령어를 수행할 수 있는 RISC-V 코어이다.


### 6. riscv_top.v
입력은 clk, reset_n 두 가지이며, 출력은 없다.


### 7. tb_riscv_top.v
top 모듈의 테스트벤치 파일이다.
