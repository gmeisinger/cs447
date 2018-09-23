.data
	filename:	.asciiz	"testFile.bin"
	firstTwo:	.space	2
	.align 2
	lastTwelve:	.space	12
.text
	# Open file
	addi $v0, $zero, 13		# Syscall 13: Open file
	la   $a0, filename		# $a0 is the address of filename
	add  $a1, $zero, $zero		# $a1 = 0
	add  $a2, $zero, $zero		# $a2 = 0
	syscall				# Open file
	add  $s0, $zero, $v0		# Copy the file descriptor to $s0
	# Read the first two bytes
	addi $v0, $zero, 14		# Syscall 14: Read file
	add  $a0, $zero, $s0		# $a0 is the file descriptor
	la   $a1, firstTwo		# $a1 is the address of a buffer (firstTwo)
	addi $a2, $zero, 2		# $s2 is the number of bytes to read
	syscall				# Read file
	la   $s1, firstTwo		# Set $s1 to the address of firstTwo
	addi $v0, $zero, 11		# Syscall 11: Print character
	lb   $a0, 0($s1)		# $a0 is the first byte of firstTwo
	syscall				# Print a character
	lb   $a0, 1($s1)		# $a0 is the second byte of firstTwo
	syscall				# Print a character
	# Read the last twelve bytes
	addi $v0, $zero, 14		# Syscall 14: Read file
	add  $a0, $zero, $s0		# $a0 is the file descriptor
	la   $a1, lastTwelve		# $a1 is the address of a buffer (lastTwelve)
	addi $a2, $zero, 12		# $s2 is the number of bytes to read
	syscall				# Read file
	la   $s1, lastTwelve		# Set $s1 to the address of lastTwelve
	addi $v0, $zero, 1		# Syscall 1: Print integer
	lw   $a0, 0($s1)		# $a0 is the first 4-byte integer
	syscall				# Print an integer
	lh   $a0, 4($s1)		# $a0 is the first 2-byte integer
	syscall				# Print an integer
	lh   $a0, 6($s1)		# $a0 is the second 2-byte integer
	syscall				# Print an integer
	lw   $a0, 8($s1)		# $a0 is the second 4-byte integer
	syscall				# Print an integer
	# Close file
	add  $v0, $zero, 16		# Syscall 16: Close file
	add  $a0, $zero, $s0		# $a0 is the file descriptor
	syscall				# Close file
	# Terminate Program
	addi $v0, $zero, 10		# Syscall 10: Terminate program
	syscall				# Terminate program