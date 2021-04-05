#  实验报告

计算机科学与技术

19307130296

孙若诗

## 1、新增指令

### 1.1 R型指令

R-type = op(6) + rs(5) + rt(5) + rd(5) + shamt(5) + funct(6)



### 1.2 I型指令

I-type = op(6) + rs/base(5) + rt/func(5) + imm(16)

* bgtz : if(GPR[rs] > 0)  pc += 4 + imm << 2
* blez : if(GPR[rs] <= 0)  pc += 4 + imm << 2
* bgez : if(GPR[rs] >= 0)  pc += 4 + imm << 2
* bgezal : if(GPR[rs] >= 0)  GPR[31] = pc + 8, pc += 4 + imm << 2
* bltz : if(GPR[rs] < 0)  pc += 4 + imm << 2
* bltzal : if(GPR[rs] < 0)  GPR[31] = pc + 8, pc += 4 + imm << 2
* lb : GPR[rt] = mem[GPR[base] + offset]


### 1.3 J型指令

J-type = op(6) + instr_index(26)


lb lbu lh lhu jalr 

sllv srav srlv

sb sh

div divu

mfhi mflo mthi mtlo mult multu
