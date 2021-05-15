#include "mycache.h"
#include "cache_ref.h"

CacheRefModel::CacheRefModel(MyCache *_top, size_t memory_size)
    : top(_top), scope(top->VCacheTop), mem(memory_size) {
    /**
     * TODO (Lab3) setup reference model :)
     */

    mem.set_name("ref");
}

void CacheRefModel::reset() {
    /**
     * TODO (Lab3) reset reference model :)
     */

    log_debug("ref: reset()\n");
    for(int i = 0; i < 4; ++i)
        c[i].clear();
    mem.reset();
}

auto CacheRefModel::load(addr_t addr, AXISize size) -> word_t {
    /**
     * TODO (Lab3) implement load operation for reference model :)
     */
    log_debug("ref: load(0x%x, %d)\n", addr, 1 << size);
    int index = (addr / 16) & 3;
    return read(index, addr);
}

void CacheRefModel::store(addr_t addr, AXISize size, word_t strobe, word_t data) {
    /**
     * TODO (Lab3) implement store operation for reference model :)
     */

    log_debug("ref: store(0x%x, %d, %x, \"%08x\")\n", addr, 1 << size, strobe, data);
    
    int index = (addr / 16) & 3;
    update(index, addr, strobe, data);
}

void CacheRefModel::check_internal() {
    /**
     * TODO (Lab3) compare reference model's internal states to RTL model :)
     *
     * NOTE: you can use pointer top and scope to access internal signals
     *       in your RTL model, e.g., top->clk, scope->mem.
     */

    log_debug("ref: check_internal()\n");

    for(int i = 0; i < 4; ++i) 
        for(int j = 0; j < 4; ++j) {
            if(!c[i].valid[j])
                continue;
            for(int k = 0; k < 4; ++k) {
                asserts(
                    c[i].a[j][k] == scope->mem[i * 16 + j * 4 + k],
                    "reference model's internal state is different from RTL model."
                    " at mem[%x][%x][%x], expected = %08x, got = %08x",
                    i, j, k, c[i].a[j][k], scope->mem[i * 16 + j * 4 + k]
                );
            }
        }

    /**
     * the following comes from StupidBuffer's reference model.
     */
    // for (int i = 0; i < 16; i++) {
    //     asserts(
    //         buffer[i] == scope->mem[i],
    //         "reference model's internal state is different from RTL model."
    //         " at mem[%x], expected = %08x, got = %08x",
    //         i, buffer[i], scope->mem[i]
    //     );
    // }
}

void CacheRefModel::check_memory() {
    /**
     * TODO (Lab3) compare reference model's memory to RTL model :)
     *
     * NOTE: you can use pointer top and scope to access internal signals
     *       in your RTL model, e.g., top->clk, scope->mem.
     *       you can use mem.dump() and MyCache::dump() to get the full contents
     *       of both memories.
     */

    log_debug("ref: check_memory()\n");

    /**
     * the following comes from StupidBuffer's reference model.
     */
    asserts(
        mem.dump(0, mem.size()) == top->dump(), 
        "reference model's memory content is different from RTL model");
}
