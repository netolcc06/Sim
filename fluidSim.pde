  
  Fluid fluid;
  
  void settings(){
      size(N*SCALE, N*SCALE);
  }
  
  void setup(){
      fluid = new Fluid(0.1, 0, 0, N);  
  }
  
  void mouseDragged(){
      fluid.addDensity(mouseX/SCALE, mouseY/SCALE, 200);
      float amountX = mouseX-pmouseX, amountY = mouseY-pmouseY; 
      fluid.addVelocity(mouseX/SCALE, mouseY/SCALE, amountX/SCALE, amountY/SCALE);
  }
  
  void mouseClicked(){}
  
  void draw(){
    
    background(0);
    fluid.simStep();
    fluid.renderDensity();
  
  }
