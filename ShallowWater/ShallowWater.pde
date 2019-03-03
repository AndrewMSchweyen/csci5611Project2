import peasy.*;

PeasyCam cam;
int size = 100;
int dx = 2;
float floor = 100; 
float gravity = 10;
float heightArray[] = new float[size];
float heightMidArray[] = new float[size];
float momentumArray[] = new float[size];
float momentumMidArray[] = new float[size];

//Create Window
public void settings() {
  size(800, 800, P3D);
}

void setup() {
  cam = new PeasyCam(this, 100, 0, 50, 400); //centered on sphere's x and y
  cam.setYawRotationMode();
  createWater();

}

void createWater()
{
  for(int i=0;i<size;i++)
  {
    heightArray[i] = 50;
    momentumArray[i] = 0;
  }
  //heightArray[10] = 120;
}

void update(float dt){
  for(int i=0;i<size-1;i++)
  {
    momentumArray[i]*=.9985;
    heightMidArray[i] = (heightArray[i] + heightArray[i+1])/2 - (dt/2) * (momentumArray[i]+momentumArray[i+1])/dx;
    momentumMidArray[i] = (momentumArray[i]+momentumArray[i+1])/2 - (dt/2) * (sq(momentumArray[i+1])/heightArray[i+1] + .5*gravity*sq(heightArray[i+1])
    - sq(momentumArray[i])/heightArray[i] - .5*gravity*sq(heightArray[i]))/dx;
  }
  for(int i=0;i<size-2;i++)
  {
    heightArray[i+1] -= dt*(momentumMidArray[i+1]-momentumMidArray[i])/dx;
    momentumArray[i+1] -= dt*(sq(momentumMidArray[i+1])/heightMidArray[i+1] + .5 * gravity * sq(heightMidArray[i+1]) 
     - sq(momentumMidArray[i])/heightMidArray[i] - .5*gravity * sq(heightMidArray[i]))/dx;
  }
  
  reflect();
}

void reflect()
{
  momentumArray[0] *= -1;
  momentumArray[size-1] *= -1;
}
void draw() 
{
  println(frameRate);
  background(255, 255, 255);
  update(.01);
  for(int i=0;i<size;i++)
  {
    //println("height at "+ i + " is " +heightArray[i]);
    drawQuad(-1*heightArray[i], floor, i*dx, (i*dx)+dx, -100, 200,  #1191F0, 200, true);
  }
}

void drawQuad(float top, float bottom, float left, float right, float front, float rear, int col, float opacity, boolean noStroke){
  fill(col, opacity);
  stroke(0);
  if(noStroke){
    noStroke();
  }
  beginShape(QUADS);
  vertex(left, top, rear);
  vertex(right, top, rear);
  vertex(right, bottom, rear);
  vertex(left, bottom, rear);
  
  vertex(right, top, rear);
  vertex(right, top, front);
  vertex(right, bottom, front);
  vertex(right, bottom, rear);
  
  
  vertex(right, top, front);
  vertex(left, top, front);
  vertex(left, bottom, front);
  vertex(right, bottom, front);
  
  vertex(left, top, front);
  vertex(left, top, rear);
  vertex(left, bottom, rear);
  vertex(left, bottom, front);
  
  vertex(left, top, front);
  vertex(right, top, front);
  vertex(right, top, rear);
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
    heightArray[size/2] = 110;
    heightArray[size/2 +1] = 105;
    heightArray[size/2 +2] = 102;
  }
}
