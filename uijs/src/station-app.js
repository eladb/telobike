var station = require('./station-panel');
var uijs = require('uijs');
var box = uijs.box;
var animate = uijs.animation;
var button = require('uijs-controls').button;

var app = box();

app.ondraw = function(ctx) {
  ctx.fillStyle = 'red';
  ctx.fillRect(0, 0, this.width, this.height);
};

var p = app.add(station({
  y: -400,
}));

var toggle_button = app.add(button({
  x: 10,
  y: 300,
  width: 200,
  height: 50,
  text: 'toggle',
}));

var opened = false;

toggle_button.on('click', function() {
  if (opened) {
    p.animate({ y: -400 }, { duration: 500 });
    opened = false;
  }
  else {
    p.animate({ y: 0 }, { duration: 500 });
    opened = true;
  }
});

module.exports = app;

