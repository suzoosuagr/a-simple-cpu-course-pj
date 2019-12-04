;------------------------------------------------------------------------------------------------------
; Module4: A Simple SoC Application
; Toggle LEDs at a given frequency. 
;------------------------------------------------------------------------------------------------------



; Vector Table Mapped to Address 0 at Reset

                PRESERVE8
                THUMB

                AREA    RESET, DATA, READONLY
                EXPORT  __Vectors

__Vectors       DCD     0x0000FFFC                ; 32K Internal Memory
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
                DCD     0
                DCD     0

                AREA    |.text|, CODE, READONLY

; Reset Handler

Reset_Handler   PROC
                GLOBAL  Reset_Handler
                ENTRY
                
AGAIN           LDR     R1, =0x57000000           ; Write to LED with value 0xff
                LDR     R0, =0xff
                STR     R0, [R1]

                LDR     R0, =0x5            	 ; Delay
Loop            SUBS    R0,R0,#1
                BNE     Loop

                LDR     R1, =0x57000004           ; Write to mask reg with 0x0f
                LDR     R0, =0x0f
                STR     R0, [R1]

                LDR     R0, =0x5	             ; Delay
Loop1           SUBS    R0,R0,#1
                BNE     Loop1
				
				LDR     R1, =0x57000000           ; Write to LED with value 0xaa
                LDR     R0, =0xaa
                STR     R0, [R1]

                LDR     R0, =0x5	             ; Delay
Loop2           SUBS    R0,R0,#1
                BNE     Loop2

				LDR     R1, =0x57000004           ; Write to mask reg with 0xff clean the mask
                LDR     R0, =0xff
                STR     R0, [R1]
				
                B AGAIN
                ENDP

                ALIGN

                END

