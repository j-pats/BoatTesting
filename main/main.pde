// vertex constants
int VERTEX_SPACE = 20;
int NUM_VERTEX_W = 50;
int NUM_VERTEX_H = 40;
float BOAT_HEIGHT_RATE = 1;
int GRID_OFFSET = (VERTEX_SPACE * NUM_VERTEX_W) / 2;
float OFFSET = 10.0;

// noise attributes
float noiseScale = 0.004;
float scaleFactor = 85;
float zOffset = 0.0;


Vertex shipPos;
Vertex delayAnchor;
Vertex leftAnchor;
Vertex rightAnchor;

PShape boat;

Vertex[][] verts;

void setup() {
  size(1200, 800, P3D);
  fill(204);
  // now create the vertex array
  createVertices();
  
  boat = loadShape("boat.obj");
  boat.scale(5);
  boat.translate(10,-5);
  boat.rotateX(PI);
  shipPos = new Vertex(GRID_OFFSET, 0.0, (NUM_VERTEX_H * VERTEX_SPACE) - (8 * VERTEX_SPACE));
  delayAnchor = new Vertex(GRID_OFFSET, 0.0, (NUM_VERTEX_H * VERTEX_SPACE) - (9 * VERTEX_SPACE));
  leftAnchor = new Vertex(shipPos.getX() - OFFSET, 0.0, shipPos.getZ());
  rightAnchor = new Vertex(shipPos.getX() + OFFSET, 0.0, shipPos.getZ());
}

void draw() {
  lights();
  background(0);
  
  // set camera position
  camera(GRID_OFFSET + 50 + (mouseX - width/2), -mouseY + 100, (NUM_VERTEX_H * VERTEX_SPACE), // eyeX, eyeY, eyeZ
         GRID_OFFSET, 0.0, (NUM_VERTEX_H * VERTEX_SPACE) - (8 * VERTEX_SPACE), // centerX, centerY, centerZ
         0.0, 1.0, 0.0); // upX, upY, upZ
         
  // draw the ship's location
  noStroke();
  drawShip();
  
  // draw sphere at ship delay and ship position
  pushMatrix();
  translate(shipPos.getX(), shipPos.getY(), shipPos.getZ());
  stroke(255,255,255);
  sphere(3);
  popMatrix();
  pushMatrix();
  translate(delayAnchor.getX(), delayAnchor.getY(), delayAnchor.getZ());
  stroke(255,255,255);
  sphere(3);
  popMatrix();
  pushMatrix();
  translate(leftAnchor.getX(), leftAnchor.getY(), leftAnchor.getZ());
  stroke(255,0,0);
  sphere(3);
  popMatrix();
  pushMatrix();
  translate(rightAnchor.getX(), rightAnchor.getY(), rightAnchor.getZ());
  stroke(0,255,0);
  sphere(3);
  popMatrix();
  
  stroke(0,0,255);
  
  for (int i = 0; i < NUM_VERTEX_W; i++) {
    for (int j = 0; j < NUM_VERTEX_H; j++) {
      // creates 20x20 points
      //verts[i][j].drawVertex();
      if (i < NUM_VERTEX_W - 1 && j < NUM_VERTEX_H - 1) {
        line(verts[i][j].getX(), verts[i][j].getY(), verts[i][j].getZ(), verts[i+1][j+1].getX(), verts[i+1][j+1].getY(), verts[i+1][j+1].getZ());
      }
      
      if (i < NUM_VERTEX_W - 1) {
        line(verts[i][j].getX(), verts[i][j].getY(), verts[i][j].getZ(), verts[i+1][j].getX(), verts[i+1][j].getY(), verts[i+1][j].getZ());
      }
      
      if (j < NUM_VERTEX_H - 1) {
        line(verts[i][j].getX(), verts[i][j].getY(), verts[i][j].getZ(), verts[i][j+1].getX(), verts[i][j+1].getY(), verts[i][j+1].getZ());
      }
    }
  }
  
  // adnance the noise offset
  zOffset = zOffset - 0.005;
  
  updateVertices();
}

float getNoiseY(float x, float z) {
  return noise(x*noiseScale, z*noiseScale + zOffset, 0.0) * scaleFactor;
}

float distance(float x1, float y1, float z1, float x2, float y2, float z2) {
        float deltaX = x2 - x1;
        float deltaY = y2 - y1;
        float deltaZ = z2 - z1;
        return (float)Math.sqrt(deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ);
    }

void drawShip() {
  pushMatrix();
  // get angle between left and right to roll boat
  float rollAngle = sin(distance(leftAnchor.getX(), leftAnchor.getY(), leftAnchor.getZ(), leftAnchor.getX(), rightAnchor.getY(), leftAnchor.getZ()) / distance(leftAnchor.getX(), leftAnchor.getY(), leftAnchor.getZ(), rightAnchor.getX(), rightAnchor.getY(), rightAnchor.getZ()));
  // Get angle between ship delay point and ship position
  float sinAngle = sin(distance(shipPos.getX(), shipPos.getY(), shipPos.getZ(), shipPos.getX(), delayAnchor.getY(), shipPos.getZ()) / distance(shipPos.getX(), shipPos.getY(), shipPos.getZ(), delayAnchor.getX(), delayAnchor.getY(), delayAnchor.getZ()));
  if (shipPos.getY() > delayAnchor.getY()) {
    sinAngle = sinAngle * -1;
  }
  if (leftAnchor.getY() > rightAnchor.getY()) {
    rollAngle = rollAngle * -1;
  }
  //println(sinAngle);
  translate(shipPos.getX(), shipPos.getY(), shipPos.getZ());
  rotateZ(rollAngle * 3);
  rotateX(sinAngle);
  rotateY(rollAngle);
  shape(boat);
  popMatrix();
}

  void updateVertices() {
  // creates the array of vertices
  for (int i = 0; i < NUM_VERTEX_W; i++) {
    for (int j = 0; j < NUM_VERTEX_H; j++) {
      // creates all points
      float x = (i * VERTEX_SPACE);
      float z = (j * VERTEX_SPACE);
      float noiseVal = getNoiseY(x, z);
      verts[i][j].setY(noiseVal);
    }
  }
  //update sphere positions - with delay for the ship
  // if difference is less than max difference allowed, just change, otherwise use max change value
  float diffY = getNoiseY(shipPos.getX(), shipPos.getZ()) - shipPos.getY();
  diffY = constrain(diffY, -BOAT_HEIGHT_RATE, BOAT_HEIGHT_RATE);
  shipPos.setY(shipPos.getY() + diffY);
  
  diffY = getNoiseY(delayAnchor.getX(), delayAnchor.getZ()) - delayAnchor.getY();
  diffY = constrain(diffY, -BOAT_HEIGHT_RATE, BOAT_HEIGHT_RATE);
  delayAnchor.setY(delayAnchor.getY() + diffY);
  
  diffY = getNoiseY(leftAnchor.getX(), leftAnchor.getZ()) - leftAnchor.getY();
  diffY = constrain(diffY, -BOAT_HEIGHT_RATE, BOAT_HEIGHT_RATE);
  leftAnchor.setY(leftAnchor.getY() + diffY);
  
  diffY = getNoiseY(rightAnchor.getX(), rightAnchor.getZ()) - rightAnchor.getY();
  diffY = constrain(diffY, -BOAT_HEIGHT_RATE, BOAT_HEIGHT_RATE);
  rightAnchor.setY(rightAnchor.getY() + diffY);
}

void createVertices() {
  verts = new Vertex[NUM_VERTEX_W][NUM_VERTEX_H];
  // creates the array of vertices
  for (int i = 0; i < NUM_VERTEX_W; i++) {
    for (int j = 0; j < NUM_VERTEX_H; j++) {
      // creates 20x20 points
      float x = (i * VERTEX_SPACE);
      float z = (j * VERTEX_SPACE);
      float noiseVal = getNoiseY(x, z);;
      verts[i][j] = new Vertex(x, noiseVal, z);
    }
  }
}
