.text
.align 1
.setup: 
    MOV r0, #6
    STR r0, [r1]
    LDR r0, [r1]
    ADD r0, r0, #2
    EOR r1, r0, r1
    ADD r2, r3, r4