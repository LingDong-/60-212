float[] intersect(float l1x1,float l1y1,float l1x2,float l1y2,
                  float l2x1,float l2y1,float l2x2,float l2y2){
  float k1 = (l1y2-l1y1)/(l1x2-l1x1);
  float k2 = (l2y2-l2y1)/(l2x2-l2x1);
  float b1 = l1y1-k1*l1x1;
  float b2 = l2y1-k2*l2x1;
  float[] ins = new float[2];
  ins[0] = (b2-b1)/(k1-k2);
  ins[1] = ins[0]*k1+b1;
  return ins;
}

boolean onseg(float x, float y, float lx1, float ly1, float lx2, float ly2){
  
  return x>min(lx1,lx2) && x<max(lx1,lx2) && y>min(ly1,ly2) && y<max(ly1,ly2);
}

int stkN = 20;
float[] L;
void setup(){
  size(640,640);
  L = new float[stkN*4];
  for (int i = 0; i < stkN*4; i = i+4) {
    L[i]=random(width);
    L[i+1]=random(height);
    L[i+2]=random(width);
    L[i+3]=random(height);
  }
}
void draw(){
  background(255);

  stroke(0);
  
  for (int i = 0; i < L.length; i = i+4){
    line(L[i],L[i+1],L[i+2],L[i+3]);
  }
  
  for (int i = 0; i < L.length; i = i+4){
    for (int j = 0; j < L.length; j = j+4){
      if (i != j){
        float[] ins = intersect(L[i],L[i+1],L[i+2],L[i+3],L[j],L[j+1],L[j+2],L[j+3]);
        if (onseg(ins[0],ins[1],L[i],L[i+1],L[i+2],L[i+3]) && 
            onseg(ins[0],ins[1],L[j],L[j+1],L[j+2],L[j+3])){
          ellipse(ins[0],ins[1],10,10);
        }
      }
    }
  }
}
void mouseClicked(){
  setup();
}