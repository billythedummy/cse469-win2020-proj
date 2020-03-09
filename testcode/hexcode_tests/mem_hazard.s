.text
.align 1
.setup: 
    MOV r0, #6
    TEQ r1, r1
    TEQ r1, r1
    STR r0, [r1]
    MOV r0, #69
    LDR r0, [r1]
    ADD r0, r0, #2 @ 0x18
    EOR r1, r0, r1
    ADD r2, r3, r4