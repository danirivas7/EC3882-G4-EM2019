/* ###################################################################
**     Filename    : main.c
**     Project     : Filtro FIR
**     Processor   : MC9S08QE128CLK
**     Version     : Driver 01.12
**     Compiler    : CodeWarrior HCS08 C Compiler
**     Date/Time   : 2019-06-15, 14:47, # CodeGen: 0
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
#include "TI1.h"
#include "AS1.h"
#include "AD1.h"
#include "Bit1.h"
#include "Bit2.h"
#include "KB1.h"
#include "TI2.h"
#include "Bit3.h"
/* Include shared modules, which are used for whole project */
#include "PE_Types.h"
#include "PE_Error.h"
#include "PE_Const.h"
#include "IO_Map.h"

/* User includes (#include below this line is not maintained by Processor Expert) */
char p=0; //varialble de flag para el muestreo de 500us
char filtro=1; //variable de inicialización del filtro


void main(void)
{
  /* Write your local variable definition here */
  signed char block1[17]; //variable para guardar las entradas
  bool dig = Bit2_GetVal(); //canal digital
  char i=0; //variable auxiliar para el filtro, para ubicarse en el vector de entradas
  char k=0; //variable auxiliar para el filtro, para ubicarse en el vector de coeficientes
  char m=0; //variable auxiliar para el filtro, para llenar el vector de entradas
  signed char coef[17] = {0, -1, 0, 6, 0, -19, 0, 78, 127, 78, 0, -19, 0, 6, 0, -1, 0}; //coeficientes del filtro
  char ch=0; //variable para guardar las entradas del canal, antes de igualarla al vector de entradas
  char ord=16; //variable que guarda el orden del filtro
  char fout[3]; //variable que guarda las salidas
  char ptr; //varaible apuntador para señalar en el SendBlock
  int resultado=0; //variable para guardar el resultado de las operaciones del filtro
  char ok; //variable que determina si se está leyendo alguna entrada
  
  /*** Processor Expert internal initialization. DON'T REMOVE THIS CODE!!! ***/
    PE_low_level_init();
  /*** End of Processor Expert internal initialization.                    ***/

    
/* Write your code here */
  /* For example: for(;;) { } */
   

   for(;;) {
	  
	  if(p){ //si la flag se encuentra activa p=1
		 p=0; //se cambia el estado de esta
		 do{ok = AD1_Measure(TRUE);} //activa el estado de medición del micro
		 while(ok != ERR_OK);
		 do{
			 ok = AD1_GetValue(&ch); //guardamos lo que estamos midiendo en la variable ch 
			 fout[0]=ch; //colocamos estos valores iniciales en el vector de salida
		 	 fout[1]=128;
		 	 fout[2]=128;}
		 while(ok != ERR_OK);
		  
		 if(!filtro){ //si el filtro no se encuentra activo
			 /* 
			  * Arreglamos los bytes de la siguiente manera:
			  * De la entrada de 8 bits, los 6 bits más significativos entran en el primer byte fout[0],
			  * que además comienza por 0 para indicar que es el primer byte de la sucesión.
			  * Los dos bits menos significativos se colocan en el segundo byte f[1], que además comienza
			  * por 1 para diferenciarlo del primero, y de ser necesario se le agrega el canal digital.
			  * El tercer byte consiste en simplemente una indicación de que no es el primer byte.
			  * Si por ejemplo, obtenemos en la entrada ch=10011010:
			  */
			 fout[0] = (ch>>2) & 63; //el primer byte quedaría como fout[0]= 00100110
			 fout[1] = (ch & 0b00000011) | 128; //el segundo byte sería fout[1]= 10000010
			 fout[2] = 0b10000000; //el tercer byte es simplemente fout[2]= 10000000
			 
			 if(!dig){
		 	 fout[0]= fout[0] | 0b0100000; //si el canal digital se encuentra activo, fout[1]= 11000010
			 }//end del if dig
		 }//end del if !filtro
		 
		 else if(filtro){ //si el filtro se encuentra activo
			 m++;
			 if(m>ord){m=0;} //si m=17, se devuelve a m=0
			 block1[m]=ch; //dado que m=0 inicialmente, se llena block1 con el valor de ch de la posición 0 a la 16
			 resultado=0; //antes de iniciar la convolución del filtro, debo retornar este valor a 0
			 for(k=0;k<=ord;k++){ //comienzo la convolución para hacer el filtro
				 /* 
				  * Para hacer el buffer circular, se necesita una variable (en este caso la variable i), que ubique
				  * de forma dinámica la posición del valor siguiente al valor más reciente del vector de entradas
				  * (en este caso la variable m). Como se puede ver en el diagrama ubicado en la wiki, se diseñaron
				  * las condiciones de la siguiente manera:
				  */
				 
				 if(m>=k){ 
					 i=m-k;
				 }
				 else{
					 i=ord+1+m-k;
				 }
				 resultado = resultado + (coef[k] * block1[i]); //realizamos la convolución
			 } //end del for
			 
			 /* 
			  * El entramado de la salida se realiza de manera similar a la anterior, pero como en este caso la 
			  * variable de salida es de 16 bits, se distribuye de la siguiente forma:
			  * fout[0] contiene los 6 bits más significativos, y un bit indicando que el filtro está activo (el 2do MSB)
			  * fout[1] contiene los siguientes 5 bits más significativos, y el canal digital 
			  * fout[2] contiene los 5 btis menos significativos
			  * Si por ejemplo en la salida del filtro resultado= 1001011100110010:
			  */
			 
			 fout[0] = ((resultado>>10)&63) | 0b01000000; //fout[0]= 01100101
			 fout[1] = ((resultado & 0b0000001111100000)>>5) | 128; //fout[1]= 10011001
			 fout[2] = (resultado & 0b0000000000011111) | 128; //fout[2]= 10010010
							
			 if(!dig){
				 fout[1]= fout[1] | 0b0100000; //se le agrega el canal digital
			 }//end del dig
		 }//end del filtro
		 
		 
		 do{
			 Bit3_NegVal();
			 ok = AS1_SendBlock(fout,3,&ptr); //se envían los bytes por el puerto serial
		 }
		 while(ok != ERR_OK);
		 
	  }//end del p=1
	} //end del for infinito



  

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
** 
*/
/*
** ###################################################################
**
**     This file was created by Processor Expert 10.3 [05.09]
**     for the Freescale HCS08 series of microcontrollers.
**
** ###################################################################
*/
