data1 segment

new_ln_chars   db 10,13,'$'                                 
space          db " $"                                     
hello_msg      db "Enter description of calculation: $"    
result_msg     db "The result is: $"                       
error_msg      db "Error - invalid input!$"                
err_first      db "Error - invalid first argument$"       
err_second     db "Error - invalid second argument$"        
err_third      db "Error - invalid third argument$"       


zero      db "zero$"
one       db "one$"
two       db "two$"
three     db "three$"
four      db "four$"
five      db "five$"          ;definations for taking inputs from user
six       db "six$"
seven     db "seven$"
eight     db "eight$"
nine      db "nine$"

ten       db "ten$"
eleven    db "eleven$"
twelve    db "twelve$"
thirteen  db "thirteen$"
fourteen  db "fourteen$"         ;definations for printing values only
fifteen   db "fifteen$"
sixteen   db "sixteen$"
seventeen db "seventeen$"
eighteen  db "eighteen$"
nineteen  db "nineteen$"

twenty    db "twenty$"
thirty    db "thirty$"
forty     db "forty$"
fifty     db "fifty$"
sixty     db "sixty$"
seventy   db "seventy$"
eighty    db "eighty$" 



plus  db "plus$"    
minus db "minus$"    
tim   db "times$"    

 
 ;input buffer - is used to load an input
input_buffer:
  size_of_buffer db 30            
  actual_size    db ?            
  buffer_memory  db 30 dup(0) ;a byte string corresponding to the sequence of characters entered

 
;individual words entered by the user 
in_first_word   db 30 dup('$')
in_second_word  db 30 dup('$')
in_third_word   db 30 dup('$')


; numerical values corresponding to individual words
first_arg       db 0
second_arg      db 0
third_arg       db 0


result          db ?
minus_flag      db 0 ;if a subtraction is performed, the minus flag is set to 1
                     
data1 ends





code1 segment 


start:

;stack initialization 
  mov ax, seg top1
  mov ss, ax
  mov sp, offset top1


;data segment indication
  mov ax, seg input_buffer
  mov ds, ax

  hello_message:              ; displaying the welcome message
    mov dx, offset hello_msg
    mov ah, 9
    int 21h

; buffered input loading
  read_input:                
    mov dx, offset input_buffer
    mov ah, 0ah   ; buffered input read, dedicated DOS interrupt           
    int 21h

  call new_line   
  
  ; INITIAL CHECKING THE CORRECTNESS OF THE INPUT           
  
  
  ; checking if there are three words on the input
; if not, a message is displayed and the program exits
  input_check:
    mov si, offset buffer_memory  ; the SI register points to the beginning of the buffer 
    skip_spaces0:     ; remove spaces at the beginning of an input             
      inc si
      mov al, byte ptr ds:[si-1]
      cmp al, 20h            ; SI is shifted to subsequent bytes,
                                   ;  until it starts pointing to a character other than a space
      jz skip_spaces0              
                                   

    mov di, offset in_first_word  ; DI indicates the first byte of memory where the first word will be stored  
    arg1_loop:                     
      cmp al, 0dh        
      jz invalid_input    ; if the program encounters a CR here, invalid input was entered
      mov byte ptr ds:[di], al   ; writing subsequent bytes of the first word to memory  
      inc di            ; go to next input byte and parsing result 
      inc si           ; we increment the SI until it points to a character other than a space
      mov al, byte ptr ds:[si-1]
      cmp al, 20h       
      jnz arg1_loop     


    skip_spaces1:   ; likewise, jumping through spaces between the first and second words 
      inc si     
      mov al, byte ptr ds:[si-1]  ; we increment the SI until it points to a character other than a space
      cmp al, 20h     
      jz skip_spaces1

    mov di, offset in_second_word  ; DI indicates the first byte of memory where the second word will be saved
    arg2_loop:              
      cmp al, 0dh        
      jz invalid_input ; if the program encounters a CR here, invalid input was entered  
      mov ds:[di], al    
      inc di            
      inc si
      mov al, byte ptr ds:[si-1] ; writing subsequent bytes of the second word to memory
      cmp al, 20h        
      jnz arg2_loop     


    skip_spaces2:  ;analogously, jumping through spaces between the second and third words     
      inc si    ;increment the SI until it points to a character other than a space         
      mov al, byte ptr ds:[si-1]
      cmp al, 20h       
      jz skip_spaces2

    cmp al, 0dh        
    jz invalid_input   

    mov di, offset in_third_word  
    arg3_loop:                   
      mov ds:[di], al       
      inc di                
      inc si
      mov al, byte ptr ds:[si-1]
      cmp al, 20h          
      jz check_excess      
      cmp al, 0dh         
      jnz arg3_loop        


    jmp arg1_parsing    

    check_excess:       
      skip_spaces3:      
        inc si
        mov al, byte ptr ds:[si-1]
        cmp al, 20h     
        jz skip_spaces3
      cmp al, 0dh       
      jnz invalid_input  
      jmp arg1_parsing  
      
;CORRECT PASSING OF INDIVIDUAL ARGUMENTS


;CL -> currently considered digit -> if it reaches 10 (or 3 for the action operator),
; that is, the argument was given incorrectly
; SI -> set to the beginning of the argument currently being tested
; DI -> is used to iterate over word patterns for digits (or operators)     
  arg1_parsing:
    xor cl, cl
    mov di,  offset zero     

    parse_arg1_loop:        
      mov al, cl
      mov ah, 10
      cmp ah, al        ; if the CL counter is 10, no pattern found
      jz invalid_first      
                           
      mov si, offset in_first_word  

      iterate_arg1_chars:  ; move over the successive bytes of the pattern and the first argument          
        mov al, '$'
        mov ah, byte ptr ds:[si]
        cmp ah, al
        jz arg1_end_reached  ; ds: [si] = '$': end of input argument reached, checking if end of pattern also reached   

        mov al, '$'
        mov ah, byte ptr ds:[di]
        cmp ah, al
        jz  pattern1_end_reached  ;end of pattern

        mov al, byte ptr ds:[si]
        mov ah, byte ptr ds:[di]
        cmp ah, al       ; comparing a given pattern character and argument         
        jz chars_match1
        jmp move_to_next_pattern1 

;volume_up
;71 / 5,000
;Translation results

; if the characters do not match, start comparing with the next pattern 


        chars_match1:   ; if pattern characters and inputs match, move to next characters        
          inc di
          inc si
          jmp iterate_arg1_chars

        pattern1_end_reached:
          inc di    ;set di at the start of a new pattern
          inc cl    ; consideration of the next digit
          jmp parse_arg1_loop

        arg1_end_reached:  ; checking to see if the end of the pattern is also reached
          mov al, '$'
          mov ah, byte ptr ds:[di]
          cmp ah, al
          jz save_arg1_value ; if so, write down the value corresponding to the first word 

        move_to_next_pattern1: ; if the end of the pattern is not reached, move the DI to the start of the new pattern  
          inc di   ; DI incremented until it hits '$' - end pattern symbol             
          mov ah, byte ptr ds:[di]
          mov al, '$'
          cmp ah, al
          jnz move_to_next_pattern1
          inc di  ;set dj to the beginning of the next pattern     
          inc cl  ; consideration of the next digit     
          jmp parse_arg1_loop

        save_arg1_value:   ; write the value corresponding to the entered word mov di, offset first arg     
          mov di, offset first_arg
          mov al, cl
          mov byte ptr ds:[di], al

   ; ///////// OTHER ARGUMENT
 
arg2_parsing:
    xor cl, cl
    mov di,  offset plus   ; DI set to start of "plus" pattern

    parse_arg2_loop:        ;loop for processing consecutive arithmetic operations
      mov al, cl
      mov ah, 3
      cmp ah, al
      jz invalid_second     ;if the CL counter points to 3, no pattern was found
                            ;=> pale others argument
      mov si, offset in_second_word ;SI points to the first byte of the second argument

      iterate_arg2_chars:           ;going over the successive bytes of the pattern and the second argument
        mov al, '$'
        mov ah, byte ptr ds:[si]
        cmp ah, al
        jz arg2_end_reached     ;ds: [si] = '$': end of input argument reached, checking if end of pattern also reached

        mov al, '$'
        mov ah, byte ptr ds:[di]
        cmp ah, al
        jz  pattern2_end_reached  ;end of pattern has been reached

        mov al, byte ptr ds:[si]
        mov ah, byte ptr ds:[di]
        cmp ah, al                ;comparing a given pattern character and argument
        jz chars_match2
        jmp move_to_next_pattern2 ;if the characters do not match, start comparing with the next pattern


        chars_match2:           ;if pattern characters and inputs match, move to next characters
          inc di
          inc si
          jmp iterate_arg2_chars

        pattern2_end_reached:
          inc di ;set di at the start of a new pattern
          inc cl ;considering the next operator
          jmp parse_arg2_loop

        arg2_end_reached:   ;checking if the end of pattern is also reached
          mov al, '$'
          mov ah, byte ptr ds:[di]
          cmp ah, al
          jz save_arg2_value  ;if so, write down the opcode corresponding to the second word

        move_to_next_pattern2:  ;if the end of the pattern is not reached, move the DI to the start of the new pattern
          inc di                ;DI incremented until it hits '$' - end pattern symbol
          mov ah, byte ptr ds:[di]
          mov al, '$'
          cmp ah, al
          jnz move_to_next_pattern2
          inc di      ;set the DJ to the beginning of the next pattern
          inc cl      ;consideration of the next operation
          jmp parse_arg2_loop

        save_arg2_value:       ;saving a value corresponding to the entered word
          mov di, offset second_arg
          mov al, cl
          mov byte ptr ds:[di], al

;///////// THIRD ARGUMENT
  arg3_parsing:
    xor cl, cl
    mov di,  offset zero    ;DI set to the beginning of the "zero" pattern

    parse_arg3_loop:        ;loop for processing consecutive digits
      mov al, cl
      mov ah, 10
      cmp ah, al
      jz invalid_third      ;if the CL counter is 10, no pattern was found
                            ;=> wrong third argument
      mov si, offset in_third_word ;SI points to the first byte of the third argument

      iterate_arg3_chars:           ;going through the successive bytes of the pattern and the third argument
        mov al, '$'
        mov ah, byte ptr ds:[si]
        cmp ah, al
        jz arg3_end_reached     ; ds: [si] = '$': end of input argument reached, checking if end of pattern also reached

        mov al, '$'
        mov ah, byte ptr ds:[di]
        cmp ah, al
        jz  pattern3_end_reached  ;end of pattern has been reached

        mov al, byte ptr ds:[si]
        mov ah, byte ptr ds:[di]
        cmp ah, al                ;comparing a given pattern character and argument
        jz chars_match3
        jmp move_to_next_pattern3 ;if the characters do not match, start comparing with the next pattern


        chars_match3:           ;if pattern characters and inputs match, move to next characters
          inc di
          inc si
          jmp iterate_arg3_chars

        pattern3_end_reached:
          inc di ;set DI to the start of a new pattern
          inc cl ;consider set DI at the beginning of a new pattern of the next digit
          jmp parse_arg3_loop

        arg3_end_reached:   ;checking if the end of pattern is also reached
          mov al, '$'
          mov ah, byte ptr ds:[di]
          cmp ah, al
          jz save_arg3_value  ;if so, write down the value corresponding to the third word

        move_to_next_pattern3:  ;if the end of the pattern is not reached, move the DI to the start of the new pattern
          inc di                ;DI incremented until it hits '$' - end pattern symbol
          mov ah, byte ptr ds:[di]
          mov al, '$'
          cmp ah, al
          jnz move_to_next_pattern3
          inc di      ;set the DJ to the beginning of the next pattern
          inc cl      ;consideration of the next digit
          jmp parse_arg3_loop

        save_arg3_value:       ;saving a value corresponding to the entered word
          mov di, offset third_arg
          mov al, cl
          mov byte ptr ds:[di], al
;////////////////////////////////////////////////////


;///////////////////////////////////////////////////
;PERFORMANCE OF OPERATIONS ON THE GIVEN NUMBERS
;///////////////////////////////////////////////////

  make_operation:         ;operation type selection block
    mov ax, offset second_arg     ;the second argument holds the code of the operation
    mov si, ax
    mov al, byte ptr ds:[si]
    cmp al, 0
    jz addition       ;operation code = 0 -> adding
    cmp al, 1         ;operation code = 1 -> subtraction
    jz subtraction
    jmp multiplication  ;otherwise, operation code = 2 -> multiplication

  addition:
    mov si, offset first_arg ;SI indicates the first digit
    mov di, offset third_arg ;DI indicates the second digit
    mov ah, byte ptr ds:[si]
    mov al, byte ptr ds:[di]
    add ah, al              ;the result of the addition saved in GA
    mov di, offset result
    mov byte ptr ds:[di], ah ;save the result in memory
    jmp show_result          ;going to printing the result

  subtraction:
    mov si, offset first_arg
    mov di, offset third_arg
    mov ah, byte ptr ds:[si]
    mov al, byte ptr ds:[di]
    cmp ah, al
    jc swap_arguments_and_set_minus ;if a1 - a2 <0, we do action a2 - a1 and set the variable "minus_flag"
    sub ah, al                      ;the result of the subtraction stored in GA
    mov di, offset result
    mov byte ptr ds:[di], ah  ;save the result in memory
    jmp show_result           ;going to printing the result

    swap_arguments_and_set_minus:
      mov dl, ah    ;swapping arguments using DL
      mov ah, al
      mov al, dl
      sub ah, al      ;the result of the subtraction stored in GA
      mov di, offset result
      mov byte ptr ds:[di], ah  ;save the result in memory
      mov di, offset minus_flag
      mov byte ptr ds:[di], 1   ;setting the "minus" indicator in the output
      jmp show_result

  multiplication:
    mov si, offset first_arg
    mov di, offset third_arg
    mov ah, 0
    mov al, byte ptr ds:[di]  ;getting the first digit from the memory
    mov ch, 0
    mov cl, byte ptr ds:[si]  ;fetching the second digit from memory
    mul cx                    ;the result of the multiplication stored in the AX register
    mov di, offset result
    mov byte ptr ds:[di], al  ;save the multiplication result in memory

;//////////////////////////////////////////



;///////////////////////////////////////////////////
;WRITING OUT THE RESULT IN TEXT MODE
;///////////////////////////////////////////////////

  show_result:
    mov dx, offset result_msg     ;printing a message about the result
    mov ah, 9
    int 21h

    mov si, offset minus_flag     ;checking if the result is negative
    mov al, byte ptr ds:[si]
    cmp al, 0
    jz number_size_check    ;if it is not necessary to print "minus", go to check if result <= 20

  show_minus:               ;writing the word "minus"
    mov dx, offset minus
    mov ah, 9
    int 21h
    mov dx, offset space
    mov ah, 9
    int 21h

  number_size_check:        ;checking if the result <= 20
    mov si, offset result
    mov ah, 20
    mov al, byte ptr ds:[si]
    cmp ah, al
    jc more_than_twenty   ;checks if the result can be written in one word (i.e. if it is not greater than 20)

    print_single_number:  ;if the result <= 20, find the correct word and write it
      xor cl, cl           ;currently selected pattern
      mov si, offset zero

      select_number_loop:
        cmp al, cl
        jz print_number  ;if a suitable pattern is found, write it out
          move_to_next_number:  ;go to the next pattern
            mov ah, '$'
            inc si
            cmp ds:[si-1], ah
            jnz move_to_next_number
            inc cl               ;the next pattern is considered
            jmp select_number_loop


  print_number: ;writing a single number on the screen (from 0 to 20), or a unit digit (for results> 20)
    mov ax, si
    mov dx, ax
    mov ah, 9
    int 21h
    jmp exit

  more_than_twenty:   ;the result to be printed is stored in AL
    xor ah, ah
    mov ch, 10
    div ch            ;divide the result by 10, in AL the result of the division, in AH the remainder
    mov si, offset twenty
    mov cl, 2
    select_number_loop_tens:
      cmp al, cl
      jz print_number_tens     ;if a suitable multiple of ten is found, print a number
        move_to_next_number_tens: ;move on to the next pattern multiples of ten
          mov ah, '$'
          inc si
          cmp byte ptr ds:[si-1], ah
          jnz move_to_next_number_tens
          inc cl                  ;consideration of the next multiple of ten
          jmp select_number_loop_tens

  print_number_tens:  ;writing out the appropriate multiple of ten
    mov ax, si
    mov dx, ax
    mov ah, 9
    int 21h
    mov dx, offset space
    mov ah, 9
    int 21h

    mov si, offset result
    mov al, byte ptr ds:[si]  ;retrieving the result of the operation from the memory
    xor ah, ah
    mov ch, 10
    div ch                    ;dividing the result by 10, the units digit (the remainder of the division) written in AH
    mov al, ah                ;shifting the units digit to AL for possible writing
    cmp al, 0
    jnz print_single_number
;///////////////////////////////////////////////////



;///////////////////////////////////////////////////
;END OF THE PROGRAM
;///////////////////////////////////////////////////

  exit:
    mov ax, 04c00h ;kod zakonczenia programu, systemowy error code = 0
    int 21h ;DOS interrupt, program exiting
;///////////////////////////////////////////////////



;///////////////////////////////////////////////////
;ADDITIONAL FUNCTIONS AND ERROR HANDLING
;///////////////////////////////////////////////////


  new_line:         ;is used to write a new line
    mov dx, offset new_ln_chars
    mov ah, 9
    int 21h
    ret

  invalid_first:    ;printing a message with a wrong first argument
    mov dx, offset err_first
    mov ah, 9
    int 21h
    jmp exit

  invalid_second: ;printing a message with a wrong first argument
    mov dx, offset err_second
    mov ah, 9
    int 21h
    jmp exit

  invalid_third:  ;printing a message with the wrong third argument
    mov dx, offset err_third
    mov ah, 9
    int 21h
    jmp exit

  invalid_input:  ;printing a message about an erroneous input
    mov dx, offset error_msg
    mov ah, 9
    int 21h
    jmp exit
;///////////////////////////////////////////////////
code1 ends


;//////////////////////////STACK SEGMENT/////////////////////////////////////
stack1 segment STACK
     dw 200 dup(?) ;fill the stack with any 200 words
top1 dw ?          ;specifies the top of the stack
stack1 ends

end start

