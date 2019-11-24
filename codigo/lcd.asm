.include "m328pdef.inc"

;FALTA: -hacer nueva funcion que permita escribir en la posicion que se quiera (usando MOVE_TO)

;pines
.EQU D4 = 0 ;LSB de comunicacion de datos (se usa en modo 4 bits)
.EQU D5 = 1 ;
.EQU D6 = 2	;
.EQU D7 = 3 ;MSB de comunicacion de datos
.EQU ENABLE = 4 ;pin de enable
.EQU RS = 5 ;pin de RS


;comandos
.EQU SET_8BITS_LONG = 0x03 ;comando para configurar modo de 8 bits
.EQU SET_4BITS_LONG = 0x02 ;comando para configurar modo de 4 bits
.EQU FUNCTION_SET = 0x2C ;comando para configurar numero de lineas, etc
.EQU SET_DISPLAY = 0x0C ;comando para configurar el display
.EQU CLEAN_DISPLAY = 0x01 ;comando para limpiar el display
.EQU ENTRY_MODE = 0x06 ;comando para configurar cursor,etc 
.EQU NEXT_LINE = 0x40 ;posicion ddram de la primera posicion de segunda linea
.EQU MOVE_DDRAM = 0x80 ;comando para cambiar posicion ddram
.EQU INICIO_LCD = 0x00
.EQU FIN_V_LCD = 5

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

;.MACRO WRITE_FROM_ROM ;macro para cargar desde la rom, se le pasa una posicion
;	;LDI ZL, LOW(@0<<1)
;	;LDI ZH, HIGH(@0<<1)
;	MOV ZL, R16
;	MOV ZH, R17
;	LDI R21, 15 ; cargo el contador de linea
;FOR_WRITE_ROM:
;	LPM R20, Z+ ; cargo el caracter  desde la rom
;	CPI R20, 0 ; veo si es fin de texto
;	BREQ END_WRITE_ROM ; si es el final me voy de la macro
;	CALL WRITE_4BITS_CHARACTER ;escribo
;	CPI R21, 0 ;veo si terminó la linea
;	BREQ ENTER_WRITE_ROM ; si termino la linea me muevo a la otra
;	DEC R21 ;decremento el contador de linea
;	RJMP FOR_WRITE_ROM

;ENTER_WRITE_ROM:
;	MOVE_TO NEXT_LINE
;	LDI R21, 15
;	RJMP FOR_WRITE_ROM

;END_WRITE_ROM:
	;termina la macro

;.ENDM


.MACRO WRITE_FROM_RAM ;macro para cargar desde la ram, se le pasa una posicion
	LDI ZL, LOW(@0)
	LDI ZH, HIGH(@0)
	LDI R21, 15 ; cargo el contador de linea
FOR_WRITE_RAM:
	LPM R20, Z+ ; cargo el caracter  desde la ram
	CPI R20, 0 ; veo si es fin de texto
	BREQ END_WRITE_RAM ; si es el final me voy de la macro
	CALL WRITE_4BITS_CHARACTER ;escribo
	CPI R21, 0 ;veo si terminó la linea
	BREQ ENTER_WRITE_RAM ; si termino la linea me muevo a la otra
	DEC R21 ;decremento el contador de linea
	RJMP FOR_WRITE_RAM

ENTER_WRITE_RAM:
	MOVE_TO NEXT_LINE
	LDI R21, 15
	RJMP FOR_WRITE_RAM

END_WRITE_RAM:
	;termina la macro
	
.ENDM





CONFIGURATION_LCD:
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
	CALL SET_RS ;activo RS (escribo datos)
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

TEXTO_LCD:
	LDI R23, LOW(TEX_TENSION<<1)
	LDI R24, HIGH(TEX_TENSION<<1)
	LDI R25, INICIO_LCD
	WRITE_FROM_ROM
	RET
