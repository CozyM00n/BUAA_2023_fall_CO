```
javaw -jar Mars4_5.jar
```

1.打印字符串

```mips
.data
      toPrintMessage: .asciiz "the message to print"

li  $v0, 4
la   $a0, toPrintMessage
syscall
```

```
.macro printS(%s)
	li $v0, 4
	la $a0, %s
	syscall
.end_macro
```

2.读入整数

```
li  $v0, 5
syscall   # 结果储存在v0
```

```
.macro readInt
li $v0, 5
syscall
.end_macro
```

3.打印整数
($a0 = integer to print)
把$a0寄存器中的数据以整数形式输出

```
li $v0, 1
lw $a0, toPrintInt
syscall
```

```
.macro printInt(%src)
	li $v0, 1
	lw $a0, %src
	syscall
.end_macro
```

4.结束程序

```
li $v0, 10
syscall
```



```
//5.PUSH
.macro push(%src) // 把src寄存器保存的值入栈
	sw %src, ($sp)
	subi $sp, $sp, 4
.end_macro

//6.POP
.macro pop(%dst)
	addi $sp, $sp, 4
	lw %dst, ($sp)
```

```
·return：
jr   $ra
```

