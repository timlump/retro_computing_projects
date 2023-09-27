cpu 8086
org 0x7c00

; read
mov ah,0x02 ; receive mode
mov dx,0    ; serial port 1
int 0x14    ; serial io

; print to screen
mov ah,0x0e
int 0x10

int 0x20
