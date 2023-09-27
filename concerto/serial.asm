cpu 8086
org 0x7c00

; setup serial port
xor ah,ah	; ah = 0 (serial port init)
mov al,0xe3  	; baud 9600, no parity, 1 stop bit
mov dx,0 	; com port 1
int 0x14	; serial interrupt

receive_data:
mov ah,2	; receive character
int 0x14	; serial interrupt

print_data:
mov ah, 0x0e	; write in teletype mode
int 0x10	; video interrupt - al already contains character

check_keyboard:
mov ah,1	; keyboard status
int 0x16	; keyboard I/O
jz  receive_data	; no data so lets check if we've recieved anything

; read keyboard
mov ah,0	; keyboard read
int 0x16	; keyboard I/O

send_data:
mov ah,1	; send character
int 0x14	; serial interrupt
jmp receive_data

quit:
int 0x20 ; return to bootOS
