	.data
signe:		.word 0
exponent:	.word 0
mantissa:	.word 0
# cfixa:		.word 0x87D18A00
cfixa:		.word 0x00FFFFFF
cflotant:	.float 0.0

	.text
	.globl main
main:
	addiu	$sp, $sp, -4
	sw	$ra, 0($sp)

	la	$t0, cfixa
	lw	$a0, 0($t0)
	la	$a1, signe
	la	$a2, exponent
	la	$a3, mantissa
	jal	descompon

	la	$a0, signe
	lw	$a0,0($a0)
	la	$a1, exponent
	lw	$a1,0($a1)
	la	$a2, mantissa
	lw	$a2,0($a2)
	jal	compon

	la	$t0, cflotant
	swc1	$f0, 0($t0)

	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4
	jr	$ra


descompon:
	addiu	$sp, $sp, -4		# EPILOG
	sw	$ra, 0($sp)
	
	
	slt	$t0, $a0, $zero		# If negative the val is 1, else 0
	sw 	$t0, 0($a1)		
	sll 	$a0 $a0, 1		# remove sign
	
	bne 	$a0, $zero, else	# if cf == 0
	li 	$t1, 0			# $t1 <--> exp, exp = 0
	b 	end_else
	
	else:
	li	$t1, 18			# else {...}
	
	do:				# do {...}
	sll 	$a0, $a0, 1
	addiu	$t1, $t1, -1
	bge 	$a0, $zero, do		# while (cf >= 0)
	
	sra	$a0, $a0, 8
	li 	$t2, 0x7FFFFF
	and	$a0, $a0, $t2		# align and remove hidden bit
	addiu	$t1, $t1, 127		# apply excess-127
	
	end_else:
	
	sw	$t1, 0($a2)		# assign final result
	sw 	$a0, 0($a3)
	
	lw	$ra, 0($sp)		# PROLEG
	addiu	$sp, $sp, 4
	jr	$ra
	
compon:
	addiu	$sp, $sp, -4		# PROLEG
	sw	$ra, 0($sp)
	
	sll	$a0, $a0, 31		# Make shifts to registers
	sll 	$a1, $a1, 23
	
	or 	$t0, $a0, $a1		# assemble the final result
	or 	$t0, $t0, $a2
	
	mtc1	$t0, $f0		# move result to return register in Coprocessor 1
	
	lw	$ra, 0($sp)		# PROLEG
	addiu	$sp, $sp, 4
	jr	$ra

