 
.text
    la $a0, Array
    la $a2, Array2
    la $a1, Count
    lw $a1, 0($a1)
Loop:
    lwc1 $f0, 0($a0)
#    add.s $f1, $f0, $f0
#    mul.s $f2, $f1, $f1
    swc1 $f2, 0($a2)
    addi $a0, $a0, 4
    addi $a2, $a2, 4
    addi $a1, $a1, -1
    bne $a1, $0, Loop

Skip:
    addi $v0, $0, 10
    syscall
    
.data
  Count: .word 8, 0, 0, 0 # fill for visualization
  Array: .float 4.5, 0.5, 6.5, 2.0, 6.2, 1.0, 6.2, 4.5
  Array2: .space 32
