# 实验报告

计算机科学与技术

19307130296

孙若诗

## 1、增加指令

### 1.1 R型指令

R-type = op(6) + rs(5) + rt(5) + rd(5) + shamt(5) + funct(6)

* add : GPR[rd] = GPR[rs] + GPR[rt]
* sub : GPR[rd] = GPR[rs] - GPR[rt]
* break
* syscall

### 1.2 I型指令

I-type = op(6) + rs(5) + rt(5) + imm(16) /

​			  op(6) + funct(5) + rt(5) + rd(5) + special(8) + sel(3) /

​              op(6) + co(1) + special(19) + funct(6)

* addi ： GPR[rt] = GPR[rs] + sign_ext(imm)
* mfc0 ：GPR[rt] = CPR[0, rd, sel]
* mtc0 ：CPR[0, rd, sel] = GPR[rt]
* eret

## 2、处理细节

1. 使用`cp0`模块维护`cp0`寄存器，类似寄存器文件，在D阶段读，M阶段写，接入的error信号和M阶段保持一致。
2. 将`VTop`中的`ext_int`信号接入`MyCore`，在`cp0`模块使用。
3. 设置一个12位`error`信号在流水段之间传递，表示异常相关信号，分别为`CpWrite`、`CpRead`、`Insolt`、`CheckOver`、`OverError`、`AddrErrorI`、`AddrErrorL`、`AddrErrorS`、`InsEret`、`InsBreak`、`InsSyscall`、`InsExcept`。实际上功能和性质均与控制信号类似，但是为了减少对代码的改动不再调整`control`信号。
4. `CpRead`、`CpWrite`分别表示是否读写`cp0`寄存器，从D阶段生成，在M和W阶段使用。
5. `Insolt`信号表示此指令是否在内存槽中，从F阶段生成，逐级传递到M阶段`cp0`模块使用。
6. 溢出：对需要考虑溢出的加法和减法，在`DECODE`阶段设置`CheckOver`为1，并对`ALU`增加一个输出信号`over`表示是否溢出，`OverError = over & CheckOver`传递到`cp0`模块统一处理。
7. 读地址错和写地址错：在`FETCH`、`MEMORY`阶段检查地址后2位，若地址错误则设置`AddrError`为1，`BadVaddr`为出错地址，在`cp0`模块处理。
8. `break`、`syscall`和保留指令：在`DECODE`阶段设置`InsBreak`、`InsSyscall`、`InsExcept`，作为`error`信号的一部分，传递到`cp0`模块处理。
9. 外部中断：将`ext_int`接入`cp0`模块处理。
10. 时钟中断：根据`Compare`和`Count`判断，在`cp0`模块处理。
11. 软件中断：根据`Cause.IP`判断，在`cp0`模块处理。
12. 异常处理具体工作有：
    1. 清空流水线，把下一条指令设为`0xbfc00380`；
    2. 将异常原因生成`exccode`写入`Cause.ExcCode`；
    3. 若为地址错异常，将出错的地址写入`BadVAddr`；
    4. 若`cp0.Status.EXL`为0，设置`p0.EPC`和`cp0.Cause.BD`；
    5. 将`cp0.Status.EXL`设置为1。
13. `eret`：执行到M阶段时，清空流水线，将下一条指令`PC`设为`EPC`，`EPC`设为0。

## 讨论

1. 加减法溢出时，结果转发的逻辑可保持不变：在M阶段溢出异常就被处理，之后用到转发结果的指令一定会被冲刷，不产生影响。

