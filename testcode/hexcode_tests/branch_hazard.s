.text
.align 1
.setup: 
    MOV r0, #6
    BL .to  @ 0x4
    ADD r0, r0, r0
    ADD r0, r0, r0
    B .setup    @ 0x10
.to: @ 0x14
    SUB r0, r0, r0
    AND r0, r0, r0
    MOV PC, LR  @ 0x1c
    ADD r0, r0, r0
    ADD r0, r0, r0
    ADD r0, r0, r0