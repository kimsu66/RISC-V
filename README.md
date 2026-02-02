# Design of Single-Cycle RISC-V Processor

본 파일은 다음과 같이 구성되어 있으며, 그림 1과 같은 구조를 가진다.

| 모듈명              | 역할             | 비고            |
| ---------------- | -------------- | ------------- |
| `riscv_top.v`    | Top Module     | 전체 회로 연결 및 제어 |
| `mem_instr.v`    | Program Memory | 읽기 전용         |
| `regfile.v`      | Register File  | 읽기 / 쓰기 가능    |
| `mem_data.v`     | Data Memory    | 읽기 / 쓰기 가능    |
| `tb_riscv_top.v` | Test Bench     | 회로 동작 검증용     |


