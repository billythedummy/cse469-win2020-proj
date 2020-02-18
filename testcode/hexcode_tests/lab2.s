.text
.align 1
.setup: @ 0x0
    MOV r1, #0
    ADD r1, r1, #4 
.mainloop:  @ 0x8
    LDR r0, [r1]
    BL  .inc
    STR r0, [r1]
    B   .mainloop

.inc:       @ 0x18
    ADDS r0, r0, #1073741824 
    BVS .overflowed
    MOV pc, lr

.overflowed: @ 0x24
    BICS r0, r0, r0
    STR r0, [r1]

.carryloop: @ 0x2C
    LDR r2, [r1, #4]
    SUBS r2, r2, #2147483648
    STR r2, [r1, #4]
    BCS .xor
    B   .carryloop

.xor:   @ 0x40
    ADD r3, r3, #1
    LDR r4, [r1, +r3, LSL #2]
    ADD r5, r4, #69
    STR r5, [r1, +r3, LSL #2]
    LDR r4, [r1, +r3, LSL #2]
    TEQ r4, r5
    MOV r3, #0
    BEQ .mainloop
