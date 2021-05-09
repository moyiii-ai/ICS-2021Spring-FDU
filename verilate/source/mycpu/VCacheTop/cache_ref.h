#pragma once

#include "defs.h"
#include "memory.h"
#include "reference.h"

class MyCache;

class CacheRefModel final : public ICacheRefModel {
public:
    CacheRefModel(MyCache *_top, size_t memory_size);

    void reset();
    auto load(addr_t addr, AXISize size) -> word_t;
    void store(addr_t addr, AXISize size, word_t strobe, word_t data);
    void check_internal();
    void check_memory();

private:
    MyCache *top;
    VModelScope *scope;

    /**
     * TODO (Lab3) declare reference model's memory and internal states :)
     *
     * NOTE: you can use BlockMemory, or replace it with anything you like.
     */

    // int state;
    BlockMemory mem;
    struct cacheline {
        word_t a[4][4];
        int tag[4], dirty[4];
        void clear() {
            for(int i = 0; i < 4; ++i)
                tag[i] = -1, dirty[i] = 0;
        }
    }c[4];

    int find(int v, addr_t addr) {
        int nt = addr / 64, pos = -1;
        for(int i = 0; i < 4; ++i)
            if(c[v].tag[i] == nt)
                pos = i;
        if(pos != -1)  return pos;
        
        int n1 = nt & 3;
        int n2 = (nt / 4) & 3;
        int n3 = (nt / 16) & 3;
        int n4 = (nt / 64) & 3;
        pos = n1 ^ n2 ^ n3 ^ n4;
        
        addr_t oldaddr = c[v].tag[pos] * 64 + (addr & 64);
        if(c[v].dirty[pos])
            for(int i = 0; i < 4; ++i)
                mem.store(oldaddr + 4 * i, c[v].a[pos][i], STROBE_TO_MASK[15]);
        for(int i = 0; i < 4; ++i)
            c[v].a[pos][i] = mem.load(addr + 4 * i);
        c[v].tag[pos] = nt;
        c[v].dirty[pos] = 0;
        return pos;
    }

    word_t read(int v, addr_t addr) {
        int pos = find(v, addr);
        int offset = (addr / 4) & 3;
        return c[v].a[pos][offset];
    }

    void write(int v, addr_t addr, word_t strobe, word_t data) {
        int pos = find(v, addr);
        int offset = (addr / 4) & 3;
        auto mask = STROBE_TO_MASK[strobe];
        auto value = c[v].a[pos][offset];
        value = (data & mask) | (value & ~mask);
        c[v].a[pos][offset] = value;
        c[v].dirty[pos] = 1;
    }
    
};
