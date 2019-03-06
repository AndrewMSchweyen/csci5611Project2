import peasy.*;

PeasyCam cam;
int size = 100;
int waterWidth;
int dx = 10;
int dy = 10;
float startheight = 400;
float floor = 0; 
float g = 10;
float damp = 1;
float front = -100;
float rear = 100;
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
boolean isNoStroke = true;
//Create Window
public void settings() {
  size(800, 800, P3D);
}

void setup() {
  cam = new PeasyCam(this, (size/2) * dx, -startheight-30, 30, 1600); //centered around water
  cam.setYawRotationMode();
  createWater();
}

void createWater()
{
  for(int i=0;i<size+1;i++)
  {
    for(int j=0; j<size+1;  j++)
    {
      h[i][j] = 250;
      v[i][j] = 0;
      u[i][j] = 0;
    }    
  }
  
  h[1][1]= 420;
  
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
        dt/(2*dx)*((sq(u[i+1][j+1])/h[i+1][j+1] + g/2*sq(h[i+1][j+1])) - //<>//
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
  
  for(int i=1; i < size; i++)
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
        
      u[i][j] *= .999;
      v[i][j] *= .999;
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
      u[0][i] = u[1][i];
      u[size][i] = -u[size-1][i];
      
      v[i][0]= -v[i][1];
      v[i][size] = -v[i][size-1];
      v[0][i] = v[1][i];
      v[size][i] = v[size-1][i];
  }
  
}

void draw() 
{
  //frame.setTitle(str(frameRate));
  background(255,255,255);
  textSize(32);
  fill(0, 0, 0);
  text(frameRate, 50, -400); //<>//

  for (int i = 0; i< updateRate; i++)
  {
    update(dt);
  }
  for(int i=0;i<size-1; i++)
  {
    for(int j=0;j<size-1; j++)
    {
       drawQuad(-1*h[i][j], floor, i*dx, (i+1)*dx, j*dy, (j+1)*dy, -1 * h[i+1][j], -1 * h[i][j+1], -1*h[i+1][j+1], #1191F0, 255, isNoStroke);
    }
  }
}

void drawQuad(float top, float bottom, float left, float right, float front, float rear,float nextHeightU, float nextHeightV, float nextHeightUV, int col, float opacity, boolean noStroke){
  fill(col, opacity);
  stroke(0);
  if(noStroke){
    noStroke();
  }
  beginShape(QUADS);
  vertex(left, nextHeightV, rear);
  vertex(right, nextHeightUV, rear);
  vertex(right, bottom, rear);
  vertex(left, bottom, rear);
  
  vertex(right, nextHeightUV, rear);
  vertex(right, nextHeightU, front);
  vertex(right, bottom, front);
  vertex(right, bottom, rear);
  
  
  vertex(right, nextHeightU, front);
  vertex(left, top, front);
  vertex(left, bottom, front);
  vertex(right, bottom, front);
  
  vertex(left, top, front);
  vertex(left, nextHeightV, rear);
  vertex(left, bottom, rear);
  vertex(left, bottom, front);
  
  vertex(left, top, front);
  vertex(right, nextHeightU, front);
  vertex(right, nextHeightUV, rear);
  vertex(left, nextHeightV, rear);
  
  vertex(left, bottom, front);
  vertex(right, bottom, front);
  vertex(right, bottom, rear);
  vertex(left, bottom, rear);
  endShape();
}

void keyPressed() 
{
  if (key == 'r') 
  {
    createWater();
  }
    if (key == 's') 
  {
    isNoStroke = (!isNoStroke);
  }
    if (keyCode == UP) 
  {
    h[60][60] = 90;
  }
    if (keyCode == DOWN) 
  {
        h[20][20] = 30;
  }
      if (keyCode == LEFT) 
  {
        h[99][99] = 10;
  }
}
