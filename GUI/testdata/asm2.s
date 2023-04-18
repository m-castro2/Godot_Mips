.text
    la $a0, Mem
    addi $t0, $0, 25
    
    sw $t0, 0($a0)
    addi $t0, $t0, -1
    addi $a0, $a0, 4
    addi $a0, $a0, 4
    sw $a0, 0($a0)
    
    addi $v0, $0, 10
    syscall

.data

Mem: .space 20
