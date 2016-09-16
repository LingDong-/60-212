BD = [10,10,790,600]
G = 1
stks = []
stkpool = []
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
  
  this.targ = {x:-1,y:-1,l:-1,a:-1,fun:null,args:[]}
  this.v = 10
  this.wasted = false
  this.id = floor(random(100000))
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
        this.targ.fun(this.targ.args)
      }
    }
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
    if (key=="d"){text(digits[i]+"_"+digitstate[i],spos.x0+sumarr(spos.d,i),spos.y0-20)}
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


animq = []
//anim[i] = [id,timeout,func,args]
function ANIM(){
  
  for (var i = animq.length-1; i >=0; i--){
    if (animq[i][1] > 0){
      animq[i][1] -= 1
    }else{
      //print(animq[i][2])
      if (stks.indexOf(idstk(animq[i][0]))==-1){
        stks.push(idstk(animq[i][0]))
        stkpool.splice(stkpool.indexOf(idstk(animq[i][0])),1)
      }
      animq[i][2](animq[i][0],animq[i][3])
      animq.splice(i,1)

    }
  }
}
function idstk(id){
  for (var i = 0; i < stks.length; i++){
    if (stks[i].id == id){
      return stks[i]
    }
  }
  for (var i = 0; i < stkpool.length; i++){
    if (stkpool[i].id == id){
      return stkpool[i]
    }
  }
  print("Invalid stick")
  print("Your stick id: "+id)
  print("All id list:")
  for (var i = 0; i < stks.length; i++){
    print("stk "+i+" : "+stks[i].id)
  } 
  for (var i = 0; i < stkpool.length; i++){
    print("stk "+i+" : "+stkpool[i].id)
  } 
}

function startswing(id,args){
//args = [fixend,torque,sup,setdigit]
  var stk = idstk(id)
  stk.phys = true
  stk.l = sl*0.8
  if (args[0] == 1){
    stk.m1.fix = {x:true,y:true}
    stk.m2.fix = {x:false,y:false}
  }else if (args[0] == 2){
    stk.m1.fix = {x:false,y:false}
    stk.m2.fix = {x:true,y:true}    
  }
  stk.appTorque(args[1])
  if (args[3] != undefined){
    digits[args[2][0]] = args[2]
    digitstate[args[2][0]] =args[2]
  }
}

function stopswing(id,args){
//args = [fixend,fixpos,sup,setdigit]
  var stk = idstk(id)
  if (args[0] == 1){
    stk.m1.x = args[1][0]
    stk.m1.y = args[1][1]
  }else if (args[0] == 2){
    stk.m2.x = args[1][0]
    stk.m2.y = args[1][1]   
  }
  stk.fullfix() 
  stk.sup = args[2]
  if (args[3] != undefined){
    digits[args[2][0]] = args[3]
    digitstate[args[2][0]] =args[3]
  }
}

function settarg(id,args){
//args = [targpos,sup,waste,setdigit]
  var stk = idstk(id)
  stk.targ = {x:args[0][0],y:args[0][1],l:args[0][2],a:args[0][3],fun:function(a){
    var s = idstk([a[0]])
    s.sup = a[1]
    s.fullfix()
    if (a[2]){
      s.wasted = true
    }
    if (a[3] != undefined){

      digits[a[1][0]] = a[3]
      digitstate[a[1][0]] =a[3]

    }
  },args:[id,args[1],args[2],args[3]]}

}



function increment(di,wrap){
  var lstk = []
  var sx = 0
  var sy = 0
  var nstk = null
  var sxy = function(){sx = stk.m1.x;sy = stk.m1.y}
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

          sxy()
          nstk = new Stk(sx,sy,sl,-PI/2)
          stks.push(nstk)
          startswing(nstk.id,[2,30])
          animq.push([nstk.id,7,stopswing,[1,[sx-sl,sy+sl],[di,3]]])
            
          nstk = new Stk(sx-sl,sy+sl,sl,0)
          nstk.fullfix()
          stkpool.push(nstk)
          animq.push([nstk.id,30,startswing,[1,0]])
          animq.push([nstk.id,100,stopswing,[2,[sx-sl,sy+sl*2],[di,4]]])
        
        } else if (stk.sup[1] == 5){
          
          sxy()
          animq.push([stk.id,60,startswing,[2,30]])
          animq.push([stk.id,68,stopswing,[1,[sx-sl,sy+sl],[di,6]]])
          
          nstk = new Stk(choice([-10,width+10]),BD[3]-10,sl,0)
          stks.push(nstk)
          settarg(nstk.id,[[stk.m1.x-sl,stk.m1.y-sl,-1,0],[di,0],false,2])
 
        }
      
      
      // TWO
      
      }else if (digits[di] == 2){
        if (wrap != 3){
          if (stk.sup[1] == 4){
            stk.fullfree()
            animq.push([stk.id,70,settarg,[[choice([-100,width+100]),-1,-1,-1],[-1,-1],true]])
            
            sxy()
            nstk = new Stk(sx+sl,sy,sl*0.8,-PI)
            nstk.fullfix()
            stks.push(nstk)
            animq.push([nstk.id,30,startswing,[1,0]])
            animq.push([nstk.id,100,stopswing,[2,[sx+sl,sy+sl],[di,5],3]])
          }
        }else{
          if (stk.sup[1] == 3){
            stk.m1.x = stk.m1.x+sl
            stk.m2.x = stk.m2.x-sl
            sxy()
            startswing(stk.id,[1,0])
            animq.push([stk.id,70,stopswing,[2,[sx,sy+sl],[di,5]]])
           
          }else if (stk.sup[1] == 0){
            sxy()
            var nstk = new Stk(sx,sy,sl,0)
            stks.push(nstk)
            startswing(nstk.id,[1,0])
            animq.push([nstk.id,80,stopswing,[2,[sx,sy+sl],[di,1],0]])
          }
        }
        
        
      // THREE  
        
      } else if (digits[di] == 3){
        if (wrap != 4){
            if (stk.sup[1] == 0){
              sxy()
              startswing(stk.id,[1,0])
              animq.push([stk.id,70,stopswing,[2,[sx,sy+sl],[di,1],4]])
              
            }if (stk.sup[1] == 6){
              stk.fullfree()
              animq.push([stk.id,70,settarg,[[choice([-100,width+100]),-1,-1,-1],[-1,-1],true]])
            }
        } else{
          if (stk.sup[1] == 3){
            
            sxy()
            startswing(stk.id,[1,0])
            animq.push([stk.id,70,stopswing,[2,[sx,sy+sl],[di,4]]])
           
          }else if (stk.sup[1] == 0){
            sxy()
            var nstk = new Stk(sx,sy,sl,0)
            stks.push(nstk)
            startswing(nstk.id,[1,0])
            animq.push([nstk.id,80,stopswing,[2,[sx,sy+sl],[di,1],0]])
          }
        }
        
        
      // FOUR  
        
      } else if (digits[di] == 4){
        
        if (stk.sup[1] == 2){
          sxy()
          startswing(stk.id,[2,-30])
          stk.l = sl*0.9
          animq.push([stk.id,42,stopswing,[1,[sx,sy+sl*2],[di,5]]])
          animq.push([stk.id,43,startswing,[1,30]])
          animq.push([stk.id,52,stopswing,[2,[sx-sl,sy+sl*2],[di,6]]])
          
          nstk = new Stk(choice([-10,width+10]),BD[3]-10,sl,0)
          stks.push(nstk)
          settarg(nstk.id,[[sx-sl,sy,-1,0],[di,0],false,5])
        }
        
      
      // FIVE
    
      }else if (digits[di] == 5){
        if (wrap != 6){
          if (stk.sup[1] == 3){
            sxy()
            nstk = new Stk(sx,sy,sl,0)
            stks.push(nstk)
            startswing(nstk.id,[1,0])
            animq.push([nstk.id,70,stopswing,[2,[sx,sy+sl],[di,4],6]])
          }
        }else{
          if (stk.sup[1] == 3){
            sxy()
            startswing(stk.id,[1,0])
            animq.push([stk.id,70,stopswing,[2,[sx,sy+sl],[di,4]]])
            
          }else if (stk.sup[1] == 0){
            sxy()
            
            nstk = new Stk(sx+sl,sy,sl,-PI)
            stks.push(nstk)
            startswing(nstk.id,[1,0])
            animq.push([nstk.id,70,stopswing,[2,[sx+sl,sy+sl],[di,2],0]])
          }
        }
        
        
      // SIX  
        
      }else if (digits[di] == 6){
        if (stk.sup[1] == 3 || stk.sup[1] == 4 || stk.sup[1] == 6){
          stk.fullfree()
          animq.push([stk.id,floor(random(70,300)),settarg,[[choice([-100,width+100]),-1,-1,-1],[-1,-1],true]])
          
        }
        if (stk.sup[1] == 0){
          sxy()
          nstk = new Stk(sx+sl,sy,sl,-PI)
          nstk.fullfix()
          stks.push(nstk)
          animq.push([nstk.id,10,startswing,[1,0]])
          animq.push([nstk.id,80,stopswing,[2,[sx+sl,sy+sl],[di,2],7]])
          
        }
        
      // SEVEN  
        
        
      }else if (digits[di] == 7){
        if (stk.sup[1] == 1){
          sxy()
          nstk = new Stk(sx,sy+sl,sl,PI/2)
          stks.push(nstk)
          
          startswing(nstk.id,[1,30])
          nstk.l = sl*0.9
          animq.push([nstk.id,90,stopswing,[2,[sx,sy+sl*2],[di,4]]])
          
          nstk = new Stk(width+10,BD[3]-10,sl,0)
          stks.push(nstk)
          settarg(nstk.id,[[sx,sy+sl,-1,0],[di,3],false])
          
          nstk = new Stk(width+100,BD[3]-10,sl,0)
          stks.push(nstk)
          settarg(nstk.id,[[sx,sy+sl*2,-1,0],[di,6],false,8])
          
        }
        
      // EIGHT  
        
        
      }else if (digits[di] == 8){
        if (stk.sup[1] == 4){
          sxy()
          startswing(stk.id,[2,10])
          stk.l = sl
          
          animq.push([stk.id,60,function(id,args){
            idstk(id).fullfree()
            idstk(id).m2.v = {x:0,y:0}
            digits[args[0]] = 9
            digitstate[args[0]] = 9
          },[di]])
          
          animq.push([stk.id,120,settarg,[[choice([-100,width+100]),-1,-1,-1],[-1,-1],true]])
          
        }
        
      // NINE  
        
      }else if (digits[di] == 9){
        if (stk.sup[1] == 3){
          sxy()
          startswing(stk.id,[1,0])
          animq.push([stk.id,70,stopswing,[2,[sx,sy+sl],[di,4],0]])
          
        }
        
        
      // ZERO  
        
      }else if (digits[di] == 0){
        if (stk.sup[1] == 0){
          stk.fullfree()
          animq.push([stk.id,70+random(200),settarg,[[choice([-100,width+100]),-1,-1,-1],[-1,-1],true]])
          animq.push([stk.id,10,function(id,args){
            digits[args[0]] = 1
            digitstate[args[0]] = 1
          },[di]])
          
        }else if (stk.sup[1] == 1 || stk.sup[1] == 4 || stk.sup[1] == 6){
          stk.fullfree()
          animq.push([stk.id,70+random(200),settarg,[[choice([-100,width+100]),-1,-1,-1],[-1,-1],true]])
          
          
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

  if (key=="d"){
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
    if (key=="d"){text(stk.sup,stk.m1.x,stk.m1.y)}
    if (stk.wasted == true){
      
      stks.splice(i,1)
      i -= 1
    }
    //ellipse(stk.m1.x,stk.m1.y,10,10)
  }
  ANIM()

  if (key=="d"){

  }

  

}
function mousePressed(){
  //increment(0)
  //increment(1)
  //increment(2)
  //increment(4)
}
