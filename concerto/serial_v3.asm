cpu 8086
org 0x7c00

; setup serial port
xor ah,ah	; ah = 0 (serial port init)
mov al,0xe3  	; baud 9600, no parity, 1 stop bit
mov dx,0 	; com port 1
int 0x14	; serial interrupt

main:
call handle_input
call print_incoming
jmp main

; receiving and printing subroutine
print_incoming:
mov ah,3	; serial status
int 0x14	; serial interrupt
test ax,0x100	; check if data available
jz print_done

mov ah,2	; read serial
int 0x14	; serial interrupt
test ah,0x80	; check for error
jnz print_done

mov ah,0x0e	; tty mode
int 0x10	; video interrupt

print_done:
ret

; keyboard and send subroutine
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
