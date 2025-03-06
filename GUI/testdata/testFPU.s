.text
    la $a0, Array
    la $a1, Count
    lw $a1, 0($a1) 
    lwc1 $f0, 0($a0)
    lwc1 $f1, 4($a0)
Loop:
    add.d $f2, $f0, $f0 # 4.5 + 4.5 = 9  0x00000000 0x40220000
    mul.d $f4, $f2, $f0 # 9 * 4.5 = 40.5 0x00000000 0x40444000
    div.d $f6, $f4, $f0 # 40.5 / 4.5 = 9 0x00000000 0x40220000
    sub.d $f8, $f6, $f0 # 9 - 4.5 = 4.5  0x00000000 0x40120000
    mov.s $f10, $f2
    c.eq.d $f8, $f0
    addi $a1, $a1, 0
    bc1f Loop
    bc1t Loop
    addi $v0, $0, 10
    syscall


.data
  Count: .word 8, 0, 0, 0 # fill for visualization
  Array: .double 4.5, 0.5, 6.5, 2.0, 6.2, 1.0, 6.2, 4.5
  Array2: .space 64