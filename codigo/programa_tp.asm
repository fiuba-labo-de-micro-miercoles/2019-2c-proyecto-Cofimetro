.include "m328pdef.inc"

;Frecuencia 16MHz

;Cosas para mas adelante:
;-cargar desde RAM convirtiendo numeros a ASCII



;comandos ADC
.EQU ADMUX_CONFIG = 0x40
.EQU ADCSRA_CONFIG = 0x8F


;timer0
.EQU COMPARE_2MHZ_39US = 78




.DSEG 
DATOS: .BYTE 1024 ;datos tanto de tension como de corriente, van intercalados
PTR_DATOS: .BYTE 2 ;puntero a la posicion actual de datos
CTR_PTR_DATOS: .BYTE 2 ;contador de en que posicion estoy en datos
PENDIENTES: .BYTE 16 ;vector de pendientes
PTR_PENDIENTES_ESCRITURA: .BYTE 2 ;puntero a la posicion actual de pendientes para escribir
CTR_PTR_PENDIENTES_ESCRITURA: .BYTE 1 ;contador de en que posicion estoy de pendientes para escribir
PTR_PENDIENTES_LECTURA: .BYTE 2 ;puntero a la posicion actual de pendientes para leer
CTR_PTR_PENDIENTES_LECTURA: .BYTE 1 ;contador de en que posicion estoy de pendientes para leer
CTR_PENDIENTES: .BYTE  1 ;contador de cuantos hay pendientes para procesar
SUMA_TOTAL_CORRIENTE: .BYTE 4 ;suma de cuadrados de corriente
SUMA_TOTAL_TENSION: .BYTE 4 ;suma de cuadrados de tension

.CSEG
	RJMP MAIN

.ORG 0x001C 
	RJMP HANDLER_TIMER0

.ORG 0x002A
	RJMP HANDLER_ADC

.ORG INT_VECTORS_SIZE

.include "lcd.asm" ; PREGUNTAR DONDE PONERLO
.include "procesar.asm"


MAIN: ;main de prueba
	CALL CONFIGURATION_LCD

	;configuro los pines de DDRC como entrada
	IN R16, DDRC
	LDI R16, 0x00
	OUT DDRC, R16

	;configuro el timer0 Y ADC

	IN R16, TCCR0A
	ANDI R16, 0x02
	OUT TCCR0A,R16

	LDI R16, 0x82
	OUT TCCR0B, R16

	LDI R16, COMPARE_2MHZ_39US
	OUT OCR0A, R16

	LDI R16, 0x02
	STS TIMSK0, R16

	LDI R16, ADMUX_CONFIG
	STS ADMUX, R16
	LDI R16, ADCSRA_CONFIG
	STS ADCSRA, R16

	CALL INICIALIZAR_PUNTERO_ADC
	
	;configuro el procesamiento
	CALL INICIALIZAR_DATOS

	CALL INICIALIZAR_SUMAS
	
	CALL INICIALIZAR_PTR_DATOS

	CALL INICIALIZAR_PUNTERO_PENDIENTES_LECTURA

	;activo las interrupciones
	SEI
	
;IMPORTANTE, VER DESDE DONDE LLAMAR A RAIZ, ¿CUANDO EL CONTADOR LLEGA A CERO PRENDO UN FLAG??

HERE: ;ciclo infinito de verificar si hay pendientes para procesar
	LDS R16, CTR_PENDIENTES
	CLR R0
	CPSE R16, R0
	CALL PROCESAR
	RJMP HERE

	

CLEAN_ADIF:
	LDS R16, ADCSRA
	ORI R16, (1<<ADIF)
	STS ADCSRA, R16
	RET

START_ADC:
	LDS R16, ADCSRA
	ORI R16, (1<<ADSC)
	STS ADCSRA, R16	
	RET



HANDLER_TIMER0: ;las interrupciones se pueden modularizar?
	PUSH R16
	LDS R16, ADMUX ;cargo el multiplexor del adc
	LDI R17, 1
	EOR R16, R17 ;hago el xor para intercambiar entre tension y corriente
 	STS ADMUX, R16

	CALL START_ADC ;arranco la conversion del adc
	RETI


HANDLER_ADC:
	PUSH R16 ;pusheo lo que uso
	PUSH R17
	PUSH R26
	PUSH R27
	LDS XL, PTR_PENDIENTES_ESCRITURA ;cargo el puntero que habia guardado antes
	LDS XH, PTR_PENDIENTES_ESCRITURA + 1
	LDS R16, ADCL ; guardo la parte baja del ADC
	ST X+, R16 ; lo guardo en ram y sumo
	LDS R17, ADCH ;guardo la parte alta del ADC
	ST X+, R17 ; lo guardo en ram
	STS PTR_PENDIENTES_ESCRITURA, XL ; vuelvo a guardar el puntero
	STS PTR_PENDIENTES_ESCRITURA + 1, XH
	LDS R17, CTR_PENDIENTES ; sumo al contador de pendientes para que se entere el programa
	INC R17
	STS CTR_PENDIENTES, R17
	LDS R17, CTR_PTR_PENDIENTES_ESCRITURA ; sumo al contador para saber cuando reiniciar el puntero
	DEC R17
	STS CTR_PTR_PENDIENTES_ESCRITURA, R17 ; guardo el contador
	BREQ BRANCH_INICIALIZAR_PUNTERO_ADC ; si es cero reinicio el puntero
SEGUIR_INICIALIZAR_PUNTERO_ADC:
	POP R27 ; popeo todo de nuevo
	POP R26
	POP R17
	POP R16

	RETI
	

BRANCH_INICIALIZAR_PUNTERO_ADC:
	CALL INICIALIZAR_PUNTERO_ADC
	RJMP SEGUIR_INICIALIZAR_PUNTERO_ADC


INICIALIZAR_PUNTERO_ADC:
	LDI XL, LOW(PENDIENTES) ;cargo el puntero de pendientes
	LDI XH, HIGH(PENDIENTES)
	STS PTR_PENDIENTES_ESCRITURA, XL ;guardo el puntero en mi espacio para el puntero
	STS PTR_PENDIENTES_ESCRITURA + 1, XH
	LDI R16, 16 ;reinicio el contador
	STS CTR_PTR_PENDIENTES_ESCRITURA, R16; guardo el contador
	RET







