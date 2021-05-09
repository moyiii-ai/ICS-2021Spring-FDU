# 实验报告

计算机科学与技术

19307130296

孙若诗

## 缓存描述

1. 本实验实现了写分配、回写的四路缓存。
2. tag为26位，index为2位，offset为4位，因此缓存中共有4个cache set，每个cache set有4条cache line。每条cache line存储4条指令，也即4字、16字节、128位，地址3-2位表示指令在cache line中的偏移量。
3. 替换策略为随机替换。处于效率和便于检验正确性考虑，采用伪随机数，将tag的1-0、3-2、5-4、7-6位异或，得到一个2位地址，作为缓存不命中时替换的地址。
4. 缓存的状态为：IDLE、SEARCH、HIT、MISS、FETCH、FLUSH、READY，分别表示空、寻找缓存、命中、不命中、读内存、写内存、读完毕。处理具体事件经过的状态如下：
5. 读hit： IDLE->SEARCH->HIT->READY->IDLE
6. 读miss： IDLE->SEARCH->MISS(->FLUSH)->HIT->FETCH->READY->IDLE
7. 写hit： IDLE->SEARCH->HIT->IDLE
8. 写miss： IDLE->SEARCH->MISS(->FLUSH)->HIT->FETCH->READY->IDLE