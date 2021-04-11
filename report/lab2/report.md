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

### 2、修改记录

1. icode.svh：增加了新增指令的编码。
2. fetch阶段： 增加了对新跳转指令的支持。
3. decode阶段：将控制信号增加2位记录内存读写粒度，增加1位记录读内存符号扩展，增加4位记录HILO读写。增加对新增分支指令的判断。处理寄存器值作为shamt的情况。
4. execute阶段：增加mult乘除法器。
5. memory阶段：增加mem_input、mem_extension模块，分别处理不同粒度的内存读写。
6. writeback阶段：增加hi、lo以及由hilo到寄存器的写逻辑。
7. hazard：增加内存延迟的阻塞。增加对hi、lo的转发。
8. VTop：加入地址翻译。
9. Mycore：针对上述修改增加数据通路。增加hilo用于读写hi、lo寄存器。

### 3、测试照片

### 4、ToDo

1. 多周期乘除法器
2. 修改数据通路，用结构体规整数据传递格式
3. 仲裁器
4. 在CPU上运行程序
