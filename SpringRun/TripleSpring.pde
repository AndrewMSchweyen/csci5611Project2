import peasy.*;
PeasyCam cam;

int numBalls = 10;
int threads = 30;
int[] fixedXValues = new int[threads];
Spring[][] springArray = new Spring[threads][numBalls];


//Create Window
public void settings() {
  size(800, 800, P3D);
}

void setup() {
 cam = new PeasyCam(this, 300,250,0, 250);
 cam.setYawRotationMode();
  surface.setTitle("Ball on Spring!");
  for(int i=0; i < threads; i++)
  {
    fixedXValues[i] = 200+ 5*i;
    println("fixedXVALUES " + fixedXValues[i]);
    for(int j =0; j<numBalls; j++)
    {
      springArray[i][j] =  new Spring(new PVector(fixedXValues[i],200+j,10*j), new PVector(0,0,0), new PVector(0,0,0));
     // println("x value: " + springArray[i][j].position.x + "y value: " +springArray[i][j].position.y );
    }
  }
}

//Simulation Parameters
float floor = 800;
float gravity = 78;
float radius = 10;
float stringTopX = 200;
float stringTopY = 50;
float restLenX = 0;
float restLen = 1;
float mass = .4; //TRY-IT: How does changing mass affect resting length?
float k = 1000; //TRY-IT: How does changing k affect resting length?
float kv = 100;
float bounce = -.1;
float keyForce = 1000;
PVector[][] newVelocity = new PVector[threads][numBalls];
final float dt = .01;
void update(float dt)
{
  copyVelocity();
  for(int i=0; i < threads-1; i++)
  {
    for(int j =0; j<numBalls; j++)
    {
      PVector distance = new PVector(0,0,0);
      float v1 ,v2 =0;
      float force =0;
      float length = 0;
      //horizontal calculations first
    //  newVelocity = springArray[i][j].velocity;
      
      PVector.sub(springArray[i+1][j].position, springArray[i][j].position, distance);
      length = sqrt(distance.dot(distance));
      distance.normalize();
      v1 = distance.dot(springArray[i][j].velocity);
      v2 = distance.dot(springArray[i+1][j].velocity);
      force = -k*(restLen - length) - kv*(v1 - v2);
      distance.y /= mass;
      newVelocity[i][j].add(PVector.mult(distance,force).mult(dt));
      newVelocity[i+1][j].sub(PVector.mult(distance,force).mult(dt)); 
      //if (j == 0)
      //{ 
      //  springArray[i][j].stretchForce.y = -k*((springArray[i][j].position.y - stringTopY) - restLen);
      //  springArray[i][j].stretchForce.x = -k*((springArray[i][j].position.x - fixedXValues[i]) - restLenX);
      //}
      //else
      //{
      //  springArray[i][j].stretchForce.y = -k*((springArray[i][j].position.y - springArray[i][j-1].position.y) - restLen);
      //  springArray[i][j].stretchForce.x = -k*((springArray[i][j].position.x - springArray[i][j-1].position.x) - restLenX);
      //}
      //springArray[i][j].dampForce.y = -kv*(springArray[i][j].velocity.y - 0);
      //springArray[i][j].overallForce.y = springArray[i][j].stretchForce.y + springArray[i][j].dampForce.y;
      //springArray[i][j].dampForce.x= -kv*(springArray[i][j].velocity.x - 0);
      //springArray[i][j].overallForce.x = springArray[i][j].stretchForce.x + springArray[i][j].dampForce.x;    
    }
  }
  
  
  for(int i=0; i < threads; i++)
  {
    for(int j =0; j<numBalls -1 ; j++)
    {
      PVector distance = new PVector(0,0,0);
      float v1 ,v2 =0;
      float force =0;
      float length = 0;
      //horizontal calculations first
    //  newVelocity = springArray[i][j].velocity;
      
      PVector.sub(springArray[i][j+1].position, springArray[i][j].position, distance);
      length = sqrt(distance.dot(distance));
      distance.normalize();
      v1 = distance.dot(springArray[i][j].velocity);
      v2 = distance.dot(springArray[i][j+1].velocity);
      force = -k*(restLen - length) - kv*(v1 - v2);
      distance.y /= mass;
      newVelocity[i][j].add(PVector.mult(distance,force).mult(dt));
      newVelocity[i][j+1].sub(PVector.mult(distance,force).mult(dt)); 
      //if (j == 0)
      //{ 
      //  springArray[i][j].stretchForce.y = -k*((springArray[i][j].position.y - stringTopY) - restLen);
      //  springArray[i][j].stretchForce.x = -k*((springArray[i][j].position.x - fixedXValues[i]) - restLenX);
      //}
      //else
      //{
      //  springArray[i][j].stretchForce.y = -k*((springArray[i][j].position.y - springArray[i][j-1].position.y) - restLen);
      //  springArray[i][j].stretchForce.x = -k*((springArray[i][j].position.x - springArray[i][j-1].position.x) - restLenX);
      //}
      //springArray[i][j].dampForce.y = -kv*(springArray[i][j].velocity.y - 0);
      //springArray[i][j].overallForce.y = springArray[i][j].stretchForce.y + springArray[i][j].dampForce.y;
      //springArray[i][j].dampForce.x= -kv*(springArray[i][j].velocity.x - 0);
      //springArray[i][j].overallForce.x = springArray[i][j].stretchForce.x + springArray[i][j].dampForce.x;    
    }
  }
  
  for(int i=0; i < threads; i++)
  {
    for(int j =0; j<numBalls; j++)
    {
      //newVelocity[i][j].add(new PVector(0,-.1,0));
      PVector.add(newVelocity[i][j], new PVector(0,gravity,0), newVelocity[i][j]);
    }
      newVelocity[i][0].mult(0);
  }
  
  for(int i=0; i < threads; i++)
  {
    for(int j =0; j<numBalls; j++)
    {
      springArray[i][j].position.add(newVelocity[i][j].mult(dt));
    }
  }
  
  
  ////Eulerian integration
  //for(int i=0; i < threads; i++)
  //{
  //  for(int j =0; j<numBalls; j++)
  //  {
  //    if(j == numBalls-1)
  //    {
  //      springArray[i][j].acceleration.x = .5*springArray[i][j].overallForce.x/mass;
  //      springArray[i][j].acceleration.y = gravity + .5*springArray[i][j].overallForce.y/mass; 
  //    }
  //    else
  //    {
  //      springArray[i][j].acceleration.x = .5*springArray[i][j].overallForce.x/mass - .5*springArray[i][j+1].overallForce.x /mass; 
  //      springArray[i][j].acceleration.y = gravity + .5*springArray[i][j].overallForce.y/mass - .5*springArray[i][j+1].overallForce.y /mass; 
  //    }
  
  //    springArray[i][j].velocity.x += springArray[i][j].acceleration.x*dt;
  //    springArray[i][j].position.x += springArray[i][j].velocity.x*dt;
  //    springArray[i][j].velocity.y += springArray[i][j].acceleration.y*dt;
  //    springArray[i][j].position.y += springArray[i][j].velocity.y*dt;
  //  }
  //}
  
    //Collision detection and response
  //  for(int i=0; i < threads; i++)
  //{
  //  for(int j =0; j<numBalls; j++)
  //  {
  //    if(springArray[i][j].position.y+radius >floor)
  //    {
  //      springArray[i][j].velocity.y *= bounce; 
  //      springArray[i][j].position.y = floor - radius;
  //    }
  //  }
  //}
      
  updateVelocity();
  
}

//Draw the scene: one sphere per mass, one line connecting each pair
void draw() 
{
  println(frameRate);
  background(255,255,255);
  update(dt); //We're using a fixed, large dt -- this is a bad idea!!
  fill(0,0,0);
  
  for(int i=1; i < threads; i++)
  {
    for(int j =1; j<numBalls; j++)
    {
    //  println("x value: " + springArray[i][j].position.x + "y value: " +springArray[i][j].position.y );
      //pushMatrix();
      strokeWeight(1);
      //if (j == 0 || i == 0)
      //{
      //  line(fixedXValues[i],stringTopY,springArray[i][j].position.x,springArray[i][j].position.y);
      // // translate(springArray[i][j].position.x,springArray[i][j].position.y);
      //}
      //else
      //{
        line(springArray[i][j-1].position.x,springArray[i][j-1].position.y,springArray[i][j-1].position.z,springArray[i][j].position.x,springArray[i][j].position.y,springArray[i][j].position.z);
        line(springArray[i-1][j].position.x,springArray[i-1][j].position.y,springArray[i-1][j].position.z,springArray[i][j].position.x,springArray[i][j].position.y,springArray[i][j].position.z);
        //translate(springArray[i][j].position.x,springArray[i][j].position.y);
        //sphere(radius);
      //}
      strokeWeight(5);
      point(springArray[i][j].position.x,springArray[i][j].position.y,springArray[i][j].position.z );
      //popMatrix();
    }
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
    if (keyCode == RIGHT) 
    {
      //springArray[i][numBalls/2].velocity.x += keyForce;
      springArray[threads/2][numBalls/2].velocity.x += keyForce;
      springArray[threads/2][numBalls/2+1].velocity.x += keyForce;
      springArray[threads/2][numBalls/2+2].velocity.x += keyForce;
      springArray[threads/2+1][numBalls/2].velocity.x += keyForce;
      springArray[threads/2+2][numBalls/2+1].velocity.x += keyForce;
      springArray[threads/2-1][numBalls/2+2].velocity.x += keyForce;
    }
    if (keyCode == LEFT) {
    springArray[threads/2][numBalls/2].velocity.x -= keyForce;
    }
    if (keyCode == UP) {
     springArray[threads/2][numBalls/2].velocity.y += keyForce;
       springArray[threads/2][numBalls/2].velocity.y += keyForce;
      springArray[threads/2][numBalls/2+1].velocity.y += keyForce;
      springArray[threads/2][numBalls/2+2].velocity.y += keyForce;
      springArray[threads/2+1][numBalls/2].velocity.y += keyForce;
      springArray[threads/2+2][numBalls/2+1].velocity.y += keyForce;
      springArray[threads/2-1][numBalls/2+2].velocity.y += keyForce;
    }
    if (keyCode == DOWN) {
     springArray[threads/2][numBalls/2].velocity.z += keyForce;
       springArray[threads/2][numBalls/2].velocity.z += keyForce;
      springArray[threads/2][numBalls/2+1].velocity.z += keyForce;
      springArray[threads/2][numBalls/2+2].velocity.z += keyForce;
      springArray[threads/2+1][numBalls/2].velocity.z += keyForce;
      springArray[threads/2+2][numBalls/2+1].velocity.z += keyForce;
      springArray[threads/2-1][numBalls/2+2].velocity.z += keyForce;
    }
}
