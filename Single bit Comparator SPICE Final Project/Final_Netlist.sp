** EGCP441 Spring 2020 1-bit Comparator Project
* BY: James Samawi and Levi Randall

* Circuit Extracted by Tanner Research's L-Edit V7.12 / Extract V4.00 ;

*** Extration Obtained
.include Model.txt

* NODE NAME ALIASES
* 		gnd = Gnd (13.499,-12.999)
*		Vdd = Vdd (20.499,36)
*		3 = B (35.499,9)
*		4 = not_B (43.499,10)
*       1 = A (20.999,12.5)
*       2 = not_A (25.499,10)
*       5 = Y (65.999,-2.499)

* TODO:
* Declare Vdd = 5v, gnd = 0v, CL = 10fF
* Vin pulse A and B which mimic logic inputs
* output should mimic xnor logic

*Inverter for A
M5 2 1 Vdd Vdd PMOS L=2u W=10u AD=110p PD=62u AS=255p PS=125u
* M5 DRAIN GATE SOURCE BULK (34.5 16.5 36.5 26.5)
M1 2 1 gnd gnd NMOS L=2u W=10u AD=110p PD=62u AS=260p PS=127u
* M1 DRAIN GATE SOURCE BULK (34.5 -5.5 36.5 4.5)

*Inverter for B
M6 4 3 Vdd Vdd PMOS L=2u W=10u AD=175p PD=75u AS=175p PS=75u
* M6 DRAIN GATE SOURCE BULK (65.5 16.5 67.5 26.5)
M2 4 3 gnd gnd NMOS L=2u W=10u AD=190p PD=78u AS=110p PS=62u
* M2 DRAIN GATE SOURCE BULK (51.5 -5.5 53.5 4.5)

*Top
M3 4 2 5 gnd NMOS L=2u W=10u AD=260p PD=127u AS=260p PS=127u
* M3 DRAIN GATE SOURCE BULK (20 -5.5 22 4.5)
M7 5 1 4 Vdd PMOS L=2u W=10u AD=255p PD=125u AS=255p PS=125u
* M7 DRAIN GATE SOURCE BULK (20 16.5 22 26.5)

*Bottom
M4 5 1 3 gnd NMOS L=2u W=10u AD=190p PD=78u AS=190p PS=78u
* M4 DRAIN GATE SOURCE BULK (67 -5.5 69 4.5)
M8 3 2 5 Vdd PMOS L=2u W=10u AD=175p PD=75u AS=110p PS=62u
* M8 DRAIN GATE SOURCE BULK (51.5 16.5 53.5 26.5)

C6 5 gnd 1fF
Va 1 gnd pulse (0 5 0 1ps 1ps 8ns 16ns)
Vb 3 gnd pulse (0 5 0 1ps 1ps 4ns 8ns)
Vdd	Vdd gnd DC 5

*Resistor on input A used for measurements:
*R6 9 1 10k
*Va 9 gnd pulse (0 5 0 1ps 1ps 8ns 16ns)

* TODO:
* run as transient sim. output = V(5)
* Gather data using trans param statements

.op
.tran 1ps 64ns
.plot V(1) V(3) V(5)

.measure tran TPHL trig V(1) val=0.9 rise=1 targ V(5) val=0.9 fall=1
.measure tran TPLH trig V(1) val=0.9 fall=2 targ V(5) val=0.9 rise=2
.measure charge_volt integral V(1) From=20ns to=36ns
.measure tran s_pwr AVG I(1) From=20ns to=36ns

.END
