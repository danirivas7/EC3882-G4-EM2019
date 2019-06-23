// V5 version definitva, solo queda pendiente verificar funcion que determina la frecuencia.
// EN ESTA VERSION SE SEPARA EL BIT QUE INDICA LA CONDICION DEL CANAL DIGITAL

import processing.serial.*;
import processing.sound.*;

int prueba=0;

int acum=0;
int control=0;
SqrOsc sine;                // usamos una señal cuadrada para generar el sonido que varia segun el vector freq_out
SqrOsc error;               // señal de error a emitir cuando se toque una nota errada
PImage img_normal;
PImage img_rock;
PImage img_WIN;
PImage img_FAIL;
Sound s;
Serial puerto;


int muestras=500;
boolean inicio=false;      // variable que determinar si el juego esta en pausa o no
boolean modo_rock=false;   // cuando esta en true cambia a modo rock y se activan varias cosas, cambia de imagen, sube volumen, gana mas puntos, 
int vueltas=0;             // cantidad de veces que se repetira la cancion durante una partida
int le=0;                  // desplazamiento de las letras
int i=0;                   // variable para control de tiempo
int velocidad=0;           // variable para mostrar la velocidad en la pantalla
int puntos=0;              // puntuacion para mostrar en pantalla
float frecuencia=0;        // 
int rock=0;                // puntuacion para poder activar el poder de rock
int DIG=0;                  // canal digital con valores 0 y 1, con 0 esta normal, con 1 activa el modo rock
float freq;                 //  frecuencia central teorica de a nota esperada que va a depender de la nota en cuestion y viene del vector freq_in
float bw=15;                // ancho de banda, este valor va a determinar lo precisa que sera la nota a recibir 

int tiempo=100;  //  duracion de un tiempmo
int ajuste=0;    // ajuste para afinar y bajar de tono, cada unidad baja un hz de frecuencia a todas las notas
int margen=10;    // margen de error para frecuencia
float volumen= 0.2;    // el volumen va de 0.0 a 1.0, estara siempre en 0.1 y cuando se active el pedal rock, se subira hasta 1.0

int A=440-ajuste;
int D=293-ajuste;
int FS=370-ajuste;
int G=391-ajuste;

int DFS=(D+FS)/2;

int[] cuerdas  = { 1  ,  1  ,  3  ,  0  ,  0  ,  0  ,  0  ,  0  ,  5    ,  5    ,  7  ,  0  ,  0  ,  0  ,  0  ,  0  ,  5    ,  5    ,  7  ,  0  ,  5    ,  5    ,  7  ,  0  ,  5    ,  0  ,  1  ,  1  ,  0  ,  0  ,  0  ,  0  };
int[] freq_out = { A  ,  A  ,  A  ,  0  ,  0  ,  0  ,  0  ,  0  ,  DFS  ,  DFS  ,  G  ,  0  ,  0  ,  0  ,  0  ,  0  ,  DFS  ,  DFS  ,  G  ,  0  ,  DFS  ,  DFS  ,  G  ,  0  ,  DFS  ,  0  ,  A  ,  A  ,  0  ,  0  ,  0  ,  0  };  // la frecuencia que se va a reproducir cuando se lea la frecuencia esperada en el tiempo esperado
int[] freq_int = { 82 ,  82 ,  82 ,  0  ,  0  ,  0  ,  0  ,  0  ,  110  ,  110  ,  146,  0  ,  0  ,  0  ,  0  ,  0  ,  110  ,  110  ,  146,  0  ,  110  ,  110  ,  146,  0  ,  110  ,  0  ,  82 ,  82 ,  0  ,  0  ,  0  ,  0  } ; // la frecuencia en hz que se lee de la guitarra que llega por puerto serial
int[] guitarra = new int[2000];
int muestreos=100;
int[] m = new int[muestreos];


int[] U1V = new int[muestras];
int[] U2V = new int[muestras];
int[] U3V = new int[muestras];

int U1,U2,U3;

void setup() {
   img_normal =    loadImage("normal.jpg");
   img_rock   =    loadImage("rock.jpg");
   img_WIN =    loadImage("WIN.jpg");
   img_FAIL   =    loadImage("FAIL.jpg");
   textAlign(CENTER);
   fill(#FFFFFF);
  
  printArray(Serial.list());
  puerto = new Serial(this, Serial.list()[1], 115200);  // revisar velocidad   
   
  s = new Sound(this);              // objeto sonido que usare para controlar globalmente todo el audio
  size(800, 600);
  image(img_normal,0,0);            
  sine = new SqrOsc(this);          // crear oscilador de onda cuadrada
  error = new SqrOsc(this);         // crear oscilador de onda cuadrada
  error.freq(50); 
  s.volume(volumen);
}

float f_freq()
{  
    float promedio=0;
    int q=0;
    
    // Lectura del puerto tenieneo en cuenta protocolo de comunicacion
    
    for(q=0;q<muestras;q++)
    {
    if(puerto.available()>0)
    {
    U1=puerto.read(); //debido a que la lectura del puerto guarda solo un byte, y recibiremos 4, se llama esta funcion 4 veces 
    if((U1 & 128) == 0)
    {
     U2=puerto.read(); 
     U3=puerto.read();
     
     //
     
     U1V[q]=U1 & 63;
     U2V[q]=U2 & 31;
     U3V[q]=U3 & 31 ; 
       
     guitarra[q]= ( U1V[q]<<10 ) | ( U2V[q]<<5 ) | ( U3V[q]<<5 );
     
     
    }else{q--;}
    }
    }
    
    
    
   int minimo=1000;                // valor minimo para considerarse pico de la onda, este valor se ajustara cuando se tenga el puerto serial de la guitarra.
   int maximo=50000;
   int pico=0;
   boolean x=false;
   
   
   
   for(int h=0;h<muestreos;h++)
   {
   for(q=0;q<muestras;q++)
    { 
      if(guitarra[q]>minimo && x==false && guitarra[q]<maximo)
      {
           pico++;                      // picos es la zona de la onde donde tiene mas que el valor "minimo" establecido
           x=true;
   
    }else if(guitarra[q]<=minimo && x==true)
         {
             x=false;
         }
    }
    m[h]=pico;
    pico=0;
    x=false;
   }
   int d=max(m);
   if(d>5)
   {
   prueba++;
   println("MAXIMO " + prueba + " : "+ max(m));
   }
   
   control++;
    acum+=pico;
    //if(control>20  && acum > 300)
    //{
    // println(acum);
    // acum=0;
    // control=0;
    //}
    
    float frecuencia = pico; ///(muestras*0.0005);  // se toman 1000 muestras y las muestras se toman cada 0.5 useg, la frecuencia es la cantidad de picos que se tienen dividio entre el tiempo
    return frecuencia;
}



void draw()
{
 float frecuencia=f_freq();
 //println(frecuencia);
}
