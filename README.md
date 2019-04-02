# EC3882-G4-EM2019
Proyectos realizados para la materia EC3882: Laboratorio de Proyectos 2.

**Grupo 4:**

> Manuel Hurtado - 12-10004

> Daniela Rivas - 14-10914

**Profesor:** 

> Novel Certad


# PROYECTO I: OSCILOSCOPIO DIGITAL 

Objetivo: la realización de un osciloscopio digital, a través de una tarjeta de desarrollo de bajo costo y de alto rendimiento (*DEMOQE128*), y una interfaz amigable para el usuario realizada en el programa Processing. Las señales a probar en el osciloscopio digital provendrán de un generador de funciones, cuya señal será acondicionada para proteger la tarjeta.

## I.	Resumen: 

   Una vez acondicionada la señal, esta se recibe por el *DEMOQE128*, y este envía la señal a través del puerto serial empleando el protocolo *RS-232*. Sin embargo, la resolución del canal analógico es de 12 bits; por lo que se deben acomodar los 12 bits de cada canal en bytes en CodeWarrior, luego de habilitar las entradas y determinar el muestreo. Finalmente, a través de Processing se toman los bytes enviados, se arreglan nuevamente en sus 12 bits originales, y se grafican de manera que cumplan con los requisitos del proyecto.

## II.	Presentación de equipo a producir, especificaciones:

  #### A.	Bloque de acondicionamiento:
  
   1.	Regulador de 5V.
      
   2.	LM234 para reajustar (limitar el voltaje) las señales analógicas.
      
   3.	SN74ALS04BN para las señales digitales.
      
  #### B.	Bloque de recepción de datos (CodeWarrior):
  
   1.	Muestreo a 12 bits, ancho de banda de 1 kHz.
      
  #### C.	Bloque de visualización gráfica (Processing):  
  
   1.	2 x canales digitales.
      
   2.	2 x canales analógicos.
      
   3.	Grid.
      
   4.	Selector de canal. 
      
   5.	Selector de base de tiempo de 3 niveles: 10Hz, 100Hz, 1kHz.
      
   6.	Selector de amplitud de 3 niveles: 0.3V, 1.0V, 3.0V.
      

## III. Esquema del funcionamiento

   > *Acondicionamiento  ->  CodeWarrior  ->  Processing*

## IV.	Funcionamiento general del Proyecto
  
  #### A.	Acondicionamiento: 
   
   En la imagen *"Esquemático - Circuito Protección.png"* que se encuentra anexa, se presenta el circuito que se montó con el objetivo de acondicionar la señal. Este se utiliza para proteger la tarjeta *DEMOQE128* ante una posible entrada de voltaje mayor a la que este soporta, consiste en:
   
   1. Un integrado de 4 amplificadores operacionales alimentados con 5V para que, si en la entrada de este hay un voltaje mayor a 5V, este se queme para proteger la tarjeta. De igual manera, a la salida de este se encuentra una resistencia de protección y un diodo zener que limita la salida a máximo 3V.
      
   2. Un integrado que consiste en un inversor lógico que a su salida tiene un divisor de voltaje seguido de una resistencia de protección y un diodo zener que limita la salida a máximo 3V.
      

  #### B.  CodeWarrior: 

   En este programa, se realizó el código para programar el *DEMOQE128*. Para este, se tomo en cuenta la manera en que se reciben los datos para ajustarlas al siguiente protocolo: 
   
   Si son 4 Bytes, por ejemplo: 
   
   1. U1 = 01110010
   
   2. U2 = 10110110
   
   3. H1 = 11011001
   
   4. H2 = 10100011 

   Entonces en cada uno de estos, el bit más significativo es una *"flag"*, que al comenzar con 0 implica que es el primer Byte de la cadena que se enviará (U1), por lo que los demás bytes comienzan con 1 (U2, H1, H2). El segundo bit más significativo en U1 y U2 es un canal digital, mientras que en H1 y H2 no significan nada. Los 6 bits restantes de cada byte es una mitad de la información que va en cada canal analógico, de manera que U1 y U2 forman el CH1, y H1 y H2 forman el CH2. Resultando con los valores del ejemplo anterior:
   
   1. CH1 = 110010110110
   
   2. CH2 = 011001100011
   
   La forma en que se ajustaron los datos recibidos a este protocolo se explica con mayor detalle en el código correspondiente. 
   
   En esta etapa, también es importante definir el número de muestras que se tomarán. En este caso, se toman 2000 muestras por segundo. Esto implica que para una señal de 10Hz, se grafican 200 muestras por periodo; para 100Hz, serían 20 muestras por periodo. A 1kHz, graficaríamos 2 muestras y a 10kHz, observariamos una señal con buena forma, pero a distinta frecuencia (ya que es cíclico).
   
   > Nota: Para poder probar en el osciloscopio la frecuencia de muestreo (que se encuentra a 2kHz), el pin PTD6_KBI2P6 niega su valor cada vez que ocurre una interrupción, resultando una onda cuadrada de 1kHz.
   
  #### C.  Processing: 
  
   En este programa, se desentramaron los 4 bytes recibidos para formar los 12 bits de los canales analógicos, el bit de cada canal digital y determinar el valor de cada uno. Luego de esto, se diseñó una interfaz gráfica amigable para el usuario, utilizando como base una imagen que se encuentra anexa llamada *"Osciloscopio Digital.jpg"*, encontrada en el siguiente link: 
   
  https://publicdomainvectors.org/es/vectoriales-gratuitas/Estilizada-ilustraci%C3%B3n-de-vector-frontal-del-osciloscopio/28191.html
   
  Un ejemplo de como se realizó el desentramado es el siguiente. Si se recibieron los bits del ejemplo anterior, se realizan las siguientes operaciones: 
  
  1. Realizo un AND de U1 con 00111111:
  
  U1a = 00000000000000000000000000110011

  2. Shifteo U1a 6 veces a la derecha:
  
  U1b = 00000000000000000000110011000000

  3. Realizo un AND de U2 con 00111111:
  
  U2a = 00000000000000000000000000110110

  4. OR entre U1b y U2a:
  
  CH1 = 00000000000000000000110011100110
  
  El procedimiento se mantuvo para el CH2, y para los canales digitales se realizó un procedimiento similar.
  
  Los detalles de cómo se realizó la interfaz gráfica se encuentran descritas en el código correspondiente.  
   
## V.	Modificaciones Introducidas y Justificación
  
  #### A.	Desentramado del protocolo en Processing: 
   
   Inicialmente, el desentramado se realizaba haciendo shift a la izquierda 26 veces en U1 (o H1), luego shift a la derecha 20 veces del mismo; despues de esto, para U2 (o H2) se hacia shift a la izquierda 26 veces y luego 26 veces a la derecha, pra finalmente hacer un OR entre ambos para asi obtener un canal analogico. Para los canales digitales, luego de shiftear U1 y U2 25 veces a la izquierda, se shifteaban 31 veces a la derecha, y se realizaba un AND con 1. Por ejemplo:
        
  U1 = 00000000000000000000000001110011

  U2 = 0000000000000000000000011100110

  1. Shifteo a la izquierda de U1:
  
  U1a = 11001100000000000000000000000000

  2. Shifteo a la derecha de U1:
  
  U1b = 00000000000000000000110011000000

  3. Shifteo a la izquierda de U2:
  
  U2a = 10011000000000000000000000000000

  4. Shifteo a la derecha de U2:
  
  U2b = 00000000000000000000000000100110

  5. OR entre U1b y U2b:
  
  CH1 = 00000000000000000000110011100110

   La razón por la que se decidió cambiar es que muchas veces al shiftear a la izquierda 26 veces, ocurría un *"overflow"* (se solicitaba un dato mayor del que podía guardar un int), y el programa retornaba un int de la máxima capacidad (32 "1"s seguidos). El desentramado implementado que se explico anteriormente con cuenta con dicho problema. 
   
#### B.  Se colocaron dos opciones para graficar:

  En las primeras versiones del código, se graficaba utilizando la función de Processing llamada *"line"*; sin embargo, debido a que era un requerimiento y era otro tipo de visualización de la señal (que permite ver el número de puntos que se grafican por escala), se decidió agregar además la función *"point"*.

