.text
    la $a0, Mem
    la $a1, Count
    lw $a1, 0($a1)

Loop:
    addi $a1, $a1, -1
    lw $t0, 0($a0)
    add $t2, $t0, $t0
    sw $t0, 0($a0)
    addi $a0, $a0, 4
    bne $a1, $0, Loop
    addi $v0, $0, 10
    syscall

.data

Mem: .word 16, 5, 1, 20
Count: .word 4

