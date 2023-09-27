cpu 8086
org 0x7c00	; boot sector location

; setup video + segment registers
mov ax,2	; 80x25
int 0x10	; video service
mov ax,0xb800
mov ds,ax
mov es,ax
; free space 0x0fa0-0x3fff

;setup serial port
xor ah,ah	; init serial
mov al,0xe3	; baud 9600, 1 stop bit, no parity
mov dx,0	; com port 1
int 0x14	; serial service

; serial port is now active


