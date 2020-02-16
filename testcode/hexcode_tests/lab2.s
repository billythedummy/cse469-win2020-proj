.text
.align 1
.setup: @ 0x0
    ADD r1, r1, #4 
.mainloop:  @ 0x4
    LDR r0, [r1]
    BL  .inc
    STR r0, [r1]
    B   .mainloop

.inc:       @ 0x14
    ADDS r0, r0, #1073741824 
    BVS .overflowed
    MOV pc, lr

.overflowed: @ 0x20
    BICS r0, r0, r0
    STR r0, [r1]

.carryloop: @ 0x28
    LDR r2, [r1, #4]
    SUBS r2, r2, #2147483648
    STR r2, [r1, #4]
    BCS .mainloop
    B   .carryloop
