#--------------------------------------------------------------
# Created by:  Rebecca
#              26 May 2019
#
# Description: Test code for Lab 5 for CMPE 12 19sp
#
# Note:        This program is intended to run in the MARS IDE
#--------------------------------------------------------------

#------------------------------------------------------------------------
# STATIC DATA
#------------------------------------------------------------------------

.data

array_: .space  36                 # assume this is 1 word greater than the size of the array <---------<---------<--------- SAFE TO MODIFY
size_:  .word    8                 # number of elements in the array: ((# bytes allocated for array_) - 4) / 4 <---------<---------<--------- SAFE TO MODIFY
score_: .word  100                 # initial score <---------<---------<--------- SAFE TO MODIFY

seed:   .word 0x12345678           # used to generate array of random ints <---------<---------<--------- SAFE TO MODIFY

s0_val: .word 0xffffffff           # used in s reg initialization <---------<---------<--------- SAFE TO MODIFY
s1_val: .word 0xbaadcafe
s2_val: .word 0xc0ffeeee
s3_val: .word 0xfeedbabe
s4_val: .word 0xabcdef00
s5_val: .word 0x00f1dd1e
s6_val: .word 0xbaaaaaaa
s7_val: .word 0xdeadbeef


#------------------------------------------------------------------------
# MACROS
#------------------------------------------------------------------------

#------------------------------------------------------------------------
# print header and s reg values before calling subroutine
#------------------------------------------------------------------------

.macro print_testing_header(%str_func_name)

print_horiz_line                                               # print "testing" header
print_in_line_str("testing ")
print_str(%str_func_name)
print_new_line

print_s_regs(%str_func_name, "before")

print_in_line_str("entering subroutine: ")
print_str(%str_func_name)
print_new_line

.end_macro

#------------------------------------------------------------------------
# print return value header
#------------------------------------------------------------------------

.macro return_val_header(%str_func_name)

print_str("-")
print_in_line_str(%str_func_name)
print_str(" return values")
print_str("-")
print_new_line

.end_macro

#------------------------------------------------------------------------
# set_s_vals
# populate s registers
# 
# set values at the top of this test file
#------------------------------------------------------------------------

.macro set_s_vals

    lw  $s0  s0_val
    lw  $s1  s1_val
    lw  $s2  s2_val
    lw  $s3  s3_val
    lw  $s4  s4_val
    lw  $s5  s5_val
    lw  $s6  s6_val
    lw  $s7  s7_val

.end_macro

#------------------------------------------------------------------------
# print_s_regs
# used to print values of registers before and after function
#
# arguments: %func         - name of subroutine being executed
#            %before_after - has value of "before" or "after"
#------------------------------------------------------------------------

.macro print_s_regs(%func, %before_after)

    print_s_val($s0, "$s0", %func, %before_after)
    print_s_val($s1, "$s1", %func, %before_after)
    print_s_val($s2, "$s2", %func, %before_after)
    print_s_val($s3, "$s3", %func, %before_after)
    print_s_val($s4, "$s4", %func, %before_after)
    print_s_val($s5, "$s5", %func, %before_after)
    print_s_val($s6, "$s6", %func, %before_after)
    print_s_val($s7, "$s7", %func, %before_after)
    print_new_line

.end_macro

.macro print_s_val(%s_reg, %s_reg_str, %func, %before_after)

    print_in_line_str(%s_reg_str)
    print_in_line_str(" ")
    print_in_line_str(%before_after)
    print_in_line_str(" ")
    print_in_line_str(%func)
    print_in_line_str(": ")
    print_hex_val(%s_reg)

.end_macro

#------------------------------------------------------------------------
# print value as hex

.macro print_hex_val(%reg_to_print)

subi  $sp   $sp   8                                            # push $a0 and $v0 to stack so values are not overwritten in syscall
sw    $a0  ($sp)
sw    $v0 4($sp)

add   $a0 $zero   %reg_to_print
addiu $v0 $zero   34                                           # print value as hex

syscall

print_new_line                                                 # add new line so next string printed starts at beginning on line

lw    $a0  ($sp)                                               # pop $a0 and $v0 off stack so values are not overwritten in syscall
lw    $v0 4($sp)
addi  $sp   $sp   8
.end_macro

#------------------------------------------------------------------------
# print in line string - without new line

.macro print_in_line_str(%str)

.data
in_line_str_to_print: .asciiz %str

.text
subi  $sp   $sp   8                                            # push $a0 and $v0 to stack so values are not overwritten in syscall
sw    $a0  ($sp)
sw    $v0 4($sp)

addiu $v0 $zero   4
la    $a0 in_line_str_to_print
syscall

lw    $a0  ($sp)                                               # pop $a0 and $v0 off stack so values are not overwritten in syscall
lw    $v0 4($sp)
addi  $sp   $sp   8
.end_macro

#------------------------------------------------------------------------
# print string - prints new line after string

.macro print_str(%str)

.data
str_to_print: .asciiz %str

.text
subi  $sp   $sp   8                                            # push $a0 and $v0 to stack so values are not overwritten in syscall
sw    $a0  ($sp)
sw    $v0 4($sp)

addiu $v0 $zero   4
la    $a0 str_to_print
syscall

print_new_line

lw    $a0  ($sp)                                               # pop $a0 and $v0 off stack so values are not overwritten in syscall
lw    $v0 4($sp)
addi  $sp   $sp   8
.end_macro

#------------------------------------------------------------------------
# print new line

.macro print_new_line

subi  $sp   $sp   8                                            # push $a0 and $v0 to stack so values are not overwritten in syscall
sw    $a0  ($sp)
sw    $v0 4($sp)

addiu $v0 $zero   11
addiu $a0 $zero   0xA
syscall

lw    $a0  ($sp)                                               # pop $a0 and $v0 off stack so values are not overwritten in syscall
lw    $v0 4($sp)
addi  $sp   $sp   8

.end_macro

#------------------------------------------------------------------------
# print horizontal line

.macro print_horiz_line

print_str("==================================================")

.end_macro

#------------------------------------------------------------------------
# initialize array with random positive numbers

#------------------------------------------------------------------------
# REGISTER USAGE
#
# $a0: seed for random number generator, output of rand num gen 
# $a1: upper limit of random number generation
# $t0: max index of array
# $t1: points to rand num gen seed
# $t2: points to max index of array, points to array element
#------------------------------------------------------------------------

.macro init_rand_array

array_init: nop                    # housekeeping
    
    lw    $t0  size_
    subi  $t0  $t0    1            # max index of array             
    
    li    $v0  42                  # syscall 42 used to generate random number w/upper limit
    
    li    $a1  99                  # set upper limit of random number generation <---------<---------<---------<--------- SAFE TO MODIFY
    
    la    $t2  array_              # address of index 0
    la    $t1  seed                # address of seed

array_init_loop: nop               # loop to populate array with random numbers 

    lw    $a0  ($t1)               # generate random number
    syscall

    ####################           # ----> for fun, add code here to ensure all unique values <---------<---------<------ SAFE TO MODIFY
    #                  #           #
    ####################           # hint: check if the value of $a0 already exists in the array
                                   
    sw    $a0  ($t2)               # store random number in array
    
                                   # loop housekeeping
    addi  $t2   $t2   4            # increment address to next word
    subi  $t0   $t0   1            # decrement loop counter
    bgez  $t0   array_init_loop    # check condition
    
    sw    $0   ($t2)               # store 0 at word after array

.end_macro


#------------------------------------------------------------------------
#------------------------------------------------------------------------
#------------------------------------------------------------------------
#------------------------------------------------------------------------
#
# START OF CODE

.text
init_rand_array                                                # initialize array_ with random numbers
set_s_vals                                                     # initialize s regs

#------------------------------------------------------------------------
# test find_max

.data
test_array_find_max: .word 1 2 3 4 5 6 7 8 0                   # test array before entering subroutine <---------<---------<--------- SAFE TO MODIFY

.text
print_testing_header("find_max")

la    $a0  test_array_find_max                                 # use array_ to test using array of random numbers <---------<---------<--------- SAFE TO MODIFY
jal   find_max

return_val_header("find_max")                                  # display return values

print_str("index of max value in array ($v0): ")
print_hex_val($v0)

print_new_line
print_str("max value ($v1): ")
print_hex_val($v1)
print_new_line

print_s_regs("find_max", "after")                              # display values of s regs after subroutine

#------------------------------------------------------------------------
# test make_bet

.data
test_score_make_bet: .word 100                        # score before entering subroutine <---------<---------<--------- SAFE TO MODIFY
test_array_make_bet: .word 1 2 3 4 5 6 7 8 0          # array before entering subroutine <---------<---------<--------- SAFE TO MODIFY

.text
print_testing_header("make_bet")

lw   $a0  test_score_make_bet                         # load arguments to test subroutine
la   $a1  test_array_make_bet                         # use array_ to test using array of random numbers <---------<---------<--------- SAFE TO MODIFY

#jal  make_bet

return_val_header("make_bet")                         # display return values

print_str("updated score ($v0): ")
print_hex_val($v0)
print_new_line

print_s_regs("make_bet", "after")                     # display values of s regs after subroutine

#------------------------------------------------------------------------
# test print_array

.data
test_array_print: .word 1 2 3 4 5 6 7 8 0             # array before entering subroutine <---------<---------<--------- SAFE TO MODIFY

.text
print_testing_header("print_array")

la   $a0  test_array_print                            # use array_ to test using array of random numbers <---------<---------<--------- SAFE TO MODIFY

jal print_array

print_s_regs("print_array", "after")                  # display values of s regs before subroutine

#------------------------------------------------------------------------
# test win_or_lose
#
# for a win or lose condition, the program should terminate
# comment out jal win_or_lose to test the full game functionality

.data
test_array_win_or_lose: .word -1 -1 -1 -1 -1 -1 -1 -1 0        # array before entering subroutine <---------<---------<--------- SAFE TO MODIFY
test_final_score:       .word 100                              # score before entering subroutine <---------<---------<--------- SAFE TO MODIFY

.text
print_testing_header("win_or_lose")

la     $a0  test_array_win_or_lose
la     $t0  test_final_score
lw     $a1  ($t0)

#jal win_or_lose                                               # un-comment to test win_or_lose <---------<---------<--------- SAFE TO MODIFY

print_s_regs("win_or_lose", "after")                           # display values of s regs before subroutine

#------------------------------------------------------------------------
# test take_turn

.data
test_score_take_turn: .word 50                                 # score before entering subroutine <---------<---------<--------- SAFE TO MODIFY
test_array_take_turn: .word 1 2 3 4 5 6 7 8 0                  # array before entering subroutine <---------<---------<--------- SAFE TO MODIFY
test_user_select:     .word 2                                  # 1 = make bet, 2 = print array, 3 = quit <---------<---------<--------- SAFE TO MODIFY

.text
print_testing_header("take_turn")

                                                               # load arguments to test subroutine
lw   $a0  test_score_take_turn
la   $a1  test_array_take_turn                                 # use array_ to test using array of random numbers <---------<---------<--------- SAFE TO MODIFY
lw   $a3  test_user_select

#jal  take_turn

return_val_header("take_turn")

print_str("updated score ($v0): ")
print_hex_val($v0)
print_new_line

print_s_regs("take_turn", "after")                             # display values of s regs before subroutine

#------------------------------------------------------------------------
# test play_game

.text

print_horiz_line                                               # print test subroutine header
print_str("testing play_game\n")

lw   $a0  score_                                               # load arguments to test subroutine
la   $a1  array_

jal  play_game

.include  "Lab5.asm"                     #replace this with Lab5.asm <---------<---------<--------- SAFE TO MODIFY




#          ()()
#         (**)
# © 2019  (______)*
