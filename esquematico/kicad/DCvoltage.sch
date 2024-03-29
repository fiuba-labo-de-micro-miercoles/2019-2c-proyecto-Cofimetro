EESchema Schematic File Version 4
LIBS:Arduino_Uno_R3_From_Scratch-cache
EELAYER 30 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 13
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L Device:Varistor_US RV?
U 1 1 5DC89CEF
P 6550 3800
F 0 "RV?" H 6653 3846 50  0000 L CNN
F 1 "Varistor_US" H 6653 3755 50  0000 L CNN
F 2 "" V 6480 3800 50  0001 C CNN
F 3 "~" H 6550 3800 50  0001 C CNN
	1    6550 3800
	1    0    0    -1  
$EndComp
$Comp
L Device:Fuse F?
U 1 1 5DC8B1E9
P 7050 4950
F 0 "F?" V 6853 4950 50  0000 C CNN
F 1 "Fuse" V 6944 4950 50  0000 C CNN
F 2 "" V 6980 4950 50  0001 C CNN
F 3 "~" H 7050 4950 50  0001 C CNN
	1    7050 4950
	0    1    1    0   
$EndComp
Wire Wire Line
	5450 3900 5450 4000
Wire Wire Line
	5450 4400 5450 4500
Wire Wire Line
	5450 4900 5450 4950
Wire Wire Line
	5450 4950 6550 4950
Wire Wire Line
	6550 3950 6550 4950
Connection ~ 6550 4950
Wire Wire Line
	6550 4950 6900 4950
Wire Wire Line
	5450 2550 6550 2550
Wire Wire Line
	6550 2550 6550 3650
Wire Wire Line
	6550 2550 7400 2550
Connection ~ 6550 2550
$Comp
L power:GND #PWR?
U 1 1 5DC8C9F8
P 5450 4950
F 0 "#PWR?" H 5450 4700 50  0001 C CNN
F 1 "GND" H 5455 4777 50  0000 C CNN
F 2 "" H 5450 4950 50  0001 C CNN
F 3 "" H 5450 4950 50  0001 C CNN
	1    5450 4950
	1    0    0    -1  
$EndComp
Connection ~ 5450 4950
$Comp
L Amplifier_Operational:LM348-quad U?
U 1 1 5DC8E0F4
P 2300 2900
F 0 "U?" H 2475 3025 50  0000 C CNN
F 1 "LM348-quad" H 2475 2934 50  0000 C CNN
F 2 "" H 2300 2900 50  0001 C CNN
F 3 "" H 2300 2900 50  0001 C CNN
	1    2300 2900
	1    0    0    -1  
$EndComp
$Comp
L Device:R_US R?
U 1 1 5DCB96DE
P 5450 2700
F 0 "R?" H 5518 2746 50  0000 L CNN
F 1 "R_US" H 5518 2655 50  0000 L CNN
F 2 "" V 5490 2690 50  0001 C CNN
F 3 "~" H 5450 2700 50  0001 C CNN
	1    5450 2700
	1    0    0    -1  
$EndComp
$Comp
L Device:R_US R?
U 1 1 5DCB9AAD
P 5450 3250
F 0 "R?" H 5518 3296 50  0000 L CNN
F 1 "R_US" H 5518 3205 50  0000 L CNN
F 2 "" V 5490 3240 50  0001 C CNN
F 3 "~" H 5450 3250 50  0001 C CNN
	1    5450 3250
	1    0    0    -1  
$EndComp
$Comp
L Device:R_US R?
U 1 1 5DCBC4B0
P 5450 4250
F 0 "R?" H 5518 4296 50  0000 L CNN
F 1 "R_US" H 5518 4205 50  0000 L CNN
F 2 "" V 5490 4240 50  0001 C CNN
F 3 "~" H 5450 4250 50  0001 C CNN
	1    5450 4250
	1    0    0    -1  
$EndComp
$Comp
L Device:R_US R?
U 1 1 5DCBC6D2
P 5450 4750
F 0 "R?" H 5518 4796 50  0000 L CNN
F 1 "R_US" H 5518 4705 50  0000 L CNN
F 2 "" V 5490 4740 50  0001 C CNN
F 3 "~" H 5450 4750 50  0001 C CNN
	1    5450 4750
	1    0    0    -1  
$EndComp
$Comp
L Device:R_US R?
U 1 1 5DCBCAEF
P 5450 3750
F 0 "R?" H 5518 3796 50  0000 L CNN
F 1 "R_US" H 5518 3705 50  0000 L CNN
F 2 "" V 5490 3740 50  0001 C CNN
F 3 "~" H 5450 3750 50  0001 C CNN
	1    5450 3750
	1    0    0    -1  
$EndComp
$Comp
L Switch:SW_Rotary12 SW?
U 1 1 5DCC0A24
P 3950 3600
F 0 "SW?" H 3850 4381 50  0000 C CNN
F 1 "SW_Rotary12" H 3850 4290 50  0000 C CNN
F 2 "" H 3750 4300 50  0001 C CNN
F 3 "http://cdn-reichelt.de/documents/datenblatt/C200/DS-Serie%23LOR.pdf" H 3750 4300 50  0001 C CNN
	1    3950 3600
	1    0    0    -1  
$EndComp
Wire Wire Line
	5450 2850 5450 3000
Wire Wire Line
	5450 2550 4350 2550
Wire Wire Line
	4350 2550 4350 3000
Connection ~ 5450 2550
Wire Wire Line
	5450 3000 4550 3000
Wire Wire Line
	4550 3000 4550 3100
Wire Wire Line
	4550 3100 4350 3100
Connection ~ 5450 3000
Wire Wire Line
	5450 3000 5450 3100
Wire Wire Line
	5450 3450 5050 3450
Wire Wire Line
	5050 3450 5050 3200
Wire Wire Line
	5050 3200 4350 3200
Wire Wire Line
	5450 3400 5450 3450
Connection ~ 5450 3450
Wire Wire Line
	5450 3450 5450 3600
Wire Wire Line
	5450 4000 4850 4000
Wire Wire Line
	4850 4000 4850 3300
Wire Wire Line
	4850 3300 4350 3300
Connection ~ 5450 4000
Wire Wire Line
	5450 4000 5450 4100
Wire Wire Line
	5450 4500 4650 4500
Wire Wire Line
	4650 4500 4650 3400
Wire Wire Line
	4650 3400 4350 3400
Connection ~ 5450 4500
Wire Wire Line
	5450 4500 5450 4600
$EndSCHEMATC
