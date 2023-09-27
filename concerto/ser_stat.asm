cpu 8086
org 0x7c00

; get key to select com port
xor ah,ah ; keyboard read
int 0x16  ; keyboard IO

; get the com port
sub al,0x30 ; convert ascii to number
xor bx,bx
mov bl,al

; activate com port
xor ah,ah ; serial port initialisation
mov al,0xe3
mov dx,bx
int 0x14

mov cx,16 ; set loop count
mov si,ax

lp:
test si,0x1
jnz not_zero
mov al, '0'
jmp print
not_zero:
mov al,'1'
print:
call print_sub

shr si,1 ; shift right
loop lp

mov al,0x0a ; new line
call print_sub

; quit
int 0x20 ; return to bootOS

print_sub:
mov ah,0x0e
int 0x10
ret
