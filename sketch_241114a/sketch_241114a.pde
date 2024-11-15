import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress pd;

Table table; 
int currentRow = 0; 
int bpm; 
int interval; // Intervalo en milisegundos
int lastTime = 0; // Último tiempo registrado
float heartSize = 50;
float heartScale = 1; 
boolean isGrowing = false; 
int heartDisease; 

void setup() {
  size(400, 400);
  smooth();
  
  oscP5 = new OscP5(this, 12000); 
  pd = new NetAddress("192.168.56.1", 8000); // Dirección y puerto de Pure Data
  
  table = loadTable("dataset_heart.csv", "header"); 

  if (table == null) {
    println("Error: no se pudo cargar el archivo dataset_heart.csv");
    exit();
  }

  // Inicialización de bpm y heartDisease
  bpm = int(table.getString(currentRow, "max heart rate"));
  heartDisease = int(table.getString(currentRow, "heart disease"));
  interval = 60000 / bpm; // Calcular el intervalo basado en el BPM
  println("BPM inicial: " + bpm + ", Intervalo: " + interval + " ms, Cardiopatía: " + heartDisease);
}

void draw() {
  background(255);
  
  int currentTime = millis();
  
  if (currentTime - lastTime >= interval) {
    sendPlaySignal(); // Enviar señal a Pure Data
    lastTime = currentTime;

    // Avance a la siguiente fila
    currentRow++;
    if (currentRow < table.getRowCount()) { 
      bpm = int(table.getString(currentRow, "max heart rate"));
      heartDisease = int(table.getString(currentRow, "heart disease"));
      interval = 60000 / bpm; 
      println("Nuevo BPM: " + bpm + ", Intervalo: " + interval + " ms, Cardiopatía: " + heartDisease);
    } else {
      println("Fin del archivo. Reiniciando...");
      currentRow = 0; 
      bpm = int(table.getString(currentRow, "max heart rate"));
      heartDisease = int(table.getString(currentRow, "heart disease"));
      interval = 60000 / bpm;
    }
    isGrowing = true;
  }
  drawHeartAndIndicator();
}

void drawHeartAndIndicator() {
  translate(width / 2, height / 2); 
  noStroke();

  if (isGrowing) {
    heartScale += 0.1; 
    if (heartScale >= 1.5) { 
      isGrowing = false; 
    }
  } else {
    heartScale -= 0.05; 
    if (heartScale <= 1) { 
      heartScale = 1; 
    }
  }

  scale(heartScale);

  // Dibujar el corazón
  fill(255, 0, 0); 
  beginShape();
  vertex(0, -heartSize / 2);
  bezierVertex(-heartSize, -heartSize, -heartSize, heartSize / 3, 0, heartSize);
  bezierVertex(heartSize, heartSize / 3, heartSize, -heartSize, 0, -heartSize / 2);
  endShape(CLOSE);

  if (heartDisease == 2) {
    drawHeartDiseaseIndicator();
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
