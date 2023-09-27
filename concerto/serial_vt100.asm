cpu 8086
org 0x7c00

; set text mode and segment registers
mov ax,2	; 80x25
int 0x10	; video service
mov ax,0xb800
mov ds,ax
mov es,ax
; 0x0fa0 - 0x3fff is free space

; setup serial port
xor ah,ah	; init
mov al,0xe3	; baud 9600, 1 stop bit, no parity
mov dx,0	; com 1
int 0x14	; serial service

; setup done now
PARAM_STRING: equ 0x0fa0

main:
	call handle_keyboard
	call handle_incoming
	jmp main

handle_keyboard:
	mov ah,1	; keyboard status
	int 0x16	; keyboard service
	jz no_data

	; read character
	xor ah,ah	; read key
	int 0x16	; keyboard service

	mov ah,1	; send character
	int 0x14	; serial service
	no_data:
	ret

handle_incoming:
	mov ah,3	; serial status
	int 0x14	; serial service
	test ax,0x100	; is data available?
	jz no_serial_data

	call read_serial_data

	test al,0x1b	; check if Escape Code
	jnz escape_code
	call print_character
	ret
	escape_code:
	call parse_escape_code
	no_serial_data:
	ret

read_serial_data:
	mov ah,2	; read serial
	int 0x14	; serial_service
	test ah,0x80	; check for error
	jnz error
	ret

print_character:
	mov ah,0x0e	; tty mode
	int 0x10	; video service
	ret

parse_escape_code:
	call read_serial_data
	test al,'['	; check if parameter type escape code
	jnz parameter_type
	call handle_non_parameter_code
	ret
	parameter_type:
	call handle_parameter_code
	ret

handle_non_parameter_code:
	test al,'D'
	je scroll_1_line

	done_non_parameter:
	ret

handle_parameter_code:
	; parse parameters
	mov di,PARAM_STRING
	mov byte [di],0	; set param string to null
	; copy params into string
	param_loop:
		call read_serial_data
		cmp al,'A'		; check if letter
		jge param_loop_end
		mov byte [di], al 	; copy letter
		inc di
		jmp param_loop
	param_loop_end:
	; todo
	ret

error:
	int 0x20	; root to bootOS
