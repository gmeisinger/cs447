.data
	buffer:	.space	11
.text
# main
	# print board
	addi	$a0, $zero, 0xFFFF8000		# $s0 is starting address of sudoku board
	la	$a1, buffer
	jal	_printBoard
	
	# solve puzzle
	add	$a0, $zero, $zero
	add	$a1, $zero, $zero
	jal	_solveSudoku
	
	#exit
	addi	$v0, $zero, 10			# exit
	syscall
	
# _printBoard
# print sudoku board
#
# Argument;
#   - $a0: memory address of board
#   - $a1: address of buffer
_printBoard:
	add	$t0, $zero, $a0			# t0 is address
	add	$t1, $zero, $zero		# t1 is row
	add	$t2, $zero, $zero		# t2 is column
	add	$t3, $zero, $a1			# t3 is address of string buffer
	rowLoop:
	beq	$t1, 9, printDone
	colLoop:
	beq	$t2, 9, colDone
	lb	$t4, 0($t0)			# read byte to t4
	addi	$t4, $t4, 48			# get ascii char
	sb	$t4, 0($t3)			# put in string address
	addi	$t2, $t2, 1			# increment col
	addi	$t0, $t0, 1
	addi	$t3, $t3, 1
	j	colLoop
	colDone:
	addi	$t4, $zero, 10			# newline
	sb	$t4, 0($t3)
	addi	$t4, $zero, 0
	sb	$t4, 1($t3)
	addi	$t1, $t1, 1			# increment row
	add	$t2, $zero, $zero		# reset col
	#print line
	addi	$v0, $zero, 4 			# print string
	la	$a0, buffer
	syscall
	add	$t3, $zero, $a1
	j	rowLoop
	printDone:
	jr	$ra
	
	
	
# _solveSudoku
# recursive sudoku solver
#
# Argument:
#   - $a0: row
#   - $a1: column
# Return Value
#   - $v0: 1 for true (solved), 0 for false
_solveSudoku:
	# backup
	addi 	$sp, $sp, -24
	sw 	$s0, 20($sp)
	sw	$s1, 16($sp)
	sw 	$s2, 12($sp)
	sw 	$s3, 8($sp)
	sw	$s4, 4($sp)
	sw 	$ra, 0($sp)
	add	$s0, $zero, $a0				# $s0 holds row
	add	$s1, $zero, $a1				# $s1 holds col
	bne	$s1, 9, solGetVal
	# if row is done
	beq	$s0, 8, solRetTrue
	addi	$s0, $s0, 1				# increment row
	add	$s1, $zero, $zero			# reset col
	addi	$a0, $a0, 1
	add	$a1, $zero, $zero
	solGetVal:
	# get value of cell
	addi	$s2, $zero, 0xffff8000			# s2 is beginning of puzzle
	add	$s3, $zero, $zero			# s3 is counter
	beqz	$s0, solRowLoopDone
	solRowLoop:
	addiu	$s2, $s2, 9
	addi	$s3, $s3, 1
	beq	$s3, $s0, solRowLoopDone
	j	solRowLoop
	solRowLoopDone:
	addu	$s2, $s2, $s1				# add col number
	lb	$s3, 0($s2)				# s3 holds value of cell
	beqz	$s3, solPreCheck
	# if s3 is NOT zero
	addi	$sp, $sp, -8
	sw	$a0, 4($sp)
	sw	$a1, 0($sp)
	addi	$a1, $a1, 1
	jal	_solveSudoku
	lw	$a0, 4($sp)
	lw	$a1, 0($sp)
	addi	$sp, $sp, 8
	j	solReturn
	# check for conflicts
	solPreCheck:
	add	$s4, $zero, $zero			# s4 is counter (1-9)
	solCheckLoop:
	addi	$s4, $s4, 1
	beq	$s4, 10, solRetFalse			# if nothing fits
	
	addi	$sp, $sp, -12
	sw	$a0, 8($sp)
	sw	$a1, 4($sp)
	sw	$ra, 0($sp)
	add	$a0, $zero, $s0
	add	$a1, $zero, $s4
	jal	_checkRow
	lw	$a0, 8($sp)
	lw	$a1, 4($sp)
	lw	$ra, 0($sp)
	addi	$sp, $sp, 12
	beq	$v0, 1, solCheckLoop
	
	addi	$sp, $sp, -12
	sw	$a0, 8($sp)
	sw	$a1, 4($sp)
	sw	$ra, 0($sp)
	add	$a0, $zero, $s1
	add	$a1, $zero, $s4
	jal	_checkColumn
	lw	$a0, 8($sp)
	lw	$a1, 4($sp)
	lw	$ra, 0($sp)
	addi	$sp, $sp, 12
	beq	$v0, 1, solCheckLoop
	
	addi	$sp, $sp, -12
	sw	$a0, 8($sp)
	sw	$a1, 4($sp)
	sw	$ra, 0($sp)
	addu	$a0, $zero, $s2				# s2 is mem loc of cell
	add	$a1, $zero, $s4
	jal	_checkSubgrid
	lw	$a0, 8($sp)
	lw	$a1, 4($sp)
	lw	$ra, 0($sp)
	addi	$sp, $sp, 12
	beq	$v0, 1, solCheckLoop
	
	# made it here, no conflicts
	sb	$s4, 0($s2)				# store value in cell
	solContinue:
	addi	$sp, $sp, -8
	sw	$a0, 4($sp)
	sw	$a1, 0($sp)
	addi	$a1, $a1, 1
	jal	_solveSudoku
	lw	$a0, 4($sp)
	lw	$a1, 0($sp)
	addi	$sp, $sp, 8
	beqz	$v0, solCheckLoop
	solRetTrue:
	addi	$v0, $zero, 1
	j	solReturn
	solRetFalse:
	sb	$zero, 0($s2)				# set cell back to 0
	add	$v0, $zero, $zero
	solReturn:
	lw	$s0, 20($sp)
	lw	$s1, 16($sp)
	lw	$s2, 12($sp)
	lw	$s3, 8($sp)
	lw	$s4, 4($sp)
	lw	$ra, 0($sp)
	addi	$sp, $sp, 24
	jr	$ra
	

# _checkRow
# 
#
# Argument:
#   - $a0: row
#   - $a1: value
# Return Value
#   - $v0: 1 if found, 0 if not
_checkRow:
	addiu	$t0, $zero, 0xffff8000		# t0 at start of puzzle
	crFindRow:
	beqz	$a0, crFindRowDone
	addiu	$t0, $t0, 9
	addi	$a0, $a0, -1
	j	crFindRow
	crFindRowDone:
	add	$t1, $zero, $zero		# t1 is col counter
	crSearchLoop:
	beq	$t1, 9, crNotFound
	lb	$t2, 0($t0)			# t2 has value from board
	beq	$a1, $t2, crFound		# if values match
	addi	$t1, $t1, 1
	addiu	$t0, $t0, 1			# increment counter and mem loc
	j	crSearchLoop
	crNotFound:
	add	$v0, $zero, $zero
	jr	$ra
	crFound:
	addi	$v0, $zero, 1
	jr	$ra
	
# _checkColumn
# 
#
# Argument:
#   - $a0: column
#   - $a1: value
# Return Value
#   - $v0: 1 if found, else 0
_checkColumn:
	addiu	$t0, $zero, 0xffff8000		# t0 at start of puzzle
	addu	$t0, $t0, $a0			# to find col
	add	$t1, $zero, $zero		# t1 is row counter
	ccSearchLoop:
	beq	$t1, 9, ccNotFound
	lb	$t2, 0($t0)			# t2 has value from board
	beq	$a1, $t2, ccFound		# if values match
	addi	$t1, $t1, 1
	addi	$t0, $t0, 9			# increment counter and mem loc
	j	ccSearchLoop
	ccNotFound:
	add	$v0, $zero, $zero
	jr	$ra
	ccFound:
	addi	$v0, $zero, 1
	jr	$ra

# _checkSubgrid
#
# Argument:
#   - $a0: memory address of cell
#   - $a1: value
# Return Value
#   - $v0: 1 if found, else 0
_checkSubgrid:
	subiu	$t0, $a0, 0xffff8000		# t0 is offset from beginning
	addi	$t3, $zero, 9
	divu	$t0, $t3			# LO has row, HI has col
	mflo	$t1				# t1 is row
	mfhi	$t2				# t2 is col
	# get subgrid starting cell
	addu	$t0, $zero, $a0			# t0 is our cell address
	addi	$t3, $zero, 3
	div	$t1, $t3			# hi has the remainder, or offset from grid start
	mfhi	$t4
	csGetRow:
	beqz	$t4, csGetCol
	addi	$t4, $t4, -1
	addiu	$t0, $t0, -9
	j	csGetRow
	csGetCol:
	div	$t2, $t3			# hi has col offset from grid start
	mfhi	$t4
	subu	$t0, $t0, $t4			# t0 should be at subgrid start
	# iterate over subgrid
	add	$t1, $zero, $zero		# row counter
	add	$t2, $zero, $zero		# col counter
	csRowLoop:
	beq	$t1, 3, csNotFound
	csColLoop:
	beq	$t2, 3, csRowDone
	lb	$t3, 0($t0)			# current cell value
	beq	$t3, $a1, csFound		# collision
	addi	$t2, $t2, 1
	addiu	$t0, $t0, 1
	j	csColLoop
	csRowDone:
	add	$t2, $zero, $zero		# reset col counter
	addi	$t1, $t1, 1
	addiu	$t0, $t0, 6
	j	csRowLoop
	csFound:
	addi	$v0, $zero, 1
	jr	$ra
	csNotFound:
	add	$v0, $zero, $zero
	jr	$ra
