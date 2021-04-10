#  实验报告

计算机科学与技术

19307130296

孙若诗

## 1、新增指令

### 1.1 R型指令

R-type = op(6) + rs(5) + rt(5) + rd(5) + shamt(5) + funct(6)

* mfhi : GPR[rd] = HI
* mflo : GPR[rd] = LO
* mthi : HI = GPR[rs]
* mtlo : LO = GPR[rs]
* mult : (HI, LO) = GPR[rs] * GPR[rt] (signed)
* multu : (HI, LO) = GPR[rs] * GPR[rt] (unsigned)
* div : (HI, LO) = GPR[rs] / GPR[rt] (signed)
* divu : (HI, LO) = GPR[rs] / GPR[rt] (unsigned)
* sllv : GPR[rd] = GPR[rt] << GPR[rs][4:0] (logical)
* srav : GPR[rd] = GPR[rt] >> GPR[rs][4:0] (arithmetic)
* srlv : GPR[rd] = GPR[rt] >> GPR[rs][4:0] (logical)
* jalr: GPR[rd] = pc + 8, pc = GPR[rs]

### 1.2 I型指令

I-type = op(6) + rs(5) + rt(5) + imm(16)

* bgtz : if(GPR[rs] > 0)  pc += 4 + imm << 2
* blez : if(GPR[rs] <= 0)  pc += 4 + imm << 2
* bgez : if(GPR[rs] >= 0)  pc += 4 + imm << 2
* bgezal : if(GPR[rs] >= 0)  GPR[31] = pc + 8, pc += 4 + imm << 2
* bltz : if(GPR[rs] < 0)  pc += 4 + imm << 2
* bltzal : if(GPR[rs] < 0)  GPR[31] = pc + 8, pc += 4 + imm << 2
* lb : GPR[rt] = sign_ext((byte)mem[GPR[rs] + offset])
* lbu : GPR[rt] = zero_ext((byte)mem[GPR[rs] + offset])
* lh : GPR[rt] = sign_ext((halfword)mem[GPR[rs] + offset])
* lhu: GPR[rt] = zero_ext((halfword)mem[GPR[rs] + offset])
* sb : mem[GPR[rs] + offset] = (byte)GPR[rt]
* sh : mem[GPR[rs] + offset] = (halfword)GPR[rt]
