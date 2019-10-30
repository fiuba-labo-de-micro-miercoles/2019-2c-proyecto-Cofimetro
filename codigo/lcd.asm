.include "m328pdef.inc"

;Cosas para mas adelante:
;-cargar desde RAM convirtiendo numeros a ASCII

;pines
.EQU D4 = 0
.EQU D5 = 1
.EQU D6 = 2
.EQU D7 = 3
.EQU ENABLE = 4
.EQU RS = 5

;comandos
.EQU SET_8BITS_LONG = 0x03
.EQU SET_4BITS_LONG = 0x02
.EQU FUNCTION_SET = 0x2C
.EQU SET_DISPLAY = 0x0C
.EQU CLEAN_DISPLAY = 0x01
.EQU ENTRY_MODE = 0x06
.EQU NEXT_LINE = 0xC0

;mascaras
.EQU MASK_4LSB = 0x0F
.EQU MASK_MSB = 0x80



.MACRO DELAY ;macro para esperar
	CLR R18
	LDI R17, @0
FOR_1:
	DEC R17
	LDI R16, @1
FOR_2:
	DEC R16
	CPSE R16, R18
	RJMP FOR_2
	CPSE R17, R18
	RJMP FOR_1
.ENDM

.MACRO WRITE_FROM_ROM ;macro para cargar desde la rom, se le pasa una posicion
	LDI ZL, LOW(@0<<1)
	LDI ZH, HIGH(@0<<1)
	LDI R21, 15 ; cargo el contador de linea
FOR_WRITE_ROM:
	LPM R20, Z+ ; cargo el caracter  desde la rom
	CPI R20, 0 ; veo si es fin de texto
	BREQ END_WRITE_ROM ; si es el final me voy de la macro
	CALL WRITE_4BITS_CHARACTER ;escribo
	CPI R21, 0 ;veo si terminó la linea
	BREQ ENTER_WRITE_ROM ; si termino la linea me muevo a la otra
	DEC R21 ;decremento el contador de linea
	RJMP FOR_WRITE_ROM

ENTER_WRITE_ROM:
	MOVE_TO NEXT_LINE
	LDI R21, 15
	RJMP FOR_WRITE_ROM

END_WRITE_ROM:
	;termina la macro
	
.ENDM

.MACRO MOVE_TO ;macro para mover el cursor del LCD
	LDI R20, @0
	CALL WRITE_4BITS_INSTRUCTION
.ENDM


.CSEG
	RJMP MAIN

.ORG INT_VECTORS_SIZE
MAIN: ;main de prueba
	CALL CONFIGURATION 
	WRITE_FROM_ROM TEXTO
HERE:
	RJMP HERE

CONFIGURATION:
	;configuro DDRB como salida
	LDI R16, 0x3F
	OUT DDRB, R16
	LDI R16, 0X80
	OUT DDRD, R16
	;limpio ENABLE y RS
	CALL CLR_ENABLE
	CALL CLR_RS
	DELAY 255, 255 ; espero ~15ms
	;INICIO CONFIGURATION PARA MODO 4 BITS (SEGUN DATASHEET)
	LDI R20, SET_8BITS_LONG
	CALL WRITE_8BITS
	DELAY 85, 255 ; espero ~5ms
	LDI R20, SET_8BITS_LONG
	CALL WRITE_8BITS
	DELAY 1, 255 ; espero ~100us
	LDI R20, SET_8BITS_LONG
	CALL WRITE_8BITS
	DELAY 255, 255
	LDI R20, SET_4BITS_LONG
	CALL WRITE_8BITS
	DELAY 255, 255
	;FIN CONFIGURATION PARA MODO 4 BITS
	;configuro la funcion (numero de lineas, etc)
	LDI R20, FUNCTION_SET
	CALL WRITE_4BITS_INSTRUCTION
	DELAY 2, 255
	;configuro el modo de entrada (incremento, decremento, desplazamiento, etc)
	LDI R20, ENTRY_MODE
	CALL WRITE_4BITS_INSTRUCTION
	DELAY 2, 255
	;configuro el modo de display (parpadeo de cursor, encendido, apagado, etc)
	LDI R20, SET_DISPLAY
	CALL WRITE_4BITS_INSTRUCTION
	DELAY 2, 255
	;limpio la pantalla
	CALL CLEAN
	RET
	
CLR_ENABLE: ;limpio la salida de enable
	IN R16, PORTB
	ANDI R16, ~(1<<ENABLE)
	OUT PORTB, R16
	RET

SET_ENABLE: ; seteo la salida de enable
	IN R16, PORTB
	ORI R16, (1<<ENABLE)
	OUT PORTB, R16
	RET

CLR_RS: ;limpio la salida de RS
	IN R16, PORTB
	ANDI R16, ~(1<<RS)
	OUT PORTB, R16
	RET

SET_RS: ; seteo la salida de RS
	IN R16, PORTB
	ORI R16, (1<<RS)
	OUT PORTB, R16
	RET

WRITE_8BITS:
	;recibe en R20 lo que se quiere escribir, solo se usa para configurar el LCD
	CALL SET_ENABLE ; seteo enable
	IN R16, PORTB ; cargo PORTB
	ANDI R20, MASK_4LSB ; dejo solo los ultimos 4
	ANDI R16, ~MASK_4LSB ;  limpio los ultimos de PORTB
	OR R16, R20 ; cargo R20 en R16
	OUT PORTB, R16 ; saco PORTB
	CALL CLR_ENABLE ; limpio ENABLE
	RET

WRITE_4BITS_INSTRUCTION:
	;recibe en R20 lo que se quiere escribir
	CALL SET_ENABLE ;activo ENABLE
	CALL CLR_RS ; RS = 0 (estoy mandando una instruccion)
	IN R16, PORTB ; cargo PORTB
	MOV R17, R20 ; copio R20 a R17 para no perderlo
	SWAP R17 ; intercambio los nibbles ya que primero se manda el nibble alto
	ANDI R16, ~MASK_4LSB ; limpio los ultimos de R16 (PORTB)
	ANDI R17, MASK_4LSB ; dejo solo los ultimos de R17 para no pisar a PORTB
	OR R16, R17; copio R17 a R16
	OUT PORTB, R16 ;saco a PORTB
	DELAY 1, 255 ; espero algunos microsegundos
	CALL CLR_ENABLE ; ENABLE = 0, mando el dato
	DELAY 1, 255 ; espero algunos microsegundos
	;lo mismo pero enviando el nibble mas bajo
	CALL SET_ENABLE
	MOV R17, R20
	ANDI R16, ~MASK_4LSB
	ANDI R17, MASK_4LSB
	OR R16, R17
	OUT PORTB, R16
	DELAY 1, 255
	CALL CLR_ENABLE
	DELAY 1, 255
	RET

WRITE_4BITS_CHARACTER:
	;recibe en R20 lo que se quiere escribir
	CALL SET_ENABLE;desactivo enable
	CALL SET_RS ;limpio RS(instruccion)
	IN R16, PORTB
	MOV R17, R20 ;copio R20 a R17
	SWAP R17
	ANDI R16, ~MASK_4LSB ; limpio los ultimos de R16
	ANDI R17, MASK_4LSB ; dejo solo los ultimos de R17
	OR R16, R17; copio R17 a R16
	OUT PORTB, R16 ;saco a PORTB
	DELAY 1, 255
	CALL CLR_ENABLE ;activo enable
	DELAY 1, 255
	CALL SET_ENABLE ;desactivo enable
	MOV R17, R20 ;copio de nuevo
	ANDI R16, ~MASK_4LSB ; limpio los ultimos de R16
	ANDI R17, MASK_4LSB ; dejo solo los ultimos de R17
	OR R16, R17; copio R17 a R16
	OUT PORTB, R16 ;saco a PORTB
	DELAY 1, 255
	CALL CLR_ENABLE ;activo enable
	DELAY 1, 255
	RET


CLEAN:
	LDI R20, CLEAN_DISPLAY ;cargo instruccion de limpiar
	CALL WRITE_4BITS_INSTRUCTION ; llamo a escribir
	DELAY 85, 255 ; espero
	RET

PUSH_EVERYTHING:
	PUSH R16
	PUSH R17
	PUSH R18
	PUSH R20
	PUSH R21
	RET

POP_EVERYTHING:
	POP R16
	POP R17
	POP R18
	POP R20
	POP R21
	RET




TEXTO: .DB "Soy un display LCD de 16x2", '\0'


	
