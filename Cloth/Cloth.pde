import peasy.*;

PeasyCam cam;
PImage cloth;
int numBalls = 30;
int threads = 30;
final float dt = .001;
float floor = 500;
float gravity = 20;
float restLen = 5;
float mass = 1; 
float k = 100000; 
float kv = 1000;
float bounce = -.1;
float sphereBounce;
float keySpeed = 5;
int updateRate = 180;
int sphereRadius = 50;
boolean fixed = true;
float sphereX = 270, sphereY =310, sphereZ = 180;
PVector newVelocity[][] = new PVector[threads][numBalls];
Spring springArray[][] = new Spring[threads][numBalls];

//Create Window
public void settings() {
  size(800, 800, P3D);
}

void setup() {
  cam = new PeasyCam(this, sphereX, sphereY, 50, 400); //centered on sphere's x and y
  cam.setYawRotationMode();
  cloth = loadImage("cloth.png");
  createCloth();
}

void createCloth()
{
  for (int i=0; i < threads; i++)
  {
    for (int j =0; j<numBalls; j++)
    {
      //springArray[i][j] =  new Spring(new PVector(restLen * i, 0, restLen * 2 * j), new PVector(0, 0, 0));
      springArray[i][j] =  new Spring(new PVector(200+restLen*i, 200, restLen*1.5*j), new PVector(0,0,0));
    }
  }
}

void update(float dt)
{
  copyVelocity(); //copy current velocity array to newVelocity array
  //Horizontal Spring Calculations
  for (int i=0; i < threads-1; i++)
  {
    for (int j =0; j<numBalls; j++)
    {
      PVector energy = new PVector(0, 0, 0);
      float v1, v2 =0;
      float force =0;
      float length = 0;  
      PVector.sub(springArray[i+1][j].position, springArray[i][j].position, energy);
      length = sqrt(energy.dot(energy));
      energy.normalize();
      v1 = energy.dot(springArray[i][j].velocity);
      v2 = energy.dot(springArray[i+1][j].velocity);
      force = -k*(restLen - length) - kv*(v1 - v2);
      energy.y /= mass;
      newVelocity[i][j].add(PVector.mult(energy, force).mult(dt));
      newVelocity[i+1][j].sub(PVector.mult(energy, force).mult(dt));
    }
  }

  //Vertical Spring Calculations
  for (int i=0; i < threads; i++)
  {
    for (int j =0; j<numBalls -1; j++)
    {
        PVector energy = new PVector(0, 0, 0);
        float v1, v2 =0;
        float force =0;
        float length = 0;   
        PVector.sub(springArray[i][j+1].position, springArray[i][j].position, energy);
        length = sqrt(energy.dot(energy));
        energy.normalize();
        v1 = energy.dot(springArray[i][j].velocity);
        v2 = energy.dot(springArray[i][j+1].velocity);
        force = -k*(restLen - length) - kv*(v1 - v2);
        energy.y /= mass;
        newVelocity[i][j].add(PVector.mult(energy, force).mult(dt));
        newVelocity[i][j+1].sub(PVector.mult(energy, force).mult(dt));
    }
  }

  for (int i=0; i < threads; i++) 
  {
    for (int j =0; j<numBalls; j++)
    {
      newVelocity[i][j].add(new PVector(0, gravity, 0)); //gravity force
    }
    if(fixed) newVelocity[i][0].mult(0); //fixed top string
  }

  for (int i=0; i < threads; i++) //update position
  {
    for (int j =0; j<numBalls; j++)
    {
      springArray[i][j].position.add(newVelocity[i][j].mult(dt));
    }
  }  
  updateVelocity(); //copy newVelocity array to current velocity array (for next dt)
  collisionDetection();
  
}

void collisionDetection()
{
  for (int i=0; i < threads; i++)
  {
    for (int j =0; j<numBalls; j++)
    {
      float distanceToSphere = sqrt( sq(sphereX-springArray[i][j].position.x) + sq(sphereY-springArray[i][j].position.y) + sq(sphereZ-springArray[i][j].position.z));
      if ( distanceToSphere <= (sphereRadius + 1))
      {
        PVector normal = new PVector(springArray[i][j].position.x - sphereX, springArray[i][j].position.z - sphereY, springArray[i][j].position.z - sphereZ);
        normal.normalize();
        sphereBounce = normal.dot(springArray[i][j].velocity);
        springArray[i][j].velocity.x -= 30*sphereBounce* normal.x;
        springArray[i][j].velocity.y -= 30*sphereBounce* normal.y;
        springArray[i][j].velocity.z -= 30*sphereBounce* normal.z;
        springArray[i][j].position.x += (1 + sphereRadius - distanceToSphere) * normal.x;
        springArray[i][j].position.y += (1 + sphereRadius - distanceToSphere) * normal.y;
        springArray[i][j].position.z += (1 + sphereRadius - distanceToSphere) * normal.z;
      }
    }
  }

  //Collision Detection w/ ground
  for (int i=0; i < threads; i++)
  {
    for (int j =0; j<numBalls; j++)
    {
      if (springArray[i][j].position.y >floor)
      {
        springArray[i][j].velocity.y *= bounce; 
        springArray[i][j].position.y = floor;
      }
    }
  }
}

void draw() 
{
  lights();
  println(frameRate);
  background(255, 255, 255);
  textSize(32);
  fill(0, 0, 0);
  //text(frameRate, 200, 200);
  for (int i = 0; i< updateRate; i++)
  {
    update(dt);
  }
  drawSphere();
  drawCloth();
}

void drawSphere()
{
  pushMatrix();
  beginShape();
  translate(sphereX, sphereY, sphereZ);
  fill(200);
  specular(204, 102, 0);
  lightSpecular(255, 255, 255);
  directionalLight(204, 102, 0, 0, 1, 0);
  sphere(sphereRadius);
  endShape();
  popMatrix();
} 

void drawCloth()
{
  //noStroke();
  noLights();
  fill(255, 255, 255);
  textureWrap(REPEAT);
  textureMode(NORMAL);
  for (int i=0; i < threads-1; i++)
  {
    beginShape(TRIANGLE_STRIP);
    texture(cloth);
    for (int j=0; j < numBalls; j++)
    {
      float u = map(j, 0, threads-1, 0, 1);
      float v = map(i, 0, numBalls-1, 0, 1);
      vertex(springArray[i][j].position.x, springArray[i][j].position.y, springArray[i][j].position.z, u, v);
      v = map(i+1, 0, numBalls-1, 0, 1);
      vertex(springArray[i+1][j].position.x, springArray[i+1][j].position.y, springArray[i+1][j].position.z, u, v);
    }
    endShape();
  }
}

void copyVelocity()
{
  for (int i=0; i < threads; i++)
  {
    for (int j =0; j<numBalls; j++)
    {
      newVelocity[i][j] = springArray[i][j].velocity.copy();
    }
  }
}

void updateVelocity()
{
  for (int i=0; i < threads; i++)
  {
    for (int j =0; j<numBalls; j++)
    {
      springArray[i][j].velocity = newVelocity[i][j].copy();
    }
  }
}

void keyPressed() 
{
  if (key == 'w') //up
  { 
    sphereY -= keySpeed;
  }
  if (key == 'a') //left
  { 
    sphereX -= keySpeed;
  }
  if (key == 's') //down
  { 
    sphereY += keySpeed;
  }
  if (key == 'd') //right
  {
    sphereX += keySpeed;
  }
  if (key == 'q') 
  {
    sphereZ +=keySpeed;
  }
  if (key == 'e') 
  {
    sphereZ -=keySpeed;
  }
  if (key == 'r') 
  {
    createCloth();
  }
  if (key == 'f') 
  {
    fixed = !fixed;
  }
}
