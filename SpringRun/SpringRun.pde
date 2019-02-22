class Spring
{
  PVector position;
  PVector velocity;
  PVector acceleration;
  PVector stretchForce;
  PVector dampForce;
  PVector overallForce;
  
  float stringBottom;
  
  Spring(PVector position2, PVector velocity2, PVector acceleration2)
  {
    position = position2;
    velocity = velocity2;
    acceleration = acceleration2;
    stretchForce = new PVector(0,0);
    dampForce = new PVector(0,0);
    overallForce = new PVector(0,0);
  }
  
 /* void run()
  {
    update();
    display();
  }*/
  
  
  //void update(double dt)
  //{
  //  for (int q = 0; q < 10; q++)//10 substeps
  //  {  
  //   for (int i= 0; i< numV; i++)
  //    {
  //      acceleration.x = 0; 
  //      acceleration.y = 0;
  //    } //Reset acceleration
  //  for (inti= 0; i< numV-1; i++)
  //  {
  //    xlen= posX[i+1]-posX[i]; 
  //    ylen= posY[i+1]-posY[i];
  //    leng= sqrt(xlen*xlen+ ylen*ylen);
  //    force = (k/restLen)*(leng-restLen);
  //    forceX= xlen/leng;
  //    forceY= ylen/leng;
  //    aX= forceX* force; 
  //    aY= forceY* force;
  //    aX+= kV*(velX[i+1] -velX[i]);
  //    aY+= kV*(velY[i+1] -velY[i]);
  //    accX[i] += aX/2; 
  //    accY[i] += aY/2;
  //    accX[i+1] += -aX/2;
  //    accY[i+1] += -aY/2;
  //  }
  //for (int i= 1; i< numV-1; i++)
  //{  //Interior 
  //  vertsvelX[i] += accX[i] * dt; 
  //  velY[i] += accY[i] * dt;posX[i] += velX[i] * dt;
  //  posY[i] += velY[i] * dt;}}
  //}
  
  //void display()
  //{
    
  //}
}
