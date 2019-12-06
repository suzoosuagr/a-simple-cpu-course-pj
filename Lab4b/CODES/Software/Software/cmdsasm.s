;------------------------------------------------------------------------------------------------------
; Design and Implementation of an AHB Interrupt Mechanism  
; 1)Input characters from keyboard (UART) and output to the terminal (using interrupt)
; 2)A counter is incremented from 1 to 10 and displayed on the 7-segment display (using interrupt)
;------------------------------------------------------------------------------------------------------

; Vector Table Mapped to Address 0 at Reset

                PRESERVE8
                THUMB

                AREA    RESET, DATA, READONLY
                EXPORT  __Vectors

__Vectors       DCD     0x00007FFC
                DCD     Reset_Handler             ; Reset Handler
                DCD     0
                DCD     0
                DCD     0
                DCD     0
                DCD     0
                DCD     0
                DCD     0
                DCD     0
                DCD     0
                DCD     0
                DCD     0
                DCD     0
                DCD     0
                DCD     0

                ; External Interrupts
                DCD     Timer_Handler
                DCD     UART_Handler
                DCD     0
                DCD     0
                DCD     0
                DCD     0
                DCD     0
                DCD     0
                DCD     0
                DCD     0
                DCD     0
                DCD     0
                DCD     0
                DCD     0
                DCD     0
                DCD     0

                AREA    |.text|, CODE, READONLY

; Reset Handler

Reset_Handler   PROC
                GLOBAL  Reset_Handler
                ENTRY
                
                LDR     R1, =0xE000E400         ; Interrupt Priority Register
                LDR     R0, =0x00004000         ; Priority: IRQ0(Timer): 0x00, IRQ1(UART): 0x40
                STR     R0, [R1]
                LDR     R1, =0xE000E100         ; Interrupt Set Enable Register
                LDR     R0, =0x00000003         ; Enable interrupts for UART and timer 
                STR     R0, [R1]

				MOVS	R0, #0x0		; 
				MSR		PRIMASK,  R0	; Clear PRIMASK register

        

                ;Configure the timer (To BE IMPLEMENTED)
				;(You need to read and understand the Verilog code of the timer in order to set it properly)
				;(Set timer load value register to 0x80. Each time when timer reaches 0, it will be reset to 0x80 and start count down)
				;(Set timer control register so that there is no prescaler, enable timer and set it to reload mode)
				;
                ;---------------------------------
				;-------Your Code-----------------
				;---------------------------------

                LDR     R5, =0x00000000         ; counting-up counter, start from '0' (ascii=0x30)  
				LDR 	R1, =0x52000000			; counter load value register
				MOVS	R0, #0x80
				STR     R0, [R1]
				LDR		R1, =0x52000008
				MOVS	R0, #0x03
				STR     R0, [R1]
				
AGAIN       	
                B       AGAIN        


                ENDP

Timer_Handler   PROC							;Timer handler code is provided
                EXPORT  Timer_Handler
                PUSH    {R0,R1,R2,LR}

                LDR     R1, =0x5200000c         ; clear timer interrupt
                MOVS    R0, #0x01
                STR     R0, [R1]

                LDR     R1, =0x50000000         ; VGA BASE
                STR     R5, [R1]
                ADDS    R5, R5, #0x01			; ++
                CMP     R5,    #0x1000
                BNE     NEXT
                LDR     R1, =0x52000008         ; timer control register
                MOVS    R0, #0x00               ; Stop timer if counts to 2^8
                STR     R0, [R1]                

NEXT            MOVS    R0, #' '
                STR     R0, [R1]
                
                POP     {R0,R1,R2,PC}           ; return
                ENDP

UART_Handler    PROC
                EXPORT  UART_Handler
					
				

                ;Complete the UART Interrup handler (To BE IMPLEMENTED)
				;(You need to read and understand the Verilog code of the timer in order to set it properly)
				;(Push the register that your are going to use into stack)
				;(Create a software loop of 256 iterations to waste some time)
				;(Read UART RX FIFO to get the RX data, write 0xFF to UART TX FIFO)
				;(Restore save register by poping them from stack)
                ;---------------------------------
				;-------Your Code-----------------
				;---------------------------------
				
				PUSH 	{R0, R1, R2, LR}
				LDR		R2, =0x00000100			;LOOP for 256 iterations
LOOP			SUBS	R2, R2, #1
				BNE 	LOOP
				
				LDR		R1, =0x51000000			;read data from RX FIFO
				LDR		R0, [R1]

				LDR		R1, =0x51000000			; write data to TX FIFO with 0xff
				MOVS	R0, #0xFF
				STR		R0, [R1]

                ENDP

                ALIGN   4                       ; Align to a word boundary

                END
