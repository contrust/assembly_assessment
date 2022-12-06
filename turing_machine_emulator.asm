.globl _start

.text

_start:
	#r8 - an opened file descriptor
	#r9 - the current state
	#r10 - the starting address of states' names
	#r11 - the number of transitions in a machine
	#r12 - the starting address of transitions table
	#r13 - the starting address of a tape
	#r14 - the initial state
	#r15 - the terminal state

	pop %rdi
	pop %rdi
	pop %rdi	# Store the memory address of the dfa path specified as the second parameter in rdi.

	mov $2, %rax
	mov $0, %rsi
	mov $0440, %rdx
	syscall 	# Store the opened file descriptor of the dfa file in rax.

        mov %rax, %r8

        xor %rax, %rax
        mov %r8, %rdi
        mov $four_bytes_buffer, %rsi
        mov $4, %rdx
        syscall 	# Store the number of states in the machine in four_bytes_buffer.

	xor %rdx, %rdx
	mov four_bytes_buffer, %edx	# Store the number of states in rdx.

	mov %rdx, %r9

	mov $10, %rax
	mul %rdx
	mov %rax, %rdx # Store the number of bytes (10 for a state) for allocation of the states' names in rdx.	

	mov $12, %rax
	xor %rdi, %rdi
	syscall		# Store the starting address of the states' names in rax.

	mov %rax, %r10

	mov $12, %rax
	mov %r10, %rdi
	add %rdx, %rdi
	syscall		# Allocate rdx number of bytes in the heap for the states' names.

	xor %rax, %rax
	mov %r8, %rdi
	mov %r10, %rsi
	syscall		# Write the states' names in the heap.

	xor %rax, %rax
        mov %r8, %rdi
        mov $four_bytes_buffer, %rsi
        mov $4, %rdx
        syscall         # Store the initial state in four_bytes_buffer.

        xor %rdx, %rdx
        mov four_bytes_buffer, %edx
	mov %rdx, %r14     # Store the initial state in r14.

        xor %rax, %rax
        mov %r8, %rdi
        mov $four_bytes_buffer, %rsi
        mov $4, %rdx
        syscall         # Store the terminal state in four_bytes_buffer.

        xor %rdx, %rdx
        mov four_bytes_buffer, %edx
        mov %rdx, %r15     # Store the terminal state in r15.

	xor %rax, %rax
        mov %r8, %rdi
        mov $four_bytes_buffer, %rsi
        mov $4, %rdx
        syscall         # Store the number of transitions in four_bytes_buffer.

        xor %rdx, %rdx
        mov four_bytes_buffer, %edx
        mov %rdx, %r11     # Store the number of transitions in r11.

	mov $11, %rax
	mul %rdx
	mov %rax, %rdx	# Store the number of bytes (11 for a state) for allocation of the transitions table in rdx.

	mov $12, %rax
        xor %rdi, %rdi
        syscall         # Store the starting address of the states' names in rax.

        mov %rax, %r12

        mov $12, %rax
        mov %r12, %rdi
        add %rdx, %rdi
        syscall         # Allocate rdx number of bytes in the heap for the transitions table.

        xor %rax, %rax
        mov %r8, %rdi
        mov %r12, %rsi
        syscall         # Write the transitions table in the heap.

	xor %rax, %rax
        mov %r8, %rdi
        mov $four_bytes_buffer, %rsi
        mov $4, %rdx
        syscall         # Store the initial tape's length in four_bytes_buffer.

        xor %rdx, %rdx
        mov four_bytes_buffer, %edx # Store the initial tape's length in rdx.

        mov $12, %rax
        xor %rdi, %rdi
        syscall         # Store the starting address of the states' names in rax.

        mov %rax, %r13

        mov $12, %rax
        mov %r13, %rdi
        add %rdx, %rdi
        syscall         # Allocate rdx number of bytes in the heap for the transitions table.

        xor %rax, %rax
        mov %r8, %rdi
        mov %r13, %rsi
        syscall         # Write the transitions table in the heap.

	mov $12, %rax
        xor %rdi, %rdi
        syscall         # Store the address of the tape's end in rax.

	mov %rax, %rdi
	mov %rdi, %rbx

	mov %rdx, %rax
	mov $100000, %rdx
	sub %rax, %rdx	# Store the number of bytes to make tape's length equal 100000.

        mov $12, %rax
        add %rdx, %rdi
        syscall         # Allocate rdx number of bytes in the heap for the end of the tape.

write_zero_loop:
	cmp %rbx, %rdi
	je play
	movb $0, (%rbx)
	inc %rbx
	jmp write_zero_loop
play:
	
exit:
        mov $60, %rax
	xor %rdi, %rdi
        syscall
.bss
.lcomm four_bytes_buffer, 4
