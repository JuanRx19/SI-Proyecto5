import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress pd;

Table table; // Tabla para almacenar los datos del CSV
int currentRow = 0; // Comienza en la fila 2 (índice 1 en Processing)
int bpm; // Frecuencia cardíaca en BPM
int interval; // Intervalo en milisegundos
int lastTime = 0; // Último tiempo registrado
float heartSize = 50; // Tamaño base del corazón
float heartScale = 1; // Escala para simular el "latido"
boolean isGrowing = false; // Indica si el corazón está en fase de expansión
int heartDisease; // Indica si tiene cardiopatía (1 o 2)

void setup() {
  size(400, 400);
  smooth();
  
  // Configurar OSC
  oscP5 = new OscP5(this, 12000); // Configurar el puerto local
  pd = new NetAddress("192.168.56.1", 8000); // Dirección y puerto de Pure Data
  
  // Cargar el archivo CSV
  table = loadTable("dataset_heart.csv", "header"); // Asegúrate de que el archivo esté en la carpeta 'data'

  // Verifica si la tabla se cargó correctamente
  if (table == null) {
    println("Error: no se pudo cargar el archivo dataset_heart.csv");
    exit();
  }

  // Obtener el primer valor de la columna 'max heart rate' y 'heart disease'
  bpm = int(table.getString(currentRow, "max heart rate"));
  heartDisease = int(table.getString(currentRow, "heart disease"));
  interval = 60000 / bpm; // Calcular el intervalo basado en el BPM
  println("BPM inicial: " + bpm + ", Intervalo: " + interval + " ms, Cardiopatía: " + heartDisease);
}

void draw() {
  background(255); // Fondo blanco
  
  int currentTime = millis();

  // Marca el ritmo según el intervalo calculado
  if (currentTime - lastTime >= interval) {
    sendPlaySignal(); // Enviar señal a Pure Data
    lastTime = currentTime;

    // Avanzar automáticamente a la siguiente fila
    currentRow++;
    if (currentRow < table.getRowCount()) { // Verifica si hay más filas
      bpm = int(table.getString(currentRow, "max heart rate"));
      heartDisease = int(table.getString(currentRow, "heart disease"));
      interval = 60000 / bpm; // Recalcular el intervalo
      println("Nuevo BPM: " + bpm + ", Intervalo: " + interval + " ms, Cardiopatía: " + heartDisease);
    } else {
      println("Fin del archivo. Reiniciando...");
      currentRow = 0; // Reinicia al comienzo del archivo
      bpm = int(table.getString(currentRow, "max heart rate"));
      heartDisease = int(table.getString(currentRow, "heart disease"));
      interval = 60000 / bpm;
    }

    // Iniciar el bombeo del corazón (crecimiento)
    isGrowing = true;
  }

  // Dibujar el corazón pulsante junto con la cardiopatía
  drawHeartAndIndicator();
}

void drawHeartAndIndicator() {
  translate(width / 2, height / 2); // Centrar el corazón
  noStroke();

  // Ajustar el tamaño del corazón según el bombeo
  if (isGrowing) {
    heartScale += 0.1; // Expande el corazón
    if (heartScale >= 1.5) { // Límite máximo de expansión
      isGrowing = false; // Cambia a contracción
    }
  } else {
    heartScale -= 0.05; // Contrae el corazón lentamente
    if (heartScale <= 1) { // Límite mínimo
      heartScale = 1; // Asegura que no reduzca demasiado
    }
  }

  scale(heartScale);

  // Dibujar el corazón
  fill(255, 0, 0); // Color rojo para el corazón
  beginShape();
  vertex(0, -heartSize / 2);
  bezierVertex(-heartSize, -heartSize, -heartSize, heartSize / 3, 0, heartSize);
  bezierVertex(heartSize, heartSize / 3, heartSize, -heartSize, 0, -heartSize / 2);
  endShape(CLOSE);

  // Dibujar el indicador de cardiopatía, si corresponde
  if (heartDisease == 2) {
    drawHeartDiseaseIndicator(); // Dibuja el rayo junto con el corazón
  }
}

void drawHeartDiseaseIndicator() {
  stroke(0); // Color negro
  strokeWeight(3);
  noFill();

  // El rayo se mueve y escala con el corazón
  beginShape();
  vertex(-10, -30);
  vertex(0, 0);
  vertex(10, -20);
  vertex(0, 30);
  endShape();
}

void sendPlaySignal() {
  OscMessage msg = new OscMessage("/play");
  oscP5.send(msg, pd);
  println("Señal enviada a Pure Data con BPM: " + bpm);
}
