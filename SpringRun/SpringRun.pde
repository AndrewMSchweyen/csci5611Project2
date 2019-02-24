import peasy.*;

PeasyCam cam;
PImage cloth;
int numBalls = 10;
int threads = 30;
final float dt = .01;
float floor = 400;
float gravity = 78;
float restLen = 1;
float mass = .8; 
float k = 1000; 
float kv = 100;
float bounce = -.1;
float keyForce = 1000;
float keyHold = 100;
PVector[][] newVelocity = new PVector[threads][numBalls];
Spring[][] springArray = new Spring[threads][numBalls];


//Create Window
public void settings() {
  size(800, 800, P3D);
}

void setup() {
  cam = new PeasyCam(this, 300, 250, 100, 250);
  cam.setYawRotationMode();
  cloth = loadImage("cloth.png");
  for(int i=0; i < threads; i++)
  {
    for(int j =0; j<numBalls; j++)
    {
      springArray[i][j] =  new Spring(new PVector(200+ 5*i,200+j,10*j), new PVector(0,0,0));
    }
  }
}

void update(float dt)
{
  copyVelocity(); //copy current velocity array to newVelocity array
  //Horizontal Spring Calculations
  for(int i=0; i < threads-1; i++)
  {
    for(int j =0; j<numBalls; j++)
    {
      PVector energy = new PVector(0,0,0);
      float v1 ,v2 =0;
      float force =0;
      float length = 0;  
      PVector.sub(springArray[i+1][j].position, springArray[i][j].position, energy);
      length = sqrt(energy.dot(energy));
      energy.normalize();
      v1 = energy.dot(springArray[i][j].velocity);
      v2 = energy.dot(springArray[i+1][j].velocity);
      force = -k*(restLen - length) - kv*(v1 - v2);
      energy.y /= mass;
      newVelocity[i][j].add(PVector.mult(energy,force).mult(dt));
      newVelocity[i+1][j].sub(PVector.mult(energy,force).mult(dt));    
    }
  }
  
  //Vertical Spring Calculations
  for(int i=0; i < threads; i++)
  {
    for(int j =0; j<numBalls -1 ; j++)
    {
      PVector energy = new PVector(0,0,0);
      float v1 ,v2 =0;
      float force =0;
      float length = 0;   
      PVector.sub(springArray[i][j+1].position, springArray[i][j].position, energy);
      length = sqrt(energy.dot(energy));
      energy.normalize();
      v1 = energy.dot(springArray[i][j].velocity);
      v2 = energy.dot(springArray[i][j+1].velocity);
      force = -k*(restLen - length) - kv*(v1 - v2);
      energy.y /= mass;
      newVelocity[i][j].add(PVector.mult(energy,force).mult(dt));
      newVelocity[i][j+1].sub(PVector.mult(energy,force).mult(dt));  
    }
  }
  
  for(int i=0; i < threads; i++) 
  {
    for(int j =0; j<numBalls; j++)
    {
      newVelocity[i][j].add(new PVector(0,gravity,0)); //gravity force
    }
    //if(i%5==0) 
    newVelocity[i][0].mult(0); //fixed top string
  }
  
  for(int i=0; i < threads; i++) //update position
  {
    for(int j =0; j<numBalls; j++)
    {
      springArray[i][j].position.add(newVelocity[i][j].mult(dt));
    }
  }
  
  //Collision Detection
  for(int i=0; i < threads; i++)
  {
    for(int j =0; j<numBalls; j++)
    {
      if(springArray[i][j].position.y >floor)
      {
        springArray[i][j].velocity.y *= bounce; 
        springArray[i][j].position.y = floor;
      }
    }
  }
  
  updateVelocity(); //copy newVelocity array to current velocity array (for next dt)
}

void draw() 
{
  println(frameRate);
  background(255,255,255);
  update(dt); 
  drawCloth();  
}

void drawCloth()
{
  //for(int i=0; i < threads; i++)
  //{
  //  for(int j=0; j < numBalls; j++)
  //  {
  //    strokeWeight(1);
  //    if(j-1>=0)
  //    {
  //      line(springArray[i][j-1].position.x,springArray[i][j-1].position.y,springArray[i][j-1].position.z,springArray[i][j].position.x,springArray[i][j].position.y,springArray[i][j].position.z);
  //    }
  //    if(i-1>=0)
  //    {
  //      line(springArray[i-1][j].position.x,springArray[i-1][j].position.y,springArray[i-1][j].position.z,springArray[i][j].position.x,springArray[i][j].position.y,springArray[i][j].position.z);
  //    }
  //    strokeWeight(5);
  //    point(springArray[i][j].position.x,springArray[i][j].position.y,springArray[i][j].position.z);
        
  //  }
  //}
  
  //strokeWeight(1);
  //fill(153);
  noStroke();
  textureWrap(REPEAT);
  textureMode(NORMAL);
  for(int i=0; i < threads-1; i++)
  {
    beginShape(TRIANGLE_STRIP);
    texture(cloth);
    for(int j=0; j < numBalls; j++)
    {
      float u = map(j, 0, threads-1, 0, 1);
      float v = map(i, 0, numBalls-1, 0, 1);
      vertex(springArray[i][j].position.x,springArray[i][j].position.y,springArray[i][j].position.z, u, v);
      v = map(i+1, 0, numBalls-1, 0, 1);
      vertex(springArray[i+1][j].position.x,springArray[i+1][j].position.y,springArray[i+1][j].position.z, u, v);
    }
    endShape();
  }
}

void copyVelocity()
{
  for(int i=0; i < threads; i++)
  {
    for(int j =0; j<numBalls; j++)
    {
      newVelocity[i][j] = springArray[i][j].velocity.copy();
    }
  }
}

void updateVelocity()
{
  for(int i=0; i < threads; i++)
  {
    for(int j =0; j<numBalls; j++)
    {
      springArray[i][j].velocity = newVelocity[i][j].copy();
    }
  }
}

void keyPressed() 
{
    if (key == 'd') 
    {
      springArray[threads/2][numBalls/2].velocity.x += keyForce;
      springArray[threads/2][numBalls/2+1].velocity.x += keyForce/2;
      springArray[threads/2][numBalls/2+2].velocity.x += keyForce/4;
      springArray[threads/2][numBalls/2-1].velocity.x += keyForce/2;
      springArray[threads/2][numBalls/2-2].velocity.x += keyForce/4;
      springArray[threads/2+1][numBalls/2].velocity.x += keyForce/2;
      springArray[threads/2+2][numBalls/2].velocity.x += keyForce/4;
      springArray[threads/2-1][numBalls/2].velocity.x += keyForce/2;
      springArray[threads/2-2][numBalls/2].velocity.x += keyForce/4;
    }
    if (key == 'a') {
      springArray[threads/2][numBalls/2].velocity.x -= keyForce;
      springArray[threads/2][numBalls/2+1].velocity.x -= keyForce/2;
      springArray[threads/2][numBalls/2+2].velocity.x -= keyForce/4;
      springArray[threads/2][numBalls/2-1].velocity.x -= keyForce/2;
      springArray[threads/2][numBalls/2-2].velocity.x -= keyForce/4;
      springArray[threads/2+1][numBalls/2].velocity.x -= keyForce/2;
      springArray[threads/2+2][numBalls/2].velocity.x -= keyForce/4;
      springArray[threads/2-1][numBalls/2].velocity.x -= keyForce/2;
      springArray[threads/2-2][numBalls/2].velocity.x -= keyForce/4;
    }
    if (key == 'w') {
      springArray[threads/2][numBalls/2].velocity.y -= keyForce;
      springArray[threads/2][numBalls/2+1].velocity.y -= keyForce/2;
      springArray[threads/2][numBalls/2+2].velocity.y -= keyForce/4;
      springArray[threads/2][numBalls/2-1].velocity.y -= keyForce/2;
      springArray[threads/2][numBalls/2-2].velocity.y -= keyForce/4;
      springArray[threads/2+1][numBalls/2].velocity.y -= keyForce/2;
      springArray[threads/2+2][numBalls/2].velocity.y -= keyForce/4;
      springArray[threads/2-1][numBalls/2].velocity.y -= keyForce/2;
      springArray[threads/2-2][numBalls/2].velocity.y -= keyForce/4;
    }
    if (key == 's') {
      springArray[threads/2][numBalls/2].velocity.y += keyForce;
      springArray[threads/2][numBalls/2+1].velocity.y += keyForce/2;
      springArray[threads/2][numBalls/2+2].velocity.y += keyForce/4;
      springArray[threads/2][numBalls/2-1].velocity.y += keyForce/2;
      springArray[threads/2][numBalls/2-2].velocity.y += keyForce/4;
      springArray[threads/2+1][numBalls/2].velocity.y += keyForce/2;
      springArray[threads/2+2][numBalls/2].velocity.y += keyForce/4;
      springArray[threads/2-1][numBalls/2].velocity.y += keyForce/2;
      springArray[threads/2-2][numBalls/2].velocity.y += keyForce/4;
    }
    if (key == 'q') 
    {
      springArray[threads/2][numBalls/2].velocity.z += keyForce;
      springArray[threads/2][numBalls/2+1].velocity.z += keyForce/2;
      springArray[threads/2][numBalls/2+2].velocity.z += keyForce/4;
      springArray[threads/2][numBalls/2-1].velocity.z += keyForce/2;
      springArray[threads/2][numBalls/2-2].velocity.z += keyForce/4;
      springArray[threads/2+1][numBalls/2].velocity.z += keyForce/2;
      springArray[threads/2+2][numBalls/2].velocity.z += keyForce/4;
      springArray[threads/2-1][numBalls/2].velocity.z += keyForce/2;
      springArray[threads/2-2][numBalls/2].velocity.z += keyForce/4;
    }
    if (key == 'e') {
      springArray[threads/2][numBalls/2].velocity.z -= keyForce;
      springArray[threads/2][numBalls/2+1].velocity.z -= keyForce/2;
      springArray[threads/2][numBalls/2+2].velocity.z -= keyForce/4;
      springArray[threads/2][numBalls/2-1].velocity.z -= keyForce/2;
      springArray[threads/2][numBalls/2-2].velocity.z -= keyForce/4;
      springArray[threads/2+1][numBalls/2].velocity.z -= keyForce/2;
      springArray[threads/2+2][numBalls/2].velocity.z -= keyForce/4;
      springArray[threads/2-1][numBalls/2].velocity.z -= keyForce/2;
      springArray[threads/2-2][numBalls/2].velocity.z -= keyForce/4;
    }
    if (keyCode == RIGHT) 
    {
      springArray[threads/2][numBalls/2].position.x += keyHold;
    }
    if (keyCode == LEFT) {
      springArray[threads/2][numBalls/2].position.x -= keyHold;
    }
    if (keyCode == UP) {
      springArray[threads/2][numBalls/2].position.y -= keyHold;
     
    }
    if (keyCode == DOWN) {
      springArray[threads/2][numBalls/2].position.y += keyHold;
    }
    if (keyCode == ALT) 
    {
      springArray[threads/2][numBalls/2].position.z += keyHold;
    }
    if (keyCode == CONTROL) {
      springArray[threads/2][numBalls/2].position.z -= keyHold;
    }
}
