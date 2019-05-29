#make_bin#

#LOAD_SEGMENT=FFFFh#
#LOAD_OFFSET=0000h#

#CS=0000h#
#IP=0000h#

#DS=0000h#
#ES=0000h#

#SS=0000h#
#SP=0800sh#

#AX=0000h#
#BX=0000h#
#CX=0000h#
#DX=0000h#
#SI=0000h#
#DI=0000h#
#BP=0000h#

; add your code here
        JMP     ST1 
        r DB      1024 DUP(0) 
;main program
          
ST1:      
        ;clear interrupt flags
        CLI 
; intialize ds, es,ss to start of RAM
        MOV     AX,0000h
        MOV     DS,AX
        MOV     ES,AX
        MOV     SS,AX
        MOV     SP,0800H 
        
;intialise porta & b as input &portc as output
        MOV     AL,92h ;10010010b
        OUT     06h,AL  
                        
;initialise counter mode 2 in 8253                   
        ;30h = address of count0 i.e. starting address for 8253
        ;count reqd = 5*10^6
        ;count0 stores 2500
        MOV     AL,34h
        OUT     36h,AL 
        MOV     AL,0C4h
        OUT     30h,AL
        MOV     AL,09h
        OUT     30h,AL
                           
        ;count1 stores 2000
        MOV     AL,74h
        OUT     36h,AL
        MOV     AL,0D0h
        OUT     32h,AL
        MOV     AL,07h
        OUT     32h,AL
        
        ;take input from smoke sensors
next:   IN      AL,00h
        MOV     BL,AL                 
        ;check if both are on or not
        CMP     BL,81h
        JNZ     off                 
        
        ;open valves, doors and windows and sound alarm
glow:	MOV     AL,0C0h
        OUT     04h,AL
        JMP     over
	                                                      
	    ;close valves, doors and windows
off:	MOV	    AL,0FFh
	    OUT	    04h,AL
        JMP     over            
over:
            
        ;interupt generation using out of 8253 after every 2 seconds
        LEA     SI,read    
        MOV     DS:[256],SI  ;vector number = 40h = 64d, so location in IVT = 64*4 = 256
        MOV     CX,CS
        MOV     DS:[258],CX
        
        ;set the interrupt flags
        STI
        
        ;infinite loop, will stop only power s switched off
        JMP     next
        
read PROC NEAR:   
        IRET
read ENDP    