# EC3882-G4-EM2019
Proyectos realizados para la materia EC3882: Laboratorio de Proyectos 2.

Grupo 4:

Manuel Hurtado - 12-10004
Daniela Rivas - 14-10914

Profesor: Novel Certad



PROYECTO I: OSCILOSCOPIO DIGITAL 

Objetivo: la realización de un osciloscopio digital, a través de una tarjeta de desarrollo de bajo costo y de alto rendimiento (DEMOQE128), y una interfaz amigable para el usuario realizada en el programa Processing. Las señales a probar en el osciloscopio digital provendrán de un generador de funciones, cuya señal será acondicionada para proteger la tarjeta.

I.	Resumen: 

   Una vez acondicionada la señal, esta se recibe por el DEMOQE128, y este envía la señal a través del puerto serial empleando el protocolo RS-232. Sin embargo, la resolución del canal analógico es de 12 bits; por lo que se deben acomodar los 12 bits de cada canal en bytes en CodeWarrior, luego de habilitar las entradas y determinar el muestreo. Finalmente, a través de Processing se toman los bytes enviados, se arreglan nuevamente en sus 12 bits originales, y se grafican de manera que cumplan con los requisitos del proyecto.

II.	Presentación de equipo a producir, especificaciones:

  A.	Bloque de acondicionamiento:
      1.	Regulador de 5V.
      2.	LM234 para reajustar (limitar el voltaje) las señales analógicas.
      3.	SN74ALS04BN para las señales digitales.
  B.	Bloque de recepción de datos (CodeWarrior):
      1.	Muestreo a 12 bits, ancho de banda de 1 kHz.
  C.	Bloque de visualización gráfica (Processing):  
      1.	2 x canales digitales.
      2.	2 x canales analógicos.
      3.	Grid.
      4.	Selector de canal. 
      5.	Selector de base de tiempo de 3 niveles: 10Hz, 100Hz, 1kHz.
      6.	Selector de amplitud de 3 niveles: 0.3V, 1.0V, 3.0V.

III. Esquema del funcionamiento

   Acondicionamiento  -->  CodeWarrior  -->  Processing

IV.	Funcionamiento general del Proyecto
  
  A.	Acondicionamiento: 
   
   En la imagen "Esquemático - Circuito Protección.PNG" que se encuentra anexa, se presenta el circuito que se montó con el objetivo de acondicionar la señal. Este se utiliza para proteger la tarjeta DEMOQE128 ante una posible entrada de voltaje mayor a la que este soporta, consiste en:
      1. Un integrado de 4 amplificadores operacionales alimentados con 5V para que, si en la entrada de este hay un voltaje mayor a 5V, este se queme para proteger la tarjeta. De igual manera, a la salida de este se encuentra una resistencia de protección y un diodo zener que limita la salida a máximo 3V.
      2. Un integrado que consiste en un inversor lógico que a su salida tiene un divisor de voltaje seguido de una resistencia de protección y un diodo zener que limita la salida a máximo 3V.


V.	Modificaciones Introducidas y Justificación
  
  A.	Desentramado del protocolo en Processing: 
   
   Inicialmente, el desentramado se realizaba haciendo shift a la izquierda 26 veces en U1 (o H1), luego shift a la derecha 20 veces del mismo; despues de esto, para U2 (o H2) se hacia shift a la izquierda 26 veces y luego 26 veces a la derecha, pra finalmente hacer un OR entre ambos para asi obtener un canal analogico. Para los canales digitales, luego de shiftear U1 y U2 25 veces a la izquierda, se shifteaban 31 veces a la derecha, y se realizaba un AND con 1. Por ejemplo:
        
U1 = 00000000000000000000000010110011

U2 = 00000000000000000000000001100110

  a. Shifteo a la izquierda de U1:
  U1a = 11001100000000000000000000000000

  b. Shifteo a la derecha de U1:
  U1b = 00000000000000000000110011000000

  c. Shifteo a la izquierda de U2:
  U2a = 10011000000000000000000000000000

  d. Shifteo a la derecha de U2:
  U2b = 00000000000000000000000000100110

  e. OR entre U1b y U2b:
  CH1 = 00000000000000000000110011100110

   La razón por la que se decidió cambiar es que muchas veces al shiftear a la izquierda 26 veces, ocurría un "overflow" (se solicitaba un dato mayor del que podía guardar un int), y el programa retornaba un int de la máxima capacidad (32 "1"s seguidos). El desentramado implementado que se explico anteriormente con cuenta con dicho problema. 
   
B.  Se colocaron dos opciones para graficar:

  En las primeras versiones del código, se graficaba utilizando la función de Processing llamada "line"; sin embargo, debido a que era un requerimiento y era otro tipo de visualización de la señal (que permite ver el número de puntos que se grafican por escala), se decidió agregar además la función "point".


