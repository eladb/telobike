var uijs = require('uijs');
var box = uijs.box;


var b = box();

var ts = Date.now();
var frames = 0;
var fstTime = true;
var blue = 0;
var counter = 35;
lastFrameRate = 0;

b.ondraw = function(ctx) {  
  /*

  var x = 0;
  var holder = [];
  function fun(num){
    return num * 5 + 4;
  }

  var funfun = fun;

  var startPrepTime = Date.now();
  
  for (var i = 0; i < 2000000; i++) {
    holder.push(i);
  };

  var stopPrepTime = Date.now();

  var deltaTime = (stopPrepTime - startPrepTime) / 1000;

  console.log("Prep time: " + deltaTime);

  var result = 0;

  var startTestTime = Date.now();
  
  for (var i = 0; i < holder.length; i++) {
    this.result = funfun(holder.pop(i));
  };

  var stopTestTime = Date.now();

  var deltaTime = (stopTestTime - startTestTime) / 1000;

  console.log("Test time: " + deltaTime);



  return;
  
  */

  //ctx.fillStyle = 'white';
  //ctx.fillStyle = "rgba(255,255," + blue.toString() + ",1)";
  //console.log(ctx.fillStyle);
  //blue++;
  //if (blue > 255) { blue = 0; };
  //ctx.fillRect(0, 0, this.width, this.height);

  var drawSmallRectsWithoutUsingBoxes = false;
  if (drawSmallRectsWithoutUsingBoxes) {
    for (var i = 0; i < counter; i++) {
      ctx.fillStyle = 'red';
      ctx.fillRect(i * 10, i * 10, 10,10);
    };

    for (var i = 0; i < counter; i++) {
      ctx.fillStyle = 'red';
      ctx.fillRect(i * 10, 20 + (i * 10), 10,10);
    };

    for (var i = 0; i < counter; i++) {
      ctx.fillStyle = 'red';
      ctx.fillRect(i * 10, 40 + (i * 10), 10,10);
    };
  }
  else{
    var iterations = counter * 3;
    for (var i = 0; i < iterations; i++) {
      this.rectRenderer.render(ctx, i);
    }
  }

  var newTime = Date.now();
  frames++;
  var deltaTime = (newTime - ts) / 1000;
  if ((deltaTime) > 1) {
    if(lastFrameRate === 0){
      lastFrameRate = frames / deltaTime; 
    }
    //lastFrameRate = (lastFrameRate * 0.9) + ((frames / deltaTime) * 0.1);
    lastFrameRate = frames / deltaTime;
    //console.log("fps: " + lastFrameRate);
    //console.log("here");
    frames = 0;
    ts = newTime;
  };
};

/*
for (var i = 0; i < counter; i++) {
  
  var r1 = box({
    x: i * 10,
    y: i * 10,
    width: 10,
    height: 10,
  });
  r1.cachedX = r1.x;
  r1.cachedY = r1.y;
  r1.cachedW = r1.width;
  r1.cachedH = r1.height;
  var r2 = box({
    x: i * 10,
    y: 20 + (i * 10),
    width: 10,
    height: 10,
  });
  r2.cachedX = r2.x;
  r2.cachedY = r2.y;
  r2.cachedW = r2.width;
  r2.cachedH = r2.height;
  var r3 = box({
    x: i * 10,
    y: 40 + (i * 10),
    width: 10,
    height: 10,
  });
  r3.cachedX = r3.x;
  r3.cachedY = r3.y;
  r3.cachedW = r3.width;
  r3.cachedH = r3.height;
  var ondraw = function(ctx) {
    ctx.fillStyle = 'red';
    ctx.fillRect(this.x, this.y, this.width, this.height);
  };
  r1.ondraw = ondraw;
  r2.ondraw = ondraw;
  r3.ondraw = ondraw;

  b.add(r1);
  b.add(r2);
  b.add(r3);
  

};
*/

var r1 = box({
  width: 10,
  height: 10,
});
r1.x = function(){
  return (this.index % counter) * this.width;
};
r1.y = function(){
  var placeInRow = (this.index % counter);
  var rowNumber = Math.floor(this.index / counter );
  return (rowNumber * 40) + (placeInRow * this.width);
};
r1.xx = function(){
  return (this.index % counter) * this.widthh;
};
r1.yy = function(){
  var placeInRow = (this.index % counter);
  var rowNumber = Math.floor(this.index / counter );
  return (rowNumber * 40) + (placeInRow * this.widthh);
};
r1.widthh = 10;
r1.heightt = 10;
var render = function(ctx, index) {
  ctx.fillStyle = 'red';

  var useBoxProperties = false;
  if (useBoxProperties) {
    this.index = index;  
    ctx.fillRect(this.x, this.y, this.width, this.height);
    //ctx.fillRect(this.xx(), this.yy(), this.widthh, this.heightt);
  }
  else{
    var placeInRow = (index % counter);
    var rowNumber = Math.floor(index / counter );
    ctx.fillRect((index % counter) * 10, (rowNumber * 40) + (placeInRow * 10), 10, 10);  
  }
};
r1.render = render;
b.rectRenderer = r1;

module.exports = b;
