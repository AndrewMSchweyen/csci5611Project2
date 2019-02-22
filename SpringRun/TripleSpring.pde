int numBalls = 15;
int threads = 15;
int[] fixedXValues = new int[threads];
Spring[][] springArray = new Spring[threads][numBalls];


//Create Window
public void settings() {
  size(800, 800, P3D);
}

void setup() {
  surface.setTitle("Ball on Spring!");
  for(int i=0; i < threads; i++)
  {
    fixedXValues[i] = 200+ 25*i;
    println("fixedXVALUES " + fixedXValues[i]);
    for(int j =0; j<numBalls; j++)
    {
      springArray[i][j] =  new Spring(new PVector(fixedXValues[i],200+j), new PVector(0,0), new PVector(0,0));
     // println("x value: " + springArray[i][j].position.x + "y value: " +springArray[i][j].position.y );
    }
  }
}

//Simulation Parameters
float floor = 800;
float gravity = 10;
float radius = 10;
float stringTopX = 200;
float stringTopY = 50;
float restLenX = 0;
float restLen = 3;
float mass = 50; //TRY-IT: How does changing mass affect resting length?
float k = 100; //TRY-IT: How does changing k affect resting length?
float kv = 50;
float bounce = -.34;
float keyForce = 50;

void update(float dt){
  
  for(int i=0; i < threads; i++)
  {
    for(int j =0; j<numBalls; j++)
    {
      if (j == 0)
      { 
        springArray[i][j].stretchForce.y = -k*((springArray[i][j].position.y - stringTopY) - restLen);
        springArray[i][j].stretchForce.x = -k*((springArray[i][j].position.x - fixedXValues[i]) - restLenX);
      }
      else
      {
        springArray[i][j].stretchForce.y = -k*((springArray[i][j].position.y - springArray[i][j-1].position.y) - restLen);
        springArray[i][j].stretchForce.x = -k*((springArray[i][j].position.x - springArray[i][j-1].position.x) - restLenX);
      }
      springArray[i][j].dampForce.y = -kv*(springArray[i][j].velocity.y - 0);
      springArray[i][j].overallForce.y = springArray[i][j].stretchForce.y + springArray[i][j].dampForce.y;
      springArray[i][j].dampForce.x= -kv*(springArray[i][j].velocity.x - 0);
      springArray[i][j].overallForce.x = springArray[i][j].stretchForce.x + springArray[i][j].dampForce.x;    
    }
  }
  
  //Eulerian integration
  for(int i=0; i < threads; i++)
  {
    for(int j =0; j<numBalls; j++)
    {
      if(j == numBalls-1)
      {
        springArray[i][j].acceleration.x = .5*springArray[i][j].overallForce.x/mass;
        springArray[i][j].acceleration.y = gravity + .5*springArray[i][j].overallForce.y/mass; 
      }
      else
      {
        springArray[i][j].acceleration.x = .5*springArray[i][j].overallForce.x/mass - .5*springArray[i][j+1].overallForce.x /mass; 
        springArray[i][j].acceleration.y = gravity + .5*springArray[i][j].overallForce.y/mass - .5*springArray[i][j+1].overallForce.y /mass; 
      }
  
      springArray[i][j].velocity.x += springArray[i][j].acceleration.x*dt;
      springArray[i][j].position.x += springArray[i][j].velocity.x*dt;
      springArray[i][j].velocity.y += springArray[i][j].acceleration.y*dt;
      springArray[i][j].position.y += springArray[i][j].velocity.y*dt;
    }
  }
  
    //Collision detection and response
    for(int i=0; i < threads; i++)
  {
    for(int j =0; j<numBalls; j++)
    {
      if(springArray[i][j].position.y+radius >floor)
      {
        springArray[i][j].velocity.y *= bounce; 
        springArray[i][j].position.y = floor - radius;
      }
    }
  }
      

  
}

//Draw the scene: one sphere per mass, one line connecting each pair
void draw() 
{
  println(frameRate);
  background(255,255,255);
  update(.1); //We're using a fixed, large dt -- this is a bad idea!!
  fill(0,0,0);
  
  for(int i=0; i < threads; i++)
  {
    for(int j =0; j<numBalls; j++)
    {
    //  println("x value: " + springArray[i][j].position.x + "y value: " +springArray[i][j].position.y );
      //pushMatrix();
      strokeWeight(1);
      if (j == 0)
      {
        line(fixedXValues[i],stringTopY,springArray[i][j].position.x,springArray[i][j].position.y);
       // translate(springArray[i][j].position.x,springArray[i][j].position.y);
      }
      else
      {
        line(springArray[i][j-1].position.x,springArray[i][j-1].position.y,springArray[i][j].position.x,springArray[i][j].position.y);
        //translate(springArray[i][j].position.x,springArray[i][j].position.y);
        //sphere(radius);
      }
      strokeWeight(5);
      point(springArray[i][j].position.x,springArray[i][j].position.y);
      //popMatrix();
    }
  }
}

void keyPressed() 
{
    for(int i=0; i < threads; i++)
  {
    if (keyCode == RIGHT) {
      springArray[i][numBalls/2].velocity.x += keyForce;
    }
    if (keyCode == LEFT) {
      springArray[i][numBalls/2].velocity.x -= keyForce;
    }
    if (keyCode == UP) {
      springArray[i][numBalls/2].velocity.y -= keyForce;
    }
    if (keyCode == DOWN) {
      springArray[i][numBalls/2].velocity.y += keyForce;
    }
  }
}
