.data
	spc:		.asciiz		" "
	prompt:		.asciiz		"Enter a filename: "
	tFirstTwo:	.asciiz		"The first two characters: "
	tSizeOfFile:	.asciiz		"\nThe size of the BMP file (bytes): "
	tStartingAddress:	.asciiz	"\nThe starting address of image data: "
	tIWidth:	.asciiz		"\nImage width (pixels): "
	tIHeight:	.asciiz		"\nImage height (pixels): "
	tCPlanes:	.asciiz		"\nThe number of color planes: "
	tBpp:		.asciiz		"\nThe number of bits per pixel: "
	tCompression:	.asciiz		"\nThe compression method: "
	tRawDataSize:	.asciiz		"\nThe size of raw bitmap data (bytes): "
	tHResolution:	.asciiz		"\nThe horizontal resolution (pixels/meter): "
	tVResolution:	.asciiz		"\nThe vertical resolution (pixels/meter): "
	tColorPalette:	.asciiz		"\nThe number of colors in the color palette: "
	tImportantColors:	.asciiz	"\nThe number of important colors used: "
	tIndexZero:	.asciiz		"\nThe color at index 0 (B G R): "
	tIndexOne:	.asciiz		"\nThe color at index 1 (B G R): "
	filename:	.space		100
	firstTwo:	.space		2
	.align 2
	firstHeader:	.space		12
	.align 2
	DIBsize:	.space		4
	colorArray:	.space		8


	
.text


	addi 	$v0, $zero, 4		# Syscall 4: Print string
	la   	$a0, prompt		# "Enter a..."
	syscall	
	addi	$v0, $zero, 8		# Syscall 8: Read string
	la	$a0, filename
	addi	$a1, $zero, 100		
	syscall
	# remove newline
	la	$t0, filename		# $t0 holds address of filename
	newlineLoop:
	lb	$t1, 0($t0)		# $t1 is current char
	beqz	$t1, newlineDone
	addi	$t0, $t0, 1		# increment $t0
	j 	newlineLoop		# go to top of loop
	newlineDone:
	sub	$t0, $t0, 1
	sb	$zero, 0($t0)		# make newline a 0
	# open file
	addi 	$v0, $zero, 13		# Syscall 13: open file
	la 	$a0, filename
	add	$a1, $zero, $zero
	add	$a2, $zero, $zero
	syscall
	add	$s0, $zero, $v0		# copy file descriptor to $s0
	
	# Read File
	
	# Read header and size of dib header
	addi 	$v0, $zero, 14		# Syscall 14: Read file
	add  	$a0, $zero, $s0		# $a0 is the file descriptor
	la   	$a1, firstTwo		# $a1 is the address of the buffer
	addi 	$a2, $zero, 2		# $a2 is the number of bytes to read
	syscall				# Read file
	addi 	$v0, $zero, 14		# Syscall 14: Read file
	add  	$a0, $zero, $s0		# $a0 is the file descriptor
	la   	$a1, firstHeader	# $a1 is the address of the buffer
	addi 	$a2, $zero, 12		# $a2 is the number of bytes to read
	syscall				# Read file
	addi 	$v0, $zero, 14		# Syscall 14: Read file
	add  	$a0, $zero, $s0		# $a0 is the file descriptor
	la	$a1, DIBsize
	addi	$a2, $zero, 4
	syscall				# read dib size
	# Read DIB Header
	la	$t0, DIBsize
	addi	$v0, $zero, 9		# Syscall 9: allocate heap memory
	lw	$a0, 0($t0)		# $a0 is size of header
	addi	$a0, $a0, -4
	syscall				# allocated mem is in $v0
	add	$s1, $zero, $v0		# $s1 has DIB header address
	addi 	$v0, $zero, 14		# Syscall 14: Read file
	add  	$a0, $zero, $s0		# $a0 is the file descriptor
	add	$a1, $zero, $s1		# $a1 has dib header address
	lw 	$a2, 0($t0)		# $a2 is the number of bytes to read
	addi	$a2, $a2, -4
	syscall				# Read file	
	addi 	$v0, $zero, 14		# syscall 14: read file
	add	$a0, $zero, $s0
	la	$a1, colorArray	
	addi	$a2, $zero, 8
	syscall				# read in color array
	
	# Print Info
	
	addi 	$v0, $zero, 4		# Syscall 4: Print string
	la   	$a0, tFirstTwo		# 
	syscall
	addi	$v0, $zero, 11		# syscall 11: print char
	la	$t0, firstTwo
	lb	$a0, 0($t0)		# first char
	syscall
	lb	$a0, 1($t0)		# second char
	syscall
	la	$t0, firstHeader
	
	addi 	$v0, $zero, 4		# Syscall 4: Print string
	la   	$a0, tSizeOfFile	# 
	syscall	
	addi	$v0, $zero, 1		# syscall 1: print int
	lw	$a0, 0($t0)		# file size
	syscall
	
	addi 	$v0, $zero, 4		# Syscall 4: Print string
	la   	$a0, tStartingAddress	# 
	syscall	
	addi	$v0, $zero, 1		# print int
	lw	$a0, 8($t0)		# offset of bmp data
	syscall
	add	$t0, $zero, $s1		# $t0 has dib header address
	
	addi 	$v0, $zero, 4		# Syscall 4: Print string
	la   	$a0, tIWidth		# 
	syscall	
	addi	$v0, $zero, 1		# print int
	lw	$a0, 0($t0)		# image width
	syscall
	
	addi 	$v0, $zero, 4		# Syscall 4: Print string
	la   	$a0, tIHeight		# 
	syscall	
	addi	$v0, $zero, 1		# print int
	lw	$a0, 4($t0)		# image height
	add	$t2, $zero, $a0		# save for later
	syscall
	
	addi 	$v0, $zero, 4		# Syscall 4: Print string
	la   	$a0, tCPlanes		# 
	syscall	
	addi	$v0, $zero, 1		# print int
	lh	$a0, 8($t0)		# color planes
	syscall
	
	addi 	$v0, $zero, 4		# Syscall 4: Print string
	la   	$a0, tBpp		# 
	syscall	
	addi	$v0, $zero, 1		# print int
	lh	$a0, 10($t0)		# bits per pixel
	syscall
	
	addi 	$v0, $zero, 4		# Syscall 4: Print string
	la   	$a0, tCompression		# 
	syscall	
	addi	$v0, $zero, 1		# print int
	lw	$a0, 12($t0)		# comp method
	syscall
	
	addi 	$v0, $zero, 4		# Syscall 4: Print string
	la   	$a0, tRawDataSize		# 
	syscall	
	addi	$v0, $zero, 1		# print int
	lw	$a0, 16($t0)		# raw data size
	add	$t1, $zero, $a0		# save for later
	syscall
	
	addi 	$v0, $zero, 4		# Syscall 4: Print string
	la   	$a0, tHResolution	# 
	syscall	
	addi	$v0, $zero, 1		# print int
	lw	$a0, 20($t0)		# horz res
	syscall
	
	addi 	$v0, $zero, 4		# Syscall 4: Print string
	la   	$a0, tVResolution	# 
	syscall	
	addi	$v0, $zero, 1		# print int
	lw	$a0, 24($t0)		# vert res
	syscall
	
	addi 	$v0, $zero, 4		# Syscall 4: Print string
	la   	$a0, tColorPalette	# 
	syscall	
	addi	$v0, $zero, 1		# print int
	lw	$a0, 28($t0)		# num of colors
	syscall
	
	addi 	$v0, $zero, 4		# Syscall 4: Print string
	la   	$a0, tImportantColors	# 
	syscall	
	addi	$v0, $zero, 1		# print int
	lw	$a0, 32($t0)		# important colors
	syscall
	la	$t0, colorArray
	
	addi 	$v0, $zero, 4		# Syscall 4: Print string
	la   	$a0, tIndexZero		# color at index 0
	syscall
	addi	$v0, $zero, 36		# print int
	lb	$a0, 0($t0)		# first color val
	beqz	$a0, color0white
	addi	$s6, $zero, 1
	j	color0continue
	color0white:
	add	$s6, $zero, $zero
	color0continue:
	andi	$a0, $a0, 0x000000ff
	syscall
	addi 	$v0, $zero, 4		# Syscall 4: Print string
	la   	$a0, spc		# 
	syscall
	addi	$v0, $zero, 36		# print int
	lb	$a0, 1($t0)		# 2nd
	andi	$a0, $a0, 0x000000ff
	syscall
	addi 	$v0, $zero, 4		# Syscall 4: Print string
	la   	$a0, spc		# 
	syscall
	addi	$v0, $zero, 36		# print int
	lb	$a0, 2($t0)		# 3rd
	andi	$a0, $a0, 0x000000ff
	syscall
	
	addi 	$v0, $zero, 4		# Syscall 4: Print string
	la   	$a0, tIndexOne		# 
	syscall	
	addi	$v0, $zero, 36		# print int
	lb	$a0, 4($t0)		# first color val
	beqz	$a0, color1white
	addi	$s7, $zero, 1
	j	color1continue
	color1white:
	add	$s7, $zero, $zero
	color1continue:
	andi	$a0, $a0, 0x000000ff
	syscall
	addi 	$v0, $zero, 4		# Syscall 4: Print string
	la   	$a0, spc		# 
	syscall
	addi	$v0, $zero, 36		# print int
	lb	$a0, 5($t0)		# 2nd
	andi	$a0, $a0, 0x000000ff
	syscall
	addi 	$v0, $zero, 4		# Syscall 4: Print string
	la   	$a0, spc		# 
	syscall
	addi	$v0, $zero, 36		# print int
	lb	$a0, 6($t0)		# 3rd
	andi	$a0, $a0, 0x000000ff
	syscall
	
	# Print Image
	
	# get bytes per row
	div	$t1, $t2		# $t1 / $t2 == raw data size / img height
	mflo	$s2			# $s2 == bytes per row of pixels
	add	$s3, $zero, $t2		# $s3 == img height
	add	$s4, $zero, $zero	# $s4 is counter
	add	$s5, $zero, $zero	# $s5 is current row address
	# $s6 == color index 0 
	# $s7 == color index 1
	readLoop:
	beq	$s4, $s3, readDone	# counter for rows read
	
	# create heap memory
	addi	$v0, $zero, 9		# Syscall 9: allocate heap memory
	add	$a0, $zero, $s2		# $a0 is bytes per row
	syscall				# allocated mem is in $v0
	add	$s5, $zero, $v0
	# read row to heap location
	addi 	$v0, $zero, 14		# Syscall 14: Read file
	add  	$a0, $zero, $s0		# $a0 is the file descriptor
	add   	$a1, $zero, $s5		# $a1 is the address of the buffer
	add 	$a2, $zero, $s2		# $a2 is the number of bytes to read
	syscall				# Read file
	# backup and repeat
	addi	$sp, $sp, -4
	sw	$s5, 0($sp)		# backup the row
	addi	$s4, $s4, 1		# increment counter
	j	readLoop
	readDone:
	add	$s4, $zero, $zero	# reset row counter
	printLoop:			# loop prints 8 rows at a time
	add	$s1, $zero, $zero	# $s1 == pixel counter (cmp to s2, row length)
	beq	$s4, $s3, printDone
	# put 8 rows in t registers
	lw	$t0, 0($sp)
	addi	$sp, $sp, 4
	lw	$t1, 0($sp)
	addi	$sp, $sp, 4
	lw	$t2, 0($sp)
	addi	$sp, $sp, 4
	lw	$t3, 0($sp)
	addi	$sp, $sp, 4
	lw	$t4, 0($sp)
	addi	$sp, $sp, 4
	lw	$t5, 0($sp)
	addi	$sp, $sp, 4
	lw	$t6, 0($sp)
	addi	$sp, $sp, 4
	lw	$t7, 0($sp)
	addi	$sp, $sp, 4
	printRow:
	addi	$s5, $zero, 7		# $s5 is current bit
	beq	$s1, $s2, printRowDone		#
	printByte:
	lbu	$s0, 0($t0)			# $s0 is current pixel 0
	srlv	$s0, $s0, $s5			# shift to get current bit on right
	andi	$s0, $s0, 1			# isolate lsb
	beqz	$s0, pix0zero
	or	$t8, $t8, $s6
	j	pix0done
	pix0zero:
	or	$t8, $t8, $s7
	pix0done:
	sll	$t8, $t8, 1
	
	lbu	$s0, 0($t1)			# $s0 is current pixel 1
	srlv	$s0, $s0, $s5			# shift to get current bit on right
	andi	$s0, $s0, 1			# isolate lsb
	beqz	$s0, pix1zero
	or	$t8, $t8, $s6
	j	pix1done
	pix1zero:
	or	$t8, $t8, $s7
	pix1done:
	sll	$t8, $t8, 1
	
	lbu	$s0, 0($t2)			# $s0 is current pixel 2
	srlv	$s0, $s0, $s5			# shift to get current bit on right
	andi	$s0, $s0, 1			# isolate lsb
	beqz	$s0, pix2zero
	or	$t8, $t8, $s6
	j 	pix2done
	pix2zero:
	or	$t8, $t8, $s7
	pix2done:
	sll	$t8, $t8, 1
	
	lbu	$s0, 0($t3)			# $s0 is current pixel 3
	srlv	$s0, $s0, $s5			# shift to get current bit on right
	andi	$s0, $s0, 1			# isolate lsb
	beqz	$s0, pix3zero
	or	$t8, $t8, $s6
	j	pix3done
	pix3zero:
	or	$t8, $t8, $s7
	pix3done:
	sll	$t8, $t8, 1
	
	lbu	$s0, 0($t4)			# $s0 is current pixel 4
	srlv	$s0, $s0, $s5			# shift to get current bit on right
	andi	$s0, $s0, 1			# isolate lsb
	beqz	$s0, pix4zero
	or	$t8, $t8, $s6
	j	pix4done
	pix4zero:
	or	$t8, $t8, $s7
	pix4done:
	sll	$t8, $t8, 1
	
	lbu	$s0, 0($t5)			# $s0 is current pixel 5
	srlv	$s0, $s0, $s5			# shift to get current bit on right
	andi	$s0, $s0, 1			# isolate lsb
	beqz	$s0, pix5zero
	or	$t8, $t8, $s6
	j	pix5done
	pix5zero:
	or	$t8, $t8, $s7
	pix5done:
	sll	$t8, $t8, 1
	
	lbu	$s0, 0($t6)			# $s0 is current pixel 6
	srlv	$s0, $s0, $s5			# shift to get current bit on right
	andi	$s0, $s0, 1			# isolate lsb
	beqz	$s0, pix6zero
	or	$t8, $t8, $s6
	j	pix6done
	pix6zero:
	or	$t8, $t8, $s7
	pix6done:
	sll	$t8, $t8, 1
	
	lbu	$s0, 0($t7)			# $s0 is current pixel 7
	srlv	$s0, $s0, $s5			# shift to get current bit on right
	andi	$s0, $s0, 1			# isolate lsb
	beqz	$s0, pix7zero
	or	$t8, $t8, $s6
	j	sendByte
	pix7zero:
	or	$t8, $t8, $s7
	
	sendByte:
	addi	$t9, $zero, 1			# printer ready
	wait:
	bnez	$t9, wait
	add	$t8, $zero, $zero		# clear t8
	addi	$s5, $s5, -1			# increment bit counter
	beq	$s5, -1, printByteDone
	j	printByte
	printByteDone:
	addi	$s1, $s1, 1
	addi	$t0, $t0, 1
	addi	$t1, $t1, 1
	addi	$t2, $t2, 1
	addi	$t3, $t3, 1
	addi	$t4, $t4, 1
	addi	$t5, $t5, 1
	addi	$t6, $t6, 1
	addi	$t7, $t7, 1
	j	printRow
	printRowDone:
	# pad row
	sll	$s0, $s2, 3			# $s0 is num of dots written
	padLoop:
	beq	$s0, 480, padDone
	add	$t8, $zero, $zero		# white space
	addi	$t9, $zero, 1			# print
	wait2:
	bnez	$t9, wait2
	addi	$s0, $s0, 1
	j	padLoop
	padDone:
	# inc row counter + 8
	addi	$s4, $s4, 8
	j	printLoop
	printDone:
	addi	$v0, $zero, 10
	syscall