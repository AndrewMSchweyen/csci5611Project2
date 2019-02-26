import peasy.*;

PeasyCam cam;
PImage cloth;
PShape sphere;
int numBalls = 10;
int threads = 30;
final float dt = .001;
float floor = 400;
float gravity = 20;
float restLen = 5;
float mass = .8; 
float k = 10000; 
float kv = 10;
float bounce = -.1;
float keyForce = 1000;
float keyHold = 100;
PVector[][] newVelocity = new PVector[threads][numBalls];
Spring[][] springArray = new Spring[threads][numBalls];
int updateRate = 95;
int sphereRadius = 50;
float sphereX = 250, sphereY =310, sphereZ = 20;
//Create Window
public void settings() {
  size(800, 800, P3D);
}

void setup() {

  lights();
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
  collisionDetection();
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

void collisionDetection()
{
    for(int i=0; i < threads; i++)
  {
    for(int j =0; j<numBalls; j++)
    {
      float distanceToSphere = sqrt( sq(sphereX-springArray[i][j].position.x) + sq(sphereY-springArray[i][j].position.y) + sq(sphereZ-springArray[i][j].position.z));
   //   println("distance to sphere: " + distanceToSphere);
      if( distanceToSphere <= (sphereRadius + .1))
      {
        PVector normal = new PVector(springArray[i][j].position.x - sphereX, springArray[i][j].position.z - sphereY, springArray[i][j].position.z - sphereZ);
        normal.normalize();
        springArray[i][j].position.x += (.1 + sphereRadius - distanceToSphere) * normal.x;
        springArray[i][j].position.y += (.1 + sphereRadius - distanceToSphere) * normal.y;
        springArray[i][j].position.z += (.1 + sphereRadius - distanceToSphere) * normal.z;
   //     println("detected");
      }
    } 
  }
}

void draw() 
{
  lights();
  println(frameRate);
  background(120,120,120);
  for(int i = 0; i< updateRate; i++)
  {
    update(dt);
  }
  drawCloth();  
}

void drawCloth()
{

  
  //strokeWeight(1);
  //fill(153);
  noStroke();
  pushMatrix();
  translate(sphereX, sphereY, sphereZ);
  fill(0,51,102);
  specular(204, 102, 0);
  lightSpecular(255, 255, 255);
  directionalLight(204, 204, 204, 0, 0, -1);
  sphere(sphereRadius);
  popMatrix();
    
  textureWrap(REPEAT);
  textureMode(NORMAL);
  for(int i=0; i < threads-1; i++)
  {
    beginShape(TRIANGLE_STRIP);
    texture(cloth);
    noTint();
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
      sphereX+=5;
    }
    if (key == 's') {
      sphereX-=5;
    }
    if (key == 'q') 
    {
      sphereZ+=5;
    }
    if (key == 'e') {
      sphereZ-=5;
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
        if (keyCode == CONTROL) {
      springArray[threads/2][numBalls/2].position.z -= keyHold;
    }
}
