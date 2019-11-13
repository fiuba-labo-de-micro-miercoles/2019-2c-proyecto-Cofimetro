.include "m328pdef.inc"

.DEF aux_1 = R17

.CSEG
	RJMP MAIN

.ORG INT_VECTORS_SIZE

MAIN:
	LDI R21, 0x3A
	LDI R22, 0x02
	CALL CUADRADO

FIN: RJMP FIN

; Multiplica R21-R22 * R21-R22 y lo pone en R23-R24-R25
CUADRADO:
	CLR aux_1
	MUL R21, R21
 	MOV R23, R0
	MOV R24, R1

	MUL R22, R21
	ADD R24, R0	
	ADC R25, aux_1
	ADD R24, R0	
	ADC R25, aux_1
	ADD R25, R1
	ADD R25, R1

	MUL R22, R22
	ADD R25, R0
RET
