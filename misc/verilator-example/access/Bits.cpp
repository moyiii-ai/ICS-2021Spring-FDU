#include <cstdint>

#include "obj_dir/VBits.h"
#include "obj_dir/VBits__Syms.h"

#include "verilated.cpp"

// typedef vluint8_t    CData;     ///< Verilated pack data, 1-8 bits
// typedef vluint16_t   SData;     ///< Verilated pack data, 9-16 bits
// typedef vluint32_t   IData;     ///< Verilated pack data, 17-32 bits
// typedef vluint64_t   QData;     ///< Verilated pack data, 33-64 bits
// typedef vluint32_t   EData;     ///< Verilated pack element of WData array
// typedef EData        WData;     ///< Verilated pack data, >64 bits, as an array

struct pair_t {
    // NOTE: the order of members is reversed in C++.
    uint32_t second;
    uint32_t first;
};

int main() {
    auto top = new VBits;
    top->eval();

    // top->a: IData
    printf("a: %08x\n", top->a);

    // top->b: SData
    auto b = reinterpret_cast<uint8_t *>(&top->b);
    printf("b: {%02x %02x}\n", b[0], b[1]);

    // top->c: IData
    auto c = reinterpret_cast<uint8_t (*)[2]>(&top->c);
    printf("c: {{%02x %02x} {%02x %02x}}\n", c[0][0], c[0][1], c[1][0], c[1][1]);

    // top->d: QData
    auto d = reinterpret_cast<uint32_t *>(&top->d);
    printf("d: {%08x %08x}\n", d[0], d[1]);

    // top->e: WData[4]
    auto e = reinterpret_cast<uint32_t (*)[2]>(top->e);
    printf("e: {{%08x %08x} {%08x %08x}}\n", e[0][0], e[0][1], e[1][0], e[1][1]);

    // top->f: WData[4]
    auto f = top->f;
    // NOTE: the order is revered due to little-endianess.
    printf("f: %08x_%08x_%08x_%08x\n", f[3], f[2], f[1], f[0]);

    // top->g: QData
    auto g = reinterpret_cast<pair_t *>(&top->g);
    printf("g: {first: %08x, second: %08x}\n", g->first, g->second);

    auto scope = top->Bits;

    // top->h: SData;
    auto h = top->h;
    printf(
        "h: {a: %u, b: %u, c: %u, d: %u}\n",
        scope->get_a(h),
        scope->abcd_t_b(h),
        scope->abcd_t_c(h),
        scope->abcd_t_d(h)
    );

    return 0;
}
