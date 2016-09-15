BD = [10,10,790,600]
G = 1
stks = []
sl = 35
sw = 6
c1 = [95,90,85]
c2 = [250,250,250]


function choice(list){
  return list[floor(random(list.length))]
}


// DOT

var Dot = function(x,y){                                                    
  this.x = x
  this.y = y
  this.v = {x:0,y:0}
  this.fric = {x:0,y:0}
  this.m = 10
  this.fix = {x:false,y:false}
}


Dot.prototype.update = function(){
  if (this.fix.x == false){
    this.x += this.v.x
  }
  if (this.fix.y == false){
    this.y += this.v.y 
  }
  if (this.y < BD[3]){
    this.v.y += G
    this.fric.x = 0.9
  }else{
    this.v.y = 0
    this.y = BD[3]
    this.fric.x = 0.1
  }
  /*
  if (this.x <= BD[0]){
    this.x = BD[0]
    this.fric.y = 0.001
  }else{
    this.fric.y = 0.99
  }
  */
  this.fric.y = 0.99
  this.v.x *= this.fric.x
  this.v.y *= this.fric.y
}

Dot.prototype.appForce = function(f,dir){
  var ax = f*cos(dir) / this.m
  var ay = f*sin(dir) / this.m
  this.v.x += ax
  this.v.y += ay
}







//STK


var Stk = function (x,y,l,a){
  this.m1 = new Dot(x,y)
  this.m2 = new Dot(endpt(x,y,l,a).x,endpt(x,y,l,a).y)
  this.l = l
  this.phys = true
  this.sup = [-1,-1]
  
  this.targ = {x:-1,y:-1,l:-1,a:-1,fun:null}
  this.v = 10
  this.wasted = false
}

function endpt (x,y,l,a){
  return {x:x + cos(a) * l, y:y - sin(a) * l}
}

Stk.prototype.getang = function(){
  return atan2(this.m2.y-this.m1.y,this.m2.x-this.m1.x)
}

Stk.prototype.update = function(){
  this.m1.update()
  this.m2.update()
  
  var d = dist(this.m1.x,this.m1.y,this.m2.x,this.m2.y)
  if (abs(d-this.l) > 1){
    this.m1.appForce(2*(d-this.l),this.getang())
    this.m2.appForce(2*(this.l-d),this.getang())
    
  }
}
Stk.prototype.appTorque = function(f){

  this.m1.appForce(f,this.getang()+PI/2)
  this.m2.appForce(-f,this.getang()+PI/2)
}
Stk.prototype.walk = function(v){
  this.appTorque(v)
}

Stk.prototype.fullfix = function(){
  this.l = sl
  this.m1.fix = {x:true,y:true}
  this.m2.fix = {x:true,y:true}
  this.m1.v = {x:0,y:0}
  this.m2.v = {x:0,y:0}
  this.phys = false  
}

Stk.prototype.fullfree = function(){
  this.phys = true
  this.m1.fix = {x:false,y:false}
  this.m2.fix = {x:false,y:false}
  this.appTorque(random(10)-5)
  this.sup = [-1,-1]
}


Stk.prototype.animate = function(){
  if (this.targ.x != -1 || this.targ.y != -1){
    if (abs(this.targ.x - this.m1.x) > this.l*2){
      this.walk(this.v*((this.targ.x-this.m1.x<0)-0.5)*2)
    
    }else if (abs(this.targ.y - this.m1.y) > 1){
      
      
      this.phys = false
      var ept = endpt(this.targ.x,this.targ.y,sl,this.targ.a)
      //this.m1.fix = {x:this.targ.x,y:this.targ.y}
      //var d1 = dist(this.targ.x,this.targ.y,this.m1.x,this.m1.y)
      //var d2 = dist(ept.x,ept.y,this.m2.x,this.m2.y)
      this.m1.x += (this.targ.x-this.m1.x)/15
      this.m1.y += (this.targ.y-this.m1.y)/15
      this.m2.x += (ept.x-this.m2.x)/15
      this.m2.y += (ept.y-this.m2.y)/15
      
      //this.m1.appForce(min(15,d1*0.5),atan2(this.targ.y-this.m1.y,this.targ.x-this.m1.x))
      //this.m2.appForce(min(15,d1*0.5),atan2(ept.y-this.m2.y,ept.x-this.m2.x))
    }else{
      var ept = endpt(this.targ.x,this.targ.y,sl,this.targ.a)
      this.m1.x = this.targ.x
      this.m1.y = this.targ.y
      this.m2.x = ept.x
      this.m2.y = ept.y
      this.targ.x = -1
      this.targ.y = -1
      if (this.targ.fun != null){
        this.targ.fun()
      }
    }
  }
  
}






//STRUCT2


function Struct2(stk1,stk2){
  this.stk1 = stk1
  this.stk2 = stk2
}

Struct2.prototype.update = function(){
  this.stk1.update()
  this.stk2.update()
  //ellipse(this.stk1.m1.x,this.stk1.m1.y,20,20)
  var d = dist(this.stk1.m1.x,this.stk1.m1.y,this.stk2.m1.x,this.stk2.m1.y)
  if (abs(d) > 0){
    var xm = (this.stk1.m1.x+this.stk2.m1.x)/2
    var ym = (this.stk1.m1.y+this.stk2.m1.y)/2
    this.stk1.m1.x = xm
    this.stk2.m1.x = xm
    this.stk1.m1.y = ym
    this.stk2.m1.y = ym
  }
}
Struct2.prototype.walk = function(v){
  this.stk1.appTorque(v-(v<0)*0.5)
  this.stk2.appTorque(-v+(v>0)*0.5)
}



//STRUCT3


function Struct3(stk1,stk2,stk3){
  this.stk1 = stk1
  this.stk2 = stk2
  this.stk3 = stk3
}

Struct3.prototype.update = function(){
  this.stk1.update()
  this.stk2.update()
  this.stk3.update()
  //ellipse(this.stk1.m1.x,this.stk1.m1.y,20,20)

  var x1 = (this.stk1.m2.x+this.stk2.m1.x)/2
  var y1 = (this.stk1.m2.y+this.stk2.m1.y)/2
  this.stk1.m2.x = x1
  this.stk1.m2.y = y1
  this.stk2.m1.x = x1
  this.stk2.m1.y = y1

  var x2 = (this.stk2.m2.x+this.stk3.m1.x)/2
  var y2 = (this.stk2.m2.y+this.stk3.m1.y)/2
  this.stk2.m2.x = x2
  this.stk2.m2.y = y2
  this.stk3.m1.x = x2
  this.stk3.m1.y = y2

}
Struct3.prototype.walk = function(v){
  if (sin(0.05*frameCount)>0){
    this.stk1.appTorque(-v)
    this.stk2.appTorque(-v)
    this.stk3.appTorque(v)
    
  }
}





//NUMBERS
/*
  _0_
1|   |2
 |_3_|
4|   |5
 |_6_|

*/
N = []
N[0] = [0,1,2,4,5,6]
N[1] = [2,5]
N[2] = [0,2,3,4,6]
N[3] = [0,2,3,5,6]
N[4] = [1,2,3,5]
N[5] = [0,1,3,5,6]
N[6] = [0,1,3,4,5,6]
N[7] = [0,1,2,5]
N[8] = [0,1,2,3,4,5,6]
N[9] = [0,1,2,3,5,6]

NP = []
NP[0] = [0,0,0]
NP[1] = [0,0,-Math.PI/2]
NP[2] = [1,0,-Math.PI/2]
NP[3] = [0,1,0]
NP[4] = [0,1,-Math.PI/2]
NP[5] = [1,1,-Math.PI/2]
NP[6] = [0,2,0]

digits = []
digitstate = []

spos = {x0:180,y0:200,d:[0,100,100,100,100]}
function sumarr(a,n){
  if (n == 0){
    return a[0]
  }else{
    return a[n] + sumarr(a,n-1)
  }
}


function nbg(){
  var ss = []
  for (var i = 0; i < digits.length; i++){
    //strokeWeight(1)
    //stroke(100)
    //line(spos.x0+sumarr(spos.d,i)-sw/2,spos.y0,spos.x0+sumarr(spos.d,i)-sw/2,BD[3])
    if (mouseIsPressed){text(digits[i]+"_"+digitstate[i],spos.x0+sumarr(spos.d,i),spos.y0-20)}
    for (var j = 0; j < NP.length; j++){
      var np = NP[j]
      var xyla = [spos.x0+np[0]*sl+sumarr(spos.d,i),spos.y0+np[1]*sl,sl,np[2]]
      var ept = endpt(xyla[0],xyla[1],xyla[2],xyla[3])
      
      ss.push({x1:xyla[0],y1:xyla[1],x2:ept.x,y2:ept.y})
    }
  }
  for (var i = 0; i < ss.length; i++){
    stroke((c1[0]+c2[0])/2,(c1[1]+c2[1])/2,(c1[2]+c2[2])/2)
    strokeWeight(sw)
    line(ss[i].x1,ss[i].y1,ss[i].x2,ss[i].y2)
  }
  for (var i = 0; i < ss.length; i++){
    stroke(c2)
    strokeWeight(sw-2)
    line(ss[i].x1,ss[i].y1,ss[i].x2,ss[i].y2)
    stroke((c1[0]+c2[0])/2,(c1[1]+c2[1])/2,(c1[2]+c2[2])/2)
    strokeWeight(1)
    ellipse(ss[i].x1,ss[i].y1,sw-1,sw-1)
    ellipse(ss[i].x2,ss[i].y2,sw-1,sw-1)
  }
}




function increment(di,wrap){
  var lstk = []
  if (digitstate[di] - floor(digitstate[di]) != 0){
    return
  }
  digitstate[di] += 0.5
  for (var i = 0; i < stks.length; i++){
    var stk = stks[i]
    if (stk.sup[0] == di){
      
      
      // ONE
      
      if (digits[di] == 1){
        if (stk.sup[1] == 2){
          var sx = stk.m1.x
          var sy = stk.m1.y
          var nstk = new Stk(sx,sy,sl,-PI/2)
          nstk.m1.fix = {x:false,y:false}
          nstk.m2.fix = {x:true,y:true}
          
          nstk.appTorque(30)
          stks.push(nstk)
          setTimeout(function(){
            nstk.m1.x = sx-sl
            nstk.m1.y = sy+sl
            nstk.fullfix()
            nstk.sup = [di,3]
            
          },220)
          setTimeout(function(){
            var tstk = new Stk(sx-sl,sy+sl,sl*0.9,0)
            tstk.m1.fix = {x:true,y:true}
            tstk.m2.fix = {x:false,y:false}
            
            tstk.appTorque(30)
            stks.push(tstk)
            setTimeout(function(){
              tstk.m2.x = sx-sl
              tstk.m2.y = sy+sl*2
              tstk.fullfix()
              tstk.sup = [di,4]
              
            },1500)
          },300)
        } else if (stk.sup[1] == 5){
          console.log("yoyo")
          var tx = stk.m1.x
          var ty = stk.m1.y
          var sstk = stk
          setTimeout(function(){
            sstk.m1.fix = {x:false,y:false}
            sstk.phys = true
            sstk.appTorque(30)

            setTimeout(function(){
              sstk.m1.x = tx-sl
              sstk.m1.y = ty+sl
              sstk.fullfix()
              sstk.sup = [di,6]
            
            },220)
            
          },900)
          var ustk = new Stk(choice([-10,width+10]),BD[3]-10,sl,0)
          ustk.targ = {x:stk.m1.x-sl,y:stk.m1.y-sl,l:-1,a:0,fun:function(){
            ustk.sup = [di,0]
            ustk.fullfix()
            digits[di] = 2
            digitstate[di] =2
          }}
          stks.push(ustk)
          
        }
      
      // TWO
      
      }else if (digits[di] == 2){
        if (wrap != 3){
          if (stk.sup[1] == 4){
            stk.fullfree()
            var tstk = stk
            setTimeout(function(){ tstk.targ.x = choice([-100,width+100]); tstk.targ.fun = function(){tstk.wasted=true}}, 1200);
            
            //setTimeout(function(){ alert("Hello"); }, 3000);
            var sx = stk.m1.x
            var sy = stk.m1.y
            setTimeout(function(){
              var nstk = new Stk(sx+sl,sy,sl*0.8,-PI)
              nstk.m1.fix = {x:true,y:true}
              nstk.m2.fix = {x:false,y:false}
              stks.push(nstk)
              setTimeout(function(){
                nstk.m2.x = nstk.m1.x
                nstk.m2.y = nstk.m1.y+sl
                nstk.fullfix()
                nstk.sup = [di,5]
                digits[di] = 3
                digitstate[di] =3
              },1500)
            },600)
          }
          
        }else{
          if (stk.sup[1] == 3){
            stk.m1.fix = {x:false,y:false}
            stk.phys = true
            stk.l = sl*0.8
            var sstk = stk
            setTimeout(function(){
              sstk.m1.x = sstk.m2.x
              sstk.m1.y = sstk.m2.y
              sstk.m2.y = sstk.m2.y + sl
              sstk.fullfix()
              sstk.sup = [di,5]
              //digits[di] = 0
              //digitstate[di] =0
            },1500)
          }else if (stk.sup[1] == 0){
            var sx = stk.m1.x
            var sy = stk.m1.y
            var nstk = new Stk(sx,sy,sl*0.8,0)
            nstk.m1.fix = {x:true,y:true}
            nstk.m2.fix = {x:false,y:false}
            stks.push(nstk)
            setTimeout(function(){
              nstk.m2.x = nstk.m1.x
              nstk.m2.y = nstk.m1.y+sl
              nstk.fullfix()
              nstk.sup = [di,1]
              digits[di] = 0
              digitstate[di] =0
            },1500)
          }
          
        }
        
      // THREE  
        
      } else if (digits[di] == 3){
        if (wrap != 4){
            if (stk.sup[1] == 0){
              stk.m2.fix = {x:false,y:false}
              stk.l = sl*0.8
              stk.phys = true
              var tstk = stk
              setTimeout(function(){
                  tstk.m2.x = tstk.m1.x
                  tstk.m2.y = tstk.m1.y+sl
                  
                  tstk.fullfix()
                  tstk.sup = [di,1]
                  digits[di] = 4
                  digitstate[di] =4
              },1500)
            }if (stk.sup[1] == 6){
              stk.fullfree()
              var sstk = stk
              setTimeout(function(){ sstk.targ.x = choice([-100,width+100]); sstk.targ.fun = function(){sstk.wasted=true}}, 1200);
            }
        } else{
          if (stk.sup[1] == 3){
            stk.m2.fix = {x:false,y:false}
            stk.phys = true
            stk.l = sl*0.8
            var sstk = stk
            setTimeout(function(){
              sstk.m2.x = sstk.m1.x
              sstk.m2.y = sstk.m1.y + sl
              
              sstk.fullfix()
              sstk.sup = [di,4]
              //digits[di] = 0
              //digitstate[di] =0
            },1500)
          }else if (stk.sup[1] == 0){
            var sx = stk.m1.x
            var sy = stk.m1.y
            var nstk = new Stk(sx,sy,sl*0.8,0)
            nstk.m1.fix = {x:true,y:true}
            nstk.m2.fix = {x:false,y:false}
            stks.push(nstk)
            setTimeout(function(){
              nstk.m2.x = nstk.m1.x
              nstk.m2.y = nstk.m1.y+sl
              nstk.fullfix()
              nstk.sup = [di,1]
              digits[di] = 0
              digitstate[di] =0
            },1500)
          }
          
          
        }
        
        
      // FOUR  
        
        
      } else if (digits[di] == 4){
        
        if (stk.sup[1] == 2){
          stk.m1.fix = {x:false,y:false}
          stk.l = sl*0.8
          stk.phys = true
          stk.appTorque(-30)
          stk.sup[1] = -1
          var tstk = stk
          
          setTimeout(function(){
              
            tstk.m1.x = tstk.m2.x
            tstk.m1.y = tstk.m2.y+sl
            tstk.l = sl*0.9
            tstk.m1.fix = {x:true,y:true}
            
            tstk.m2.v = {x:0,y:0}
            tstk.m2.fix = {x:false,y:false}
            tstk.appTorque(30)
            
            setTimeout(function(){
              tstk.m2.x = tstk.m1.x-sl
              tstk.m2.y = tstk.m1.y
              tstk.fullfix()
              tstk.sup = [di,4]
              
            },180)  
              
              
          },700)
          var nstk = new Stk(choice([-10,width+10]),BD[3]-10,sl,0)
          nstk.targ = {x:stk.m1.x-sl,y:stk.m1.y,l:-1,a:0,fun:function(){
            nstk.sup = [di,0]
            nstk.fullfix()
            
            digits[di] = 5
            digitstate[di] =5
          }}
          stks.push(nstk)
        }
        
      
      // FIVE
      
        
      }else if (digits[di] == 5){
        if (wrap != 6){
          if (stk.sup[1] == 3){
            var sx = stk.m1.x
            var sy = stk.m1.y
            var nstk = new Stk(sx,sy,sl*0.8,0)
            nstk.m1.fix = {x:true,y:true}
            nstk.m2.fix = {x:false,y:false}
            stks.push(nstk)
            setTimeout(function(){
              nstk.m2.x = nstk.m1.x
              nstk.m2.y = nstk.m1.y+sl
              nstk.fullfix()
              nstk.sup = [di,4]
              digits[di] = 6
              digitstate[di] =6
            },1500)
          }
        }else{
          if (stk.sup[1] == 3){
            stk.m2.fix = {x:false,y:false}
            stk.phys = true
            stk.l = sl*0.8
            var sstk = stk
            setTimeout(function(){
              sstk.m2.x = sstk.m1.x
              sstk.m2.y = sstk.m1.y+sl
              sstk.fullfix()
              sstk.sup = [di,4]
              //digits[di] = 0
              //digitstate[di] =0
            },1500)
          }else if (stk.sup[1] == 0){
            var sx = stk.m1.x
            var sy = stk.m1.y
            var nstk = new Stk(sx+sl,sy,sl*0.8,-PI)
            nstk.m1.fix = {x:true,y:true}
            nstk.m2.fix = {x:false,y:false}
            stks.push(nstk)
            setTimeout(function(){
              nstk.m2.x = nstk.m1.x
              nstk.m2.y = nstk.m1.y+sl
              nstk.fullfix()
              nstk.sup = [di,2]
              digits[di] = 0
              digitstate[di] =0
            },1500)
          }
        }
        
        
      // SIX  
        
      }else if (digits[di] == 6){
        if (stk.sup[1] == 3 || stk.sup[1] == 4 || stk.sup[1] == 6){
          stk.fullfree()
          
          lstk.push(stk)
          setTimeout(function(){ l1stk = lstk.pop();
            l1stk.targ.x = choice([-100,width+100]);
            l1stk.targ.fun = function(){l1stk.wasted=true}}, random(3000)+500);
          
        }
        if (stk.sup[1] == 0){
          var sx = stk.m1.x
          var sy = stk.m1.y
          setTimeout(function(){
            var nstk = new Stk(sx+sl,sy,sl*0.8,-PI)
            nstk.m1.fix = {x:true,y:true}
            nstk.m2.fix = {x:false,y:false}
            stks.push(nstk)
            setTimeout(function(){
              nstk.m2.x = nstk.m1.x
              nstk.m2.y = nstk.m1.y+sl
              nstk.fullfix()
              nstk.sup = [di,2]
              digits[di] = 7
              digitstate[di] =7
            },1500)
          },600)
        }
        
      // SEVEN  
        
        
      }else if (digits[di] == 7){
        if (stk.sup[1] == 1){
          var sx = stk.m1.x
          var sy = stk.m1.y
          setTimeout(function(){
            var nstk = new Stk(sx,sy+sl,sl*0.9,0)
            nstk.m1.fix = {x:true,y:true}
            nstk.m2.fix = {x:false,y:false}
            stks.push(nstk)
            setTimeout(function(){
              nstk.m2.x = nstk.m1.x
              nstk.m2.y = nstk.m1.y+sl
              nstk.fullfix()
              nstk.sup = [di,4]
              
            },1500)
          },600)
          var sstk = new Stk(choice([-10,width+10]),BD[3]-10,sl,0)
          sstk.targ = {x:sx,y:sy+sl,l:-1,a:0,fun:function(){
            sstk.sup = [di,3]
            sstk.fullfix()
            
          }}
          stks.push(sstk)
          var tstk = new Stk(width+100,BD[3]-10,sl,PI/2)
          tstk.targ = {x:sx,y:sy+sl*2,l:-1,a:0,fun:function(){
            tstk.sup = [di,6]
            tstk.fullfix()
            digits[di] = 8
            digitstate[di] =8
          }}
          stks.push(tstk)
        }
        
      // EIGHT  
        
        
      }else if (digits[di] == 8){
        if (stk.sup[1] == 4){
          stk.phys = true
          stk.m1.fix = {x:false,y:false}
          //stk.m2.fix = {x:false,y:false}
          stk.appTorque(10)
          stk.sup = [-1,-1]
          var tstk = stk
          setTimeout(function(){
            digits[di] = 9
            digitstate[di] =9
          },100)
          setTimeout(function(){tstk.m2.v = {x:0,y:0};tstk.m2.fix = {x:false,y:false}},900)
          setTimeout(function(){ tstk.targ.x = choice([-100,width+100]); tstk.targ.fun = function(){tstk.wasted=true}}, 2000);
        }
        
      // NINE  
        
      }else if (digits[di] == 9){
        if (stk.sup[1] == 3){
          stk.m2.fix = {x:false,y:false}
          stk.l = sl*0.8
          stk.phys = true
          var tstk = stk
          setTimeout(function(){
              tstk.m2.x = tstk.m1.x
              tstk.m2.y = tstk.m1.y+sl
              tstk.fullfix()
              tstk.sup = [di,4]
              digits[di] = 0
              digitstate[di] = 0
          },1500)
        }
        
        
      // ZERO  
        
      }else if (digits[di] == 0){
        if (stk.sup[1] == 0 || stk.sup[1] == 1 || stk.sup[1] == 4 || stk.sup[1] == 6){
          stk.fullfree()
          setTimeout(function(){digits[di] = 1;digitstate[di] = 1},100)
          
          lstk.push(stk)
          setTimeout(function(){ 
            var l1stk = lstk.pop()
            l1stk.targ.x = choice([-100,width+100]);
            l1stk.targ.fun = function(){l1stk.wasted=true}; 
            //l1stk.targ.fun = function(){delete l1stk}
          }, random(4000)+500);
          
        }
      }
      
    }
  }
  //print(test.targ.x)

}

function gettime(){
  return [floor(hour()/10),hour()%10,floor(((minute())%60)/10),(minute())%10,floor(second()/10)]
}


function setup(){
  //digits = [7,8,0,1]
  digits = gettime()
  
  //digitstate = [digits[0],digits[1],digits[2],digits[3],digits[4]]
  createCanvas(800,800)
  for (var i = 0; i < digits.length; i++){
    digitstate.push(digits[i])
    for (var j = 0; j < NP.length; j++){
      if (N[digits[i]].indexOf(j)!=-1){
        var np = NP[j]
        var nstk = new Stk(spos.x0+np[0]*sl+sumarr(spos.d,i),spos.y0+np[1]*sl,sl,np[2])
        nstk.m1.fix = {x:true,y:true}
        nstk.m2.fix = {x:true,y:true}
        nstk.phys = false
        nstk.sup = [i,j]
        stks.push(nstk)
      }
    }
  }
  //strokeCap(SQUARE);
}





function draw(){
  background(c2)

  if (mouseIsPressed){
    print(minute())
    print(gettime())
  }
  stroke(c1)
  strokeWeight(1)
  //line(0,BD[3],width,BD[3])
  noFill()
  rect(BD[0],BD[1],BD[2]-BD[0],BD[3]-BD[1])
  
  for (var i = 0; i < digits.length; i++){
    if (digits[i] != gettime()[i]){
      if (i == 0){
        increment(i,3)
      }else if (i == 2 || i == 4){
        increment(i,6)
      }else if (i == 1 && digits[0] == 2){
        increment(i,4)
      
      }else{
        increment(i)
      }
    }
  }
  
  
  
  nbg()

  for (var i = 0; i < stks.length; i++){
    var stk = stks[i]
    if (stk.phys){
      stk.update()
    }
    stk.animate()
    noFill()
    strokeWeight(sw)
    stroke(c1)
    line(stk.m1.x,stk.m1.y,stk.m2.x,stk.m2.y)
    noStroke()
    fill(255,0,0)
    if (mouseIsPressed){text(stk.sup,stk.m1.x,stk.m1.y)}
    if (stk.wasted == true){
      
      stks.splice(i,1)
      i -= 1
    }
    //ellipse(stk.m1.x,stk.m1.y,10,10)
  }

  if (mouseIsPressed){

  }

  

}
function mousePressed(){
  //increment(0)
  //increment(1)
  //increment(2)
  //increment(3)
}
