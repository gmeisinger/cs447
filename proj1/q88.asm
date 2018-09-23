.text
	wait: beq $t9, $zero, wait # Wait until $t9 is not zero (1)
	# Get operands A and B from $a0 and $a1
	add	$s0, $zero, $a0			# $s0 = A
	add 	$s1, $zero, $a1			# $s1 = B
	# Calculate A + B and put the result in the lower 16-bit of $v0
	add	$s2, $s0, $s1			# $s2 = A + B
	add	$v0, $zero, $s2			# put result in lower 16 of v0
	sll	$v0, $v0, 16			# shift left then right to clear upper half of register
	srl	$v0, $v0, 16
	# Calculate A - B and put the result in the higher 16-bit of $v0
	sub	$s2, $s0, $s1			# $s2 = A - B
	sll	$s2, $s2, 16			# shift to put result in upper 16
	or	$v0, $v0, $s2			# store in v0
	# Calculate A * B and put the result in the lower 16-bit of $v1
	# s2 = running result
	# s3 = counter
	add	$s3, $zero, $zero		# set counter to 0
	add	$s2, $zero, $zero		# reset s2
	# convert negative operands to positive
	add	$t3, $zero, $zero		# set t3 to 0
	slt	$t2, $s0, $zero			# t2 = 1 if A is negative
	beq	$t2, $zero, isBNegative		# if A is negative:
	sub	$s0, $zero, $s0			# 0 - negative is positive
	addi	$t3, $zero, 1			# t3 will keep track of whether product should be negative
	isBNegative:
	slt	$t2, $s1, $zero			# t2 = 1 if B is negative
	beq	$t2, $zero, multLoop		# if B is negative:
	sub	$s1, $zero, $s1			# 0 - negative is positive
	addi	$t3, $t3, -1			# if both operands are negative (or positive), t3 = 0
	multLoop:
	beq	$s3, 16, multConvertNegative	# check counter
	srlv	$t0, $s1, $s3			# shift right by counter to get current bit
	and	$t0, $t0, 1			# t0 is current bit
	bne	$t0, $zero, multBitIsOne	# if bit is one, get sum
	addi	$s3, $s3, 1			# increment counter
	j 	multLoop			# go to top of loop
	multBitIsOne:
	add	$t1, $zero, $s0			# set t1 to top number
	sllv	$t1, $t1, $s3			# shift left by counter
	add	$s2, $s2, $t1			# add to total
	addi	$s3, $s3, 1			# increment counter
	j	multLoop			# go to top of mult loop
	multConvertNegative:
	beq	$t3, $zero, multReturn		# if the product should be negative:
	sub	$s2, $zero, $s2			# 0 - product to make it negative
	multReturn:
	srl	$s2, $s2, 8			# shift right 8 to get q16.8
	add	$v1, $zero, $s2			# store result in lower 16 of v1
	sll	$v1, $v1, 16			# clear upper half of register
	srl	$v1, $v1, 16
	# Calculate A / B and put the result in the higher 16-bit of $v1
	add	$s0, $zero, $a0			# $s0 is dividend (remainder)
	add	$s1, $zero, $a1			# $s1 is divisor
	add	$s3, $zero, $zero		# $s3 is quotient
	sll	$s1, $s1, 16			# shift divisor left 16
	addi	$s2, $zero, 17			# set loop counter
	# convert negative operands to positive
	add	$t3, $zero, $zero		# set t3 to 0
	slt	$t2, $s0, $zero			# t2 = 1 if A is negative
	beq	$t2, $zero, divIsBNegative	# if A is negative:
	sub	$s0, $zero, $s0			# 0 - negative is positive
	addi	$t3, $zero, 1			# t3 will keep track of whether product should be negative
	divIsBNegative:
	slt	$t2, $s1, $zero			# t2 = 1 if B is negative
	beq	$t2, $zero, divLoop		# if B is negative:
	sub	$s1, $zero, $s1			# 0 - negative is positive
	addi	$t3, $t3, -1			# if both operands are negative (or positive), t3 = 0
	divLoop:
	beqz	$s2, divDone			# check counter
	slt	$t0, $s0, $s1			# 
	beqz	$t0, quotientOne		# if remainder < divisor
	sll	$s3, $s3, 1			# shift 0 into quotient
	srl	$s1, $s1, 1			# shift divisor
	addi	$s2, $s2, -1			# decrement counter
	j	divLoop
	quotientOne:
	sll	$s3, $s3, 1			# shift quotient
	ori	$s3, 1				# make bit 1
	sub	$s0, $s0, $s1			# remainder = remainder - divisor
	srl	$s1, $s1, 1			# shift divisor
	addi	$s2, $s2, -1			# decrement counter
	j	divLoop
	divDone:
	sll	$s3, $s3, 8
	sll	$s3, $s3, 16			# shift quotient to upper 16
	or	$v1, $v1, $s3			# store in $v1 upper
	# now calculate the decimal
	add	$s1, $zero, $a1			# reset divisor
	slt	$t2, $s1, $zero
	beq	$t2, $zero, decContinue
	sub	$s1, $zero, $s1
	decContinue:
	sll	$s0, $s0, 8			# shift remainder left 8
	add	$s3, $zero, $zero		# reset quotient
	sll	$s1, $s1, 16			# shift divisor left 16
	addi	$s2, $zero, 17			# set loop counter
	decLoop:
	beqz	$s2, divConvertNegative		# check counter
	slt	$t0, $s0, $s1			# 
	beqz	$t0, decQuotientOne		# if remainder < divisor
	sll	$s3, $s3, 1			# shift 0 into quotient
	srl	$s1, $s1, 1			# shift divisor
	addi	$s2, $s2, -1			# decrement counter
	j	decLoop
	decQuotientOne:
	sll	$s3, $s3, 1			# shift quotient
	ori	$s3, 1				# make bit 1
	sub	$s0, $s0, $s1			# remainder = remainder - divisor
	srl	$s1, $s1, 1			# shift divisor
	addi	$s2, $s2, -1			# decrement counter
	j	decLoop
	divConvertNegative:
	andi	$s3, $s3, 0x0000ffff
	sll	$s3, $s3, 16
	or	$v1, $v1, $s3
	beq	$t3, $zero, decDone		# if the quotient should be negative:
	srl	$t0, $v1, 16			
	sub	$t0, $zero, $t0
	sll	$t0, $t0, 16
	andi	$v1, $v1, 0x0000ffff
	or	$v1, $v1, $t0
	decDone:
	# Calculate sqrt(|A|) and put the result in the lower 16-bit of $a2
	abs	$s0, $a0			# $s0 is |A|
	add	$s1, $zero, $zero		# $s1 is remainder
	add	$s2, $zero, $zero		# $s2 is result
	addi	$s3, $zero, 22			# $s3 is the shift counter
	add	$s4, $zero, $zero		# $s4 is temp
	sll	$s0, $s0, 8			# shift left 8 to get q8.16
	sqrtLoop:
	slt	$t2, $s3, $zero			# check for end of loop
	bnez	$t2, sqrtDone
		# get left most 2 digits and put them to the right of remainder
	srlv	$t0, $s0, $s3			# shift out bits to right of our current group
	andi	$t0, $t0, 3			# isolate the 2 bits we want
	sll	$s1, $s1, 2			# make space in remainder
	or	$s1, $s1, $t0			# new remainder has our 2 bits to the right of old remainder
		# mult current result by 2 and by 2 again, this is temp
	sll	$s4, $s2, 2			# temp = current result * 4
	slt	$t0, $s4, $s1			# if temp < curr remainder, we want x = 1 ($t0 now holds x, 0 or 1)
	beqz	$t0, xIsZero
	sub	$s1, $s1, $s4			# subtract reaminder by temp
	sub	$s1, $s1, $t0			# subract remainder by x (we have subracted remainder by temp + x)
	xIsZero:
		# put x to right of current result
	sll	$s2, $s2, 1			# make room for x to right of result
	or	$s2, $s2, $t0			# put x to right of result
	addi	$s3, $s3, -2			# decrement counter
	j	sqrtLoop			# repeat
	sqrtDone:
	add	$a2, $s2, $zero			# store result in $a2
	
	
	
	add $t9, $zero, $zero # Set $t9 back to 0
	j wait # Go back to waits