R = 200
R0 = 24
R1 = 80
RM = 700

bgc = [50,50,50]

palette = [[255,255,255]]
palette = [[70,145,116],[243,232,144],[251,171,106],[204,72,70],[150,60,66]]
palette = [[255,150,255],[255,255,100],[100,255,150],[150,240,250]]

sw = 20
tapes = []


function wtrand(func){
  var x = random()
  var y = random()
  if (y<func(x)){
    return x
  }else{
    return wtrand(func)
  }
}

function choice(list){
  return list[floor(random(list.length))]
}


function tex(w,col,bord){
  var img = createImage(w*2, w*2);
  img.loadPixels();
  for (i = 0; i < img.width; i++) {
    for (j = 0; j < img.height; j++) {
      img.set(i, j, color(col));
      if (bord){
        if ((bord[0] > 0 && j<bord[0])
          ||(bord[1] > 0 && j>img.width-bord[1]-1)
          ||(bord[2] > 0 && i<bord[2])
          ||(bord[3] > 0 && i>img.height-bord[3]-1)){
          img.set(i, j, color(bgc));
          
        }

      }
    }
  }
  img.updatePixels();
  return img
}

var Tape = function(l){
  this.r = map(wtrand(function(x){return 1/pow((x+1),10)}),0,1,R1,RM)
  this.a = random(PI*2)
  this.roty = random(PI*2)
  this.spd = PI/20
  this.seg = PI/20
  this.rp = 1-(this.r-R1)/RM
  this.ox = R0+(R-R1)*this.rp+this.r
  this.band = []
  this.col = choice(palette)
  for (var i = 0; i < l; i++){
    this.band.push([this.a-i*this.seg])
  }
  this.tx = tex(sw,this.col,[5,5,0,0])
  this.txtop = tex(sw,this.col,[5,5,5,0])
  this.txend = tex(sw,this.col,[5,5,0,5])
}
Tape.prototype.update = function(){
  for (var i = 0; i < this.band.length; i++){

    this.band[i][0] -= this.spd//*(-sin(0.2*frameCount)+2)
    
  }   
}
Tape.prototype.plot = function(){
  push()
  rotateY(this.roty)
  for (var i = 0; i < this.band.length; i++){
    var b = this.band[i]
    var x0 = this.ox
    var y0 = 0
    push()
    
    translate(x0+this.r*cos(b[0]),y0+this.r*sin(b[0]))
    
    rotateZ(PI/2-b[0])
    rotateX(PI/2)

    if (i==0){
      texture(this.txtop)
    }else if (i==this.band.length-1){
      texture(this.txend)
    }else{
      texture(this.tx)
    }
    plane(this.r*sin(this.seg/2)+1,sw)
    pop()
  }  
  pop()
}




function setup() {
  createCanvas(500,500,WEBGL)
  
  for (var i = 0; i < 50; i++){
    tapes.push(new Tape(10))
  }
  //frameRate(1)
}

function draw() {
  //translate(width/2,height/2)
  rotateX(PI/5)
  translate(0,-10,0)
  //rotateY(frameCount*PI/40)

  background(bgc)
  
  for (var i = 0; i < tapes.length; i++){
    var t = tapes[i]
    t.update()
    t.plot()
  }

  if (frameCount<=80){
    //print("saving")
    //save(frameCount+".jpg");
  }  
}