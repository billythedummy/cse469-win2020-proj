.text
.align  1
.start:
    B   .lul
    BNE .lul
    BLT .lul
    BL  .lul
    MOV r2, r1
    MVN r3, r2
    LDR r4, [r3]
    ADD r5, r4
    SUB r6, r5
    CMP r7, r6
    TST r8, r7
    TEQ r9, r8
    EOR r0, r9
    BIC r1, r0
    ORR r2, r1
.lul:
    MOV r2, r1
    BLE start
