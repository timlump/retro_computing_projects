cpu 8086
org 0x7c00

param_string_loc:	equ 0x0fa4

can_have_params:	equ 0x0fa0
has_params:		equ 0x0fa1
param_0_loc:		equ 0x0fa2
param_1_loc:		equ 0x0fa3

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
	test al,'['	; check if may have parameters
	jnz parameters
	mov byte [can_have_params],0
	call execute_escape_code
	ret
	parameters:
	mov byte [can_have_params],1
	call parse_parameters
	ret

execute_escape_code:
	ret

; put length until ; or null in cx
; param string in DI
get_length_of_param:
	xor cx,cx	; cx = 0
	len_loop:
		mov ah,[di] 	; ah = next char in param string
		test ah, ';'	; if ; done
		jnz len_loop_end
		test ah,0	; if null done
		jnz len_loop_end
		inc cx
		inc di
		jmp len_loop
	len_loop_end:
	ret

convert_params_to_integers:
	; check if no params were set
	test byte [param_string_loc],0x0
	jz no_params_set

	no_params_set:
	mov byte [has_params],1
	ret

parse_parameters:
	mov di,param_string_loc	; load free memory location into DI
	param_loop:	; while is number 0-9 or delimiter
		call read_serial_data
		test al,0x3c	; if greater than ';'
		jg param_loop_end
		mov byte [di],al
		inc di
		jmp param_loop
	param_loop_end:
	mov byte [di],0	; null terminate
	call convert_params_to_integers
	call execute_escape_code
	ret

error:
	int 0x20	; root to bootOS
