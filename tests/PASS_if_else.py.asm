  # Assigning depth: 0
# Assigning depth: 0
# Assigning depth: 0
# Assigning depth: 0
# Assigning depth: 0
   # Assigning depth: 3
# Assigning depth: 3
# Assigning depth: 3
# Assigning depth: 3
# Assigning depth: 3
# Assigning depth: 3
# Assigning depth: 3
# Assigning depth: 3
# Assigning depth: 3
# Assigning depth: 3
# Assigning depth: 0
# Assigning depth: 0
# Assigning depth: 0
# Assigning depth: 0
# Assigning depth: 0
# Assigning depth: 0
# Assigning depth: 0
# Assigning depth: 0
# Assigning depth: 0
# Assigning depth: 0
# Assigning depth: 0
# Assigning depth: 0

.data
newline: .asciiz "\n"
zero: .float 0.0
var_0: .float 10.000
var_1: .float 10.000
var_2: .float 5.000

.text
lwc1 $f31, zero
lwc1 $f0, var_0
swc1 $f0, var_1
_IF_START_0:
lwc1 $f0, var_1
lwc1 $f1, var_2
li $t0, 1
c.le.s $f0, $f1
movt $t0, $0
beqz $t0 _ELSE_START_0
lwc1 $f0, var_0
li $v0, 2
add.s $f12, $f31, $f0
mov.s $f30, $f12
syscall
li $v0, 4
la $a0, newline
syscall
j _IF_END_0
_ELSE_START_0:
lwc1 $f1, var_0
li $v0, 2
add.s $f12, $f31, $f1
mov.s $f30, $f12
syscall
li $v0, 4
la $a0, newline
syscall
_ELSE_END_0:
_IF_END_0:
EXIT:
