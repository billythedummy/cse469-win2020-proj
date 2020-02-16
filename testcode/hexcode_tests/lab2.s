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
    ADD r0, r0, #9
    MOV pc, lr
