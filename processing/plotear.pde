/*
Laboratorio de Proyectos 2
Proyecto I: Osciloscopio Digital

Nombres:
Manuel Hurtado, 12-10004
Daniela Rivas, 14-10914

Profesor: 
Novel Certad

*/

// Importamos esto para poder procesar lo que entra por el puerto serial

import processing.serial.*; 

// Comenzamos a declarar las variables

float Vtext=1; // Declaramos lo que imprimiremos en la pantalla auxiliar del osciloscopio
int Ttext=1;
float Vdiv=1; // Variable para el voltaje por división
int vertical=0;
int centroY=200; // Variable para ajustar la gráfica a aproximadamente el centro de la pantalla
int f=0;
float control=14.7; // Variable para ajustar la base de tiempo del osciloscipio
int j=0;
int bytes=0;
boolean listo=false;
int lecturas=0;

color rectColor, circleColor, baseColor; //declaramos los colores que usaremos
color curprentColor; 
boolean rectOver = false; //declaramos el booleano que nos diran si estamos en un boton o no
PImage img,ON;

int ONX=700;
int ONY=350;
int F1Y = 160; //estas variables son las posiciones de los colores
int F2Y = 240; //F# se refiere a la fila en la que se encuentran, son dos filas
int A1X = 640; //A# o D# se refieren al tipo y el numero de canal
int A2X = 707;
int D1X = 775;
int D2X = 842;
int T1X = 640; //T1X Se refiere al boton que disminuye la escala de tiempo, T2X al que lo aumenta
int T2X = 707; 
int V1X = 775; //es analogo para V1X y V2X
int V2X = 842;
int POWX = 842;
int POWY = 179;

int factorY=30; //ese es el factor para cambiar la escala el voltaje
int factorY2=61; //ese es el factor para cambiar la escala el voltaje

int origenY=229; //fijo el origen que emplearemos
int T=2;  // valor para division de tiempo
int V=2;  // valor para division de voltaje

int wboton = 30; //ancho del boton
int boton;
boolean A1ON=false; //booleanos para los botones de encendido de los canales
boolean A2ON=false;
boolean D1ON=false;
boolean D2ON=false;
boolean ONON=false;

boolean flag;

Serial puerto;
String portName = Serial.list()[1];  //para determinar en que puerto estamos
int U1,U2,H1,H2; // estos son desde el mas signficativo del mayor hasta el menos significativo del menor
float i=0; // solo una variable para ir imprimiendo y saber por que numero de lecutra va

int cha1, cha2, chd1, chd2; //valores de los canales
int muestras=2000;//para muestreo

int[] cha1V = new int[muestras]; //vectores para los canales
int[] cha2V = new int[muestras];
int[] chd1V = new int[muestras];
int[] chd2V = new int[muestras];

int[] cha1V2 = new int[muestras]; //vectores para los canales

int[] U1V = new int[muestras];
int[] U2V = new int[muestras];
int[] H1V = new int[muestras];
int[] H2V = new int[muestras];

float[] y = new float[muestras];
int time=1;


int principal=0; //variable de conteo

int aux=0; //variable auxiliar

String valores;
boolean comprobacion=false;

void setup()
{
  //Interfaz
  size(960, 508);
  rectColor = color(0);
  circleColor = color(255);
  baseColor = color(102);
  ellipseMode(CENTER);
  img = loadImage("osc2.png");  // imagen en png fondo transparente que va super puesta y que permite ubicar los controles del osciloscopio con facilidad
  background(0);
  
  printArray(Serial.list()); // se imprimen en consola lsos puertos conectados al pc con el numero de arreglo, lo cual permite configurar el puerto que esta conectado
  puerto = new Serial(this, portName, 115200); //establecemos que la información en nuestro puerto se guardara en la variable puerto, y cuales serian los baudios
  
  puerto.buffer(muestras);  // el buffer de datos a almacenar en el puerto serial 
 
  for(int pk=0;pk<muestras;pk++)
  {
      U1V[pk]=0;
      U2V[pk]=0;
      H1V[pk]=0;
      H2V[pk]=0; 
  }
}

void llenar()
{   //f=0;
    int q=0;
    for(q=0;q<muestras;q++)
    {
    if(puerto.available()>0)
    {
    U1=puerto.read(); //debido a que la lectura del puerto guarda solo un byte, y recibiremos 4, se llama esta funcion 4 veces 
    if((U1 & 128) == 0) // ignoramos los datos si no fuesen el inicio de la trama
    {
     U2=puerto.read(); // de ser el inicio de la trama guardamos en una variable temporal los datos leidos
     H1=puerto.read();
     H2=puerto.read();
     U1V[q]=U1;
     U2V[q]=U2;
     H1V[q]=H1;
     H2V[q]=H2;  

    }else{q--;}  // de no haberse recibido el dato inicio de la trama, se decrementa q para no dejar espacios vacios o espacios de los vectores con los datos no esperados
    }
    }
    
    

}

void arreglar()  // desenmascarar la trama
{
  
 for(int i=0;i<muestras;i++) // i recorre los vectores de los 4 canales
  {
    
    int temp1 = U1V[i] & 63;   // en esta linea se quitan los dos primeros bits del byte 1, ya que 63 es 00111111
    
    int temp2 = temp1 << 6;    // shifteamos 6 veces para hacer espacio para la segunda parte del canal
    int temp3 = U2V[i] & 63;   // quitamos los dos primeros bits del byte 2
    int temp4 = temp2 | temp3; // hacemos un OR entre los dos bytes modificados 
    int temp5 = temp4 & 4095;  // para evitar ruido, quitamos cualquier bit que sobre antes de los 12 del canal, ya que 4095 es 111111111111 
    cha1V[i]=temp5/factorY;    // este factor es para que la onda quepa en la pantalla con las escalas que escogimos
    aux=i;
    principal++;
    
    temp1 = H1V[i] & 63;  // Hacemos exactamente lo mismo con H1 y H2 para el canal analogico 2
    temp2 = temp1 << 6;
    temp3 = H2V[i] & 63; 
    temp4 = temp2 | temp3;
    temp5 = temp4 & 4095;
    
    cha2V[i] = temp5/factorY2;
 
    temp1 = U1 & 64; //para aislar el bit del canal digital, pues 64 es 01000000
    temp2 = temp1 >> 6;
  
    chd1V[i] = temp2 & 1;
    
    temp1 = U2 & 64; //lo mismo para el chd2
    temp2 = temp1 >> 6;
    
    chd2V[i] = temp2 & 1;  
  }
  // en este punto todo el vecotor esta arreglado y desentramado
}


void graficar() // plotea con puntos de los datos adquiridos con el DEMOQE
                // marca con un bool en las variables A1ON, A2ON, D1ON, D2ON solo grafica los que esten en true
{ 
 float x=0;       // esta variable es la variable de tiempo, la variable control depende de la division de timepo que se utilice
                // la variable que define la division de tiemmpo es "control" 
 for(int i=0;i<muestras*.5-1;i++)
  {
   if(A1ON)       // plotea el canal A1 si esta en ON
   {
     stroke(#30FF08);    
     strokeWeight(2);
     point(73+x,(cha1V[i]*Vdiv)+centroY+vertical-100); // dibuja un punto de grueso 2 en las cordenadas (x,y) el 73+ es para que grafique despues de el margen del osciloscopio dibujado, la variable centroY ubica el origen dentro de los margenes del osciloscpio dibujado, vertical y -100m son valores de referencia        
     //line(x,(cha1V[i]*V)+centroY+vertical,x+control,(cha1V[i+1]*V)+centroY+vertical);
   }

   if(A2ON)       // plotea el canal A1 si esta en ON
   {
     stroke(#FAFF00);    
     strokeWeight(2);
     point(73+x,(cha2V[i]*Vdiv)+centroY+vertical-50);
   }
 
   if(D1ON)       // plotea el canal A1 si esta en ON
   {
    stroke(#02D3ED);    
    strokeWeight(2);
    point(73+x,-(chd1V[i]*V*10)+275);        //line(x,(cha1V[i]*V)+250,x+control,(cha1V[i+1]*V)+250);
   }

  if(D2ON)       // plotea el canal A1 si esta en ON
   {
    stroke(#FFFAFA);    
    strokeWeight(2);
    point(73+x,-(chd2V[i]*V*10)+300);        //line(x,(cha1V[i]*V)+250,x+control,(cha1V[i+1]*V)+250);
   }
 x+=control;
 } // end for
}

void leds()  // esta funcion solo dibuja un led del color de la onda sobre cada boton como indicador para saber que esta encendido ese canal en el osciloscpio.
{
  if(A1ON)
  {
    fill(#10FF00);
    stroke(1);
    ellipse(A1X, F1Y, 10, 10);
  }
  if(A2ON==true)
  {
    fill(#FAFF00);
    stroke(0);
    ellipse(A2X, F1Y, 10, 10);
  }
  if(D1ON==true)
  {
      fill(#02D3ED);
    stroke(0);
    ellipse(D1X, F1Y, 10, 10);
  }
  if(D2ON==true)
  {
    fill(#FFFAFA);
    stroke(0);
    ellipse(D2X, F1Y, 10, 10);
  }  
}

void draw()
{
   clear();
   llenar();  
   arreglar();
   graficar();
   fill(#17DEFF);
   rect(610, 270, 258,70);   
   grid();
   image(img, 0, 0);
   leds();
   display();

   fill(#DBD9D9);
   stroke(#030000);
   strokeWeight(2);
   
   rect(700, 460, 20,20); // grafica de controles para control de offset   
   rect(730, 460, 20,20);   
   rect(760, 460, 70,20);   
   fill(#030000);
   text("VERTICAL",685,455);
   text("-",705.2,475);
   text("+",734,475);
   text("ResetV",763.5,476);
 }

void display()
{
 fill(50);
 textSize(13);
 text("Vdiv(V) =" + Vtext,745,315);
 text("Tdiv(ms) =" + Ttext,635, 315);
}

boolean overCircle(int x, int y, int diameter) {  // esta funcion determina mediante el calculo de distancia entre dos puntos si el mouse esta sobre un circulo o no
  float disX = x - mouseX;                        // si la distancia del centro del boton a la posicion del mouse es menor a el diametrod el boton retorna un verdadero
  float disY = y - mouseY;                        // de lo contrario retorna un false
  if (sqrt(sq(disX) + sq(disY)) < diameter/2 ) {
    return true;
  } else {
    return false;
  }
}

void mousePressed() {                              // este evento se dispara al presionar el click izquierdo del mouse
 
  if ( overCircle(A1X,F1Y, wboton)) {              // se envia a la funcion overcircle las coordenadas del boton en cuestion y el diametro del boton y cambia de false a true o viceversa el estado de la variable ON del canal
    if(A1ON==true)                          
    {
    A1ON=false;
    }else{A1ON =true;}

}else if(overCircle(A2X,F1Y, wboton))
  {
    if(A2ON==true)
    {
    A2ON=false;
    }else{A2ON =true;}
    
  } else if(overCircle(D1X,F1Y, wboton))
  {
    
    if(D1ON==true)
    {
    D1ON=false;
    }else{D1ON =true;}
    
  } else if(overCircle(D2X,F1Y, wboton))
  {
    
    if(D2ON==true)
    {
    D2ON=false;
    }else{D2ON =true;}
    
}else if(overCircle(T1X,F2Y, wboton))
{
  time--;
}
else if(overCircle(T2X,F2Y, wboton))
  {
    time++;
   }else if(overCircle(V1X,F2Y, wboton))
  {
    V--;  
}else if(overCircle(V2X,F2Y, wboton))
  {V++;}
  else if(overCircle(705,475,wboton))
    {
      vertical+=2;
      if(vertical>200)
      {
       vertical=200;
      }
    }else if(overCircle(734,475,wboton))
     {
      vertical-=2;
      if(vertical<-200)
      {
       vertical=-200;
      }
     }else if(overCircle(790,476,wboton*2))
     {
      vertical=0;
     }
     
 
 if(V>3)
 {V=1;}else if(V<1){V=3;}
  
 if(time>3)
 {
  time=1;
 }else if(time<1)
 {
   time=3;
 }
 
 switch(V)
 {
  case 1:
  Vtext=0.3;
  Vdiv=6.7;
  break;

  case 2:
  Vtext=1;
  Vdiv=2;
  break;

  case 3:
  Vtext=3;
  Vdiv=0.6;
  break;
}
 
 switch(time) // los valores de control que van aqui deben cambiarse para que se vea la onda en las frecuencias solicitadas, la variable time cambia de 1 a 3 univamente
 {
   case 1:
   control=23;
   Ttext=1;        // escribe la division de tiempo correspondiente en el display
   break;
   
   case 2:
   control=2.3;
   Ttext=10;
   break;
   
   case 3:
   control=0.24;
   Ttext=100;
   break;
 } 
}

  
void grid()  // dibuja el grid 
{
  int div = 11;         // cantidad de divisiones
  int origengridx=68;   // desde aqui empieza el grid
  stroke(0);
  
  if(A1ON | A2ON | D1ON | D2ON){  // solo dibuja el grid cuando este encendidoi el osciloscopio
    fill(#89FCFF);
  } else{
    fill(0);
  }
  
  stroke(127, 34, 255);
  
  strokeWeight(0.8);  // grosor de la linea del grid
  for(int k=0;k<div;k++){
    line(origengridx, 10, origengridx, 600); // lineas verticales
    line(70, origengridx-10, 600, origengridx-10); // lineas horizontales
    origengridx+=46;
  }
  }
