.text
    la $a0, Array
    la $a1, Count
    lw $a1, 0($a1) 
    lwc1 $f1, 0($a0)
    lwc1 $f0, 4($a0)
Loop:
    add.s $f2, $f0, $f0 # 4.5 + 4.5 = 9  0x00000000 0x40220000
    add.d $f2, $f0, $f2 # 13.5
    addi $v0, $0, 10
    syscall


.data
  Count: .word 8, 0, 0, 0 # fill for visualization
  Array: .double 4.5, 0.5, 6.5, 2.0, 6.2, 1.0, 6.2, 4.5
  Array2: .space 64