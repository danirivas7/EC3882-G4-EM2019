/* ###################################################################
**     Filename    : main.c
**     Project     : oscilocopio
**     Processor   : MC9S08QE128CLK
**     Version     : Driver 01.12
**     Compiler    : CodeWarrior HCS08 C Compiler
**     Date/Time   : 2019-02-25, 10:53, # CodeGen: 0
**     Abstract    :
**         Main module.
**         This module contains user's application code.
**     Settings    :
**     Contents    :
**         No public methods
**
** ###################################################################*/
/*!
** @file main.c
** @version 01.12
** @brief
**         Main module.
**         This module contains user's application code.
*/         
/*!
**  @addtogroup main_module main module documentation
**  @{
*/         
/* MODULE main */


/* Including needed modules to compile this module/procedure */
#include "Cpu.h"
#include "Events.h"
#include "AD1.h"
#include "AS1.h"
#include "TI1.h"
#include "Bit1.h"
#include "Bit2.h"
#include "Bit3.h"
#include "TI2.h"
#include "Bit4.h"
/* Include shared modules, which are used for whole project */
#include "PE_Types.h"
#include "PE_Error.h"
#include "PE_Const.h"
#include "IO_Map.h"

/* User includes (#include below this line is not maintained by Processor Expert) */

char p=0;
char h=0;
char k=0;

// Función para acomodar los datos según el protocolo

void mask1(char maskblock[4],char block1[],char block2[],char dig,char dig2)
{
	   /* Las variables son:
	    * maskblock hace referencia a los 4 bytes completos que envía el demoQE, sería la trama según el protocolo
	    * block1 cuenta con 2 bytes del canal 1
	    * block2 son los 2 bytes del canal 2
	    */
	
		/* Ejemplo del funcionamiento:
		 * Si antes de programar el demoQE, obtenemos por ejemplo una señal en la cual el máximo valor es:
		 * block1[0] = 00001111
		 * block1[1] = 11111111
		 * 
		 * El protocolo se ajusta para que este resulte de la siguiente manera:
		 * block1[0] = 00111111
		 * block1[1] = 10111111
		 * 
		 * Donde el segundo bit más significativo de cada uno corresponde a un canal digital.
		 */
	
		maskblock[0]= block1[0] << 2; // Siguiendo el ejemplo anterior, maskblock[0] = 00111100
		maskblock[1]= block1[1] >> 6; // Ahora, maskblock[1] = 00000011
		
		maskblock[0]= maskblock[0] | maskblock[1]; // Ahora maskblock[0] = 00111111
		maskblock[0]= maskblock[0] & 0b01111111; // En caso de ruido en el MSB, se asegura que la flag sea 0 en el primer byte
		maskblock[1]= block1[1] | 0b10000000; // Para el segundo byte, se coloca la flag 1 
		
		
		// Repetimos el procedimiento anterior para el canal analógico 2, con la excepción de que ambos bytes comienzan con 0
		
		maskblock[2]= block2[0] << 2;
		maskblock[3]= block2[1] >> 6;
	
		maskblock[2]= maskblock[2] | maskblock[3];
		maskblock[2]= maskblock[2] | 0b10000000;
		maskblock[3]= block2[1] | 0b10000000;	

		// A continuación, se le indica al programa qué hacer con los canales digitales (colocar el 2do MSB en 1 o 0)
			
		if(!dig) {
				maskblock[0]=maskblock[0]| 0b01000000; // No se presiona el pulsador PTD2
			}
		else{ 
				maskblock[0]=maskblock[0]& 0b10111111; // Se presiona el pulsador PTD2
			}

		if(!dig2){
				maskblock[1]=maskblock[1]| 0b01000000; // No se presiona el pulsador PTD3
			}
		else{
				maskblock[1]=maskblock[1]& 0b10111111; // Se presiona el pulsador PTD3
			}
}

void main(void)
{
  /* Write your local variable definition here */
char block1[2],block2[2],maskblock[4]; // Variables descritas anteriormente
unsigned int ptr; // Apuntador que se requiere para la función de enviar los bloques
char dig,dig2; // Canales digitales

  /*** Processor Expert internal initialization. DON'T REMOVE THIS CODE!!! ***/
  PE_low_level_init();
  /*** End of Processor Expert internal initialization.                    ***/

  /* Write your code here */
  /* For example: for(;;) { } */
 
   for(;;) {
	   
	  if(p) {
	   Bit4_NegVal();  // PTD4 PIN 30, utilizado pra grafica una onda cuadrada de 1kHz que representa la frecuencia de muestreo
	   p=0; // Cada vez que se activa la interrupción el valor de p cambia a 1, esta parte es para devolverlo a 0
	   AD1_MeasureChan(TRUE,0); // Lee lo que se encuentra en el canal 1
	   AD1_GetChanValue(0, &block1); // Se asigna lo que se leyó a la variable block1
	   AD1_MeasureChan(TRUE,1); // Lee lo que se encuentra en el canal 2
	   AD1_GetChanValue(1, &block2); // Se asigna lo que se leyó a la variable block2
	   dig=Bit1_GetVal(); // Asignamos el valor de un bit a la variable del canal digital 1
	   dig2=Bit2_GetVal(); // Asignamos el valor de un bit a la variable del canal digital 2
	   mask1(maskblock,block1,block2,dig,dig2);	// Llamamos al procedimiento mask1	
       AS1_SendBlock(maskblock,4,&ptr); // Devolvemos el valor de maskblock (la trama)
      }
  }
  /*** Don't write any code pass this line, or it will be deleted during code generation. ***/
  /*** RTOS startup code. Macro PEX_RTOS_START is defined by the RTOS component. DON'T MODIFY THIS CODE!!! ***/
  #ifdef PEX_RTOS_START
    PEX_RTOS_START();                  /* Startup of the selected RTOS. Macro is defined by the RTOS component. */
  #endif
  /*** End of RTOS startup code.  ***/
  /*** Processor Expert end of main routine. DON'T MODIFY THIS CODE!!! ***/
  for(;;){}
  /*** Processor Expert end of main routine. DON'T WRITE CODE BELOW!!! ***/
} /*** End of main routine. DO NOT MODIFY THIS TEXT!!! ***/

/* END main */
/*!
** @}
*/
/*
** ###################################################################
**
**     This file was created by Processor Expert 10.3 [05.09]
**     for the Freescale HCS08 series of microcontrollers.
**
** ###################################################################
*/
