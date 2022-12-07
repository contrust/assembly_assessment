.globl _start

.text

_start:
	#r8 - an opened file descriptor
	#r9 - the current state
	#r10 - the starting address of states' names
	#r11 - the number of successful transitions
	#r12 - the starting address of transitions table
	#r13 - the starting address of a tape
	#r14 - the initial state
	#r15 - the terminal state

	pop %rdi
	pop %rdi
	pop %rdi	# Store the memory address of the input file path specified as the second parameter in rdi.

	mov $2, %rax
	mov $0, %rsi
	mov $0440, %rdx
	syscall 	# Store the opened file descriptor of the input file in rax.

        mov %rax, %r8
states_names:
        xor %rax, %rax
        mov %r8, %rdi
        mov $buffer, %rsi
        mov $4, %rdx
        syscall 	# Store the number of states in the machine in four_bytes_buffer.

	xor %rdx, %rdx
	mov buffer, %edx	# Store the number of states in rdx.

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
initial_state:
	xor %rax, %rax
        mov %r8, %rdi
        mov $buffer, %rsi
        mov $4, %rdx
        syscall         # Store the initial state in buffer.

        xor %rdx, %rdx
        mov buffer, %edx
	mov %rdx, %r14     # Store the initial state in r14.
terminal_state:
        xor %rax, %rax
        mov %r8, %rdi
        mov $buffer, %rsi
        mov $4, %rdx
        syscall         # Store the terminal state in buffer.

        xor %rdx, %rdx
        mov buffer, %edx
        mov %rdx, %r15     # Store the terminal state in r15.
transitions:
	xor %rax, %rax
        mov %r8, %rdi
        mov $buffer, %rsi
        mov $4, %rdx
        syscall         # Store the number of transitions in buffer.

        mov %r9, %rdx # Store the number of states' names in rdx.

	shl $9, %rdx # Store the number of bytes (11 for a state) for allocation of the transitions table in rdx.

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
tape_start:
	xor %rax, %rax
        mov %r8, %rdi
        mov $buffer, %rsi
        mov $4, %rdx
        syscall         # Store the initial tape's length in buffer.

        xor %rdx, %rdx
        mov buffer, %edx # Store the initial tape's length in rdx.

        mov $12, %rax
        xor %rdi, %rdi
        syscall         # Store the starting address of the tape in rax.

        mov %rax, %r13

        mov $12, %rax
        mov %r13, %rdi
        add %rdx, %rdi
        syscall         # Allocate rdx number of bytes in the heap for the tape.

        xor %rax, %rax
        mov %r8, %rdi
        mov %r13, %rsi
        syscall         # Write the tape in the heap.
tape_end:
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
	pop %r11
write_lambda_loop:
	cmp %rbx, %rdi
	je set_initial_values
	movb $95, (%rbx)
	inc %rbx
	jmp write_lambda_loop
set_initial_values:
	mov %r14, %r9
	mov $0, %r11
step:
	cmp %r15, %r9
	je exit
	cmp $100000, %r11
	je exit
	mov %r13, %rax
	mov current_tape_index, %rbx
	xor %rcx, %rcx
	movb (%rax, %rbx), %cl
	shl $2, %rcx
	mov %r9, %rdx
	shl $9, %rdx
	add %rcx, %rdx
	mov %r12, %rbx
	xor %rcx, %rcx
	movb 2(%rbx, %rdx), %cl
	cmpb $0, %cl
	je exit
	
	push %rcx
	
	inc %r11
	
        movb 0(%rbx, %rdx), %cl
        mov %rcx, %r9
        movb 1(%rbx, %rdx), %cl
        mov %r13, %rbx
        mov current_tape_index, %rdx
        movb %cl, (%rbx, %rdx)

	pop %rcx

	cmpb $1, %cl
	je step_left
	cmpb $2, %cl
	je step
	cmpb $3, %cl
	je step_right
	jmp exit
step_left:
	cmp $0, %rdx
	jne .1
	mov $99999, %rdx
	jmp .2
.1:
	dec %rdx
.2:
	mov $current_tape_index, %rax
        mov %rdx, (%rax)
	mov $leftmost_tape_index, %rax
        cmp (%rax), %rdx
	jg step
	mov %rdx, (%rax)
	jmp step
step_right:
        inc %rdx
        mov $current_tape_index, %rax
        mov %rdx, (%rax)
        mov $rightmost_tape_index, %rax
        cmp (%rax), %rdx
        jl step
        mov %rdx, (%rax)
        jmp step
exit:
	mov %r11, %rdi
        mov $60, %rax
        syscall
.data
current_tape_index:
.quad 0
leftmost_tape_index:
.quad 100000
rightmost_tape_index:
.quad 0
.bss
.lcomm buffer, 4
