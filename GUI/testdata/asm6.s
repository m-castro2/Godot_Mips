 
.text
    la $a0, Array
    la $a2, Array2
    la $a1, Count
    lw $a1, 0($a1)
Loop:
    lwc1 $f0, 0($a0)
    lwc1 $f1, 4($a0)
    add.d $f2, $f0, $f0
    mul.d $f4, $f2, $f2
    swc1 $f4, 0($a2)
    swc1 $f5, 4($a2)
    addi $a0, $a0, 8
    addi $a2, $a2, 8
    addi $a1, $a1, -1
    bne $a1, $0, Loop

Skip:
    addi $a1, $a1, -5
    addi $v0, $0, 10
    syscall
    
.data
  Count: .word 8, 0, 0, 0 # fill for visualization
  Array: .double 4.5, 0.5, 6.5, 2.0, 6.2, 1.0, 6.2, 4.5
  Array2: .space 64
