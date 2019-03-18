# EC3882-G4-EM2019
Proyectos realizados para la materia EC3882: Laboratorio de Proyectos 2.

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
