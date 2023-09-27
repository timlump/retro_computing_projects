cpu 8086
org 0x7c00

; setup serial port
xor ah,ah	; ah = 0 (serial port init)
mov al,0xe3  	; baud 9600, no parity, 1 stop bit
mov dx,0 	; com port 1
int 0x14	; serial interrupt

main:
call handle_input
jmp main

; keyboard subroutine
handle_input:
mov ah,1	; keyboard status
int 0x16	; keyboard I/O
jz input_done 
; read character 

mov ah,0	; read key
int 0x16	; keyboard I/O

mov ah,1	; send character
int 0x14	; serial interrupt
input_done:
ret
