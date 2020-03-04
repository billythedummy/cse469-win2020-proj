.text
.align 1
.setup: @ 0x0
    MOV r1, #2
    ADD r2, r3, #4
    ORR r4, r1, r2
    BIC r4, r4, r4
    SUB r12, r2, r1 
    ADD r1, r1, r1
    ADD r1, pc
