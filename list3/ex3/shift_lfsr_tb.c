#include <stdio.h>
#include <stdint.h>

extern uint16_t shift_lfsr(uint16_t v);

int main(int argc, char **argv) {
    const uint16_t init = 65535;
    uint16_t v = init;
    do {
        v = shift_lfsr(v);
        printf("%u\n", v);
    } while ( v != init);
}