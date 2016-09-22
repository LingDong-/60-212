mat = []
ssize = 600
msize = 40
sl = 25
sw = 6
c1 = [45,40,35]
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

  this.fric.x = 0.9
  this.fric.y = 0.9
  this.v.x *= this.fric.x
  this.v.y *= this.fric.y
}

Dot.prototype.appForce = function(f,dir){
  var ax = f*cos(dir) / this.m
  var ay = f*sin(dir) / this.m
  this.v.x += ax
  this.v.y += ay
}

Dot.prototype.remoteRepel = function(x0,y0,f){
  var d = dist(this.x,this.y,x0,y0)
  var a = atan2(y0-this.y,x0-this.x)
  this.appForce(-pow(d,-1.6)*f,a)
 
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




function setup(){
  createCanvas(ssize+100,ssize+100)
  for (var i = 0; i < msize; i++){
    mat.push([])
    for (var j = 0; j < msize; j++){
      var stk = new Stk(j*(ssize/msize),i*(ssize/msize),sl,PI/2)
      stk.appTorque(random(-20,20))
      mat[i].push(stk)
      
    }
  }
}


function draw(){
  background(c2)
  translate(50,50)
  for (var i = 0; i < msize; i++){
    for (var j = 0; j < msize; j++){
      var stk = mat[i][j]
      if (stk.phys){
        stk.update()
      }
      if (mouseIsPressed){
        stk.m1.remoteRepel(mouseX-50,mouseY-50,100)
        stk.m2.remoteRepel(mouseX-50,mouseY-50,100)
      }
      stroke(c1)
      line(stk.m1.x,stk.m1.y,stk.m2.x,stk.m2.y)
    }
  }  
}