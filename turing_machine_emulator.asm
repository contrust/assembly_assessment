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
transitions_table:
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
tape_before:
        mov $12, %rax
        xor %rdi, %rdi
        syscall         # Store the address of the tape's end in rax.

	mov %rax, %r13	
	mov %rax, %rbx
	mov %rax, %rdi
        mov $100000, %rdx
	push %r13

        mov $12, %rax
        add %rdx, %rdi
        syscall         # Allocate rdx number of bytes in the heap for the end of the tape.
write_lambda_loop2:
        cmp %rbx, %rdi
        je tape_start
        movb $95, (%rbx)
        inc %rbx
        jmp write_lambda_loop2
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
write_lambda_loop:
	cmp %rbx, %rdi
	je set_initial_values
	movb $95, (%rbx)
	inc %rbx
	jmp write_lambda_loop
set_initial_values:
	pop %r13
	pop %r11
	mov %r14, %r9
	mov $0, %r11
step:
	cmp %r15, %r9
	je stop_transition
	cmp $100000, %r11
	je made_transition
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
	je fail_transition
	
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
	dec %rdx
	mov $current_tape_index, %rax
        mov %rdx, (%rax)
	jmp step
step_right:
        inc %rdx
        mov $current_tape_index, %rax
        mov %rdx, (%rax)
	jmp step
fail_transition:
	push %r9
	push %r11

	mov $fail_after, %rsi
	mov $11, %rdx
	mov $1, %rdi
	mov $1, %rax
	syscall

	pop %r11
	jmp print_rest_of_the_first_line
stop_transition:
        push %r9
        push %r11

        mov $stop_after, %rsi
        mov $11, %rdx
        mov $1, %rdi
        mov $1, %rax
        syscall

        pop %r11
        jmp print_rest_of_the_first_line
made_transition:
        push %r9
        push %r11

        mov $made, %rsi
        mov $5, %rdx
        mov $1, %rdi
        mov $1, %rax
        syscall

        pop %r11
        jmp print_rest_of_the_first_line
print_rest_of_the_first_line:
	mov %r11, %rax
	push %r11
	call convert_to_decimal_start
	pop %r11
        mov $transitions, %rsi
        mov $13, %rdx
        mov $1, %rdi
        mov $1, %rax
        syscall
        jmp print_last_two_lines	
print_last_two_lines:
	
	push %r11
	call print_tape

	mov $newline, %rsi
	mov $1, %rdx
	mov $1, %rdi
	mov $1, %rax
	syscall
	pop %r11
	pop %r9
	call print_current_state

        mov $space, %rsi
        mov $1, %rdx
        mov $1, %rdi
        mov $1, %rax
        syscall

	call print_current_tape_index

	mov $newline, %rsi
        mov $1, %rdx
        mov $1, %rdi
        mov $1, %rax
        syscall

	jmp exit

print_current_tape_index:
	mov leftmost_tape_index, %rbx
	mov rightmost_tape_index, %rcx
	cmp %rbx, %rcx
	je mov_zero_to_rax
	mov current_tape_index, %rax
	sub %rbx, %rax
	cmp $0, %rax
	jge print_current_tape_index_end

	push %rax

        mov $minus, %rsi
        mov $1, %rdx
        mov $1, %rdi
        mov $1, %rax
        syscall
	pop %rax	

	neg %rax
	jmp print_current_tape_index_end
mov_zero_to_rax:
	xor %rax, %rax	
print_current_tape_index_end:
	push %r11
	call convert_to_decimal_start
	pop %r11
	ret 
print_current_state:
	mov $10, %rax
	mul %r9
	add %r10, %rax
	mov %rax, %rbx
	mov %rax, %rdx
	add $10, %rdx
print_current_state_loop:
	cmp %rdx, %rbx
        je print_current_state_loop_end
	cmpb $0, (%rbx)
	je print_current_state_loop_inc
	push %rdx
	mov %rbx, %rsi
	mov $1, %rdx
	mov $1, %rdi
	mov $1, %rax
	syscall
	pop %rdx
print_current_state_loop_inc:
	inc %rbx
	jmp print_current_state_loop
print_current_state_loop_end:
	ret
print_tape:
	push %r11
	mov %r13, %rax
	mov $0, %rbx
	mov $199999, %rcx
find_first_not_empty_element_from_left:
	cmp %rcx, %rbx
	je update_leftmost_tape_index
	cmpb $95, (%rax, %rbx)
	jne update_leftmost_tape_index
	inc %rbx
	jmp find_first_not_empty_element_from_left
update_leftmost_tape_index:
	mov $leftmost_tape_index, %rdx
	mov %rbx, (%rdx)
find_first_not_empty_element_from_right:
	cmp %rcx, %rbx
	je check_for_empty
	mov (%rax, %rcx), %rsi
	cmpb $95, (%rax, %rcx)
	jne inc_rcx
	dec %rcx
	jmp find_first_not_empty_element_from_right
check_for_empty:
        cmpb $95, (%rax, %rcx)
	je _print_tape
inc_rcx:
	inc %rcx
_print_tape:
	mov $rightmost_tape_index, %rdx
        mov %rcx, (%rdx)

	mov %r13, %rsi
	add %rbx, %rsi
	mov %rcx, %rdx
	sub %rbx, %rdx
	mov $1, %rdi
	mov $1, %rax
	syscall
	pop %r11
	ret
convert_to_decimal_start:
	mov $decimal_res, %rdi
	add $decimal_res_len, %rdi
	dec %rdi
convert_to_decimal_loop:
	mov $0, %rdx
	mov $10, %rsi
	div %rsi
	add $48, %dl
	movb %dl, (%rdi)
	mov $0, %rdx
        cmp $decimal_res, %rdi
        je find_first_nonzero_symbol_start
	dec %rdi
	jmp convert_to_decimal_loop
find_first_nonzero_symbol_start:
	mov $decimal_res, %rsi
	mov %rsi, %rdx
	add $decimal_res_len, %rdx
	dec %rdx
find_first_nonzero_symbol_loop:
	cmpb $48, (%rsi)
	jne write
	cmp %rsi, %rdx
	je write
	inc %rsi
	jmp find_first_nonzero_symbol_loop
write:
	sub %rsi, %rdx
	add $2, %rdx
        mov $1, %rax
        mov $1, %rdi
        syscall
	ret
exit:
        mov $60, %rax
	xor %rdi, %rdi
        syscall
.data
current_tape_index:
.quad 100000
fail_after:
.ascii "FAIL after "
made:
.ascii "MADE "
stop_after:
.ascii "STOP after "
transitions:
.ascii " transitions\n"
space:
.ascii " "
newline:
.ascii "\n"
minus:
.ascii "-"
decimal_res: 
.ascii "00000000000000000000"
decimal_res_len=.-decimal_res
.bss
.lcomm buffer, 4
.lcomm leftmost_tape_index, 8
.lcomm rightmost_tape_index, 8
