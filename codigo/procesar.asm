.include "m328pdef.inc"


INICIALIZAR_TODO: ;inicializa el vector de datos en 0
	LDI XL, LOW(DATOS)
	LDI XH, HIGH(DATOS)
	LDI R16, 1 
	LDI R17, 1	;arranca en 1 el contador (LSB)
	LDI R18, 0 ; MSB
	LDI R19, 8
	CLR R0
FOR_INICIALIZAR_TODO:
	ST X+, R0
	LDI R16, 1
	ADD R17, R16
	ADC R18, R0
	CPSE R18, R19 ;cuento hasta 1024
	RJMP FOR_INICIALIZAR_TODO
	RET

INICIALIZAR_SUMAS: ;inicializo la suma de tension y corriente en 0
	CLR R7
	CLR R8
	CLR R9
	CLR R10
	CALL GUARDAR_SUMA_TENSION
	CALL GUARDAR_SUMA_CORRIENTE
	RET

	
SUMAR_3_4_BYTES: ; SE LE PASA R7(LSB) R8 R9 Y R10 (MSB) Y R23(LSB) R24 Y R25 (MSB)
	CLR R0
	ADD R7, R23
	ADC R8, R24
	ADC R9, R25
	ADC R10, R0
	RET

RESTAR_4_3_BYTES: ;SE LE PASA R7(LSB) R8 R9 Y R10 (MSB) Y R23(LSB) R24 Y R25 (MSB)
	CLR R0
	SUB R7, R23
	SBC R8, R24
	SBC R9, R25
	SBC R10, R0
	RET
	
PROCESAR:
	;leo el pendiente
	LDS XL, PTR_PENDIENTES_LECTURA
	LDS XH, PTR_PENDIENTES_LECTURA + 1
	LD R16, X+
	LD R17, X+

	;cargo la suma total (carga en r7(LSB) hasta r10 (MSB))
	LDS R18, CTR_PTR_DATOS ; el contador arranca en uno, entonces si el numero es impar es tension y si es par es corriente
	SBRC R18, 0
	CALL CARGAR_SUMA_TENSION
	SBRS R18, 0
	CALL CARGAR_SUMA_CORRIENTE

	;calculo el cuadrado del viejo y guardo el nuevo (y guardo el puntero de nuevo en ram)
	LDS YL, PTR_DATOS
	LDS YH, PTR_DATOS + 1
	LD R21, Y
	ST Y+, R16
	LD R22, Y
	ST Y+, R17
	STS PTR_DATOS, YL
	STS PTR_DATOS + 1, YH
	CALL CUADRADO ;llamo a cuadrado con R21(L) y R22(M) y me devuelve R23(L) R24 Y R25 (M)

	;le resto a la suma total
	CALL RESTAR_4_3_BYTES

	;calculo el cuadrado nuevo
	MOV R21, R16
	MOV R22, R17
	CALL CUADRADO

	;sumo el cuadrado nuevo
	CALL SUMAR_3_4_BYTES

	;guardo la suma de nuevo
	SBRC R18, 0
	CALL GUARDAR_SUMA_TENSION
	SBRS R18, 0
	CALL GUARDAR_SUMA_CORRIENTE

	;	LDI R23, LOW(HOLA<<1)
	;LDI R24, HIGH(HOLA<<1)
	;WRITE_FROM_ROM

	;sumo al contador del puntero
	LDS R19, CTR_PTR_DATOS + 1 ; el LSB ya lo habia cargado anteriormente
	LDI R16, 1
	ADD R18, R16
	CLR R0
	ADC R19, R0
	
	;guardo el contador del puntero
	STS CTR_PTR_DATOS, R18
	STS CTR_PTR_DATOS + 1, R19
	
	;si llego a 512 reinicio
	CPI R19, 2
	BREQ BRANCH_INICIALIZAR_PUNTERO_DATOS

SEGUIR_PUNTERO_DATOS:
	;decrementa los pendientes.
	LDS R19, CTR_PENDIENTES
	DEC R19
	STS CTR_PENDIENTES, R19

	;suma al contador del puntero y reinicia el puntero si se llego al final
	LDS R19, CTR_PTR_PENDIENTES_LECTURA 
	DEC R19
	STS CTR_PTR_PENDIENTES_LECTURA, R19
	BREQ BRANCH_INICIALIZAR_PUNTERO_PENDIENTES_LECTURA
SEGUIR_INICIALIZAR_PUNTERO_PENDIENTES_LECTURA:
	RET

BRANCH_INICIALIZAR_PUNTERO_DATOS:
	;ACA SE PODRIA LLAMAR A LA RAIZ
	CALL CALCULAR_VALOR_FINAL_TENSION
	CALL INICIALIZAR_PTR_DATOS
	RJMP SEGUIR_PUNTERO_DATOS

BRANCH_INICIALIZAR_PUNTERO_PENDIENTES_LECTURA:
	CALL INICIALIZAR_PUNTERO_PENDIENTES_LECTURA
	RJMP SEGUIR_INICIALIZAR_PUNTERO_PENDIENTES_LECTURA

INICIALIZAR_PTR_DATOS: ;cambia el puntero  al inicio de datos y reinicia el contador
	LDI XL, LOW(DATOS)
	LDI XH, HIGH(DATOS)
	STS PTR_DATOS, XL
	STS PTR_DATOS + 1, XH
	LDI R18, 1
	LDI R19, 0
	STS CTR_PTR_DATOS, R18
	STS CTR_PTR_DATOS + 1, R19 
	RET
	

INICIALIZAR_PUNTERO_PENDIENTES_LECTURA: ;carga  el puntero de los pendientes de lectura al principio y reinicia el contador
	LDI XL, LOW(PENDIENTES)
	LDI XH, HIGH(PENDIENTES)
	STS PTR_PENDIENTES_LECTURA, XL
	STS PTR_PENDIENTES_LECTURA + 1, XH
	LDI R16, 16
	STS CTR_PTR_PENDIENTES_LECTURA, R16
	RET


CARGAR_SUMA_TENSION: ;carga la suma de tension a los registros R7, R8, R9 y R10
	LDI XL, LOW(SUMA_TOTAL_TENSION)
	LDI XH, HIGH(SUMA_TOTAL_TENSION)
	LD R7, X+
	LD R8, X+
	LD R9, X+
	LD R10, X+
	RET

GUARDAR_SUMA_TENSION: ;guarda la suma de tension desde los registros R7, R8, R9 y R10
	LDI XL, LOW(SUMA_TOTAL_TENSION)
	LDI XH, HIGH(SUMA_TOTAL_TENSION)
	ST X+, R7
	ST X+, R8
	ST X+, R9
	ST X+, R10
	RET

CARGAR_SUMA_CORRIENTE:;carga la suma de corriente a los registros R7, R8, R9 y R10
	LDI XL, LOW(SUMA_TOTAL_CORRIENTE)
	LDI XH, HIGH(SUMA_TOTAL_CORRIENTE)
	LD R7, X+
	LD R8, X+
	LD R9, X+
	LD R10, X+
	RET

GUARDAR_SUMA_CORRIENTE: ;guarda la suma de corriente desde los registros R7, R8, R9 y R10
	LDI XL, LOW(SUMA_TOTAL_CORRIENTE)
	LDI XH, HIGH(SUMA_TOTAL_CORRIENTE)
	ST X+, R7
	ST X+, R8
	ST X+, R9
	ST X+, R10
	RET


CALCULAR_VALOR_FINAL_TENSION: ;primero hace la raiz cuadrada y despues divide por 16 (shift derecho 4 veces)
	LDI XL, LOW(SUMA_TOTAL_TENSION)
	LDI XH, HIGH(SUMA_TOTAL_TENSION)
	LD R5, X+
	LD R4, X+
	LD R3, X+
	LD R2, X+
	CALL RAIZ_CUADRADA; toma en R5(L) hasta R2 (M) (ojo! alreves que todo el programa)
	;devuelve desde R21(L) a R20(M)
	LSR R20
	ROR R21
	LSR R20
	ROR R21
	LSR R20
	ROR R21
	LSR R20
	ROR R21
	LDI XL, LOW(VALOR_FINAL_TENSION)
	LDI XH, HIGH(VALOR_FINAL_TENSION)
	ST X+, R21
	ST X+, R20
	RET

CALCULAR_VALOR_FINAL_CORRIENTE:
	LDS XL, LOW(SUMA_TOTAL_CORRIENTE)
	LDS XH, HIGH(SUMA_TOTAL_CORRIENTE)
	LD R5, X+
	LD R4, X+
	LD R3, X+
	LD R2, X+
	CALL RAIZ_CUADRADA; toma en R5(L) hasta R2 (M) (ojo! alreves que todo el programa)
	;devuelve desde R21(L) a R20(M)
	LSR R20
	ROR R21
	LSR R20
	ROR R21
	LSR R20
	ROR R21
	LSR R20
	ROR R21
	LDI XL, LOW(VALOR_FINAL_CORRIENTE)
	LDI XH, HIGH(VALOR_FINAL_CORRIENTE)
	ST X+, R21
	ST X+, R20
	RET
	
