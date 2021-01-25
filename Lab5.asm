#-------------------------------------------------------------------------
# Created by:  Doddi, Chidvi
#              cdoddi
#              1st June 2019
#
# Assignment:  Lab 5: A Gambling Game
#              CMPE 012, Computer Systems and Assembly Language
#              UC Santa Cruz, Spring 2019
# 
# Description: This program is responsible for resembling a guessing game based on what numbered option (1-3) the user decides to enter.
# 
# Notes:       This file is able to run alone or with the given test file.
#-------------------------------------------------------------------------

jal end_game                    # this is to prevent the rest of
                                   # the code executing unexpectedly

#--------------------------------------------------------------------
# play_game
#
# This is the highest level subroutine.
#
# arguments:  $a0 - starting score
#             $a1 - address of array index 0 
#
# return:     n/a
#--------------------------------------------------------------------
#
# REGISTER USE
# $t9: stores the address of the randomly generated array
# $t2: stores the initial and updated scores
# $v0: syscalls
# $a0: starting/initial score
# $a1: address of the randomly generated array
#--------------------------------------------------------------------

.text
play_game: nop
    
	# some code                    	# use $a1 to get the number of elements in the array
     
     	#move $t4, $a0
     	move $t2, $a0			# moves the value of the current score
     	move $a0, $a1
     	move $t9, $a1
     
    	jal get_array_size
    
    	move $a0, $v0
    
    	jal   welcome
    
	b label
    
    	label:
    
    		#jal get_array_size
    
   		jal   prompt_options
    
         	# some code
  
   		move $s6, $a0
    
    	 	jal   take_turn
    	 
    	 	b label
    
    	 	jr $ra
    
    	 #Tests:
    	 #play_again_label:
    
    	 #jal prompt_options 
    	 #jr $ra

#--------------------------------------------------------------------
# welcome (given)
#
# Prints welcome message indicating valid indices.
# Do not modify this subroutine.
#
# arguments:  $a0 - array size in words
#
# return:     n/a
#--------------------------------------------------------------------
#
# REGISTER USE
# $t0: array size
# $a0: syscalls
# $v0: syscalls
#--------------------------------------------------------------------

.data
welcome_msg: .ascii "------------------------------"
             .ascii "\nWELCOME"
             .ascii "\n------------------------------"
             .ascii "\n\nIn this game, you will guess the index of the maximum value in an array."
             .asciiz "\nValid indices for this array are 0 - "

end_of_msg:  .asciiz ".\n\n"

             
.text
welcome: nop

    add   $t0  $zero  $a0         # save address of array

    addiu $v0  $zero  4           # print welcome message
    la    $a0  welcome_msg
    syscall
    
    addiu $v0  $zero  1           # print max array index
    sub   $a0  $t0    1
    syscall

    addiu $v0  $zero  4           # print period
    la    $a0  end_of_msg
    syscall
    
    jr $ra
    
    
#--------------------------------------------------------------------
# prompt_options (given)
#
# Prints user options to screen.
# Do not modify this subroutine. No error handling is required.
# 
# return:     $v0 - user selection
#--------------------------------------------------------------------
#
# REGISTER USE
# $v0, $a0: syscalls
# $t0:      temporarily save user input
#--------------------------------------------------------------------

.data
turn_options: .ascii  "------------------------------" 
              .ascii  "\nWhat would you like to do? Select a number 1 - 3"
              .ascii  "\n"
              .ascii  "\n1 - Make a bet"
              .ascii  "\n2 - Cheat! Show me the array"
              .asciiz "\n3 - Quit before I lose everything\n\n"
              

#array_init: .word 1,5,6,8,9,0 	# array that was created to test the program; you have to add the 0 in at the end manually or then there would not be a null terminator 

.text
prompt_options: nop

    addiu $v0  $zero  4           # print prompts
    la    $a0  turn_options       
    syscall

    addiu $v0  $zero  5           # get user input
    syscall
    
    add   $t0  $zero  $v0         # temporarily saves user input to $t0
    
    addiu $v0  $zero  11
    addiu $a0  $zero  0xA         # print blank line
    syscall

    add   $v0  $zero  $t0         # return player selection
    jr    $ra


#--------------------------------------------------------------------
# take_turn	
#
# All actions taken in one turn are executed from take_turn.
#
# This subroutine calls one of following sub-routines based on the
# player's selection:
#
# 1. make_bet
# 2. print_array
# 3. end_game
#
# After the appropriate option is executed, this subroutine will also
# check for conditions that will lead to winning or losing the game
# with the nested subroutine win_or_lose.
# 
# arguments:  $a0 - current score
#             $a1 - address of array index 0 
#             $a2 - size of array (this argument is optional)
#             $a3 - user selection from prompt_options
#
# return:     $v0 - updated score
#--------------------------------------------------------------------
#
# REGISTER USE
# $t9: stores the address of the randomly generated array
# $t2: stores the initial and updated scores
# $v0: syscalls
# $a0: current score
# $a1: address of array index 0 
# $a2: the array size (from register $t4)
# $a3: user selection from prompt_options
#--------------------------------------------------------------------
.text
take_turn: nop

	subi   $sp   $sp  4          # push return address to stack
	sw     $ra  ($sp)
    
	move $a3, $v0
    
	# to decide which of the three labels (destinations) to go to, based on the user's input:
	beq $a3, 2, print_array_label 
	beq $a3, 3, end_game
    
	# some code
    
	# if the user chooses the first option (option 1):
	jal    make_bet
    
	# TEST:
	#jal    win_or_lose
    
	# some code
  
	#jal end_game

	lw    $ra  ($sp)            # pop return address from stack
	addi  $sp   $sp   4
	
	#--------------------------------
	li     $v0   0xaabbccdd     # setting test return value, REMOVE THIS LINE
	#--------------------------------
        
	jr $ra
    
	print_array_label: 	# label for the print_array method call 
    
		jal    print_array
    
		jal   prompt_options
    
    		# some code
  
   		move $s6, $a0
    
   		jal   take_turn

#--------------------------------------------------------------------
# make_bet
#
# Called from take_turn.
#
# Performs the following tasks:
#
# 1. Player is prompted for their bet along with their index guess.
# 2. Max value in array and index of max value is determined.
#    (find_max subroutine is called)
# 3. Player guess is compared to correct index.
# 4. Score is modified
# 5. If player guesses correctly, max value in array is either:
#    --> no extra credit: replaced by -1
#    --> extra credit:    removed from array
#  
# arguments:  $a0 - current score of user
#             $a1 - address of first element in array
#
# return:     $v0 - updated score
#--------------------------------------------------------------------
#
# REGISTER USE
# $t9: stores the address of the randomly generated array
# $t2: stores the initial and updated scores
# $v0: syscalls
# $a0: current score of user
# $a1: address of first element in array
# $s0: user index guess
# $s5: user bet
#--------------------------------------------------------------------

.data
bet_header:   .ascii  "------------------------------"
              .asciiz "\nMAKE A BET\n\n"
            
score_header: .ascii  "------------------------------"
              .asciiz "\nCURRENT SCORE\n\n"
            
# add more strings

.text
make_bet: nop       
    
	subi   $sp   $sp  4
	sw     $ra  ($sp)
	
	subi $sp $sp 8
	sw $s0, ($sp)
	sw $s5, ($sp)
	
         # some code
         move $s5, $a0
         move $s0, $a1
    	
         addiu  $v0  $zero  4           # print header
         la     $a0  bet_header
	syscall
    	
    	move $a0, $a1
    	
	#jal init_points_label 	 # responsible for controlling the score in the game:	
    	
    	jal get_array_size
    	
    	move $a0, $s5
	jal prompt_bet

	move $s0, $v1 		 # $s0 - player index guess [put it in a temporary and unused register]
    
	jal find_max
    
    	move $t9, $a1
	move $a1, $v0  		 # $a1 - index of the maximum element in the array
	move $a0, $s0 		 # now $a0 - player index guess
    
	jal compare
   
	move $a0, $a1
	move $a2, $v0			# boolean value from compare subroutine
	#move $a0, $t2			# $t7 keeped track of the score before
	move $a1, $t5
   
	jal mod_score
   
	addiu  $v0  $zero  4           # print header
	la     $a0  score_header
	syscall
   	
	# to print the new score stored in $a0:
  	li  $v0 1 		# using syscall 1
  	add $a0, $zero, $t2	# use add here instead of addi due to no immediate value
  	syscall
  	 
	# to print out "pts" (with a space before):
 	li $v0, 11
 	la $a0, 0x20
 	syscall
  	la $a0, 0x70		# 'p'
  	syscall
  	la $a0, 0x74
  	syscall
  	la $a0, 0x73
  	syscall
  	   
         # to print a new line:
	li $v0, 11
  	la $a0, 0x0A 
  	syscall
  	 	
      
    	# to print a new line:
	li $v0, 11
  	la $a0, 0x0A 
  	syscall
   
  
   	beq $t2, 0, win_or_lose		# checks if the score is 0 (YOU LOSE!)
   	beq $t2, 200, win_or_lose	# checks if the score is greater than 200 (YOU WON!)
   
  
   	# $t8 - the index of max element
  	# $t1 - address of array index 0
   	move $a0, $t1
   	move $a1, $t8
   
   	jal mod_array
   
   	# pop
	lw $s0, ($sp)
	lw $s5, 4($sp)
	addi $sp $sp 8
	
    	lw     $ra  ($sp)
    	addi   $sp   $sp  4

    	#--------------------------------
    	#li     $v0   0xc0ffeeee        # setting test return value, REMOVE THIS LINE
    	#--------------------------------
	
   	 jr     $ra
    
    	jump_back:
    
    		jr $ra
    
    	score_not_init: # for the updated scores
    	
    		move $s3, $t2 
    

#--------------------------------------------------------------------
# find_max
#
# Finds max element in array, returns index of the max value.
# Called from make_bet.
# 
# arguments:  $a0 - address of first element in array
#
# returns:    $v0 - index of the maximum element in the array
#             $v1 - value of the maximum element in the array
#--------------------------------------------------------------------
#
# REGISTER USE
# $t9: stores the address of the randomly generated array
# $t2: stores the initial and updated scores
# $v0: syscalls and the index of the maximum element in the array
# $v1: the value of the maximum element in the array
# $t3: temporary register that helps iterate over the array elements
# $t6: temporary register that helps iterate over the array elements
# $s1: temporary variable for the comparions
# $s2: temporary variable for the comparions
# $s3: temporary variable for the comparions
# $s5: temporary variable for the comparions
#--------------------------------------------------------------------

.text
find_max: nop

subi $sp $sp 16
sw $s1, ($sp)
sw $s2, 4($sp)
sw $s3, 8($sp)
sw $s5, 12($sp)

  #la $a0, array_init
    	         
		addi $t4, $zero, 0 			# t4- previous bit
		addi $t6, $zero, 0 			# t6- next bit
		
		move $a0, $t9				# move the array address to $a0 from $a1
			
  	 	increment_loop:
  	 		lw $t3, ($a0) 			# t2- stores each of the bits of the program argument
  	 		#addi $t8, $t8, 1	
			beqz $t3, endIncrement 		# if this is 0, end the increment because we reached the end of the program argument
  	 		
  	 		addi $a0, $a0, 4			# increments the current bits in the program argument by 4 in order to jump to the next bit
  	 		lw $t6, 0($a0) 			# t2- stores each of the bits of the program argument
  	 		#addi $t9, $t9, 1		
  	 		b compare_loop
  	 	
  	 		#to jump back to the beginning of the loop:
  	 		b increment_loop
  	 	
  	 	b end
  	 	
  	 	t6_max_element:
  	 	move $s1, $t6
  	 	
  	 	#beqz $t3, the_actual_max_check
  	 	
  	 	b increment_loop
    	         
    	         compare_loop:
    	         	bgt $t6, $t3, t6_max_element
    	         	
    	         	move $s2, $t3
    	         	addi $t8, $t8, 1
    	         	addi $s5, $s5, 1	
    	         	
    	         	#beqz $t3, the_actual_max_check
    	         	
    	         	b increment_loop 
    	         	
    	         endIncrement:				# comes here if the counters reached a null value in the array (0)
    	         
    	         s1_max_element:
  	 	
  	 		# if $s1 is the max.:
  	 		move $v1, $s1
  	 		move $a2, $s3 
  	 		move $s3, $t8
  	 	
  	 		b first_element_is_max_check
  	 	
  	 	b end 	#like a placeholder
  	 	
  	 	the_actual_max_check:
  	 		bgt $s1, $s2, s1_max_element
  	 	
  	 		# if $s2 is the max.:
  	 		move $v1, $s2
  	 		move $s4, $t5
  	 	
  	 		b first_element_is_max_check
    	         
    	         end:
    
  		#li $v0 0xdeadbeef       			# setting test return values, remove these 2 lines
   		#li $v1 0xbaadcafe
		
		first_element_is_max_check:
		
			#la $a0, array_init
			lw $t7, 0($a0) 			# loads the first element of the array
			bgt $t7, $v1, first_element_is_max
    	         
    	         	 # to print the max value stored in $v1:
  	 	 	#	li $v0 1 		# using syscall 1
  	 	 	#	add $a0, $zero, $v1	# use add here instead of addi due to no immediate value
  	 	 	#	syscall
   		
   			b exit 	#the next destination
    	         	
   		# some code
   		
   		# b first_element_is_max_check # to stop it from going to the label below by default
   		
   		first_element_is_max:
   		
			move $v1, $t7
  	 		
  	 	exit:
  	 	
  	 		addi $t8, $zero, 0		# index variable
  	 		#la $a0, array_init
  	 	
  	 	index_find_loop: 				# loop to find the index of themax value
  	 		lw $s5, ($a0)	
  	 		addi $t8, $t8, 1
  	 		beq $v1, $s5, endIncrement1	# compares the value of the max value with the current value in the array
  	 		beqz $s5, exit1
  	 		addi $a0, $a0, 4
  	 		b index_find_loop			# jumps back to the beginning of the loop
  	 		
  	 	endIncrement1: 
  	 		subi $t8, $t8, 1
  	 		move $v0, $t8
  	 	
  	 		# AT THE END OF THIS SUBROUTINE:
			# $v0 - index of max element
			# $v1 - value of max element
  	 	
  	 	exit1: 	
  	 					# this will probably never get executed
			lw $s1, ($sp)
			lw $s2, 4($sp)
			lw $s3, 8($sp)
			lw $s5, 12($sp)
			addi $sp, $sp 16	
    			jr     $ra			# it is is a must to have this when you use the jal keyword with the method calls 


#--------------------------------------------------------------------
# win_or_lose
#
# After turn is taken, checks to see if win or lose conditions
# have been met
# 
# arguments:  $a0 - address of the first element in array
#             $a1 - updated score
#
# return:     n/a
#--------------------------------------------------------------------
#
# REGISTER USE
# $t9: stores the address of the randomly generated array
# $t2: stores the initial and updated scores
# $v0: syscalls
#--------------------------------------------------------------------

.data
win_msg:  .ascii   "------------------------------"
          .asciiz  "\nYOU'VE WON! HOORAY! :D\n\n"

lose_msg: .ascii   "------------------------------"
          .asciiz  "\nYOU'VE LOST! D:\n\n"

.text
win_or_lose: nop

    # some code
    bge $t2, 200, win_label
    beq $t2, 0, lose_label
    
    jr $ra
    
    # some code
    win_label:
    
    addiu  $v0  $zero  4
    la     $a0  win_msg
    syscall
    
    j end_game

    lose_label:
    
    addiu  $v0  $zero  4
    la     $a0  lose_msg
    syscall
    
    j end_game

#--------------------------------------------------------------------
# print_array
#
# Print the array to the screen. Called from take_turn
# 
# arguments:  $a1 - address of the first element in array
#--------------------------------------------------------------------
#
# REGISTER USE
# $t9: stores the address of the randomly generated array
# $t2: stores the initial and updated scores
# $v0: syscalls
# $s3: temporary register that helps iterate over the array elements
# $t8: counter for the loop(s)
#--------------------------------------------------------------------

.data
cheat_header: .ascii  "------------------------------"
              .asciiz "\nCHEATER!\n\n"

.text
print_array: nop

    # some code
    
    addiu  $v0  $zero  4           # print header
    la     $a0  cheat_header
    syscall
  	 	
		addi $t8, $zero, 0 	# t5- counter for the indexes
		
		#la $a1, array_init
		
		#move $a0, $a1 
		#move $a1, $t5
		
  	 	increment_:
  	 		# addi $t4, $t4, 1 		# increments the bit counter by 1
  	 		
  	 		lw $s3, ($a1) 		# s3- stores each of the bits of the program argument
  	 		
  	 		beqz $s3, endIncrem 	# if this is 0, end the increment because we reached the end of the program argument
  	 		
  	 		# to print the current value of $t8:
  	 		li $v0 1 		# using syscall 1
  	 		add $a0, $t8, $zero
  	 		syscall
  	 		 
  	 		#to print a colon:
			li $v0, 11
  	 		la $a0, 0x3A  
  	 		syscall
  	 	
  	 		#to print a space:
			li $v0, 11
  	 		la $a0, 0x20
  	  		syscall
  	  		
  	  		
  	  		li $v0, 1
  	  		add $a0, $s3, $zero
  	  		syscall
  	  		
  	  		
			#to print a new line:
			li $v0, 11
  	 		la $a0, 0x0A  
  	 		syscall
  	  		
  	  		addi $a1, $a1, 4
  	  		addi $t8, $t8, 1
  	  		
  	  		j increment_
  	 		
output_loop:

			#Code that outputs the current value stored in $s3 to the user: 
			#bge $s3 100000000000 twelvenum 		# checks if the number is less than 100000000000
			#bge $s3 10000000000 elevennum 		# checks if the number is less than 10000000000
			bge $s3 1000 threenum 			# checks if the number is less than 1000
			bge $s3 100 threenum 			# checks if the number is less than 100
			bge $s3 10 twonum 			# checks if the number is less than 10
			bge $s3 0 onenum 				# checks if the number is less than 0

	
			fournum:
				li $t5 1000
				j asciiloop 		# jumps to the ascii loop after it determined what the number is
	
			threenum:
				li $t5 100
				j asciiloop 		# jumps to the ascii loop after it determined what the number is
	
			twonum:
				li $t5 10
				j asciiloop 		# jumps to the ascii loop after it determined what the number is
	
			onenum: 		# in this, we don't need to jump to ascii loop
				li $t5 1 

			asciiloop:	# converts the valude to an ascii value so it can be printed
				#beq $t5, $a1, max_element_found
				beq $t5 1 final_print
				div $t8 $s3 $t5
				rem $s3 $s3 $t5
				div $t5 $t5 10

				li $v0 11 	# syscall for printing
				add $t8 $t8 0x30
				la $a0 ($t8)
				syscall
				j asciiloop 	# jumps back to the asciiloop after the iteration is done
	
			final_print:
				
				li $v0 11 	# syscall for printing
				add $s3 $s3 0x30
				la $a0 ($s3)
				syscall
				
				#to print a newline:
				li $v0, 11
   				la $a0, 0x0A  
   				syscall
  	 	
  	 			addi $t8, $t8, 1 		# increments the bit counter by 1
  	 		
  	 			addi $a1, $a1, 4		# increments the current bits in the program argument by 4 in order to jump to the next bit
  	 	
  	 			#to jump back to the beginning of the loop:
  	 			b increment_
  	 		
  	 		endIncrem:
  	 		
  	 		#to print a newline:
			li $v0, 11
   			la $a0, 0x0A  
   			syscall
   				
  	 		move $a0, $t4
  	 		move $v1, $t4
    	
    jr     $ra

#--------------------------------------------------------------------
# end_game (given)
#
# Exits the game. Invoked by user selection or if the player wins or
# loses.
#
# arguments:  $a0 - current score
#
# returns:    n/a
#--------------------------------------------------------------------
#
# REGISTER USE
# $t9: stores the address of the randomly generated array
# $t2: stores the initial and updated scores
# $v0: syscalls
#--------------------------------------------------------------------

.data
game_over_header: .ascii  "------------------------------"
                  .ascii  " GAME OVER"
                  .asciiz " ------------------------------"

.text
end_game: nop

    add   $s0  $zero  $a0              # save final score

    addiu $v0  $zero  4                # print game over header
    la    $a0  game_over_header
    syscall
    
    addiu $v0  $zero  11               # print new line
    addiu $a0  $zero  0xA
    syscall
    
    addiu $v0  $zero  10               # exit program cleanly
    syscall


#--------------------------------------------------------------------
# OPTIONAL SUBROUTINES
#--------------------------------------------------------------------
# You are permitted to delete these comments.

#--------------------------------------------------------------------
# get_array_size (optional)
# 
# Determines number of 1-word elements in array.
#
# argument:   $a0 - address of array index 0
#
# returns:    $v0 - number of 1-word elements in array
#--------------------------------------------------------------------
#
# REGISTER USE
# $t9: stores the address of the randomly generated array
# $t2: stores the initial and updated scores
# $v0: syscalls
# $t4: counter to store the array size
# $t3: temporary register that helps iterate over the array elements
#--------------------------------------------------------------------

	get_array_size: nop # method header
		#subi $sp, $sp, 4
		#sw $s3, ($sp)
		
		#la $a1, array_init # loads all the elements from array_init into $a1
		
		move $a0, $t9
		
		addi $t4, $zero, 0 	# t4- counter for the number of bits in the argument
		
  	 	incrementer_loop:
  	 		# addi $t4, $t4, 1 	# increments the bit counter by 1
  	 		
  	 		lw $t3, ($a0) 		# t2- stores each of the bits of the program argument
			beqz $t3, endIncrementer 	# if this is 0, end the increment because we reached the end of the program argument
  	 		
  	 		addi $t4, $t4, 1 		# increments the bit counter by 1
  	 		
  	 		addi $a0, $a0, 4		# increments the current bits in the program argument by 4 in order to jump to the next bit
  	 	
  	 	
  	 		#to jump back to the beginning of the loop:
  	 		j incrementer_loop
  	 	
  	 	endIncrementer:
  	 		move $v0, $t4
					 # the welcome label uses this value for the upper bound of the valid indices of the array
  	 		
  	 		# AT THE END OF THIS SUBROUTINE:
  	 		# v0 - number of elements in the array
  	 		 
  	 		#lw $s3, ($sp)
  	 		#addi $sp, $sp, 4
  	 		
  	 		jr $ra
  	 		
#--------------------------------------------------------------------
# prompt_bet (optional)
#
# Prompts user for bet amount and index guess. Called from make_bet.
# 
# arguments:  $a0 - current score
#             $a1 - address of array index 0
#             $a2 - array size in words
#
# returns:    $v0 - user bet
#             $v1 - user index guess
#--------------------------------------------------------------------
#
# REGISTER USE
# $t9: stores the address of the randomly generated array
# $t2: stores the initial and updated scores
# $t5: stores the user-inputted bet value
# $t6: stores the user-inputted bet value
# $v0: syscalls
# $t5: user inputted bet
# $s0: user index guess
# $a0: current score
# $a1 - address of array index 0
# $a2 - array size in words
#--------------------------------------------------------------------

.data
current_score_statement_part1: "You currently have "
current_score_statement_part2: " points"
bet_required_prompt: .asciiz "How many points would you like to bet"
bet_error_prompt: .asciiz "Sorry, your bet exceeds your current worth"
index_required_prompt: .asciiz "Valid indices for this array are 0 - "
index_required_prompt2: .asciiz "Which index do you believe contains the maximum value"

.text

prompt_bet: nop

	# move $t2, $t3
	
	prompt_bet_loop:
	
	 	addiu $v0  $zero  4           # print the required message
   	 	la    $a0  current_score_statement_part1
   	 	syscall
   	 
   	 	li $v0 1
   	 	add $a0, $t2, $zero
   	 	syscall	
   	 
   	 	#move $a0, $s3		# makes $a0 the score holder
  	 	
   	 	addiu $v0  $zero  4           # print the required message
   	 	la    $a0  current_score_statement_part2
   	 	syscall	
   	 
   	 	# to print a period:
   		li $v0, 11
  	 	la $a0, 0x2E 
  	 	syscall
  	 	
 	 	#add   $t0  $zero  $a0         # save address of array
 	 
 	 	# to print a new line:
		li $v0, 11
  	 	la $a0, 0x0A  
  	 	syscall
  	 	
	 	addiu $v0  $zero  4           # print the 1st required message
   	 	la    $a0  bet_required_prompt
   	 	syscall
   	 
		# to print a question mark:
		li $v0, 11
  	 	la $a0, 0x3F 
  	 	syscall
  	 
  	 	# to print a space:
		li $v0, 11
  	 	la $a0, 0x20
  	  	syscall
  	  		
  	  	# to get user input:
		li $v0, 5 
		syscall
		
		# to store the user-inputted bet value:
  	 	move $t6, $v0
  	 	move $t5, $v0
  	 
  		bgt $t6, $t2, if_error_output_label
  	 
  		b index_out
  	 
  	index_out:
		
		# to print a new line:
		li $v0, 11
  	 	la $a0, 0x0A  
  	 	syscall
  	 	
  	 	addiu $v0  $zero  4           # print the 2nd required message
   	 	la    $a0  index_required_prompt
   	 	syscall

    		# to print the current value of $t4, the array size:
    		addiu $v0  $zero  1           # print max array index
    		sub   $a0  $t4    1
   		syscall
  	 	
      		# to print a period:
   		li $v0, 11
  	 	la $a0, 0x2E 
  	 	syscall
       	 
    		# to print a new line:
		li $v0, 11
  	 	la $a0, 0x0A  
  	 	syscall
  	 	
 	 	addiu $v0  $zero  4           # print the 1st required message
   	 	la $a0 index_required_prompt2
   	 	syscall
   	 
		# to print a question mark:
		li $v0, 11
  	 	la $a0, 0x3F 
  	 	syscall
  	 
  	 	#to print a space:
		li $v0, 11
  	 	la $a0, 0x20
  	  	syscall
  	  		
  	  	#to get user input:
		li $v0, 5 
		syscall
		
		# to store the user-inputted index guess:
	  	move $s5, $v0
		
		#to print a new line:
		li $v0, 11
  	 	la $a0, 0x0A  
  	 	syscall
  	 	
  	 	move $v0, $s4
  	 	move $v1, $s5
  	 	
  		# AT THE END OF THIS SUBROUTINE:
  		# $v0 - the user bet
  		# $v1 - user index guess
	
  	 	jr $ra	
	
	if_error_output_label: 
  	 
  	 	# to print a new line:
		li $v0, 11
  	 	la $a0, 0x0A  
  	 	syscall
  	 	
  	 	addiu $v0  $zero  4           # print the required message
   	 	la    $a0  bet_error_prompt
   	 	syscall	
   	 
   	 	# to print a period:
   		li $v0, 11
  	 	la $a0, 0x2E
  	 	syscall 
  	 	
  	 	# to print a new line:
		li $v0, 11
  		la $a0, 0x0A  
  		syscall
  	 
  	 	# to print a new line:
		li $v0, 11
  	 	la $a0, 0x0A  
  	 	syscall
  	 	
  	 b prompt_bet_loop
	
#--------------------------------------------------------------------
# compare (optional)
#
# Compares user guess with index of largest element in array. Called
# from make_bet.
#
# arguments:  $a0 - player index guess
#             $a1 - index of the maximum element in the array
#
# return:     $v0 - 1 = correct guess, 0 = incorrect guess
#--------------------------------------------------------------------
#
# REGISTER USE
# $t9: stores the address of the randomly generated array
# $t2: stores the initial and updated scores
# $v0: syscalls and the boolean value of comparison
# $t5: user inputted bet
# $s0: user index guess
# $a0: player index guess
# $a1: index of the maximum element in the array
#--------------------------------------------------------------------

compare: nop

	beq $a0, $a1, v0_equals_1

	li $v0, 0

	# AT THE END OF THIS SUBROUTINE:
	# v0 is 0 or 1 based on the user's guess

	jr $ra

	v0_equals_1: 	# if a correct guess
		li $v0, 1 
   	 
		jr $ra

#--------------------------------------------------------------------
# mod_score (optional)
#
# Modifies score based on outcome of comparison between user guess
# correct answer. Returns score += bet for correct guess. Returns
# score -= bet for incorrect guess. Called from make_bet.
# 
# arguments:  $a0 - current score
#             $a1 - player’s bet
#             $a2 - boolean value from comparison
#
# return:     $v0 - updated score
#--------------------------------------------------------------------
#
# REGISTER USE
# $t9: stores the address of the randomly generated array
# $t2: stores the initial and updated scores
# $v0: syscalls
# $t5: user inputted bet
# $s0: user index guess
# $a0 - current score
#             $a1 - player’s bet
#             $a2 - boolean value from comparison
#
#--------------------------------------------------------------------

.data
correct_guess_part1: .asciiz  "Score"
correct_guess_part2: .asciiz "Index "
correct_guess_part3: .asciiz " has the maximum value in the array"
points_earned_prompt_part1: "You earned "
points_earned_prompt_part2: .asciiz " points"
mod_array_prompt: .asciiz "This value has been removed from the array"
wrong_guess_part1: .asciiz "Your guess is incorrect"
wrong_guess_part2: .asciiz " The maximum value is not in index "
wrong_guess_conseq_part1: "You lost"
wrong_guess_conseq_part2: .asciiz " points"
#
# REGISTER USE
# $s5: user index guess
# $v0: syscalls
#--------------------------------------------------------------------
#
# REGISTER USE
# $t9: stores the address of the randomly generated array
# $t2: stores the initial and updated scores
# $v0: syscalls
# $t5: user inputted bet
# $s0: user index guess
# $a0: current score
# $a1: player’s bet
# $a2: boolean value from comparison
#
#--------------------------------------------------------------------
.text
mod_score: nop

beq $a2, 1, score_increment_and_output
  	
  	  	 addiu $v0  $zero  4           # print the required message
   	 	 la    $a0  wrong_guess_part1
   	 	 syscall		
  	 
  	 	 # to print an exclamation mark:
		 li $v0, 11
  	 	 la $a0, 0x21 
  	 	 syscall
  	 		
  	 	 addiu $v0  $zero  4           # print the required message
   	 	 la    $a0  wrong_guess_part2
   	 	 syscall	

		 # to print the user index guess stored in $s5 (currently):
  	 	 li $v0 1 		# using syscall 1
  	 	 add $a0, $zero, $s0	# use add here instead of addi due to no immediate value
  	 	 syscall
  	 	 	
  	 	 # to print a period:
   		 li $v0, 11
  	 	 la $a0, 0x2E 
  	 	 syscall 
  	 	
  	 	 # to print a new line:
		 li $v0, 11
  	 	 la $a0, 0x0A 
		 syscall
    	
    		 #to print a new line:
		 li $v0, 11
  	 	 la $a0, 0x0A  
  	 	 syscall
  	 	
    		 addiu $v0  $zero  4           # print the required message
   	 	 la    $a0  wrong_guess_conseq_part1
   	 	 syscall		
   	 
   		 # to print a space:
		 li $v0, 11
  	 	 la $a0, 0x20 
  	 	 syscall
   	 
   	 	 # to print the user bet stored in $t5 (currently):
  	 	 li $v0 1 		# using syscall 1
  	 	 add $a0, $zero, $t5	# use add here instead of addi due to no immediate value
  	 	 syscall
   	 
   	 	addiu $v0  $zero  4           # print the required message
   	 	la    $a0  wrong_guess_conseq_part2
   	 	syscall	
   	 
   	 	# to print a period:
   		li $v0, 11
  	 	la $a0, 0x2E 
  	 	syscall 
  	 	
  	 	# to print a new line:
		li $v0, 11
  	 	la $a0, 0x0A  
  	 	syscall
  	 	
  	 	# to print a new line:
		li $v0, 11
  	 	la $a0, 0x0A  
  	 	syscall
  	 	
  	 	#SCORE CALCULATION:
   	 	sub $t2, $t2, $t5 	# t2 has the initial score as of now
   	 	
   	 	# moves the updated score into $v0
  	 	move $v0, $t2
   	 	
		jr $ra
	
		score_increment_and_output:

			addiu $v0  $zero  4           # print the required message
   			la    $a0  correct_guess_part1
   			syscall	

			# to print an exclamation mark:
			li $v0, 11
  	 		la $a0, 0x21 
  	 		syscall
  	 	
  			# to print a new line:
			li $v0, 11
  			la $a0, 0x0A  
  	 		syscall
  	 	
			addiu $v0  $zero  4           # print the required message
   		 	la    $a0  correct_guess_part2
   		 	syscall		 	

   		  	# to print the user index guess stored in $s5 (currently):
  		 	 li $v0 1 		# using syscall 1
  		 	 add $a0, $zero, $s0	# use add here instead of addi due to no immediate value
  		 	 syscall

			addiu $v0  $zero  4           # print the required message
   	 		la    $a0  correct_guess_part3
   	 		syscall	
   	 
   	 		# to print a period:
   			li $v0, 11
  	 		la $a0, 0x2E 
  	 		syscall 
  	 	
  	 		# to print a new line:
			li $v0, 11
  	 		la $a0, 0x0A 
  	 		syscall
  	 	
  	 		# to print a new line:
			li $v0, 11
  	 		la $a0, 0x0A 
  	 		syscall
  	 	
  	 		addiu $v0  $zero  4           # print the required message
   	 		la    $a0 points_earned_prompt_part1
   	 		syscall	
   	 
   	 		#SCORE CALCULATION:
   	 		add $t2, $t2, $t5 	# t2 has the initial score as of now
   	 	
   	 		# to print the new score stored in $a0:
  	 		 li $v0 1 		# using syscall 1
  	 		 add $a0, $zero, $t2	# use add here instead of addi due to no immediate value
  	 		 syscall
   	 	
   	 		addiu $v0  $zero  4           # print the required message
   	 		la    $a0 points_earned_prompt_part2
   	 		syscall	
  	 
  	 		# to print an exclamation mark:
			li $v0, 11
  	 		la $a0, 0x21 
  	 		syscall
  	 	
  	 		# to print a new line:
			li $v0, 11
  	 		la $a0, 0x0A 
  	 		syscall
  	 	
  	 		# to print a new line:
			li $v0, 11
  	 		la $a0, 0x0A 
  	 		syscall
  	 	
  	 		addiu $v0  $zero  4           # print the required message
   			la    $a0  mod_array_prompt
   			syscall
   		
   			# to print a period:
   			li $v0, 11
  	 		la $a0, 0x2E 
  	 		syscall 
  	 	
  	 		# to print a new line:
			li $v0, 11
  	 		la $a0, 0x0A 
  	 		syscall
  	 	
  	 		# to print a new line:
			li $v0, 11
  	 		la $a0, 0x0A 
  	 	 	syscall
   		
  	 		# moves the updated score into $v0
  	 		move $v0, $t2
  	 		
  	 		jr $ra


#--------------------------------------------------------------------
# mod_array (optional)
#
# Replaces largest element in array with -1 if player guessed correctly.
# Called from make_bet.
#
# If extra credit implemented, the largest element in the array is
# removed and array shrinks by 1 element. Index of largest element
# is replaced by another element in the array.
# 
# arguments:  $a0 - address of array index 0
#             $a1 - index of the maximum element in the array
# 
# return:     n/a
#--------------------------------------------------------------------
#
# REGISTER USE
# $t9: stores the address of the randomly generated array
# $t2: stores the initial and updated scores
# $v0: syscalls
# $a1: index of the max element
# $a0: the address of the array index 0; it gets its value from $t9
#--------------------------------------------------------------------
	
mod_array:
	
  	 beq $a2, 1, max_element_change

  	 jr $ra	
	
	 move $a0, $t9
	 
		max_element_change:
			#la $a0, array_init
	
			mul $a1, $a1, 4
			add $a0, $a0, $a1
			addi $t4, $zero, -1
			sw $t4, ($a0)
	
			jr $ra
