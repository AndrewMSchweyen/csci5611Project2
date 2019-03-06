import peasy.*; //<>// //<>//

PeasyCam cam;
int size = 100;
int dx = 10;
int dy = 10;
int time=0;
boolean rain;
float damp = .05;
float startheight = 250;
float g = 10;
float dt = .01;
float updateRate = 6;
float h[][] = new float[size+1][size+1];
float hx[][] = new float[size][size];
float hy[][] = new float[size][size];
float u[][] = new float[size+1][size+1];
float ux[][] = new float[size][size];
float uy[][] = new float[size][size];
float v[][] = new float[size+1][size+1];
float vx[][] = new float[size][size];
float vy[][] = new float[size][size];

//Create Window
public void settings() {
  size(800, 800, P3D);
}

void setup() {
  cam = new PeasyCam(this, (size/2) * dx, -startheight, ((size/2) * dy), 800); //centered around water
  //cam.setYawRotationMode();
  cam.setPitchRotationMode();
  createWater();
}

void createWater()
{
  for(int i=0;i<size+1;i++)
  {
    for(int j=0; j<size+1;  j++)
    {
      h[i][j] = startheight;
      v[i][j] = 0;
      u[i][j] = 0;
    }    
  }
  
  for(int i=0;i<size;i++)
  {
    for(int j=0; j<size;  j++)
    {
      hx[i][j] = 0;
      hy[i][j] = 0;
      vx[i][j] = 0;
      vy[i][j] = 0;
      ux[i][j] = 0;
      uy[i][j] = 0;
    }    
  }
}

void update(float dt)
{

  reflectWater();
  //thread("calcHX");
  //  thread("calcUX");
  //    thread("calcVX");
  for(int i=0; i < size; i++)//x half step
  {
    for(int j =0; j<size-1; j++)
    {
      hx[i][j] = (h[i+1][j+1]+h[i][j+1])/2 - 
        dt/(2*dx)*(u[i+1][j+1] - u[i][j+1]);
      
      ux[i][j] = (u[i+1][j+1]+u[i][j+1])/2 - 
        dt/(2*dx)*((sq(u[i+1][j+1])/h[i+1][j+1] + g/2*sq(h[i+1][j+1])) -
        (sq(u[i][j+1])/h[i][j+1] + g/2*sq(h[i][j+1])));
      
      vx[i][j] = (v[i+1][j+1]+v[i][j+1])/2 - 
        dt/(2*dx)*(((u[i+1][j+1]*v[i+1][j+1])/h[i+1][j+1]) -  
        (u[i][j+1])*v[i][j+1]/h[i][j+1]);
    }
  }
  for(int i=0; i < size-1; i++)//y half step
  {
    for(int j =0; j<size; j++)
    {
      hy[i][j] = (h[i+1][j+1]+h[i+1][j])/2 -
        dt/(2*dy)*(v[i+1][j+1] - v[i+1][j]);
      
      uy[i][j] = (u[i+1][j+1]+u[i+1][j])/2 -
        dt/(2*dy)*(((v[i+1][j+1]*u[i+1][j+1])/h[i+1][j+1]) -
        (v[i+1][j]*u[i+1][j]/h[i+1][j]));    
      
      vy[i][j] = (v[i+1][j+1]+v[i+1][j])/2 - 
        dt/(2*dy)*((sq(v[i+1][j+1])/h[i+1][j+1] + g/2*sq(h[i+1][j+1])) - 
        (sq(v[i+1][j])/h[i+1][j] + g/2*sq(h[i+1][j])));
    }
  }
  
  for(int i=1; i < size; i++) //full step both directions
  {
    for(int j=1; j< size; j++)
    {
      h[i][j] = h[i][j] - (dt/dx)*(ux[i][j-1]-ux[i-1][j-1]) -
        (dt/dy)*(vy[i-1][j]-vy[i-1][j-1]);
      
      u[i][j] = u[i][j] - (dt/dx)*((sq(ux[i][j-1])/hx[i][j-1] + g/2*sq(hx[i][j-1])) - 
        (sq(ux[i-1][j-1])/hx[i-1][j-1] + g/2*sq(hx[i-1][j-1]))) - 
        (dt/dy)*((vy[i-1][j]*uy[i-1][j]/hy[i-1][j]) - 
        (vy[i-1][j-1]*uy[i-1][j-1]/hy[i-1][j-1]));
      
      v[i][j] = v[i][j] - (dt/dx)*((ux[i][j-1]*vx[i][j-1]/hx[i][j-1]) - 
        (ux[i-1][j-1]*vx[i-1][j-1]/hx[i-1][j-1])) - 
        (dt/dy)*((sq(vy[i-1][j])/hy[i-1][j] + g/2*sq(hy[i-1][j])) - 
        (sq(vy[i-1][j-1])/hy[i-1][j-1] + g/2*sq(hy[i-1][j-1])));
        
      u[i][j] -= dt *(damp*u[i][j]);
      v[i][j] -= dt *(damp*v[i][j]);
    }
  }  
}

void calcHX()
{
  for(int i=0; i < size; i++)//x half step
  {
    for(int j =0; j<size-1; j++)
    {
      hx[i][j] = (h[i+1][j+1]+h[i][j+1])/2 - 
        dt/(2*dx)*(u[i+1][j+1] - u[i][j+1]);
    }
  }
}

void calcUX()
{
  for(int i=0; i < size; i++)//x half step
  {
    for(int j =0; j<size-1; j++)
    {
            ux[i][j] = (u[i+1][j+1]+u[i][j+1])/2 - 
        dt/(2*dx)*((sq(u[i+1][j+1])/h[i+1][j+1] + g/2*sq(h[i+1][j+1])) -
        (sq(u[i][j+1])/h[i][j+1] + g/2*sq(h[i][j+1])));
    }
    
    
  }
}

void calcVX()
{
  for(int i=0; i < size; i++)//x half step
  {
    for(int j =0; j<size-1; j++)
    {
      
            vx[i][j] = (v[i+1][j+1]+v[i][j+1])/2 - 
        dt/(2*dx)*(((u[i+1][j+1]*v[i+1][j+1])/h[i+1][j+1]) -  
        (u[i][j+1])*v[i][j+1]/h[i][j+1]);
    }
  }
}

void reflectWater()
{
  for(int i=0;i<size+1;i++)
  {
      h[i][0]= h[i][1];
      h[i][size] = h [i][size-1];
      h[0][i] = h[1][i];
      h[size][i] = h[size-1][i];
      
      u[i][0]= u[i][1];
      u[i][size] = u[i][size-1];
      u[0][i] = -u[1][i];
      u[size][i] = -u[size-1][i];
      
      v[i][0]= -v[i][1];
      v[i][size] = -v[i][size-1];
      v[0][i] = v[1][i];
      v[size][i] = v[size-1][i];
  }
  
}

void draw() 
{
  println(frameRate);
  background(255, 255, 255);
  textSize(32);
  fill(0, 0, 0);
  text(frameRate, 0, -300);
  for (int i = 0; i< updateRate; i++)
  {
    update(dt);
  }
  for (int i=0; i < size; i++)
  {
    //noStroke();
    fill(17, 145, 240);
    beginShape(TRIANGLE_STRIP);
    for (int j=0; j < size; j++)
    {
      vertex(i*dx, -h[i][j], j*dy);
      vertex((i+1)*dx, -h[i+1][j+1], (j+1)*dy);
      //stroke(17, 145, 240);
      //line(i*dx, -h[i][j], j*dy, (i+1)*dx, -h[i+1][j], (j)*dy);
      //line(i*dx, -h[i][j], j*dy, (i)*dx, -h[i][j+1], (j+1)*dy);
    }
    endShape();
  }
  createRaindrops();
}

void createRaindrops()
{
  if(rain && (millis()-time) > 500) //every .5 second
  {
    h[(int)random(0,size)][(int)random(0,size)] = random(100, 200);
    time = millis();
  }
}

void keyPressed() 
{
  if (key == 'r') 
  {
    createWater();
  }
  if (keyCode == UP) 
  {
    h[1][1] = 20;
    h[size-1][1] = 20;
    h[1][size-1] = 20;
    h[size-1][size-1] = 20;
  }
  if (keyCode == DOWN) 
  {
    rain = !rain;
  }
}
