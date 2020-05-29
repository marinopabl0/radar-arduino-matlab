function radar_1(~,~,~)
global s % declara como global la variable del puerto COM 
delete(instrfind({'Port'},{'COM4'})); % puerto COM donde está conectada la placa Arduino
s = serial('COM4','BaudRate',9600,'Terminator','CR/LF','Timeout',2); % define la variable s como el puerto y dejo para editar algunas de sus propiedades
fopen(s); %  abre el puerto
p=get(0,'ScreenSize'); % obtiene las dimensiones en pixeles de la pantalla
figure('Units','Pixels','Position',p,'Name','Radar con Arduino y MATLAB','Menubar','none','color',[0.7 0.7 0.7]); % abre la interfaz de usuario en pantalla completa
uicontrol('style','text','string','RADAR CON ARDUINO Y MATLAB','fontweight','bold','fontsize',16,'horizontalalignment','right','foregroundcolor',[0 0 0],'backgroundcolor',[0.7 0.7 0.7],'position',[100,750,400,50]); % texto como titulo
uicontrol('style','text','string','Escribir la distancia al radar','fontweight','bold','fontsize',12,'horizontalalignment','right','foregroundcolor',[0 0 0],'backgroundcolor',[0.7 0.7 0.7],'position',[90,680,300,50]); % texto indicativo de que hacer 
uicontrol('Style', 'edit',       'string', '',        'fontweight','bold','fontsize',11,'BackgroundColor',[1 1 1],      'position', [400,700,100,40],'Callback',@radio) % caja de texto para poner la distancia al radar
uicontrol('Style', 'pushbutton', 'string', 'Comenzar','fontweight','bold','fontsize',11,'BackgroundColor',[0.6 0.6 0.6],'position', [400,650,100,40],'Callback',@comenzar) % boton para comenzar el escaneo del radar
uicontrol('Style', 'pushbutton', 'string', 'Terminar','fontweight','bold','fontsize',11,'BackgroundColor',[0.6 0.6 0.6],'position', [400,600,100,40],'Callback',@terminar) % boton para detener el escaneo del radar
uicontrol('Style', 'pushbutton', 'string', 'Salir',   'fontweight','bold','fontsize',11,'BackgroundColor',[0.6 0.6 0.6],'position', [400,550,100,40],'Callback',@salir) % boton para salir del programa
end 

% esta funcion auxiliar es para obtener el numero puesto en la caja de
% texto que se corresponde con la distancia al radar
function radio(hObj,~,~)
global r
a=get(hObj,'String'); % es un string
r=str2double(a); % lo convierte a numero
end

function comenzar(~,~,~)
global r s run
axes('Units','Pixels','Position',[600 400 800 400]); % dibuja una grafica
set(gca,'Color',[0 0 0]); % setea el color de fondo
axis on % deja visibles los ejes de la grafica
hold on % la mantiene siempre en pantalla
a=-r:0.01:r; % vector que divide la grafica en un semicirculo con muchas divisiones
b=sqrt(r^2-a.^2); % vector que se obtiene a partir del anterior mediante la ecuacion de una circunferencia de centro el origen (0,0) y radio el valor digitado por el usurio
plot(a,b,'-b','linewidth',2),xlim([-r-5 r+5]), ylim([-5 r+5]), ylabel('Distancia al radar','fontsize',12), title('RADAR CON ARDUINO Y MATLAB','fontsize',16); % grafica el semicirculo del radar
fprintf(s,'I'); % envia el caracter I por el puerto serie para que el Arduino inicie su loop
pause(0.5); % una pausa 
p=50; % angulo de abertura total del radar, esto se puede editar por otro valor
h=1; % grosor de las lineas del radar
run=1; % se debe hacer igual a 1 esta variable para que arranque el grafico en tiempo real
k=1; % un contador que empieza en 1
while(run) % mientras run valga 1 se ejecuta lo que sigue
e=fscanf(s); % escanea el puerto serie
o=str2double(e); % convierte a numero lo que leyó en el puerto serie
R1=fscanf(s); % vuelve a escanear el puerto serie
R=str2double(R1); % convierte a numero lo que leyó en el puerto serie
if R>r % si la distancia medida por el radar supera al valor prefijado de r
R=r; % R pasa a valer r
end
t=2*pi*(o)/360; % convierte el angulo del servo de grados a radianes
[x,y]=pol2cart(t,R); % convierte a cartesianas las coordenadas polares t y R
[z,w]=pol2cart(t,r); % idem pero con t y r
c(k)=plot([0 x],[0 y],'-g','linewidth',h); % grafica una linea desde el (0,0) hasta r de color verde
d(k)=plot([x z],[y w],'-r','linewidth',h); % si detecta algo por el sensor ultrasonico, lo dibuja en rojo sobre la linea anterior
drawnow % actualiza la grafica
if k>p % si el k es mayor que el angulo de apertura...va borrando las lineas anteriores para dar el efecto del radar girando; va borrando lineas anteriores
delete(c(k-p));
delete(d(k-p));
end
k=k+1; % se va incrementando el valor de k
end
end

function terminar(~,~,~)
global run s 
fprintf(s,'D'); % envia por el puerto serie el caracter D que detiene el loop de arduino
run=0; % la variable run pasa a valer 0 y se detiene tambien el loop de MATLAB
end

function salir(~,~,~)
global run s
run=0; % detiene el loop de MATLAB haciendo que run valga 0
fclose(s); % cierra el puerto
clear global % elimina las variables globales
close all % cierra la pantalla
end