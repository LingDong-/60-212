L = []
stkN = 100
stkL = 300
function setup() {
  createCanvas(windowWidth,windowHeight)
  L = []
  for (var i = 0; i < stkN; i++){
    L.push({x:random(width),y:random(height),l:stkL,a:random(PI)})
  }
  //noLoop()
}

function endpt(ln){
  return {x:ln.x+ln.l*cos(ln.a),y:ln.y+ln.l*sin(ln.a)}
}

function intersect(l1,l2){
  var k1 = tan(l1.a)
  var k2 = tan(l2.a)
  var b1 = l1.y-k1*l1.x
  var b2 = l2.y-k2*l2.x
  var xi = (b2-b1)/(k1-k2)
  var yi = xi*k1+b1
  return {x:xi,y:yi}
}


function onseg(pt,ln){
  var xmax = max(ln.x,endpt(ln).x)
  var xmin = min(ln.x,endpt(ln).x)
  var ymax = max(ln.y,endpt(ln).y)
  var ymin = min(ln.y,endpt(ln).y)
  return pt.x > xmin && pt.x < xmax && pt.y > ymin && pt.y < ymax
}

function draw() {
  background(255)
  stroke(0)
  strokeWeight(2)
  for (var i = 0; i < L.length; i++){
    L[i].a += 0.1
    line(L[i].x,L[i].y,endpt(L[i]).x,endpt(L[i]).y)
  }
  for (var i = 0; i < L.length; i++){
    for (var j = 0; j < L.length; j++){
      if (i != j){
        var its = intersect(L[i],L[j])

        if (onseg(its,L[i]) && onseg(its,L[j])){
          ellipse(its.x,its.y,10,10)
        }
      }
    }
  }
}

function mousePressed(){
  setup()
}