.text
.align 1
.setup:
    ADD r1, r1, #4
.mainloop:
    LDR r0, [r1]
    BL  .inc
    STR r0, [r1]
    B   .mainloop

.inc:
    ADDS r0, r0, #1073741824
    BVS .overflowed
    MOV pc, lr

.overflowed:
    BICS r0, r0, r0
    STR r0, [r1]

.carryloop:
    LDR r2, [r1, #4]
    SUBS r2, r2, #2147483648
    STR r2, [r1, #4]
    BCS .mainloop
    B   .carryloop
