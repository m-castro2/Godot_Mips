.text

    lui $a0, 0x1001
    addi $8, $0, 25
Loop:
    add $t1, $t1, $s0
    sw $8, 0($a0)
    addi $8, $8, -1
    addi $a0, $a0, 4
    bne $8, $0, Loop

    addi $v0, $0, 10
    syscall
    
.data

Mem: .space 100
