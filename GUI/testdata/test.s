.text
.globl main

main:
  addi $t2, $0, 40
  addi $t1, $0, 20
  sub $t3, $t2, $t1

Loop:
  addi $t3, $t3, -1
  bne $t3, $0, Loop
  
  
fin:
  addi $v0,$0,10      # la llamada para salir del programa
  syscall
