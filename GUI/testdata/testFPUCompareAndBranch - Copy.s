.text
    la $a0, Array
    la $a1, Count
    lw $a1, 0($a1) 
    lwc1 $f0, 0($a0)
    lwc1 $f1, 4($a0)
    add.d $f2, $f0, $f2
Skip:
    add.d $f4, $f0, $f4
    c.eq.d $f4, $f2
    bc1t Skip
    addi $v0, $0, 10
    syscall


.data
  Count: .word 8, 0, 0, 0 # fill for visualization
  Array: .double 4.5, 0.5, 6.5, 2.0, 6.2, 1.0, 6.2, 4.5
  Array2: .space 64