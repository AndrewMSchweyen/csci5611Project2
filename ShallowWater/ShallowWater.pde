import peasy.*;

PeasyCam cam;
int waterLength = 100;
int waterWidth;
int dx = 20;
float startHeight = 100;
float floor = 0; 
float gravity = 10;
float damp = 1;
float front = -100;
float rear = 100;
float dt = .01;
float updateRate = 6;
float heightArray[] = new float[waterLength];
float heightMidArray[] = new float[waterLength];
float momentumArray[] = new float[waterLength];
float momentumMidArray[] = new float[waterLength];

//Create Window
public void settings() {
  size(800, 800, P3D);
}

void setup() {
  cam = new PeasyCam(this, (waterLength/2) * dx, -startHeight, 0, 800); //centered around water
  cam.setYawRotationMode();
  createWater();
}

void createWater()
{
  for(int i=0;i<waterLength;i++)
  {
    heightArray[i] = startHeight;
    momentumArray[i] = 0;
  }
}

void update(float dt){
  for(int i=0;i<waterLength-1;i++)
  {
    heightMidArray[i] = (heightArray[i] + heightArray[i+1])/2 - (dt/2) * (momentumArray[i]+momentumArray[i+1])/dx;
    momentumMidArray[i] = (momentumArray[i]+momentumArray[i+1])/2 - (dt/2) * (sq(momentumArray[i+1])/heightArray[i+1] + .5*gravity*sq(heightArray[i+1])
    - sq(momentumArray[i])/heightArray[i] - .5*gravity*sq(heightArray[i]))/dx;
  }
  for(int i=0;i<waterLength-2;i++)
  {
    heightArray[i+1] -= dt*(momentumMidArray[i+1]-momentumMidArray[i])/dx;
    momentumArray[i+1] -= dt*(damp * momentumArray[i+1] + sq(momentumMidArray[i+1])/heightMidArray[i+1] + .5*gravity*sq(heightMidArray[i+1]) 
     - sq(momentumMidArray[i])/heightMidArray[i] - .5*gravity*sq(heightMidArray[i]))/dx;
  }
  
  reflectWater();
}

void reflectWater()
{
  heightArray[0] = heightArray[1];
  heightArray[waterLength-1] = heightArray[waterLength-2];
  momentumArray[0] = -momentumArray[1];
  momentumArray[waterLength-1] = -momentumArray[waterLength-2];
}

void draw() 
{
  println(frameRate);
  background(255, 255, 255);
  for (int i = 0; i< updateRate; i++)
  {
    update(dt);
  }
  for(int i=0;i<waterLength-1; i++)
  {
    println("height at "+ i + " is " +heightArray[i]);
    drawQuad(-1*heightArray[i], floor, i*dx, (i+1)*dx, front, rear,heightArray[i+1]*-1,  #1191F0, 255, true);
  }
}

void drawQuad(float top, float bottom, float left, float right, float front, float rear,float nextHeight, int col, float opacity, boolean noStroke){
  fill(col, opacity);
  stroke(0);
  if(noStroke){
    noStroke();
  }
  beginShape(QUADS);
  vertex(left, top, rear);
  vertex(right, nextHeight, rear);
  vertex(right, bottom, rear);
  vertex(left, bottom, rear);
  
  vertex(right, nextHeight, rear);
  vertex(right, nextHeight, front);
  vertex(right, bottom, front);
  vertex(right, bottom, rear);
  
  
  vertex(right, nextHeight, front);
  vertex(left, top, front);
  vertex(left, bottom, front);
  vertex(right, bottom, front);
  
  vertex(left, top, front);
  vertex(left, top, rear);
  vertex(left, bottom, rear);
  vertex(left, bottom, front);
  
  vertex(left, top, front);
  vertex(right, nextHeight, front);
  vertex(right, nextHeight, rear);
  vertex(left, top, rear);
  
  vertex(left, bottom, front);
  vertex(right, bottom, front);
  vertex(right, bottom, rear);
  vertex(left, bottom, rear);
  endShape();
}

void keyPressed() 
{
  if (keyCode == DOWN) {
    heightArray[waterLength/2] = 500;
    heightArray[waterLength/2+1] = 450;
    heightArray[waterLength/2-1] = 450;
  }
 if (keyCode == UP) {
    heightArray[1] = 800;
    heightArray[2] = 600;
  }
  if (key == 'r') 
  {
    createWater();
  }
}
