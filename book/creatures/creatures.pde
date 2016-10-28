//Imaginary Creatures Generator

boolean debug = false;
boolean export = false;

void regpoly(float x, float y, float r, float n, float ro){
  beginShape();
  for (int i = 0; i < n; i ++){
    vertex(x+r*cos(ro+i/n*PI*2),y-r*sin(ro+i/n*PI*2));
  }
  endShape(CLOSE);
}

float distsum(float[][] P){ 
  float d = 0;
  for (int i = 0; i < P.length-1; i++){
    d += dist(P[i][0],P[i][1],P[i+1][0],P[i+1][1]);
  }
  return d;
}

float[] midpt(float[] p1,float[] p2){
  return new float[] {(p1[0]+p2[0])/2,(p1[1]+p2[1])/2};
}

float[][] revpl(float[][] pl){
  float[][] nl = new float[pl.length][pl[0].length];
  for (int i = 0; i < pl.length; i++){
    nl[pl.length-1-i]=pl[i];
  }
  return nl;
  
}

float[][] bezmh(float[][] P){
  int cpl = 0;
  float[][] plist = new float[10000][2];
  
  for (int j = 0; j < P.length-2; j++){
    
    float[] p0;float[] p1;float[] p2;
    if (j == 0){
      p0 = P[j];
    }else{
      p0 = midpt(P[j],P[j+1]);
    }
    p1 = P[j+1];
    if (j == P.length-3){
      p2 = P[j+2];
    }else{
      p2 = midpt(P[j+1],P[j+2]);
    }
    float pl = distsum(new float[][]{p0,p1,p2});
    for (int i = 0; i < pl; i+= 1){
       float t = i/pl;
       float w=2;
       plist[cpl][0] = (pow(1-t,2)*p0[0]+2*t*(1-t)*p1[0]*w+t*t*p2[0])/(pow(1-t,2)+2*t*(1-t)*w+t*t);
       plist[cpl][1] = (pow(1-t,2)*p0[1]+2*t*(1-t)*p1[1]*w+t*t*p2[1])/(pow(1-t,2)+2*t*(1-t)*w+t*t);
       cpl++;
    }
  }
  float[][] fplist = new float[cpl][2];
  for (int i = 0; i < cpl; i+= 1){
    fplist[i] = plist[i];
  }
  return fplist;
}



public class Limb{
 Limb[] subs = new Limb[32];
 int subslength = 0;
 Limb par = null;
 float l;
 float tl1;
 float tl2;
 float a;
 float[] alim = new float[2];

 public Limb(float l){
   this.l = l;
 }
 public Limb growlimb(float nl, float na){
   Limb newlimb = new Limb(nl);
   newlimb.par = this;
   newlimb.a = na;
   subs[subslength] = newlimb;
   subslength ++;
   return newlimb;
 }

 public float rot(){
   if (par == null){
     return a;
   }else{
     float la = par.rot();
     float nl = la + a;
     return nl;
   }      
 }
 public float[] loc(){
   float r = rot();
   if (par == null){
     return new float[] {l * cos(r),-l * sin(r)};
   }else{
     float[] ll = par.loc();
     return new float[] {ll[0] + l * cos(r), ll[1] - l*sin(r)};
   }   
 }
  public float[] tlloc(int n){
   float[] lo = this.loc();  
    if (par == null){
   if (n== 1){
     return new float[] {lo[0]+tl1*cos(rot()-PI/2),lo[1]-tl1*sin(rot()-PI/2)};     
   } else if (n== 2){
     return new float[] {lo[0]+tl2*cos(rot()+PI/2),lo[1]-tl2*sin(rot()+PI/2)};     
   }
    }
   lo = par.loc();  
   float ro = (rot()+par.rot()+PI)/2+PI;
   if (n== 1){
     return new float[] {lo[0]+par.tl1*cos(ro),lo[1]-par.tl1*sin(ro)};     
   } else if (n== 2){
     return new float[] {lo[0]+par.tl2*cos(ro+PI),lo[1]-par.tl2*sin(ro+PI)};     
   }
   return new float[2];
   
 }
 
 
 public float[] relcoord(float pr, float di){
   float[] parloc;
   float r = rot();
   if (par == null){
     parloc = new float[]{0,0};
   }else{
     parloc = par.loc();
   }
   return new float[]{parloc[0] + pr * l * cos(r) + di * cos(r+PI/2), parloc[1] - pr * l * sin(r) - di * sin(r+PI/2)};
  
 }
 
 public void bounds(float[] bd){
   if (loc()[0] < bd[0]){bd[0] = loc()[0];}
   if (loc()[0] > bd[1]){bd[1] = loc()[0];}
   if (loc()[1] < bd[2]){bd[2] = loc()[1];}
   if (loc()[1] > bd[3]){bd[3] = loc()[1];}
   for (int i = 0; i < subslength; i++){
     if (subs[i] != null){
       
       subs[i].bounds(bd);
     }
   } 
 }
 public void flip(){
   if (par != null){
     a = -a;
   }else{
     a = PI-a;
   }
   for (int i = 0; i < subslength; i++){
     if (subs[i] != null){ 
       subs[i].flip();
     }
   } 
 } 
 
 public void drawSkel(){
   if (par != null){
     line(par.loc()[0],par.loc()[1],loc()[0],loc()[1]);
   }
   for (int i = 0; i < subslength; i++){
     if (subs[i] != null){
       
       subs[i].drawSkel();
     }
   }
 }
  public void drawOline(){
   if (par != null){
     line(par.tlloc(1)[0],par.tlloc(1)[1],tlloc(1)[0],tlloc(1)[1]);
     line(par.tlloc(2)[0],par.tlloc(2)[1],tlloc(2)[0],tlloc(2)[1]);
   }
   for (int i = 0; i < subslength; i++){
     if (subs[i] != null){
       stroke(random(255),random(255),random(255));
       subs[i].drawOline();
     }
   }
 }

}

public class Creature{
 float x;
 float y;
 float[][] dotmap = new float [floor(random(200,800))][2];
 float stpwd = random(20,100);
 float[] stpcol = {random(100),random(30),random(10,40)};
 
 Limb head; Limb jaw_u; Limb jaw_l; Limb neck;
 Limb spine_a; Limb spine_b; Limb spine_c; Limb pelvis;
 Limb tail_a; Limb tail_b; Limb tail_c; Limb tail_d;
 
 Limb shoulder_l; Limb forethigh_l; Limb foreleg_l; Limb forepaw_l;
 Limb midshould_l; Limb midthigh_l; Limb midleg_l; Limb midpaw_l;
 Limb hip_l; Limb hindthigh_l; Limb hindleg_l; Limb hindpaw_l;
 Limb wing_a_l; Limb wing_b_l; Limb wing_c_l;
 
 Limb shoulder_r; Limb forethigh_r; Limb foreleg_r; Limb forepaw_r;
 Limb midshould_r; Limb midthigh_r; Limb midleg_r; Limb midpaw_r; 
 Limb hip_r; Limb hindthigh_r; Limb hindleg_r; Limb hindpaw_r;
 Limb wing_a_r; Limb wing_b_r; Limb wing_c_r;

 Limb[] limbs;


 public Creature(){

   pelvis = new Limb(0);
   spine_c = pelvis.growlimb(0,0);
   spine_b = spine_c.growlimb(0,0);
   spine_a = spine_b.growlimb(0,0);
   neck = spine_a.growlimb(0,0);
   head = neck.growlimb(0,0);
   jaw_u = head.growlimb(0,0);
   jaw_l = head.growlimb(0,0);
   shoulder_l = spine_a.growlimb(0,0);
   shoulder_r = spine_a.growlimb(0,0);
   forethigh_l = shoulder_l.growlimb(0,0);
   forethigh_r = shoulder_r.growlimb(0,0);
   foreleg_l = forethigh_l.growlimb(0,0);
   foreleg_r = forethigh_r.growlimb(0,0);
   forepaw_l = foreleg_l.growlimb(0,0);
   forepaw_r = foreleg_r.growlimb(0,0);
   midshould_l = spine_b.growlimb(0,0);
   midshould_r = spine_b.growlimb(0,0);
   midthigh_l = midshould_l.growlimb(0,0);
   midthigh_r = midshould_r.growlimb(0,0);
   midleg_l = midthigh_l.growlimb(0,0);
   midleg_r = midthigh_r.growlimb(0,0);
   midpaw_l = midleg_l.growlimb(0,0);
   midpaw_r = midleg_r.growlimb(0,0); 
   hip_l = pelvis.growlimb(0,0);
   hip_r = pelvis.growlimb(0,0);
   hindthigh_l = hip_l.growlimb(0,0);
   hindthigh_r = hip_r.growlimb(0,0);
   hindleg_l = hindthigh_l.growlimb(0,0);
   hindleg_r = hindthigh_r.growlimb(0,0);
   hindpaw_l = hindleg_l.growlimb(0,0);
   hindpaw_r = hindleg_r.growlimb(0,0); 
   wing_a_l = spine_a.growlimb(0,0);
   wing_a_r = spine_a.growlimb(0,0);
   wing_b_l = wing_a_l.growlimb(0,0);
   wing_b_r = wing_a_r.growlimb(0,0);
   wing_c_l = wing_b_l.growlimb(0,0);
   wing_c_r = wing_b_r.growlimb(0,0);
   tail_a = pelvis.growlimb(0,0);
   tail_b = tail_a.growlimb(0,0);
   tail_c = tail_b.growlimb(0,0);
   tail_d = tail_c.growlimb(0,0);
   
   limbs = new Limb[] {pelvis,spine_c,spine_b,spine_a,neck,head,jaw_u,jaw_l,
   shoulder_l,shoulder_r,forethigh_l,forethigh_r,foreleg_l,foreleg_r,forepaw_l,forepaw_r,
   midshould_l,midshould_r,midthigh_l,midthigh_r,midleg_l,midleg_r,midpaw_l,midpaw_r,
   hip_l,hip_r,hindthigh_l,hindthigh_r,hindleg_l,hindleg_r,hindpaw_l,hindpaw_r,
   wing_a_l,wing_a_r,wing_b_l,wing_b_r,wing_c_l,wing_c_r,tail_a,tail_b,tail_c};
   
  }
  void makedotmap(float s0, float s1){
    for (int i = 0; i < dotmap.length; i ++){
      float[][] cdd = new float[1000][2];
      for (int j = 0; j < cdd.length; j++){
        cdd[j] = new float[]{random(-width*0.2,width*1.2)-trans[0],random(-height*0.2,height*1.2)-trans[1],random(s0,s1)};
      }
      int maxind = 0;
      float maxdist = 0;
      for (int j = 0; j < cdd.length; j++){
        float shortdist = width*height;
        for (int k = 0; k < i; k++){
           float cd = dist(cdd[j][0],cdd[j][1],dotmap[k][0],dotmap[k][1])-cdd[j][2]-cdd[k][2];
           if (cd < shortdist){
             shortdist = cd;
           }
        }
        if (shortdist > maxdist){
          maxdist = shortdist;
          maxind = j;
        }
      }
      dotmap[i] = cdd[maxind];
    } 

 }

 public void feather(float len, float bw, float[] col){

   for (int i = 0; i < len; i+=2){
     
     float ang = PI/4*((len-i)/len);//+random(-0.5*PI/i,0.5*PI/i);
     float cl = bw*0.03*sqrt(pow(len/2,4)-pow(i-len/2,4));
     stroke(col[0],col[1],lerp(min(col[2]+50,100),random(col[2],col[2]+50),i*1.0/len));
     line(i,0,i+cl*cos(ang),0+cl*sin(ang));
     stroke(col[0],col[1],lerp(min(col[2]+50,100),random(col[2],col[2]+50),i*1.0/len));
     line(i,0,i+cl*cos(ang),0-cl*sin(ang));
     
   }
   stroke(col[0],col[1],min(col[2],100));
   line(0,0,len,0);
 }
 
 public void antler(float[] p0, float wd, float len, int depth){
  
  if (depth > 0){
    float[][] cur = bezmh(new float[][]{{p0[0],p0[1]},{p0[0]+len/2,random(len/6,len/3)},{p0[0]+len,p0[1]}});
    hornnoil(cur,wd,new float[]{10,20,100});
    for (int i = 0; i < len/40; i++){
      pushMatrix();
      int ri = floor(random(0,cur.length));
      float[] rc = cur[ri];
      translate(rc[0],rc[1]);
      rotate(random(PI/4));
      float pp = 1.0*(cur.length-ri)/cur.length;
      antler(new float[]{0,0},wd*pp,len*random(pp/2,pp),depth-1);
      popMatrix();
    }
  }
 }
 
 
 public void horn(float[][] cur,float bw){
   
   beginShape();
   for (int i = 0; i < cur.length-1; i++){

     float tang = PI/2+atan2(cur[i+1][1]-cur[i][1],cur[i+1][0]-cur[i][0]);
     float cw =bw * (cur.length-i)/cur.length;
     vertex(cur[i][0]+cw*cos(tang),cur[i][1]+cw*sin(tang));
   }
   for (int i = cur.length-1; i >0; i--){
     float tang = PI/2+atan2(cur[i-1][1]-cur[i][1],cur[i-1][0]-cur[i][0]);
     float cw = bw * (cur.length-i)/cur.length;
     vertex(cur[i][0]+cw*cos(tang),cur[i][1]+cw*sin(tang));
   }   
   endShape(CLOSE);
 }
 
 public void hornil(float[][] cur, float bw, float[] col){

     noStroke();
    for (float i = bw; i > 0; i--){
      fill(col[0],col[1],col[2]*0.5+col[2]*0.5*(bw-i)/bw);
      horn(cur,i);  
    }  
   
 }
 
 public void hornnoil(float[][] cur, float bw, float[] col){

  fill(col[0],col[1],col[2]/3);
  noStroke();
  horn(cur,bw);
   for (int i = 0; i < cur.length-1; i++){

     float tang = PI/2+atan2(cur[i+1][1]-cur[i][1],cur[i+1][0]-cur[i][0]);

     float cw =(bw * (cur.length-i)/cur.length+1)*(0.4+1.1*noise(i*0.05));
     for (int j = 0; j < cw*10; j++){
       float rw = random(-1,1);
       float rc = col[2]*0.4+random(col[2]*0.3*(1-abs(rw)),col[2]*1.2*(1-abs(rw)));
       fill(col[0],col[1],rc);
       ellipse(cur[i][0]+rw*cw*cos(tang),cur[i][1]+rw*cw*sin(tang),1,1);
     }
   }

   
 }
 
 public void anyfill(String filltype, float[][] cur0, float[][] cur1, float[] coldat, float[] furdat, float[] patdat, int amount){
   if (filltype == "fur"){
     furfill(cur0,cur1,coldat,furdat,patdat,amount);
   }else if (filltype == "scale"){
     scalefill(cur0,cur1,coldat,furdat,patdat,amount);
   }else if (filltype == "feather"){
     featherfill(cur0,cur1,coldat,furdat,patdat,amount);
   }
   if (debug){
     strokeWeight(1);noFill();stroke(255,0,0);
     beginShape(); for (int i = 0; i < cur0.length; i++){
       vertex(cur0[i][0],cur0[i][1]);  
     }endShape(); stroke(255,0,255);
     beginShape(); for (int i = 0; i < cur1.length; i++){
       vertex(cur1[i][0],cur1[i][1]);    
     }endShape();
   }
 }
 
 public void furfill(float[][] cur0, float[][] cur1, float[] coldat, float[] furdat, float[] patdat, int amount){
   int ml = min(cur0.length,cur1.length);
   for (int i = 0; i < ml; i++){
     float ca = atan2(cur1[i][1]-cur0[i][1],cur1[i][0]-cur0[i][0]);
     float cl = dist(cur0[i][0],cur0[i][1],cur1[i][0],cur1[i][1]);
     float d2e = min(i,ml-i)/ml;
     cl = cl*(1.0+d2e*(0.4-0.8*noise(0.005*i)));
     cur1[i][0] = cur0[i][0]+cl*cos(ca);
     cur1[i][1] = cur0[i][1]+cl*sin(ca);    
   }   
   strokeWeight(1);
   if (ml > 0){
   for (int i = 0; i < amount; i++){
     int ir = floor(random(0,min(cur0.length,cur1.length)-1));
     float r = random(1);
     float xr = floor(lerp(cur0[ir][0],cur1[ir][0],r));
     float yr = floor(lerp(cur0[ir][1],cur1[ir][1],r));
     float driv1 = atan2(cur1[ir+1][1]-cur1[ir][1],cur1[ir+1][0]-cur1[ir][0]);
     float driv2 = atan2(cur0[ir+1][1]-cur0[ir][1],cur0[ir+1][0]-cur0[ir][0]);
     float p = dist(xr,yr,cur1[ir][0],cur1[ir][1])/dist(cur0[ir][0],cur0[ir][1],cur1[ir+1][0],cur1[ir+1][1]);
     float d = driv1*p+driv2*(1-p);
     float dr = d+random(-PI*0.1,PI*0.1)+(1-p)*furdat[2];
     stroke(coldat[0]+p*coldat[1]+random(coldat[2]),coldat[3]+p*coldat[4]+random(coldat[5]),coldat[6]+p*coldat[7]+random(coldat[8]));
     if (patdat[0] == 1){
       if (floor(xr/stpwd)%2 == 0){
         stroke(stpcol[0],stpcol[1],random(stpcol[2]));
       }
     }else if (patdat[0] == 2){
       for (int j = 0; j < dotmap.length; j++){
         if (dist(xr,yr,dotmap[j][0],dotmap[j][1])<dotmap[j][2]){
           stroke(stpcol[0],stpcol[1],random(stpcol[2]));
         }
       }
     }else if (patdat[0] == 3){
       for (int j = 0; j < dotmap.length; j++){
         if (dist(xr,yr,dotmap[j][0],dotmap[j][1])<dotmap[j][2] && dist(xr,yr,dotmap[j][0],dotmap[j][1])>dotmap[j][2]/2){
           stroke(stpcol[0],stpcol[1],random(stpcol[2]));
         }
       }       
     }
     float fl = furdat[0]+furdat[1]*noise(0.01*i);
     line(xr,yr,xr+fl*cos(dr),yr+fl*sin(dr));  

   }  
   }

 }
 public void furball(float x, float y,float r,float[] coldat){
   for (int i = 0; i < 100; i++){
     stroke(coldat[0]+0*coldat[1]+random(coldat[2]),coldat[3]+0*coldat[4]+random(coldat[5]),coldat[6]+0*coldat[7]+random(coldat[8]));
     line(x+random(-r,r),y+random(-r,r),x+random(-r,r),y+random(-r,r)); 
   }
 }
 
 public void scalefill(float[][] cur0, float[][] cur1, float[] coldat, float[] furdat, float[] patdat, int amount){
   int ml = min(cur0.length,cur1.length);
   for (int i = 0; i < ml; i++){
     float ca = atan2(cur1[i][1]-cur0[i][1],cur1[i][0]-cur0[i][0]);
     float cl = dist(cur0[i][0],cur0[i][1],cur1[i][0],cur1[i][1]);
     float d2e = min(i,ml-i)/ml;
     cl = cl*(1.0+d2e*(0.4-0.8*noise(0.005*i)));
     cur1[i][0] = cur0[i][0]+cl*cos(ca);
     cur1[i][1] = cur0[i][1]+cl*sin(ca);
     
   }   
   strokeWeight(1);
   amount = amount/20;
   for (int i = 0; i < amount; i+=5){
     int ir = floor(random(0,min(cur0.length,cur1.length)-1));
     float cd =  dist(cur0[ir][0],cur0[ir][1],cur1[ir][0],cur1[ir][1]);
     for (int j = 0; j < cd; j+=5){
       float r = random(1);
       float xr = floor(lerp(cur0[ir][0],cur1[ir][0],r));
       float yr = floor(lerp(cur0[ir][1],cur1[ir][1],r));
       float driv1 = atan2(cur1[ir+1][1]-cur1[ir][1],cur1[ir+1][0]-cur1[ir][0]);
       float driv2 = atan2(cur0[ir+1][1]-cur0[ir][1],cur0[ir+1][0]-cur0[ir][0]);
       float p = dist(xr,yr,cur1[ir][0],cur1[ir][1])/dist(cur0[ir][0],cur0[ir][1],cur1[ir+1][0],cur1[ir+1][1]);
       float d = driv1*p+driv2*(1-p);
       float dr = d+random(-PI*0.1,PI*0.1)+(1-p)*furdat[2];
       //dr = random(PI*2);
       float[] col = new float[]{coldat[0]+p*coldat[1]+random(coldat[2]),coldat[3]+p*coldat[4]+random(coldat[5]),coldat[6]+p*coldat[7]+random(coldat[8])};
       fill(col[0],col[1],col[2]);
       stroke(col[0],col[1]*0.8,col[2]*0.6);
       regpoly(xr,yr,4,5,dr);

     }
   }     
   
   for (int i = 0; i < ml-1; i+=6){
     int ir = i;//floor((i*1.0)/amount*(ml-1));//floor(random(0,min(cur0.length,cur1.length)-1));
     float cd =  dist(cur0[ir][0],cur0[ir][1],cur1[ir][0],cur1[ir][1]);
     for (int j = 0; j < cd; j+=6){
       float r = j/cd;//random(1);
       float xr = floor(lerp(cur0[ir][0],cur1[ir][0],r));
       float yr = floor(lerp(cur0[ir][1],cur1[ir][1],r));
       float driv1 = atan2(cur1[ir+1][1]-cur1[ir][1],cur1[ir+1][0]-cur1[ir][0]);
       float driv2 = atan2(cur0[ir+1][1]-cur0[ir][1],cur0[ir+1][0]-cur0[ir][0]);
       float p = dist(xr,yr,cur1[ir][0],cur1[ir][1])/dist(cur0[ir][0],cur0[ir][1],cur1[ir+1][0],cur1[ir+1][1]);
       float d = driv1*p+driv2*(1-p);
       float dr = d+random(-PI*0.1,PI*0.1)+(1-p)*furdat[2];

       float[] col = new float[]{coldat[0]+p*coldat[1]+random(coldat[2]),coldat[3]+p*coldat[4]+random(coldat[5]),coldat[6]+p*coldat[7]+random(coldat[8])};
       fill(col[0],col[1],col[2]);
       stroke(col[0],col[1]*0.8,col[2]*0.6);

       regpoly(xr,yr,6,5,dr);
     }
   }    
 } 
 
 
  public void featherfill(float[][] cur0, float[][] cur1, float[] coldat, float[] furdat, float[] patdat, int amount){
     
   int ml = min(cur0.length,cur1.length);
   if (ml > 0){
   strokeWeight(1);
   float a0 = atan2(cur0[1][1]-cur0[0][1],cur0[1][0]-cur0[0][0])+PI/2;
   float a1 = atan2(cur0[cur0.length-1][1]-cur0[cur0.length-2][1],cur0[cur0.length-1][0]-cur0[cur0.length-2][0]);

   for (int k = 0; k <=4; k+=1){
     for (float i = 1; i < ml-1; i*=1.05){
       int ir = floor(i);
       float cd =  dist(cur0[ir][0],cur0[ir][1],cur1[ir][0],cur1[ir][1]);
       
       float j = (4-k)*cd/4;
       float r = j/cd;
       float xr = floor(lerp(cur0[ir][0],cur1[ir][0],r));
       float yr = floor(lerp(cur0[ir][1],cur1[ir][1],r));
       pushMatrix();
       translate(xr,yr);
       rotate(lerp(a0,a1,(i*1.0)/ml));
       feather(lerp(20,100,j/cd*(i*1.0)/ml+random(-0.1,0.1)),lerp(0.5,5,(cd-j)/cd*(ml-i)/ml),new float[]{coldat[0],coldat[3],pow(j/cd,0.9)*coldat[6]+random(20)*coldat[7]});
       popMatrix();
       
     }
   }    
 } }

 
 public void featherfin(float[][] cur,float[] coldat){
  for(int i = 0; i < cur.length-1; i++){
    float tng = atan2(cur[i+1][1]-cur[i][1],cur[i+1][0]-cur[i][0]);
     pushMatrix();
     translate(cur[i][0],cur[i][1]);
     rotate(tng+random(-PI*0.1,PI*0.1));
     feather(100,0.1,new float[]{coldat[0],coldat[3],pow(0.5,0.9)*coldat[6]+random(20)});
     popMatrix();
  }
 } 
 
 public void feathertail(float[][] cur, float[] coldat){
  for(float j = 1; j < cur.length-1; j=j*1.5){
    int i = floor(j);
    float tng = atan2(cur[i+1][1]-cur[i][1],cur[i+1][0]-cur[i][0]);
    for (float k = 0; k < 1; k++){
     pushMatrix();
     translate(cur[i][0],cur[i][1]);
     rotate(tng+random(-PI/10*(cur.length-i)/cur.length,PI/10*(cur.length-i)/cur.length));
     feather(lerp(50,200,j/cur.length),lerp(0.5,0.001,j/cur.length),new float[]{coldat[0],coldat[3],pow(0.5,0.9)*coldat[6]+random(20)});
     popMatrix();
    }
  }
 } 
 public void drawfeathertail(float[] coldat){
   feathertail(bezmh(new float[][]{pelvis.loc(),tail_a.loc(),tail_b.loc(),tail_c.loc()}),coldat);   
 }
 
 
 
 
 
 public void draweye(float pr,float di, float rad,float[] col1, float[] col2, float[] coldat, float[] furdat, float[]patdat){

  float[] p1;
  p1 = head.relcoord(pr,di);//0.75,-25
  stroke(col1[0],col1[1],col1[2]/10);
  strokeWeight(5);
  fill(col1[0],col1[1],col1[2]);
  ellipse(p1[0],p1[1],rad,rad);
  
  noStroke();
  
  for (float i = 0; i < PI*2; i+=PI*0.1){
    fill(col1[0],col1[1],col1[2]*random(0.8,1.0));
    float rr = random(rad*0.4);
    ellipse(p1[0]+rr*cos(i),p1[1]+rr*sin(i),2,2);
  }
  
  stroke(col2[0],col2[1],col2[2]*2);
  strokeWeight(2);
  fill(col2[0],col2[1],col2[2]);
  
  
  ellipse(p1[0],p1[1],rad/3,rad/3);
  strokeWeight(1);
  for (float i = 0; i < PI*2; i+=PI*0.2){
    stroke(col2[0],col2[1],col2[2]*1.5);
    line(p1[0]+rad/10*cos(i),p1[1]+rad/10*sin(i),p1[0]+rad/6*cos(i),p1[1]+rad/6*sin(i));
  }

  furfill(
  bezmh(new float[][]{head.relcoord(pr+0.45,di),head.relcoord(pr+0.05,di-rad+min(rad,13)),head.relcoord(pr-0.25,di+5)}),
  bezmh(new float[][]{head.relcoord(pr+0.45,di),head.relcoord(pr+0.04,di-rad-5),head.relcoord(pr-0.25,di+5)}),
  coldat,new float[]{furdat[0]/3,furdat[1]/3,furdat[2]},patdat,floor(furdat[3]/100));
  furfill(
  bezmh(new float[][]{head.relcoord(pr+0.45,di),head.relcoord(pr+0.25,di+rad-min(22,rad)),head.relcoord(pr-0.05,di+rad-min(10,rad)),head.relcoord(pr-0.25,di+5)}),
  bezmh(new float[][]{head.relcoord(pr+0.45,di),head.relcoord(pr-0.05,di+rad),head.relcoord(pr-0.25,di+5)}),
  coldat,new float[]{furdat[0]/3,furdat[1]/3,furdat[2]},patdat,floor(furdat[3]/100));  
   
 }
 public void drawclaw(Limb leg, Limb paw, float size, float bend, float[] col, float[] coldat, float[] furdat, float[] patdat){

  hornil(bezmh(new float[][]{paw.relcoord(1.0,-2),paw.relcoord((size+1)/2,-bend-4),paw.relcoord(size,-5)}),4,col);
  hornil(bezmh(new float[][]{paw.relcoord(1.0,0),paw.relcoord((size+1)/2,-bend),paw.relcoord(size,0)}),4,col);
  hornil(bezmh(new float[][]{paw.relcoord(1.0,2),paw.relcoord((size+1)/2,-bend+4),paw.relcoord(size,5)}),4,col);

  furfill(
  bezmh(new float[][]{paw.relcoord(0.8,0),paw.loc(),paw.relcoord(0.8,0)}),
  bezmh(new float[][]{paw.relcoord(0.8,0),paw.relcoord(1.0,5),paw.relcoord(1.0,-15),paw.relcoord(0.8,0)}),
  coldat,new float[]{furdat[0]/3,furdat[1]/3,furdat[2]},patdat,floor(furdat[3])); 
   
 }
 public void drawear(float wd, float ht, float[] incol, float[] coldat,float[] furdat, float[] patdat){
  float b = -neck.tl1/2;
  furfill(
  bezmh(new float[][]{neck.loc(),neck.relcoord(1.0,b-ht),neck.loc()}),
  bezmh(new float[][]{neck.relcoord(1+wd,0),neck.relcoord(1.0,b-ht-20),neck.relcoord(1-wd,0)}),
  coldat,furdat,patdat,floor(furdat[3]/100)); 
  furfill(
  bezmh(new float[][]{neck.relcoord(1,b-ht/6),neck.relcoord(1.0,b-ht/2),neck.relcoord(1,b-ht/6)}),
  bezmh(new float[][]{neck.relcoord(1+wd/3,b-ht/4),neck.relcoord(1.0,b-ht),neck.relcoord(1-wd/3,b-ht/4)}),
  incol,furdat,new float[]{0},floor(furdat[3]/100)) ;
 }
   
 public void drawteeth(float wd, float ht, float[] col){
    for (float i = jaw_u.l*0.2; i < jaw_u.l*0.8; i+=wd){

     hornil(bezmh(new float[][]{jaw_u.relcoord(i/jaw_u.l,0),jaw_u.relcoord(i/jaw_u.l,ht),jaw_u.relcoord(i/jaw_u.l,ht+ht*4*noise(i*0.1))}),
     wd,col);
       }
    for (float i = jaw_l.l*0.2; i < jaw_l.l*0.8; i+=wd){


     hornil(bezmh(new float[][]{jaw_l.relcoord(i/jaw_l.l,0),jaw_l.relcoord(i/jaw_l.l,-ht),jaw_l.relcoord(i/jaw_l.l,-ht-ht*10*noise(i*0.1))}),
     wd,col);
     }  
   
 }
 public void drawtusk(float wd, float ht, float un, float ln, float[] col){
    for (float ii = 0; ii < un; ii+=1){
     float i = random(jaw_u.l*0.5,jaw_u.l*0.9);
     hornnoil(bezmh(new float[][]{jaw_u.relcoord(i/jaw_u.l,0),jaw_u.relcoord(i/jaw_u.l,ht),jaw_u.relcoord(i/jaw_u.l,ht+ht*4*noise(i*0.1))}),
     wd,col);
       }
  for (float ii = 0; ii < ln; ii+=1){

     float i = random(jaw_l.l*0.5,jaw_l.l*0.9);
     hornnoil(bezmh(new float[][]{jaw_l.relcoord(i/jaw_l.l,0),jaw_l.relcoord(i/jaw_l.l,-ht),jaw_l.relcoord(i/jaw_l.l,-ht-ht*10*noise(i*0.1))}),
     wd,col);
     } 

 }

 public void drawhorsetail(float[] coldat){

  float[][] cur = bezmh(new float[][]{pelvis.loc(),tail_a.loc(),tail_b.loc(),tail_c.loc()});
  for (int i = 0; i < 500; i++){
    noFill();
    stroke(coldat[0],coldat[3],random(coldat[6]*3));
    
    beginShape();
    float[] lastp = new float[]{cur[0][0],cur[0][1]};
    float rl = random(1);
    for (int j = 1; j < cur.length*rl; j++){

      float dis = dist(cur[j][0],cur[j][1],cur[j-1][0],cur[j-1][1]);
      float ang = atan2(cur[j][1]-cur[j-1][1],cur[j][0]-cur[j-1][0]);
      float nz = noise(i,j*0.01)*2-1;
      lastp = new float[]{lastp[0]+dis*cos(ang+nz*PI/6),lastp[1]+dis*sin(ang+nz*PI/6)};
      vertex(lastp[0],lastp[1]);
    }
    endShape();
  }
 }
   
 public void fishtail(float[][]cur0, float[][]cur1,float[] coldat){
  float sp = cur1.length*1.0/cur0.length;
  
   for (int i = 1; i < cur0.length; i++){
    
    for (int j = 0; j <= sp; j++){
      stroke(coldat[0],coldat[1],coldat[2]/2);
      strokeWeight(3);
      int ji = floor(i*sp+j);
      if (ji < cur1.length && ji >= 0){
        line(cur0[i][0],cur0[i][1],cur1[ji][0]+random(-5,5),cur1[ji][1]+random(-5,5));

      }
    } 
  
   }
  for (int i = 0; i < cur0.length; i++){
    
    for (int j = 0; j <= sp; j++){
      stroke(coldat[0],coldat[1],random(coldat[2]/3,coldat[2]));
      strokeWeight(1);
      int ji = floor(i*sp+j);
      if (ji < cur1.length && ji >= 0){

        float[] nc = new float[]{cur1[ji][0]+random(-5,5),cur1[ji][1]+random(-5,5)};
        float di = dist(cur0[i][0],cur0[i][1],nc[0],nc[1]);
        
        pushMatrix();
        translate(cur0[i][0],cur0[i][1]);
        rotate(atan2(nc[1]-cur0[i][1],nc[0]-cur0[i][0]));
        float lp = random(-1,1);
        for (int k = 0; k <= di; k+=5){
          float lp2 = random(-1,1);
          line(k,lp,k+5,lp+lp2);
          lp = lp + lp2;
        }
        popMatrix();
      }
    } 
  }
 }   
   
  public void drawfeatherfin(float[] coldat){
   featherfin(bezmh(new float[][]{pelvis.loc(),tail_a.loc(),tail_b.loc(),tail_c.loc()}),coldat);
  }
  public void drawfin_l(float[] coldat){
   featherfin(bezmh(new float[][]{spine_a.loc(),forethigh_l.loc(),forethigh_l.loc()}),coldat);
  }
  public void drawfin_r(float[] coldat){
   featherfin(bezmh(new float[][]{spine_a.loc(),forethigh_r.loc(),forethigh_r.loc()}),coldat);
  } 
  public void drawmidfin_l(float[] coldat){
   featherfin(bezmh(new float[][]{spine_b.loc(),midthigh_l.loc(),midthigh_l.loc()}),coldat);
  }
  public void drawmidfin_r(float[] coldat){
   featherfin(bezmh(new float[][]{spine_b.loc(),midthigh_r.loc(),midthigh_r.loc()}),coldat);
  } 
      
   
 public void drawwing(Limb wing_a, Limb wing_b, Limb wing_c, float[] coldat){
   scalefill( bezmh(new float[][]{wing_a.relcoord(0,0),wing_a.loc(),wing_b.loc(),wing_c.relcoord(0.7,0)}),
   bezmh(new float[][]{wing_a.relcoord(0,-40),wing_b.tlloc(1),wing_c.tlloc(1),wing_c.relcoord(0.7,0)}),
   new float[]{10,5,0,10,10,0,30,10,10},new float[]{6,8,0},new float[]{2},10);
   featherfill( bezmh(new float[][]{wing_a.relcoord(0,0),wing_a.loc(),wing_b.loc(),wing_c.loc()}),
   bezmh(new float[][]{wing_a.relcoord(0,-40),wing_b.tlloc(1),wing_c.tlloc(1),wing_c.loc()}),
   coldat,new float[]{6,8,0},new float[]{2},10);
 }
 
 

 
 
 public void drawtongue(int len){

  if (len > 0){
  float[][] cur = new float[len][2];
  for (int i = 0; i < len; i++){
    cur[i] = head.relcoord(1+i*0.2,random(10)*i/len);
  }
  hornil(bezmh(cur),10,new float[]{0,100,50});
  }
   
 }
 public void drawhorn(float wd, float ht, float[]col){
     hornnoil(bezmh(new float[][]{head.relcoord(1.0,0),head.relcoord(1.0,-ht/2),head.relcoord(0.5,-ht)}),
     wd,col);  
 }
 public void drawbeak(float[] col){
  c.hornil(bezmh(new float[][]{c.head.loc(),c.jaw_u.relcoord(0.5,-random(30)),c.jaw_u.loc()}),c.head.tl1/3,col);
  c.hornil(bezmh(new float[][]{c.head.loc(),c.jaw_l.relcoord(0.5,-random(30)),c.jaw_l.loc()}),c.head.tl2/3,col);   
 }
 
 public void drawback(String filltype, float[] coldat, float[] furdat, float[] patdat){
  anyfill(filltype,
  bezmh(new float[][]{neck.loc(),spine_a.loc(),spine_b.loc(),spine_c.loc(),pelvis.loc(),tail_a.loc(),tail_b.loc(),tail_c.loc()}),
  bezmh(new float[][]{head.tlloc(1),neck.tlloc(1),spine_a.tlloc(1),spine_b.tlloc(1),pelvis.tlloc(2),tail_b.tlloc(2),tail_c.tlloc(2),tail_c.loc()}),
  coldat,furdat,patdat,floor(furdat[3]));
 
 }
 public void drawbacknotail(String filltype, float[] coldat, float[] furdat, float[] patdat){
  anyfill(filltype,
  bezmh(new float[][]{neck.loc(),spine_a.loc(),spine_b.loc(),spine_c.loc(),pelvis.loc(),tail_a.loc()}),
  bezmh(new float[][]{head.tlloc(1),neck.tlloc(1),spine_a.tlloc(1),spine_b.tlloc(1),pelvis.tlloc(2),tail_a.loc()}),
  coldat,furdat,patdat,floor(furdat[3]));
 
 }
 
 
 public void drawbelly(String filltype, float[] coldat, float[] furdat, float[] patdat){
  anyfill(filltype,
  bezmh(new float[][]{neck.loc(),spine_b.loc(),spine_c.loc(),pelvis.loc(),tail_a.loc()}),
  bezmh(new float[][]{neck.loc(),forethigh_l.relcoord(0.5,0),spine_a.tlloc(2),spine_b.tlloc(2),midpt(hip_l.loc(),hindthigh_l.loc())}),
  coldat,new float[]{furdat[0]*2,furdat[1],furdat[2]+PI/3},patdat,floor(furdat[3]));  
   
 }
 public void drawforeleg_l(String filltype, float[] coldat, float[] furdat, float[] patdat){
  anyfill(filltype,
  bezmh(new float[][]{forepaw_l.loc(),foreleg_l.loc(),forethigh_l.loc(),shoulder_l.loc(),spine_a.loc(),neck.loc()}),
  bezmh(new float[][]{forepaw_l.loc(),forepaw_l.tlloc(1),foreleg_l.tlloc(1),forethigh_l.tlloc(1),head.tlloc(2)}), 
  coldat,furdat,patdat,floor(furdat[3])); 
  anyfill(filltype,
  bezmh(new float[][]{forepaw_l.loc(),foreleg_l.loc(),forethigh_l.loc(),shoulder_l.loc(),neck.loc(),spine_a.loc()}),
  bezmh(new float[][]{forepaw_l.loc(),forepaw_l.tlloc(2),foreleg_l.tlloc(2),forethigh_l.tlloc(2),spine_a.loc()}),
  coldat,furdat,patdat,floor(furdat[3])); 
 }
 public void drawforeleg_r(String filltype, float[] coldat, float[] furdat, float[] patdat){
  float[] nc = new float[coldat.length];
  arrayCopy(coldat,nc);
  nc[6] = nc[6]/3;
  nc[7] = nc[7]/3;
  nc[8] = nc[8]/3;
  anyfill(filltype,
  bezmh(new float[][]{forepaw_r.loc(),foreleg_r.loc(),forethigh_r.loc(),shoulder_r.loc(),spine_a.loc(),neck.loc()}),
  bezmh(new float[][]{forepaw_r.loc(),forepaw_r.tlloc(1),foreleg_r.tlloc(1),forethigh_r.tlloc(1),head.tlloc(2)}), 
  nc,furdat,patdat,floor(furdat[3])); 
  anyfill(filltype,
  bezmh(new float[][]{forepaw_r.loc(),foreleg_r.loc(),forethigh_r.loc(),shoulder_r.loc(),neck.loc(),spine_b.loc()}),
  bezmh(new float[][]{forepaw_r.loc(),forepaw_r.tlloc(2),foreleg_r.tlloc(2),forethigh_r.tlloc(2),spine_b.loc()}),
  nc,furdat,patdat,floor(furdat[3])); 
 } 
 
 public void drawmidleg_r(String filltype, float[] coldat, float[] furdat, float[] patdat){
  float[] nc = new float[coldat.length];
  arrayCopy(coldat,nc);
  nc[6] = nc[6]/3;
  nc[7] = nc[7]/3;
  nc[8] = nc[8]/3;
  anyfill(filltype,
  bezmh(new float[][]{midpaw_r.loc(),midleg_r.loc(),midthigh_r.loc(),midshould_r.loc(),spine_b.loc()}),
  bezmh(new float[][]{midpaw_r.loc(),midpaw_r.tlloc(1),midleg_r.tlloc(1),midthigh_r.tlloc(1),spine_b.loc()}), 
  nc,furdat,patdat,floor(furdat[3])); 
  anyfill(filltype,
  bezmh(new float[][]{midpaw_r.loc(),midleg_r.loc(),midthigh_r.loc(),midshould_r.loc(),spine_c.loc()}),
  bezmh(new float[][]{midpaw_r.loc(),midpaw_r.tlloc(2),midleg_r.tlloc(2),midthigh_r.tlloc(2),spine_c.loc()}),
  nc,furdat,patdat,floor(furdat[3])); 
 }  
 public void drawmidleg_l(String filltype, float[] coldat, float[] furdat, float[] patdat){
  anyfill(filltype,
  bezmh(new float[][]{midpaw_l.loc(),midleg_l.loc(),midthigh_l.loc(),midshould_l.loc(),spine_b.loc()}),
  bezmh(new float[][]{midpaw_l.loc(),midpaw_l.tlloc(1),midleg_l.tlloc(1),midthigh_l.tlloc(1),spine_b.loc()}), 
  coldat,furdat,patdat,floor(furdat[3])); 
  anyfill(filltype,
  bezmh(new float[][]{midpaw_l.loc(),midleg_l.loc(),midthigh_l.loc(),midshould_l.loc(),spine_c.loc()}),
  bezmh(new float[][]{midpaw_l.loc(),midpaw_l.tlloc(2),midleg_l.tlloc(2),midthigh_l.tlloc(2),spine_c.loc()}),
  coldat,furdat,patdat,floor(furdat[3])); 
 } 
 
 
 public void drawhindleg_l(String filltype, float[] coldat, float[] furdat, float[] patdat){
  anyfill(filltype,
  bezmh(new float[][]{hindpaw_l.loc(),hindleg_l.loc(),hindthigh_l.loc(),hip_l.loc(),pelvis.loc(),tail_a.loc(),tail_b.loc(),tail_c.loc()}),
  bezmh(new float[][]{hindpaw_l.loc(),hindpaw_l.tlloc(2),hindleg_l.tlloc(2),hindthigh_l.tlloc(2),pelvis.loc(),tail_b.tlloc(1),tail_c.tlloc(1),tail_c.loc()}),
  coldat,furdat,patdat,floor(furdat[3])); 
  anyfill(filltype,
  bezmh(new float[][]{pelvis.loc(),hip_l.loc(),hindthigh_l.loc(),hindleg_l.loc(),hindpaw_l.loc()}),
  bezmh(new float[][]{spine_c.tlloc(2),hindthigh_l.tlloc(1),hindleg_l.tlloc(1),hindpaw_l.tlloc(1),hindpaw_l.loc()}),
  coldat,furdat,patdat,floor(furdat[3])); 
 }
 public void drawhindlegnotail_l(String filltype, float[] coldat, float[] furdat, float[] patdat){
  anyfill(filltype,
  bezmh(new float[][]{hindpaw_l.loc(),hindleg_l.loc(),hindthigh_l.loc(),hip_l.loc(),pelvis.loc()}),
  bezmh(new float[][]{hindpaw_l.loc(),hindpaw_l.tlloc(2),hindleg_l.tlloc(2),hindthigh_l.tlloc(2),pelvis.loc()}),
  coldat,furdat,patdat,floor(furdat[3])); 
  anyfill(filltype,
  bezmh(new float[][]{pelvis.loc(),hip_l.loc(),hindthigh_l.loc(),hindleg_l.loc(),hindpaw_l.loc()}),
  bezmh(new float[][]{spine_c.tlloc(2),hindthigh_l.tlloc(1),hindleg_l.tlloc(1),hindpaw_l.tlloc(1),hindpaw_l.loc()}),
  coldat,furdat,patdat,floor(furdat[3])); 
 }
 
 
 public void drawhindleg_r(String filltype, float[] coldat, float[] furdat, float[] patdat){
  float[] nc = new float[coldat.length];
  arrayCopy(coldat,nc);
  nc[6] = nc[6]/3;
  nc[7] = nc[7]/3;
  nc[8] = nc[8]/3; 
  anyfill(filltype,
  bezmh(new float[][]{hindpaw_r.loc(),hindleg_r.loc(),hindthigh_r.loc(),hip_r.loc(),pelvis.loc()}),
  bezmh(new float[][]{hindpaw_r.loc(),hindpaw_r.tlloc(2),hindleg_r.tlloc(2),hindthigh_r.tlloc(2),pelvis.loc()}),
  nc,furdat,patdat,floor(furdat[3])); 
  anyfill(filltype,
  bezmh(new float[][]{pelvis.loc(),hip_r.loc(),hindthigh_r.loc(),hindleg_r.loc(),hindpaw_r.loc()}),
  bezmh(new float[][]{spine_c.tlloc(2),hindthigh_r.tlloc(1),hindleg_r.tlloc(1),hindpaw_r.tlloc(1),hindpaw_r.loc()}),
  nc,furdat,patdat,floor(furdat[3])); 
 }
 
 public void drawhead(String filltype, float[] coldat, float[] furdat, float[] patdat){
  anyfill(filltype,
  bezmh(new float[][]{spine_a.loc(),neck.loc(),head.loc(),jaw_l.loc(),head.loc(),jaw_u.loc(),head.loc(),neck.loc(),spine_a.loc()}),
  bezmh(new float[][]{forethigh_l.tlloc(2),head.tlloc(2),jaw_l.tlloc(2),jaw_l.loc(),head.loc(),jaw_u.loc(),jaw_u.tlloc(1),head.tlloc(1),neck.tlloc(1)}),
  coldat,furdat,patdat,floor(furdat[3])); 
 }
 
 public void drawbirdhead(String filltype, float[] coldat, float[] furdat, float[] patdat){
  anyfill(filltype,
  bezmh(new float[][]{spine_a.loc(),neck.loc(),head.loc(),jaw_l.relcoord(0.5,0),head.loc(),jaw_u.relcoord(0.5,0),head.loc(),neck.loc(),spine_a.loc()}),
  bezmh(new float[][]{forethigh_l.tlloc(2),head.tlloc(2),jaw_l.tlloc(2),jaw_l.relcoord(0.5,0),head.loc(),jaw_u.relcoord(0.5,0),jaw_u.tlloc(1),head.tlloc(1),neck.tlloc(1)}),
  coldat,furdat,patdat,floor(furdat[3])); 
 }
 
 public void drawantler(float[] coldat){
  pushMatrix();
  translate(neck.loc()[0]-10,neck.loc()[1]-30);
  rotate(-PI/4);
  antler(new float[] {0,0},5,200,3);
  popMatrix();
  furball(neck.loc()[0]-10,neck.loc()[1]-30,10,coldat);
 }
}

float choice(float a,float b){
  if (random(1) > 0.5){
    return a;
  }
  return b;
  
}

float rg(float x, float xmin, float xmax){
  if (random(xmin,xmax) < x){
    return x-abs(randomGaussian()*(x-xmin)/2);
  }
  return x+abs(randomGaussian()*(xmax-x)/2);
}

float rtg(float x, float xmin, float xmax){
  if (random(xmin,xmax) < x){
    return x-abs(randomGaussian()*(x-xmin)/5);
  }
  return x+abs(randomGaussian()*(xmax-x)/5);
}

float[] dark(float[] col){
  return new float[] {col[0],col[1],col[2],col[3],col[4],col[5],col[6]/2.2,col[7]/2.2,col[8]/2.2};
  
}

public int maind(float[] arr){
  int ind = 0;
  float ma = 0;
  for (int i = 0; i < arr.length; i++){
    if (arr[i]>ma){
      ind = i;
      ma = arr[i];
    }    
  }
  return ind;
}

public class Generator{
  Creature c;
  float[] col;
  float[] fur;
  float[] pat;
  
  float[] bonecol;
  float[] feathercol;
  float[] fincol;
  float[] scalecol;
  String filltype;
  
  float sixleg = floor(random(4));
  float[] ctype;
  
  float patstyle = floor(random(4));
  float tailstyle = floor(random(3));
  float hoofy = (random(1));
  float clawsize = rg(2,1,2.5);
  float clawbend = rg(5,0,20);
  float eyehue = random(70);
  float winged = random(1);
    
  public Generator(){
    float a = random(7);
    float b = random(4);
    float c = random(4);
    ctype = new float[]{a/(a+b+c),b/(a+b+c),c/(a+b+c)};    
  }

  public void gen(){
    c = new Creature();
    if (patstyle == 0){
      c.makedotmap(10,100);
    }else{
      c.makedotmap(20,20);
    }
    if (random(1) > 0.2){
      filltype = "fur";
    }else{
      filltype = "scale";
    }    
    c.pelvis.tl1 = rg(50,30,100);
    c.pelvis.tl2 = rg(50,30,100);
    
    c.spine_c.l = rg(100,10,200);
    c.spine_c.a = rtg(0.9*PI,0.6*PI,1.2*PI);
    c.spine_c.tl1 = rg(20,5,50);
    c.spine_c.tl2 = rg(100,10,200);
    
    c.spine_b.l = rg(100,10,300);
    c.spine_b.a = rtg(0.1*PI,-0.5*PI,0.5*PI);
    c.spine_b.tl1 = rg(50,10,100);
    c.spine_b.tl2 = rg(100,10,200);
        
    c.spine_a.l = rg(100,10,300);
    c.spine_a.a = rtg(0.1*PI,-0.5*PI,0.5*PI);
    c.spine_a.tl1 = rg(50,10,100);
    c.spine_a.tl2 = rg(50,10,100);
    
    
    c.neck.l = rg(50,0,200);
    c.neck.a = rtg(-0.3*PI,-0.5*PI,-0.0*PI);
    c.neck.tl1 = rg(40,0,60);
    c.neck.tl2 = rg(40,0,60);
    
    
    c.head.l = rg(80,0,200);
    c.head.a = rtg(0.1*PI,-0.5*PI,0.5*PI);
    c.head.tl1 = rg(60,10,100);
    c.head.tl2 = rg(30,10,100);    
    
    
    c.jaw_u.l = rg(80,10,250);
    c.jaw_u.a = rtg(-0.1*PI,-0.4*PI,0.0*PI);
    c.jaw_l.l = rg(80,10,250);
    c.jaw_l.a = rtg(0.1*PI,0.0*PI,0.4*PI);
   

    c.shoulder_l.l = rg(20,10,100);
    c.shoulder_r.l = c.shoulder_l.l;
    c.shoulder_l.a = rtg(0.2*PI,-0.1*PI,0.6*PI);
    c.shoulder_r.a = c.shoulder_l.a + rtg(0,-PI*0.5,PI*0.5);
    c.shoulder_l.tl1 = rg(10,0,80);
    c.shoulder_l.tl2 = rg(50,10,150); 
    c.shoulder_r.tl1 = c.shoulder_l.tl1;
    c.shoulder_r.tl2 = c.shoulder_l.tl2;
    
    c.forethigh_l.l = rg(100,20,200);
    c.forethigh_r.l = c.forethigh_l.l;
    c.forethigh_l.a = rtg(0.4*PI,0.2*PI,0.6*PI);
    c.forethigh_r.a = c.forethigh_l.a + rtg(0,-PI*0.5,PI*0.5);    
    c.forethigh_l.tl1 = c.shoulder_l.tl1 * rg(0.8,0,1);
    c.forethigh_l.tl2 = c.shoulder_l.tl2 * rg(0.8,0,1);; 
    c.forethigh_r.tl1 = c.forethigh_l.tl1;
    c.forethigh_r.tl2 = c.forethigh_l.tl2;    
    
    c.foreleg_l.l = c.forethigh_l.l*rtg(1,0,2);
    c.foreleg_r.l = c.foreleg_l.l;
    c.foreleg_l.a = rtg(-0.5*PI,-0.7*PI,-0.3*PI);
    c.foreleg_r.a = c.foreleg_l.a +  rtg(0,-PI*0.5,PI*0.5);       
    c.foreleg_l.tl1 = c.forethigh_l.tl1  * rg(0.8,0,1);
    c.foreleg_l.tl2 = c.forethigh_l.tl2  * rg(0.8,0,1); 
    c.foreleg_r.tl1 = c.foreleg_l.tl1;
    c.foreleg_r.tl2 = c.foreleg_l.tl2;   
  
 
    if (hoofy < 0.3){ 
      c.forepaw_l.l = c.foreleg_l.l*rtg(0.5,0,1);
      c.forepaw_r.l = c.forepaw_l.l;
      c.forepaw_l.a = rtg(-0.2*PI,-0.7*PI,0.3*PI);
      c.forepaw_r.a = c.forepaw_l.a +  rtg(0,-PI*0.5,PI*0.5);         
    }else{
      c.forepaw_l.l = c.foreleg_l.l*rtg(1,0,2);
      c.forepaw_r.l = c.forepaw_l.l;
      c.forepaw_l.a = rtg(0.3*PI,0.0*PI,0.8*PI);
      c.forepaw_r.a = c.forepaw_l.a +  rtg(0,-PI*0.5,PI*0.5);        
    }
    if (sixleg == 1){
      c.midshould_l.l = c.shoulder_l.l * rtg(1,0.8,1.1);
      c.midshould_r.l = c.midshould_l.l;
      c.midshould_l.a = rtg(0.5*PI,-0.1*PI,0.6*PI);
      c.midshould_r.a = c.midshould_l.a + rtg(0,-PI*0.5,PI*0.5);
      c.midshould_l.tl1 = c.shoulder_l.tl1 * rtg(1,0.8,1.1);
      c.midshould_l.tl2 = c.shoulder_l.tl2 * rtg(1,0.8,1.1); 
      c.midshould_r.tl1 = c.midshould_l.tl1;
      c.midshould_r.tl2 = c.midshould_l.tl2;
      
      c.midthigh_l.l = c.forethigh_l.l * rtg(1,0.8,1.1);
      c.midthigh_r.l = c.midthigh_l.l;
      c.midthigh_l.a = rtg(0.4*PI,0.2*PI,0.6*PI);
      c.midthigh_r.a = c.midthigh_l.a + rtg(0,-PI*0.5,PI*0.5);    
      c.midthigh_l.tl1 = c.midshould_l.tl1 * rg(0.8,0,1);
      c.midthigh_l.tl2 = c.midshould_l.tl2 * rg(0.8,0,1);; 
      c.midthigh_r.tl1 = c.midthigh_l.tl1;
      c.midthigh_r.tl2 = c.midthigh_l.tl2;    
      
      c.midleg_l.l =  c.foreleg_l.l * rtg(1,0.8,1.1);
      c.midleg_r.l = c.midleg_l.l;
      c.midleg_l.a = rtg(-0.5*PI,-0.7*PI,-0.3*PI);
      c.midleg_r.a = c.midleg_l.a +  rtg(0,-PI*0.5,PI*0.5);       
      c.midleg_l.tl1 = c.midthigh_l.tl1  * rg(0.8,0,1);
      c.midleg_l.tl2 = c.midthigh_l.tl2  * rg(0.8,0,1); 
      c.midleg_r.tl1 = c.midleg_l.tl1;
      c.midleg_r.tl2 = c.midleg_l.tl2;   
           
      if (hoofy < 0.3){ 
        c.midpaw_l.l = c.midleg_l.l*rtg(0.5,0,1);
        c.midpaw_r.l = c.midpaw_l.l;
        c.midpaw_l.a = rtg(-0.2*PI,-0.7*PI,0.3*PI);
        c.midpaw_r.a = c.midpaw_l.a +  rtg(0,-PI*0.5,PI*0.5);         
      }else{
        c.midpaw_l.l = c.midleg_l.l*rtg(1,0,2);
        c.midpaw_r.l = c.midpaw_l.l;
        c.midpaw_l.a = rtg(0.3*PI,0.0*PI,0.8*PI);
        c.midpaw_r.a = c.midpaw_l.a +  rtg(0,-PI*0.5,PI*0.5);        
      }    
    }
    
    
    c.hip_l.l = rg(20,10,100);
    c.hip_r.l = c.hip_l.l;
    c.hip_l.a = rtg(-0.3*PI,-0.5*PI,0.1*PI);
    c.hip_r.a = c.hip_l.a + rtg(0,-PI*0.4,PI*0.4);
    c.hip_l.tl1 = rg(80,10,200);
    c.hip_l.tl2 = rg(20,0,30); 
    c.hip_r.tl1 = c.hip_l.tl1;
    c.hip_r.tl2 = c.hip_l.tl2;   
    
    c.hindthigh_l.l = rg(100,20,200);
    c.hindthigh_r.l = c.hindthigh_l.l;
    c.hindthigh_l.a = rtg(-0.5*PI,-0.7*PI,-0.3*PI);
    c.hindthigh_r.a = c.hindthigh_l.a + rtg(0,-PI*0.4,PI*0.4);    
    c.hindthigh_l.tl1 = rg(20,0,30);
    c.hindthigh_l.tl2 = rg(20,0,30); 
    c.hindthigh_r.tl1 = c.hindthigh_l.tl1;
    c.hindthigh_r.tl2 = c.hindthigh_l.tl2;       
    
    c.hindleg_l.l = rg(100,20,200);
    c.hindleg_r.l = c.hindleg_l.l;
    c.hindleg_l.a = rtg(0.5*PI,0.3*PI,0.7*PI);
    c.hindleg_r.a = c.hindleg_l.a +  rtg(0,-PI*0.4,PI*0.4);       
    c.hindleg_l.tl1 = rg(5,0,30);
    c.hindleg_l.tl2 = rg(20,0,30); 
    c.hindleg_r.tl1 = c.hindleg_l.tl1;
    c.hindleg_r.tl2 = c.hindleg_l.tl2; 
    
    c.hindpaw_l.l = rg(80,20,150);
    c.hindpaw_r.l = c.hindpaw_l.l;
    c.hindpaw_l.a = rtg(-0.3*PI,-0.6*PI,-0.0*PI);
    c.hindpaw_r.a = c.hindpaw_l.a +  rtg(0,-PI*0.4,PI*0.4);   
    
    c.wing_a_l.l = rg(100,10,200);
    c.wing_a_r.l = c.wing_a_l.l;
    c.wing_a_l.a = rtg(-0.8*PI,-1.0*PI,-0.5*PI);
    c.wing_a_r.a = c.wing_a_l.a + rtg(0,-PI*0.4,PI*0.4);  
    c.wing_a_l.tl1 = rg(50,0,100);
    c.wing_a_l.tl2 = rg(0,0,10); 
    c.wing_a_r.tl1 = c.wing_a_l.tl1;
    c.wing_a_r.tl2 = c.wing_a_l.tl2; 
    
    c.wing_b_l.l = rg(100,10,200);
    c.wing_b_r.l = c.wing_b_l.l;
    c.wing_b_l.a = rtg(0.2*PI,0.0*PI,0.7*PI);  
    c.wing_b_r.a = c.wing_b_l.a + rtg(0,-PI*0.4,PI*0.4);  
    c.wing_b_l.tl1 = rg(80,0,160);
    c.wing_b_l.tl2 = rg(0,0,10); 
    c.wing_b_r.tl1 = c.wing_b_l.tl1;
    c.wing_b_r.tl2 = c.wing_b_l.tl2;     
    
    
    c.wing_c_l.l = rg(100,10,200);
    c.wing_c_r.l = c.wing_c_l.l;
    c.wing_c_l.a = rtg(-0.3*PI,-0.6*PI,0.0*PI);  
    c.wing_c_r.a = c.wing_c_l.a + rtg(0,-PI*0.4,PI*0.4);  
    c.wing_c_l.tl1 = rg(80,0,160);
    c.wing_c_l.tl2 = rg(0,0,10); 
    c.wing_c_r.tl1 = c.wing_c_l.tl1;
    c.wing_c_r.tl2 = c.wing_c_l.tl2;         
    
    
    c.tail_a.l = rg(100,0,200);
    c.tail_a.a = rg(0,-PI/3,PI/3);
    c.tail_a.tl1 = rg(5,0,50);
    c.tail_a.tl2 = rg(10,0,50); 
    
    c.tail_b.l = rg(100,0,200);
    c.tail_b.a = rg(0,-PI/3,PI/3);
    c.tail_b.tl1 = rg(5,0,50);
    c.tail_b.tl2 = rg(10,0,50);     
    
    c.tail_c.l = rg(100,0,200);
    c.tail_c.a = rg(0,-PI/3,PI/3);
    
    c.pelvis.a = -PI+ 
      atan2(c.spine_a.loc()[1]-c.pelvis.loc()[1],c.spine_a.loc()[0]-c.pelvis.loc()[0]);
      
    bonecol = new float[]{rtg(5,0,50),random(5,15),90};
    fincol = new float[]{random(100),0,0,rg(5,0,50),0,0,random(30),random(0.2,1),0};
    feathercol = new float[]{rtg(5,0,80),0,0,rg(5,0,50),0,0,random(60),random(0.5,1),0};
    if (filltype == "fur"){
      col = new float[]{rtg(5,0,30),2,10,random(10,50),-10,10,random(30),20,50};
    }else if (filltype == "scale"){
      col = new float[]{random(100),2,10,random(10,50),-10,10,random(20),10,10};
    }
    fur = new float[]{rg(6,0,20),8,0,50000};
    pat = new float[]{floor(random(4))};
  }
  public void render(){
    //c.drawbody();

    if (maind(ctype) == 2){
      winged = 1;
    }
    switch (maind(ctype)){
      case 0: 
        c.drawforeleg_r(filltype,col,fur,pat);

        c.drawhindleg_r(filltype,col,fur,pat);
        c.drawclaw(c.foreleg_r,c.forepaw_r,(clawsize+1)/2,clawbend,bonecol,dark(col),fur,pat);
        c.drawclaw(c.hindleg_r,c.hindpaw_r,(clawsize+1)/2,clawbend,bonecol,dark(col),fur,pat);
        if (sixleg == 1){ 
          c.drawmidleg_r(filltype,col,fur,pat);
          c.drawclaw(c.midleg_r,c.midpaw_r,(clawsize+1)/2,clawbend,bonecol,dark(col),fur,pat);
        }
      break;case 1:
        c.drawfin_r(dark(fincol));
        if (sixleg == 1){
          c.drawmidfin_r(dark(fincol));
        }
      break;case 2:
        c.drawhindleg_r("scale",col,fur,pat);
        c.drawhindlegnotail_l("scale",col,fur,pat);
        c.drawclaw(c.hindleg_r,c.hindpaw_r,clawsize,clawbend,bonecol,dark(col),fur,pat);
        c.drawclaw(c.hindleg_l,c.hindpaw_l,clawsize,clawbend,bonecol,col,fur,pat);
      break;
    }
    
    if (winged > 0.8){
      c.drawwing(c.wing_a_r,c.wing_b_r,c.wing_c_r,dark(feathercol));
    }

    switch (maind(ctype)){
      case 0:
        if (tailstyle == 1){
          c.drawhorsetail(dark(col));
          c.drawbacknotail(filltype,col,fur,pat);
          
        }else if (tailstyle == 2){
          c.drawfeatherfin(feathercol);
          c.drawbacknotail(filltype,col,fur,pat);
          
        }else{
          c.drawback(filltype,col, fur, pat);
          
        }break;
      case 1:
        c.drawfeatherfin(fincol);
        c.drawbacknotail(filltype,col,fur,pat);
        break; 
      case 2:
      
        if (random(1) > 0.5){
          c.drawfeathertail(feathercol);
        }else{
          c.drawfeatherfin(feathercol);
        }
        c.drawbacknotail(filltype,col,fur,pat);
        break;
       
    }
    c.drawbelly(filltype,col,fur,pat);

    if (random(1) <0.2){
      c.drawhorn(random(5,30),random(100,300),bonecol);
    }
    c.drawtongue(floor(random(2,12)));
    
    if (maind(ctype) == 2){
      c.drawbeak(bonecol);
      c.drawbirdhead(filltype,col,fur,pat);
    }else{
      
      c.drawhead(filltype,col,fur,pat);
      c.drawteeth(random(3,8),random(3,4),bonecol);
      if (random(1) <0.2){
        c.drawantler(col);
      }
      if (filltype == "fur"){
        c.drawear(random(0.1,0.3),random(20,120),new float[]{random(10),2,10,random(20),-10,10,random(50,80),20,50},col,fur,pat);
      }
      
      if (random(1)>0.5){
        c.drawtusk(random(3,10),random(3,20),random(3),random(3),bonecol);
      }
    }

    c.draweye(0.75,-c.head.tl1*random(0.1,0.8),random(15,40),new float[]{eyehue,random(30),random(80,100)},new float[]{eyehue,random(60),random(0,50)},col,fur,pat);
    if (winged > 0.8){
      c.drawwing(c.wing_a_l,c.wing_b_l,c.wing_c_l,feathercol);
    }


    switch (maind(ctype)){
      case 0: 
        c.drawforeleg_l(filltype,col,fur,pat);
        
        if (tailstyle == 0){
          c.drawhindleg_l(filltype,col,fur,pat);
        }else{
          c.drawhindlegnotail_l(filltype,col,fur,pat);
        }
        c.drawclaw(c.foreleg_l,c.forepaw_l,(clawsize+1)/2,clawbend,bonecol,col,fur,pat);
        c.drawclaw(c.hindleg_l,c.hindpaw_l,(clawsize+1)/2,clawbend,bonecol,col,fur,pat);
        
        if (sixleg == 1){
          c.drawmidleg_l(filltype,col,fur,pat);
          c.drawclaw(c.midleg_l,c.midpaw_l,(clawsize+1)/2,clawbend,bonecol,col,fur,pat);
        }
      break;case 1:
        c.drawfin_l(fincol);
        if (sixleg == 1){
          c.drawmidfin_l(fincol);
        }
      break;case 2:
        
      break;
    }

  }

}





float[] trans = new float[] {500,400};
Creature c = new Creature();
Generator g;
float[] bd;

void settings(){
  if(export){size(2000,2000);}
  else{size(800,800);}
}
void setup(){
  if(!export){noLoop();}
  colorMode(HSB,100,100,100);  
}
void draw(){
  //c.wing_c_l.a += PI/4;
  float flippy = choice(0,1);
  pushMatrix();
  g = new Generator();
  bd = new float[]{0,0,0,0};
  g.gen();
  if (flippy == 1){
    g.c.pelvis.flip();
  }
  g.c.pelvis.bounds(bd);
  if (flippy == 1){
    g.c.pelvis.flip();
  }
  background(18,4,100);
  
  float sc = min(width*0.7/(bd[1]-bd[0]),height*0.7/(bd[3]-bd[2]));
  translate(width/2-sc*(bd[1]-(bd[1]-bd[0])/2),height/2.2-sc*(bd[3]-(bd[3]-bd[2])/2));//width/2-bd[0]-(bd[1]-bd[0])/2,height/2+bd[2]+(bd[3]-bd[2])/2);
  scale(sc);
  scale(1-flippy*2,1);
  
  g.render();
  popMatrix();

  if(debug){stroke(0,100,100);g.c.pelvis.drawSkel();}
  if(export){saveFrame("render"+nf(day(),2)+nf(hour(),2)+nf(minute(),2)+nf(second(),2)+nf(millis(),3)+".png");}

}