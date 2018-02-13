.data
xdmsg:           .asciiz "Enter the first integer x: "
kdmsg:           .asciiz "Enter the second integer k: "
ndmsg:           .asciiz "Enter the third integer n: "
rsltmsg:         .asciiz "The result of x^k mod n = "
x: .word 0
k: .word 0
n: .word 0

.text
.globl main
main:
    #Gets all the values from the user and stores them to the varaibles
    li      $v0,  4        #Value to v0 for display string
    la      $a0,  xdmsg    #Loads the first message       
    syscall                #Print the first message to enter in x

    li      $v0,  5        #Value to v0 to take in integers. 
    syscall                #Read values in from console for x. 
    sw      $v0, x         #Store the value to x from the console. 
   
    li      $v0,  4        #Value to v0 for display string 
    la      $a0,  kdmsg    #Loads the first message
    syscall                #Print the second message to enter in k

    li      $v0,  5        #Value to v0 to take in integers. 
    syscall                #Read values in from console for k. 
    sw      $v0, k         #Store the value to x from the console. 
    
    li      $v0,  4        #Read values in from console for n. 
    la      $a0,  ndmsg    #Value to v0 to take in integers. 
    syscall                #Print the second message to enter in k

    li      $v0,  5        #Value to v0 to take in integers. 
    syscall                #Read values in from console for n. 
    sw      $v0, n         #Store the value to n from the console. 

    lw      $a0, x         #Loads the value stored in x to register a0
    lw      $a1, k         #Loads the value stored in k to register a1
    lw      $s2, n         #Loads the value stored in n to register s2
    li      $t1, 1         #t1 is the result register, equal to 1 to start. 
    jal fme                #Jump and link to fme function to do the work. 
    # The result is equal to x % n
    div     $a1, $t7       #Divide k by 2
    mfhi    $t3            #Move the mod of k and 2 to t2
    beq     $t3, $zero, exponentMod2Zero  #If the mod of the exponent and 2 is equal to zero, branch to exponentMod2Zero
    div     $a0, $s2       #Divides the number by the exponent
    mfhi    $t0            #Moves the mod from the dividing registers to t0. 
    j skip                 #Skip over exponenetMod2Zero.            

    exponentMod2Zero:      #If the exponent modded by 2 is equal to zero, then the result = 1.
         li      $t0, 1    #Set result = 1 by setting t0 to 1.

    skip:
        mult    $v0, $v0   #Multiply temp * temp
        mflo    $t8        #Moves the product from low to t8.
        mult    $t8, $t0   #Multiply temp * temp * result
        mflo    $t8        #Moves the product from low to t8.
        div     $t8, $s2   #Divides the product by the mod
        mfhi    $v0        #Moves the mod from hi to v0.
        move    $t4, $v0   #Moves v0 to t4 for return reasons. 
        li      $t8, 0     #Loads t8 with the value of 0 to ensure it doesn't interfere with subsequent calls.

        #Final Display Messages
        li        $v0, 4     #Value to v0 for display string
        la        $a0, rsltmsg #Loads the final message to a0
        syscall              #Print final message to console

        li        $v0, 1     #Value to v0 for displaying integers. 
        la        $a0, ($t4) #Loads the value from t4 to a0 to be displayed out.
        syscall              #Print answer to console

        #Terminates the program safely.
        li        $v0, 10    #Loads v0 with terminate command
        syscall              #Final call to terminate program. 

#---------------------------------------------------------------
#fme function to find the answer. 
.globl fme
fme:
    subu        $sp, $sp, 8    #Subtracts 8 from the stack pointer to create room for return address and value
    sw          $a1, ($sp)     #Stores the value of the return value to the stack pointer.
    sw          $ra, 4($sp)    #Stores the return address to the stack, offset by 4 places to not overwrite the value.
    li          $t0, 1         #Result = 1, loads 1 into t0.

    #BaseCase
    blez        $a1, exponentZero  #Branch if the exponent is less then or equal to 0.
    li          $t7, 2             #Loads t7 with 2. 
    div         $a1, $t7           #Divides exponent by 2, which is stored in the t8 register. 
    mflo        $a1                #Moves the answer of the division from low to a1.

    #Recursive Call
    jal fme      

    #If k % 2 equals 1 check
    div         $a1, $t7    #Divides k by 2 to see if it is equal to 0 or 1 (odd or even)
    mfhi        $t3         #Moves the mod from the hi register to t2.
    beq         $t3, $zero, modEven #If mod is even, then branch to modEven. 
    
    #Mod is odd, so go into second if statement. 
    div         $a0, $s2     #N divided by x
    mfhi        $t0          #Moves the mod from the hi register to t0. 
    j answerFinal            #Jumps over the modEven to the answerFinal once complete.

    modEven:                 #If mod is even then load 1 into t0. Result = 1
        li      $t0, 1       #Loads 1 into t0. 

    answerFinal:
        mult    $v0, $v0  #Multiplies Temp * Temp
        mflo    $t8       #Moves the product to t8 register
        mult    $t8, $t0  #Multiply product times result
        mflo    $t8       #Move product to t8. 
        div     $t8, $s2  #Divide product by modder
        mfhi    $v0       #Move the remainder into v0. 
        move    $t4, $v0  #Move the value from v0 to t4.
        li      $t8, 0    #Clears the t8 register so the values don't interfere with their subsequent calls.
    
    finalReturn:
        lw      $a1, ($sp)  #Loads the return value from the stack
        lw      $ra, 4($sp) #loads the return address from the stack, displaced by 4
        addu    $sp, $sp, 8 #deletes the stack by adding 8 unsigned to the value of the stack address.
        jr      $ra         #Returns from the function.

    exponentZero:           #If the exponent is zero, we will reach here. 
      li        $v0, 1      #Result = 1
      j finalReturn