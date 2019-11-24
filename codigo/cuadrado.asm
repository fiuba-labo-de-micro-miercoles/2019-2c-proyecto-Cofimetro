.include "m328pdef.inc"

.DEF aux_1 = R19


; Multiplica R21-R22 * R21-R22 y lo pone en R23-R24-R25
CUADRADO:
	PUSH aux_1
	PUSH R0
	PUSH R1
	CLR aux_1
	CLR R25
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


	POP R1
	POP R0
	POP aux_1
RET
