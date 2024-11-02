        
.data
newline: .asciiz "\n"
zero: .float 0.0
var_0: .float 5.000
var_1: .float 5.000
var_2: .float 3.000
var_3: .float 3.000
var_4: .float 8.000

.text
lwc1 $f31, zero
lwc1 $f0, var_0
# 5.000000
swc1 $f0, var_1
lwc1 $f0, var_2
# 3.000000
swc1 $f0, var_3
lwc1 $f1, var_1
lwc1 $f2, var_3
add.s $f0, $f1, $f2
# 0.000000
swc1 $f0, var_4
lwc1 $f0, var_4
li $v0, 2
mov.s $f12, $f0
mov.s $f30, $f12
syscall
li $v0, 4
la $a0, newline
syscall
EXIT:
