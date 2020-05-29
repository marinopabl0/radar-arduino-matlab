/* 
SKETCH PARA EL RADAR CON ARDUINO Y MATLAB
*/

#include <Servo.h> // incluimos esta libreria necesaria para los motores servo
Servo myservo;  // creamos un objeto llamado myservo
int pos = 0;    // variable para almacenar la posicion del servo, inicialmente siempre estará en laposición 0 grado
const int serv=7; // pin digital donde se debe conectar el cable blanco del servo
const int trigger=8; // pin digital donde se conecta la pata TRIGGER del sensor ultrasonico
const int echo =9; // pin digital donde se conecta la pata ECHO del sensor ultrasonico
long distancia=300; // variable para calcular la distancia
long tiempo; // variable para el tiempo
char a; // variable para ejecutar tareas segun el caracter que reciba en el puerto serie

void setup() {
  Serial.begin(9600); // inicializa la comunicacion serial
  pinMode(trigger,OUTPUT); // defino el pin TRIGGER como salida
  pinMode(echo,INPUT); // defino el pin ECHO como entrada
  myservo.attach(serv);  // conectar el servo al pin serv
}

void loop() {
  pos=0; // una vez mas siempre que se entre al loop el servo ira a la posición 0 grado
  myservo.write(pos);
  if(Serial.available()){ // si hay algo en el puerto serie
  a=Serial.read(); // lee el puerto serie
  switch (a) { // ejecutará tarea segun que sea el caracter recibido por el puerto serie
  case 'I': // si es una I se va a la función inicio
  inicio();
  break;
  }}}

void inicio() {
  // mientras no llegue una D por el puerto serie
  while (a!='D') { 
  Serial.println(pos); // envia por el puerto serie la posición actual
  Serial.println(distancia); // idem envia la distancia
  for (pos = 1; pos < 181; pos ++) { // entre 0 y 180 grados
  // en pasos de 1 grado
  digitalWrite(trigger,LOW); // Por cuestión de estabilización del sensor
  delayMicroseconds(60);
  digitalWrite(trigger, HIGH); // envío del pulso ultrasónico
  delayMicroseconds(60);
  tiempo=pulseIn(echo, HIGH); /* Función para medir la longitud del pulso entrante. Mide el tiempo que transcurrido entre el envío
  del pulso ultrasónico y cuando el sensor recibe el rebote, es decir: desde que el pin 12 empieza a recibir el rebote, HIGH, hasta que
  deja de hacerlo, LOW, la longitud del pulso entrante*/
  distancia= int(0.017*tiempo); /*fórmula para calcular la distancia obteniendo un valor entero*/
  /*Monitorización en centímetros por el monitor serial*/
  myservo.write(pos); // el servo avanza hacia la nueva posicion que es un grado mas del que estaba
  delay(15); // 15 ms para que el servo reaccione
  Serial.println(pos); // envia por puerto serie la posición actualizada del servo
  Serial.println(distancia); // envia por puerto serie la distancia hacia el sensor ultrasónico de los objetos que tenga enfrente
  a=Serial.read(); // escanea el puerto serie a ver si recibió una D
  if (a=='D') { // si recibe una D, se detiene el loop
  return;
  }
  delay(50);
  }
  delay(500);
  // ahora el servo va a hacer el giro contrario desde 180 grados hasta 0
  for (pos = 180; pos >= 0; pos --) { // goes from 0 degrees to 180 degrees
  // en pasos de 1 grado
  digitalWrite(trigger,LOW); // Por cuestión de estabilización del sensor
  delayMicroseconds(60);
  digitalWrite(trigger, HIGH); // envío del pulso ultrasónico
  delayMicroseconds(60);
  tiempo=pulseIn(echo, HIGH); /* Función para medir la longitud del pulso entrante. Mide el tiempo que transcurrido entre el envío
  del pulso ultrasónico y cuando el sensor recibe el rebote, es decir: desde que el pin 12 empieza a recibir el rebote, HIGH, hasta que
  deja de hacerlo, LOW, la longitud del pulso entrante*/
  distancia= int(0.017*tiempo); /*fórmula para calcular la distancia obteniendo un valor entero*/
  /*Monitorización en centímetros por el monitor serial*/
  myservo.write(pos);              
  delay(15);                       
  Serial.println(pos);
  Serial.println(distancia);
  a=Serial.read();
  if (a=='D') {
  return;
  }
  delay(50);
  }
  delay(500);
  }}

