	.data 
array: 				.space 400
string1: 			.asciiz "Nhap do dai mang: "
string_element_open: 		.asciiz "Nhap a["
string_element_close:		.asciiz "]: "
string_open: 			.asciiz "a["
string_close:			.asciiz "] = "
escape_sequence:		.asciiz "\n"
string_input_notification: 	.asciiz "NHAP CAC PHAN TU CUA MANG\n"
string_output_notification:	.asciiz "CAC PHAN TU CUA MANG: "
string_output_sum: 		.asciiz "1. Tong cac phan tu: "
string_output_min: 		.asciiz "2. Phan tu nho nhat: "
string_output_max:		.asciiz "3. Phan tu lon nhat: "
string_output_even:		.asciiz "4. So cac phan tu chan: "
string_output_odd:		.asciiz "5. So cac phan tu le: "
string_space:			.asciiz " "

	.text
 main:
 	li	$t6, 1		# constant value 1
 	li 	$t7, 101 	# over_size = 101, size >= over_size || size <= 0 => read_size_loop
 input:
	 print_input_notification:
 		li 	$v0, 4
 		
 		la 	$a0, string_input_notification
 		syscall
 	# input size of array
 	print_string1:
 		li 	$v0, 4
 
 		la 	$a0, string1
 		syscall 
 	
 	read_size:
 		li 	$v0, 5
 	
 		syscall
 		add 	$s0, $zero, $v0 	# size: $s0
 	
 	check_size:	
 		slt 	$t1, $s0, $t7	# size < 101 ?
 		beq 	$t1, $zero, input
 		
 		slt 	$t1, $s0, $t6 	# size <= 0 ?
 		bne 	$t1, $zero, input
 	read_elements:
 		# index : $t1
 		addi 	$t1, $zero, 0	# index $t1 = 0
 		la	$t3, array 	# load address to $t3
 		read_loop:
 			beq 	$t1, $s0, end_read_loop # index = size => break
 			
 			print_string_element_open:
 				li	$v0, 4
 				
 				la	$a0, string_element_open
 				syscall
 			print_index:
 				li 	$v0, 1
 				
 				add	$a0, $zero, $t1
 				syscall
 			print_string_element_close:
 				li 	$v0, 4
 				
 				la 	$a0, string_element_close
 				syscall
 			read_element:	# $t8 <=> array[$t1]
 				li 	$v0, 5
 				
 				syscall 
 				add 	$t8, $zero, $v0
 				
 				slt 	$t2, $t8, $t6	# arr[index] < 1 ?
 				bne 	$t2, $zero, read_loop
 				
 				sw 	$t8, 0($t3)
 				
 			addi 	$t3, $t3, 4 
 			addi	$t1, $t1, 1
 			j 	read_loop
 		end_read_loop:
 end_input:
 
 output:
 	print_output_notification:
 		li 	$v0, 4
 		
 		la 	$a0, string_output_notification
 		syscall
 		
 	addi 	$t1, $zero, 0 	# index $t1 = 0
 	la 	$t3, array	# load address of array to $t3
 	for_output_array:
 		beq 	$t1, $s0, initialize
 
 		print_element:
 			li 	$v0, 1
 			
 			lw	$t4, 0($t3)
 			add	$a0, $zero, $t4
 			syscall
 		
 		print_space:
 			li 	$v0, 4
 			la	$a0, string_space
 			syscall
 				
 		addi 	$t3, $t3, 4
 		addi 	$t1, $t1, 1
 		j 	for_output_array
 	
 	initialize:
 		li 	$v0, 4
 		la 	$a0, escape_sequence
 		syscall
 		
 		la 	$t3, array 	# t3 = base address of array
 		lw 	$s3, 0($t3)	# sum $s3 = a[0]
 		add 	$s4, $zero, $s3 # min $s4 = a[0]
 		add	$s5, $zero, $s3	# max $s5 = a[0]
 		li	$s6, 0		# num_even $s6 = 0
 		li 	$s7, 0		# num_odd $s7 = 0
 		
 		andi 	$t0, $s3, 1 	# check if a[0] is even ?
 		beq 	$t0, $zero, first_increase_even	# if (a[0] is even) => jump ($s6++) else $s7++
 			addi	$s7, $s7, 1
 			j 	first_skip_increase_even
 		first_increase_even:	
 			addi 	$s6, $s6, 1
 		first_skip_increase_even:
 		
 		addi 	$t3, $t3, 4	# t3 = address of a[1]
 		addi 	$t1, $zero, 1	# index $t1 = 1
 		
 	for:	
 		beq 	$t1, $s0, done
 		
 		lw	$t9, 0($t3)	# $t9 <= a[index]
 		
 		calulate_sum:
 			add	$s3, $s3, $t9
 			
 		find_min:
 			slt 	$t0, $s4, $t9	# $s4 < $t9 ?
 			bne 	$t0, $zero, maximize 	# if $s4 < $t9 => skip minimize (jump into maximize)
 				add 	$s4, $zero, $t9	# $s4 = $t9
 			
 		maximize:
 			slt 	$t0, $s5, $t9	# $s5 < $t9 ? 
 			beq	$t0, $zero, count_odd_even	# if $s5 >= $t9 => skip maximize (jump to count_odd_even)
 				add 	$s5, $zero, $t9
 		count_odd_even:
 			andi	$t0, $t9, 1	# check if $t9 is even ?
 			beq 	$t0, $zero, increase_even	# if ($t9 is even) => $s6++ else $s7++
 				addi	$s7, $s7, 1 
 				j	skip_increase_even
 			increase_even:
 				addi	$s6, $s6, 1	
 			
 			skip_increase_even:
 			
 		addi 	$t3, $t3, 4
 		addi 	$t1, $t1, 1
 		j 	for
 	done:
 		
 	output_sum:
 		print_output_sum:
 			li	$v0, 4
 			la 	$a0, string_output_sum
 			syscall
 		print_sum:
 			li	$v0, 1
 			add 	$a0, $zero, $s3
 			syscall
 		# print_escape_sequence
 		li 	$v0, 4
 		la 	$a0, escape_sequence
 		syscall
 	
 	output_min:
 		print_output_min:
 			li	$v0, 4
 			la 	$a0, string_output_min
 			syscall
 		print_min:
 			li	$v0, 1
 			add 	$a0, $zero, $s4
 			syscall
 		# print_escape_sequence
 		li 	$v0, 4
 		la 	$a0, escape_sequence
 		syscall
 		
 	output_max:
 		print_output_max:
 			li	$v0, 4
 			la 	$a0, string_output_max
 			syscall
 		print_max:
 			li 	$v0, 1
 			add 	$a0, $zero, $s5
 			syscall
 		# print_escape_sequence
 		li 	$v0, 4
 		la 	$a0, escape_sequence
 		syscall
 	
 	output_num_even:
 		print_output_even:
 			li 	$v0, 4
 			la 	$a0, string_output_even
 			syscall
 		print_even:
 			li 	$v0, 1
 			add 	$a0, $zero, $s6
 			syscall
 		# print_escape_sequence
 		li 	$v0, 4
 		la 	$a0, escape_sequence
 		syscall
 		
 	output_num_odd:
 		print_output_odd:
 			li 	$v0, 4
 			la 	$a0, string_output_odd
 			syscall
 		print_odd:
 			li 	$v0, 1
 			add 	$a0, $zero, $s7
 			syscall
 		# print_escape_sequence
 		li 	$v0, 4
 		la 	$a0, escape_sequence
 		syscall
 	
 exit:
 	li 	$v0, 10
 	syscall	
